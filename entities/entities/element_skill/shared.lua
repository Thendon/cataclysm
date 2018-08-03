ENT.Base = "base_entity"
ENT.Type = "anim"
ENT.PrintName = "Element Skill"
ENT.isskill = true

AccessorFunc( ENT, "maxlive", "MaxLive", FORCE_INT )

local function StageChange( ent, name, oldval, newval )
    ent.stage = newval
    if (!oldval) then return end
    local skill = ent:GetSkill()
    ecall( skill["Transition" .. oldval], skill, ent )
end

function ENT:SetupDataTables()
    self.skill = nil --{}
    self.lastThink = CurTime()
    self.alive = 0 --Use Timestamp instead TODO
    self.stage = 1
    self:SetMaxLive( 60 )
    --immediately networked & reliable but no proxy
    self:NetworkVar("String", 0, "Skillname")
    self:NetworkVar("Entity", 0, "Caster")
    self:NetworkVar("Entity", 1, "Target")
    self:NetworkVar("Bool", 0, "Invisible")
    self:NetworkVar("Float", 0, "Birth")
    --faster? has proxys though
    self:SetNW2Int("stage", 1)
    self:SetNWVarProxy("stage", StageChange)

    if SERVER then
        self.touchCooldown = {}
        self.casterCollision = false
        self.removeOnWorldTrace = false
        self.touchPlayerOnce = false
        self.touchCaster = false
        self.touchRate = 1
        self.collidePlayers = true
        self.collideSkills = false
        self.touchedPlayers = {}
        self.touching = {}
        self.dots = {}
    end

    self:DrawShadow( false )
end

function ENT:SetSkill( skill )
    self.skill = skill
    if SERVER then
        self:SetSkillname(skill.name)
    end
end

function ENT:GetSkill()
    if (!self.skill) then
        self.skill = skill_manager.GetSkill(self:GetSkillname())
    end
    return self.skill
end

function ENT:Update( stage )
    if (!self.loaded) then return false end

    local now = CurTime()
    self.deltaTime = now - self.lastThink
    self.alive = self.alive + self.deltaTime
    self.lastThink = now

    self:NextThink( now )
    return true
end

function ENT:UpdateSkill( stage )
    stage = stage or self:GetNW2Int("stage")
    local skill = self:GetSkill()
    ecall(skill["Stage" .. stage], skill, self )

    return skill
end

function ENT:SetCustomCollider( collider )
    self.collider = collider
    self.collider:SetEntity( self )
    local filter = { self }
    if SERVER and !self:GetTouchCaster() then
        table.insert(filter, self:GetCaster())
    end
    self.collider:Filter( filter )
    return self.collider
end

function ENT:GetCustomCollider()
    return self.collider
end

function ENT:OnRemove()
    local skill = self:GetSkill()
    ecall(skill.OnRemove, skill, self)
end
