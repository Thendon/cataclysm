local player = FindMetaTable( "Player" )

local speedEpsilon = 500
local speedDamageFactor = 0.05
local waitAfterPhysHit = 0.02

local fallsounds = {
    Sound("player/damage1.wav"),
    Sound("player/damage2.wav"),
    Sound("player/damage3.wav")
}

local deathsounds = {
    Sound("player/death1.wav"),
    Sound("player/death2.wav"),
    Sound("player/death3.wav"),
    Sound("player/death4.wav"),
    Sound("player/death5.wav"),
    Sound("player/death6.wav")
}

local STATUS = {}
STATUS.SILENCED = 1
STATUS.CASTING = 2
STATUS.FALLIMMUNE = 3
STATUS.SLOWED = 4

speedEpsilon = speedEpsilon * speedEpsilon

function player:FinishedLoading()
    self.loaded = true
end

function player:Loaded()
    return self.loaded
end

function player:Move(mv)
    self.startVelocity = mv:GetVelocity()

    player_manager.RunClass(self, "CalcMoveSpeed")
end

function player:FinishMove(mv)
    local stopVelocity = mv:GetVelocity()
    local direction = stopVelocity - self.startVelocity

    local difference = direction:LengthSqr()
    if (difference < speedEpsilon) then return end

    local speed = math.sqrt(difference - speedEpsilon)

    self:HitWorld( speed, direction )
end

function player:HitWorld( speed, direction )
    if self:IsFallImmune() then
        self:SetFallImmune( false )
        return
    end
    if ((CurTime() - self:LastPhysHit()) < waitAfterPhysHit) then return end

    local damage = speed * speedDamageFactor

    local dmg = DamageInfo()
    dmg:SetDamageType(DMG_FALL)
    dmg:SetAttacker(game.GetWorld())
    dmg:SetInflictor(game.GetWorld())
    dmg:SetDamageForce(-direction:GetNormalized())
    dmg:SetDamage(damage)

    self:TakeDamageInfo(dmg)

    if damage > 5 then
        sound.Play(table.Random(fallsounds), self:GetPos(), 80, 100, 1)
    end
end

function player:OnDeath( inflictor, attacker )
    sound.Play(table.Random(deathsounds), self:GetPos(), 80, 100, 1)
end

function player:SetStatusTime( status, time )
    time = time or 0
    self.status = self.status or {}
    self.status[status] = CurTime() + time
end

function player:HasStatus( status )
    self.status = self.status or {}
    self.status[status] = self.status[status] or 0
    if (self.status[status] == 0) then return false end
    if (self.status[status] - CurTime() > 0) then return true end
    self.status[status] = 0
    return false
end

function player:IsSilenced()
    return self:HasStatus( STATUS.SILENCED )
end

function player:Silence( time )
    self:SetStatusTime( STATUS.SILENCED, time )
end

function player:Unsilence()
    self:SetStatusTime( STATUS.SILENCED )
end

function player:IsCasting()
    return self:HasStatus( STATUS.CASTING )
end

function player:SetCasting( time )
    self:SetStatusTime( STATUS.CASTING, time )
end

function player:IsFallImmune()
    return self:HasStatus( STATUS.FALLIMMUNE )
end

function player:SetFallImmune( time )
    self:SetStatusTime( STATUS.FALLIMMUNE, time )
end

function player:IsSlowed()
    return self:HasStatus( STATUS.SLOWED )
end

function player:Slow( time, factor )
    self:SetStatusTime( STATUS.SLOWED, time )
    self.slowFactor = factor
end

function player:GetSlowFactor()
    if (!self:IsSlowed()) then return 1 end
    return self.slowFactor
end

function player:LastPhysHit()
    return self.lastPhysHit or 0
end

function player:UpdateLastPhysHit()
    self:SetFallImmune( false )
    self.lastPhysHit = CurTime()
end

function player:PhysHit( velocity )
    self:UpdateLastPhysHit()
    self:SetVelocity( velocity )
end