

local invalidPrefixes
if SERVER then invalidPrefixes = { "cl_" } end
if CLIENT then invalidPrefixes = { "sv_" } end

local fileBlacklist = {
    "db", "vvd", "phy", "vtf", "vtx", "txt", "ztmp"
}

local function ProcessFolder( path, domain, handle, foldername )
    local files, folders = file.Find( path .. "/*", domain )
    path = path .. "/"
    for _, filename in next, files do
        handle( path, filename, foldername )
    end

    for _, folder in next, folders do
        ProcessFolder( path .. folder, domain, handle, folder )
    end
end

_G.ProcessFolder = ProcessFolder

local function removeGamemodePrefix( path )
    if ( string.find(path, GM.Name .. "/gamemode/") ) then
        path = string.sub(path, string.len(GM.Name .. "/gamemode/") + 1)
    end
    return path
end

local function AddCSFolder( path )
    local count = 0
    ProcessFolder( path, "LUA", function( foldername, filename )
        if ( string.StartWith( filename, "sv_") or filename == "init.lua" ) then return end

        AddCSLuaFile( removeGamemodePrefix(foldername) .. filename )
        --print(" - added " .. foldername .. filename .. " to Download" )
        count = count + 1
    end)
    print(" - " .. path .. ": Added " .. count .. " LUA-Files to Download" )
end

local function AddResources( path )
    ProcessFolder( path, "GAME", function( foldername, filename)
        local ext = string.GetExtensionFromFilename( filename )
        if ( table.HasValue(fileBlacklist, ext) ) then return end

        resource.AddFile( foldername .. filename )
        print(" - added " .. foldername .. filename .. " to Download" )
    end)
end

local function checkPrefix( filename )
    for k, prefix in next, invalidPrefixes do
        if ( string.StartWith(filename, prefix) ) then return false end
    end
    return true
end

local function LoadFolder( path )
    local count = 0
    ProcessFolder( path, "LUA", function( foldername, filename )
        if ( !checkPrefix( filename ) ) then return end

        include( removeGamemodePrefix(foldername) .. filename )

        --print(" - included " .. foldername .. filename )
        count = count + 1
    end)
    print(" - " .. path .. ": Loaded " .. count .. " LUA-Files" )
end

local function LoadManagedMusic()
    local countFiles = 0
    local countTracks = 0
    local tracks = {}

    ProcessFolder( "sound/element/music_managed", "THIRDPARTY", function( path, filename, foldername )
        countFiles = countFiles + 1
        if (!tracks[foldername]) then
            tracks[foldername] = {}
            countTracks = countTracks + 1
        end
        table.insert(tracks[foldername], filename)
    end)

    for name, files in next, tracks do
        music_manager.Feed( name, files )
    end

    print(" - Loaded " .. countTracks .. " Managed Music Tracks containing " .. countFiles .. " Files" )
end

print("Cataclysm: Setting up Gamemode")
print("# Requiring libraries")
require("classes")
require("pon")
require("netstream")
require("ecall")
if SERVER then
    print("# Setup FastDL")
    AddCSFolder( GM.Name .. "/gamemode" )
    AddCSFolder( GM.Name .. "/entities" )
    AddResources( "resource/fonts")
end
print("# Loading Code")
LoadFolder( GM.Name .. "/gamemode/config" )
LoadFolder( GM.Name .. "/gamemode/resources" )
LoadFolder( GM.Name .. "/gamemode/managers" )
LoadFolder( GM.Name .. "/gamemode/extensions" )
LoadFolder( GM.Name .. "/gamemode/modules/skillsystem" ) --cheating to ensure UI has everything ready
LoadFolder( GM.Name .. "/gamemode/modules" )
LoadFolder( GM.Name .. "/gamemode/skills" )

include("player_class/element/base.lua")
LoadFolder( GM.Name .. "/gamemode/player_class" )
if CLIENT then
    require("tdlib")
    LoadFolder( GM.Name .. "/gamemode/vgui" )
    LoadFolder( GM.Name .. "/gamemode/animations" )
    LoadManagedMusic()
end
print("\n\n")