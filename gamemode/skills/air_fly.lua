
local skill = Skill( "air_fly" )
skill:SetDescription("Fly forward and try not to run into something.")
skill:SetMaxLive( 5 )
skill:SetCooldown( 0.5 )
skill:SetCastUntilRelease( true )
skill:SetRefillFactor( 0.2 )

local speed = 1000

function skill:Stage1( ent )
    local caster = ent:GetCaster()
    ent:SetPos( caster:GetPos() )

    if CLIENT then return end

    if caster:OnGround() then
        if ent.alive > 0.5 then ent:Remove() return end
        caster:ReachVelocity(_VECTOR.UP * 500)
        return
    end

    caster:SetMoveType(MOVETYPE_FLY)
    caster:ReachVelocity(caster:GetAimVector() * speed)
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("fly")
        ent:CreateParticleEffect("element_air_trail_fly", 1)
        ent:EmitSound("air_smooth")
    end

    function skill:OnRemove( ent )
        ent:StopSound("air_smooth")
        ent:GetCaster():StopAnimation()
    end
end

if SERVER then
    function skill:Spawn( ent, caster )
        ent:SetInvisible( true )
        ent:RemoveOnDeath()
        ent:SetPos( caster:GetPos() )
        caster:SetFallDamper( 10, 0.5 )
    end

    function skill:OnRemove( ent )
        ent:GetCaster():SetMoveType(MOVETYPE_WALK)
        ent:GetCaster():SetFallDamper(0)
    end
end

skill_manager.Register( skill )