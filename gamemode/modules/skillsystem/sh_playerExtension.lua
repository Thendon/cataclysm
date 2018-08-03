local meta = FindMetaTable( "Player" )

local globalCooldown = 0.5

if CLIENT then
    local waitForResponse = 0

    function meta:UseKey( key, pressing )
        local skill = skill_manager.GetSkill(self.skills[key])

        local hasTarget, cleverData = skill:CleverCast( pressing )

        if (skill:GetCastUntilRelease() and self:GetCasting(skill) and (!pressing or !hasTarget)) then
            self:SetCasting(skill, false)
            netstream.Start("player:BreakSkill", skill:GetName() )
            return
        end

        if !hasTarget then return end
        if !self:CanActivateSkill( skill ) then return end
        if !skill:CanBeActivated( self, pressing ) then return end
        if waitForResponse > CurTime() then return end

        waitForResponse = CurTime() + 0.5
        netstream.Start("player:UseSkill", skill:GetName(), cleverData )
    end

    function meta:ApplyCooldown(skill, timestamp)
        self:SetCooldown(skill, timestamp - 0.1)
        self:ApplyGlobalCooldown( timestamp - skill:GetCooldown(), 0.1 )
    end

    function meta:ResetCooldowns( timestamp )
        for key, skillname in next, self.skills do
            local skill = skill_manager.GetSkill(skillname)
            self:SetCooldown( skill, timestamp + skill:GetCooldown() - 0.1 )
        end
    end

    function meta:SetCasting( skill, status )
        self.casting = self.casting or {}
        self.casting[skill] = status
    end

    netstream.Hook("player:SkillDenied", function( skillname )
        waitForResponse = 0
    end)

    netstream.Hook("player:ApplyCooldown", function( skillname, timestamp )
        waitForResponse = 0
        LocalPlayer():ApplyCooldown( skill_manager.GetSkill(skillname), timestamp )
    end)

    netstream.Hook("player:SetCasting", function( skillname, status )
        waitForResponse = 0
        LocalPlayer():SetCasting( skill_manager.GetSkill(skillname), status )
    end)

    netstream.Hook("player:ResetCooldowns", function( timestamp )
        if !GAMEMODE:Loaded() then return end
        LocalPlayer():ResetCooldowns( timestamp )
    end)
end

if SERVER then
    function meta:UseSkill( skill, cleverData )
        print(self,skill,cleverData)

        if !self:CanActivateSkill( skill ) then --todo add skill conditions
            netstream.Start(self, "player:SkillDenied", skill:GetName())
            return
        end

        if (skill:GetCastUntilRelease() and self:GetCasting(skill)) then return end

        skill:Activate( self, cleverData )
    end

    function meta:BreakSkill( skill )
        if !skill:GetCastUntilRelease() then return end

        self:SetCasting( skill, false )
    end

    function meta:ApplyCooldown( skill, time )
        self:SetCooldown( skill, CurTime() + time )
        self:ApplyGlobalCooldown()

        netstream.Start( self, "player:ApplyCooldown", skill:GetName(), self.nextUse[skill] )
    end

    function meta:ResetCooldowns()
        for key, skillname in next, self.skills do
            local skill = skill_manager.GetSkill(skillname)
            self:SetCooldown( skill, CurTime() + skill:GetCooldown() )
        end

        netstream.Start( self, "player:ResetCooldowns", CurTime() )
    end

    function meta:SetCasting( skill, status, entity )
        self.casting = self.casting or {}
        self.castingEnts = self.castingEnts or {}

        self.casting[skill] = status
        if status then
            if IsValid(self.castingEnts[skill]) then
                skill:Deactivate(self.castingEnts[skill])
            end
            self.castingEnts[skill] = entity
        else
            skill:Deactivate(self.castingEnts[skill])
        end
        netstream.Start(self, "player:SetCasting", skill:GetName(), status)
    end

    netstream.Hook("player:UseSkill", function( ply, skillname, cleverData )
        ply:UseSkill( skill_manager.GetSkill(skillname), cleverData )
    end)

    netstream.Hook("player:BreakSkill", function( ply, skillname )
        ply:BreakSkill( skill_manager.GetSkill(skillname) )
    end)
end

function meta:SetCooldown( skill, timestamp )
    self.nextUse = self.nextUse or {}
    self.nextUse[skill] = timestamp
    self.cooldownTime = self.cooldownTime or {}
    self.cooldownTime[skill] = timestamp - CurTime()
end

function meta:CanActivateSkill( skill )
    if (!self:Alive()) then return false end
    if (SERVER and self:IsSilenced()) then return false end
    if self:GetCooldown( skill ) > 0 then return false end
    return true
end

function meta:SkillNextUse( skill )
    self.nextUse = self.nextUse or {}
    self.nextUse[skill] = self.nextUse[skill] or 0

    return self.nextUse[skill]
end

function meta:GetCooldownLength( skill )
    self.cooldownTime = self.cooldownTime or {}
    self.cooldownTime[skill] = self.cooldownTime[skill] or 1

    return self.cooldownTime[skill]
end

function meta:GetCooldown( skill )
    if (isnumber(skill)) then skill = skill_manager.GetSkill(self.skills[skill]) end
    local nextUse = self:SkillNextUse( skill ) - CurTime()
    local cooldown = self:GetCooldownLength( skill ) or skill.cooldown

    return math.Clamp( nextUse / cooldown, 0, 1)
end

function meta:HandSwitcher()
    self.hand = self.hand or false
    self.hand = !self.hand
    return self.hand
end

function meta:GetCasting( skill )
    self.casting = self.casting or {}

    return self.casting[skill] or false
end

function meta:ApplyGlobalCooldown( timestamp, epsilon )
    timestamp = timestamp or CurTime()
    epsilon = epsilon or 0

    local global = timestamp + globalCooldown
    for otherSkill, cooldown in next, self.nextUse do
        if cooldown > global then continue end
        self.nextUse[otherSkill] = global - epsilon
        self.cooldownTime[otherSkill] = globalCooldown - epsilon
    end
end