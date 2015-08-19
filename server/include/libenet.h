#pragma once
#include <cstdint>
#include <memory>
#include <string>
#include <vector>
#include <algorithm>

#include <enet/enet.h>

namespace keron {
namespace net {

using event_t = ENetEvent;
using peer_t = ENetPeer;

using packet_ptr_t = std::unique_ptr<ENetPacket, decltype(&enet_packet_destroy)>;
using host_ptr_t = std::unique_ptr<ENetHost, decltype(&enet_host_destroy)>;

struct address_t final {
	address_t(const ENetAddress &address):addr(address) {}
	const std::string ip() const
	{
		std::vector<char> rawname(256);
		enet_address_get_host_ip(&addr, &rawname[0], rawname.size());
		rawname.erase(std::find(std::begin(rawname), std::end(rawname), 0), std::end(rawname));

		std::string name(rawname.begin(), rawname.end());
		return name;
	}

private:
	const ENetAddress &addr;
};

struct library_t final {
	library_t() { enet_initialize(); }
	~library_t() { enet_deinitialize(); }
};

struct packet_t final {
	packet_t():packet_t(static_cast<ENetPacket *>(nullptr)) {};
	packet_t(ENetPacket *packet):packet_(packet, enet_packet_destroy) {}

	template<typename... Args>
	packet_t(Args&&... args)
		:packet_(enet_packet_create(std::forward<Args>(args)...), enet_packet_destroy)
	{}

	inline std::size_t length() const
	{
		return packet_->dataLength;
	}

	inline uint8_t *data() const { return packet_->data; }
	inline ENetPacket * release() { return packet_.release(); }

	operator ENetPacket *() { return packet_.get(); }
private:
	packet_ptr_t packet_;
};

struct host_t final {
	host_t(const ENetAddress &addr, int clients, int channels)
		:address(addr),
		server(enet_host_create(&address, clients, channels, 0, 0), enet_host_destroy)
	{}

	inline int service(event_t &evt, uint32_t timeout)
	{
		return enet_host_service(*this, &evt, timeout);
	}

	inline void broadcast(uint8_t channel, packet_t &&p)
	{
		enet_host_broadcast(*this, channel, p.release());
	}

	operator ENetHost *() { return server.get(); }

private:
	ENetAddress address;
	host_ptr_t server;
};

struct incoming_t
{
	int *generation;
	event_t event;
};

struct outgoing_t
{
	peer_t *peer;
	packet_t payload;
	int *generation;
	enet_uint8 channelID;
};

}
} // namespace keron
// vim: shiftwidth=4 tabstop=4
