local skill = Skill( "water_shield" )
skill:SetDescription("Protect you and your allies with a mobile shield of water.")

local uptime = 6

skill:SetMaxLive( uptime )
skill:SetCooldown( 0.5 )
skill:SetStages( {uptime - 1} )

local size = 1.5

local function posEnt( ent )
    local caster = ent:GetCaster()

    if CLIENT and caster != LocalPlayer() then
        --ent:SetRenderAngles(ent:GetAngles() + Angle(0,90,0))
        return
    end

    local forward = caster:GetForward()
    forward.z = 0
    forward:Normalize()

    local ang = forward:Angle() + Angle(90,0,0)

    ent:SetPos( caster:GetPos() + forward * 40 + _VECTOR.UP * 50)
    ent:SetAngles( ang )
end

function skill:Stage1( ent )
    posEnt( ent )
end

function skill:Transition1( ent )
    if SERVER then return end
    --ent.bgl:FadeOut(1)
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

        PlayBGL( ent, "water_stream2", 1 )

        local child = ent:GetNW2Entity("particleChild")
        if !IsValid(ent) then print("not valid") return end
        child:CreateParticleEffect("element_water_shield", 1)
    end

    function skill:OnRemove( ent )
    end
end

if SERVER then
    function skill:Spawn( ent, caster )
        ent:SetModel("models/props_phx/construct/plastic/plastic_angle_360.mdl")
        ent:SetModelScale(size)
        ent:SetInvisible( true )
        ent:RemoveOnDeath()
        ent:InitPhys(ELEMENT_PHYS_TYPE.SOLIDMOVING)

        local child = self:CreateChildEntity( ent, Vector(0,0,-30), Angle(-90,0,0))
        ent:SetNW2Entity("particleChild", child)
        child:SetInvisible( true )
        posEnt( ent )

        caster:SetSkillImmune(uptime)
    end
end

skill_manager.Register( skill )