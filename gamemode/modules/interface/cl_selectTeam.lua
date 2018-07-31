local teamMenu = {}

function teamMenu:Toggle()
    if (IsValid(self.derma)) then
        self:Close()
    else
        if (cataUI.IsActive()) then return end
        self:Open()
    end
end

local teamSelect = function( panel )
    if panel:IsHovered() and input.IsMouseDown(MOUSE_LEFT) then
        player_manager.RequestTeamSwitch( panel.team )
        teamMenu:Close()
    end
end

local playerList = function( panel )
    players = team.GetPlayers(panel.team)
    panel.lastPlayers = panel.lastPlayers or {}
    panel.dermas = panel.dermas or {}
    if table.Count(players) == table.Count(panel.lastPlayers) then return end

    for k, derma in next, panel.dermas do
        derma:Remove()
    end

    local width = panel:GetWide()
    local w, y, h = width * 0.7 - 16, 16, 64
    local x = 0
    for k, ply in next, players do
        local derma = TDLib("DPanel", panel)
        derma:SetPos(x,y)
        derma:SetSize(w,h)
        derma:ClearPaint()
        derma:Background(_COLOR.INVIS)

        local class = TDLib("DImage", derma)
        class:SetMaterial(player_manager.RunClass(ply, "GetClassIcon"))
        class:SetSize( h, h )

        local label = TDLib("DLabel", derma)
        label:SetText(ply:GetName())
        label:SetFont("fujimaru")
        label:SetPos(h,0)
        label:SetSize(w-h, h)
        label:SetTextColor(GAMEMODE:GetEnemyTeamColor(ply))

        table.insert(panel.dermas, derma)
        y = y + h + 8
    end

    panel.lastPlayers = players
end

function teamMenu:Open()
    local scrw, scrh = ScrW(), ScrH()
    local scrwh = scrw * 0.5
    local panel = TDLib("DPanel")
    panel:SetSize(scrw, scrh)
    panel:ClearPaint()
    panel:FadeIn(0.1)

    local panelLeft = TDLib("DPanel", panel)
    panelLeft:SetSize(scrwh, scrh)
    panelLeft:ClearPaint()
    panelLeft:Background(_COLOR.WHITE)
    panelLeft:SetMouseInputEnabled(true)
    panelLeft.team = TEAM_WHITE
    panelLeft.Think = teamSelect

    local panelRight = TDLib("DPanel", panel)
    panelRight:SetSize(scrwh, scrh)
    panelRight:SetPos(scrwh, 0)
    panelRight:ClearPaint()
    panelRight:Background(_COLOR.BLACK)
    panelRight:SetMouseInputEnabled(true)
    panelRight.team = TEAM_BLACK
    panelRight.Think = teamSelect

    local ying = TDLib("DImage", panel)
    ying:SetPos(scrwh - 512, 0)
    ying:SetSize(1024, 1024)
    ying:SetImage("element/ui/ying.png")
    ying:SetMouseInputEnabled(false)
    ying.lastPaint = CurTime()
    ying.ang = 0
    function ying:Paint()
        self.deltaTime = CurTime() - self.lastPaint
        self.lastPaint = CurTime()
        local ranomizer = math.max(math.abs(math.cos(CurTime())), 0.5)
        self.ang = self.ang - self.deltaTime * ranomizer * 100

        local dw = self:GetWide()
        local dh = self:GetTall()

        surface.SetMaterial( self:GetMaterial() )
        surface.SetDrawColor( _COLOR.FULL )
        surface.DrawTexturedRectRotated( dw * 0.5, dh * 0.5, dw, dh, self.ang )
    end

    local listLeft = TDLib("DPanel", panel)
    listLeft:SetSize(scrwh * 0.7, scrh)
    listLeft:SetPos(scrwh * 0.3, 16)
    listLeft:ClearPaint()
    listLeft:SetMouseInputEnabled(false)
    listLeft.team = TEAM_WHITE
    listLeft.Think = playerList

    local listRight = TDLib("DPanel", panel)
    listRight:SetSize(scrwh * 0.7, scrh)
    listRight:SetPos(scrwh + scrwh * 0.3, 16)
    listRight:ClearPaint()
    listRight:SetMouseInputEnabled(false)
    listRight.team = TEAM_BLACK
    listRight.Think = playerList

    self.derma = panel
    cataUI.Opened( self.derma )
end

function teamMenu:Close()
    cataUI.Closed( self.derma )
    self.derma:Remove()
end

_G.teamSelection = teamMenu