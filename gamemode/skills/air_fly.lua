
local skill = Skill( "air_fly" )
skill:SetMaxLive( 10 )
skill:SetCooldown( 0.5 )

function skill:Stage1( ent )
    local caster = ent:GetCaster()
    ent:SetPos( caster:GetPos() )

    if CLIENT then return end

    caster:ReachVelocity(caster:GetAimVector() * 1000)
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("shoot_fire" .. math.random(1,2))
        ent:CreateParticleEffect("element_air_trail_fly", 1)
        ent:EmitSound("air_smooth")
    end

    function skill:OnRemove( ent )
        ent:StopSound("air_smooth")
    end
end

if SERVER then
    function skill:Spawn( ent, caster )
        ent:SetInvisible( true )
        caster:SetVelocity(_VECTOR.UP * 300)
        ent:RemoveOnDeath()
    end
end

skill_manager.Register( skill )