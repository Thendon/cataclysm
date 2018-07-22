local earth_boost = Skill( "earth_boost")
local end_up = 0.25
earth_boost:SetStages( { end_up } )
earth_boost:SetMaxLive( 1 )
earth_boost:SetCooldown( 1 )

local models = {
    "models/props_wasteland/rockcliff01e.mdl",
    "models/props_wasteland/rockcliff01c.mdl",
    "models/props_wasteland/rockcliff01g.mdl"
}

function earth_boost:Stage1( ent )
    local progress = ent.alive / end_up
    local dest = LerpVector( progress, ent:GetNW2Vector("startPos"), ent:GetNW2Vector("endPos") )
    ent:SetPos( dest )
end

function earth_boost:Stage2( ent )
    local progress = (ent.alive - end_up) / end_up
    progress = math.Clamp(progress, 0, 1)
    local dest = LerpVector( progress, ent:GetNW2Vector("endPos"), ent:GetNW2Vector("startPos") )
    ent:SetPos( dest )
end

function earth_boost:CanBeActivated( caster )
    return caster:OnGround()
end

if CLIENT then
    function earth_boost:Activate( ent, caster )
        caster:PlayAnimation("shoot_stone")
        ParticleEffect("element_earth_burst", caster:GetPos(), Angle())
        ent:EmitSound("earth_summon")
    end
end

if SERVER then
    function earth_boost:Spawn( ent, caster )
        local pos = caster:GetPos() - _VECTOR.UP * 150
        ent:SetModel( models[math.random(1, 3)] )
        ent:SetPos( pos )
        ent:SetAngles( caster:GetAngles() )
        ent:SetNW2Vector( "startPos", pos )
        ent:SetNW2Vector( "endPos", caster:GetPos() + _VECTOR.UP * 50 )
        function ent:OnRemove()
            ParticleEffect("element_earth_explode", self:GetPos(), Angle())
        end
        --ent:InitPhys(ELEMENT_PHYS_TYPE.GHOST)
        --ent:PhysWake()

        local dir = caster:GetVelocity():GetNormalized()
        local dot = caster:GetAimVector():Dot(_VECTOR.UP)
        dir.z = math.Clamp(dot, 0.5, 1)
        caster:SetVelocity( dir * 750 )
        caster:SetFallDamper(30, 0.5, 2)
        --caster:SetFallImmune( 30 )
    end
end

skill_manager.Register( earth_boost )