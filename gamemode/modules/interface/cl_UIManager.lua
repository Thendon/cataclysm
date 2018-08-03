local cataUI = cataUI or {}

cataUI.opened = cataUI.opened or {}

for menu, _ in next, cataUI.opened do
    cataUI.opened[menu] = nil
    menu:Remove()
end

local mouseActive = false
local lastMousePos

function cataUI.Opened( panel )
    cataUI.opened[panel] = true

    cataUI.ActivateMouse()
end

function cataUI.Closed( panel )
    cataUI.opened[panel] = nil

    if cataUI.IsActive() then return end

    cataUI.DeactivateMouse()
end

function cataUI.IsActive()
    return table.Count(cataUI.opened) > 0
end

function cataUI.GetLastMousePos()
    if !lastMousePos then cataUI.SetLastMousePos( input.GetCursorPos() ) end
    return lastMousePos.x, lastMousePos.y
end

function cataUI.SetLastMousePos(x, y)
    if !lastMousePos then lastMousePos = {} end
    lastMousePos.x = x
    lastMousePos.y = y
end

function cataUI.ActivateMouse()
    if (mouseActive) then return end
    mouseActive = true
    gui.EnableScreenClicker( true )
    input.SetCursorPos( cataUI.GetLastMousePos() )
end

function cataUI.DeactivateMouse()
    if (!mouseActive) then return end
    mouseActive = false
    cataUI.SetLastMousePos( input.GetCursorPos() )
    gui.EnableScreenClicker( false )
end

_G.cataUI = cataUI