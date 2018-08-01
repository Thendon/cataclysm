_G.ele_scoreboard = ele_scoreboard or {}

local teams = {}
teams[TEAM_BLACK] = Material("element/ui/black.png")
teams[TEAM_WHITE] = Material("element/ui/white.png")

local playerList = function( panel )
    players = team.GetPlayers(panel.team)
    panel.lastPlayers = panel.lastPlayers or {}
    panel.dermas = panel.dermas or {}
    if table.Count(players) == table.Count(panel.lastPlayers) then return end

    for k, derma in next, panel.dermas do
        derma:Remove()
    end

    local width = panel:GetWide()
    local height = panel:GetTall()
    local w, y, h = width * 0.8, 64, 64
    local max = height / (h + 8) - 2
    local x = width * 0.1

    table.sort(players, function( a, b )
        return a:Frags() > b:Frags()
    end)

    local counter = 1
    for k, ply in next, players do
        local derma = TDLib("DPanel", panel)
        derma:SetPos(x,y)
        derma:SetSize(w,h)
        derma:ClearPaint()

        local class = TDLib("DImage", derma)
        class:SetMaterial(player_manager.RunClass(ply, "GetClassIcon"))
        class:SetSize( h, h )

        --local color = GAMEMODE:GetEnemyTeamColor(ply)
        local color = team.GetColor(ply:Team())
        local font = "fujimaru_small"

        local name = TDLib("DLabel", derma)
        local size = w * 0.8
        name:SetText(ply:GetName())
        name:SetFont(font)
        name:SetPos(h,0)
        name:SetSize(size, h)
        name:SetTextColor(color)

        local frags = TDLib("DLabel", derma)
        frags:SetText(ply:Frags())
        frags:SetFont(font)
        frags:SetPos(h + size,0)
        frags:SetSize(w-h, h)
        frags:SetTextColor(color)

        table.insert(panel.dermas, derma)
        y = y + h + 8
        counter = counter + 1
        if (counter > max) then break end
    end

    panel.lastPlayers = players
end

local derma

function ele_scoreboard:Show()
    if IsValid(derma) then
        derma:Remove()
    end

    local w, h = ScrW() * 0.5, ScrH() - 0

    derma = TDLib("DPanel")
    derma:ClearPaint()
    derma:Blur()
    derma:SetSize(w, h)
    derma:SetPos(w * 0.5, 0)
    derma:FadeIn(0.1)

    local black = TDLib("DPanel", derma)
    black:ClearPaint()
    black:SetSize(w, h * 0.5)
    --black:Background(_COLOR.BLACK)
    black.team = TEAM_BLACK
    black.Think = playerList

    local white = TDLib("DPanel", derma)
    white:ClearPaint()
    white:SetPos(0, h * 0.5)
    white:SetSize(w, h * 0.5)
    --white:Background(_COLOR.WHITE)
    white.team = TEAM_WHITE
    white.Think = playerList

    local size = 128
    local wins = round_manager.GetWins()
    local offset = w * 0.8 / wins
    for teamID, material in next, teams do
        local score = team.GetScore(teamID)
        for j = 0, wins - 1 do
            local point = TDLib("DImage", derma)
            point:SetPos(w * 0.1 + j * offset, h * 0.5 - size * 0.5)
            point:SetSize( size, size )
            point:SetMaterial( material )
            point:SetAlpha( score > j and 255 or 25 )
            point.lastPaint = CurTime()
            point.ang = 0
            function point:Paint()
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
        end
    end
end

function ele_scoreboard:Hide()
    if IsValid(derma) then
        derma:Remove()
    end
    derma = nil
end

function ele_scoreboard:Hidden()
    return derma == nil
end