local skill = Skill( "earth_boost")
skill:SetDescription("Boost yourself into the skies. (Boosts in your walk direction)")
local end_up = 0.25
skill:SetStages( { end_up } )
skill:SetMaxLive( 1 )
skill:SetCooldown( 5 )

local models = {
    "models/props_wasteland/rockcliff01e.mdl",
    "models/props_wasteland/rockcliff01c.mdl",
    "models/props_wasteland/rockcliff01g.mdl"
}

function skill:Stage1( ent )
    local progress = ent.alive / end_up
    local dest = LerpVector( progress, ent:GetNW2Vector("startPos"), ent:GetNW2Vector("endPos") )
    ent:SetPos( dest )
end

function skill:Stage2( ent )
    local progress = (ent.alive - end_up) / end_up
    progress = math.Clamp(progress, 0, 1)
    local dest = LerpVector( progress, ent:GetNW2Vector("endPos"), ent:GetNW2Vector("startPos") )
    ent:SetPos( dest )
end

function skill:ActivationConditions( caster )
    return caster:OnGround()
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("fly2")
        ParticleEffect("element_earth_burst", caster:GetPos(), Angle())
        ent:EmitSound("earth_summon")
    end

    function skill:OnRemove( ent )
        ent:GetCaster():StopAnimation()
    end
end

if SERVER then
    function skill:Spawn( ent, caster )
        local pos = caster:GetPos() - _VECTOR.UP * 150
        ent:SetModel( models[math.random(1, 3)] )
        ent:SetPos( pos )
        ent:SetAngles( caster:GetAngles() )
        ent:SetNW2Vector( "startPos", pos )
        ent:SetNW2Vector( "endPos", caster:GetPos() + _VECTOR.UP * 50 )
        function ent:OnRemove()
            ParticleEffect("element_earth_explode", self:GetPos(), Angle())
        end

        local dir = caster:GetMoveVector() --caster:GetVelocity():GetNormalized()
        local dot = caster:GetAimVector():Dot(_VECTOR.UP)
        dir.z = math.Clamp(dot, 0.5, 1)
        caster:SetVelocity( dir * 750 )
        caster:SetFallDamper(30, 0.5, 2)
    end
end

skill_manager.Register( skill )