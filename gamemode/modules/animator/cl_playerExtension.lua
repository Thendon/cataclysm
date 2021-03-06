local player = FindMetaTable( "Player" )

function player:PlayAnimation( anim )
    if (self.anim and !self.anim.interruptible) then return end
    self.animState = 0

    if (isstring(anim)) then
        anim = AnimationManager.GetAnimation( anim )
    end

    if (!anim) then error("animation " .. tostring(anim) .. " invalid!") end
    self.anim = anim
end

function player:StopAnimation()
    if !self:AnimationRunning() then return end

    self.animState = self.anim:GetLastStateStart()
end

function player:AnimationRunning()
    return self.anim and true or false
end

function player:UpdateAnimation()
    if !self.anim then return end

    self.animState = self.animState + FrameTime() * self.anim.speed

    local animID, animWeight, sound = self.anim:GetInfos( self.animState )
    if ( animID == -1 ) then self.anim = nil return end
    if ( sound ) then self:EmitSound(sound) end

    self:AnimRestartGesture( GESTURE_SLOT_CUSTOM, animID, true )
    self:AnimSetGestureWeight( GESTURE_SLOT_CUSTOM, math.abs(animWeight) )
end