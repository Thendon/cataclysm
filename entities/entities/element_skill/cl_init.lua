include("shared.lua")

function ENT:Initialize()
	if !GAMEMODE:Loaded() then return end
	self:GetSkill():Activate( self, self:GetCaster() )
	self.alive = CurTime() - self:GetBirth()
	self.loaded = true
end

function ENT:Draw()
	local skill = self:GetSkill()
	ecall(skill.Draw, skill, self)
	if (self:GetInvisible()) then return end
	self:DrawModel()
end