include("sh_skill.lua")

function Skill:Activate( caster, cleverData )
    --if (!self:CanBeActivated( caster )) then return false end
    local skillEnt = ents.Create("element_skill")
    skillEnt:SetSkill( self )
    skillEnt:SetCaster( caster )
    skillEnt:SetMaxLive( self.maxlive )
    skillEnt:SetName(self.name)
    self:Spawn( skillEnt, caster, cleverData )
    skillEnt:Spawn()

    skill_manager.NewInstance( skillEnt )

    if (self.cast > 0) then caster:SetCasting( self.cast ) end
end

function Skill:Spawn( ent, caster )
end

function Skill:GenerateDamageInfo(ent, damage, type, velocity)
    type = type or DMG_GENERIC

    local dmg = DamageInfo()
    dmg:SetDamageType(type)
    dmg:SetAttacker(ent)
    dmg:SetInflictor(ent:GetCaster())
    if velocity then dmg:SetDamageForce(velocity) end
    dmg:SetDamage(damage)

    return dmg
end

function Skill:Hit( ent, victim, damage, type, velocity )
    local dmgType = skill_manager.GetDamageType(self:GetDamageType())

    if (damage < 0 ) then
        victim:Heal( -damage, dmgType )
        return
    end

    local dmg = self:GenerateDamageInfo( ent, damage, type, velocity )
    victim:TakeSkillDamage( dmg, dmgType )
end

function Skill:Dot( ent, victim, time, damage, rate, start )
    local dot = {}
    dot.rate = rate or 1
    dot.start = start or CurTime()
    dot.stop = dot.start + time
    dot.nextHit = dot.start + dot.rate
    dot.damage = damage

    ent.dots[victim] = dot
end

function Skill:HandleDots( ent )
    local now = CurTime()
    for ply, dot in next, ent.dots do
        if (now > dot.stop) then
            if (dot.stop >= dot.nextHit) then
                self:ApplyDotDamage(ent, ply, dot)
            end
            ent.dots[ply] = nil
            continue
        end

        if (now > dot.nextHit) then
            self:ApplyDotDamage(ent, ply, dot)
        end
    end
end

function Skill:ApplyDotDamage(ent, victim, dot)
    local now = CurTime()
    while (now > dot.nextHit) do
        self:Hit( ent, victim, dot.damage, DMG_GENERIC )
        dot.nextHit = dot.nextHit + dot.rate
    end
end