local UI = ElementUI or {}

local keyStrings = {}
keyStrings[KEY_Q] = "Q"
keyStrings[KEY_E] = "E"
keyStrings[KEY_R] = "R"
keyStrings[KEY_LSHIFT] = "Shift"
keyStrings[MOUSE_LEFT] = "Left"
keyStrings[MOUSE_RIGHT] = "Right"

local keyMaterials = {}
keyMaterials[KEY_Q] = Material("element/keys/q.png")
keyMaterials[KEY_E] = Material("element/keys/e.png")
keyMaterials[KEY_R] = Material("element/keys/r.png")
keyMaterials[KEY_LSHIFT] = Material("element/keys/shift.png")
keyMaterials[MOUSE_LEFT] = Material("element/keys/left.png")
keyMaterials[MOUSE_RIGHT] = Material("element/keys/right.png")

local skillw, skillh = 128, 128

function UI.Init()
    if (IsValid(UI.derma)) then UI.derma:Remove() end
    UI.derma = TDLib("DPanel")
    UI.skillBar = TDLib("DPanel", UI.derma)

    local scrw, scrh = ScrW(), ScrH()
    UI.derma:SetSize(scrw, scrh)
    UI.derma:ClearPaint()
    UI.skillBar:SetPos( 64, scrh - 256 )
    UI.skillBar:ClearPaint()

    local i = 0
    skillo = skillw + 16
    UI.CreateSkill(KEY_Q, skillo * i, 0)
    i = i + 1
    UI.CreateSkill(KEY_E, skillo * i, 0)
    i = i + 1
    UI.CreateSkill(KEY_LSHIFT, skillo * i, 0)
    i = 2
    UI.CreateSkill(MOUSE_RIGHT, scrw - skillo * i, 0)
    i = i + 1
    UI.CreateSkill(MOUSE_LEFT, scrw - skillo * i, 0)

    UI.skillBar:SetSize(scrw, skillh)
end

local function UpdateSkill( panel )
    if LocalPlayer():IsSpectator() then
        panel:SetAlpha(0)
        return
    end

    local key = panel:GetKey()
    local icon = skill_manager.GetSkill(LocalPlayer().skills[key]).icon
    panel:SetAlpha(255)

    if (icon != panel:GetMaterial()) then
        panel:SetMaterial( icon )
    end
    panel:SetCooldown( LocalPlayer():GetCooldown( key ) )
end

function UI.CreateSkill(key, x, y)
    --local skill = skill_manager.GetSkill(LocalPlayer().skills[key])

    local panel = TDLib("DSkill", UI.skillBar)
    panel:SetKey( key )
    --panel:SetMaterial( skill.icon )
    --skill:SetText( keyStrings[key] )
    panel:SetMaterial2( keyMaterials[key] )
    panel:SetPos( x, y )
    panel:SetSize( skillw, skillh )
    panel.Think = UpdateSkill
end

hook.Add("FinishedLoading", "UIInit", UI.Init)
hook.Add("OnReloaded", "UIInit", UI.Init)

_G.ElementUI = UI