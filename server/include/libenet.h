#pragma once
#include <cstdint>
#include <memory>
#include <string>
#include <vector>
#include <algorithm>

#include <enet/enet.h>

namespace keron {
namespace net {

using event = ENetEvent;

using packet_ptr = std::unique_ptr<ENetPacket, decltype(&enet_packet_destroy)>;
using host_ptr = std::unique_ptr<ENetHost, decltype(&enet_host_destroy)>;

struct address final {
	address(const ENetAddress &address):addr(address) {}
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

struct library final {
	library() { enet_initialize(); }
	~library() { enet_deinitialize(); }
};

struct packet final {
	packet(ENetPacket *packet):packet_(packet, enet_packet_destroy) {}

	template<typename... Args>
	packet(Args&&... args)
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
	packet_ptr packet_;
};

struct host final {
	host(const ENetAddress &addr, int clients, int channels)
		:address(addr),
		server(enet_host_create(&address, clients, channels, 0, 0), enet_host_destroy)
	{}

	inline int service(event &evt, uint32_t timeout)
	{
		return enet_host_service(*this, &evt, timeout);
	}

	inline void broadcast(uint8_t channel, packet &p)
	{
		enet_host_broadcast(*this, channel, p.release());
	}

	operator ENetHost *() { return server.get(); }

private:
	ENetAddress address;
	host_ptr server;
};

}
} // namespace keron
// vim: shiftwidth=4 tabstop=4
