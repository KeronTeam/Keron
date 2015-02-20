#include <cstring>

#include <iostream>
#include <atomic>
#include <vector>
#include <functional>

#include "flightctrlstate_generated.h"
#include "netmessages_generated.h"

#include "libenet.h"
#include "signal_handlers.h"


using msg_handler = std::function<void(keron::net::host &, const keron::net::event &, const keron::messages::NetMessage &)>;

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

	std::vector<msg_handler> handlers(16);
	handlers[keron::messages::Type_NONE] = msg_none;
	handlers[keron::messages::Type_Chat] = msg_chat;
	handlers[keron::messages::Type_FlightCtrl] = msg_flightctrl;

	keron::net::library enet;
	ENetAddress address;
	address.host = ENET_HOST_ANY;
	address.port = 54321;
	keron::net::host host(address, 8, 2);

	if (!host) {
		std::cerr << "ERROR: creating host." << std::endl;
		return -3;
	}

	keron::net::event event;

	std::cout << "Waiting for inputs." << std::endl;

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
				auto type = message->message_type();
				std::cout << "Message is: " << keron::messages::EnumNameType(type) << std::endl;

				if (!(type < handlers.size())) {
					std::cout << "No available handlers.";
					break;
				}

				handlers.at(type)(host, event, *message);

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
