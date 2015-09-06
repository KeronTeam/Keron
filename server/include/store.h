#pragma once
#include <cstdint>

#include <memory>
#include <string>
#include <exception>

#include <lmdb++.h>

namespace keron {
namespace db {

struct store_t {
	explicit store_t(const std::string &path, const std::uint64_t size = 1UL * 1024UL * 1024UL * 1024UL)
    :env_(lmdb::env::create())
	{
        env_.set_mapsize(size);
        env_.open(path.c_str(), 0, 0664);
	}

	~store_t() = default;

    store_t(const store_t &) = delete;
    store_t(const store_t &&) = delete;
    const store_t &operator=(const store_t &) = delete;
    const store_t &operator=(store_t &&) = delete;

    const lmdb::env &get() const { return env_; }
    lmdb::env &get() { return env_; }

    lmdb::txn transaction() const
    {
        return lmdb::txn::begin(env_);
    }
private:
    lmdb::env env_;
};

template<typename T>
static lmdb::val make_val(const T &v)
{
    return lmdb::val(&v, sizeof(v));
}
} // namespace store
} // namespace keron

// vim: shiftwidth=4 tabstop=4
