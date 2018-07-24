
local skill = Skill( "fire_kick" )
local distance = 280
skill:SetMaxLive( 1 )
skill:SetCooldown( 0.5 )
skill:SetDamageType( "fire" )

local col = Capsule(Vector(0,-20,0), Vector(0,20,0), 20)
col:SetPos1Dest(Vector(320,-100,0))
col:SetPos2Dest(Vector(320,100,0))

function skill:Stage1( ent )
    ent:SetPos( ent:GetPos() + ent:GetNW2Vector("moveDir") * ent.deltaTime )

    if CLIENT then return end
    ent:GetCustomCollider():SetFraction(ent.alive)
end

function skill:CanBeActivated( caster )
    return caster:WaterLevel() < 2
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("kick_fire")
        sound.Play("fire_shot2", ent:GetPos())
        CreateParticleSystem( ent, "element_fire_spread", PATTACH_POINT_FOLLOW, 1)
    end
end

if SERVER then
    function skill:Spawn( ent, caster )
        local ang = caster:GetAimVector():Angle()
        local forward = ang:Forward()
        local pos = caster:GetPos() + _VECTOR.UP * 50 + forward * 25 --+ offset

        ent:SetPos( pos )
        ent:SetAngles( ang )
        ent:SetInvisible( true )
        ent:SetTouchPlayerOnce( true )
        ent:SetRemoveOnWorldTrace( true )
        ent:SetTriggerFlag( true )
        ent:SetCustomCollider( Capsule( col ) )

        ent:SetNW2Vector("moveDir", forward * math.max(caster:GetVelocity():Dot(forward) * 1.5,0))

        caster:SetVelocity( -caster:GetForward() * 200 )
    end

    function skill:Touch( ent, touched )
        local damage = distance - (ent.alive * distance)
        damage = damage * 0.1

        self:Hit(ent, touched, damage, DMG_FALL, ent:GetForward())
    end
end

skill_manager.Register( skill )