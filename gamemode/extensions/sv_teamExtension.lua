
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

local function shuffleTable( tbl )
    local size = #tbl
    for i = size, 1, -1 do
        local rand = math.random(size)
        tbl[i], tbl[rand] = tbl[rand], tbl[i]
    end
    return tbl
end

function team.SpawnPointsGet( id )
    teams[id] = teams[id] or {}
    teams[id].spawnPoints = teams[id].spawnPoints or {}

    teams[id].spawnPoints = shuffleTable(teams[id].spawnPoints)

    return teams[id].spawnPoints or {}
end