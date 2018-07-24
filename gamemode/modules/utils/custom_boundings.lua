local bounds = bounds or {}

function bounds.pointInCylinderCalc( axis, difference, radiusSqr)
    local length = axis:LengthSqr()
    if length == 0 then return false end

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
    distance = bounds.pointInSphereCalc(difference, radiusSqr) or false

    if p1 == p2 then return distance end

    local lowestDistance = distance
    --local lowestDifference = difference

    difference = pTest - p1
    distance = bounds.pointInSphereCalc(difference, radiusSqr)
    if distance then
        if !lowestDistance then
            lowestDistance = distance
        elseif distance < lowestDistance then
            --lowestDifference = difference
            lowestDistance = distance
        end
    end

    local axis = p2 - p1
    distance = bounds.pointInCylinderCalc(axis, difference, radiusSqr)
    if !lowestDistance then lowestDistance = distance end
    if distance then
        if !lowestDistance then
            lowestDistance = distance
        elseif distance < lowestDistance then
            lowestDistance = distance
        end
    end

    if lowestDistance then return lowestDistance end

    return false
end

local function callbackOnAttachmentsOf( ent, callback )
    local attachments = ent:GetAttachments()
    if (!attachments or table.Count(attachments) <= 0) then
        return callback( ent:GetPos() )
    end

    for _, attachment in next, attachments do
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

local function objectInCollider( list, blacklist, radiusSqr, func, ... )
    blacklist = blacklist or {}
    local inside = {}
    for _, obj in next, list do
        if blacklist[obj] then continue end
        local distance = func( obj, ..., radiusSqr )
        if distance then table.insert( inside, { obj = obj, distance = distance } ) end
    end
    return inside
end

function bounds.objectsInCapsule( list, p1, p2, radiusSqr, blacklist )
    blacklist = blacklist or {}
    local inside = {}
    for _, obj in next, list do
        if blacklist[obj] then continue end
        local distance = bounds.entInCapsule( obj, p1, p2, radiusSqr )
        if distance then table.insert( inside, { obj = obj, distance = distance } ) end
    end
    return inside
end

function bounds.objectsInSphere( list, pos, radiusSqr, blacklist )
    blacklist = blacklist or {}
    local inside = {}
    for _, obj in next, list do
        if blacklist[obj] then continue end
        local distance = bounds.entInSphere( obj, pos, radiusSqr )
        if distance then table.insert( inside, { obj = obj, distance = distance } ) end
    end
    return inside
end

_G.bounds = bounds

local epsilon = 0.0001

_G.CalcUpRight = function( forward )
    local tempForward = forward
    if (forward == _VECTOR.UP) then tempForward = forward + Vector(epsilon, 0, 0) end
    local right = tempForward:Cross( _VECTOR.UP ):GetNormalized()
    local up = forward:Cross( right )

    return up, right
end