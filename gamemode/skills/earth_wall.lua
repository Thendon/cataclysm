local end_up = 2
local up_time = 10
local skill = Skill( "earth_wall" )
skill:SetDescription("Summon a wall, which protects you and your team from projectiles.")
skill:SetStages({ end_up, up_time })
skill:SetMaxLive( 15 )
skill:SetCooldown( 15 )
skill:SetDamageType( "earth" )

local forward_offset = 200
local movespeed = 0.001

function skill:Stage1( ent )
    local progress = ent.alive / end_up
    local dest = LerpVector( progress, ent:GetNW2Vector("startPos"), ent:GetNW2Vector("endPos") )
    ent:SetPos( dest )
end

function skill:Transition1( ent )
    if SERVER then ent:InitPhys(ELEMENT_PHYS_TYPE.SOLID) end
end

function skill:Transition2( ent )
    if SERVER then return end
    ent:EmitSound("earth_grow")
    ParticleEffect("element_earth_burst_big", ent:GetNW2Vector("startPos") + Vector(0,0,300), Angle())
end

function skill:Stage3( ent )
    local progress = movespeed + ent.deltaTime
    local dest = LerpVector( progress, ent:GetPos(), ent:GetNW2Vector("startPos") )
    ent:SetPos( dest )
end

function skill:ActivationConditions( caster )
    return caster:OnGround()
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("summon_earth")
        ParticleEffect("element_earth_burst_big", ent:GetPos() + Vector(0,0,300), Angle())
        sound.Play("earth_summon2", ent:GetPos())
        ent:EmitSound("earth_grow")
    end
end

if SERVER then
    function skill:Spawn( ent, caster )
        ent:SetModel( "models/props_wasteland/rockcliff05a.mdl" )
        local offset = caster:GetPos() + caster:GetForward() * forward_offset
        ent:SetPos( offset - _VECTOR.UP * 300 )
        ent:SetAngles( caster:GetAngles() )
        ent:SetTouchCaster( true )
        ent:SetTouchRate( 0 )
        ent:SetNW2Vector( "startPos", ent:GetPos() )
        ent:SetNW2Vector( "endPos", offset + _VECTOR.UP )

        ent:InitPhys(ELEMENT_PHYS_TYPE.TRIGGER)
        ent:PhysWake()
    end

    function skill:Touch( ent, touched )
        local direction = (touched:GetPos() - ent:OBBCenter()):GetNormalized()
        direction.z = 0
        touched:ReachVelocity(direction * 500)
    end
end

skill_manager.Register( skill )