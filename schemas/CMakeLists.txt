cmake_minimum_required(VERSION 3.0)
project(Keron-Schemas)
set(SCHEMAS server.fbs netmessages.fbs flightctrlstate.fbs)
set(SCHEMAS_TARGET_DEPS "")

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
  list(APPEND SCHEMAS_TARGET_DEPS ${SCHEMA_GENERATED})
endforeach(SCHEMA)

add_custom_target(schemas DEPENDS ${SCHEMAS_TARGET_DEPS})
