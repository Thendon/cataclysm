local classMenu = {}

function classMenu:Toggle()
    if (IsValid(self.derma)) then
        self:Close()
    else
        if (cataUI.IsActive()) then return end
        self:Open()
    end
end

local classImageSize = 256
local fadeSpeed = 0.1

function classMenu:GenerateClassImage( name, a, r, parentPanel )
    local midx = ScrW() * 0.5 - classImageSize * 0.5
    local midy = ScrH() * 0.5 - classImageSize * 0.5
    local x, y = math.cos(a) * r, math.sin(a) * r
    local classImg = TDLib("DImage", parentPanel)
    classImg:SetImage("element/classes/" .. name .. ".png")
    classImg:SetSize(classImageSize, classImageSize)
    classImg:SetPos(midx + x, midy + y)
    classImg:SetMouseInputEnabled(true)

    local current = player_manager.GetPlayerClass(LocalPlayer()) == "player_" .. name
    local picked = LocalPlayer():GetClassPick() == name
    local defaultAlpha = current and 255 or 50
    classImg:SetAlpha( defaultAlpha )

    function classImg:Think()
        local alpha = self:GetAlpha()
        local dest = defaultAlpha

        if current then
            dest = 255
        elseif picked then
            dest = math.Clamp( math.abs( math.sin( CurTime() * 5 ) ) * 255, defaultAlpha, 255)
        elseif self:IsHovered() then
            dest = 255
        end

        if self:IsHovered() and input.IsMouseDown(MOUSE_LEFT) then
            player_manager.RequestClassSwitch( name )
            classMenu:Close()
        end

        alpha = Lerp(fadeSpeed, alpha, dest)
        self:SetAlpha(alpha)
    end
end

function classMenu:Open()
    local scrw, scrh = ScrW(), ScrH()
    local panel = TDLib("DPanel")
    panel:SetSize(scrw, scrh)
    panel:ClearPaint()
    panel:Background(Color(0, 0, 0, 200))
    panel:Blur()

    local a = -math.pi
    local r = scrh * 0.25
    local step = math.pi * 0.5

    a = a + step
    self:GenerateClassImage("fire", a, r, panel)
    a = a + step
    self:GenerateClassImage("air", a, r, panel)
    a = a + step
    self:GenerateClassImage("water", a, r, panel)
    a = a + step
    self:GenerateClassImage("earth", a, r, panel)

    self.derma = panel
    cataUI.Opened( self.derma )
end

function classMenu:Close()
    cataUI.Closed( self.derma )
    self.derma:Remove()
end

_G.classSelection = classMenu