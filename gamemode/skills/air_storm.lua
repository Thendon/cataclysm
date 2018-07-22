local skill = Skill( "air_storm" )
skill:SetMaxLive( 10 )
skill:SetCooldown( 0.5 )
skill:SetDamageType( "air" )

local power = 1000

local rate = 0.1

local col = Capsule(Vector(), Vector(), 100)
col:SetPos1Dest(Vector(0,0,0))
col:SetPos2Dest(Vector(0,0,1000))

function skill:Stage1( ent )
    local fraction = 1 + ent.alive
    ent:GetCustomCollider():SetFraction(fraction * fraction - 1)

    if CLIENT then return end
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("shoot_fire" .. math.random(1,2))
        ent:EmitSound("air_storm")
        ent:CreateParticleEffect("element_air_storm", 1)
        ent:SetCustomCollider( Capsule( col ) )
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
        ent:SetTouchRate( rate )
        ent:SetCustomCollider( Capsule( col ) )
        ent:SetTouchAllEnts( true )
    end

    function skill:Touch( ent, touched )
    end
end

skill_manager.Register( skill )