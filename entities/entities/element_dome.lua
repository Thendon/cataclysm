ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Element Preparing Dome"

function ENT:SetupDataTables()
end

function ENT:Initialize()
    self:SetModel("models/props_phx/construct/glass/glass_dome360.mdl")
    self:SetModelScale( 22 )
    self:DrawShadow(false)
end

function ENT:Draw()
    self:DrawModel()
end