local PANEL = {}

AccessorFunc( PANEL, "key", "Key" )

function PANEL:Init()
    self.icon = vgui.Create("DImage", self)
    self.icon:SetPos( 0,0 )
    self.icon.fraction = 0
    self.icon.Paint = function( pnl )
        local w, h = pnl:GetSize()
        local f = 1 - pnl.fraction
        local o = f * h

        surface.SetMaterial( pnl:GetMaterial() )
        if f == 1 then
            surface.SetDrawColor( _COLOR.FULL )
        else
            surface.SetDrawColor( _COLOR.WHITEFADE )
        end

        surface.DrawTexturedRectUV( 0, h - o, w, o, 0, 1 - f, 1, 1)

        local fuel = self:GetFuel()
        if fuel == -1 then return end
        o = fuel * h
        surface.SetDrawColor( _COLOR.BLACKFADE2 )
        surface.DrawTexturedRectUV( 0, 0, w, h - o, 0, 0, 1, 1 - fuel )
    end

    self.keyImage = vgui.Create("DImage", self)
    self.keyImage:SetPos( 0,0 )

    self.label = vgui.Create("DLabel", self)
    self.label:SetPos( 0,0 )
    self.label:SetFont("fujimaru")
    self.label:SetTextColor(_COLOR.BLACK)
    self.label:SetText("")

    self:SetFuel( -1 )
end

function PANEL:PerformLayout(w, h)
    self.icon:SetSize(w, h)
    self.keyImage:SetSize(w,h)
    self.label:SetSize(w * 2, h)
    --self.loading:SetSize(w, h)
    local letters = string.len(self:GetText())
    wOffset = letters * 13
    hOffset = letters > 1 and 30 or 0
    self.label:SetPos(w * 0.5 - wOffset, h * 0.1 + hOffset)
end

function PANEL:SetCooldown( fraction )
    self.icon.fraction = fraction
end

function PANEL:SetFuel( fraction )
    self.icon.fuel = fraction
end

function PANEL:GetFuel( fraction )
    return self.icon.fuel
end

function PANEL:Flash( level )
    //TODO
end

function PANEL:Paint(w, h)
end

function PANEL:SetMaterial( mat )
    self.icon:SetMaterial( mat )
    self:SetFuel( -1 )
end

function PANEL:GetMaterial()
    return self.icon:GetMaterial()
end

function PANEL:SetMaterial2( mat )
    self.keyImage:SetMaterial( mat )
end

function PANEL:GetMaterial2()
    return self.keyImage:GetMaterial()
end

function PANEL:SetImage( image )
    self.icon:SetImage( image )
end

function PANEL:GetImage()
    return self.icon:GetImage()
end

function PANEL:SetText( text )
    self.label:SetText( text )

    if ( string.len(text) > 1 ) then
        self.label:SetFont("fujimaru_small")
    end
end

function PANEL:GetText()
    return self.label:GetText()
end

derma.DefineControl("DSkill", "Skill for element gamemode", PANEL, "DPanel")