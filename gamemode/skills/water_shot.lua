
local skill = Skill( "water_shot" )
skill:SetMaxLive( 5 )
skill:SetCooldown( 1 )
skill:SetCleverCast( true )
skill:SetCleverTarget( Skill.TARGET.PLAYERLOCK )
skill:SetCastOnRelease( false )

local damage = 10
local range = 1000
skill:SetRange( range )
skill:SetDamageType( "water" )

function skill:Stage1( ent )
    local caster = ent:GetCaster()
    ent:SetPos( caster:GetPos() + _VECTOR.UP * 50 + caster:GetForward() * 80 )

    if CLIENT then return end
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("shoot_fire" .. math.random(1,2))

        local effect = ent:CreateParticleEffect("element_water_attack", 1)
        effect:AddControlPoint( 1, ent:GetTarget(), PATTACH_ABSORIGIN_FOLLOW, 0, _VECTOR.UP * 50 )
        ent:EmitSound("water_shot4")
    end

    function skill:OnRemove( ent )
        --ent:StopAndDestroyParticles()
    end
end

if SERVER then
    function skill:Spawn( ent, caster, cleverData )
        ent:SetInvisible( true )
        ent:RemoveOnDeath( cleverData.target )
        ent:SetTarget( cleverData.target )

        local livetime = (cleverData.target:GetPos() - caster:GetPos()):Length()
        livetime = 0.5 + livetime * ( 1 / range )
        ent:SetMaxLive( livetime )
    end

    function skill:OnRemove( ent )
        self:Hit(ent, ent:GetTarget(), damage)
    end
end

skill_manager.Register( skill )