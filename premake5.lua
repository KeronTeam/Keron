solution "Keron"
    configurations { "Debug", "Release" }
    location "build"

    filter "language:C++"
        buildoptions { "-std=c++11" }
        flags { "NoRTTI" }

    filter "configurations:Debug"
        defines { "DEBUG" }
        flags { "Symbols" }

    filter "configurations:Release"
        defines { "NDEBUG" }
        flags { "LinkTimeOptimization" }
        optimize "Full"

    project "flatc"
        kind "ConsoleApp"
        language "C++"
        includedirs { "flatbuffers/include" }
        files {
                "flatbuffers/include/flatbuffers.h",
                "flatbuffers/include/idl.h",
                "flatbuffers/include/util.h",
                "flatbuffers/src/idl_parser.cpp",
                "flatbuffers/src/idl_gen_cpp.cpp",
                "flatbuffers/src/idl_gen_general.cpp",
                "flatbuffers/src/idl_gen_go.cpp",
                "flatbuffers/src/idl_gen_text.cpp",
                "flatbuffers/src/idl_gen_fbs.cpp",
                "flatbuffers/src/flatc.cpp"
        }

    project "flatbuffers-cpp"
        kind "StaticLib"
        language "C++"
        targetname "flatbuffers"
        includedirs { "flatbuffers/include" }
        files {
            "flatbuffers/include/flatbuffers.h",
            "flatbuffers/include/idl.h",
            "flatbuffers/include/util.h",
            "flatbuffers/src/idl_parser.cpp",
            "flatbuffers/src/idl_gen_text.cpp",
        }

    project "flatbuffers-net"
	kind "SharedLib"
	language "C#"
	targetname "FlatBuffers"
	files { "flatbuffers/net/**.cs" }
	links { "System.Core" }

    project "enet-static"
        kind "StaticLib"
        language "C"
        targetname "enet"
        files { "enet/*.c" }
        includedirs { "enet/include/" }
        defines {
            "HAS_FCNTL", "HAS_POLL",
            "HAS_GETHOSTBYNAME_R", "HAS_GETHOSTBYADDR_R",
            "HAS_INET_PTON", "HAS_INET_NTOP",
            "HAS_MSGHDR_FLAGS", "HAS_SOCKLEN_T"
        }

     project "enet-shared"
        kind "SharedLib"
        language "C"
        targetname "enet"
        files { "enet/*.c" }
        includedirs { "enet/include/" }
        defines {
            "ENET_DLL", "HAS_FCNTL", "HAS_POLL",
            "HAS_GETHOSTBYNAME_R", "HAS_GETHOSTBYADDR_R",
            "HAS_INET_PTON", "HAS_INET_NTOP",
            "HAS_MSGHDR_FLAGS", "HAS_SOCKLEN_T"
        }
        
        filter "system:windows"
                targetprefix ""
                targetname "ENet"
                architecture "x32"
                targetsuffix "X86"
		targetextension ".dll"

        filter "system:linux"
                targetname "enet"
		targetextension ".so.1"

    project "ENet-net"
        kind "SharedLib"
        language "C#"
        framework "2.0"
        targetname "ENet"
        files { "enetcs/ENetCS/**.cs" }
        buildoptions { "/unsafe+" }
        links { "System" }
        filter "system:windows"
            architecture "x32"
