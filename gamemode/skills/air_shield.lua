local skill = Skill( "air_shield" )
local immune = 5
local rate = 0.5

local stage2 = immune - 2
skill:SetDescription("Become completely immune to damage and move everything out of your way.")
skill:SetMaxLive( immune )
skill:SetCooldown( 10 )
skill:SetStages( { stage2 } )

 --todo make sphere collider
 --its fine though, only first sphere will be calced
local col = Capsule(Vector(), Vector(), 100)

function skill:Stage1( ent )
    ent:SetPos( ent:GetCaster():GetPos() + _VECTOR.UP * 50 )

    if SERVER then return end

    local caster = ent:GetCaster()
    if !caster:AnimationRunning() then caster:PlayAnimation("summon_air2") end
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
        ent:SetCollideWithPlayers( true )
        ent:SetCollideWithSkills( true )
        ent:RemoveOnDeath()
        ent:SetPos( caster:GetPos() + _VECTOR.UP * 50 )

        caster:SetDamageImmune( immune )
    end

    function skill:Touch( ent, touched )
        local direction = (touched:GetPos() - ent:GetPos()):GetNormalized() * 500
        direction.z = math.max(direction.z, 250)
        touched:SetVelocity( direction )
    end
end

skill_manager.Register( skill )