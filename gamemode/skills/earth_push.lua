local skill = Skill( "earth_push" )
skill:SetDescription("Raise a pillar on the position you are looking at.")
skill:SetMaxLive( 5 )
skill:SetCleverCast( true )
skill:SetCooldown( 1 )
skill:SetDamageType( "earth" )
skill:SetRange( 2000 )

local end_up = 0.35
local pushPower = 1000
local angleExp = 3
local angleEpsilon = 0.2
skill:SetStages({ end_up })

local models = {
    "models/props_wasteland/rockcliff01e.mdl",
    "models/props_wasteland/rockcliff01c.mdl",
    "models/props_wasteland/rockcliff01g.mdl"
}

function skill:Stage1( ent )
    local factor = ent.alive / end_up
    local dest = LerpVector( factor, ent:GetPos(), ent:GetNW2Vector("endPos") )
    ent:SetPos( dest )
end

function skill:Transition1( ent )
    if SERVER then ent:InitPhys(ELEMENT_PHYS_TYPE.SOLID) end
end

function skill:ActivationConditions( caster )
    return caster:OnGround()
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("shoot_stone2")
        ParticleEffect("element_earth_summon", caster:GetPos(), Angle())
        ParticleEffect("element_earth_burst", ent:GetNW2Vector("endPos") - ent:GetUp() * 50, ent:GetAngles())
        ent:EmitSound("earth_summon")
    end

    function skill:OnRemove( ent )
        ParticleEffect("element_earth_explode", ent:GetPos(), Angle())
        sound.Play("earth_hit3", ent:GetPos())
    end
end

if SERVER then
    function skill:Spawn( ent, caster, cleverData )
        ent:SetModel( models[math.random(1, 3)] )
        ent:SetPos( cleverData.pos - cleverData.dir * 100 )
        cleverData.ang:RotateAroundAxis(cleverData.dir, math.random(1, 360))
        ent:SetAngles( cleverData.ang )
        ent:SetTouchCaster( true )
        ent:SetTouchRate( 0.15 )
        ent:SetNW2Vector( "endPos", cleverData.pos + cleverData.dir * 50 )
        ent.pushDir = cleverData.dir

        ent:InitPhys(ELEMENT_PHYS_TYPE.TRIGGER)
        ent:PhysWake()
    end

    function skill:Touch( ent, touched )
        local angleFactor = math.abs( ent.pushDir:Dot( _VECTOR.UP ) )
        if (angleFactor < angleEpsilon) then
            angleFactor = angleFactor * ( 1 / angleEpsilon )
            angleFactor = 2 - angleFactor
            angleFactor = math.pow(angleFactor, angleExp)
        else
            angleFactor = 1
        end

        if ( touched:IsPlayer() ) then
            touched:SetVelocity( ent.pushDir * pushPower * angleFactor )
            --touched:PhysHit(ent.pushDir * pushPower * angleFactor)
            touched:UpdateLastPhysHit()
        else
            local phys = touched:GetPhysicsObject()
            phys:AddVelocity( ent.pushDir * pushPower )
        end
    end
end

skill_manager.Register( skill )