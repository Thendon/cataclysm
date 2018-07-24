local skill = Skill( "air_storm" )
skill:SetMaxLive( 13 )
skill:SetCooldown( 0.5 )
skill:SetDamageType( "air" )

local stage2 = 10
skill:SetStages( { stage2 } )

local radius = 170
local power = 1
local rate = 0.1

local col = Capsule(Vector(), Vector(), radius)
col:SetPos1Dest(Vector(0,0,0))
col:SetPos2Dest(Vector(0,0,600))

function skill:Stage1( ent )
    if CLIENT then return end
    ent:GetCustomCollider():SetFraction(ent.alive * 0.25)
end

function skill:Transition1( ent )
    if CLIENT then
        ent:StopSound("air_storm") --TODO fadeout
        ent:StopParticleEmission()
        return
    end

    local collider = ent:GetCustomCollider()

    collider:SetPos2(Vector(0,0,600))
    collider:SetPos1Dest(Vector(0,0,600))
end

function skill:Stage2( ent )
    if CLIENT then return end
    ent:GetCustomCollider():SetFraction((ent.alive - stage2) * 0.25)
end

function skill:CanBeActivated( caster )
    return caster:OnGround()
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("shoot_fire" .. math.random(1,2))
        ent:EmitSound("air_storm")
        ent:CreateParticleEffect("element_air_storm", 1)
        --ent:SetCustomCollider( Capsule( col ) )
    end

    function skill:OnRemove( ent )
        ent:StopSound("air_storm")
    end
end

if SERVER then
    function skill:Spawn( ent, caster )
        ent:SetPos( caster:GetPos() )

        ent:SetInvisible( true )
        ent:SetRemoveOnWorldTrace( true )
        ent:SetTriggerFlag( true )
        ent:SetTouchRate( 0 )
        ent:SetTouchCaster( true )
        ent:SetCustomCollider( Capsule( col ) )
        ent:SetCollideWithSkills( true )
    end

    function skill:Touch( ent, touched )
        local physObj = touched:GetPhysicsObject()
        if !IsValid(physObj) then return end

        local velocity = touched:GetVelocity()
        local direction = ent:GetCustomCollider():GetDirectionTo( touched )
        direction.z = 0
        local turn = direction:Cross(_VECTOR.UP)
        turn.z = touched:OnGround() and 250 or 50

        touched:ReachVelocity(velocity + -direction * power + turn * power )
    end
end

skill_manager.Register( skill )