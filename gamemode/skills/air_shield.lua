local skill = Skill( "air_shield" )
skill:SetMaxLive( 10 )
skill:SetCooldown( 0.5 )

local power = 1000

local particles = {
    "element_air_trail_move",
    "element_air_trail_move2"
}

local sounds = {
    "air_push",
    "air_push2"
}

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
        sound.Play(sounds[math.random(1, 2)], caster:GetPos())
        ent:CreateParticleEffect(particles[math.random(1,2)], 1)
        ent:SetCustomCollider( Capsule( col ) )
    end
end

if SERVER then
    function skill:Spawn( ent, caster )
        ent:SetInvisible( true )
        ent:SetRemoveOnWorldTrace( true )
        ent:SetTriggerFlag( true )
        ent:SetTouchRate( rate )
        ent:SetCustomCollider( Capsule( col ) )

        local ang = caster:GetAimVector():Angle()
        ent:SetAngles(ang)
    end
end

skill_manager.Register( skill )