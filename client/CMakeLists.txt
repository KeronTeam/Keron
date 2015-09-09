cmake_minimum_required(VERSION 3.1)
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
)

set(REFERENCES
    System 
    Assembly-CSharp
    UnityEngine
)

make_csproj(
  TARGET client
  ASSEMBLY_NAME KeronClient
  ROOT_NAMESPACE client
  SOURCES ${SOURCES}
  FRAMEWORK v3.5
  REFERENCES ${REFERENCES}
  PROJECT_REFERENCES schemas-net enet-cs flatbuffers-net
  ADDITIONAL_LIB_PATHS ${ASSEMBLIES_PATH}
)

get_target_property(CLIENT_DLL client DLL)

install(
        FILES "${CLIENT_DLL}"
        DESTINATION client
        PERMISSIONS
          OWNER_READ OWNER_WRITE OWNER_EXECUTE
          GROUP_READ
          WORLD_READ
    )
