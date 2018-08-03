local meta = FindMetaTable( "Player" )

local assistTime = 7

function meta:SetClassPick( class )
    self.classPick = class
end

function meta:GetClassPick()
    return self.classPick
end

function meta:JoinTeam(teamID)
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

function meta:IsSpectator()
    local teamID = self:Team()
    return teamID != TEAM_BLACK and teamID != TEAM_WHITE
end

function meta:LastDeath()
    return self.lastDeath or 0
end

function meta:SetLastDeath( time )
    self.lastDeath = time or CurTime()

    if SERVER then netstream.Start(self, "player:SetLastDeath", time) end
end

function meta:LastHit()
    return self.lastHit or false
end

function meta:SetLastHit( info )
    self.lastHit = {}
    self.lastHit.attacker = info.attacker or info:GetAttacker()
    self.lastHit.inflictor = info.inflictor or info:GetInflictor()
    self.lastHit.damage = info.damage or info:GetDamage()
    self.lastHit.time = info.time or CurTime()

    if SERVER then
        netstream.Start(self, "player:SetLastHit", self.lastHit)
        if IsValid(self.lastHit.attacker) and self.lastHit.attacker:IsPlayer() then
            netstream.Start(self.lastHit.attacker, "player:LandedHit", self, self.lastHit.time)
            self:AddAssists(self.lastHit.attacker, info.time)
        end
    end
end

function meta:AddAssists( ply, time )
    time = time or CurTime()
    self.assistList = self.assistList or {}

    table.insert(self.assistList, { player = ply, time = time + assistTime })
end

function meta:GetAssists()
    self.assistList = self.assistList or {}

    local i = 1
    while i <= table.Count(self.assistList) do
        local assist = self.assistList[i]
        if !IsValid(assist.player) or assist.time < CurTime() then
            table.remove(self.assistList, i)
            continue
        end
        i = i + 1
    end

    return self.assistList
end

function meta:WipeAssists()
    self.assistList = {}
end

function meta:SetKey( key, status )
    self.keysPressed = self.keysPressed or {}

    self.keysPressed[key] = status
end

function meta:KeyPressed( key )
    self.keysPressed = self.keysPressed or {}

    return self.keysPressed[key] or false
end

function meta:GetMoveVector()
    local direction = Vector()
    if self:KeyPressed(IN_MOVERIGHT) then direction = direction + self:GetRight() end
    if self:KeyPressed(IN_MOVELEFT) then direction = direction - self:GetRight() end
    if self:KeyPressed(IN_FORWARD) then direction = direction + self:GetForward() end
    if self:KeyPressed(IN_BACK) then direction = direction - self:GetForward() end

    if direction:LengthSqr() < 0.1 then direction = _VECTOR.UP end
    return direction:GetNormalized()
end

function meta:GetScore()
    return self.score or 0
end

function meta:AddScore( points )
    self.score = self.score or 0
    self.score = self.score + points

    if SERVER then netstream.Start(player.GetAll(), "player:SetScore", self, self.score) end
end

function meta:SetScore( score )
    self.score = score
end

function meta:GetLastScore()
    return self.lastScored
end

if CLIENT then
    function meta:SetClassIcon( icon )
        self.classIcon = icon
    end

    function meta:GetClassIcon()
        self.classIcon = self.classIcon or player_manager.RunClass(self, "GetClassIcon")
        return self.classIcon
    end

    function meta:SetLastLandedHit( ply, time )
        self.lastLandedHit = self.lastLandedHit or {}
        self.lastLandedHit.player = ply
        self.lastLandedHit.time = time
    end

    function meta:LastLandedHit()
        return self.lastLandedHit or false
    end

    netstream.Hook("player:SetLastDeath", function(time)
        LocalPlayer():SetLastDeath(time)
    end)

    netstream.Hook("player:SetLastHit", function(lastHit)
        LocalPlayer():SetLastHit(lastHit)
    end)

    netstream.Hook("player:SetScore", function(ply, score)
        ply:SetScore(score)
    end)

    netstream.Hook("player:LandedHit", function(ply, time)
        LocalPlayer():SetLastLandedHit( ply, time )
    end)
end