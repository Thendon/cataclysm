local end_up = 0.35
local forward_offset = 60
local skill = Skill( "earth_blast" )
skill:SetDescription("Throw a giant rock at your opponent.")
local damage_min_speed = 50
local damage_on_hit = 30
damage_min_speed = damage_min_speed * damage_min_speed
damage_factor = 1 / damage_on_hit
skill:SetStages({ end_up })
skill:SetCastTime( 0.5 )
skill:SetMaxLive( 10 )
skill:SetCooldown( 2 )
skill:SetDamageType( "earth" )

function skill:Stage1( ent )
    local factor = ent.alive / end_up
    local dest = LerpVector( factor * factor, ent:GetPos(), ent:GetNW2Vector("physPos") )
    ent:SetPos( dest )
end

function skill:Transition1( ent )
    if CLIENT then
        sound.Play("earth_hit", ent:GetPos())
        ent:EmitSound( "earth_woosh" )
        return
    end

    ent:InitPhys(ELEMENT_PHYS_TYPE.PROJECTILE)
    ent:PhysWake()

    local phys = ent:GetPhysicsObject()
    phys:AddVelocity(ent:GetCaster():GetAimVector() * 10000)
end

function skill:ActivationConditions( caster )
    return caster:OnGround()
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("shoot_stone")
        ParticleEffect("element_earth_summon2", caster:GetPos(), caster:GetAngles())
        ent:EmitSound("earth_summon")
        ent:CreateParticleEffect("element_earth_dirt", 1)
        ent:DrawShadow(true)
        if !IsMounted("cstrike") then
            ent:SetClientModel("models/props_wasteland/rockgranite02a.mdl")
        end
    end

    function skill:OnRemove( ent )
        ParticleEffect("element_earth_explode", ent:GetPos(), Angle())
        ent:StopSound("earth_woosh")
        sound.Play("earth_hit3", ent:GetPos())
    end
end

if SERVER then
    function skill:Spawn( ent, caster )
        ent:SetModel( "models/props/cs_militia/militiarock05.mdl" )
        local offset = caster:GetPos() + caster:GetForward() * forward_offset
        ent:SetPos( offset - _VECTOR.UP * 50 )
        ent:SetAngles(Angle(math.random(0, 360),math.random(0, 360),0))
        ent:SetNW2Vector( "physPos", offset + _VECTOR.UP * 60 )
        ent:InitPhys(ELEMENT_PHYS_TYPE.GHOST)
        ent:SetCustomCollisionCheck( true )
        ent:DrawShadow(true)
    end

    function skill:PhysicsCollide( ent, data, phys )
        if ( data.Speed > 50 ) then ent:EmitSound( "earth_hit2" ) end

        local dot = math.abs( data.HitNormal:Dot(data.OurOldVelocity:GetNormalized()) )
        if (dot > 0.5 ) then
            ent:SetDestroyFlag(true)
        end
    end

    function skill:StartTouch( ent, touched )
        if (!touched:IsPlayer()) then return end
        local velocity = ent:GetVelocity()
        local speed = velocity:LengthSqr()

        if (speed < damage_min_speed) then return end

        local damage = math.min( math.sqrt(speed - damage_min_speed) * damage_factor, damage_on_hit )

        self:Hit(ent, touched, damage, DMG_CRUSH, velocity * 0.5)
    end
end

skill_manager.Register( skill )