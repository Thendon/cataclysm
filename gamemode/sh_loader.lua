

local invalidPrefixes
if SERVER then invalidPrefixes = { "cl_" } end
if CLIENT then invalidPrefixes = { "sv_" } end

local fileBlacklist = {
    "db", "vvd", "phy", "vtf", "vtx", "txt", "ztmp"
}

local function processFolder( path, domain, handle )
    local files, folders = file.Find( path .. "/*", domain )
    path = path .. "/"
    for _, filename in next, files do
        handle( path, filename )
    end

    for _, foldername in next, folders do
        processFolder( path .. foldername, domain, handle )
    end
end

local function removeGamemodePrefix( path )
    if ( string.find(path, GM.Name .. "/gamemode/") ) then
        path = string.sub(path, string.len(GM.Name .. "/gamemode/") + 1)
    end
    return path
end

local function AddCSFolder( path )
    local count = 0
    processFolder( path, "LUA", function( foldername, filename )
        if ( string.StartWith( filename, "sv_") or filename == "init.lua" ) then return end

        AddCSLuaFile( removeGamemodePrefix(foldername) .. filename )
        --print(" - added " .. foldername .. filename .. " to Download" )
        count = count + 1
    end)
    print(" - " .. path .. ": Added " .. count .. " LUA-Files to Download" )
end

local function AddResources( path )
    processFolder( path, "GAME", function( foldername, filename)
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
    processFolder( path, "LUA", function( foldername, filename )
        if ( !checkPrefix( filename ) ) then return end

        include( removeGamemodePrefix(foldername) .. filename )

        --print(" - included " .. foldername .. filename )
        count = count + 1
    end)
    print(" - " .. path .. ": Loaded " .. count .. " LUA-Files" )
end

print("Cataclysm: Setting up Gamemode")
print("# Requiring libraries")
require("classes")
require("pon")
require("netstream")
require("ecall")
print("# Setup FastDL")
AddCSFolder( GM.Name .. "/gamemode" )
AddCSFolder( GM.Name .. "/entities" )
print("# Loading Code")
LoadFolder( GM.Name .. "/gamemode/ressources" )
LoadFolder( GM.Name .. "/gamemode/managers" )
LoadFolder( GM.Name .. "/gamemode/extensions" )
LoadFolder( GM.Name .. "/gamemode/modules" )
LoadFolder( GM.Name .. "/gamemode/skills" )
LoadFolder( GM.Name .. "/gamemode/player_class" )
if CLIENT then
    require("tdlib")
    LoadFolder( GM.Name .. "/gamemode/vgui" )
end
print("\n\n")