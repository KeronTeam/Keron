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

set(CSPROJ_LOCATION "${CMAKE_CURRENT_LIST_DIR}" CACHE FILEPATH "csproj directory" INTERNAL)

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
    set(XML_REF "<Reference Include=\"${REF}\"><Private>False</Private>")
    if (${HINT})
      message(STATUS "Using hint ${${HINT}} for ${REF}")
      set(XML_REF "${XML_REF}<HintPath>${${HINT}}/${REF}.dll</HintPath>")
    endif()
    set(XML_REF "${XML_REF}</Reference>")
    list(APPEND ${OUT} "${XML_REF}")
  endforeach()
  string(REPLACE ";" "\n" ${OUT} "${${OUT}}")
  set(${OUT} ${${OUT}} PARENT_SCOPE)
endfunction(references_to_xml)

function(project_references_to_xml INPUTS OUT)
  set(${OUT})
  foreach(REF IN LISTS ${INPUTS})
    get_target_property(REF_PATH ${REF} PROJECT_PATH)
    get_target_property(REF_GUID ${REF} GUID)
    get_target_property(REF_ASSEMBLY ${REF} ASSEMBLY)
    get_property(REF_HAS_GUID TARGET ${REF} PROPERTY GUID SET)
    if (REF_HAS_GUID)
    	set(XML_REF "<ProjectReference Include=\"${REF_PATH}\"><Project>{${REF_GUID}}</Project><Name>${REF}</Name></ProjectReference>")
    	list(APPEND ${OUT} "${XML_REF}")
    endif()
  endforeach()
  string(REPLACE ";" "\n" ${OUT} "${${OUT}}")
  set(${OUT} ${${OUT}} PARENT_SCOPE)
endfunction(project_references_to_xml)

function(make_csproj)
  set(oneValueArgs TARGET ASSEMBLY_NAME ROOT_NAMESPACE FRAMEWORK NOSTDLIB UNSAFE GUID PLATFORM HINT_PATH)
  set(multiValueArgs SOURCES REFERENCES REFERENCES_WITH_HINT ADDITIONAL_LIB_PATHS PROJECT_REFERENCES)
  cmake_parse_arguments(CS "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # Sanity checks.
  if(NOT DEFINED CS_NOSTDLIB)
    set(CS_NOSTDLIB FALSE)
  endif()
  if(NOT DEFINED CS_UNSAFE)
    set(CS_UNSAFE FALSE)
  endif()
  if(NOT DEFINED CS_GUID)
    # namespace is a magic number, UUIDv4.
    string(UUID CS_GUID NAMESPACE b3bedb1e-a742-4966-9f26-bd2c7ee949a2 NAME ${CS_TARGET} TYPE SHA1 UPPER)
  endif()
  set(CS_PLATFORM "x64")
  if (NOT DEFINED CS_PLATFORM OR "${CS_PLATFORM}" STREQUAL "")
    if (CMAKE_GENERATOR MATCHES "^Visual Studio")
      if (CMAKE_GENERATOR MATCHES "Win64$")
        set(CS_PLATFORM "x64")
      else()
        set(CS_PLATFORM "x32")
      endif()
    else()
      # Use native platform if none specified.
      math(EXPR CS_PLATFORM 8*${CMAKE_SIZEOF_VOID_P})
      set(CS_PLATFORM "x${CS_PLATFORM}")
    endif()
  endif()

  if(NOT DEFINED CS_ADDITIONAL_LIB_PATHS OR "${CS_ADDITIONAL_LIB_PATHS}" STREQUAL "")
  	set(CS_ADDITIONAL_LIB_PATHS "$(AssemblySearchPaths)")
  else()
  	set(CS_ADDITIONAL_LIB_PATHS "$(AssemblySearchPaths);${CS_ADDITIONAL_LIB_PATHS}")
  endif()

  # Weirldy enough with at least CMake 3.1 these will not go to the configured file
  # if not used prior...
  message(STATUS "CSProject is ${CS_PLATFORM} for ${CS_TARGET} in ${CMAKE_BUILD_TYPE}")
  set(CS_OUTPUT_PATH "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}")
  set(CS_DLL "${CS_OUTPUT_PATH}/${CS_ASSEMBLY_NAME}.dll")
  set(CS_MDB "${CS_DLL}.mdb")

  sources_to_xml(CS_SOURCES CS_XML_SOURCES)
  references_to_xml(CS_REFERENCES CS_XML_REFERENCES "")
  if(DEFINED CS_REFERENCES_WITH_HINT)
  	references_to_xml(CS_REFERENCES_WITH_HINT CS_XML_REFERENCES_WITH_HINT CS_HINT_PATH)
  	set(CS_XML_REFERENCES "${CS_XML_REFERENCES}\n${CS_XML_REFERENCES_WITH_HINT}")
  endif()

  project_references_to_xml(CS_PROJECT_REFERENCES CS_XML_PROJECT_REFERENCES)

  configure_file(
    "${CSPROJ_LOCATION}/../Templates/Project.csproj.in"
    "${CMAKE_CURRENT_BINARY_DIR}/${CS_TARGET}.csproj"
    @ONLY
  )

  set(DEPENDENCIES)
  foreach(CS_SRC IN LISTS CS_SOURCES)
    if (NOT "${CS_SRC}" MATCHES "\\*")
      list(APPEND DEPENDENCIES "${CS_SRC}")
    endif()
  endforeach()

  if (CMAKE_GENERATOR MATCHES "^Visual Studio")
  	include_external_msproject(
  	  ${CS_TARGET}
  	  "${CMAKE_CURRENT_BINARY_DIR}/${CS_TARGET}.csproj"
  	  TYPE FAE04EC0-301F-11D3-BF4B-00C04F79EFBC
  	  GUID ${CS_GUID}
  	  ${CS_PROJECT_REFERENCES}
  	)
  else()
      add_custom_command(
        OUTPUT "${CS_DLL}" "${CS_MDB}"
        COMMAND "${CSBUILD}"
        ARGS "${CMAKE_CURRENT_BINARY_DIR}/${CS_TARGET}.csproj"
        DEPENDS ${DEPENDENCIES}
      )
	  add_custom_target(${CS_TARGET} ALL DEPENDS "${CS_DLL}" "${CS_MDB}") 
  endif()
  if (DEFINED CS_PROJECT_REFERENCES)
  	foreach(PROJECT_REF IN LISTS CS_PROJECT_REFERENCES)
  		add_dependencies(${CS_TARGET} ${PROJECT_REF})
  	endforeach()
  endif()
  set_target_properties(
	    ${CS_TARGET}
	    PROPERTIES
	      ASSEMBLY ${CS_ASSEMBLY_NAME}
	      ASSEMBLY_PATH ${CS_OUTPUT_PATH}
	      DLL ${CS_DLL}
	      MDB ${CS_MDB}
	      GUID ${CS_GUID}
	      PROJECT_PATH "${CMAKE_CURRENT_BINARY_DIR}/${CS_TARGET}.csproj"
	  )
endfunction(make_csproj)
