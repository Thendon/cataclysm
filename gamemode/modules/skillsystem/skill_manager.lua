local skill_manager = {}

local skills = {}
local instances = {}
local damageTypes = {}

function skill_manager.Register( skill )
    skills[skill:GetName()] = skill
end

function skill_manager.GetSkill( index )
    return skills[index]
end

function skill_manager.NewInstance( ent )
    table.insert(instances, ent)
end

function skill_manager.GetAll()
    local i = 1
    while i <= table.Count(instances) do
        if !IsValid(instances[i]) then
            table.remove(instances, i)
            continue
        end
        i = i + 1
    end
    return instances
end

function skill_manager.Clear()
    print("Clear")
    for k, skill in next, skill_manager.GetAll() do
        skill:Remove()
    end
end

function skill_manager.PlayerDeath(victim)
    local skillEnts = skill_manager.GetAll()
    for _, ent in next, skillEnts do
        local players = ent:GetRemoveOnDeath()
        if (!players) then continue end

        for _, ply in next, players do
            if (!IsValid(ply)) then continue end
            if (ply != victim) then continue end
            ent:Remove()
        end
    end
end

function skill_manager.RegisterDamageType( type )
    damageTypes[type:GetName()] = type
end

function skill_manager.GetDamageType( index )
    return damageTypes[index]
end

function skill_manager.Initialize()
    if (IsValid(skill_manager.csent)) then skill_manager.csent:Remove() end

    local csent = ClientsideModel("models/props_phx/construct/plastic/plastic_angle_360.mdl")
    csent:SetNoDraw( true )

    function csent:Show()
        self.hidden = false
    end

    function csent:Hide()
        self.hidden = true
    end

    function csent:Hidden()
        return self.hidden
    end

    csent:Hide()
    skill_manager.csent = csent
end

if CLIENT then
    function skill_manager.CleverHalo()
        skill_manager.HaloCSEnt()
        skill_manager.HaloPlayer()
    end

    function skill_manager.HaloColor()
        return player_manager.RunClass(LocalPlayer(), "GetClassColor")
    end

    function skill_manager.HaloCSEnt()
        if ( !IsValid(skill_manager.csent) ) then return end
        if ( skill_manager.csent:Hidden() ) then return end

        local color = skill_manager.HaloColor()
        local additive = color == _COLOR.WHITE
        halo.Add( { skill_manager.csent }, color, 3, 3, 1, additive, true)
    end

    function skill_manager.HaloPlayer()
        if ( !IsValid(skill_manager.ccply) ) then return end

        local color = skill_manager.HaloColor()
        local additive = color == _COLOR.WHITE
        halo.Add( { skill_manager.ccply }, color, 3, 3, 1, additive, true)
    end

    local function checkRange( pos, rangeSqr )
        return (pos - LocalPlayer():GetPos()):LengthSqr() <= rangeSqr
    end

    local function checkTeam(ply, friendly)
        local teamLocal = LocalPlayer():Team()
        local teamPly = ply:Team()
        if friendly then
            return teamPly == teamLocal
        end
        return teamPly != teamLocal
    end

    local function IsValidTarget(ply, rangeSqr, friendly, pos)
        if !IsValid(ply) then return false end
        if !ply:IsPlayer() then return false end
        if ply == LocalPlayer() then return false end
        if !checkTeam(ply, friendly) then return false end
        pos = pos or ply:GetPos()
        local dir = pos - LocalPlayer():GetPos()
        if dir:LengthSqr() > rangeSqr then return false end
        return dir
    end

    --[[function skill_manager.CleverCastPlayer( pressing, trace, rangeSqr, friendly )
        if (!checkRange(trace.HitPos, rangeSqr) or !trace.Entity or !trace.Entity:IsPlayer() or !checkTeam(trace.Entity, friendly)) then
            skill_manager.ccply = nil
            return false
        end

        if (!pressing) then
            skill_manager.ccply = nil
        else
            skill_manager.ccply = trace.Entity
        end

        return true, { target = trace.Entity }
    end]]

    local function getClosestPlayer(dir, rangeSqr, friendly, lock)
        local closestPlayer
        local closestDot = 0

        for k, ply in next, player.GetAll() do
            local plyDir = IsValidTarget(ply, rangeSqr, friendly)
            if !plyDir then continue end

            local eyePos = LocalPlayer():EyePos()
            local tr = util.TraceLine({start = eyePos, endpos = eyePos + plyDir, filter = LocalPlayer()})
            if tr.Entity != ply then continue end

            plyDir:Normalize()
            local plyDot = plyDir:Dot( dir )

            if plyDot > lock and plyDot > closestDot then
                closestPlayer = ply
                closestDot = plyDot
            end
        end

        return closestPlayer
    end

    function skill_manager.CleverLockPlayer( pressing, trace, rangeSqr, friendly, lock )
        lock = lock or 0.95

        local closestPlayer
        if IsValidTarget(trace.Entity, rangeSqr, friendly, trace.HitPos) then
            closestPlayer = trace.Entity
        else
            closestPlayer = getClosestPlayer( trace.Normal, rangeSqr, friendly, lock )
        end

        if (!closestPlayer) then
            skill_manager.ccply = nil
            return false
        end

        if (!pressing) then
            skill_manager.ccply = nil
        else
            skill_manager.ccply = closestPlayer
        end
        return true, { target = closestPlayer }
    end

    function skill_manager.CleverCastWorld( pressing, trace, rangeSqr )
        if (trace.Entity and trace.Entity:IsPlayer()) then
            trace = util.TraceLine({
                start = trace.Entity:GetPos() + _VECTOR.UP * 20,
                endpos = trace.Entity:GetPos() - _VECTOR.UP * 100,
                collisiongroup = COLLISION_GROUP_WORLD
            })
        end

        if (!checkRange(trace.HitPos, rangeSqr) or !trace.HitWorld or trace.HitSky) then
            skill_manager.csent:Hide()
            return false
        end

        if (!pressing) then
            skill_manager.csent:Hide()
        elseif skill_manager.csent:Hidden() then
            skill_manager.csent:Show()
        end

        local ang = trace.HitNormal:Angle()
        ang:RotateAroundAxis(ang:Right(), -90)
        skill_manager.csent:SetPos( trace.HitPos )
        skill_manager.csent:SetAngles( ang )

        return true, { pos = trace.HitPos, dir = trace.HitNormal, ang = ang }
    end
end

_G.skill_manager = skill_manager