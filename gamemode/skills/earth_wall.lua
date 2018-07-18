local end_up = 2
local up_time = 10
local earth_wall = Skill( "earth_wall" )
earth_wall:SetStages({ end_up, up_time })
earth_wall:SetMaxLive( 15 )
earth_wall:SetCooldown( 1 )
earth_wall:SetDamageType( "earth" )

local forward_offset = 200
local movespeed = 0.001

function earth_wall:Stage1( ent )
    local progress = ent.alive / end_up
    local dest = LerpVector( progress, ent:GetNW2Vector("startPos"), ent:GetNW2Vector("endPos") )
    ent:SetPos( dest )
end

function earth_wall:Stage2( ent )
end

function earth_wall:Transition2( ent )
    if SERVER then return end
    ent:EmitSound("earth_grow")
    ParticleEffect("element_earth_burst_big", ent:GetNW2Vector("startPos") + Vector(0,0,300), Angle())
end

function earth_wall:Stage3( ent )
    local progress = movespeed + ent.deltaTime
    local dest = LerpVector( progress, ent:GetPos(), ent:GetNW2Vector("startPos") )
    ent:SetPos( dest )
end

function earth_wall:CanBeActivated( caster )
    return caster:OnGround()
end

if CLIENT then
    function earth_wall:Activate( ent, caster )
        caster:PlayAnimation("shoot_stone")
        ParticleEffect("element_earth_burst_big", ent:GetPos() + Vector(0,0,300), Angle())
        sound.Play("earth_summon2", ent:GetPos())
        ent:EmitSound("earth_grow")
    end
end

if SERVER then
    function earth_wall:Spawn( ent, caster )
        ent:SetModel( "models/props_wasteland/rockcliff05a.mdl" )
        local offset = caster:GetPos() + caster:GetForward() * forward_offset
        ent:SetPos( offset - _VECTOR.UP * 300 )
        ent:SetAngles( caster:GetAngles() )
        ent:SetNW2Vector( "startPos", ent:GetPos() )
        ent:SetNW2Vector( "endPos", offset + _VECTOR.UP )

        ent:InitPhys(ELEMENT_PHYS_TYPE.SOLIDMOVING)
        ent:PhysWake()
    end
end

skill_manager.Register( earth_wall )