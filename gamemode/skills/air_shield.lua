local skill = Skill( "air_shield" )
local immune = 5
local rate = 0.5

local stage2 = immune - 2
skill:SetMaxLive( immune )
skill:SetCooldown( 0.5 )
skill:SetStages( { stage2 } )

 --todo make sphere collider
 --its fine though, only first sphere will be calced
local col = Capsule(Vector(), Vector(), 100)

function skill:Stage1( ent )
    ent:SetPos( ent:GetCaster():GetPos() + _VECTOR.UP * 50 )
end

function skill:Transition1( ent )
    ent:StopSound("air_storm2")
    ent:StopParticles()
end

function skill:Stage2( ent )
    ent:SetPos( ent:GetCaster():GetPos() + _VECTOR.UP * 50 )
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("shoot_fire" .. math.random(1,2))
        ent:EmitSound("air_storm2")
        ent:CreateParticleEffect("element_air_shield", 1)
        --ent:SetCustomCollider( Capsule( col ) )
    end

    function skill:OnRemove( ent )
        ent:StopSound("air_storm2")
    end
end

if SERVER then
    function skill:Spawn( ent, caster )
        ent:SetInvisible( true )
        ent:SetRemoveOnWorldTrace( true )
        ent:SetTriggerFlag( true )
        ent:SetTouchRate( rate )
        ent:SetCustomCollider( Capsule( col ) )
        ent:SetCollideWithPlayers( false )
        ent:SetCollideWithSkills( true )
        ent:RemoveOnDeath()

        caster:SetSkillImmune( immune )
        caster:SetFallImmune( immune )
    end

    function skill:StartTouch( ent, touched )
        if ent:IsPlayer() then return end

        local physObj = ent:GetPhysicsObject()
        if (!IsValid(physObj)) then return end

        physObj:SetVelocity(-physObj:GetVelocity())
    end
end

skill_manager.Register( skill )