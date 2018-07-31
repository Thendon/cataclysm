include( "shared.lua" )
include( "cl_hud.lua" )

local loaded = false
local BGSVolume = 0.25
local healthDistance = 1000
healthDistance = healthDistance * healthDistance

function GM:UpdateAnimation( ply )
    ply:UpdateAnimation()
end

_G.PlayBGS = function( file )
    sound.PlayFile("sound/" .. file, "noplay", function( channel )
        if !IsValid( channel ) then print("couldnt play bgs: " .. tostring(file)) return end
        if !system.HasFocus() then return end

        channel:SetVolume(BGSVolume)
        channel:Play()
    end)
end

function GM:FinishedLoading()
    netstream.Start("GM:FinishedLoading")
    skill_manager.Initialize()

    loaded = true
end

function GM:Loaded()
    return loaded
end

function GM:PreDrawHalos()
    skill_manager.CleverHalo()
end

function GM:GetEnemyTeamColor( player )
    local teamID = self:GetEnemyTeam( player )
    return self:GetTeamNumColor( teamID )
end

netstream.Hook("DeathMessage", function( victim, attacker, inflictor )
    if !IsValid(victim) or victim:IsSpectator() then return end

    local teamColor = GAMEMODE:GetEnemyTeamColor(victim)

    local text = {}
    table.insert(text, player_manager.RunClass(victim, "GetClassColor"))
    table.insert(text, victim:GetName())
    table.insert(text, teamColor)
    table.insert(text, " killed ")

    if (inflictor == victim) then
        table.insert(text, "himself")
        chat.AddText(unpack(text))
        return
    end

    if (attacker and !IsValid(inflictor) or inflictor.GetName and attacker != inflictor:GetName()) then
        table.insert(text, "from ")
        table.insert(text, _COLOR.RED) --TODO SHOW SKILL ICON INSTEAD
        table.insert(text, attacker)
        table.insert(text, teamColor)
    end

    if (IsValid(inflictor) and inflictor:IsPlayer()) then
        table.insert(text, " by ")
        table.insert(text, player_manager.RunClass(inflictor, "GetClassColor"))
        table.insert(text, inflictor:GetName())
    end

    chat.AddText(unpack(text))
end)

local function GetEyeBounds()
    local eyeAng = EyeAngles()
    eyeAng:RotateAroundAxis(eyeAng:Forward(), -90)
    eyeAng:RotateAroundAxis(eyeAng:Right(), 90)
    eyeAng:RotateAroundAxis(eyeAng:Up(), 180)

    return eyeAng
end

local function ShouldDrawPlayerInfos(ply)
    if ( ply == LocalPlayer() ) then return false end
    if (!IsValid(ply)) then return false end
    if (!ply:Alive()) then return false end

    local plyPos = ply:GetPos()
    if (healthDistance < (plyPos - LocalPlayer():GetPos()):LengthSqr()) then return false end
    return plyPos
end

function GM:HUDShouldDraw( name )
    if (name == "CHudHealth") then return false end
    if (name == "CHudCrosshair") then return false end
    return true
end

function GM:ScoreboardShow()
    ele_scoreboard:Show()
end

function GM:ScoreboardHide()
    ele_scoreboard:Hide()
end

--going for the stupid way, garry xD
function GM:HUDDrawScoreBoard()
    if ele_scoreboard:Hidden() then return end

    hook.Call("PaintRound", GAMEMODE)
end

hook.Add("HUDPaint", "Healthbar", function()
    if LocalPlayer():IsSpectator() then return end

    hook.Call("PaintHealthbar", GAMEMODE)
    hook.Call("PaintRoundState", GAMEMODE)
    hook.Call("PaintScore", GAMEMODE)
end)

hook.Add("Think", "LoadingStatus", function()
    if (!IsValid(LocalPlayer())) then return end

    hook.Call("FinishedLoading", GAMEMODE)
    hook.Remove("Think", "LoadingStatus")
end)

hook.Add("PostPlayerDraw", "Healthbars", function( ply )
    local eyeAng = GetEyeBounds()
    local offset = Vector(0,0,80)

    local plyPos = ShouldDrawPlayerInfos(ply)
    if !plyPos then return end

    cam.Start3D2D(plyPos + offset, eyeAng, 1)
    hook.Call("DrawPlayerHealthbar", GAMEMODE, ply)
    cam.End3D2D()
end)

hook.Add("PostDrawOpaqueRenderables", "ClassIcons", function()
    local eyeAng = GetEyeBounds()
    local offset = Vector(0,0,80)

    for k, ply in next, player.GetAll() do
        local plyPos = ShouldDrawPlayerInfos(ply)
        if !plyPos then continue end

        cam.Start3D2D(plyPos + offset, eyeAng, 1)
        hook.Call("DrawPlayerClass", GAMEMODE, ply)
        cam.End3D2D()
    end
end)