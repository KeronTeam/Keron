#include <cstring>

#include <iostream>
#include <chrono>
#include <atomic>
#include <vector>
#include <functional>
#include <type_traits>
#include <stdexcept>

#include <flatbuffers/flatbuffers.h>
#include <flatbuffers/idl.h>
#include <flatbuffers/util.h>

#include <spdlog/spdlog.h>

#include "store.h"
#include "libenet.h"
#include "signal_handlers.h"

#include "flightctrlstate_generated.h"
#include "netmessages_generated.h"
#include "server_generated.h"


using msg_handler = std::function<void(keron::net::host &, const keron::net::event &, const keron::messages::NetMessage &)>;
using config_ptr = std::unique_ptr<const keron::server::Configuration>;

std::shared_ptr<spdlog::logger> logger;

void msg_none(keron::net::host &, const keron::net::event &, const keron::messages::NetMessage &)
{
	logger->info("No message.");
}

void msg_chat(keron::net::host &host, const keron::net::event &event, const keron::messages::NetMessage &msg)
{
	auto chat = reinterpret_cast<const keron::messages::Chat *>(msg.message());
	logger->info("Chat message: {}", chat->message()->c_str());
	keron::net::packet response(event.packet->data, event.packet->dataLength, event.packet->flags);
	host.broadcast(event.channelID, response);
}

void msg_flightctrl(keron::net::host &host, const keron::net::event &event, const keron::messages::NetMessage &flight)
{
	auto flightCtrl = reinterpret_cast<const keron::messages::FlightCtrl *>(flight.message());
	logger->info("Flight control state");
}

void msg_clocksync(keron::net::host &host, const keron::net::event &event, const keron::messages::NetMessage &msg)
{
	using keron::messages::CreateNetMessage;
	using keron::messages::NetID_ClockSync;
	using keron::messages::CreateClockSync;
	using keron::messages::FinishNetMessageBuffer;

	auto clocksync = reinterpret_cast<const keron::messages::ClockSync *>(msg.message());
	auto now = std::chrono::system_clock::now().time_since_epoch();
	auto server_ts = std::chrono::duration_cast<std::chrono::seconds>(now).count();
	auto client_ts = clocksync->clientTransmission();

	flatbuffers::FlatBufferBuilder fbb;
	auto replysync = CreateNetMessage(fbb, NetID_ClockSync, CreateClockSync(fbb, client_ts, server_ts).Union());

	FinishNetMessageBuffer(fbb, replysync);

	logger->info("Client TS: {}. Server TS: {}", client_ts, server_ts);
	keron::net::packet response(fbb.GetBufferPointer(), fbb.GetSize(), event.packet->flags);
	enet_peer_send(event.peer, event.channelID, response.release());
}

void load_configuration(flatbuffers::Parser &parser, const std::string &schema, const std::string &configfile)
{
	std::string serverschema;
	std::string configjson;
    parser.builder_.Clear();

	if (!flatbuffers::LoadFile(schema.c_str(), false, &serverschema))
                throw std::runtime_error("Cannot load server schema.");

	parser.Parse(serverschema.c_str());

	if (!flatbuffers::LoadFile(configfile.c_str(), false, &configjson)) {
		spdlog::get("config")->warn() << "No server configuration found. Creating a default one.";
		flatbuffers::FlatBufferBuilder fbb;
		auto cfg = keron::server::CreateConfiguration(fbb,
				fbb.CreateString("*"),
				('K' << 8) | ('S' << 4) | 'P', 8, fbb.CreateString("server.db"), fbb.CreateString("logs/keron.log"));
		auto generator = flatbuffers::GeneratorOptions();
		generator.strict_json = true;
		FinishConfigurationBuffer(fbb, cfg);
		flatbuffers::GenerateText(parser, fbb.GetBufferPointer(), generator, &configjson);

		if (!flatbuffers::SaveFile(configfile.c_str(), configjson.c_str(), configjson.size(), false))
                        throw std::runtime_error("Unable to write default configuration!");

                throw std::runtime_error(
			"A default configuration has been written. "
			"Check the content of `server.json`, and restart the server.");
	}

	parser.Parse(configjson.c_str());
}

std::vector<msg_handler> initialize_messages_handlers()
{
	using namespace keron::messages;

	std::vector<msg_handler> handlers(NetID_MAXNETID);
	handlers[NetID_NONE] = msg_none;
	handlers[NetID_Chat] = msg_chat;
	handlers[NetID_FlightCtrl] = msg_flightctrl;
	handlers[NetID_ClockSync] = msg_clocksync;

	return handlers;
}

ENetAddress initialize_server_address(const keron::server::Configuration &config)
{
	const std::string host(config.address()->c_str());
	uint16_t port{config.port()};

	ENetAddress address;

	if (host == "*")
		address.host = ENET_HOST_ANY;
	else
		enet_address_set_host(&address, host.c_str());

	address.port = port;
	return address;
}

int main(int argc, char *argv[])
{
	flatbuffers::Parser parser;

	{
		auto config = spdlog::stderr_logger_st("config");
		load_configuration(parser, "schemas/server.fbs", "server.json");
		spdlog::drop(config->name());
	}

	spdlog::set_async_mode();
	auto settings = keron::server::GetConfiguration(parser.builder_.GetBufferPointer());
	logger = spdlog::rotating_logger_mt("log", settings->logs()->c_str(), 5UL * 1024UL * 1024UL, 5);
	keron::server::register_signal_handlers();

	logger->info() << "Firing up storage.";
	keron::db::store datastore(settings->datastore()->c_str());

	logger->info() << "Preparing message handlers.";
	std::vector<msg_handler> handlers = initialize_messages_handlers();

	logger->info() << "Initializing network.";
	keron::net::library enet;

	auto address = initialize_server_address(*settings);
	keron::net::host host(address, settings->maxclients(), 2);
	if (!host) {
		logger->error() << "Creating host.";
		return -3;
	}

	keron::net::event event;

	logger->info("Listening on {}:{} with {} clients allowed.",
		settings->address()->c_str(), settings->port(), settings->maxclients());

	while (host.service(event, 100) >= 0 && !keron::server::stop) {
		switch (event.type) {
			case ENET_EVENT_TYPE_RECEIVE:
			{
				keron::net::packet packet(event.packet);
				keron::net::address address(event.peer->address);
				logger->debug("Received packet from {} on channel {} size {}B", address.ip(), event.channelID, packet.length());

				flatbuffers::Verifier verifier(packet.data(), packet.length());
				if (!keron::messages::VerifyNetMessageBuffer(verifier)) {
					logger->warn("Incorrect buffer received.");
					break;
				}


				auto message = keron::messages::GetNetMessage(packet.data());
				keron::messages::NetID id = message->message_type();
				logger->debug("Message is: {} {}", id, keron::messages::EnumNameNetID(id));

				if (!(id < handlers.size())) {
					logger->error("No available handlers for message ID {}", id);
					break;
				}

				handlers.at(id)(host, event, *message);

			}
				break;
			case ENET_EVENT_TYPE_CONNECT:
			{
				keron::net::address address(event.peer->address);
				logger->info("Connection from: {}", address.ip());
			}
				break;
			case ENET_EVENT_TYPE_DISCONNECT:
			{
				keron::net::address address(event.peer->address);
				logger->info("Disconnection from: {}", address.ip());
			}
				break;
			case ENET_EVENT_TYPE_NONE:
				// reached timeout without incomings.
				break;
			default:
				logger->error("Unhandled event {}", event.type);
		}
	}

	logger->info("Server is shutting down.");
	logger->flush();
	spdlog::drop_all();
	return 0;
}

// vim: shiftwidth=4 tabstop=4
