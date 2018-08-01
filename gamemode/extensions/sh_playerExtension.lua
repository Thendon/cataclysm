local player = FindMetaTable( "Player" )

function player:SetClassPick( class )
    self.classPick = class
end

function player:GetClassPick()
    return self.classPick
end

function player:JoinTeam(teamID)
    if self:Alive() then self:Kill() end

    if self:IsSpectator() then
        self:UnSpectate()
    end

    self:SetTeam(teamID)
    self.selectedTeam = teamID

    if self:IsSpectator() then
        self:Spectate(OBS_MODE_ROAMING)
    end
end

function player:IsSpectator()
    local teamID = self:Team()
    return teamID != TEAM_BLACK and teamID != TEAM_WHITE
end

function player:LastDeath()
    return self.lastDeath or 0
end

function player:SetLastDeath( time )
    self.lastDeath = time or CurTime()

    if SERVER then netstream.Start(self, "player:SetLastDeath", time) end
end

function player:LastHit()
    return self.lastHit or false
end

function player:SetLastHit( info )
    self.lastHit = {}
    self.lastHit.attacker = info.attacker or info:GetAttacker()
    self.lastHit.inflictor = info.inflictor or info:GetInflictor()
    self.lastHit.damage = info.damage or info:GetDamage()
    self.lastHit.time = info.time or CurTime()

    if SERVER then netstream.Start(self, "player:SetLastHit", self.lastHit) end
end

function player:SetKey( key, status )
    self.keysPressed = self.keysPressed or {}

    self.keysPressed[key] = status
end

function player:KeyPressed( key )
    return self.keysPressed[key] or false
end

function player:GetMoveVector()
    local direction = Vector()
    if self:KeyPressed(IN_MOVERIGHT) then direction = direction + self:GetRight() end
    if self:KeyPressed(IN_MOVELEFT) then direction = direction - self:GetRight() end
    if self:KeyPressed(IN_FORWARD) then direction = direction + self:GetForward() end
    if self:KeyPressed(IN_BACK) then direction = direction - self:GetForward() end

    if direction:LengthSqr() < 0.1 then direction = _VECTOR.UP end
    return direction:GetNormalized()
end

if CLIENT then
    netstream.Hook("player:SetLastDeath", function(time)
        LocalPlayer():SetLastDeath(time)
    end)

    netstream.Hook("player:SetLastHit", function(lastHit)
        LocalPlayer():SetLastHit(lastHit)
    end)
end