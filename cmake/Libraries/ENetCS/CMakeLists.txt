cmake_minimum_required(VERSION 3.1)

project(ENetCS)

include(CSProj)

set(REFERENCES
  System
  System.Core
  mscorlib
)

set(SOURCES
    "${CMAKE_SOURCE_DIR}/enetcs/ENetCS/ENetException.cs"
    "${CMAKE_SOURCE_DIR}/enetcs/ENetCS/Event.cs"
    "${CMAKE_SOURCE_DIR}/enetcs/ENetCS/EventType.cs"
    "${CMAKE_SOURCE_DIR}/enetcs/ENetCS/Host.cs"
    "${CMAKE_SOURCE_DIR}/enetcs/ENetCS/Library.cs"
    "${CMAKE_SOURCE_DIR}/enetcs/ENetCS/Native/ENetApi.Platform.cs"
    "${CMAKE_SOURCE_DIR}/enetcs/ENetCS/Native/ENetApi.cs"
    "${CMAKE_SOURCE_DIR}/enetcs/ENetCS/Native/Structs.cs"
    "${CMAKE_SOURCE_DIR}/enetcs/ENetCS/Packet.IList.cs"
    "${CMAKE_SOURCE_DIR}/enetcs/ENetCS/Packet.UserData.cs"
    "${CMAKE_SOURCE_DIR}/enetcs/ENetCS/Packet.cs"
    "${CMAKE_SOURCE_DIR}/enetcs/ENetCS/PacketFlags.cs"
    "${CMAKE_SOURCE_DIR}/enetcs/ENetCS/Peer.cs"
    "${CMAKE_SOURCE_DIR}/enetcs/ENetCS/PeerState.cs"
    "${CMAKE_SOURCE_DIR}/enetcs/ENetCS/Properties/AssemblyInfo.cs"
)

make_csproj(
  TARGET enet-cs
  ASSEMBLY_NAME ENet
  ROOT_NAMESPACE ENet
  SOURCES ${SOURCES}
  FRAMEWORK v2.0
  REFERENCES ${REFERENCES}
  ADDITIONAL_LIB_PATHS ${KSP_MANAGED_PATH}
  NOSTDLIB TRUE
  UNSAFE TRUE
)
