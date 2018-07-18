local function ecall( func, ... )
    if (!func) then return end
    func( ... )
end

_G.ecall = ecall