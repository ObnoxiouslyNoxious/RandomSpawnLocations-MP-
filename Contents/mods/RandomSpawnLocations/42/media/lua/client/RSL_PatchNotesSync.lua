if isServer() and not isClient() then return end

require "RSL_Env"
require "RSL_PatchNotes"
require "RSL_UI_PatchNotes"

RSL_PatchNotesSync = {}

local MOD_ID = "RandomSpawnLocations"
local MOD_KEY = "RSL"
local SEEN_FILE = "ObNoxPatchNotes.txt"

local function loadSeenData()
	local data = {}
	local reader = getFileReader(SEEN_FILE, false)
	if not reader then return data end
	local line = reader:readLine()
	while line do
		local key, version = string.match(line, "^(%S+)%s*=%s*(%S+)$")
		if key and version then
			data[key] = version
		end
		line = reader:readLine()
	end
	reader:close()
	return data
end

local function saveSeenData(data)
	local writer = getFileWriter(SEEN_FILE, true, false)
	if not writer then return end
	for key, version in pairs(data) do
		writer:writeln(key .. " = " .. version)
	end
	writer:close()
end

local function hasSeenVersion(version)
	local data = loadSeenData()
	return data[MOD_KEY] == version
end

local function markVersionSeen(version)
	local data = loadSeenData()
	data[MOD_KEY] = version
	saveSeenData(data)
end

function RSL_PatchNotesSync.acknowledge(version)
	markVersionSeen(version)
end

local function openAutoPopup(version)
	version = version or RSL_PatchNotes.CURRENT_VERSION
	if hasSeenVersion(version) then return end
	if RSL_PatchNotes and RSL_UI_PatchNotes and RSL_UI_PatchNotes.openAuto then
		RSL_UI_PatchNotes.openAuto(version, RSL_PatchNotes.History, RSL_PatchNotes.Links)
	end
end

local function onCreatePlayer(playerIndex, player)
	if playerIndex ~= 0 then return end

	local ticksWaited = 0
	local function deferredCheck()
		ticksWaited = ticksWaited + 1
		if ticksWaited >= 10 then
			Events.OnTick.Remove(deferredCheck)
			if not isClient() or isServer() then
				openAutoPopup()
			else
				if hasSeenVersion(RSL_PatchNotes.CURRENT_VERSION) then return end
				local localPlayer = getSpecificPlayer(0)
				if localPlayer then
					sendClientCommand(localPlayer, MOD_ID, "requestPatchNotesCheck", {})
				end
			end
		end
	end
	Events.OnTick.Add(deferredCheck)
end

local function onServerCommand(module, command, args)
	if module ~= MOD_ID then return end
	if command == "patchNotesAvailable" then
		openAutoPopup(args and args.version)
	end
end

Events.OnCreatePlayer.Add(onCreatePlayer)
Events.OnServerCommand.Add(onServerCommand)
