_G.Capsule = Capsule or Class()
Capsule.iscapsule = true

AccessorFunc( Capsule, "pos1", "Pos1" )
AccessorFunc( Capsule, "pos2", "Pos2" )
AccessorFunc( Capsule, "pos1Dest", "Pos1Dest" )
AccessorFunc( Capsule, "pos2Dest", "Pos2Dest" )
AccessorFunc( Capsule, "Entity", "Entity" )

local drawDetail = 10

function Capsule:_init(pos1, pos2, radius, ent)
    if pos1.iscapsule then
        self:_initFromObj( pos1 )
        return
    end

    self.radius = radius
    self.radiusSqr = radius * radius
    self.pos1 = pos1
    self.pos2 = pos2
    self.pos1Lerped = pos1
    self.pos2Lerped = pos2
    self.pos1Dest = pos1
    self.pos2Dest = pos2
    self.Entity = ent
    self.filtered = {}
end

function Capsule:_initFromObj( capsule )
    self.radius = capsule.radius
    self.radiusSqr = capsule.radiusSqr
    self.pos1 = capsule.pos1
    self.pos2 = capsule.pos2
    self.pos1Lerped = capsule.pos1Lerped
    self.pos2Lerped = capsule.pos2Lerped
    self.pos1Dest = capsule.pos1Dest
    self.pos2Dest = capsule.pos2Dest
    self.Entity = capsule.Entity
    self.filtered = capsule.filtered
end

function Capsule:LerpPositions( factor )
    self.pos1Lerped = LerpVector( factor, self.pos1, self.pos1Dest )
    self.pos2Lerped = LerpVector( factor, self.pos2, self.pos2Dest )
    return self.pos1Lerped, self.pos2Lerped
end

function Capsule:PosToWorld( pos )
    if !self.Entity then return pos end
    return self.Entity:LocalToWorld( pos )
end

function Capsule:PlayersTouched()
    local pos1 = self:PosToWorld(self.pos1Lerped)
    local pos2 = self:PosToWorld(self.pos2Lerped)
    return bounds.playersInCapsule(pos1, pos2, self.radiusSqr, self.filtered)
end

function Capsule:Draw()
    local pos1 = self:PosToWorld( self.pos1Lerped )
    local pos2 = self:PosToWorld( self.pos2Lerped )

    local step = 2 * math.pi / drawDetail

    local left = -_VECTOR.LEFT * self.radius
    local up = _VECTOR.UP * self.radius
    for i = 1, drawDetail do
        local offsetLeft = left * math.cos(i * step)
        local offsetUp = up * math.sin(i * step)
        local offset = offsetLeft + offsetUp
        local offset1 = self:PosToWorld(self.pos1Lerped + offset)
        local offset2 = self:PosToWorld(self.pos2Lerped + offset)

        render.DrawLine( offset1, offset2, _COLOR.GREEN, true )
    end

    render.DrawWireframeSphere( pos1, self.radius, drawDetail, drawDetail, _COLOR.GREEN, true )
    render.DrawWireframeSphere( pos2, self.radius, drawDetail, drawDetail, _COLOR.GREEN, true )
end

function Capsule:SetRadius(radius)
    self.radius = radius
    self.radiusSqr = radius * radius
end

function Capsule:GetRadius()
    return self.radius
end

function Capsule:GetRadiusSqr()
    return self.radiusSqr
end

function Capsule:Filter( players )
    for _, ply in next, players do
        self.filtered[ply] = true
    end
end