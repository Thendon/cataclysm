
local BGSVolume = 0.25

local activeBGS = {}
local activeBGL = {}

local function fadeOut( volume, target, speed )
    if volume > target then
        volume = math.max( target, volume - DeltaTime() * speed )
    end
    return volume
end

local function fadeIn( volume, target, speed )
    if volume < target then
        volume = math.min( target, volume + DeltaTime() * speed )
    end
    return volume
end

_G.FadeTo = function( volume, target, speed )
    if volume < target then
        volume = math.min( target, volume + DeltaTime() * speed )
    elseif volume > target then
        volume = math.max( target, volume - DeltaTime() * speed )
    end
    return volume
end

_G.SoundFadeFocus = function( volume, target )
    if !system.HasFocus() then
        return fadeOut( volume, 0, 1 )
    end
    return fadeIn( volume, target, 1 )
end

_G.PlayBGS = function( file )
    sound.PlayFile("sound/" .. file, "noplay", function( channel )
        if !IsValid( channel ) then print("couldnt play bgs: " .. tostring(file)) return end

        channel:SetVolume(system.HasFocus() and BGSVolume or 0)
        channel:Play()

        table.insert(activeBGS, {channel = channel, volume = BGSVolume})
    end)
end

local function CalcVolumeDistance( pos, volume, level )
    local range = level * 25
    local distance = (LocalPlayer():GetPos() - pos):Length()
    return math.Clamp( 1 - distance / range, 0, 1 ) * volume
end

_G.PlayBGL = function( ent, name, delta )
    delta = delta or 1
    local data = sound.GetProperties( name )
    --TODO 3d is broken for some reason :S
    sound.PlayFile("sound/" .. data.sound, "noplay noblock", function( channel, errID, errMsg )
        if !IsValid( channel ) then print("couldnt play bgs: " .. tostring(data.sound), errID, errMsg) return end

        channel:SetVolume(0)
        --channel:SetPos(ent:GetPos())
        channel:Set3DFadeDistance(data.level, data.level * 5)
        channel:EnableLooping(true)
        channel:Play()

        table.insert(activeBGL, { channel = channel, ent = ent, delta = delta, volume = data.volume, level = data.level, start = CurTime() })

        ent.bgl = channel
    end)
end

local function HandleActiveBGL()
    local toRemove = {}
    for k, bgl in next, activeBGL do
        if !IsValid(bgl.channel) or bgl.channel:GetState() == GMOD_CHANNEL_STOPPED then
            table.insert(toRemove, k)
            continue
        end

        local volume = bgl.channel:GetVolume()

        if IsValid(bgl.ent) then
            --scince 3d is not working
            local distance = CalcVolumeDistance( bgl.ent:GetPos(), bgl.volume, bgl.level )
            local fade = SoundFadeFocus( volume, bgl.volume )
            volume = FadeTo( volume, math.min(distance, fade), bgl.delta )
        else
            volume = fadeOut( volume, 0, bgl.delta )
            if (volume <= 0) then
                bgl.channel:Stop()
                table.insert(toRemove, k)
                continue
            end
        end

        bgl.channel:SetVolume(volume)
    end

    for k, index in next, toRemove do
        table.remove(activeBGL, index)
    end
end

local function HandleActiveBGS()
    local toRemove = {}

    for k, bgs in next, activeBGS do
        bgs.channel:SetVolume( SoundFadeFocus( bgs.channel:GetVolume(), bgs.volume ) )
    end

    for k, index in next, toRemove do
        table.remove(activeBGL, index)
    end
end

hook.Add("Tick", "handleActiveBGL", function()
    HandleActiveBGL()
    HandleActiveBGS()
end)