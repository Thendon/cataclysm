include("shared.lua")
local physInits = include("sh_physics.lua")

AccessorFunc( ENT, "destroy", "DestroyFlag", FORCE_BOOL )
AccessorFunc( ENT, "trigger", "TriggerFlag", FORCE_BOOL )
AccessorFunc( ENT, "casterCollision", "CasterCollision", FORCE_BOOL )
AccessorFunc( ENT, "removeOnWorldTrace", "RemoveOnWorldTrace", FORCE_BOOL )
AccessorFunc( ENT, "touchPlayerOnce", "TouchPlayerOnce", FORCE_BOOL )
AccessorFunc( ENT, "touchCaster", "TouchCaster", FORCE_BOOL )
AccessorFunc( ENT, "touchRate", "TouchRate", FORCE_NUMBER )
AccessorFunc( ENT, "collidePlayers", "CollideWithPlayers", FORCE_BOOL )
AccessorFunc( ENT, "collideSkills", "CollideWithSkills", FORCE_BOOL )

function ENT:Initialize()
    self:SetBirth( CurTime() )
    self.loaded = true
end

function ENT:Think()
    if (!self:Update()) then return end

    if ( !IsValid(self:GetCaster()) ) then --TODO validate target
        self:SetCaster(game.GetWorld())
        self:Remove()
        return
    end

    if ( self:GetDestroyFlag() ) then self:Remove() end
    if ( self:GetRemoveOnWorldTrace() ) then self:CheckWorldTrace() end
    if ( self:GetCustomCollider() ) then self:CalcCustomCollisions() end

    local stage = self:GetNW2Int("stage")
    if self.skill.stages[stage] and self.alive > self.skill.stages[stage] then
        self:SetNW2Int("stage", stage + 1)
    end

    local skill = self:UpdateSkill( stage )
    skill:HandleDots( self )

    if ( self.alive > self:GetMaxLive() ) then self:Remove() end

    return true
end

local function shouldTouchContinue( ent, touched )
    if (!ent:GetTriggerFlag()) then return false end

    if (touched:IsPlayer()) then
        if (!ent:GetTouchCaster() and ent:GetCaster() == touched) then
            return false
        end

        if (ent:GetTouchPlayerOnce()) then
            if (ent.touchedPlayers[touched]) then return false end
            ent.touchedPlayers[touched] = true
        end
    end

    local now = CurTime()
    ent.touchCooldown[touched] = ent.touchCooldown[touched] or 0
    if (ent.touchCooldown[touched] > now) then return false end
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

function ENT:CalcCustomCollisions()
    local touchingBefore = self.touching
    self.touching = {}
    local list = {}

    if self:GetCollideWithPlayers() then
        table.Add(list, player.GetAll())
    end
    if self:GetCollideWithSkills() then
        table.Add(list, skill_manager.GetAll())
    end

    local touching = self.collider:GetTouchedObjects( list )
    for _, hit in next, touching do
        self.touching[hit.obj] = hit.distance
    end

    for obj, distance in next, self.touching do
        self:Touch( obj )
        if touchingBefore[obj] then continue end
        self:StartTouch( obj )
    end
end

function ENT:RemoveOnDeath( target )
    if !target then target = { self:GetCaster() } end
    if !istable(target) then target = { target } end
    self.removeOnDeath = target
end

function ENT:GetRemoveOnDeath()
    return self.removeOnDeath
end