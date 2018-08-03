local HUD = HUD or {}

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

function HUD.Init()
    if (IsValid(HUD.derma)) then HUD.derma:Remove() end
    HUD.derma = TDLib("DPanel")
    HUD.skillBar = TDLib("DPanel", HUD.derma)

    local scrw, scrh = ScrW(), ScrH()
    HUD.derma:SetSize(scrw, scrh)
    HUD.derma:ClearPaint()
    HUD.skillBar:SetPos( 64, scrh - 256 )
    HUD.skillBar:ClearPaint()

    local i = 0
    skillo = skillw + 16
    HUD.CreateSkill(KEY_Q, skillo * i, 0)
    i = i + 1
    HUD.CreateSkill(KEY_E, skillo * i, 0)
    i = i + 1
    HUD.CreateSkill(KEY_LSHIFT, skillo * i, 0)
    i = 2
    HUD.CreateSkill(MOUSE_RIGHT, scrw - skillo * i, 0)
    i = i + 1
    HUD.CreateSkill(MOUSE_LEFT, scrw - skillo * i, 0)

    HUD.skillBar:SetSize(scrw, skillh)
end

local function UpdateSkill( panel )
    --[[if LocalPlayer():IsSpectator() then
        panel:SetAlpha(0)
        return
    end

    local key = panel:GetKey()
    local icon = skill_manager.GetSkill(LocalPlayer().skills[key]).icon
    panel:SetAlpha(255)]]

    local key = panel:GetKey()
    local icon = skill_manager.GetSkill(LocalPlayer().skills[key]).icon

    if (icon != panel:GetMaterial()) then
        panel:SetMaterial( icon )
    end
    panel:SetCooldown( LocalPlayer():GetCooldown( key ) )
end

function HUD.CreateSkill(key, x, y)
    local panel = TDLib("DSkill", HUD.skillBar)
    panel:SetKey( key )
    --skill:SetText( keyStrings[key] )
    panel:SetMaterial2( keyMaterials[key] )
    panel:SetPos( x, y )
    panel:SetSize( skillw, skillh )
    panel.Think = UpdateSkill
end

hook.Add("FinishedLoading", "UIInit", HUD.Init)
hook.Add("OnReloaded", "UIInit", HUD.Init)

_G.SkillHUD = HUD