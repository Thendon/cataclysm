
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