
local AnimationManager = {}
local animations = {}

function AnimationManager.Add( animName, anim )
    animations[animName] = anim
end

function AnimationManager.GetAnimation( animName )
    return animations[animName]
end

_G.AnimationManager = AnimationManager