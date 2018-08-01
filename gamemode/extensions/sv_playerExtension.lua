local player = FindMetaTable( "Player" )

local speedEpsilon = 500
local speedDamageFactor = 0.05
local waitAfterPhysHit = 0.05
local assumeHitInflictor = 10

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
STATUS.SKILLIMMUNE = 4
STATUS.FALLDAMPED = 5
STATUS.SLOWED = 6
STATUS.ROOTED = 7

speedEpsilon = speedEpsilon * speedEpsilon

function player:FinishedLoading()
    self.loaded = true
end

function player:Loaded()
    return self.loaded
end

function player:Move(mv)
    player_manager.RunClass(self, "CalcMoveSpeed")
end

function player:FinishMove(mv)
    self.lastVelocity = self.lastVelocity or Vector()
    self.lastOnGround = self.lastOnGround or true

    local velocity = mv:GetVelocity()
    local veloLength = velocity:LengthSqr()
    local lastLength = self.lastVelocity:LengthSqr()

    local direction = velocity - self.lastVelocity
    self.lastVelocity = velocity

    --[[local lastOnGround = self.lastOnGround
    self.lastOnGround = self:OnGround()

    if self.lastOnGround and lastOnGround then return end]]
    if veloLength >= lastLength then return end

    local difference = lastLength - veloLength
    if (difference < speedEpsilon) then return end
    print(direction, difference)

    local damper = self:GetFallDamper()
    if damper then
        difference = difference * damper
        if (difference < speedEpsilon) then return end
    end

    local speed = math.sqrt(difference - speedEpsilon)
    self:HitWorld( speed, direction )
end

function player:HitWorld( speed, direction )
    if !self:Alive() then return end

    if self:IsFallImmune() then return end
    if ((CurTime() - self:LastPhysHit()) < waitAfterPhysHit) then return end
    self:UpdateLastPhysHit()

    local damage = speed * speedDamageFactor

    local dmg = DamageInfo()
    dmg:SetDamageType(DMG_GENERIC) --DMG_FALL
    dmg:SetAttacker(game.GetWorld())

    local lastHit = self:LastHit()
    if (lastHit and lastHit.time > self:LastDeath() and lastHit.time + assumeHitInflictor > CurTime()) then
        dmg:SetInflictor(lastHit.inflictor)
    else
        dmg:SetInflictor(game.GetWorld())
    end
    dmg:SetDamage(damage)

    self:TakeDamageInfo(dmg)

    local now = CurTime()
    self.nextFallSound = self.nextFallSound or now
    if damage > 5 and self.nextFallSound < now then
        print("MAKE FALL SOUND")
        self.nextFallSound = now + 1
        sound.Play(table.Random(fallsounds), self:GetPos(), 80, {90, 110}, 1)
    end
end

function player:LastPhysHit()
    return self.lastPhysHit or 0
end

function player:UpdateLastPhysHit()
    self:SetFallImmune( false )
    self.lastPhysHit = CurTime()
end

--[[function player:PhysHit( velocity )
    self:UpdateLastPhysHit()
    self:SetVelocity( velocity )
end]]

function player:TakeSkillDamage( dmgInfo, dmgType )
    if self:IsSkillImmune() then return end

    self:TakeDamageInfo( dmgInfo )
    self:SetLastHit( dmgInfo )
    dmgType:Hit( self )
end

function player:Heal( amount, type )
    local hp = math.Clamp(self:Health() + amount, 0, self:GetMaxHealth())
    self:SetHealth( hp )
    type:Hit( self )
end

function player:OnDeath( inflictor, attacker )
    sound.Play(table.Random(deathsounds), self:GetPos(), 80, 100, 1)
    skill_manager.PlayerDeath(self)
    self:ResetStatus()
    self:SetLastDeath( CurTime() )
end

function player:ResetStatus()
    self.status = self.status or {}

    for k, status in next, self.status do
        self.status[k] = 0
    end
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

function player:Silence( time )
    self:SetStatusTime( STATUS.SILENCED, time )
end

function player:Unsilence()
    self:SetStatusTime( STATUS.SILENCED )
end

function player:IsSilenced()
    return self:HasStatus( STATUS.SILENCED )
end
--[[
function player:SetCasting( time )
    self:SetStatusTime( STATUS.CASTING, time )
end

function player:IsCasting()
    return self:HasStatus( STATUS.CASTING )
end
]]
function player:SetSkillImmune( time )
    self:SetStatusTime( STATUS.SKILLIMMUNE, time )
end

function player:IsSkillImmune()
    return self:HasStatus( STATUS.SKILLIMMUNE )
end

function player:SetFallImmune( time )
    self:SetStatusTime( STATUS.FALLIMMUNE, time )
end

function player:IsFallImmune()
    return self:HasStatus( STATUS.FALLIMMUNE )
end

function player:SetFallDamper( time, factor, factorFactor )
    self:SetStatusTime( STATUS.FALLDAMPED, time )
    self.fallFactor = factor
    self.fallFactorFactor = factorFactor or 1
end

function player:GetFallDamper()
    if (!self:IsFallDamped()) then return false end
    local fallFactor = self.fallFactor
    self.fallFactor = self.fallFactor * self.fallFactorFactor
    return math.Clamp(fallFactor,0,1)
end

function player:IsFallDamped()
    return self:HasStatus( STATUS.FALLDAMPED )
end

function player:Slow( time, factor )
    self:SetStatusTime( STATUS.SLOWED, time )
    self.slowFactor = factor
end

function player:GetSlowFactor()
    if (!self:IsSlowed()) then return 1 end
    return self.slowFactor
end

function player:IsSlowed()
    return self:HasStatus( STATUS.SLOWED )
end

function player:Root( time )
    self:SetStatusTime( STATUS.ROOTED, time )
    self.slowFactor = 0.001
end

function player:IsRooted()
    return self:HasStatus( STATUS.ROOTED )
end