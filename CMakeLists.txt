cmake_minimum_required(VERSION 3.1)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/Modules")
project(Keron)
set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
find_package(Threads REQUIRED)

option(KERON_BUILD_SERVER "Enable the build of the server" ON)
option(KERON_BUILD_CLIENT "Enable the build of the client" ON)

if (NOT KERON_BUILD_SERVER AND NOT KERON_BUILD_CLIENT)
    message(SEND_ERROR "At least the server *or* the client must be built!")
endif()

set(EXTERNALS)

if (KERON_BUILD_SERVER)
    set(EXTERNALS spdlog enet)
endif(KERON_BUILD_SERVER)

if("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
    # There's currently an issue with clang and c++11 (flatbuffers forcefully sets c++0x).
    set(FlatBuffers_Library_SRCS
      ${CMAKE_CURRENT_SOURCE_DIR}/flatbuffers/include/flatbuffers/flatbuffers.h
      ${CMAKE_CURRENT_SOURCE_DIR}/flatbuffers/include/flatbuffers/hash.h
      ${CMAKE_CURRENT_SOURCE_DIR}/flatbuffers/include/flatbuffers/idl.h
      ${CMAKE_CURRENT_SOURCE_DIR}/flatbuffers/include/flatbuffers/util.h
      ${CMAKE_CURRENT_SOURCE_DIR}/flatbuffers/include/flatbuffers/reflection.h
      ${CMAKE_CURRENT_SOURCE_DIR}/flatbuffers/include/flatbuffers/reflection_generated.h
      ${CMAKE_CURRENT_SOURCE_DIR}/flatbuffers/src/idl_parser.cpp
      ${CMAKE_CURRENT_SOURCE_DIR}/flatbuffers/src/idl_gen_text.cpp
      ${CMAKE_CURRENT_SOURCE_DIR}/flatbuffers/src/reflection.cpp
    )

    set(FlatBuffers_Compiler_SRCS
      ${CMAKE_CURRENT_SOURCE_DIR}/flatbuffers/src/idl_gen_cpp.cpp
      ${CMAKE_CURRENT_SOURCE_DIR}/flatbuffers/src/idl_gen_general.cpp
      ${CMAKE_CURRENT_SOURCE_DIR}/flatbuffers/src/idl_gen_go.cpp
      ${CMAKE_CURRENT_SOURCE_DIR}/flatbuffers/src/idl_gen_python.cpp
      ${CMAKE_CURRENT_SOURCE_DIR}/flatbuffers/src/idl_gen_fbs.cpp
      ${CMAKE_CURRENT_SOURCE_DIR}/flatbuffers/src/flatc.cpp
    )
    add_library(flatbuffers STATIC ${FlatBuffers_Library_SRCS})
    target_include_directories(flatbuffers PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/flatbuffers/include)

    add_executable(flatc ${FlatBuffers_Compiler_SRCS})
    target_link_libraries(flatc flatbuffers)
    target_include_directories(flatc PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/flatbuffers/include)
    set_property(TARGET flatbuffers flatc PROPERTY CXX_STANDARD 11)
    set_property(TARGET flatbuffers flatc PROPERTY CXX_STANDARD_REQUIRED ON)
    set_property(TARGET flatbuffers flatc PROPERTY CXX_EXTENSIONS OFF)
else()
    set(FLATBUFFERS_BUILD_TESTS OFF)
    set(FLATBUFFERS_INSTALL "Enable the installation of targets." OFF)
    list(APPEND EXTERNALS flatbuffers)
endif()

foreach(EXTERNAL IN LISTS EXTERNALS)
  add_subdirectory(${EXTERNAL})
endforeach(EXTERNAL)

if (NOT MSVC)
    set_property(TARGET flatbuffers flatc PROPERTY CXX_STANDARD 11)
endif()

if (KERON_BUILD_CLIENT)
    add_subdirectory(cmake/Libraries/FlatBuffersNet)
    add_subdirectory(cmake/Libraries/ENetShared)
    add_subdirectory(cmake/Libraries/ENetCS)
endif(KERON_BUILD_CLIENT)

add_subdirectory(schemas)

if (KERON_BUILD_CLIENT)
    add_subdirectory(client)
endif(KERON_BUILD_CLIENT)

if (KERON_BUILD_SERVER)
    set(LMDB_SOURCE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/lmdb/libraries/liblmdb)
    set(LMDB_SRCS
        ${LMDB_SOURCE_PATH}/mdb.c
        ${LMDB_SOURCE_PATH}/midl.c
    )
    add_library(lmdb ${LMDB_SRCS})
    target_include_directories(lmdb PUBLIC ${LMDB_SOURCE_PATH})
    target_link_libraries(lmdb ${CMAKE_THREAD_LIBS_INIT})

    add_subdirectory(server)
endif(KERON_BUILD_SERVER)

