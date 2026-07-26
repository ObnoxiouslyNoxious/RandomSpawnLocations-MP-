RSL_Env = RSL_Env or {}

RSL_Env.isSP = function()
    return not isServer() and not isClient()
end
