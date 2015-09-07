cmake_minimum_required(VERSION 3.1)
include(CSProj)

set(OUTPUT_PATH "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}")
set(FLATBUFFERS_DLL "${OUTPUT_PATH}/FlatBuffers.dll")
set(FLATBUFFERS_MDB "${FLATBUFFERS_DLL}.mdb")

get_filename_component(FLATBUFFERS_CSPROJ "${CMAKE_CURRENT_SOURCE_DIR}/../../../flatbuffers/net/FlatBuffers/FlatBuffers.csproj" ABSOLUTE)

add_custom_command(
  OUTPUT "${FLATBUFFERS_DLL}" "${FLATBUFFERS_MDB}"
  COMMAND "${CSBUILD}"
    ARGS
      /property:Configuration=${CMAKE_BUILD_TYPE}
      /property:OutputPath="${OUTPUT_PATH}"
      /property:BaseIntermediateOutputPath="${CMAKE_CURRENT_BINARY_DIR}/obj/"
      /property:AssemblySearchPaths="${KSP_MANAGED_PATH}"
      "${FLATBUFFERS_CSPROJ}"

)

add_custom_target(flatbuffers-net DEPENDS "${FLATBUFFERS_DLL}")
set_target_properties(flatbuffers-net PROPERTIES ASSEMBLY_PATH ${OUTPUT_PATH})
