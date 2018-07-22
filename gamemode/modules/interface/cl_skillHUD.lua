local UI = ElementUI or {}

local keyStrings = {}
keyStrings[KEY_Q] = "Q"
keyStrings[KEY_E] = "E"
keyStrings[KEY_R] = "R"
keyStrings[MOUSE_LEFT] = "Left"
keyStrings[MOUSE_RIGHT] = "Right"

local keyMaterials = {}
keyMaterials[KEY_Q] = Material("element/skills/Q.png")
keyMaterials[KEY_E] = Material("element/skills/E.png")
keyMaterials[KEY_R] = Material("element/skills/R.png")
keyMaterials[MOUSE_LEFT] = Material("element/skills/Left.png")
keyMaterials[MOUSE_RIGHT] = Material("element/skills/Right.png")

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
    UI.CreateSkill(KEY_R, skillo * i, 0)
    i = 2
    UI.CreateSkill(MOUSE_RIGHT, scrw - skillo * i, 0)
    i = i + 1
    UI.CreateSkill(MOUSE_LEFT, scrw - skillo * i, 0)

    UI.skillBar:SetSize(scrw, skillh)
end

local function UpdateSkill( panel )
    local key = panel:GetKey()
    if (LocalPlayer().skills[key].icon != panel:GetMaterial()) then
        panel:SetMaterial( LocalPlayer().skills[key].icon )
    end
    panel:SetCooldown( LocalPlayer():GetCooldown( key ) )
end

function UI.CreateSkill(key, x, y)
    local skill = TDLib("DSkill", UI.skillBar)
    skill:SetKey( key )
    skill:SetMaterial( LocalPlayer().skills[key].icon )
    --skill:SetText( keyStrings[key] )
    skill:SetMaterial2( keyMaterials[key] )
    skill:SetPos( x, y )
    skill:SetSize( skillw, skillh )
    skill.Think = UpdateSkill
end

hook.Add("FinishedLoading", "UIInit", UI.Init)
hook.Add("OnReloaded", "UIInit", UI.Init)

_G.ElementUI = UI