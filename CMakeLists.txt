cmake_minimum_required(VERSION 3.1)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/Modules")
project(Keron)
set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
find_package(Threads REQUIRED)

set(EXTERNALS spdlog enet)
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
    list(APPEND EXTERNALS flatbuffers)
endif()

foreach(EXTERNAL IN LISTS EXTERNALS)
  add_subdirectory(${EXTERNAL})
endforeach(EXTERNAL)

set_property(TARGET flatbuffers flatc PROPERTY CXX_STANDARD 11)


set(LMDB_SOURCE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/lmdb/libraries/liblmdb)
set(LMDB_SRCS
    ${LMDB_SOURCE_PATH}/mdb.c
    ${LMDB_SOURCE_PATH}/midl.c
)
add_library(lmdb ${LMDB_SRCS})
target_include_directories(lmdb PUBLIC ${LMDB_SOURCE_PATH})
target_link_libraries(lmdb ${CMAKE_THREAD_LIBS_INIT})

add_subdirectory(cmake/Libraries/FlatBuffersNet)
add_subdirectory(cmake/Libraries/ENetCS)

add_subdirectory(schemas)
add_subdirectory(server)
add_subdirectory(client)
add_subdirectory(client-cpp)
