newoption {
    trigger = "arch",
    description = "Which architecture to build. Defaults to the underlying platform if not provided.",
    value = "ARCH",
    allowed = {
        { "x86", "32-bit" },
        { "x32", "32-bit" },
        { "x64", "64-bit" }
    }
}

if not _OPTIONS["arch"] then
    if os.is64bit() then
        _OPTIONS["arch"] = "x64"
    else
        _OPTIONS["arch"] = "x32"
    end
end

if _OPTIONS["arch"] == "x86" then
    _OPTIONS["arch"] = "x32"
end

function prebuildschemas()
	prebuildcommands {
		"%{sln.location}/%{cfg.buildcfg}-%{cfg.architecture}/bin/flatc -o %{sln.location}/schemas -c -n ../schemas/*"
	}
end


solution "Keron"
    configurations { "Debug", "Release" }
    location "build"
    architecture (_OPTIONS["arch"])

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
        targetdir "build/%{cfg.buildcfg}-%{cfg.architecture}/bin"
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
        targetdir "build/%{cfg.buildcfg}-%{cfg.architecture}/lib"
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
	framework "2.0"
	targetname "FlatBuffers"
        targetdir "build/%{cfg.buildcfg}-%{cfg.architecture}/lib"
	files { "flatbuffers/net/**.cs" }
	links { "System.Core" }

    project "enet-static"
        kind "StaticLib"
        language "C"
        targetname "enet-static"
        targetdir "build/%{cfg.buildcfg}-%{cfg.architecture}/lib"
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
        targetdir "build/%{cfg.buildcfg}-%{cfg.architecture}/lib"
        files { "enet/*.c" }
        includedirs { "enet/include/" }
        defines {
            "ENET_DLL", "HAS_FCNTL", "HAS_POLL",
            "HAS_GETHOSTBYNAME_R", "HAS_GETHOSTBYADDR_R",
            "HAS_INET_PTON", "HAS_INET_NTOP",
            "HAS_MSGHDR_FLAGS", "HAS_SOCKLEN_T"
        }
        
        filter "system:windows"
                targetprefix "lib"
                links { "Winmm", "Ws2_32" }

    project "ENet-net"
        kind "SharedLib"
        language "C#"
        framework "2.0"
        targetname "ENet"
        targetdir "build/%{cfg.buildcfg}-%{cfg.architecture}/lib"
        files { "enetcs/ENetCS/**.cs" }
        flags { "Unsafe" }
        links { "System" }

    project "server"
        kind "ConsoleApp"
	language "C++"
	includedirs {
		"server/include",
		"flatbuffers/include",
		"%{sln.location}/schemas"
	}
	files { "server/src/**.cpp" }
	links { "flatbuffers-cpp", "enet-static" }
	prebuildschemas()
