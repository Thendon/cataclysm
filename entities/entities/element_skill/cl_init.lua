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

	if (self:GetCustomCollider()) then self.collider:Draw() end

	if (self.csmodel) then
		self:DrawClientModel()
		return
	end

	if (self:GetInvisible()) then return end
	self:DrawModel()
end

function ENT:Think()
	if (!self:Update()) then return end
	if (!IsValid(self:GetCaster())) then return end

	self:UpdateSkill( stage )

	return true
end

function ENT:DrawClientModel()
	self.csmodel:SetPos( self:GetPos() )
	self.csmodel:SetAngles( self:GetAngles() )
	self.csmodel:DrawModel()
end

function ENT:SetClientModel( model )
	self.csmodel = ClientsideModel(model)
	self.csmodel:SetNoDraw(true)
end