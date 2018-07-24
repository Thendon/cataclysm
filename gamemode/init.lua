AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

AddCSLuaFile( "sh_loader.lua" )

include( "shared.lua" )

function GM:PlayerSpawn( ply )
    ply:SetTeam(math.random(1, 2))
    player_manager.SetPlayerClass(ply, "player_" .. ply:GetClassPick())
    player_manager.RunClass(ply, "Spawn")
end

function GM.FinishedLoading( ply )
    ply:FinishedLoading()
end

function GM:Move( ply, mv )
    ply:Move( mv )
end

function GM:FinishMove( ply, mv )
    ply:FinishMove( mv )
end

function GM:GetFallDamage(ply, speed)
    return 0
end

function GM:PlayerDeathSound()
    return true
end
--[[
local lastThink = 0
local deltaTime = 0
_G.DeltaTime = function()
    return deltaTime
end

function GM:Think()
    local now = CurTime()
    DeltaTime = now - lastThink
    lastThink = now
end
]]
function GM:DeathMessage( victim, inflictor, attacker )
    netstream.Start(player.GetAll(), "DeathMessage", victim, attacker:GetName(), inflictor)
end

function GM:PlayerDeath( victim, inflictor, attacker )
    victim:OnDeath( inflictor, attacker )
    self:DeathMessage(victim, inflictor, attacker)
end

--USING CONSTRAINT INSTEAD
function GM:ShouldCollide(ent1, ent2)
    if (!ent1.isskill) then return end
    local ret = ent1:ShouldCollide( ent2 )
    if ( ret != nil ) then return ret end
    return true
end

function GM:EntityTakeDamage( ent, dmg )
    if (dmg:GetInflictor().isskill) then return true end
end

netstream.Hook("GM:FinishedLoading", GM.FinishedLoading)