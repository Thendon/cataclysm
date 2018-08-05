_G.SpawnCreator = SpawnCreator or {}

SpawnCreator.spawns = SpawnCreator.spawns or {}
SpawnCreator.group = SpawnCreator.group or 0

local maxDistance = 1000
maxDistance = maxDistance * maxDistance

function SpawnCreator.CreateSpawns()
    SpawnCreator.spawns = {}
    SpawnCreator.group = 0
    print("wiped spawns")
end

function SpawnCreator.RequestSpawns()
    netstream.Start("spawn_manager:RequestSpawns")
end

function SpawnCreator.LoadSpawns( tbl )
    SpawnCreator.spawns = tbl
end

function SpawnCreator.DeleteGroup( group )
    table.remove(SpawnCreator.spawns, group)
end

function SpawnCreator.SetGroup( group )
    SpawnCreator.group = group
end

function SpawnCreator.NewSpawnGroup()
    table.insert(SpawnCreator.spawns, {})
    SpawnCreator.group = SpawnCreator.group + 1
    print("added spawn group: " .. SpawnCreator.group)
end

function SpawnCreator.AddSpawn()
    local pos = LocalPlayer():GetPos() + Vector(0,0,20)
    local ang = LocalPlayer():GetAngles()

    if (SpawnCreator.spawns[1].pos) then
        PrintTable(SpawnCreator.spawns[1])
        local distance = (SpawnCreator.spawns[1].pos - pos):LengthSqr()
        if distance > maxDistance then
            print("SPAWN TO FAR AWAY FROM ORIGIN")
            return
        end
    end

    table.insert(SpawnCreator.spawns[SpawnCreator.group], { pos = pos, ang = ang })
    print("added spawn " .. tostring(pos) .. " " .. tostring(ang) .. " to group: " .. SpawnCreator.group)
end

function SpawnCreator.ShowSpawns()
    PrintTable(SpawnCreator.spawns)
    print(util.TableToJSON(SpawnCreator.spawns))
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
end)