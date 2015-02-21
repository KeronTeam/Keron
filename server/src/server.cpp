#include <cstring>

#include <iostream>
#include <atomic>
#include <vector>
#include <functional>
#include <type_traits>

#include <flatbuffers/flatbuffers.h>
#include <flatbuffers/idl.h>
#include <flatbuffers/util.h>

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

int main(void)
{
	int errcode = keron::server::register_signal_handlers();

	if (errcode)
		return errcode;

	std::string filename("server.json");
	std::string serverschema;
	std::string configjson;

	if (!flatbuffers::LoadFile("schemas/server.fbs", false, &serverschema)) {
		std::cerr << "Cannot load server schema." << std::endl;
		return -1;
	}

	flatbuffers::Parser parser;
	parser.Parse(serverschema.c_str());
	if (!flatbuffers::LoadFile(filename.c_str(), false, &configjson)) {
		std::cerr << "No server configuration found. Creating a default one." << std::endl;
		flatbuffers::FlatBufferBuilder fbb;
		auto cfg = keron::server::CreateConfiguration(fbb, fbb.CreateString("*"), 18246, 8);
		auto generator = flatbuffers::GeneratorOptions();
		generator.strict_json = true;
		FinishConfigurationBuffer(fbb, cfg);
		flatbuffers::GenerateText(parser, fbb.GetBufferPointer(), generator, &configjson);

		if (!flatbuffers::SaveFile(filename.c_str(), configjson.c_str(), configjson.size(), false)) {
			std::cerr << "Unable to write default configuration!" << std::endl;
			return -2;
		}

		std::cerr << "A default configuration has been written.\n"
			<< "Check the content of `server.json`, and restart the server." << std::endl;
		return -4;
	}

	parser.Parse(configjson.c_str());

	auto settings = keron::server::GetConfiguration(parser.builder_.GetBufferPointer());

	std::vector<msg_handler> handlers(16);
	handlers[keron::messages::NetID_NONE] = msg_none;
	handlers[keron::messages::NetID_Chat] = msg_chat;
	handlers[keron::messages::NetID_FlightCtrl] = msg_flightctrl;

	keron::net::library enet;
	ENetAddress address;

	if (strncmp(settings->address()->c_str(), "*", 1) == 0) {
		std::cout << "any" << std::endl;
		address.host = ENET_HOST_ANY;
	}
	else
		enet_address_set_host(&address, settings->address()->c_str());

	address.port = settings->port();
	keron::net::host host(address, settings->maxclients(), 2);
	std::cout << "address.host = " << address.host << ", port = " << address.port << std::endl;

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
