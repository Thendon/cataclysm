local player = {}
local keyWasDown = {}

function player:Init()
    self.Player.skills = self.skills
end

function player:GetClassIcon()
    return self.Icon
end

function player:GetClassColor()
    return self.Color
end

if SERVER then
    function player:CalcMoveSpeed()
        local slowFactor = self.Player:GetSlowFactor()
        local newSpeed = self.WalkSpeed * slowFactor

        if (self.Player:GetWalkSpeed() == newSpeed) then return end

        self.Player:SetWalkSpeed( newSpeed )
        self.Player:SetRunSpeed( self.RunSpeed * slowFactor )
    end
end

if CLIENT then
    function player:SkillInputs( cmd )
        for key, skill in next, self.skills do
            if input.IsButtonDown( key ) then
                self.Player:UseSkill( key, true )
                keyWasDown[key] = true
            elseif keyWasDown[key] then
                self.Player:UseSkill( key, false )
                keyWasDown[key] = false
            end
        end
    end

    local menuKeys = {}
    menuKeys[KEY_H] = classSelection

    function player:MenuInputs( cmd )
        for key, menu in next, menuKeys do
            if input.IsButtonDown(key) then
                keyWasDown[key] = true
            elseif keyWasDown[key] then
                menu:Toggle()
                keyWasDown[key] = false
            end
        end
    end

    function player:StartMove( mv, cmd )
        if (LocalPlayer():IsTyping()) then return end
        if (gui.IsGameUIVisible()) then return end

        self:MenuInputs( cmd )

        if (cataUI.IsActive()) then return end
        if (IsValid( vgui.GetHoveredPanel() )) then return end

        self:SkillInputs( cmd )
        --do static skills here
    end
end

player_manager.RegisterClass("player_element", player, "player_default")