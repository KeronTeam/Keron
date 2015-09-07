cmake_minimum_required(VERSION 3.1)

project(Keron-Client)

include(CSProj)

set(SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/Connection/ConnexionUtils.cs
    ${CMAKE_CURRENT_SOURCE_DIR}/UserInterface/AKeronWindow.cs
    ${CMAKE_CURRENT_SOURCE_DIR}/UserInterface/ChatWindow.cs
    ${CMAKE_CURRENT_SOURCE_DIR}/UserInterface/ConnexionWindow.cs)

get_target_property(ENET_ASSEMBLY_PATH enet-cs ASSEMBLY_PATH)
get_target_property(FLATBUFFERS_ASSEMBLY_PATH flatbuffers-net ASSEMBLY_PATH)
get_target_property(SCHEMAS_ASSEMBLY_PATH schemas-net ASSEMBLY_PATH)
set(ASSEMBLIES_PATH
        ${KSP_MANAGED_PATH}
        ${ENET_ASSEMBLY_PATH}
        ${FLATBUFFERS_ASSEMBLY_PATH}
        ${SCHEMAS_ASSEMBLY_PATH})

set(REFERENCES
    KeronSchemas
    ENet
    FlatBuffers
    UnityEngine
    Assembly-CSharp
    System
    mscorlib)

make_csproj(
  TARGET client
  ASSEMBLY_NAME KeronClient
  ROOT_NAMESPACE KeronClient
  SOURCES ${SOURCES}
  FRAMEWORK v3.5
  REFERENCES ${REFERENCES}
  ADDITIONAL_LIB_PATHS ${ASSEMBLIES_PATH}
  NOSTDLIB TRUE
  UNSAFE TRUE
)

add_dependencies(client schemas-net enet-cs flatbuffers-net)

get_target_property(CLIENT_DLL client DLL)

install(
        FILES "${CLIENT_DLL}"
        DESTINATION client
        PERMISSIONS
          OWNER_READ OWNER_WRITE OWNER_EXECUTE
          GROUP_READ
          WORLD_READ
    )
