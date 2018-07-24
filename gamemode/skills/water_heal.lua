
local skill = Skill( "water_heal" )
skill:SetMaxLive( 10 )
skill:SetCooldown( 1 )
skill:SetCleverCast( true )
skill:SetCleverTarget( Skill.TARGET.PLAYERLOCK )
skill:SetRange( 1000 )
skill:SetDamageType( "water" )

local rate = 0.5
local amount = 5

function skill:Stage1( ent )
    local caster = ent:GetCaster()
    ent:SetPos( caster:GetPos() + _VECTOR.UP * 50 + caster:GetForward() * 80 )

    if CLIENT then return end
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("shoot_fire" .. math.random(1,2))

        local effect = ent:CreateParticleEffect("element_water_heal", 1)
        --local effect = CreateParticleSystem( ent, "element_water_attack", PATTACH_ABSORIGIN )
        --effect:SetControlPoint(1, ent:GetTarget():GetPos() + _VECTOR.UP * 50)
        --effect:SetControlPointEntity(1, ent:GetTarget())
        effect:AddControlPoint( 1, ent:GetTarget(), PATTACH_ABSORIGIN_FOLLOW, 0, _VECTOR.UP * 50 )
        ent:EmitSound("water_stream")
    end

    function skill:OnRemove( ent )
        ent:StopSound("water_stream")
    end
end

if SERVER then
    function skill:Spawn( ent, caster, cleverData )
        ent:SetInvisible( true )
        ent:RemoveOnDeath( { cleverData.target, caster } )
        ent:SetTarget( cleverData.target )
        self:Dot(ent, cleverData.target, 10, -amount, rate)
    end
end

skill_manager.Register( skill )