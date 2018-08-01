
local skill = Skill( "water_surf" )
local duration = 3

local start = 0.5
skill:SetMaxLive( start + duration )
skill:SetCooldown( 0.5 )
skill:SetCastUntilRelease( true )
skill:SetStages({ start })

local speed = 1000

local function posEnt( ent )
    local caster = ent:GetCaster()

    if CLIENT and caster != LocalPlayer() then return end

    ent:SetPos( caster:GetPos() + Vector(0, 0, 20) )
    local forward = caster:GetForward()
    forward.z = 0
    ent:SetAngles( forward:Angle() )

    return caster
end

function skill:Transition1( ent )
    if CLIENT then return end
    ent:GetCaster():SetFallDamper( duration, 0.25 )
end

function skill:Stage1( ent )
    posEnt( ent )
end

function skill:Stage2( ent )
    local caster = posEnt( ent )

    if CLIENT then return end

    if caster:OnGround() then
        caster:SetMoveType(MOVETYPE_WALK)
        caster:ReachVelocity(_VECTOR.UP * 500)
        return
    end

    local tr = util.TraceLine({
        start = caster:GetPos(),
        endpos = caster:GetPos() - _VECTOR.UP * 50,
        collisiongroup = COLLISION_GROUP_WORLD
    })

    if !tr.Hit then return end

    caster:SetMoveType(MOVETYPE_FLYGRAVITY)
    caster:ReachVelocity(caster:GetAimVector() * speed)
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("shoot_fire" .. math.random(1,2))
        ent:CreateParticleEffect("element_water_surf", 1)
        ent:EmitSound("water_stream3")
    end

    function skill:OnRemove( ent )
        ent:StopSound("water_stream3")
    end
end

if SERVER then
    function skill:Spawn( ent, caster )
        ent:SetInvisible( true )
        ent:RemoveOnDeath()
        posEnt( ent )
    end

    function skill:OnRemove( ent )
        ent:GetCaster():SetMoveType(MOVETYPE_WALK)
    end
end

skill_manager.Register( skill )