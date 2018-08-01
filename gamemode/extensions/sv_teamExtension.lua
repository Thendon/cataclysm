--MEH
local teams = {}

function team.SpawnPointsSet( id, points )
    teams[id] = teams[id] or {}
    teams[id].spawnPoints = points
end

function team.SpawnPointsAdd( id, point )
    teams[id] = teams[id] or {}
    teams[id].spawnPoints = teams[id].spawnPoints or {}

    table.insert(teams[id].spawnPoints, point)
end

function team.SpawnPointsGet( id )
    teams[id] = teams[id] or {}
    return teams[id].spawnPoints or {}
end