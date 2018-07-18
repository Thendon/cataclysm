
local function new(class, ...)
    local instance = setmetatable({}, class)

    instance:_init(...)

    return instance
end

local function Classify(parent)
    tbl = {}
    tbl.__index = tbl
    tbl._Class = true

    local meta = {}

    if ( parent ) then
        meta.__index = parent
    end

    meta.__call = new

    return setmetatable(tbl, meta)
end

local function isClass(obj)
    return obj and istable(obj) and obj._Class
end

_G.TableToClass = Classify
_G.Class = Classify
_G.isclass = isClass