local hpLerpSpeed = 0.4

local function CalcHealthFactor( ply )
    ply.lastHealthFactor = ply.lastHealthFactor or 1
    local actualHP = math.Clamp(ply:Health() / ply:GetMaxHealth(), 0, 1)

    ply.lastHealthFactor = Lerp(hpLerpSpeed, ply.lastHealthFactor, actualHP)
    return ply.lastHealthFactor
end

local function DrawPlayerInfos(x,y,w,h, ply, color)
    surface.SetDrawColor( color )
    surface.DrawRect(x, y - h * 0.2, w, h + h * 0.4)

    local width = math.floor(w * (1 - CalcHealthFactor(ply)))
    surface.SetDrawColor( _COLOR.RED )
    surface.DrawRect(x + w - width,y, width,h)
end

function GM:DrawPlayerHealthbar(ply)
    local x,y = -25, -5
    local w,h = 50, 5
    local teamColor = team.GetColor(ply:Team())

    DrawPlayerInfos(x,y,w,h, ply, teamColor)
end

function GM:PaintHealthbar()
    local ply = LocalPlayer()
    local x,y = 64, ScrH() - 96
    local w,h = 500, 50
    local teamColor = team.GetColor(ply:Team())

    DrawPlayerInfos( x,y,w,h, ply, teamColor )

    surface.SetDrawColor( _COLOR.WHITE )
    surface.SetMaterial(player_manager.RunClass(ply, "GetClassIcon"))
    surface.DrawTexturedRect(x - 50 ,y - 50, 128,128)
end

function GM:DrawPlayerClass(ply)
    local x,y = -25, -5
    surface.SetDrawColor( _COLOR.WHITE )
    surface.SetMaterial(player_manager.RunClass(ply, "GetClassIcon"))
    surface.DrawTexturedRect(x - 15, y - 5, 16,16)
end

local teams = {} --TODO move this into vgui
teams[TEAM_BLACK] = Material("element/ui/black.png")
teams[TEAM_WHITE] = Material("element/ui/white.png")

function GM:PaintRoundState()
    local width = 500
    local x, y = ScrW() * 0.5 - width * 0.5, 0

    local name = round_manager.GetStateName()
    local time = round_manager.GetStateTimeLeft()
    local minutes = math.floor(time / 60)
    local seconds = math.floor(time % 60)
    if seconds < 10 then seconds = 0 .. seconds end

    --draw.RoundedBox(0, x - 50,y, width + 100, 100, _COLOR.FADE)
    draw.DrawText( name, "fujimaru", x, y, _COLOR.FULL, TEXT_ALIGN_LEFT )
    local color = time < 6 and _COLOR.RED or time < 11 and _COLOR.YELLOW or _COLOR.FULL
    draw.DrawText( minutes .. ":" .. seconds, "fujimaru", x + 500, y, color, TEXT_ALIGN_RIGHT )
end

function GM:PaintRound()
    local x, y = ScrW() - 16, 0
    draw.DrawText( "Round: " .. round_manager:GetRound(), "fujimaru", x, y, _COLOR.FULL, TEXT_ALIGN_RIGHT )
end

function GM:PaintScore()
    local h = 32
    local o = 4
    local d = round_manager.GetWins()
    x, y = ScrW() * 0.5 - d * 0.5 * (h + o), 80

    surface.SetDrawColor(_COLOR.FADE_WHITE)
    for teamID, material in next, teams do
        local score = team.GetScore(teamID)
        for j = 0, d - 1 do
            if score > j then
                surface.SetDrawColor(_COLOR.FULL)
            else
                surface.SetDrawColor(_COLOR.FADE_WHITE)
            end
            surface.SetMaterial(material)
            surface.DrawTexturedRect(x + j % d * (h + o), y + math.floor(j / d) * (h + o), h, h)
        end
    end
end
