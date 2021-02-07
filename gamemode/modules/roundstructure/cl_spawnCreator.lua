_G.SpawnCreator = SpawnCreator or {}

SpawnCreator.spawns = SpawnCreator.spawns or {}
SpawnCreator.group = SpawnCreator.group or 1

local maxDistance = 1000
maxDistance = maxDistance * maxDistance

function SpawnCreator.CreateSpawns()
    SpawnCreator.spawns = {}
    SpawnCreator.group = 1
    print("wiped spawns")
end

function SpawnCreator.RequestSpawns()
    netstream.Start("spawn_manager:RequestSpawns")
end

function SpawnCreator.LoadSpawns( tbl )
    SpawnCreator.spawns = tbl
end

function SpawnCreator.SaveSpawns()
    local groupCount = table.Count(SpawnCreator.spawns)
    if groupCount < 2 then print("there should be at least 2 spawn groups!") return end

    for index = 1, groupCount do
        if !SpawnCreator.spawns[index] then print("group " .. index .. " is missing!") return end
        if table.Count(SpawnCreator.spawns[index]) < 5 then print("group " .. index .. " invalid! (there should be at least 5 spawns)") return end
    end

    netstream.Start("spawn_manager:SaveSpawns", SpawnCreator.spawns)
    print("saved! (check your servers \"garrysmod/garrysmod/data/element/\" folder for the map.txt file)")
end

function SpawnCreator.SetGroup( group )
    SpawnCreator.group = group
    print("editing group: " .. SpawnCreator.group)
end

local function getFreeSpawnGroup()
    local groupCount = table.Count(SpawnCreator.spawns)

    for index = 1, groupCount do
        if SpawnCreator.spawns[index] then continue end
        return index
    end
    return groupCount + 1
end

function SpawnCreator.DeleteGroup( group )
    group = group or SpawnCreator.group
    --table.remove(SpawnCreator.spawns, group)
    SpawnCreator.spawns[group] = nil
    print("group " .. group .. " removed")
end

function SpawnCreator.NewSpawnGroup( group )
    if !group then group = getFreeSpawnGroup() end

    SpawnCreator.spawns[group] = {}
    print("added spawn group: " .. group)
    SpawnCreator.SetGroup( group )
end

function SpawnCreator.AddSpawn()
    print("editing group: " .. SpawnCreator.group)
    local pos = LocalPlayer():GetPos() + Vector(0,0,20)
    local ang = LocalPlayer():GetAngles()

    if (!SpawnCreator.spawns[SpawnCreator.group]) then print("invalid spawn group!") return end

    --PrintTable(SpawnCreator.spawns[SpawnCreator.group])
    if SpawnCreator.spawns[SpawnCreator.group][1] then
        local distance = (SpawnCreator.spawns[SpawnCreator.group][1].pos - pos):LengthSqr()
        if distance > maxDistance then
            print("spawn too far away from origin")
            return
        end
    end

    table.insert(SpawnCreator.spawns[SpawnCreator.group], { pos = pos, ang = ang })
    print("added spawn " .. tostring(pos) .. " " .. tostring(ang))
end

function SpawnCreator.RemoveSpawn( index )
    if (!SpawnCreator.spawns[SpawnCreator.group]) then print("spawn group " .. SpawnCreator.group .. " invalid!") end
    if (!SpawnCreator.spawns[SpawnCreator.group][index]) then print("spawn " .. index .. " invalid!") end
    table.remove(SpawnCreator.spawns[SpawnCreator.group], index)
end

function SpawnCreator.ShowSpawns()
    print("Table:")
    PrintTable(SpawnCreator.spawns)
    print()
    print("JSON:")
    print(util.TableToJSON(SpawnCreator.spawns))
    print()
    print("spawns are visible! (use \"cata_spawns new\" to hide them)")
end

local colFactor = 0.1

local function VectorToColor( vec )
    local col = Color( vec.x, vec.y, vec.z )

    col.r = math.abs(col.r)
    col.g = math.abs(col.g)
    col.b = math.abs(col.b)

    return col
end

function SpawnCreator.Draw()
    if table.Count(SpawnCreator.spawns) < 1 then return end

    for k, group in next, SpawnCreator.spawns do
        if table.Count(group) < 1 then continue end

        local col = VectorToColor(group[1].pos * colFactor)
        render.DrawWireframeSphere(group[1].pos, 1000, 50, 50, col, true)

        for j, spawn in next, group do
            col = VectorToColor( spawn.pos - group[1].pos )
            render.DrawWireframeSphere(spawn.pos, 25, 10, 10, col, true)
        end
    end
end

hook.Add("PostDrawOpaqueRenderables", "DrawSpawnCreator", function()
    SpawnCreator.Draw()
end)

netstream.Hook("SpawnCreator:LoadSpawns", function( tbl )
    SpawnCreator.LoadSpawns( tbl )
    print("spawns loaded!")
end)

local function spawncommand(ply, cmd, args, argString)
    local option = args[1]
    if !option then return false end

    if option == "new" then SpawnCreator.CreateSpawns() return end
    if option == "request" then SpawnCreator.RequestSpawns() return end
    if option == "save" then SpawnCreator.SaveSpawns() return end
    if option == "show" then SpawnCreator.ShowSpawns() return end

    if option == "spawn_add" then SpawnCreator.AddSpawn() return end

    local index = args[2]
    if index then index = tonumber(index) end

    if option == "group_new" then SpawnCreator.NewSpawnGroup(index) return end

    if !index then print("no id given") return end
    if option == "group_edit" then SpawnCreator.SetGroup( index ) return end
    if option == "group_delete" then SpawnCreator.DeleteGroup(index) return end
    if option == "spawn_remove" then SpawnCreator.RemoveSpawn( index ) return end
end

local simpleOptions = { "new", "request", "save", "show", "spawn_add" }
local groupIndexOptions = { "group_new", "group_delete", "group_edit" }
local spawnIndexOptions = { "spawn_remove" }
local function autocomplete(cmd, argString)
    argString = string.Trim( argString )
    argString = string.lower( argString )

    local tbl = {}
    for _, option in next, simpleOptions do
        if string.find(option, argString) then table.insert(tbl, "cata_spawns " .. option) end
    end
    for _, option in next, groupIndexOptions do
        if string.find(option, argString) then table.insert(tbl, "cata_spawns " .. option) end
        if string.find(argString, option) then
            for index, _ in next, SpawnCreator.spawns do
                table.insert(tbl, "cata_spawns " .. option .. " " .. index)
            end
        end
    end
    for _, option in next, spawnIndexOptions do
        if string.find(option, argString) then table.insert(tbl, "cata_spawns " .. option) end
        if string.find(argString, option) and SpawnCreator.spawns[SpawnCreator.group] then
            for index, _ in next, SpawnCreator.spawns[SpawnCreator.group] do
                table.insert(tbl, "cata_spawns " .. option .. " " .. index)
            end
        end
    end
    return tbl
end

local helptext = "cata_spawns <option>"
concommand.Add("cata_spawns", spawncommand, autocomplete, helptext)