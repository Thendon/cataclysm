include("sh_skill.lua")

function Skill:Activate( caster, cleverData )
    --if (self.cast > 0) then caster:SetCasting( self.cast ) end --SETCASTING USED TWICE TODO
    local ent = self:CreateEntity( caster, cleverData )
    if (self:GetCastUntilRelease()) then caster:SetCasting( self, true, ent ) end
    caster:ApplyCooldown( self, self:GetCooldown() )
end

function Skill:Deactivate( ent )
    if (!IsValid(ent)) then return end
    --todo maybe call hook
    ent:Remove()
    ent:GetCaster():ApplyCooldown( self, self:GetCooldown() )
end

function Skill:CreateEntity( caster, cleverData )
    local skillEnt = ents.Create("element_skill")
    skillEnt:SetSkill( self )
    skillEnt:SetCaster( caster )
    skillEnt:SetMaxLive( self.maxlive )
    skillEnt:SetName(self.name)
    self:Spawn( skillEnt, caster, cleverData )
    skillEnt:Spawn()

    skill_manager.NewInstance( skillEnt )

    return skillEnt
end

function Skill:CreateChildEntity( ent, offset, angle )
    offset = offset or _VECTOR.ZERO
    local skillChild = ents.Create("element_skillChild")
    skillChild:SetName( self.name )
    skillChild:SetPos( ent:GetPos() + offset )
    if angle then skillChild:SetAngles(angle) end
    skillChild:SetParent( ent, 0 )
    skillChild:Spawn()

    return skillChild
end

function Skill:Spawn( ent, caster )
end

function Skill:GenerateDamageInfo(ent, damage, type, velocity)
    type = type or DMG_GENERIC

    local dmg = DamageInfo()
    dmg:SetDamageType(type)
    dmg:SetInflictor(ent)
    dmg:SetAttacker(ent:GetCaster())
    if velocity then dmg:SetDamageForce(velocity) end
    dmg:SetDamage(damage)

    return dmg
end

function Skill:Hit( ent, victim, damage, type, velocity )
    if !victim:IsPlayer() then return end

    damage = damage or 0
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
    dot.nextHit = dot.start-- + dot.rate
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