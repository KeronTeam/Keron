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
	local flatc = "%{sln.location}"
	if os.is("windows") then
		flatc = path.join(flatc, "$(OutDir)", "..")
	else
		flatc = path.join(flatc, "%{cfg.buildcfg}-%{cfg.architecture}")
	end
        flatc = path.normalize(path.join(flatc, "bin", "flatc"))
        local out_dir = path.normalize(path.join("%{sln.location}", "schemas"))
	local commands_list = {}
	local fbs_files = os.matchfiles(path.join(_WORKING_DIR, "schemas", "*.fbs"))

	for i, fbs in ipairs(fbs_files) do
		local call = { flatc, "-n", "-o", out_dir, fbs }
		table.insert(commands_list, table.concat(call, " "))
	end
	return commands_list
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
                "flatbuffers/include/flatbuffers/flatbuffers.h",
                "flatbuffers/include/flatbuffers/hash.h",
                "flatbuffers/include/flatbuffers/idl.h",
                "flatbuffers/include/flatbuffers/util.h",
                "flatbuffers/include/flatbuffers/reflection.h",
                "flatbuffers/include/flatbuffers/reflection_generated.h",
                "flatbuffers/src/idl_parser.cpp",
                "flatbuffers/src/idl_gen_text.cpp",
                "flatbuffers/src/reflection.cpp",
                "flatbuffers/src/idl_gen_cpp.cpp",
                "flatbuffers/src/idl_gen_general.cpp",
                "flatbuffers/src/idl_gen_go.cpp",
                "flatbuffers/src/idl_gen_python.cpp",
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
                "flatbuffers/include/flatbuffers/flatbuffers.h",
                "flatbuffers/include/flatbuffers/hash.h",
                "flatbuffers/include/flatbuffers/idl.h",
                "flatbuffers/include/flatbuffers/util.h",
                "flatbuffers/include/flatbuffers/reflection.h",
                "flatbuffers/include/flatbuffers/reflection_generated.h",
                "flatbuffers/src/idl_parser.cpp",
                "flatbuffers/src/idl_gen_text.cpp",
                "flatbuffers/src/reflection.cpp"
        }

    project "flatbuffers-net"
	kind "SharedLib"
	language "C#"
	framework "3.5" -- Uses Linq.
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
        framework "2.0"
        targetname "ENet"
        targetdir(lib_outdir)
        files { "enetcs/ENetCS/**.cs" }
        if _OPTIONS["ksp"] then
            buildoptions { "/nostdlib" }
        end
        flags { "NoCopyLocal" }
        clr "Unsafe"
        filter "system:not macosx"
	    links({ ksp_assembly "System.dll", ksp_assembly "System.Core.dll", ksp_assembly "mscorlib.dll" })
        filter "system:macosx"
	    links({ ksp_bundle "System.dll", ksp_bundle "System.Core.dll", ksp_bundle "mscorlib.dll" })

    project "client"
        kind "SharedLib"
        language "C#"
        framework "3.5"
	dependson { "flatc" }
        targetname "KeronClient"
        targetdir(lib_outdir)
        prebuildcommands(prebuildschemas())
        files { "build/schemas/keron/FlightCtrlState.cs",
                "build/schemas/keron/FlightCtrlStateToggles.cs",
                "build/schemas/keron/messages/Chat.cs",
                "build/schemas/keron/messages/ClockSync.cs",
                "build/schemas/keron/messages/FlightCtrl.cs",
                "build/schemas/keron/messages/NetID.cs",
                "build/schemas/keron/messages/NetMessage.cs",
                "client/**.cs" }
        flags { "Unsafe", "NoCopyLocal" }
        filter "system:not macosx"
            links({ "ENet-net",
                    "flatbuffers-net",
                    ksp_assembly "UnityEngine.dll",
                    ksp_assembly "Assembly-CSharp.dll",
                    ksp_assembly "System.dll" })
        filter "system:macosx"
            links({ "ENet-net",
                    "flatbuffers-net",
                    ksp_bundle "UnityEngine.dll",
                    ksp_bundle "Assembly-CSharp.dll",
                    ksp_bundle "System.dll" })
        postbuildcommands {
            "{MKDIR} " .. path.join(_WORKING_DIR, target_outdir, "initSave"),
            "{COPY} " .. path.join(_WORKING_DIR, "client", "initSave", "*.sfs") .. " " .. path.join(_WORKING_DIR, target_outdir, "initSave")
        }

