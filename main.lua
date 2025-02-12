UEHelpers = require("UEHelpers")

local version = 1.00

local debugLogging = true
local initialSpawnDone = false
local modsTable = {}

UBLPlayerController = nil

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
			print(string.format("[UBL] Added mod: %s\n", modName))
		end
	end
end

local function initialization()
	local BPModsDir = IterateGameDirectories().Game.Content.Paks.BPMods
	
	if not BPModsDir then
		UBLPlayerController:SetPropertyValue("abortSpawn", true)
		error("[UBL] BPMods directory not found. Please create and populate it with your desired mods.\n")
	else
		if #BPModsDir.__files == 0 then
			UBLPlayerController:SetPropertyValue("abortSpawn", true)
		else
			--Populate mod table only for initial spawn
			if not initialSpawnDone then
				createModTable(BPModsDir)
				initialSpawnDone = true
				require("bpIntercepter")
			end
			
			--Pass detected mods to playerController
			UBLPlayerController:SetPropertyValue("bpNamesArray", modsTable)
		end
	end
end

local function preInit()
	--Retrieve all playercontrollers
	local playerControllers = FindAllOf("UBLPlayerController_C")
	
	for _, playerController in pairs(playerControllers) do
		if playerController:IsValid() and playerController:GetFName():ToString() ~= "Default__UBLPlayerController_C" then
			UBLPlayerController = playerController
		end
	end
	
	DebugLog("Current PlayerController: " .. UBLPlayerController:GetFullName())
	DebugLog("Current World: " .. UBLPlayerController:GetWorld():GetFullName())

	initialization()
end

RegisterCustomEvent("LoadBlueprints", function()
	preInit()
end)

print(string.format("[UBL] Initializing UBL version: %.2f\n", version))