ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Element Buff Zone"

AccessorFunc( ENT, "maxlive", "MaxLive", FORCE_INT )

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Type")
    self:NetworkVar("String", 0, "Particlename")

    self:SetMaxLive( 60 )
end

function ENT:Initialize()
    self:SetNoDraw(true)
    if CLIENT then self:GenerateParticles() end
end

function ENT:GenerateParticles()
    local name = self:GetParticlename()
    self:CreateParticleEffect(name, 0)
end

function ENT:Think()
    if CLIENT then return end

    if ( CurTime() > self.death ) then self:Remove() end
end

function ENT:SetMaxLive( maxlive )
    self.maxlive = maxlive
    self.death = CurTime() + maxlive
end