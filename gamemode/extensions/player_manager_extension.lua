

if SERVER then
    netstream.Hook("player_manager:RequestClassSwitch", function( ply, class )
        ply:SetClassPick( class )
        if round_manager.CanRespawn() then ply:Spawn() end
    end)

    netstream.Hook("player_manager:RequestTeamSwitch", function( ply, teamID )
        local joinCount = team.NumPlayers(teamID)
        local enemyCount = team.NumPlayers(GAMEMODE:GetEnemyTeam(teamID))
        if joinCount > enemyCount then return end

        ply:JoinTeam(teamID)
    end)
end

if CLIENT then
    function player_manager.RequestClassSwitch( class )
        local currentClass = player_manager.GetPlayerClass(LocalPlayer())
        if (currentClass == class) then return end
        if (currentClass == LocalPlayer():GetClassPick()) then return end

        netstream.Start("player_manager:RequestClassSwitch", class)
        LocalPlayer():SetClassPick( class )
    end

    function player_manager.RequestTeamSwitch( teamID )
        local currentTeam = LocalPlayer():Team()
        if (currentTeam == teamID) then return end
        netstream.Start("player_manager:RequestTeamSwitch", teamID)
    end
end