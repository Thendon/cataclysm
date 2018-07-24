
local skill = Skill( "water_drown" )

local drownTime = 5
local start = 1
local rate = 0.5
local damage = 5

local stage2 = start + drownTime * 0.5
local stage3 = start + drownTime
skill:SetCleverCast( true )
skill:SetCleverTarget( Skill.TARGET.PLAYERLOCK )
skill:SetMaxLive( start + drownTime * 2 )
skill:SetCooldown( 0.5 )
skill:SetRange( 500 )
skill:SetDamageType( "water" )
skill:SetStages({ start, stage2, stage3 })

function skill:Stage1( ent )
    if CLIENT then return end

    local fraction = ent.alive / start
    fraction = math.Clamp(fraction, 0, 1)
    local victim = ent:GetTarget()

    local pos = LerpVector(fraction, ent:GetNW2Vector("startPos"), ent:GetNW2Vector("endPos"))
    victim:SetPos( pos )
end

function skill:Transition1( ent )
    if CLIENT then return end

    self:Dot(ent, ent:GetTarget(), drownTime, damage, rate)
end

function skill:Stage2( ent )
    if CLIENT then return end

    ent:GetTarget():SetPos( ent:GetNW2Vector("endPos") )
end

function skill:Stage3( ent )
    if CLIENT then return end

    local fraction = (ent.alive - stage2) / (drownTime * 0.5)
    fraction = math.Clamp(fraction, 0, 1)

    local pos = LerpVector(fraction, ent:GetNW2Vector("endPos"), ent:GetNW2Vector("startPos"))
    ent:GetTarget():SetPos( pos )
end

function skill:Transition3( ent )
    if CLIENT then
        --ent:StopSound("water_waves") --FADE HERE
        return
    end

    ent:GetTarget():SetMoveType(MOVETYPE_WALK)
end

if CLIENT then
    function skill:Activate( ent, caster )
        caster:PlayAnimation("shoot_fire" .. math.random(1,2))
        ent:CreateParticleEffect("element_water_drown", 1)
        ent:EmitSound("water_waves")
    end

    function skill:OnRemove( ent )
        ent:StopSound("water_waves")
        --ent:StopAndDestroyParticles()
    end
end

if SERVER then
    function skill:Spawn( ent, caster, cleverData )
        ent:SetInvisible( true )
        ent:SetPos( cleverData.target:GetPos() + _VECTOR.UP * 50 )
        ent:SetParent( cleverData.target, 0 )
        local pos = cleverData.target:GetPos()
        --ent:SetNW2Entity("target", cleverData.target)
        ent:SetTarget(cleverData.target)
        ent:SetNW2Vector("startPos", pos)
        ent:SetNW2Vector("endPos", pos + _VECTOR.UP * 100)
        ent:RemoveOnDeath( cleverData.target )

        cleverData.target:SetMoveType(MOVETYPE_FLY)
        cleverData.target:Silence( drownTime )
        --cleverDate.target:Root( drownTime )
    end
end

skill_manager.Register( skill )