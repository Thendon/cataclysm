
local skill = Skill( "water_shield" )

local uptime = 5

skill:SetMaxLive( uptime )
skill:SetCooldown( 0.5 )

local size = 1.5

function skill:Stage1( ent )
    local caster = ent:GetCaster()
    local forward = caster:GetForward()
    forward.z = 0
    forward:Normalize()

    local ang = forward:Angle()
    ang:RotateAroundAxis(ang:Right(), -90)

    ent:SetPos( caster:GetPos() + forward * 30 + _VECTOR.UP * 50)
    ent:SetAngles( ang )

    if CLIENT then return end
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("shoot_fire" .. math.random(1,2))
        ent:CreateParticleEffect("element_water_shield", 1)
        ent:EmitSound("water_stream2")
    end

    function skill:OnRemove( ent )
        ent:StopSound("water_stream2")
    end
end

if SERVER then
    function skill:Spawn( ent, caster )
        ent:SetModel("models/props_phx/construct/plastic/plastic_angle_360.mdl")
        ent:SetModelScale(size)
        ent:SetInvisible( true )
    end
end

skill_manager.Register( skill )