#include "signal_handlers.h"

#include <cstring>
#include <cerrno>

#include <iostream>
#include <system_error>

#include <unistd.h>
#include <signal.h>


namespace keron {
namespace server {
std::atomic_int stop(0);

static void shutdown(int, siginfo_t *, void *)
{
	std::cout << "The server is going DOWN!" << std::endl;
	stop = 1;
}

void register_signal_handlers()
{
	struct sigaction action;
	memset(&action, 0, sizeof(action));
	action.sa_sigaction = &shutdown;
	action.sa_flags = SA_SIGINFO;

	for (const auto sig: { SIGTERM, SIGINT }) {
		if (sigaction(sig, &action, nullptr) < 0) {
			auto errcode = errno;
			throw std::system_error({errcode, std::system_category()}, "Cannot register signal handler");
		}
	}
}

} // namespace server
} // namespace keron
