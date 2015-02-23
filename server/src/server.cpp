#include <cstring>

#include <iostream>
#include <atomic>
#include <vector>
#include <functional>
#include <type_traits>
#include <stdexcept>

#include <flatbuffers/flatbuffers.h>
#include <flatbuffers/idl.h>
#include <flatbuffers/util.h>

#include "libvedis.h"
#include "libenet.h"
#include "signal_handlers.h"

#include "flightctrlstate_generated.h"
#include "netmessages_generated.h"
#include "server_generated.h"


using msg_handler = std::function<void(keron::net::host &, const keron::net::event &, const keron::messages::NetMessage &)>;
using config_ptr = std::unique_ptr<const keron::server::Configuration>;

void msg_none(keron::net::host &, const keron::net::event &, const keron::messages::NetMessage &)
{
	std::cout << "No message.\n";
}

void msg_chat(keron::net::host &host, const keron::net::event &event, const keron::messages::NetMessage &msg)
{
	auto chat = reinterpret_cast<const keron::messages::Chat *>(msg.message());
	std::cout << "Chat message: " << chat->message()->c_str() << std::endl;
	keron::net::packet response(event.packet->data, event.packet->dataLength, event.packet->flags);
	host.broadcast(event.channelID, response);
}

void msg_flightctrl(keron::net::host &host, const keron::net::event &event, const keron::messages::NetMessage &flight)
{
	auto flightCtrl = reinterpret_cast<const keron::messages::FlightCtrl *>(flight.message());
	std::cout << "Flight control state" << std::endl;
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
		std::cerr << "No server configuration found. Creating a default one." << std::endl;
		flatbuffers::FlatBufferBuilder fbb;
		auto cfg = keron::server::CreateConfiguration(fbb, fbb.CreateString("*"), 18246, 8, fbb.CreateString("server.vdb"));
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

	std::vector<msg_handler> handlers(3);
	handlers[NetID_NONE] = msg_none;
	handlers[NetID_Chat] = msg_chat;
	handlers[NetID_FlightCtrl] = msg_flightctrl;

	return handlers;
}

ENetAddress initialize_server_address(const keron::server::Configuration &config)
{
	const std::string host(config.address()->c_str());
	uint16_t port{config.port()};

	ENetAddress address;

	if (host != "*")
		address.host = ENET_HOST_ANY;
	else
		enet_address_set_host(&address, host.c_str());

	address.port = port;
	return address;
}

int main(void)
{
	std::cout << "Registering signal handlers." << std::endl;
	keron::server::register_signal_handlers();

	std::cout << "Loading server configuration." << std::endl;
	flatbuffers::Parser parser;
	load_configuration(parser, "schemas/server.fbs", "server.json");

	auto settings = keron::server::GetConfiguration(parser.builder_.GetBufferPointer());

	std::cout << "Firing up storage." << std::endl;
	keron::db::store datastore(settings->datastore()->c_str());

	std::cout << "Preparing message handlers." << std::endl;
	std::vector<msg_handler> handlers = initialize_messages_handlers();

	std::cout << "Initializing network." << std::endl;
	keron::net::library enet;

	auto address = initialize_server_address(*settings);
	keron::net::host host(address, settings->maxclients(), 2);
	if (!host) {
		std::cerr << "ERROR: creating host." << std::endl;
		return -3;
	}

	keron::net::event event;

	std::cout << "Listening on " << settings->address()->c_str() << ":" << settings->port()
		<< " " << settings->maxclients() << " clients allowed." << std::endl;

	while (host.service(event, 100) >= 0 && !keron::server::stop) {
		switch (event.type) {
			case ENET_EVENT_TYPE_RECEIVE:
			{
				keron::net::packet packet(event.packet);
				keron::net::address address(event.peer->address);
				std::cout
					<< "Received packet from "
					<< address.ip()
					<< " on channel " << static_cast<int>(event.channelID)
					<< " size " << packet.length() << std::endl;

				flatbuffers::Verifier verifier(packet.data(), packet.length());
				if (!keron::messages::VerifyNetMessageBuffer(verifier)) {
					std::cout << "Incorrect buffer received." << std::endl;
					break;
				}
					

				auto message = keron::messages::GetNetMessage(packet.data());
				keron::messages::NetID id = message->message_type();
				std::cout << "Message is: " << keron::messages::EnumNameNetID(id) << std::endl;

				if (!(id < handlers.size())) {
					std::cout << "No available handlers.";
					break;
				}

				handlers.at(id)(host, event, *message);

			}
				break;
			case ENET_EVENT_TYPE_CONNECT:
			{
				keron::net::address address(event.peer->address);
				std::cout << "Connection from: " << address.ip() << std::endl;
			}
				break;
			case ENET_EVENT_TYPE_DISCONNECT:
			{
				keron::net::address address(event.peer->address);
				std::cout << "Disconnection from: " << address.ip() << std::endl;
			}
				break;
			case ENET_EVENT_TYPE_NONE:
				// reached timeout without incomings.
				break;
			default:
				std::cout << "Unhandled event `" << event.type << "`\n";
		}
	}

	std::cout << "Server is shutting down." << std::endl;

	return 0;
}

// vim: shiftwidth=4 tabstop=4
