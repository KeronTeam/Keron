#pragma once
#include <memory>
#include <string>
#include <exception>

#include <vedis.h>

namespace keron {
namespace db {

struct store {
	explicit store(const std::string &path = ":mem:")
	{
		int rc = vedis_open(&store_, path.c_str());

		if (rc != VEDIS_OK)
			throw std::bad_alloc();
	}

	~store() { vedis_close(store_); }

        store(const store &) = delete;
        store(const store &&) = delete;
        const store &operator=(const store &) = delete;

	operator vedis *() const { return store_; }
private:
    vedis *store_;
};
} // namespace store
} // namespace keron

// vim: shiftwidth=4 tabstop=4
