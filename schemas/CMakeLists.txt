cmake_minimum_required(VERSION 3.0)
project(Keron-Schemas)
include(CSProj)

set(SCHEMAS server.fbs netmessages.fbs flightctrlstate.fbs)
set(SCHEMAS_TARGET_DEPS "")
set(SCHEMAS_NET_DEPS)

foreach(SCHEMA IN LISTS SCHEMAS)
  get_filename_component(SCHEMA_BASENAME ${SCHEMA} NAME_WE)
  get_filename_component(SCHEMA_PATH ${SCHEMA} ABSOLUTE)
  get_filename_component(SCHEMA_DIR ${SCHEMA_PATH} DIRECTORY)
  set(SCHEMA_GENERATED ${CMAKE_CURRENT_BINARY_DIR}/${SCHEMA_BASENAME}_generated.h)
  add_custom_command(
	OUTPUT ${SCHEMA_GENERATED}
	COMMAND flatc ARGS -o ${CMAKE_CURRENT_BINARY_DIR} -I ${CMAKE_CURRENT_SOURCE_DIR} -c ${SCHEMA}
	DEPENDS ${SCHEMA_PATH}
	WORKING_DIRECTORY ${SCHEMA_DIR}
  )
  add_custom_target(
    schema-${SCHEMA_BASENAME}-net
    COMMAND flatc -o ${CMAKE_CURRENT_BINARY_DIR} -I ${CMAKE_CURRENT_SOURCE_DIR} -n ${SCHEMA}
    DEPENDS ${SCHEMA_PATH}
    WORKING_DIRECTORY ${SCHEMA_DIR}
  )
  list(APPEND SCHEMAS_TARGET_DEPS ${SCHEMA_GENERATED})
  list(APPEND SCHEMAS_NET_DEPS schema-${SCHEMA_BASENAME}-net)
endforeach(SCHEMA)

get_target_property(FLATBUFFERS_ASSEMBLY_PATH flatbuffers-net ASSEMBLY_PATH)
make_csproj(
  TARGET schemas-net
  ASSEMBLY_NAME KeronSchemas
  ROOT_NAMESPACE keron
  SOURCES "${CMAKE_CURRENT_BINARY_DIR}/keron/*.cs" "${CMAKE_CURRENT_BINARY_DIR}/keron/messages/*.cs"
  FRAMEWORK v2.0
  REFERENCES FlatBuffers mscorlib
  ADDITIONAL_LIB_PATHS ${KSP_MANAGED_PATH} ${FLATBUFFERS_ASSEMBLY_PATH}
  NOSTDLIB TRUE
)

add_custom_target(schemas DEPENDS ${SCHEMAS_TARGET_DEPS})
add_dependencies(schemas-net ${SCHEMAS_NET_DEPS} flatbuffers-net)
