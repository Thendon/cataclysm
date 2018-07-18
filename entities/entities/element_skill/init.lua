include("shared.lua")
local physInits = include("sh_physics.lua")

local touchCooldown = 0.5

AccessorFunc( ENT, "destroy", "DestroyFlag", FORCE_BOOL )
AccessorFunc( ENT, "trigger", "TriggerFlag", FORCE_BOOL )
AccessorFunc( ENT, "casterCollision", "CasterCollision", FORCE_BOOL )
AccessorFunc( ENT, "removeOnWorldTrace", "RemoveOnWorldTrace", FORCE_BOOL )

function ENT:Initialize()
    self:DrawShadow( false )
    self:SetBirth( CurTime() )
    self.loaded = true
    self.touchCooldown = {}
    self.casterCollision = false
    self.RemoveOnWorldTrace = false
end

function ENT:StartTouch( ent )
    if (!self:GetTriggerFlag()) then return end

    local now = CurTime()
    self.touchCooldown[ent] = self.touchCooldown[ent] or 0
    if (self.touchCooldown[ent] > now ) then return end
    self.touchCooldown[ent] = now + touchCooldown

    local skill = self:GetSkill()
    ecall( skill.StartTouch, skill, self, ent )
end

function ENT:PhysicsCollide( data, phys )
    local skill = self:GetSkill()
    ecall( skill.PhysicsCollide, skill, self, data, phys )
end

function ENT:Touch(entity)
    --print(entity)
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