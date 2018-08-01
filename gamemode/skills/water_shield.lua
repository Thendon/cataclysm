
local skill = Skill( "water_shield" )

local uptime = 5

skill:SetMaxLive( uptime )
skill:SetCooldown( 0.5 )
skill:SetStages( {uptime - 1} )

local size = 1.5

local function posEnt( ent )
    local caster = ent:GetCaster()

    if CLIENT and caster != LocalPlayer() then return end

    local forward = caster:GetForward()
    forward.z = 0
    forward:Normalize()

    local ang = forward:Angle()

    ent:SetPos( caster:GetPos() + forward * 20 + _VECTOR.UP * 50)
    ent:SetAngles( ang )
end

function skill:Stage1( ent )
    posEnt( ent )
end

function skill:Transition1( ent )
    if SERVER then return end
    ent.bgl:FadeOut(1)
end

function skill:Stage2( ent )
    posEnt( ent )
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("shoot_fire" .. math.random(1,2))

        local forward = caster:GetForward()
        forward.z = 0
        forward:Normalize()
        local ang = forward:Angle()
        ang:RotateAroundAxis(ang:Up(), -90)

        ent:CreateParticleEffect("element_water_shield", 1)
        --ent:EmitSound("water_stream2")
        ent.bgl = PlayBGL( caster, "water_stream2" )
        ent.bgl:ChangeVolume(1, 1)
    end

    function skill:OnRemove( ent )
    end
end

if SERVER then
    function skill:Spawn( ent, caster )
        posEnt( ent )
        local child = self:CreateChildEntity( ent, Vector(30,0,0), Angle(90,0,0))
        child:SetModel("models/props_phx/construct/plastic/plastic_angle_360.mdl")
        child:SetModelScale(size)
        child:SetInvisible( true )
        ent:SetInvisible( true )
        ent:RemoveOnDeath()
        caster:SetSkillImmune(uptime)
    end
end

skill_manager.Register( skill )