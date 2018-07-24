local entity = FindMetaTable( "Entity" )

function entity:ReachVelocity( velocity )
    local physObj = self:GetPhysicsObject()
    if (!IsValid(physObj)) then return end

    velocity = velocity - self:GetVelocity()

    if self:IsPlayer() then
        self:SetVelocity( velocity )
        return
    end

    physObj:AddVelocity(velocity)
end
