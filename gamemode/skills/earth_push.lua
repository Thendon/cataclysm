local earth_push = Skill( "earth_push" )
earth_push:SetMaxLive( 5 )
earth_push:SetCleverCast( true )
earth_push:SetCooldown( 1 )
earth_push:SetDamageType( "earth" )

local end_up = 0.35
local pushPower = 1000
local angleExp = 3
local angleEpsilon = 0.2
earth_push:SetStages({ end_up })

local models = {
    "models/props_wasteland/rockcliff01e.mdl",
    "models/props_wasteland/rockcliff01c.mdl",
    "models/props_wasteland/rockcliff01g.mdl"
}

function earth_push:Stage1( ent )
    local factor = ent.alive / end_up
    local dest = LerpVector( factor, ent:GetPos(), ent:GetNW2Vector("endPos") )
    ent:SetPos( dest )
end

function earth_push:Transition1( ent )
    if SERVER then ent:InitPhys(ELEMENT_PHYS_TYPE.SOLID) end
end

function earth_push:CanBeActivated( caster )
    return caster:OnGround()
end

if CLIENT then
    function earth_push:Activate( ent, caster )
        caster:PlayAnimation("shoot_stone")
        ParticleEffect("element_earth_summon", caster:GetPos(), Angle())
        ParticleEffect("element_earth_burst", ent:GetNW2Vector("endPos") - ent:GetUp() * 50, ent:GetAngles())
        ent:EmitSound("earth_summon")
    end
end

if SERVER then
    function earth_push:Spawn( ent, caster, cleverData )
        ent:SetModel( models[math.random(1, 3)] )
        ent:SetPos( cleverData.pos - cleverData.dir * 100 )
        cleverData.ang:RotateAroundAxis(cleverData.dir, math.random(1, 360))
        ent:SetAngles( cleverData.ang )
        ent:SetNW2Vector( "endPos", cleverData.pos + cleverData.dir * 50 )

        function ent:OnRemove()
            ParticleEffect("element_earth_explode", self:GetPos(), Angle())
        end
        ent.pushDir = cleverData.dir

        ent:InitPhys(ELEMENT_PHYS_TYPE.TRIGGER)
        ent:PhysWake()
    end

    function earth_push:StartTouch( ent, touched )
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

skill_manager.Register( earth_push )