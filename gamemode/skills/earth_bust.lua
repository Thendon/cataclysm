local skill = Skill( "earth_bust" )
skill:SetCleverCast( true )
skill:SetCleverTarget( Skill.TARGET.PLAYERLOCK )
skill:SetMaxLive( 1.75 )
skill:SetRange(1000)
skill:SetCooldown( 1 )
skill:SetDamageType( "earth" )

local silenceTime = 2

function skill:CanBeActivated( caster )
    return caster:OnGround()
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("shoot_stone")
        ent:GetTarget():PlayAnimation("handcuffed")
        ent:CreateParticleEffect("element_earth_hit", 1)
        ParticleEffect("element_earth_summon", caster:GetPos(), Angle())
        ent:EmitSound("earth_gather")
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
        --ent:SetMoveType( MOVETYPE_NONE )
        ent:SetTarget(cleverData.target)
        ent:RemoveOnDeath(cleverData.target)

        cleverData.target:Silence( silenceTime )
    end
end

skill_manager.Register( skill )