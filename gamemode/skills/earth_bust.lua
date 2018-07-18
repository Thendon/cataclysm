local earth_bust = Skill( "earth_bust" )
earth_bust:SetCleverCast( true )
earth_bust:SetCleverTarget( Skill.TARGET.PLAYERLOCK )
earth_bust:SetMaxLive( 1.75 )
earth_bust:SetRange(1000)
earth_bust:SetCooldown( 1 )
earth_bust:SetDamageType( "earth" )

local silenceTime = 2

function earth_bust:CanBeActivated( caster )
    return caster:OnGround()
end

if CLIENT then
    function earth_bust:Activate( ent, caster )
        caster:PlayAnimation("shoot_stone")
        ent:GetNW2Entity("target"):PlayAnimation("handcuffed")
        ent:CreateParticleEffect("element_earth_hit", 1)
        ParticleEffect("element_earth_summon", caster:GetPos(), Angle())
        ent:EmitSound("earth_gather")
    end
end

if SERVER then
    function earth_bust:Spawn( ent, caster, cleverData )
        ent:SetModel( "models/props/cs_militia/militiarock05.mdl" )
        ent:SetModelScale(0.3)

        local attachmentID = cleverData.target:LookupAttachment( "anim_attachment_LH" )
        local attachment = cleverData.target:GetAttachment( attachmentID )
        ent:SetPos( attachment.Pos - attachment.Ang:Up() * 9 + attachment.Ang:Right() * 5 + attachment.Ang:Forward() * 2)
        ent:SetAngles( attachment.Ang )
        ent:SetParent( cleverData.target, attachmentID )
        ent:SetMoveType( MOVETYPE_NONE )
        ent:SetNW2Entity("target", cleverData.target)
        function ent:OnRemove()
            ParticleEffect("element_earth_hit_fast", self:GetPos(), Angle())
            sound.Play("earth_hit", self:GetPos())
        end

        cleverData.target:Silence( silenceTime )
    end
end

skill_manager.Register( earth_bust )