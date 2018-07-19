local end_up = 0.35
local skill = Skill( "fire_ball" )
skill:SetStages({ end_up })
skill:SetCastTime( 0.5 )
skill:SetMaxLive( 10 )
skill:SetCooldown( 1 )
skill:SetDamageType( "fire" )

local moveSpeed = 5000

local explosions = {
    "element_fire_explode",
    "element_fire_explode2",
    "element_fire_implode"
}

function skill:Stage1( ent )
    local caster = ent:GetCaster()
    local forward = caster:GetRight():Cross(_VECTOR.UP)
    ent:SetPos( _VECTOR.UP * 50 + caster:GetPos() - forward * 30 )
    ent:SetAngles( forward:Angle() )
end

function skill:Transition1( ent )
    if CLIENT then return end
    ent:InitPhys(ELEMENT_PHYS_TYPE.PROJECTILE)
    ent:PhysWake()
    ent:EmitSound( "earth_woosh2" )
    ent.velocity = ent:GetCaster():GetAimVector() * moveSpeed
end

function skill:Stage2( ent )
    if CLIENT then return end

    ReachVelocity( ent, ent.velocity )
end

function skill:CanBeActivated( caster )
    return caster:OnGround()
end

if CLIENT then
    function skill:Activate( ent, caster )
        --sound.Play("fire_explode", ent:GetPos())

        caster:PlayAnimation("shoot_fire1")
        sound.Play("fire_explode2", caster:GetPos())
        ent:CreateParticleEffect("element_fire_ball", 1)
    end
end

if SERVER then
    function skill:Spawn( ent, caster )
        ent:SetModel( "models/props/cs_militia/militiarock05.mdl" )
        --ent:SetInvisible(true)
        ent:InitPhys(ELEMENT_PHYS_TYPE.GHOST)
        function ent:OnRemove()
            ParticleEffect("element_fire_explode"--[[explosions[math.random(1, 3)]], self:GetPos(), Angle())
            self:StopSound("earth_woosh2")
            sound.Play("fire_explode", self:GetPos())

            //NETWORK ME :)
        end
        ent:SetCustomCollisionCheck( true )
    end

    function skill:PhysicsCollide( ent, data, phys )
        ent:SetDestroyFlag(true)
    end
end

skill_manager.Register( skill )