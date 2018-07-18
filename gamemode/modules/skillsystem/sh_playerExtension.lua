local player = FindMetaTable( "Player" )

if CLIENT then
    function player:CastSkill( key, pressing )
        return self.skills[key]:CleverCast( pressing )
    end

    function player:UseSkill( key, pressing )
        if !self:CanActivateSkill( key ) then return end

        local ret = self:CastSkill( key, pressing )
        if (!ret) then return end

        if (istable(ret)) then
            self:ActivateSkill( key, ret )
        else
            self:ActivateSkill( key )
        end
    end

    function player:ActivateSkill( key, cleverData )
        netstream.Start("player:UseSkill", key, cleverData )
    end

    function player:ActivatedSkill(key, timestamp)
        self.nextUse[key] = timestamp - 0.1
    end

    netstream.Hook("player:ActivatedSkill", function( key, timestamp )
        LocalPlayer():ActivatedSkill( key, timestamp )
    end)
end

if SERVER then
    function player:UseSkill( key, cleverData )
        if !self:CanActivateSkill( key ) then return end

        self:ActivateSkill( key, cleverData )
    end

    netstream.Hook("player:UseSkill", function( ply, key, cleverData )
        ply:UseSkill( key, cleverData )
    end)

    function player:ActivateSkill( key, cleverData )
        self.skills[key]:Activate( self, cleverData )

        self.nextUse[key] = CurTime() + self.skills[key].cooldown
        netstream.Start( self, "player:ActivatedSkill", key, self.nextUse[key] )
    end
end

function player:CanActivateSkill( key )
    if (!self:Alive()) then return false end
    if (SERVER and self:IsSilenced()) then return false end
    if self:GetCooldown( key ) > 0 then return false end
    if (!self.skills[key]:CanBeActivated( self )) then return false end
    return true
end

function player:SkillNextUse( key )
    self.nextUse = self.nextUse or {}
    self.nextUse[key] = self.nextUse[key] or 0

    return self.nextUse[key]
end

function player:GetCooldown( key )
    return math.Clamp((self:SkillNextUse( key ) - CurTime()) / self.skills[key].cooldown, 0, 1)
end

function player:HandSwitcher()
    self.hand = self.hand or false
    self.hand = !self.hand
    return self.hand
end