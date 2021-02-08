local end_up = 0.35
local skill = Skill( "fire_ball" )
skill:SetDescription("Throw a fireball, which explodes on impact.")
skill:SetStages({ end_up })
skill:SetCastTime( 0.5 )
skill:SetMaxLive( 10 )
skill:SetCooldown( 10 )
skill:SetDamageType( "fire" )

local moveSpeed = 5000
local blastRange = 1000
local blastDamage = 50
local blastPower = 15

blastRange = blastRange * blastRange

local sounds = {
    "fire_hit",
    "fire_hit2"
}

function skill:Stage1( ent )
    local caster = ent:GetCaster()

    if CLIENT and caster != LocalPlayer() then return end

    local forward = caster:GetRight():Cross(_VECTOR.UP)
    ent:SetPos( _VECTOR.UP * 50 + caster:GetPos() - forward * 30 )
    ent:SetAngles( forward:Angle() )
    print("stage1")
end

function skill:Transition1( ent )
    if CLIENT then
        print(tostring(ent) .. "emit fire_engine")
        ent:EmitSound( "fire_engine" )
        return
    end
    ent:InitPhys(ELEMENT_PHYS_TYPE.PROJECTILE)
    ent:PhysWake()
    print("trans1")
    print(ent)
    print(ent.velocity)
    ent.velocity = ent:GetCaster():GetAimVector() * moveSpeed
    print(ent.velocity)
end

function skill:Stage2( ent )
    if CLIENT then return end

    print("stage2")
    print(ent)
    print(ent.velocity)
    --ent:ReachVelocity( ent.velocity )
    local physObj = ent:GetPhysicsObject()
    physObj:SetVelocity(ent.velocity)
end

function skill:ActivationConditions( caster )
    return caster:WaterLevel() < 2
end

if CLIENT then
    function skill:Activate( ent, caster )
        sound.Play("fire_ignite", ent:GetPos())

        caster:PlayAnimation("shoot_fire1")
        sound.Play(sounds[math.random(1, 2)], caster:GetPos())
        ent:CreateParticleEffect("element_fire_ball", 1)
    end
end

if SERVER then
    function skill:Spawn( ent, caster )
        ent:SetModel( "models/props_wasteland/rockgranite02a.mdl" )
        ent:SetModelScale( 0.3 )
        ent:SetInvisible(true)
        ent:InitPhys(ELEMENT_PHYS_TYPE.GHOST)
        ent:SetCustomCollisionCheck( true )
        local forward = caster:GetRight():Cross(_VECTOR.UP)
        ent:SetPos( _VECTOR.UP * 50 + caster:GetPos() - forward * 30 )
        ent:SetAngles( forward:Angle() )
    end

    function skill:PhysicsCollide( ent, data, phys )
        ent:SetDestroyFlag(true)
    end
end

function skill:OnRemove( ent )
    print("on remove")
    if CLIENT then
        print("on remove")
        ParticleEffect("element_fire_explode", ent:GetPos(), Angle())
        print(tostring(ent) .. "stop fire_engine")
        ent:StopSound("fire_engine")
        sound.Play("fire_explode", ent:GetPos())
        return
    end

    local pos = ent:GetPos()

    local hits = bounds.objectsInSphere( player.GetAll(), pos, blastRange )
    for _, hit in next, hits do
        if !EntsInSight(ent, hit.obj) then continue end

        local damage = ( 1 - hit.distance / blastRange ) * blastDamage
        print(hit.obj, damage, hit.obj:GetMaxHealth())
        local velocity = hit.obj:GetPos() - pos
        velocity.z = velocity.z + 100

        hit.obj:SetVelocity(velocity:GetNormalized() * blastPower * damage)
        self:Hit(ent, hit.obj, damage, DMG_GENERIC, velocity)
    end
end

skill_manager.Register( skill )