
local skill = Skill( "water_surf" )
skill:SetDescription("Summon a wave that boosts you forward. (You have to remain near ground) Using this in water boosts the speed!")
local duration = 3

local start = 0.5
skill:SetMaxLive( start + duration )
skill:SetCooldown( 0.5 )
skill:SetCastUntilRelease( true )
skill:SetStages({ start })
skill:SetRefillFactor(2)

local speed = 1000
local range = 150

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
    local caster = ent:GetCaster()
    if CLIENT then
        caster:PlayAnimation("fly2")
        return
    end
    caster:SetFallDamper( duration, 0.5 )
end

function skill:Stage1( ent )
    posEnt( ent )
end

function skill:Stage2( ent )
    local caster = posEnt( ent )

    if CLIENT then return end

    if caster:OnGround() then
        caster:SetMoveType(MOVETYPE_WALK)
        caster:ReachVelocity(_VECTOR.UP * 250)
        return
    end

    local boost = 1

    local tr = util.TraceLine({
        start = caster:GetPos(),
        endpos = caster:GetPos() - _VECTOR.UP * range,
        collisiongroup = COLLISION_GROUP_WORLD
    })

    if !tr.Hit then
        tr = util.TraceLine({
            start = caster:GetPos(),
            endpos = caster:GetPos() - _VECTOR.UP * range,
            mask = CONTENTS_WATER
        })

        if !tr.Hit and caster:WaterLevel() < 1 then
            caster:SetMoveType(MOVETYPE_WALK)
            return
        end

        boost = 1.5
    end

    caster:SetMoveType(MOVETYPE_FLY)
    local direction = caster:GetAimVector() * speed * boost
    caster:ReachVelocity(LerpVector(FrameTime() * 10, caster:GetVelocity(), direction))
end

if CLIENT then
    function skill:Activate( ent, caster )
        ent:CreateParticleEffect("element_water_surf", 1)
        ent:EmitSound("water_stream3")
    end

    function skill:OnRemove( ent )
        ent:StopSound("water_stream3")
        ent:GetCaster():StopAnimation()
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