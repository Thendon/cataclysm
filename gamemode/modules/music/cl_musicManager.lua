_G.music_manager = music_manager or {}

local tracks = {}

local tensionTime = 10

local function analyseFile( trackname, file )
    local sequence = {}

    local formatPos = string.len(file) - 3
    local namePos = string.len(trackname) + 1
    sequence.format = string.sub(file, formatPos)
    sequence.name = string.sub(file, namePos, formatPos - 1)

    local sufix = string.sub(sequence.name, 0)
    local state
    if string.len(sufix) == 1 then
        state = tonumber(sufix)
    elseif string.find(sufix, "_end") then
        state = -1
    else
        local number = tonumber(string.sub(sufix, 1, 1))
        susufix = string.sub(sufix, 3)
        if susufix == "t" then
            sequence.transition = number
        elseif susufix == "h" then
            sequence.half = number
        else
            state = number
        end
    end
    sequence.state = state

    return sequence
end

function music_manager.Feed( name, files )
    tracks[name] = {}

    for k, file in next, files do
        table.insert(tracks[name], analyseFile( name, file ))
    end
end

function music_manager.GetTrack( name )
    return tracks[name]
end

function music_manager.ChangeTrack( trackname )
    print("change track")
    music_machine.SetTrack(trackname)
    music_machine.EndTrack()
end

function music_manager.UpdateHealthFracion()
    local health = LocalPlayer():Health() / LocalPlayer():GetMaxHealth()
    local fraction = math.Clamp(1 - health, 0, 1)
    music_machine.SetFraction(fraction)
end

function music_manager.SetTrackStatus( status )
    local playing = music_machine.IsPlaying()

    if playing == status then return end

    if status then
        music_machine.StartTrack()
    else
        music_machine.EndTrack()
    end
end

function music_manager.EndTrack()
    music_manager.SetTrackStatus( false )
end

function music_manager.StartTrack()
    music_manager.SetTrackStatus( true )
end

local function HandleLastHit()
    local lastHit = LocalPlayer():LastHit()

    if !lastHit then return false end

    if lastHit.time <= LocalPlayer():LastDeath() then
        return false
    end

    if lastHit.time + tensionTime < CurTime() then
        return false
    end

    return true
end

local function HandleLastLandedHit()
    local lastLanded = LocalPlayer():LastLandedHit()

    if !lastLanded then return false end

    if lastLanded.time <= LocalPlayer():LastDeath() then
        return false
    end

    if lastLanded.time + tensionTime < CurTime() then
        return false
    end

    return true
end

function music_manager.ControlPlaying()
    if round_manager.GetRoundState() != ROUND_STATE.ACTIVE then
        music_manager.SetTrackStatus( false )
        return
    end

    if !HandleLastHit() and !HandleLastLandedHit() then
        music_manager.SetTrackStatus( false )
        return
    end

    music_manager.SetTrackStatus( true )
end

function music_manager.Update()
    if !GAMEMODE:Loaded() then return end

    local playerTrack = player_manager.RunClass(LocalPlayer(), "GetTrack")
    local machineTrack = music_machine.GetTrack()
    if machineTrack != playerTrack then music_manager.ChangeTrack(playerTrack) end

    music_manager.ControlPlaying()
    music_manager.UpdateHealthFracion()

    music_machine.Update()
end