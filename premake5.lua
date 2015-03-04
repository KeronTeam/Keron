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

newoption {
    trigger = "ksp",
    description = "Path to your KSP installation."
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

if not _OPTIONS["ksp"] then
    print "ksp directory is **NOT** set. Using system libraries."
end

function ksp_assembly(name)
    if not _OPTIONS["ksp"] then
        return name
    end
    local managed = path.join(_OPTIONS["ksp"], "KSP_Data", "Managed")

    return path.join(managed, name)
end

function ksp_bundle(name)
    if not _OPTIONS["ksp"] then
        return name
    end
    local managed = path.join(_OPTIONS["ksp"], "KSP.app", "Contents", "Data", "Managed")

    return path.join(managed, name)
end

function prebuildschemas()
	local flatc = path.join("%{sln.location}", "%{cfg.buildcfg}-%{cfg.architecture}", "bin", "flatc")
        flatc = path.normalize(flatc)
        local out_dir = path.normalize(path.join("%{sln.location}", "schemas"))
	local commands_list = {}
	local fbs_files = os.matchfiles(path.join(_WORKING_DIR, "schemas", "*.fbs"))

	for i, fbs in ipairs(fbs_files) do
		local call = { flatc, "-c", "-n", "-o", out_dir, fbs }
		table.insert(commands_list, table.concat(call, " "))
	end
	prebuildcommands(commands_list)
end

local target_outdir = path.join("build", "%{cfg.buildcfg}-%{cfg.architecture}")
local bin_outdir = path.join(target_outdir, "bin")
local lib_outdir = path.join(target_outdir, "lib")

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
        targetdir(bin_outdir)
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
        targetdir(lib_outdir)
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
	framework "3.5"
	targetname "FlatBuffers"
        targetdir(lib_outdir)
	files { "flatbuffers/net/**.cs" }
	links { "System.Core" }

    project "enet-static"
        kind "StaticLib"
        language "C"
        targetname "enet-static"
        targetdir(lib_outdir)
        files { "enet/*.c" }
        includedirs { "enet/include/" }
        defines {
            "HAS_FCNTL", "HAS_POLL",
            "HAS_GETHOSTBYNAME_R", "HAS_GETHOSTBYADDR_R",
            "HAS_INET_PTON", "HAS_INET_NTOP",
            "HAS_MSGHDR_FLAGS", "HAS_SOCKLEN_T"
        }
        filter "system:macosx"
            removedefines {"HAS_GETHOSTBYNAME_R", "HAS_GETHOSTBYADDR_R"}

    project "vedis"
        kind "StaticLib"
	language "C"
	files { "vedis/vedis.c" }
	includedirs { "vedis/" }

     project "enet-shared"
        kind "SharedLib"
        language "C"
        targetname "enet"
        targetdir(lib_outdir)
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
        filter "system:macosx"
            removedefines {"HAS_GETHOSTBYNAME_R", "HAS_GETHOSTBYADDR_R"}

    project "ENet-net"
        kind "SharedLib"
        language "C#"
        targetname "ENet"
        targetdir(lib_outdir)
        files { "enetcs/ENetCS/**.cs" }
        if _OPTIONS["ksp"] then
            buildoptions { "/nostdlib" }
        end
        flags { "NoImplicitLink", "OmitDefaultLibrary" }
        clr "Unsafe"
        filter "system:not macosx"
	    links({ ksp_assembly "System.dll", ksp_assembly "System.Core.dll", ksp_assembly "mscorlib.dll" })
        filter "system:macosx"
	    links({ ksp_bundle "System.dll", ksp_bundle "System.Core.dll", ksp_bundle "mscorlib.dll" })

    project "server"
        kind "ConsoleApp"
	language "C++"
        targetname "keron-server"
        targetdir(bin_outdir)
	includedirs {
		"server/include",
                "enet/include",
                "vedis",
		"flatbuffers/include",
		"%{sln.location}/schemas"
	}
	files { "server/src/**.cpp" }
	links { "flatbuffers-cpp", "enet-static", "vedis" }
	prebuildschemas()
	postbuildcommands {
		"{MKDIR} " .. path.join(_WORKING_DIR, bin_outdir, "schemas"),
		"{COPY} " .. path.join(_WORKING_DIR, "schemas", "server.fbs") .. " " .. path.join(_WORKING_DIR, bin_outdir, "schemas")
	}

	filter "system:windows"
	    removefiles { "server/src/os/posix.cpp" }
	    defines { "NOMINMAX" }
	    links { "Winmm", "Ws2_32" }
	filter "system:linux or macosx"
	    removefiles { "server/src/os/windows.cpp" }

    project "client"
        kind "SharedLib"
        language "C#"
        framework "4.5"
        targetname "KeronClient"
        targetdir(lib_outdir)
        files { "client/**.cs" }
        flags { "Unsafe" }
        links { "ENet-net",
                "flatbuffers-net", 
                ksp_assembly "UnityEngine.dll",
                ksp_assembly "Assembly-CSharp.dll",
                ksp_assembly "System.dll" }
                postbuildcommands {
                    "{MKDIR} " .. path.join(_WORKING_DIR, target_outdir, "initSave"),
                    "{COPY} " .. path.join(_WORKING_DIR, "client", "initSave", "*.sfs") .. " " .. path.join(_WORKING_DIR, target_outdir, "initSave")
                }

