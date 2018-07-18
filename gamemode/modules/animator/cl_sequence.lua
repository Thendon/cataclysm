
local sequence = Class()

local function validateAct( actID )
    if (!table.HasValue(VALID_ACTS, actID)) then
        error("act " .. tostring(actID) .. " invalid")
    end
    return actID
end

function sequence:_init( actID, duration, startW, endW )
    self.actID = actID --validateAct(actID)
    self.duration = duration or 1
    self.durationFactor = 1 / self.duration
    self.startW = startW or 0
    self.endW = endW or 1
end

function sequence:GetInfos( state )
    local weight = self.startW + state * (self.endW - self.startW)
    return self.actID, weight
end

return sequence