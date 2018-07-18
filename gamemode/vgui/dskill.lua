local PANEL = {}

AccessorFunc( PANEL, "key", "Key" )

function PANEL:Init()
    self.icon = TDLib("DImage", self)
    self.icon:SetPos( 0,0 )

    --[[self.loading = TDLib("DImage", self)
    self.loading:SetPos( 0,0 )
    --self.loading:SetBackgroundColor(_COLOR.FADE)
    --mat_Add:SetTexture("$basetexture", )
    self.loading:SetMaterial(mat_Add)]]

    self.label = TDLib("DLabel", self)
    self.label:SetPos( 0,0 )
    self.label:SetFont("fujimaru")
    self.label:SetTextColor(_COLOR.BLACK)
end

function PANEL:PerformLayout(w, h)
    self.icon:SetSize(w, h)
    self.label:SetSize(w * 2, h)
    --self.loading:SetSize(w, h)
    local letters = string.len(self:GetText())
    wOffset = letters * 13
    hOffset = letters > 1 and 30 or 0
    self.label:SetPos(w * 0.5 - wOffset, h * 0.1 + hOffset)
end

function PANEL:SetCooldown( level )
    level = 1 - level
    self:SetAlpha( level * level * 255 )

    --local _, h = self.loading:GetSize()
    --self.loading:SetPos(0, -h * (1 - level))
end

function PANEL:Flash( level )
    //TODO
end

function PANEL:Paint(w, h)
end

function PANEL:SetMaterial( mat )
    self.icon:SetMaterial( mat )
end

function PANEL:GetMaterial()
    self.icon:GetMaterial()
end

function PANEL:SetImage( image )
    self.icon:SetImage( image )
end

function PANEL:GetImage()
    self.icon:GetImage()
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