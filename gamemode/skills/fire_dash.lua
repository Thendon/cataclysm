local skill = Skill( "fire_dash")
skill:SetMaxLive( 1 )
skill:SetCooldown( 1 )

local power = 1750

function skill:Stage1( ent )
    local caster = ent:GetCaster()
    ent:SetPos( _VECTOR.UP * 50 + caster:GetPos() )
    local forward = caster:GetRight():Cross(_VECTOR.UP):GetNormalized()
    ent:SetAngles( forward:Angle() )

    if CLIENT then return end

    local velocity = forward * -power
    velocity.z = 0
    caster:ReachVelocity(velocity)
end

function skill:CanBeActivated( caster )
    return caster:WaterLevel() < 2
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("dash_fire")
        ent:EmitSound("fire_burst")
        ent:CreateParticleEffect("element_fire_dash", 1)
    end

    function skill:OnRemove( ent )
        ent:StopSound("fire_burst")
    end
end

if SERVER then
    function skill:Spawn( ent, caster )
        ent:SetInvisible( true )
        ent:SetPos( _VECTOR.UP * 50 + caster:GetPos() )
        local forward = caster:GetRight():Cross(_VECTOR.UP)
        ent:SetAngles( forward:Angle() )
        ent:RemoveOnDeath()
        caster:SetFallDamper( 1.5, 0.25 )
        --caster:SetFallImmune( 1.5 )
    end
end

skill_manager.Register( skill )