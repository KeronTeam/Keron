#include "signal_handlers.h"

#include <iostream>

#include <unistd.h>
#include <signal.h>
#include <cstring>


namespace keron {
namespace server {
std::atomic_int stop(0);

static void shutdown(int, siginfo_t *, void *)
{
	std::cout << "The server is going DOWN!" << std::endl;
	stop = 1;
}

int register_signal_handlers()
{
	struct sigaction action;
	memset(&action, 0, sizeof(action));
	action.sa_sigaction = &shutdown;
	action.sa_flags = SA_SIGINFO;

	if (sigaction(SIGTERM, &action, nullptr) < 0) {
		perror("Cannot register TERM signal handler.");
		return -1;
	}

	if (sigaction(SIGINT, &action, nullptr) < 0) {
		perror("Cannot register INT signal handler.");
		return -2;
	}

	return 0;
}

} // namespace server
} // namespace keron
