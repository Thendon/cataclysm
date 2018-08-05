local skill = Skill( "earth_bust" )
skill:SetDescription("Silence your opponents and take them the ability to cast.")
skill:SetCleverCast( true )
skill:SetCleverTarget( Skill.TARGET.PLAYERLOCK )
skill:SetMaxLive( 3 )
skill:SetRange(1000)
skill:SetCooldown( 9 )
skill:SetDamageType( "earth" )

local silenceTime = 2

function skill:ActivationConditions( caster )
    return caster:OnGround()
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("summon_earth")
        ent:GetTarget():PlayAnimation("handcuffed")
        ent:CreateParticleEffect("element_earth_gather", 1)
        ParticleEffect("element_earth_summon", caster:GetPos(), Angle())
        ent:EmitSound("earth_gather")
        if !IsMounted("cstrike") then ent:SetClientModel("models/props_wasteland/rockgranite03b.mdl") end
    end

    function skill:OnRemove( ent )
        ParticleEffect("element_earth_hit_fast", ent:GetPos(), Angle())
        sound.Play("earth_hit", ent:GetPos())
    end
end

if SERVER then
    function skill:Spawn( ent, caster, cleverData )
        ent:SetModel( "models/props/cs_militia/militiarock05.mdl" )
        ent:SetModelScale(0.3)

        local attachmentID = cleverData.target:LookupAttachment( "anim_attachment_LH" )
        local attachment = cleverData.target:GetAttachment( attachmentID )
        ent:SetPos( attachment.Pos - attachment.Ang:Up() * 9 + attachment.Ang:Right() * 5 + attachment.Ang:Forward() * 2)
        ent:SetAngles( attachment.Ang )
        ent:SetParent( cleverData.target, attachmentID )
        ent:SetTarget(cleverData.target)
        ent:RemoveOnDeath(cleverData.target)

        self:Hit( ent, cleverData.target )

        cleverData.target:Silence( silenceTime )
    end
end

skill_manager.Register( skill )