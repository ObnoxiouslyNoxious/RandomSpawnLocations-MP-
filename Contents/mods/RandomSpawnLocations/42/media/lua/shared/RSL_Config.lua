RSL_Config = RSL_Config or {}
RSL_Config.DEBUG = false

function RSL_dprint(...)
	if RSL_Config.DEBUG then print(...) end
end
