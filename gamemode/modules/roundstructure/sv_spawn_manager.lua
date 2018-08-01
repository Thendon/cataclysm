_G.spawn_manager = spawn_manager or {}

spawn_manager.spawnPoints = spawn_manager.spawnPoints or {}
spawn_manager.swapperIndex = spawn_manager.swapperIndex or 1
spawn_manager.teamSpawnPoints = spawn_manager.teamSpawnPoints or {}
spawn_manager.usedSpawnPoints = spawn_manager.usedSpawnPoints or {}

spawn_manager.domes = spawn_manager.domes or {}

function spawn_manager.LoadSpawnFile()
    local filename = "element/" .. game.GetMap() .. ".txt"
    local content = file.Read( filename, "DATA" )
    if !content then return end
    local spawns = util.JSONToTable(content)
    if !spawns or table.Count(spawns) == 0 then return end

    local i = 1
    for _, group in next, spawns do
        spawn_manager.spawnPoints[i] = {}
        for _, spawn in next, group do
            table.insert(spawn_manager.spawnPoints[i], spawn)
        end
        i = i + 1
    end
end

function spawn_manager.SwapSpawnPoints()
    local groups = table.Count(spawn_manager.spawnPoints)

    if spawn_manager.swapperIndex > groups then
        spawn_manager.swapperIndex = 1
    end

    local groupBlack
    local groupWhite
    if (spawn_manager.swapperIndex % 2 != 0) then
        groupBlack = spawn_manager.swapperIndex
        groupWhite = spawn_manager.swapperIndex + 1

        if groupWhite > groups then
            groupWhite = 1
        end
    else
        groupBlack = spawn_manager.swapperIndex
        groupWhite = spawn_manager.swapperIndex - 1

        if groupWhite < 1 then
            groupWhite = groups
        end
    end

    spawn_manager.teamSpawnPoints[TEAM_BLACK] = spawn_manager.spawnPoints[groupBlack]
    spawn_manager.teamSpawnPoints[TEAM_WHITE] = spawn_manager.spawnPoints[groupWhite]
    spawn_manager.swapperIndex = spawn_manager.swapperIndex + 1
    spawn_manager.ResetSpawnPoints()
end

function spawn_manager.ResetSpawnPoints()
    spawn_manager.usedSpawnPoints[TEAM_BLACK] = {}
    spawn_manager.usedSpawnPoints[TEAM_WHITE] = {}
end

function spawn_manager.IsSpawnOccupied( spawn, teamID )
    local occupied = false
    for ply, usedSpawn in next, spawn_manager.usedSpawnPoints[teamID] do
        if spawn != usedSpawn then continue end
        if !IsValid(ply) then return false end
        occupied = true
        break
    end

    return occupied
end

function spawn_manager.GetFreeSpawnPoint(ply)
    local teamID = ply:Team()
    if !spawn_manager.teamSpawnPoints[teamID] then return false end

    for _, spawn in next, spawn_manager.teamSpawnPoints[teamID] do
        if spawn_manager.IsSpawnOccupied( spawn, teamID ) then continue end
        spawn_manager.usedSpawnPoints[teamID][ply] = spawn
        return spawn
    end

    return false
end

function spawn_manager.GetPlayerSpawn(ply)
    local teamID = ply:Team()
    if !spawn_manager.usedSpawnPoints[teamID] then return end
    if spawn_manager.usedSpawnPoints[teamID][ply] then
        return spawn_manager.usedSpawnPoints[teamID][ply]
    end
    return spawn_manager.GetFreeSpawnPoint(ply)
end

function spawn_manager.SpawnDomes()
    if !spawn_manager.teamSpawnPoints[TEAM_BLACK] or !spawn_manager.teamSpawnPoints[TEAM_WHITE] then return end

    spawn_manager.RemoveDomes()

    local spawn, dome11, dome12, dome21, dome22

    dome11 = ents.Create("element_dome")
    dome12 = ents.Create("element_dome")

    spawn = spawn_manager.teamSpawnPoints[TEAM_BLACK][1]
    dome11:SetPos(spawn.pos)
    dome12:SetPos(spawn.pos)
    dome12:SetAngles(Angle(180,0,0))

    dome21 = ents.Create("element_dome")
    dome22 = ents.Create("element_dome")

    spawn = spawn_manager.teamSpawnPoints[TEAM_WHITE][1]
    dome21:SetPos(spawn.pos)
    dome22:SetPos(spawn.pos)
    dome22:SetAngles(Angle(180,0,0))

    spawn_manager.domes = { dome11, dome12, dome21, dome22 }

    for k, dome in next, spawn_manager.domes do
        dome:Spawn()
    end
end

function spawn_manager.RemoveDomes()
    for k, dome in next, spawn_manager.domes do
        if (!IsValid(dome)) then continue end
        dome:Remove()
    end
    spawn_manager.domes = {}
end

local domeDistance = 1000
local domeDistanceSqr = domeDistance * domeDistance

function spawn_manager.KeepEverythingInDome()
    local stuff = player.GetAll()
    table.Add(stuff, skill_manager.GetAll())

    for k, ent in next, stuff do
        local isPlayer = ent:IsPlayer()
        local ply = isPlayer and ent or ent:GetCaster()
        local teamID = ply:Team()

        if teamID < 1 then continue end
        if !spawn_manager.teamSpawnPoints[teamID] then continue end

        local domeSpawn = spawn_manager.teamSpawnPoints[teamID][1]
        local distance = ent:GetPos() - domeSpawn.pos
        if distance:LengthSqr() > domeDistanceSqr then
            if isPlayer then
                ent:Spawn()
            else
                ent:Remove()
            end
        end
    end
end

netstream.Hook("spawn_manager:RequestSpawns", function( ply )
    netstream.Start(ply, "SpawnCreator:LoadSpawns", spawn_manager.spawnPoints)
end)