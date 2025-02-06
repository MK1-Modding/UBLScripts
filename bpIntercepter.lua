local charDataTable = {}
local palPatterns = {}
local skinPatterns = {}
local generalPatterns = {}
local patternsCreated = false

local assetTable = require("assetLoader")

local eventHandlers = {
	ChangeBlood = require("bloodChanger"),
	ChangeSkinFX = require("skinFXChanger"),
	ChangeFace = require("meshChanger"),
	ChangeHair = require("meshChanger"),
	ChangeBody = require("meshChanger"),
	ChangeCloth = require("meshChanger"),
	ChangeMask = require("gearChanger"),
	ChangeCowl = require("gearChanger"),
	ChangeGearMask = require("gearChanger"),
	ChangeGearCowl = require("gearChanger"),
	ChangeAnimBlueprint = require("meshChanger"),
	ChangeFaceOverrideMaterials = require("meshChanger"),
	ChangeBodyOverrideMaterials = require("meshChanger"),
	ChangeHairOverrideMaterials = require("meshChanger"),
	ChangeClothOverrideMaterials = require("meshChanger"),
	ChangeVoice = require("soundChanger"),
	ChangeGrunts = require("soundChanger"),
	ChangeMoveset = require("movesetSwapper")
}

function StoreCharData(eventType, charName, paramTable)
	--Check if char is already in table
	if not charDataTable[charName] then
		charDataTable[charName] = {}
	end
	
	local dataToStore = {}
	
	for k, v in pairs(paramTable) do
		if v then
			dataToStore[k] = v
		else
			DebugLog(string.format("Provided param: %s is nil, skipping...", k))
		end
	end
	
	--If there's valid data, store it
	if next(dataToStore) then
		charDataTable[charName][eventType] = dataToStore
		DebugLog(string.format("Stored %s event data for character: %s", eventType, charName))
	end
end

function ValidateTypes(expectedTypeTable, parameterTypes)
	for i, expectedType in pairs(expectedTypeTable) do
		local currentType = parameterTypes[i]:type()
		
		if currentType ~= expectedType then
			error(string.format("Parameter %s is of invalid type! Expected type %s, got type %s\n", i, expectedType, currentType))
		end
	end
	DebugLog("All parameters are of valid type.")
end

function CheckIfDuplicateEntry(charName, eventType)
	if charDataTable[charName] and charDataTable[charName][eventType] then
		--Data already stored, return
		return true
	end
	
	return false
end

local function modifyCDO(interceptedBP, data, event)
	LoopAsync(5, function()
		if not interceptedBP or interceptedBP == nil then
            DebugLog("Blueprint reference is nil. Stopping loop to prevent crash!")
            return true
        end

		if not interceptedBP:IsValid() then
			DebugLog("Blueprint reference is not valid. Stopping loop to prevent crash!")
			return true
		end

		local succesBp, CDO = pcall(function()
			return interceptedBP:GetCDO()
		end)

		if not succesBp or not CDO or CDO == nil then
            DebugLog("Error getting new CDO. Exiting loop to prevent crash!")
            return true
        end

		if not CDO:IsValid() then
			DebugLog("CDO not available, delaying by 5ms...")
			return false
		end

		local success, CDOName = pcall(function()
			return CDO:GetFName():ToString()
		end)

        if not success then
            DebugLog("Error accessing CDO properties. CDO might have been cleared.")
            return true
        end

		DebugLog(string.format("CDO: %s", CDOName))
			
		local ehandler = eventHandlers[event]
		if ehandler then

			local handlerSuccess, error = pcall(function()
				ehandler(CDO, data, interceptedBP)
			end)

			if not handlerSuccess then
				DebugLog(string.format("Error in event handler: %s", error))
			end
			
		else
			error(string.format("No handler found for event: %s\n", event))
		end

		return true
	end)
end

local function populateBlueprintPatterns()
	for charName, _ in pairs(charDataTable) do
		--Create pattern priority
		if string.find(charName, "Pal") then
			palPatterns[charName] = "^BP_" .. charName
			
			DebugLog(string.format("Created palette specific pattern: %s, for character: %s", palPatterns[charName], charName))
		elseif string.find(charName, "Skin") then
			skinPatterns[charName] = "^BP_" .. charName .. "_Char_C$"
			
			DebugLog(string.format("Created skin specific pattern: %s, for character: %s", skinPatterns[charName], charName))
		else
			generalPatterns[charName] = "^BP_" .. charName .. "_Skin%d%d%d_[^_]+_Char_C$"
			
			DebugLog(string.format("Created general pattern: %s, for character: %s", generalPatterns[charName], charName))
		end
	end
	
	patternsCreated = true
end

--Match palette helper func
local function matchPalette(bpName, callback)
	for charName, pattern in pairs(palPatterns) do
		--Perform essential string manipulations
		local paletteLess, pal = string.match(pattern, "^(.-)_([^_]+)$")
		local skinBpName = paletteLess .. "_Char_C$"
		local paletteBpName = string.gsub(string.match(paletteLess, "^(.-)_([^_]*)$"), "%^", "") .. "_" .. pal .."_C"

		--Match skin name and check palette validity
		if string.find(bpName, skinBpName) then
			--DebugLog(string.format("Matched %s with %s", bpName, skinBpName))
			local triesBeforeGivingUp = 0;

			LoopAsync(50, function()
				--Find palette bp object
				local paletteBp = FindObject("BlueprintGeneratedClass", paletteBpName)
				
				if paletteBp:IsValid() then
					--DebugLog(string.format("Intercepted blueprint: %s matches targeted palette skin: %s", bpName, pattern))
					callback(true, charName)
					return true
				end

				--Stop the loop if not found after 20 tries
				if triesBeforeGivingUp ~= 20 then
					triesBeforeGivingUp = triesBeforeGivingUp + 1
					return false
				else
					return true
				end
			end)
			return
		end
	end
	callback(false, nil)
end

--Match skin helper func
local function matchSkin(bpName, callback)
	for charName, pattern in pairs(skinPatterns) do
		if string.find(bpName, pattern) then
			--DebugLog(string.format("Intercepted blueprint: %s matches targeted skin: %s", bpName, pattern))
			callback(true, charName)
			return
		end
	end
	callback(false, nil)
end

--Match general helper func
local function matchGeneral(bpName, callback)
	for charName, pattern in pairs(generalPatterns) do
		if string.find(bpName, pattern) then
			--DebugLog(string.format("Intercepted blueprint: %s matches targeted general skin: %s", bpName, pattern))
			callback(true, charName)
			return
		end
	end
	callback(false, nil)
end

local function runEvents(charName, interceptedBp, matchedEvents)
	local events = charDataTable[charName]

	if events then
		for eventType, eventData in pairs(events) do
			if matchedEvents[eventType] ~= true then
				DebugLog(string.format("Event type: %s", eventType))
				modifyCDO(interceptedBp, eventData, eventType)

				--Add it to the table to prevent further matches for this event
				matchedEvents[eventType] = true
			end
		end
	end

	return matchedEvents
end

local function matchBlueprintNames(interceptedBp)
	local bpName = interceptedBp:GetFName():ToString()

	--Basic character blueprint check
	if string.find(bpName, "_Char_C") then
		local matchedEvents = {}

		--DebugLog(string.format("Intercepted blueprint: %s for character: %s" , bpName, charName))

		--Check for palette matching first
		matchPalette(bpName, function(paletteMatch, charName)
			if paletteMatch then
				matchedEvents = runEvents(charName, interceptedBp, matchedEvents)
			end
		

			--Match for skin pattern next
			matchSkin(bpName, function(skinMatch, charName)
				if skinMatch then
					matchedEvents = runEvents(charName, interceptedBp, matchedEvents)
				end
						
				--Match for general pattern last
				matchGeneral(bpName, function(generalMatch, charName)
					if generalMatch then
						matchedEvents = runEvents(charName, interceptedBp, matchedEvents)
					end
				end)
			end)
		end)
	end
end

function AdjustCharName(charName, skinName, palName)
	--Add skin and/or palette name to charName if available
	if skinName ~= "" then
		charName = charName .. "_" .. skinName
		
		if palName ~= "" then
			charName = charName .. "_" .. palName
		end
	end
	
	return charName
end

local function loadAssets()
	--Abort if assetTable is empty
	if not next(assetTable) then
		DebugLog("No assets to load.")
		return
	end
	
	local ublgameinstance = UEHelpers:GetGameInstance()
	
	--Set assetsPathArray property if this is the first call
	if ublgameinstance:GetPropertyValue("assetsPathArray"):GetArrayNum() == 0 then
		DebugLog("Setting assetsPathArray property...")
		ublgameinstance:SetPropertyValue("assetsPathArray", assetTable)
	end
	
	--Start asset loading
	ublgameinstance:SetPropertyValue("needsLoading", true)
	DebugLog("Setting needsLoading property...")
end

NotifyOnNewObject("/Script/Engine.BlueprintGeneratedClass", function(interceptedBP)
	--Initial check for empty charDataTable
	if not next(charDataTable) then
		return
	end
	
	--Populate patterns if needed
	if not patternsCreated then
		populateBlueprintPatterns()
	end

	--Call bp names matcher func
	matchBlueprintNames(interceptedBP)
end)

ExecuteWithDelay(7000, function()
	loadAssets()
	
	--Unregister events that should no longer be registered
	DebugLog("Unregistering events...")
	UnregisterCustomEvent("ChangeBlood")
	
	UnregisterCustomEvent("ChangeLightning")
	
	UnregisterCustomEvent("ChangeFace")
	
	UnregisterCustomEvent("ChangeHair")
	
	UnregisterCustomEvent("ChangeBody")
	
	UnregisterCustomEvent("ChangeCloth")
	
	UnregisterCustomEvent("ChangeMask")

	UnregisterCustomEvent("ChangeCowl")

	UnregisterCustomEvent("ChangeGearMask")

	UnregisterCustomEvent("ChangeGearCowl")
	
	UnregisterCustomEvent("ChangeAnimBlueprint")

	UnregisterCustomEvent("ChangeFaceOverrideMaterials")

	UnregisterCustomEvent("ChangeBodyOverrideMaterials")

	UnregisterCustomEvent("ChangeHairOverrideMaterials")

	UnregisterCustomEvent("ChangeClothOverrideMaterials")
	
	UnregisterCustomEvent("ChangeVoice")
	
	UnregisterCustomEvent("ChangeGrunts")

	UnregisterCustomEvent("ChangeMoveset")
	
	UnregisterCustomEvent("LoadAssets")
	DebugLog("Successfully unregistered all events")
end)