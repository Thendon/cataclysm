_G.round_manager = round_manager or {}

local wins = 5
local warmupTime = 3 * 60
local prepTime = 1 * 30
local roundTime = 5 * 60
local overTime = 1 * 30
--[[
warmupTime = 3
--prepTime = 1
roundTime = 10
overTime = 1
]]
_G.ROUND_STATE = {}
ROUND_STATE.UNKNOWN = -1
ROUND_STATE.LOADING = 0
ROUND_STATE.WARMUP = 1
ROUND_STATE.PREPARING = 2
ROUND_STATE.ACTIVE = 3
ROUND_STATE.OVER = 4
ROUND_STATE.GAMEOVER = 5

local maxRounds = 2 * wins
local minPlayers = 2

local states = {}
states[ROUND_STATE.UNKNOWN] = { name = "Unknown" }
states[ROUND_STATE.LOADING] = { name = "Loading", time = 0 }
states[ROUND_STATE.WARMUP] = { name = "Warmup", time = warmupTime }
states[ROUND_STATE.PREPARING] = { name = "Preparing", time = prepTime, sound = "flute9.wav" }
states[ROUND_STATE.ACTIVE] = { name = "Active", time = roundTime, sound = "flute1.wav" }
states[ROUND_STATE.OVER] = { name = "Over", time = overTime, sound = "flute6.wav" }
states[ROUND_STATE.GAMEOVER] = { name = "Game Over", time = overTime, sound = "flute8.wav" }

local defRoundState = SERVER and ROUND_STATE.LOADING or ROUND_STATE.UNKNOWN
round_manager.roundState = round_manager.roundState or defRoundState
round_manager.startTime = round_manager.startTime or CurTime()
round_manager.stateTime = round_manager.stateTime or CurTime()
round_manager.round = round_manager.round or 0

function round_manager.GetRoundState()
    return round_manager.roundState
end

function round_manager.SetRoundState( state )
    round_manager.roundState = state
    if SERVER then round_manager.ResetStateTime() end
end

function round_manager.GetNextState( state )
    state = state or round_manager.roundState

    if state == ROUND_STATE.WARMUP and player.GetCount() < minPlayers then
        return ROUND_STATE.WARMUP
    end

    if state == ROUND_STATE.OVER then
        if round_manager.round >= maxRounds
            or team.GetScore(TEAM_BLACK) >= wins
            or team.GetScore(TEAM_WHITE) >= wins
            or player.GetCount() < 2 then
            return ROUND_STATE.GAMEOVER
        end
        return ROUND_STATE.PREPARING
    end

    return state + 1
end

function round_manager.GetTime()
    return CurTime() - round_manager.startTime
end

function round_manager.GetStateTime()
    return CurTime() - round_manager.stateTime
end

function round_manager.GetStateTimeLeft()
    if (round_manager.roundState == ROUND_STATE.UNKNOWN) then return 0 end
    local time = states[round_manager.roundState].time - (CurTime() - round_manager.stateTime)
    return math.max(time, 0)
end

function round_manager.GetStateTimestamp()
    return round_manager.stateTime
end

function round_manager.SetStateTime( timestamp )
    round_manager.stateTime = timestamp
end

function round_manager.ResetStateTime()
    round_manager.SetStateTime( CurTime() )
end

function round_manager.GetStateName()
    return states[round_manager.roundState].name
end

function round_manager.GetRound()
    return round_manager.round
end

function round_manager.GetWins()
    return wins
end

function round_manager.GetMaxRounds()
    return maxRounds
end

function round_manager.CanRespawn()
    return round_manager.roundState < ROUND_STATE.ACTIVE
end

function round_manager.CanFriendlyFire()
    return round_manager.roundState == ROUND_STATE.WARMUP or round_manager.roundState == ROUND_STATE.OVER
end

if SERVER then
    function round_manager.NextRound()
        round_manager.round = round_manager.round + 1

        netstream.Start(player.GetAll(), "round_manager:SetRound", round_manager.round)
    end

    function round_manager.RespawnAll( force )
        for k, ply in next, player.GetAll() do
            if ply:IsSpectator() then continue end
            if !force and ply:Alive() then continue end
            ply:Spawn()
        end
    end

    function round_manager.ResetHealth()
        for k, ply in next, player.GetAll() do
            if ply:IsSpectator() then continue end
            ply:SetHealth(ply:GetMaxHealth())
        end
    end

    function round_manager.ResetCooldowns()
        for k, ply in next, player.GetAll() do
            if ply:IsSpectator() then continue end
            ply:ResetCooldowns()
        end
    end

    function round_manager.TeamMoreAlive()
        local teamAlive = {}
        teamAlive[TEAM_BLACK] = 0
        teamAlive[TEAM_WHITE] = 0

        for k, ply in next, player.GetAll() do
            if ply:IsSpectator() then continue end
            if !ply:Alive() then continue end

            local teamID = ply:Team()

            teamAlive[teamID] = teamAlive[teamID] + 1
        end

        if teamAlive[TEAM_BLACK] == teamAlive[TEAM_WHITE] then return false end
        if teamAlive[TEAM_BLACK] > teamAlive[TEAM_WHITE] then return TEAM_BLACK end
        return TEAM_WHITE
    end

    function round_manager.ScoreWinner()
        local winner = false

        local teamAlive = round_manager.TeamWiped()
        if teamAlive then
            team.AddScore(teamAlive, 1)
            winner = teamAlive
        else
            local moreAlive = round_manager.TeamMoreAlive()
            if moreAlive then
                team.AddScore(moreAlive, 1)
                winner = moreAlive
            end
        end

        local points = team.GetScore(teamAlive)
        netstream.Start(player.GetAll(), "round_manager:TeamScored", winner, points)
    end

    function round_manager.AnnounceWinner()
        local scoreBlack = team.GetScore(TEAM_BLACK)
        local scoreWhite = team.GetScore(TEAM_WHITE)

        local winner
        if (scoreBlack == scoreWhite) then
            winner = false
        elseif (scoreBlack > scoreWhite) then
            winner = TEAM_BLACK
        else
            winner = TEAM_WHITE
        end

        netstream.Start(player.GetAll(), "round_manager:AnnounceWinner", winner)
    end

    function round_manager.InitState( state )
        state = state or round_manager.roundState
        round_manager.SetRoundState( state )

        if state == ROUND_STATE.WARMUP then
            --round_manager.ResetSpawnPoints()
            spawn_manager.LoadSpawnFile()
        elseif state == ROUND_STATE.PREPARING then
            spawn_manager.SwapSpawnPoints()
            skill_manager.Clear()
            round_manager.RespawnAll(true)
            round_manager.NextRound()
            spawn_manager.SpawnDomes()
        elseif state == ROUND_STATE.ACTIVE then
            spawn_manager.RemoveDomes()
            skill_manager.Clear()
            round_manager.RespawnAll()
            round_manager.ResetHealth()
            round_manager.ResetCooldowns()
        elseif state == ROUND_STATE.OVER then
            round_manager.ScoreWinner()
        elseif state == ROUND_STATE.GAMEOVER then
            round_manager.AnnounceWinner()
        end

        netstream.Start(player.GetAll(), "round_manager:InitState", state, round_manager.GetStateTimestamp())
    end

    --These have spawns
    local maps = {
        "gm_uldum2",
        "gm_floatingworlds_3",
        "gm_isles",
        "gm_dunes",
        --"001_nanshansi_shishi" --CSS CONTENT
    }

    function round_manager.LoadNextMap()
        local index = 1
        local mapname = game.GetMap()
        for k, map in next, maps do
            if map == mapname then
                index = k + 1
                break
            end
        end

        if index > table.Count(maps) then
            index = 1
        end

        RunConsoleCommand("changelevel", maps[index])
    end

    function round_manager.InitNextState( state )
        state = state or round_manager.roundState
        if state == ROUND_STATE.GAMEOVER then
            round_manager.LoadNextMap()
            return
        end

        round_manager.InitState( round_manager.GetNextState() )
    end

    function round_manager.TeamWiped()
        local teamAlive
        for k, ply in next, player.GetAll() do
            if !ply:Alive() then continue end
            local plyTeam = ply:Team()
            if plyTeam != TEAM_BLACK and plyTeam != TEAM_WHITE then continue end
            --team already declared alive
            if teamAlive == plyTeam then continue end
            --other time also alive -> both teams alive
            if teamAlive then return false end

            teamAlive = plyTeam
        end

        return teamAlive
    end

    function round_manager.NooneAlive()
        for k, ply in next, player.GetAll() do
            if ply:Alive() then return false end
        end
        return true
    end

    function round_manager.Update()
        if player.GetCount() < 1 then return end

        local stateTime = round_manager.GetStateTime()
        if stateTime > states[round_manager.roundState].time then round_manager.InitNextState() end

        if round_manager.roundState == ROUND_STATE.PREPARING then
            spawn_manager.KeepEverythingInDome()
        elseif round_manager.roundState == ROUND_STATE.ACTIVE
                and (round_manager.TeamWiped()
                or round_manager.NooneAlive()) then
            round_manager.InitNextState()
        elseif round_manager.roundState == ROUND_STATE.OVER
                and round_manager.NooneAlive() then
            round_manager.InitNextState()
        end
    end

    function round_manager.SendInfos(ply)
        local state = round_manager.GetRoundState()
        local stateTime = round_manager.stateTime
        local startTime = round_manager.startTime
        local round = round_manager.round
        local scores = {}
        scores[TEAM_BLACK] = team.GetScore(TEAM_BLACK)
        scores[TEAM_WHITE] = team.GetScore(TEAM_WHITE)
        netstream.Start(ply, "round_manager:SetInfos", state, stateTime, startTime, round, scores)
    end

    netstream.Hook("round_manager:RequestInfos", function(ply)
        round_manager.SendInfos(ply)
    end)

    hook.Add("PlayerFinishedLoading", "SendRoundState", function(ply)
        round_manager.SendInfos(ply)
    end)
end

if CLIENT then
    function round_manager.InitState( state, timestamp )
        round_manager.SetRoundState( state )
        round_manager.SetStateTime( timestamp )
        local sound = states[round_manager.roundState].sound
        if sound then PlayBGS("element/fx/misc/" .. sound) end

        if state == ROUND_STATE.ACTIVE then
            Popup.Add("Fight!", _COLOR.RED)
        end
    end

    function round_manager.SetStartTime( timestamp )
        round_manager.startTime = timestamp
    end

    function round_manager.SetRound( round )
        round_manager.round = round
    end

    function round_manager.TeamScored(winner, points)
        if !winner then
            Popup.Add("Round Draw!")
            return
        end
        Popup.Add("Team " .. team.GetName(winner) .. " Scores!", team.GetColor(winner))
        team.SetScore(winner, points)
    end

    function round_manager.AnnounceWinner(winner)
        if !winner then
            Popup.Add("Match Draw!")
            return
        end
        Popup.Add("Team " .. team.GetName(winner) .. " won!", team.GetColor(winner))
    end

    netstream.Hook("round_manager:SetInfos", function(state, stateTime, startTime, round, scores)
        round_manager.SetRoundState( state )
        round_manager.SetStateTime( stateTime )
        round_manager.SetStartTime( startTime )
        round_manager.SetRound( round )
        for teamID, points in next, scores do
            team.SetScore(teamID, points)
        end
    end)

    netstream.Hook("round_manager:InitState", function(state, timestamp)
        round_manager.InitState(state, timestamp)
    end)

    netstream.Hook("round_manager:SetRound", function(round)
        round_manager.SetRound( round )
    end)

    netstream.Hook("round_manager:TeamScored", function(winner, points)
        round_manager.TeamScored(winner, points)
    end)

    netstream.Hook("round_manager:AnnounceWinner", function(winner)
        round_manager.AnnounceWinner(winner)
    end)
end