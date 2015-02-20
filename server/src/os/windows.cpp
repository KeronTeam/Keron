#include "signal_handlers.h"

#include <cstring>

#include <iostream>

#define WIN32_LEAN_AND_MEAN 1
#include <windows.h>


namespace keron {
namespace server {
std::atomic_int stop(0);

static BOOL handler(DWORD fdwCtrlType)
{

	switch (fdwCtrlType) {
		case CTRL_C_EVENT:
		case CTRL_CLOSE_EVENT:
			std::cout << "The server is going DOWN!" << std::endl;
			stop.store(1);
			return TRUE;
		case CTRL_BREAK_EVENT:
		case CTRL_LOGOFF_EVENT:
		case CTRL_SHUTDOWN_EVENT:
			std::cout << "The server is going DOWN!" << std::endl;
			stop.store(1);
			// Same return as the default case.
		default:
			return FALSE;
	}
}

int register_signal_handlers()
{
	return SetConsoleCtrlHandler((PHANDLER_ROUTINE)handler, TRUE) == TRUE;
}

} // namespace server
} // namespace keron
