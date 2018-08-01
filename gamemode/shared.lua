GM.Name = "Cataclysm"
GM.Author = "Thendon.exe"
GM.Website = "sneaky.rocks"

DeriveGamemode( "base" )

_G.TEAM_BLACK = 1
_G.TEAM_WHITE = 2

include("sh_loader.lua")

function GM:CreateTeams()
    team.SetUp( TEAM_BLACK, "Black", _COLOR.BLACK, true)
    team.SetClass( TEAM_BLACK, { "player_earth", "player_fire", "player_air", "player_water" } )

    team.SetUp( TEAM_WHITE, "White", _COLOR.WHITE, true)
    team.SetClass( TEAM_WHITE, { "player_earth", "player_fire", "player_air", "player_water" } )
end

function GM:GetEnemyTeam( teamID )
    teamID = isnumber(teamID) and teamID or teamID:Team()
    return teamID == TEAM_BLACK and TEAM_WHITE or TEAM_BLACK
end

local lastThink = 0
local deltaTime = 0
_G.DeltaTime = function()
    return deltaTime
end

local function CalcDelta()
    local now = CurTime()
    deltaTime = now - lastThink
    lastThink = now
end

function GM:Tick()
    CalcDelta()
    if SERVER then round_manager.Update() end
    if CLIENT then music_manager.Update() end
end