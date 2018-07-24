include("sh_skill.lua")

function Skill:Activate( ply )
end

function Skill:CleverCast( pressing )
    if (!self:GetCleverCast()) then return true end

    local trace = LocalPlayer():GetEyeTrace()

    ecall(self.Stage0, self, trace)

    if (self:GetCleverTarget() == Skill.TARGET.PLAYER) then
        return skill_manager.CleverCastPlayer( pressing, trace )
    elseif (self:GetCleverTarget() == Skill.TARGET.PLAYERLOCK) then
        return skill_manager.CleverLockPlayer( pressing, trace, self:GetRange(), self:GetLockrange() )
    end
    return skill_manager.CleverCastWorld( pressing, trace )
end