ENT.Base = "base_entity"
ENT.Type = "anim"
ENT.PrintName = "Element Skill"
ENT.isskill = true

AccessorFunc( ENT, "maxlive", "MaxLive", FORCE_INT )

local function StageChange( ent, name, oldval, newval )
    ent.stage = newval
    if (!oldval) then return end
    local skill = ent:GetSkill()
    if (!skill) then print("fix me") return end //TODO
    ecall( skill["Transition" .. oldval], skill, ent )
end

function ENT:SetupDataTables()
    self.skill = nil --{}
    self.lastThink = CurTime()
    self.alive = 0 --maybe send alive scince
    self.stage = 1
    self:SetMaxLive( 60 )
    --immediately networked & reliable but no proxy
    self:NetworkVar("String", 0, "Skillname")
    self:NetworkVar("Entity", 0, "Caster")
    self:NetworkVar("Bool", 0, "Invisible")
    self:NetworkVar("Float", 0, "Birth")
    --faster? has proxys though
    self:SetNW2Int("stage", 1)
    self:SetNWVarProxy("stage", StageChange)
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

function ENT:Think()
    --if ( !self.skill.Think ) then return end
    if (!self.loaded) then return end

    local now = CurTime()
    self.deltaTime = now - self.lastThink
    self.alive = self.alive + self.deltaTime
    self.lastThink = now

    if (SERVER) then
        if ( self:GetRemoveOnDeath() and !self:GetCaster():Alive() ) then self:Remove() end
        if ( self.alive > self:GetMaxLive() ) then self:Remove() end
        if ( self:GetDestroyFlag() ) then self:Remove() end
        if ( self:GetRemoveOnWorldTrace() ) then self:CheckWorldTrace() end
        if ( self:GetCustomCollider() ) then self:CalcCustomCollisions() end
    end

    local stage = self:GetNW2Int("stage")
    if ( SERVER and self.skill.stages[stage] and self.alive > self.skill.stages[stage] ) then
        self:SetNW2Int("stage", stage + 1)
    end
    local skill = self:GetSkill()
    ecall(skill["Stage" .. stage], skill, self )

    self:NextThink( now )
    return true
end

function ENT:SetCustomCollider( collider )
    self.collider = collider
    self.collider:SetEntity( self )
    if SERVER and !self:GetTouchCaster() then
        self.collider:Filter( { self:GetCaster() } )
    end
    return self.collider
end

function ENT:GetCustomCollider()
    return self.collider
end

function ENT:CalcCustomCollisions()
    local hits = {}
    if self:GetTouchAllEnts() then
        hits = self.collider:EntitiesTouched()
    else
        hits = self.collider:PlayersTouched()
    end

    for _, hit in next, hits do
        self:Touch( hit.obj )
    end
end

function ENT:OnRemove()
    local skill = self:GetSkill()
    ecall(skill.OnRemove, skill, self)
end
