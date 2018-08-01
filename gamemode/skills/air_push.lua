
local skill = Skill( "air_push" )
skill:SetMaxLive( 1 )
skill:SetCooldown( 0.5 )
skill:SetDamageType( "air" )

local power = 1500

local particles = {
    "element_air_trail_move",
    "element_air_trail_move2"
}

local sounds = {
    "air_push",
    "air_push2"
}

local rate = 0.1

local col = Capsule(Vector(), Vector(), 40)
col:SetPos1Dest(Vector(0,0,0))
col:SetPos2Dest(Vector(1000,0,0))

function skill:Stage1( ent )
    local pos = ent:GetCaster():GetPos() + _VECTOR.UP * 50 + ent:GetAngles():Forward() * 25
    ent:SetPos(pos)

    if CLIENT then return end
    local fraction = 1 + ent.alive
    ent:GetCustomCollider():SetFraction(fraction * fraction - 1)
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("shoot_air")
        sound.Play(sounds[math.random(1, 2)], caster:GetPos())
        ent:CreateParticleEffect(particles[math.random(1,2)], 1)
    end
end

if SERVER then
    function skill:Spawn( ent, caster )
        ent:SetInvisible( true )
        ent:SetRemoveOnWorldTrace( true )
        ent:SetTriggerFlag( true )
        ent:SetTouchRate( rate )
        ent:SetCustomCollider( Capsule( col ) )
        ent:SetCollideWithSkills( true )
        ent:RemoveOnDeath()
        ent:SetPos(caster:GetPos() + _VECTOR.UP * 50)

        local ang = caster:GetAimVector():Angle()
        ent:SetAngles(ang)
    end

    function skill:Touch( ent, touched )
        local velocity = ent:GetForward() * power
        if touched:OnGround() then velocity.z = 250 end
        touched:ReachVelocity( velocity )

        self:Hit(ent, touched)
    end
end

skill_manager.Register( skill )