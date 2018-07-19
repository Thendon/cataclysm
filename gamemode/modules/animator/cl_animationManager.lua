local VALID_ACTS = include("cl_acts.lua")
local sequence = include("cl_sequence.lua")
local animation = include("cl_animation.lua")

local animator = {}
local animations = {}

function animator:Add( animName, anim )
    animations[animName] = anim
end

function animator:GetAnimation( animName )
    return animations[animName]
end

//###################################################
local animationCreator = false
local animationFinder = false
//###################################################


local seqs = {}
local anim = {}

table.insert(seqs, sequence( 1801, 0.05, 0, 1 ))
table.insert(seqs, sequence( 1801, 0.1, 1, 1 ))
table.insert(seqs, sequence( 1801, 0.2, 1, 0 ))
table.insert(seqs, sequence( 1797, 0.02, 0, 1 ))
table.insert(seqs, sequence( 1797, 0.1, 1, 1 ))
table.insert(seqs, sequence( 1797, 0.1, 1, 0 ))
table.insert(seqs, sequence( 1, 1, 0, 0 ))

anim = animation( seqs, 1 )

animator:Add( "shoot_stone", anim )

seqs = {}
anim = {}

local id = 1670
local val = 0.5
local timetill = 0.15
local timerest = 2 - 2 * timetill
table.insert(seqs, sequence( id, timetill, 0, val ))
table.insert(seqs, sequence( id, timerest, val, val ))
table.insert(seqs, sequence( id, timetill, val, 0 ))

anim = animation( seqs, 1 )

animator:Add( "handcuffed", anim )

seqs = {}
anim = {}

local id = 1798
table.insert(seqs, sequence( id, 0.05, 0, 1 ))
table.insert(seqs, sequence( id, 0.15, 1, 1 ))
table.insert(seqs, sequence( id, 0.15, 1, 0.5 ))
table.insert(seqs, sequence( id, 10, 0.4, 0.4 ))
table.insert(seqs, sequence( id, 0.5, 0.4, 0 ))

anim = animation( seqs, 1 )

animator:Add( "shoot_fire1", anim )

seqs = {}
anim = {}

local id = 1801
table.insert(seqs, sequence( id, 0.05, 0, 1 ))
table.insert(seqs, sequence( id, 0.15, 1, 1 ))
table.insert(seqs, sequence( id, 0.15, 1, 0 ))
table.insert(seqs, sequence( 1798, 0.05, 0, 0.4 ))
table.insert(seqs, sequence( 1798, 10, 0.4, 0.4 ))
table.insert(seqs, sequence( 1798, 0.15, 0.4, 0 ))

anim = animation( seqs, 1 )

animator:Add( "shoot_fire2", anim )

seqs = {}
anim = {}

local id = 1649
local val = 1
table.insert(seqs, sequence( id, 0.15, 0, val ))
table.insert(seqs, sequence( id, 0.5, val, val ))
table.insert(seqs, sequence( id, 0.15, val, 0 ))

anim = animation( seqs, 1 )

animator:Add( "dash_fire", anim )

seqs = {}
anim = {}

local id = 2004
local val = 1
table.insert(seqs, sequence( id, 0.15, 0, val ))
table.insert(seqs, sequence( id, 0.15, val, 0 ))

anim = animation( seqs, 1 )

animator:Add( "kick_fire", anim )

local function animatePlayerConstantly(ply)
    --for k, v in next, player.GetAll() do
        if (ply:AnimationRunning()) then return end
        ply:PlayAnimation( anim )
    --end
end

hook.Add("Think", "animator", function()
    if (!animationCreator) then return end

    for k, v in next, player.GetAll() do
        animatePlayerConstantly( v )
    end
end)

//###################################################

_G.animLoop = _G.animLoop or VALID_ACTS[1]
local animWeight = 1
local animPlaying = false
local onlyValid = true

local function animationLoopOn( ply )
    animWeight = animPlaying and math.sin(CurTime() * 1) or animWeight

    ply:AnimRestartGesture( GESTURE_SLOT_CUSTOM, animLoop, true )
    ply:AnimSetGestureWeight( GESTURE_SLOT_CUSTOM, math.abs(animWeight) )
end

local function animatorInputs()
    if (input.IsKeyDown(KEY_N)) then
        animPlaying = !animPlaying
    end
end

hook.Add("UpdateAnimation", "animationFinder", function( ply )
    if !animationFinder then return end

    animationLoopOn( ply )
    animatorInputs()
end)

local function nextAnim( direction )
    if !onlyValid then
        return animLoop + direction
    end

    local index
    for k, actID in next, VALID_ACTS do
        if (actID == animLoop) then
            index = k
            break
        end
    end
    local newAnim = VALID_ACTS[index + direction]
    return newAnim or animLoop
end

local function animatorMouseWheel( cmd )
    if !animationFinder then return end

    animLoop = nextAnim(cmd:GetMouseWheel())

    if (input.WasKeyPressed(KEY_PAD_MINUS)) then
        animLoop = nextAnim( 1 )
    end

    if (input.WasKeyPressed(KEY_PAD_PLUS)) then
        animLoop = nextAnim( -1 )
    end

    if (animLoop < 0) then animLoop = 0 end
    if (animLoop > LAST_SHARED_ACTIVITY) then animLoop = LAST_SHARED_ACTIVITY end
end

hook.Add("CreateMove", "mymove", animatorMouseWheel)

local function animationLoopInfo()
    if !animationFinder then return end

    local x, y = ScrW() * 0.5, ScrH() * 0.5
    x = x - 128
    y = y - 48 - 200

    surface.SetDrawColor( 255, 255, 255, 100 )
    surface.DrawRect( x - 32, y - 32, 256, 128 )

    surface.SetFont( "DermaLarge" )
    surface.SetTextColor( 255, 0, 0, 255 )
    surface.SetTextPos( x, y )
    surface.DrawText( "ANIM: " .. animLoop )
    surface.SetTextPos( x, y + 32 )
    surface.DrawText( "WGHT: " .. animWeight )
end

hook.Add( "HUDPaint", "drawsometext", animationLoopInfo )

//###################################################

local function animatorCam( ply, pos, angles, fov )
    if !animationFinder and !animationCreator then return end

    local view = {}

    local t = CurTime()
    local x = math.sin(t)
    local y = math.cos(t)
    local plyPos = ply:GetPos() + Vector(0,0,35)
    local lastAng = Angle()

    view.origin = plyPos + lastAng:Forward() * - 600 --+ Vector(x,y,0) * 100

    local plyDir = plyPos - view.origin
    plyDir:Normalize()

    view.angles = lastAng --plyDir:Angle()
    view.fov = fov
    view.drawviewer = true

    return view
end

hook.Add( "CalcView", "MyCalcView", animatorCam )

return animator
