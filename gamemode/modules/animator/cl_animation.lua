_G.Animation = Animation or Class()

function Animation:_init( sequences, speed, interruptable )
    self.sequences = sequences
    self.speed = speed or 1
    self.interruptible = (interruptible == nil) and true or false
end

function Animation:GetActiveSequence( state )
    local activeSequence = -1
    local sequenceState = 0
    local prevDuration = 0
    for k, sequence in next, self.sequences do
        if (state > prevDuration + sequence.duration) then
            prevDuration = prevDuration + sequence.duration
            continue
        end

        activeSequence = sequence
        sequenceState = ( state - prevDuration ) * sequence.durationFactor
        break
    end

    return activeSequence, sequenceState
end

function Animation:GetInfos( state )
    local activeSequence, sequenceState = self:GetActiveSequence( state )
    if (activeSequence == -1) then return activeSequence end
    return activeSequence:GetInfos( sequenceState )
end