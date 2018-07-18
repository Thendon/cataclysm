
_G.Skill = Skill or Class()
Skill.TARGET = {}
Skill.TARGET.WORLD = 1
Skill.TARGET.PLAYER = 2
Skill.TARGET.PLAYERLOCK = 3

AccessorFunc( Skill, "maxlive", "MaxLive", FORCE_NUMBER )
AccessorFunc( Skill, "cast", "CastTime", FORCE_NUMBER )
AccessorFunc( Skill, "range", "Range", FORCE_NUMBER )
AccessorFunc( Skill, "lockrange", "Lockrange", FORCE_NUMBER )
AccessorFunc( Skill, "cooldown", "Cooldown", FORCE_NUMBER )
AccessorFunc( Skill, "cleverCast", "CleverCast", FORCE_BOOL )
AccessorFunc( Skill, "cleverTarget", "CleverTarget", FORCE_NUMBER )
AccessorFunc( Skill, "name", "Name", FORCE_STRING )
AccessorFunc( Skill, "damageType", "DamageType", FORCE_STRING )
AccessorFunc( Skill, "stages", "Stages" )

function Skill:_init( name )
    self.name = name
    self.cooldown = 0
    self.stages = {}
    self.cast = 0
    self.maxlive = 60
    self.range = 0
    self.damageType = "default"
    self.cleverTarget = Skill.TARGET.WORLD
    self.icon = Material("element/skills/" .. name .. ".png")
end

function Skill:CanBeActivated( caster )
    return true
end

if SERVER then
    function Skill:Activate( caster, cleverData )
        --if (!self:CanBeActivated( caster )) then return false end
        local skillEnt = ents.Create("element_skill")
        skillEnt:SetSkill( self )
        skillEnt:SetCaster( caster )
        self:Spawn( skillEnt, caster, cleverData )
        skillEnt:SetMaxLive( self.maxlive )
        skillEnt:SetName(self.name)
        skillEnt:Spawn()

        if (self.cast > 0) then caster:SetCasting( self.cast ) end
    end

    function Skill:Spawn( ent, caster )
    end

    function Skill:Hit( ent, caster, victim, damage, type, velocity )
        type = type or DMG_GENERIC

        local dmg = DamageInfo()
        dmg:SetDamageType(type)
        dmg:SetAttacker(ent)
        dmg:SetInflictor(caster)
        dmg:SetDamageForce(velocity)
        dmg:SetDamage(damage)

        victim:TakeDamageInfo(dmg)

        local dmgType = skill_manager.GetDamageType(self:GetDamageType())
        dmgType:Hit( victim )
    end
end

if CLIENT then
    function Skill:Activate( ply )
    end

    function Skill:CleverCast( pressing )
        if (!self:GetCleverCast()) then return true end

        local trace = LocalPlayer():GetEyeTrace()

        ecall(self.Stage0, self, trace)

        if (self:GetCleverTarget() == Skill.TARGET.PLAYER) then
            return skill_manager.CleverCastPlayer( pressing, trace )
        elseif (self:GetCleverTarget() == Skill.TARGET.PLAYERLOCK) then
            return skill_manager.CleverLockPlayer( pressing, trace, self:GetRange(), self:GetLockrange() )
        end
        return skill_manager.CleverCastWorld( pressing, trace )
    end
end