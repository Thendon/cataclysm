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

    velocity = forward * -power
    velocity.z = 0

    ReachVelocity(caster, velocity)
end

function skill:CanBeActivated( caster )
    return caster:WaterLevel() < 2
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("dash_fire")
        caster:EmitSound("fire_burst")
        ent:CreateParticleEffect("element_fire_dash", 1)
    end
end

if SERVER then
    function skill:Spawn( ent, caster )
        ent:SetInvisible( true )
        ent:SetPos( _VECTOR.UP * 50 + caster:GetPos() )
        local forward = caster:GetRight():Cross(_VECTOR.UP)
        ent:SetAngles( forward:Angle() )

        function ent:OnRemove()
            self:StopSound("fire_burst")
        end

        caster:SetFallImmune( 4 )
    end
end

skill_manager.Register( skill )