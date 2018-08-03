AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

AddCSLuaFile( "sh_loader.lua" )

include( "shared.lua" )

local respawnWait = 3

function GM:PlayerInitialSpawn( ply )
    ply:SetTeam(team.BestAutoJoinTeam())
end

local classes = {
    "fire", "water", "earth", "air"
}

function GM:PlayerSpawn( ply )
    skill_manager.PlayerDeath( ply )
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

function GM:KeyPress( ply, key )
    ply:SetKey( key, true )
end

function GM:KeyRelease( ply, key )
    ply:SetKey( key, false )
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
    inflictor = inflictor:IsWorld() and "world" or inflictor:GetName()
    --todo send team colors and attacker name instead
    netstream.Start(player.GetAll(), "DeathMessage", victim, attacker, inflictor)
end

function GM:PlayerDeath( victim, inflictor, attacker )
    victim:OnDeath( inflictor, attacker )
    victim.NextSpawnTime = CurTime() + respawnWait
    self:DeathMessage(victim, inflictor, attacker)
end

function GM:DoPlayerDeath(ply, attacker, dmgInfo)
    ply:CreateRagdoll()
    if round_manager.GetRoundState() != ROUND_STATE.ACTIVE then return end

    ply:AddDeaths( 1 )

    if ( !attacker:IsValid() or !attacker:IsPlayer() ) then return end
    if ( attacker == ply ) then return end

    attacker:AddScore( 10 )
    for k, assist in next, ply:GetAssists() do
        if assist.player == attacker then continue end
        assist.player:AddScore( 5 )
    end
end

function GM:ShouldCollide(ent1, ent2)
    if (!ent1.isskill) then return end
    local ret = ent1:ShouldCollide( ent2 )
    if ( ret != nil ) then return ret end
    return true
end

function GM:EntityTakeDamage( ent, dmg )
    --TODO remove physics damage to player
    if (dmg:GetAttacker().isskill) then return true end
end

function GM:PlayerCanPickupWeapon(ply, wep)
    return false
end

function GM:PlayerCanPickupWeapon( ply, item )
    return false
end

netstream.Hook("GM:FinishedLoading", function(ply)
    hook.Call("PlayerFinishedLoading", GAMEMODE, ply)
end)