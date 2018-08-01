_G.music_machine = music_machine or {}

local MUSIC_STATES = {}
MUSIC_STATES.OVER = -3
MUSIC_STATES.LOADING = -2
MUSIC_STATES.ENDING = -1
MUSIC_STATES.LOADED = 0
MUSIC_STATES.START = 1
--state > 0 => PLAYING

music_machine.state = music_machine.state or MUSIC_STATES.OVER
music_machine.sequence = music_machine.sequence
music_machine.sequences = music_machine.sequences or {}
music_machine.trackPlaying = music_machine.trackPlaying
music_machine.totalStates = music_machine.totalStates or 0
local desiredState = MUSIC_STATES.ENDING
local trackname

function music_machine.GetState()
    return music_machine.state
end

function music_machine.IsPlaying()
    return music_machine.state > MUSIC_STATES.LOADED or music_machine.state == MUSIC_STATES.ENDING
end

function music_machine.IsOver()
    return music_machine.state == MUSIC_STATES.OVER
end

function music_machine.GetTrack()
    return music_machine.trackPlaying
end

local function SetDesiredState( state, force )
    if !force and desiredState == MUSIC_STATES.ENDING then return end
    desiredState = force and state or math.Clamp(state, 1, music_machine.totalStates)
end

function music_machine.EndTrack()
    SetDesiredState( MUSIC_STATES.ENDING, true )
end

function music_machine.StartTrack()
    SetDesiredState( MUSIC_STATES.START, true )
end

local function CheckLoadingStatus()
    print("CHECK STATUS")
    local ready = true
    if table.Count(music_machine.sequences) < 1 then return end

    for _, sequence in next, music_machine.sequences do
        if !sequence.channel then ready = false break end
        if sequence.channel:GetState() != GMOD_CHANNEL_STOPPED then ready = false break end
    end
    if ready then music_machine.state = MUSIC_STATES.LOADED end
end

local function IsLoopingSequence( sequence )
    return !sequence.transition and sequence.state != MUSIC_STATES.ENDING
end

local function ForceStopSequences()
    for k, sequence in next, music_machine.sequences do
        sequence.channel:Pause()
    end
end

local function BufferTrack()
    local track = music_manager.GetTrack(trackname)
    if !track then
        music_machine.state = MUSIC_STATES.OVER
        return
    end

    music_machine.state = MUSIC_STATES.LOADING
    music_machine.trackPlaying = trackname

    ForceStopSequences()
    music_machine.sequences = {}

    music_machine.totalStates = 0
    for k, sequence in next, track do
        local file = "sound/element/music_managed/" .. trackname .. "/" .. trackname .. sequence.name .. sequence.format
        music_machine.sequences[k] = table.Copy(sequence)

        local flags = "noplay"
        local looping = IsLoopingSequence( sequence )
        if looping then flags = flags .. " noblock" end

        --noplay = does not start without command, noblock = enables looping
        sound.PlayFile( file, flags, function(channel, errID, errName)
            if (!channel) then error("Music could not be buffered (" .. tostring(errName) .. ")") end
            --if looping then channel:EnableLooping(true) end
            music_machine.sequences[k].channel = channel
        end)

        if !sequence.state then continue end
        if music_machine.totalStates >= sequence.state then continue end
        music_machine.totalStates = sequence.state
    end
end

function music_machine.SetTrack( name )
    trackname = name
end

function music_machine.HasValidTrack()
    return music_machine.totalStates > 0
end

function music_machine.SetFraction( fraction )
    --print(fraction)
    if !music_machine.HasValidTrack() or desiredState < MUSIC_STATES.START then return end

    if fraction == 1 then
        music_machine.EndTrack()
        return
    end

    fraction = math.ceil(fraction * music_machine.totalStates)
    SetDesiredState(fraction)
end

local function GetTransition( sequence )
    sequence = sequence or music_machine.sequence
    if !sequence then return false end

    for k, seq in next, music_machine.sequences do
        if !seq.transition then continue end
        if seq.transition != sequence.state then continue end
        return seq
    end
    return false
end

local function GetNextSequence()
    local transition = GetTransition(music_machine.sequence)
    if transition then return transition end

    local options = {}
    for k, sequence in next, music_machine.sequences do
        if sequence.state == desiredState then
            table.insert(options, sequence)
        end
    end

    return options[math.random(1, table.Count(options))]
end

local function PlayNextSequence( sequence )
    sequence = sequence or GetNextSequence()
    PrintTable(sequence)
    if IsLoopingSequence( sequence ) then sequence.channel:EnableLooping(true) end
    music_machine.sequence = sequence
    music_machine.state = music_machine.sequence.state or music_machine.sequence.transition
    music_machine.sequence.channel:Play()
end

local function SwitchState( desiredSequence )
    local sequence = music_machine.sequence

    if sequence.channel:IsLooping() then sequence.channel:EnableLooping(false) end

    local ending = sequence.channel:GetLength() - sequence.channel:GetTime()
    local delta = DeltaTime()
    if ending > delta and delta < 1 or delta > 1 and sequence.channel:GetState() == GMOD_CHANNEL_PLAYING then return end
    --sequence.channel:Pause()
    --sequence.channel:SetTime(0)

    PlayNextSequence( desiredSequence )
end

local function HasAlternatives(sequence)
    for k, seq in next, music_machine.sequences do
        if seq == sequence then continue end
        if !seq.state then continue end
        if seq.state != sequence.state then continue end
        return seq
    end
    return false
end

local function HandlePlayingState()
    --print(desiredState, music_machine.state)

    if desiredState != music_machine.state then
        SwitchState()
        return
    end

    if music_machine.state == MUSIC_STATES.ENDING then
        if music_machine.sequence.channel:GetState() != GMOD_CHANNEL_PLAYING then
            music_machine.state = MUSIC_STATES.OVER
        end
        return
    end

    local alternative = HasAlternatives(music_machine.sequence)
    if alternative then
        SwitchState( alternative )
        return
    end
end

local function CheckStartFlag()
    if desiredState < 1 then return end
    --print("start next")
    PlayNextSequence()
end

local function TrackChanged()
    return trackname and trackname != music_machine.trackPlaying
end

local function CheckTrackStatus()
    if TrackChanged() then
        print("BUFFER NEW")
        BufferTrack()
        return
    end

    if music_machine.HasValidTrack() then
        print("HAS VALID")
        music_machine.state = MUSIC_STATES.LOADING
    end
end

function music_machine.Update()
    if music_machine.state == MUSIC_STATES.OVER then
        CheckTrackStatus()
        return
    end
    if music_machine.state == MUSIC_STATES.LOADING then
        CheckLoadingStatus()
        return
    end
    if music_machine.state == MUSIC_STATES.LOADED then
        if TrackChanged() then
            music_machine.state = MUSIC_STATES.OVER
            return
        end
        CheckStartFlag()
        return
    end

    HandlePlayingState()
end