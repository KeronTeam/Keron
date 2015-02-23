#pragma once
#include <atomic>

namespace keron {
namespace server {

///! 0 while server is alive, stop code otherwise.
extern std::atomic_int stop;

/*! Register signal handlers (cross-platform).
 *
 * Register signal handlers to allow proper shutdown of the server.
 *
 * \throw std::system_error with native error code if the signals cannot be registered.
 */
void register_signal_handlers();

} // namespace server
} // namespace keron
