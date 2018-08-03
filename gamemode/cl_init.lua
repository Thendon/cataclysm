include( "shared.lua" )
include( "cl_hud.lua" )

local loaded = false
local healthDistance = 1000
healthDistance = healthDistance * healthDistance

function GM:UpdateAnimation( ply )
    ply:UpdateAnimation()
end

function GM:FinishedLoading()
    print("finished loading")
    netstream.Start("GM:FinishedLoading")
    skill_manager.Initialize()

    loaded = true
end

hook.Add("Think", "LoadingStatus", function()
    if (!IsValid(LocalPlayer())) then return end

    hook.Call("FinishedLoading", GAMEMODE)
    hook.Remove("Think", "LoadingStatus")
end)
--[[
function GM:InitPostEntity()
    GM:FinishedLoading()
end

function GM:OnReloaded()
    GM:FinishedLoading()
end
]]
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

    if (attacker == victim) then
        table.insert(text, "himself")
        chat.AddText(unpack(text))
        return
    end

    if (inflictor and !IsValid(attacker) or attacker.GetName and inflictor != attacker:GetName()) then
        table.insert(text, "from ")
        table.insert(text, _COLOR.RED) --TODO SHOW SKILL ICON INSTEAD
        table.insert(text, inflictor)
        table.insert(text, teamColor)
    end

    if (IsValid(attacker) and attacker:IsPlayer()) then
        table.insert(text, " by ")
        table.insert(text, player_manager.RunClass(attacker, "GetClassColor"))
        table.insert(text, attacker:GetName())
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
    --if ( ply:IsSpectator() ) then return false end
    if ( ply == LocalPlayer() ) then return false end
    if (!IsValid(ply)) then return false end
    if (!ply:Alive()) then return false end

    local plyPos = ply:GetPos()
    local distance = (plyPos - LocalPlayer():GetPos()):LengthSqr()
    if (healthDistance < distance) then return false end
    return plyPos, distance
end

function GM:HUDDrawTargetID()
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

function GM:HUDDrawScoreBoard()
    if ele_scoreboard:Hidden() then return end

    hook.Call("PaintRound", GAMEMODE)
end

local shoulder = 0

local function CalcOptimalCamPos( origin, angles )
    local camPos = origin - angles:Forward() * 100 + angles:Up() * 20 + angles:Right() * shoulder

    local tr = util.TraceLine({
        start = origin,
        endpos = camPos,
        collisionGroup = COLLISION_GROUP_DEBRIS,
        --for some reason i m hitting the back of my head without this?!
        filter = LocalPlayer()
    })

    return tr.HitPos or camPos
end

local lastCamPos
local lastCamAng

function GM:CalcView( ply, origin, angles, fov, znear, zfar )
    local camPos = CalcOptimalCamPos( origin, EyeAngles() )
    local camAng = angles

    lastCamPos = lastCamPos or camPos
    lastCamAng = lastCamAng or angles

    local delta = math.Clamp(FrameTime() * 20, 0, 1)
    camPos = LerpVector(delta, lastCamPos, camPos)
    camAng = LerpAngle(delta, lastCamAng, camAng)

    lastCamPos = camPos
    lastCamAng = camAng

    local view = {}
    view.origin		= camPos
    view.angles		= camAng
    view.fov		= fov
    view.znear		= znear
    view.zfar		= zfar
    view.drawviewer	= true

    player_manager.RunClass( ply, "CalcView", view )

    return view
end

hook.Add( "CalcView", "MyCalcView", animatorCam )

hook.Add("HUDPaint", "ElementPaint", function()
    if LocalPlayer():IsSpectator() then return end

    hook.Call("PaintHealthbar", GAMEMODE)
    hook.Call("PaintRoundState", GAMEMODE)
    hook.Call("PaintScore", GAMEMODE)
end)

--[[
hook.Add("PostPlayerDraw", "Healthbars", function( ply )
    local eyeAng = GetEyeBounds()
    local offset = Vector(0,0,80)

    local plyPos = ShouldDrawPlayerInfos(ply)
    if !plyPos then return end

    cam.Start3D2D(plyPos + offset, eyeAng, 1)
    print(ply, "draw healthbar")
    cam.End3D2D()
end)
]]

hook.Add("PostDrawOpaqueRenderables", "ClassIcons", function(depth, skybox)
    if skybox then return end

    local eyeAng = GetEyeBounds()
    local offset = Vector(0,0,80)

    for k, ply in next, player.GetAll() do
        local plyPos, distance = ShouldDrawPlayerInfos(ply)
        if !plyPos then continue end

        cam.Start3D2D(plyPos + offset, eyeAng, 1)
        hook.Call("DrawPlayerHealthbar", GAMEMODE, ply, distance)
        hook.Call("DrawPlayerClass", GAMEMODE, ply)
        cam.End3D2D()
    end
end)