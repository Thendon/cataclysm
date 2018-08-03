
_G.Skill = Skill or Class()
Skill.TARGET = {}
Skill.TARGET.WORLD = 1
Skill.TARGET.PLAYER = 2
Skill.TARGET.PLAYERLOCK = 3

AccessorFunc( Skill, "description", "Description", FORCE_STRING )
AccessorFunc( Skill, "maxlive", "MaxLive", FORCE_NUMBER )
AccessorFunc( Skill, "cast", "CastTime", FORCE_NUMBER ) --TODO unused but good idea
AccessorFunc( Skill, "range", "Range", FORCE_NUMBER )
AccessorFunc( Skill, "rangeSqr", "RangeSqr", FORCE_NUMBER )
AccessorFunc( Skill, "lockrange", "Lockrange", FORCE_NUMBER )
AccessorFunc( Skill, "cooldown", "Cooldown", FORCE_NUMBER )
AccessorFunc( Skill, "cleverCast", "CleverCast", FORCE_BOOL )
AccessorFunc( Skill, "cleverFriendly", "CleverFriendly", FORCE_BOOL )
AccessorFunc( Skill, "cleverTarget", "CleverTarget", FORCE_NUMBER )
AccessorFunc( Skill, "castOnRelease", "CastOnRelease", FORCE_BOOL )
AccessorFunc( Skill, "castUntilRelease", "CastUntilRelease", FORCE_BOOL )
AccessorFunc( Skill, "name", "Name", FORCE_STRING )
AccessorFunc( Skill, "damageType", "DamageType", FORCE_STRING )
AccessorFunc( Skill, "stages", "Stages" )

function Skill:_init( name )
    self.name = name
    self.description = ""
    self.cooldown = 0
    self.stages = {}
    self.cast = 0
    self.maxlive = 60
    self.range = 0
    self.rangeSqr = 0
    self.damageType = "default"
    self.cleverCast = false
    self.cleverTarget = Skill.TARGET.WORLD
    self.cleverFriendly = false
    self.castOnRelease = false
    self.castUntilRelease = false
    self.icon = Material("element/skills/" .. name .. ".png", "noclamp")
end

function Skill:CanBeActivated( caster, pressing, cleverData )
    if !self:ActivationConditions( caster, pressing, cleverData ) then return false end
    if self:GetCastUntilRelease() then return caster:GetCasting( self ) != pressing end
    if self:GetCastOnRelease() then return !pressing end
    return pressing
end

function Skill:ActivationConditions( caster, pressing, cleverData )
    return true
end

function Skill:SetCleverCast()
    self:SetCastOnRelease( true )
    self.cleverCast = true
end

function Skill:SetRange( range )
    self:SetRangeSqr( range * range )
    self.range = range
end