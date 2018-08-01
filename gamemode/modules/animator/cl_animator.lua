//###################################################
//SUPER SLOPPY ANIMATOR BY THENDON.EXE, ENJOY :3
//###################################################

--true false (for cpy paste lol i m lazy k)

local camDistance = 100
local camRotation = false

local animationFinder = false --Scroll through usable acts

local animationCreator = false --Loop Animation
local animationToLoop = "shoot_stone"

local justCam = false
//###################################################
// LOOPER
//###################################################

local function animatePlayerConstantly(ply)
    --for k, v in next, player.GetAll() do
        if (ply:AnimationRunning()) then return end
        ply:PlayAnimation( AnimationManager.GetAnimation( animationToLoop ) )
    --end
end

hook.Add("Think", "animator", function()
    if (!animationCreator) then return end

    for k, v in next, player.GetAll() do
        animatePlayerConstantly( v )
    end
end)

//###################################################
// FINDER
//###################################################

_G.animLoop = _G.animLoop or VALID_ACTS[1]
local animWeight = 1
local animPlaying = true
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
// CAM
//###################################################

local function animatorCam( ply, pos, angles, fov )
    if !justCam and !animationFinder and !animationCreator then return end

    local view = {}

    local t = CurTime()
    local x = math.sin(t)
    local y = math.cos(t)
    local plyPos = ply:GetPos() + Vector(0,0,35)
    local lastAng = Angle()

    view.origin = plyPos + (camRotation and Vector(x,y,0) or lastAng:Forward() * (-1)) * camDistance

    local plyDir = plyPos - view.origin
    plyDir:Normalize()

    view.angles = camRotation and plyDir:Angle() or lastAng
    view.fov = fov
    view.drawviewer = true

    return view
end

hook.Add( "CalcView", "MyCalcView", animatorCam )

return animator
