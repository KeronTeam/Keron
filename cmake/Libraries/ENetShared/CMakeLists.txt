cmake_minimum_required(VERSION 2.6)

project(enet-shared)

# The "configure" step.
include(CheckFunctionExists)
include(CheckStructHasMember)
include(CheckTypeSize)
check_function_exists("fcntl" HAS_FCNTL)
check_function_exists("poll" HAS_POLL)
check_function_exists("gethostbyname_r" HAS_GETHOSTBYNAME_R)
check_function_exists("gethostbyaddr_r" HAS_GETHOSTBYADDR_R)
check_function_exists("inet_pton" HAS_INET_PTON)
check_function_exists("inet_ntop" HAS_INET_NTOP)
check_struct_has_member("struct msghdr" "msg_flags" "sys/types.h;sys/socket.h" HAS_MSGHDR_FLAGS)
set(CMAKE_EXTRA_INCLUDE_FILES "sys/types.h" "sys/socket.h")
check_type_size("socklen_t" HAS_SOCKLEN_T BUILTIN_TYPES_ONLY)
unset(CMAKE_EXTRA_INCLUDE_FILES)

if(HAS_FCNTL)
    add_definitions(-DHAS_FCNTL=1)
endif()
if(HAS_POLL)
    add_definitions(-DHAS_POLL=1)
endif()
if(HAS_GETHOSTBYNAME_R)
    add_definitions(-DHAS_GETHOSTBYNAME_R=1)
endif()
if(HAS_GETHOSTBYADDR_R)
    add_definitions(-DHAS_GETHOSTBYADDR_R=1)
endif()
if(HAS_INET_PTON)
    add_definitions(-DHAS_INET_PTON=1)
endif()
if(HAS_INET_NTOP)
    add_definitions(-DHAS_INET_NTOP=1)
endif()
if(HAS_MSGHDR_FLAGS)
    add_definitions(-DHAS_MSGHDR_FLAGS=1)
endif()
if(HAS_SOCKLEN_T)
    add_definitions(-DHAS_SOCKLEN_T=1)
endif()

get_filename_component(ENET_ROOT "${PROJECT_SOURCE_DIR}/../../../enet/" ABSOLUTE)
include_directories(${ENET_ROOT}/include)
add_definitions(-DENET_DLL=1)

add_library(enet-shared SHARED
        "${ENET_ROOT}/callbacks.c"
        "${ENET_ROOT}/compress.c"
        "${ENET_ROOT}/host.c"
        "${ENET_ROOT}/list.c"
        "${ENET_ROOT}/packet.c"
        "${ENET_ROOT}/peer.c"
        "${ENET_ROOT}/protocol.c"
        "${ENET_ROOT}/unix.c"
        "${ENET_ROOT}/win32.c"
    )

if (WIN32)
  target_link_libraries(enet-shared ws2_32 winmm)
endif()

# The output name is somewhat a specific name for ENetCS usage.
set_target_properties(enet-shared PROPERTIES OUTPUT_NAME libenet)
