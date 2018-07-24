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
    halo.Add( { skill_manager.csent }, skill_manager.HaloColor(), 3, 3, 1, false, true)
end

function skill_manager.HaloPlayer()
    if ( !IsValid(skill_manager.ccply) ) then return end
    halo.Add( { skill_manager.ccply }, skill_manager.HaloColor(), 3, 3, 1, false, true)
end

function skill_manager.CleverCastPlayer( pressing, trace )
    if (!trace.Entity or !trace.Entity:IsPlayer()) then
        skill_manager.ccply = nil
        return false
    end

    if (!pressing) then
        skill_manager.ccply = nil
        return { target = trace.Entity }
    end

    skill_manager.ccply = trace.Entity

    return false
end

function skill_manager.CleverLockPlayer( pressing, trace, range, lock )
    lock = lock or 0.95

    local dir = trace.Normal
    local players = ents.FindInSphere(LocalPlayer():GetPos(), range)
    local pos = LocalPlayer():GetPos()

    local closestPlayer
    local closestDot = 0

    for k, ply in next, players do
        if (!ply:IsPlayer()) then continue end
        if (ply == LocalPlayer()) then continue end

        local plyDir = (ply:GetPos() - pos):GetNormalized()
        local plyDot = plyDir:Dot( dir )

        if plyDot > lock and plyDot > closestDot then
            closestPlayer = ply
            closestDot = plyDot
        end
    end

    if (closestPlayer and !pressing) then
        skill_manager.ccply = nil
        return { target = closestPlayer }
    end

    skill_manager.ccply = closestPlayer
    return false
end

function skill_manager.CleverCastWorld( pressing, trace )
    if (!trace.HitWorld or trace.HitSky) then
        skill_manager.csent:Hide()
        return false
    end

    local ang = trace.HitNormal:Angle()
    ang:RotateAroundAxis(ang:Right(), -90)

    if (!pressing) then
        skill_manager.csent:Hide()
        return { pos = trace.HitPos, dir = trace.HitNormal, ang = ang }
    end

    if skill_manager.csent:Hidden() then skill_manager.csent:Show() end
    skill_manager.csent:SetPos( trace.HitPos )
    skill_manager.csent:SetAngles( ang )

    return false
end

_G.skill_manager = skill_manager