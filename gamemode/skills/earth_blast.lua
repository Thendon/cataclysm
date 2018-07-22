local end_up = 0.35
local forward_offset = 60
local earth_blast = Skill( "earth_blast" )
local damage_min_speed = 50
local damage_on_hit = 50
damage_min_speed = damage_min_speed * damage_min_speed
damage_factor = 1 / damage_on_hit
earth_blast:SetStages({ end_up })
earth_blast:SetCastTime( 0.5 )
earth_blast:SetMaxLive( 10 )
earth_blast:SetCooldown( 1 )
earth_blast:SetDamageType( "earth" )

function earth_blast:Stage1( ent )
    local factor = ent.alive / end_up
    local dest = LerpVector( factor * factor, ent:GetPos(), ent:GetNW2Vector("physPos") )
    ent:SetPos( dest )
end

function earth_blast:Transition1( ent )
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

function earth_blast:CanBeActivated( caster )
    return caster:OnGround()
end

function earth_blast:OnRemove( ent )
    if SERVER then return end

    ParticleEffect("element_earth_explode", ent:GetPos(), Angle())
    ent:StopSound("earth_woosh")
    sound.Play("earth_hit3", ent:GetPos())
end

if CLIENT then
    function earth_blast:Activate( ent, caster )
        caster:PlayAnimation("shoot_stone")
        ParticleEffect("element_earth_summon2", caster:GetPos(), caster:GetAngles())
        ent:EmitSound("earth_summon")
        ent:CreateParticleEffect("element_earth_dirt", 1)
    end
end

if SERVER then
    function earth_blast:Spawn( ent, caster )
        ent:SetModel( "models/props/cs_militia/militiarock05.mdl" )
        local offset = caster:GetPos() + caster:GetForward() * forward_offset
        ent:SetPos( offset + _VECTOR.UP * (-50) )
        ent:SetAngles(Angle(math.random(0, 360),math.random(0, 360),0))
        ent:SetNW2Vector( "physPos", offset + _VECTOR.UP * 60 )
        ent:InitPhys(ELEMENT_PHYS_TYPE.GHOST)
        ent:SetCustomCollisionCheck( true )
        --ent:NoCollideWithCaster()
    end

    function earth_blast:PhysicsCollide( ent, data, phys )
        if ( data.Speed > 50 ) then ent:EmitSound( "earth_hit2" ) end

        --if (IsValid(data.HitEntity) and data.HitEntity:IsPlayer()) then return end
        local dot = math.abs( data.HitNormal:Dot(data.OurOldVelocity:GetNormalized()) )
        if (dot > 0.5 ) then
            ent:SetDestroyFlag(true)
        end
    end

    function earth_blast:StartTouch( ent, touched )
        if (!touched:IsPlayer()) then return end
        local velocity = ent:GetVelocity()
        local speed = velocity:LengthSqr()

        if (speed < damage_min_speed) then return end

        local damage = math.min( math.sqrt(speed - damage_min_speed) * damage_factor, damage_on_hit )

        local dmg = DamageInfo()
        dmg:SetDamageType(DMG_CRUSH)
        dmg:SetAttacker(ent)
        dmg:SetInflictor(ent:GetCaster())
        dmg:SetDamageForce(velocity) //TODO MIT MARTEN TESTEN OB RAGDOLL BALLERT :)
        dmg:SetDamage(damage)

        touched:TakeDamageInfo(dmg)
    end
end

skill_manager.Register( earth_blast )