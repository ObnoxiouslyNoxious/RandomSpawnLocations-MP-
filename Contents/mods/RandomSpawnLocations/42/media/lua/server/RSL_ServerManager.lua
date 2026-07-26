if not isServer() then return end

require "RSL_PatchNotes"

local MOD_ID = "RandomSpawnLocations"

local function playerHasAdminTool(player)
	if not player then return false end
	local role = player:getRole()
	return role and role.hasAdminTool and role:hasAdminTool() == true
end

local function isEligibleForAutoPopup(player)
	return playerHasAdminTool(player)
end

local function handleRequestPatchNotesCheck(player, args)
	if not player then return end
	if not isEligibleForAutoPopup(player) then return end
	sendServerCommand(player, MOD_ID, "patchNotesAvailable", { version = RSL_PatchNotes.CURRENT_VERSION })
end

local COMMAND_HANDLERS = {
	requestPatchNotesCheck = handleRequestPatchNotesCheck,
}

local function onClientCommand(module, command, player, args)
	if not isServer() then return end
	if module ~= MOD_ID then return end
	local handler = COMMAND_HANDLERS[command]
	if handler then handler(player, args) end
end

Events.OnClientCommand.Add(onClientCommand)
