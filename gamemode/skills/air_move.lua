
local skill = Skill( "air_move" )
skill:SetMaxLive( 2 )
skill:SetCooldown( 0.5 )
skill:SetDamageType( "air" )

local power = 1000
local movespeed = 20

local rate = 0.5

local col = Capsule(Vector(100,0,0), Vector(100,0,0), 100)
col:SetPos1Dest(Vector(100,0,0))
col:SetPos2Dest(Vector(900,0,0))

function skill:Stage1( ent )
    local pos = ent:GetPos() + ent:GetForward() * ent.alive * movespeed
    ent:SetPos( pos )

    if CLIENT then return end
    ent:GetCustomCollider():SetFraction(ent.alive)
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("shoot_fire" .. math.random(1,2))
        ent:CreateParticleEffect("element_air_trail_remove", 1)
        ent:EmitSound("air_move")
    end
end

if SERVER then
    function skill:Spawn( ent, caster )
        local ang = caster:GetAimVector():Angle()
        local pos = ent:GetCaster():GetPos() + _VECTOR.UP * 50 + ang:Forward() * 25
        ent:SetPos( pos )
        ent:SetAngles( ang )

        ent:SetInvisible( true )
        ent:SetRemoveOnWorldTrace( true )
        ent:SetTriggerFlag( true )
        ent:SetTouchRate( rate )
        ent:SetCustomCollider( Capsule( col ) )
        ent:SetCollideWithSkills( true )
    end

    function skill:Touch( ent, touched )
        local velocity = ent:GetCustomCollider():GetDirectionTo( touched )
        velocity = velocity:GetNormalized() * power
        velocity.z = touched:OnGround() and 250 or 50
        touched:ReachVelocity( velocity )
    end
end

skill_manager.Register( skill )