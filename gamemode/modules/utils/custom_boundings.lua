local bounds = bounds or {}

function bounds.pointInCylinderCalc( axis, difference, radiusSqr)
    local length = axis:LengthSqr()
    local dot = difference:Dot(axis)

    if ( dot < 0 || dot > length ) then
        return false
    end

    local distance = difference:LengthSqr() - dot * dot / length
    if (distance > radiusSqr) then
        return false
    end
    return distance
end

function bounds.pointInCylinder( p1, p2, radiusSqr, pTest )
    local axis = p2 - p1
    local difference = pTest - p1

    return bounds.pointInCylinderCalc( axis, difference, radiusSqr )
end

function bounds.pointInSphereCalc( difference, radiusSqr )
    local distance = difference:LengthSqr()

    if (distance > radiusSqr) then
        return false
    end
    return distance
end

function bounds.pointInSphere( pos, radiusSqr, pTest )
    local difference = pTest - pos

    return bounds.pointInSphereCalc( difference, radiusSqr )
end

function bounds.pointInCapsule( p1, p2, radiusSqr, pTest )
    local difference, distance

    difference = pTest - p2
    distance = bounds.pointInSphereCalc(difference, radiusSqr)
    if (distance) then return distance end

    difference = pTest - p1
    distance = bounds.pointInSphereCalc(difference, radiusSqr)
    if (distance) then return distance end

    local axis = p2 - p1
    distance = bounds.pointInCylinderCalc(axis, difference, radiusSqr)
    if (distance) then return distance end

    return false
end

local function callbackOnAttachmentsOf( ent, callback )
    for _, attachment in next, ent:GetAttachments() do
        local ret = callback( ent:GetAttachment(attachment.id).Pos )
        if ret then return ret end
    end
    return false
end

function bounds.entInCylinder( ent, p1, p2, radiusSqr )
    return callbackOnAttachmentsOf( ent, function( point )
        return bounds.pointInCylinder( p1, p2, radiusSqr, point )
    end)
end

function bounds.entInSphere( ent, pos, radiusSqr )
    return callbackOnAttachmentsOf( ent, function( point )
        return bounds.pointInSphere( pos, radiusSqr, point )
    end)
end

function bounds.entInCapsule( ent, p1, p2, radiusSqr )
    return callbackOnAttachmentsOf( ent, function( point )
        return bounds.pointInCapsule( p1, p2, radiusSqr, point )
    end)
end

function bounds.playersInCapsule( p1, p2, radiusSqr, blacklist )
    blacklist = blacklist or {}
    local inside = {}
    for _, ply in next, player.GetAll() do
        if blacklist[ply] then continue end
        local distance = bounds.entInCapsule( ply, p1, p2, radiusSqr )
        if distance then table.insert( inside, { ply = ply, distance = distance } ) end
    end
    return inside
end

_G.bounds = bounds