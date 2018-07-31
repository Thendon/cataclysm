ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Element Skill Child"
ENT.isskill = true

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Invisible")
end

function ENT:Initialize()
end

function ENT:GetSkill()
    return self:GetParent():GetSkill()
end

function ENT:GetCaster()
    return self:GetParent():GetCaster()
end

function ENT:Draw()
    if self:GetInvisible() then return end
    self:DrawModel()
end