include( "shared.lua" )

--require("tdlib")
--include("ressources/fonts.lua")

local loaded = false

function GM:UpdateAnimation( ply )
    ply:UpdateAnimation()
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

local healthDistance = 1000
healthDistance = healthDistance * healthDistance

local hpLerpSpeed = 0.4

local function CalcHealthFactor( ply )
    local maxHP = ply:GetMaxHealth()
    ply.lastHealthFactor = ply.lastHealthFactor or 1
    local actualHP = math.Clamp(ply:Health() / maxHP, 0, 1)

    ply.lastHealthFactor = Lerp(hpLerpSpeed, ply.lastHealthFactor, actualHP)
    return ply.lastHealthFactor
end

function GM:DrawPlayerHealthbar(ply)
    local x,y = -25, -5
    local w,h = 50, 5
    local teamColor = team.GetColor(ply:Team())
    --[[surface.SetDrawColor( _COLOR.RED )
    surface.DrawRect(x,y, w,h)
    surface.SetDrawColor( team.GetColor(ply:Team()) )
    surface.DrawRect(x,y, w * CalcHealthFactor( ply ),h)
    surface.DrawOutlinedRect( x,y, w,h )
    surface.SetDrawColor( _COLOR.WHITE )
    surface.SetMaterial(player_manager.RunClass(ply, "GetClassIcon"))
    surface.DrawTexturedRect(x - 5 , y - 5, 16,16)]]
    surface.SetDrawColor( teamColor )
    surface.DrawRect(x, y, w, h)
    surface.SetDrawColor( _COLOR.RED )
    local factor = CalcHealthFactor( ply )
    surface.DrawRect( x + w * factor, y+1, w * (1 - factor), h-2)
    surface.SetDrawColor( _COLOR.WHITE )
    surface.SetMaterial(player_manager.RunClass(ply, "GetClassIcon"))
    surface.DrawTexturedRect(x - 15, y - 5, 16,16)
end

function GM:GetEnemyTeamColor( player )
    local teamID = player:Team() == 1 and 2 or 1
    return self:GetTeamNumColor( teamID )
end

netstream.Hook("DeathMessage", function( victim, attacker, inflictor )
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

hook.Add("PostPlayerDraw", "Healthbars", function( ply )
    if ( ply == LocalPlayer() ) then return end
    if (!IsValid(ply)) then return end
    if (!ply:Alive()) then return end

    local plyPos = ply:GetPos()
    if (healthDistance < (plyPos - LocalPlayer():GetPos()):LengthSqr()) then return end

    local eyeAng = EyeAngles()
    local offset = Vector(0,0,80)
    eyeAng:RotateAroundAxis(eyeAng:Forward(), -90)
    eyeAng:RotateAroundAxis(eyeAng:Right(), 90)
    eyeAng:RotateAroundAxis(eyeAng:Up(), 180)

    cam.Start3D2D(plyPos + offset, eyeAng, 1)
    hook.Call("DrawPlayerHealthbar", GAMEMODE, ply)
    cam.End3D2D()
end)

function GM:PaintHealthbar()
    local ply = LocalPlayer()
    local x,y = 64, ScrH() - 96
    local w,h = 500, 50
    local teamColor = team.GetColor(ply:Team())
    --[[surface.SetDrawColor( _COLOR.RED )
    surface.DrawRect(x,y, w,h)
    surface.SetDrawColor( team.GetColor(ply:Team()) )
    surface.DrawRect(x,y, w * CalcHealthFactor( LocalPlayer() ),h)
    surface.DrawOutlinedRect( x,y, w,h )
    surface.SetDrawColor( _COLOR.WHITE )
    surface.SetMaterial(player_manager.RunClass(ply, "GetClassIcon"))
    surface.DrawTexturedRect(x - 50 ,y - 50, 128,128)]]
    surface.SetDrawColor( teamColor )
    surface.DrawRect(x, y, w, h)
    surface.SetDrawColor( _COLOR.RED )
    local factor = CalcHealthFactor( ply )
    surface.DrawRect( x + w * factor, y+5, w * (1 - factor), h-10)
    surface.SetDrawColor( _COLOR.WHITE )
    surface.SetMaterial(player_manager.RunClass(ply, "GetClassIcon"))
    surface.DrawTexturedRect(x - 50 ,y - 50, 128,128)
end

function GM:HUDShouldDraw( name )
    if (name == "CHudHealth") then return false end
    return true
end

hook.Add("HUDPaint", "Healthbar", function()
    hook.Call("PaintHealthbar", GAMEMODE)
end)

hook.Add("Think", "LoadingStatus", function()
    if (!IsValid(LocalPlayer())) then return end

    hook.Call("FinishedLoading", GAMEMODE)
    hook.Remove("Think", "LoadingStatus")
end)