
_G.Sequence = Sequence or Class()

--[[local function validateAct( actID )
    if (!table.HasValue(VALID_ACTS, actID)) then
        error("act " .. tostring(actID) .. " invalid")
    end
    return actID
end]]

function Sequence:_init( actID, duration, startW, endW )
    self.actID = actID --validateAct(actID)
    self.duration = duration or 1
    self.durationFactor = 1 / self.duration
    self.startW = startW or 0
    self.endW = endW or 1
end

function Sequence:GetInfos( state, starting )
    local weight = self.startW + state * (self.endW - self.startW)
    return self.actID, weight, starting and self:GetSound()
end

function Sequence:SetSound( sounds )
    if !istable(sounds) then sounds = { sounds } end
    self.sounds = sounds
end

function Sequence:GetSound()
    if !self.sounds then return false end
    return self.sounds[math.random(1, table.Count(self.sounds))]
end