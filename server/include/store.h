#pragma once
#include <cstdint>

#include <memory>
#include <string>
#include <exception>

#include <lmdb++.h>

namespace keron {
namespace db {

struct store {
	explicit store(const std::string &path, const std::uint64_t size = 1UL * 1024UL * 1024UL * 1024UL)
    :env_(lmdb::env::create())
	{
        env_.set_mapsize(size);
        env_.open(path.c_str(), 0, 0664);
	}

	~store() = default;

    store(const store &) = delete;
    store(const store &&) = delete;
    const store &operator=(const store &) = delete;
    const store &operator=(store &&) = delete;
private:
    lmdb::env env_;
};
} // namespace store
} // namespace keron

// vim: shiftwidth=4 tabstop=4
