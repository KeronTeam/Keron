#pragma once
#include <atomic>

namespace keron {
namespace server {

extern std::atomic_int stop;
int register_signal_handlers();

} // namespace server
} // namespace keron
