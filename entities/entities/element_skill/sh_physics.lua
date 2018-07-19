
local ELEMENT_PHYS_TYPE = {}
ELEMENT_PHYS_TYPE.TRIGGER = 1
ELEMENT_PHYS_TYPE.GHOST = 2
ELEMENT_PHYS_TYPE.PROJECTILE = 3
ELEMENT_PHYS_TYPE.SOLID = 4
ELEMENT_PHYS_TYPE.SOLIDMOVING = 5
_G.ELEMENT_PHYS_TYPE = ELEMENT_PHYS_TYPE

local physInits = {}

physInits[ELEMENT_PHYS_TYPE.TRIGGER] = function( ent )
    ent:SetMoveType(MOVETYPE_NONE)
    ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
    ent:SetTrigger(true)
    ent:SetTriggerFlag(true)
end

physInits[ELEMENT_PHYS_TYPE.GHOST] = function( ent )
    ent:SetMoveType(MOVETYPE_NONE)
    ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    ent:SetTrigger(false)
    ent:SetTriggerFlag(false)
end

physInits[ELEMENT_PHYS_TYPE.PROJECTILE] = function( ent )
    ent:SetMoveType(MOVETYPE_VPHYSICS)
    ent:SetCollisionGroup(COLLISION_GROUP_NONE)
    ent:SetTrigger(true)
    ent:SetTriggerFlag(true)
end

physInits[ELEMENT_PHYS_TYPE.SOLID] = function( ent )
    ent:SetMoveType(MOVETYPE_VPHYSICS)
    ent:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
    ent:GetPhysicsObject():EnableMotion( false )
    ent:SetTrigger(false)
    ent:SetTriggerFlag(false)
end

physInits[ELEMENT_PHYS_TYPE.SOLIDMOVING] = function( ent )
    ent:SetMoveType(MOVETYPE_CUSTOM)
    ent:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
    ent:GetPhysicsObject():EnableMotion( false )
    ent:SetTrigger(false)
    ent:SetTriggerFlag(false)
end

return physInits