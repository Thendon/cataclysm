_G.ele_scoreboard = ele_scoreboard or {}
ele_scoreboard.derma = ele_scoreboard.derma

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
        frags:SetText(ply:GetScore())
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

local smart_cast_guides = {}
smart_cast_guides[Skill.TARGET.PLAYERLOCK] = "Target: Player - You have to hold the key until you see a glowing player"
smart_cast_guides[Skill.TARGET.WORLD] = "Target: World - You have to hold the key until you see a glowing area"

local hold_guide = "Cast will be up until the key was released"

local function GenerateGuide( scrw, scrh, derma )
    local size = 128
    local offset = 16
    local key_offsets = {}
    key_offsets[KEY_Q] = { x = 0, y = 0 }
    key_offsets[KEY_E] = { x = size + offset, y = -200 }
    key_offsets[KEY_LSHIFT] = { x = 2 * size + 2 * offset, y = 0 }
    key_offsets[MOUSE_LEFT] = { x = scrw - offset * 3 - size * 3, y = -200 }
    key_offsets[MOUSE_RIGHT] = { x = scrw - offset * 2 - size * 2, y = 0 }

    for key, skillname in next, LocalPlayer().skills do
        local skill = skill_manager.GetSkill(skillname)
        local x, y = key_offsets[key].x, key_offsets[key].y
        x = x + 64
        y = y + scrh - 600
        local h = 160

        local text = skill:GetDescription()
        if skill:GetCleverCast() then
            text = text .. "\n\n" .. smart_cast_guides[skill:GetCleverTarget()]
            h = h + 64
        end

        if skill:GetCastUntilRelease() then
            text = text .. "\n\n" .. hold_guide
            h = h + 32
        end

        local guide = TDLib("DLabel", derma)
        guide:ClearPaint()
        guide:SetPos( x - offset * 3, y )
        guide:SetSize( 256, h )
        guide:SetFont( "Trebuchet24" ) --"fujimaru_small")
        guide:SetWrap( true )
        guide:SetTextColor(_COLOR.WHITEFADE)
        guide:SetText(text)

        local line = TDLib("DPanel", derma)
        line:ClearPaint()
        line:Background(_COLOR.WHITEFADE)
        line:SetPos( x + size * 0.5, y + h  )
        line:SetSize( 8, y - h - key_offsets[key].y * 2 - 128)
    end
end

function ele_scoreboard:Show()
    local derma = ele_scoreboard.derma

    if IsValid(derma) then
        derma:Remove()
    end

    local scrw, scrh = ScrW(), ScrH()
    local w, h = scrw * 0.4, scrh

    derma = TDLib("DPanel")
    derma:ClearPaint()
    derma:SetSize(scrw, scrh)

    local score = TDLib("DPanel", derma)
    score:ClearPaint()
    score:Blur()
    score:SetSize(w, h)
    score:SetPos(scrw * 0.5 - w * 0.5, 0)
    score:FadeIn(0.1)

    local black = TDLib("DPanel", score)
    black:ClearPaint()
    black:SetSize(w, h * 0.5)
    --black:Background(_COLOR.BLACK)
    black.team = TEAM_BLACK
    black.Think = playerList

    local white = TDLib("DPanel", score)
    white:ClearPaint()
    white:SetPos(0, h * 0.5)
    white:SetSize(w, h * 0.5)
    --white:Background(_COLOR.WHITE)
    white.team = TEAM_WHITE
    white.Think = playerList

    local size = 128
    local wins = round_manager.GetWins()
    local offset = w * 0.9 / wins
    for teamID, material in next, teams do
        local points = team.GetScore(teamID)
        for j = 0, wins - 1 do
            local point = TDLib("DImage", score)
            point:SetPos(w * 0.05 + j * offset, h * 0.5 - size * 0.5)
            point:SetSize( size, size )
            point:SetMaterial( material )
            point:SetAlpha( points > j and 255 or 25 )
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

    GenerateGuide( scrw, scrh, derma )

    ele_scoreboard.derma = derma
end

function ele_scoreboard:Hide()
    if IsValid(ele_scoreboard.derma) then
        ele_scoreboard.derma:Remove()
    end
    ele_scoreboard.derma = nil
end

function ele_scoreboard:Hidden()
    return ele_scoreboard.derma == nil
end