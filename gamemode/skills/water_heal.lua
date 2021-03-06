
local skill = Skill( "water_heal" )
skill:SetDescription("Heal your allies.")
skill:SetMaxLive( 10 )
skill:SetCooldown( 0.5 )
skill:SetCleverCast( true )
skill:SetCleverTarget( Skill.TARGET.PLAYERLOCK )
skill:SetRange( 1000 )
skill:SetCleverFriendly( true )
skill:SetDamageType( "water" )
skill:SetCastUntilRelease( true )
skill:SetRefillFactor( 4 )

local rate = 0.1
local amount = 5

function skill:Stage1( ent )
    local caster = ent:GetCaster()
    ent:SetPos( caster:GetPos() + _VECTOR.UP * 50 + caster:GetForward() * 80 )

    if CLIENT then return end
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("stream_water")

        local effect = ent:CreateParticleEffect("element_water_heal", 1)
        effect:AddControlPoint( 1, ent:GetTarget(), PATTACH_ABSORIGIN_FOLLOW, 0, _VECTOR.UP * 50 )
        ent:EmitSound("water_stream")
    end

    function skill:OnRemove( ent )
        ent:GetCaster():StopAnimation()
        ent:StopSound("water_stream")
    end
end

if SERVER then
    function skill:Spawn( ent, caster, cleverData )
        ent:SetPos( caster:GetPos() + _VECTOR.UP * 50 + caster:GetForward() * 80 )
        ent:SetInvisible( true )
        ent:RemoveOnDeath( { cleverData.target, caster } )
        ent:SetTarget( cleverData.target )
        self:Dot(ent, cleverData.target, 10, -amount, rate)
    end
end

skill_manager.Register( skill )