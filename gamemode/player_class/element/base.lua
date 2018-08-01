local player = {}
local keyWasDown = {}
local spawnProtection = 2

function player:Init()
    self.Player.skills = self.skills
    self.Player:SetWalkSpeed( self.WalkSpeed )
    self.Player:SetRunSpeed( self.WalkSpeed )
    self.Player:SetCanZoom( false )
    --todo check if unused
    local skills = {}
    for name, skill in next, self.skills do
        skills[skill] = name
    end
    self.Player.keys = skills

    self:SetRandomClassModel()
    self.Player:ResetCooldowns( CurTime() )

    if CLIENT and self.Player:Team() == LocalPlayer():Team() then
        sound.Play(self.Sound, self.Player:GetPos())
    end

    if SERVER then
        self.Player:SetMaxHealth( self.Health )
    end
end

function player:Spawn()
    self.Player:ResetCooldowns()

    self.Player:SetHealth(self.Player:GetMaxHealth())
    self.Player:SetSkillImmune(spawnProtection)
    self.Player:SetFallImmune(spawnProtection)
end

function player:SetRandomClassModel()
    local model, details = self:GetModel()
    self.Player:SetModel(model)
    if (details) then
        if details.skin then self.Player:SetSkin(details.skin) end
        if details.body then self.Player:SetBodygroup(details.body.id, details.body.value) end
    end
end

function player:GetModel( id )
    id = id or math.random(1, table.Count(self.models))
    return self.models[id].model, self.models[id].details
end

function player:GetClassIcon()
    return self.Icon
end

function player:GetClassColor()
    return self.Color
end

function player:GetTrack()
    return self.Track
end

if SERVER then
    function player:CalcMoveSpeed()
        local slowFactor = self.Player:GetSlowFactor()
        local newSpeed = self.WalkSpeed * slowFactor

        if (self.Player:GetWalkSpeed() == newSpeed) then return end

        self.Player:SetWalkSpeed( newSpeed )
        self.Player:SetRunSpeed( newSpeed )
    end
end

if CLIENT then
    local menuKeys = {}
    menuKeys[KEY_H] = classSelection
    menuKeys[KEY_J] = teamSelection

    local cooldownKeys = {}
    cooldownKeys[MOUSE_LEFT] = 0
    cooldownKeys[MOUSE_RIGHT] = 0

    function player:SkillInputs( cmd )
        for key, skill in next, self.skills do
            if input.IsButtonDown( key ) then
                self.Player:UseKey( key, true )
                keyWasDown[key] = true
            elseif keyWasDown[key] then
                self.Player:UseKey( key, false )
                keyWasDown[key] = false
            end
            if cooldownKeys[key] then cooldownKeys[key] = 0 end
        end
    end

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

    --this is my masterpiece xD
    local function HandleLeftMouse()
        for key, timestamp in next, cooldownKeys do
            if input.IsButtonDown( key ) then
                if timestamp > CurTime() then return true end
                cooldownKeys[key] = CurTime() + 0.5
            end
        end

        return false
    end

    function player:StartMove( mv, cmd )
        if (LocalPlayer():IsTyping()) then return end
        if (gui.IsGameUIVisible()) then return end

        self:MenuInputs( cmd )

        if (cataUI.IsActive()) then return end
        if (HandleLeftMouse()) then return end
        if (IsValid( vgui.GetHoveredPanel() )) then return end
        if (self.Player:IsTyping()) then return end

        self:SkillInputs( cmd )

        --do static skills here
    end
end

player_manager.RegisterClass("player_element", player, "player_default")