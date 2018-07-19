
local skill = Skill( "fire_shot" )
local distance = 280
skill:SetMaxLive( 1 )
skill:SetCooldown( 0.5 )
skill:SetDamageType( "fire" )

local sounds = {
    "fire_shot",
    "fire_hit3"
}

local col = Capsule(Vector(), Vector(50,0,0), 20)
col:SetPos1Dest(Vector(100,0,0))
col:SetPos2Dest(Vector(320,0,0))

function skill:Stage1( ent )
    local factor = ent.alive
    ent:SetPos( ent:GetPos() + ent:GetNW2Vector("moveDir") * ent.deltaTime )

    ent.collider:LerpPositions(factor)
    if CLIENT then return end
    local hits = ent.collider:PlayersTouched()

    for _, hit in next, hits do
        self:StartTouch( ent, hit.ply )
    end
end

function skill:CanBeActivated( caster )
    return caster:WaterLevel() < 2
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("shoot_fire" .. math.random(1,2))
        sound.Play(sounds[math.random(1, 2)], ent:GetPos())
        CreateParticleSystem( ent, "element_fire_throw", PATTACH_POINT_FOLLOW, 1)

        ent.collider = Capsule( col )
        ent.collider:SetEntity( ent )
    end

    function skill:Draw( ent )
        ent.collider:Draw()
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
        ent.collider = Capsule( col )
        ent.collider:SetEntity( ent )
        ent.collider:Filter( { caster } )

        ent:SetNW2Vector("moveDir", forward * math.max(caster:GetVelocity():Dot(forward),0))
    end

    function skill:StartTouch( ent, touched )
        local damage = distance - (ent.alive * distance)
        damage = damage * 0.1

        self:Hit(ent, caster, touched, damage, DMG_BLAST, ent:GetForward())
    end
end

skill_manager.Register( skill )