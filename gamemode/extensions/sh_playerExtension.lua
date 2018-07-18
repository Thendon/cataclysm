local player = FindMetaTable( "Player" )

function player:SetClassPick( class )
    self.classPick = class
end

function player:GetClassPick()
    return self.classPick or "fire"
end