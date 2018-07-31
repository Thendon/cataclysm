local player = FindMetaTable( "Player" )

local globalCooldown = 0.5

if CLIENT then
    local waitForResponse = 0

    function player:UseKey( key, pressing )
        local skill = skill_manager.GetSkill(self.skills[key])

        local hasTarget, cleverData = skill:CleverCast( pressing )

        if (skill:GetCastUntilRelease() and (!pressing or !hasTarget)) then
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

    function player:ApplyCooldown(skill, timestamp)
        self:SetCooldown(skill, timestamp - 0.1)

        for k, cooldown in next, self.nextUse do
            self.nextUse[k] = math.max(cooldown, CurTime() + globalCooldown - 0.1)
        end
    end

    function player:ResetCooldowns( timestamp )
        for key, skillname in next, self.skills do
            local skill = skill_manager.GetSkill(skillname)
            self:SetCooldown( skill, timestamp + skill:GetCooldown() - 0.1 )
        end
    end

    function player:SetCasting( skill, status )
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
    function player:UseSkill( skill, cleverData )
        print(self,skill,cleverData)

        if !self:CanActivateSkill( skill ) then --todo add skill conditions
            netstream.Start(self, "player:SkillDenied", skill:GetName())
            return
        end

        if (skill:GetCastUntilRelease() and self:GetCasting(skill)) then return end

        skill:Activate( self, cleverData )
    end

    function player:BreakSkill( skill )
        if !skill:GetCastUntilRelease() then return end

        self:SetCasting( skill, false )
    end

    function player:ApplyCooldown( skill, time )
        self:SetCooldown( skill, CurTime() + time )

        for k, cooldown in next, self.nextUse do
            self.nextUse[k] = math.max(cooldown, CurTime() + globalCooldown)
        end

        netstream.Start( self, "player:ApplyCooldown", skill:GetName(), self.nextUse[skill] )
    end

    function player:ResetCooldowns()
        for key, skillname in next, self.skills do
            local skill = skill_manager.GetSkill(skillname)
            self:SetCooldown( skill, CurTime() + skill:GetCooldown() )
        end

        netstream.Start( self, "player:ResetCooldowns", CurTime() )
    end

    function player:SetCasting( skill, status, entity )
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

function player:SetCooldown( skill, timestamp )
    self.nextUse = self.nextUse or {}
    self.nextUse[skill] = timestamp
end

function player:CanActivateSkill( skill )
    if (!self:Alive()) then return false end
    if (SERVER and self:IsSilenced()) then return false end
    if self:GetCooldown( skill ) > 0 then return false end
    return true
end

function player:SkillNextUse( skill )
    self.nextUse = self.nextUse or {}
    self.nextUse[skill] = self.nextUse[skill] or 0

    return self.nextUse[skill]
end

function player:GetCooldown( skill )
    if (isnumber(skill)) then skill = skill_manager.GetSkill(self.skills[skill]) end
    return math.Clamp((self:SkillNextUse( skill ) - CurTime()) / skill.cooldown, 0, 1)
end

function player:HandSwitcher()
    self.hand = self.hand or false
    self.hand = !self.hand
    return self.hand
end

function player:GetCasting( skill )
    self.casting = self.casting or {}

    return self.casting[skill] or false
end