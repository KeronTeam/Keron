include(CMakeParseArguments)

find_program(CSBUILD msbuild)
if (NOT CSBUILD)
  find_program(CSBUILD xbuild)
endif()

if (NOT CSBUILD)
  message(WARNING "msbuild (or xbuild) NOT found but required for C#. Projects will NOT be generated.")
else()
  message(STATUS "CSBUILD: ${CSBUILD}")
endif()

set(CSPROJ_LOCATION "${CMAKE_CURRENT_LIST_DIR}" CACHE FILEPATH "csproj directory")

function(sources_to_xml INPUTS OUT)
  set(${OUT})
  foreach(SRC IN LISTS ${INPUTS})
    list(APPEND ${OUT} "<Compile Include=\"${SRC}\" />")
  endforeach()
  string(REPLACE ";" "\n" ${OUT} "${${OUT}}")
  set(${OUT} ${${OUT}} PARENT_SCOPE)
endfunction(sources_to_xml)

function(references_to_xml INPUTS OUT HINT)
  set(${OUT})
  foreach(REF IN LISTS ${INPUTS})
    list(APPEND ${OUT} "<Reference Include=\"${REF}\"><Private>False</Private></Reference>")
  endforeach()
  string(REPLACE ";" "\n" ${OUT} "${${OUT}}")
  set(${OUT} ${${OUT}} PARENT_SCOPE)
endfunction(references_to_xml)

function(make_csproj)
  set(oneValueArgs TARGET ASSEMBLY_NAME ROOT_NAMESPACE FRAMEWORK NOSTDLIB UNSAFE GUID PLATFORM)
  set(multiValueArgs SOURCES REFERENCES ADDITIONAL_LIB_PATHS)
  cmake_parse_arguments(CS "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # Sanity checks.
  if(NOT DEFINED CS_NOSTDLIB)
    set(CS_NOSTDLIB TRUE)
  endif()
  if(NOT DEFINED CS_UNSAFE)
    set(CS_UNSAFE FALSE)
  endif()
  if(NOT DEFINED CS_GUID)
    # namespace is a magic number, UUIDv4.
    string(UUID CS_GUID NAMESPACE b3bedb1e-a742-4966-9f26-bd2c7ee949a2 NAME ${PROJECT_NAME} TYPE SHA1 UPPER)
  endif()
  if (NOT DEFINED CS_PLATFORM OR "${CS_PLATFORM}" STREQUAL "")
    if (CMAKE_GENERATOR MATCHES "^Visual Studio")
      if (CMAKE_GENERATOR MATCHES "Win64$")
        set(PLATFORM x64)
      else()
        set(PLATFORM x32)
      endif()
    else()
      # Use native platform if none specified.
      math(EXPR CS_PLATFORM 8*${CMAKE_SIZEOF_VOID_P})
      set(CS_PLATFORM "x${CS_PLATFORM}")
    endif()
  endif()

  set(CS_OUTPUT_PATH "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}")
  set(CS_DLL "${CS_OUTPUT_PATH}/${CS_ASSEMBLY_NAME}.dll")
  set(CS_MDB "${CS_DLL}.mdb")

  sources_to_xml(CS_SOURCES CS_XML_SOURCES)
  references_to_xml(CS_REFERENCES CS_XML_REFERENCES CS_REFERENCES_HINT)

  configure_file(
    "${CSPROJ_LOCATION}/../Templates/Project.csproj.in"
    "${CMAKE_CURRENT_BINARY_DIR}/${CS_ASSEMBLY_NAME}.csproj"
    @ONLY
  )

  set(DEPENDENCIES)
  foreach(CS_SRC IN LISTS CS_SOURCES)
    if (NOT "${CS_SRC}" MATCHES "\\*")
      list(APPEND DEPENDENCIES "${CS_SRC}")
    endif()
  endforeach()

  add_custom_command(
    OUTPUT "${CS_DLL}" "${CS_MDB}"
    COMMAND "${CSBUILD}"
      ARGS "${CMAKE_CURRENT_BINARY_DIR}/${CS_ASSEMBLY_NAME}.csproj"
      DEPENDS ${DEPENDENCIES}
  )

  add_custom_target(${CS_TARGET} DEPENDS "${CS_DLL}" "${CS_MDB}")
  set_target_properties(${CS_TARGET} PROPERTIES ASSEMBLY_PATH ${CS_OUTPUT_PATH})

endfunction(make_csproj)
