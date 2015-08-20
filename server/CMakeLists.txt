cmake_minimum_required(VERSION 3.1)
project(Keron-Server CXX)

set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
find_package(Threads REQUIRED)

set(SOURCES
  src/server.cpp
)

if (WIN32)
  list(APPEND SOURCES src/os/windows.cpp)
else(WIN32)
  list(APPEND SOURCES src/os/posix.cpp)
endif(WIN32)

add_executable(keron ${SOURCES})
set_property(TARGET keron PROPERTY CXX_STANDARD 11)
set_property(TARGET keron PROPERTY CXX_STANDARD_REQUIRED ON)
set_property(TARGET keron PROPERTY CXX_EXTENSIONS OFF)
target_link_libraries(keron spdlog enet flatbuffers lmdb ${CMAKE_THREAD_LIBS_INIT})
target_include_directories(keron PRIVATE
  include
  ${CMAKE_BINARY_DIR}/schemas
  ${CMAKE_SOURCE_DIR}/spdlog/include
  ${CMAKE_SOURCE_DIR}/flatbuffers/include
  ${CMAKE_SOURCE_DIR}/enet/include
  ${CMAKE_SOURCE_DIR}/lmdb/libraries/liblmdb
  ${CMAKE_SOURCE_DIR}/lmdbxx
)
add_dependencies(keron schemas)
