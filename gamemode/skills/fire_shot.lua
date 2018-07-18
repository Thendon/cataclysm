
local fire_shot = Skill( "fire_shot" )
local distance = 280
local handOffset = 10
fire_shot:SetMaxLive( 1 )
fire_shot:SetCooldown( 0.5 )
fire_shot:SetDamageType( "fire" )

local sounds = {
    "fire_shot",
    "fire_hit3"
}

local col = Capsule(Vector(), Vector(50,0,0), 20)
col:SetPos1Dest(Vector(100,0,0))
col:SetPos2Dest(Vector(320,0,0))

function fire_shot:Stage1( ent )
    local factor = ent.alive
    ent:SetPos( ent:GetPos() + ent:GetNW2Vector("moveDir") * ent.deltaTime )

    if CLIENT then return end

    ent.collider:LerpPositions(factor)
    local hits = ent.collider:PlayersTouched()

    for _, hit in next, hits do
        self:StartTouch( ent, hit.ply )
    end
end

function fire_shot:CanBeActivated( caster )
    return caster:WaterLevel() < 2
end

if CLIENT then
    function fire_shot:Activate( ent, caster )
        caster:PlayAnimation("shoot_fire" .. math.random(1,2))
        sound.Play(sounds[math.random(1, 2)], ent:GetPos())
        CreateParticleSystem( ent, "element_fire_throw", PATTACH_POINT_FOLLOW, 1)
        --ent.collider = Capsule( col )
        --ent.collider:SetEntity( ent )
    end

    --[[function fire_shot:Draw( ent )
        ent.collider:Draw()
    end]]
end

if SERVER then
    function fire_shot:Spawn( ent, caster )
        --[[handLeft = caster:HandSwitcher()
        local offset = caster:GetRight() * handOffset
        if (handLeft) then
            offset = offset * (-1)
        end]]

        --ent:SetNoDraw(true)
        local ang = caster:GetAimVector():Angle()
        local forward = ang:Forward()
        local pos = caster:GetPos() + _VECTOR.UP * 50 + forward * 25 --+ offset

        ent:SetPos( pos )
        ent:SetAngles( ang )
        ent:SetInvisible( true )
        ent.collider = Capsule( col )
        ent.collider:SetEntity( ent )
        ent.collider:Filter( { caster } )

        ent:SetNW2Vector("moveDir", forward * math.max(caster:GetVelocity():Dot(forward),0))
    end

    function fire_shot:StartTouch( ent, touched )
        local caster = ent:GetCaster()
        ent.alreadyTouched = ent.alreadyTouched or {}
        if (caster == touched) then return end
        if (ent.alreadyTouched[touched]) then return end

        local damage = distance - (ent.alive * distance)
        damage = damage * 0.1

        self:Hit(ent, caster, touched, damage, DMG_BLAST, ent:GetForward())

        ent.alreadyTouched[touched] = true
    end
end

skill_manager.Register( fire_shot )