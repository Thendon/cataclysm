AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

AddCSLuaFile( "sh_loader.lua" )

include( "shared.lua" )

function GM:PlayerInitialSpawn( ply )
    ply:SetTeam(team.BestAutoJoinTeam())
end

local classes = {
    "fire", "water", "earth", "air"
}

function GM:PlayerSpawn( ply )
    --if !ply.team then ply:JoinTeam(TEAM_SPECTATOR) end

    if ply:IsSpectator() then return end --TODO not implemented at all ^^

    ply:UnSpectate()

    local class = ply:GetClassPick() or classes[math.random(1,4)]

    if !class then return end

    local spawn = spawn_manager.GetPlayerSpawn( ply )

    if spawn then
        ply:SetPos( spawn.pos )
        ply:SetAngles( spawn.ang )
        ply:SetEyeAngles( spawn.ang )
    end

    player_manager.SetPlayerClass(ply, "player_" .. class)
    player_manager.RunClass(ply, "Spawn")
end

function GM:PlayerDeathThink( ply )
    if ( ply.NextSpawnTime && ply.NextSpawnTime > CurTime() ) then return end

    ply:Spectate(OBS_MODE_ROAMING)

    if !round_manager.CanRespawn() then return end

    if ( ply:IsBot() || ply:KeyPressed( IN_ATTACK ) || ply:KeyPressed( IN_ATTACK2 ) || ply:KeyPressed( IN_JUMP ) ) then
        ply:Spawn()
    end
end

function GM:PlayerFinishedLoading( ply )
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

function GM:DeathMessage( victim, inflictor, attacker )
    attacker = attacker:IsWorld() and "world" or attacker:GetName()
    netstream.Start(player.GetAll(), "DeathMessage", victim, attacker, inflictor)
end

function GM:PlayerDeath( victim, inflictor, attacker )
    victim:OnDeath( inflictor, attacker )
    victim.NextSpawnTime = CurTime() + 3
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
    --TODO remove physics damage to player
    if (dmg:GetInflictor().isskill) then return true end
end

netstream.Hook("GM:FinishedLoading", function(ply)
    hook.Call("PlayerFinishedLoading", GAMEMODE, ply)
end)