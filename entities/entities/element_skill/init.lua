include("shared.lua")
local physInits = include("sh_physics.lua")

AccessorFunc( ENT, "destroy", "DestroyFlag", FORCE_BOOL )
AccessorFunc( ENT, "trigger", "TriggerFlag", FORCE_BOOL )
AccessorFunc( ENT, "casterCollision", "CasterCollision", FORCE_BOOL )
AccessorFunc( ENT, "removeOnWorldTrace", "RemoveOnWorldTrace", FORCE_BOOL )
AccessorFunc( ENT, "removeOnDeath", "RemoveOnDeath", FORCE_BOOL )
AccessorFunc( ENT, "touchPlayerOnce", "TouchPlayerOnce", FORCE_BOOL )
AccessorFunc( ENT, "touchCaster", "TouchCaster", FORCE_BOOL )
AccessorFunc( ENT, "touchAllEnts", "TouchAllEnts", FORCE_BOOL )
AccessorFunc( ENT, "touchRate", "TouchRate", FORCE_NUMBER )

function ENT:Initialize()
    self:DrawShadow( false )
    self:SetBirth( CurTime() )
    self.loaded = true

    self.touchCooldown = {}
    self.casterCollision = self.casterCollision or false
    self.removeOnWorldTrace = self.removeOnWorldTrace or false
    self.removeOnDeath = self.removeOnDeath or false
    self.touchPlayerOnce = self.touchPlayerOnce or false
    self.touchCaster = self.touchCaster or false
    self.touchAllEnts = self.touchAllEnts or false
    self.touchRate = self.touchRate or 1
    self.touchedPlayers = {}
end

local function shouldTouchContinue( ent, touched )
    if (!ent:GetTriggerFlag()) then return false end

    if (touched:IsPlayer()) then
        if (ent:GetTouchCaster() and ent:GetCaster() == touched) then
            return false
        end

        if (ent:GetTouchPlayerOnce()) then
            if (ent.touchedPlayers[touched]) then return false end
            ent.touchedPlayers[touched] = true
        end
    end

    local now = CurTime()
    ent.touchCooldown[touched] = ent.touchCooldown[touched] or 0
    if (ent.touchCooldown[touched] > now ) then return false end
    ent.touchCooldown[touched] = now + ent.touchRate

    return true
end

function ENT:StartTouch( ent )
    if (!self:GetTriggerFlag()) then return end
    local skill = self:GetSkill()
    if (!skill.StartTouch) then return end
    if (!shouldTouchContinue(self, ent)) then return end
    ecall( skill.StartTouch, skill, self, ent )
end

function ENT:Touch(ent)
    if (!self:GetTriggerFlag()) then return end
    local skill = self:GetSkill()
    if (!skill.Touch) then return end
    if (!shouldTouchContinue(self, ent)) then return end
    ecall( skill.Touch, skill, self, ent )
end


function ENT:PhysicsCollide( data, phys )
    local skill = self:GetSkill()
    ecall( skill.PhysicsCollide, skill, self, data, phys )
end

function ENT:InitPhys(type)
    if (!IsValid(self:GetPhysicsObject())) then
        self:PhysicsInit(SOLID_VPHYSICS)
    end

    physInits[type]( self )
    self:SetTrigger(type == ELEMENT_PHYS_TYPE.TRIGGER)
end

--SetCustomCollisionCheck must be set true
function ENT:ShouldCollide( ent )
    --print(self, ent, !self.casterCollision and ent == self:GetCaster() )
    if !self.casterCollision and ent == self:GetCaster() then return false end
    return true
end

--[[ tried with constraint, didnt work :(
function ENT:NoCollideWithCaster()
    local caster = self:GetCaster()
    for k = 1, caster:GetBoneCount() do
        constraint.NoCollide(self, caster, 0, k)
    end
end
]]

function ENT:CheckWorldTrace()
    local tr = util.TraceLine({
        start = self:GetPos(),
        endpos = self:GetForward() * 50,
        filter = function( hit )
            if (hit == self or hit:IsPlayer()) then
                return
            end
            return true
        end
    })

    if (tr.StartSolid) then self:Remove() end
end