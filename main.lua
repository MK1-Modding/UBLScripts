UEHelpers = require("UEHelpers")

local debugLogging = true
local initialSpawnDone = false
local modsTable = {}

ublplayercontroller = nil

function DebugLog(msg)
	if debugLogging then
		--Set debug messages to be printed
		print("[UBL] " .. msg .. "\n")
	end
end

local function createModTable(BPModsDir)
	local BPModsFiles = BPModsDir.__files
	local addedMods = {}
	
	for _, file in pairs(BPModsFiles) do
		local modName = file.__name:match("^(.*)%.[^%.]+$")
		if not addedMods[modName] then
			table.insert(modsTable, modName)
			addedMods[modName] = true
			DebugLog(string.format("Added mod: %s", modName))
		end
	end
end

local function initialization()
	local BPModsDir = IterateGameDirectories().Game.Content.Paks.BPMods
	
	if not BPModsDir then
		ublplayercontroller:SetPropertyValue("abortSpawn", true)
		error("BPMods directory not found. Please create and populate it with your desired mods.\n")
	else
		if #BPModsDir.__files == 0 then
			ublplayercontroller:SetPropertyValue("abortSpawn", true)
		else
			--Populate mod table only for initial spawn
			if not initialSpawnDone then
				createModTable(BPModsDir)
				initialSpawnDone = true
				require("bpIntercepter")
			end
			
			--Pass detected mods to playerController
			ublplayercontroller:SetPropertyValue("bpNamesArray", modsTable)
		end
	end
end

local function preInit()
	--Retrieve all playercontrollers
	local playerControllers = FindAllOf("UBLPlayerController_C")
	
	for _, playerController in pairs(playerControllers) do
		if playerController:IsValid() and playerController:GetFName():ToString() ~= "Default__UBLPlayerController_C" then
			ublplayercontroller = playerController
		end
	end
	
	DebugLog("Current PlayerController: " .. ublplayercontroller:GetFullName())
	DebugLog("Current World: " .. ublplayercontroller:GetWorld():GetFullName())
	
	initialization()
end

RegisterCustomEvent("LoadBlueprints", function()
	preInit()
end)