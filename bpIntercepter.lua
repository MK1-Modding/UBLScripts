local charDataTable = {}
local palPatterns = {}
local skinPatterns = {}
local generalPatterns = {}
WaitingBlueprintAssets = {}
local patternsCreated = false

local assetTables = require("assetLoader")

local eventHandlers = {
	ChangeBlood = { 
		Event = require("events.miscellaneous"),
		Handler = require("bloodChanger")
	},
	ChangeSkinFX = {
		Event = require("events.miscellaneous"),
		Handler = require("skinFXChanger")
	},
	ChangeFace = {
		Event = require("events.mesh"),
		Handler = require("eventHandler")
	},
	ChangeHair = {
		Event = require("events.mesh"),
		Handler = require("eventHandler")
	},
	ChangeBody = {
		Event = require("events.mesh"),
		Handler = require("eventHandler")
	},
	ChangeCloth = {
		Event = require("events.mesh"),
		Handler = require("eventHandler")
	},
	ChangeGearMask = {
		Event = require("events.gear"),
		Handler = require("gearChanger")
	},
	ChangeGearCowl = {
		Event = require("events.gear"),
		Handler = require("gearChanger")
	},
	ChangeAnimBlueprint = {
		Event = require("events.animBlueprint"),
		require("eventHandler")
	},
	ChangeFaceOverrideMaterials = {
		Event = require("events.overrideMaterials"),
		Handler = require("eventHandler")
	},
	ChangeBodyOverrideMaterials = {
		Event = require("events.overrideMaterials"),
		Handler = require("eventHandler")
	},
	ChangeHairOverrideMaterials = {
		Event = require("events.overrideMaterials"),
		Handler = require("eventHandler")
	},
	ChangeClothOverrideMaterials = {
		Event = require("events.overrideMaterials"),
		Handler = require("eventHandler")
	},
	ChangeFacialAnims = {
		Event = require("events.anims"),
		Handler = require("eventHandler")
	},
	ChangeVoice = {
		Event = require("events.sounds"),
		Handler = require("soundChanger")
	},
	ChangeGrunts = {
		Event = require("events.sounds"),
		Handler = require("soundChanger")
	},
	ChangeMoveset = {
		Event = require("events.miscellaneous"),
		Handler = require("movesetSwapper")
	}
}

function StoreCharData(eventType, charName, paramTable)
	--Check if char is already in table
	if not charDataTable[charName] then
		charDataTable[charName] = {}
	end
	
	local dataToStore = {}
	
	for key, val in pairs(paramTable) do
		if key then
			dataToStore[key] = val
		else
			error(string.format("[UBL] Provided param: %s is nil!\n", key))
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
			error(string.format("[UBL] Parameter %s is of invalid type! Expected type %s but got type %s! Please make sure you are using the correct input types for your event parameters!\n", i, expectedType, currentType))
		end
	end
	DebugLog("All parameters are of valid type")
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
            DebugLog("Blueprint is nil. Stopping loop to prevent crash!")
            return true
        end

		if not interceptedBP:IsValid() then
			DebugLog("Blueprint is no longer valid. Stopping loop to prevent crash!")
			return true
		end

		local CDO = interceptedBP:GetCDO()

		if not CDO:IsValid() then
			DebugLog("CDO not available, delaying by 5ms...")
			return false
		end

		DebugLog(string.format("CDO: %s", CDO:GetFName():ToString()))
			
		local ehandler = eventHandlers[event]["Handler"]
		if ehandler then
			ehandler(CDO, data, interceptedBP)
		else
			error(string.format("[UBL] No handler found for event: %s\n", event))
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

			--Find palette bp object
			local paletteBp = FindObject("BlueprintGeneratedClass", paletteBpName)

			if paletteBp:IsValid() then
				callback(true, charName)
				return
			end

			WaitingBlueprintAssets[paletteBpName] = function(paletteBlueprint)
				if paletteBlueprint:IsValid() then
					callback(true, charName)
				else
					callback(false, nil)
				end
			end
			
			return
		end
	end

	-- If no match was found, return false
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
	if not next(assetTables.assetTable) and not next(assetTables.mkAssetLibraryTable) then
		DebugLog("No assets to load.")
		return
	end
	
	local ublgameinstance = UEHelpers:GetGameInstance()
	
	if next(assetTables.assetTable) then
		--Set assetsPathArray property if this is the first call
		if ublgameinstance:GetPropertyValue("assetsPathArray"):GetArrayNum() == 0 then
			DebugLog("Setting assetsPathArray property...")
			ublgameinstance:SetPropertyValue("assetsPathArray", assetTables.assetTable)
		end
	end

	if next(assetTables.mkAssetLibraryTable) then
		DebugLog("Setting mkAssetLibraryArray property...")
		ublgameinstance:SetPropertyValue("mkAssetLibraryArray", assetTables.mkAssetLibraryTable)
	end
end

local function registerStuff()
	loadAssets()
	
	--Unregister events that should no longer be registered
	DebugLog("Unregistering events...")
	UnregisterCustomEvent("ChangeBlood")
	
	UnregisterCustomEvent("ChangeSkinFX")
	
	UnregisterCustomEvent("ChangeFace")
	
	UnregisterCustomEvent("ChangeHair")
	
	UnregisterCustomEvent("ChangeBody")
	
	UnregisterCustomEvent("ChangeCloth")

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
end

NotifyOnNewObject("/Script/Engine.BlueprintGeneratedClass", function(interceptedBP)
	--Initial check for empty charDataTable
	if not next(charDataTable) then
		return
	end
	
	--Populate patterns if needed
	if not patternsCreated then
		populateBlueprintPatterns()

		registerStuff()
	end

	--Basic character blueprint check
	if string.find(interceptedBP:GetFName():ToString(), "_Char_C") then
		--Call bp names matcher func
		matchBlueprintNames(interceptedBP)
	elseif WaitingBlueprintAssets[interceptedBP:GetFName():ToString()] then
		DebugLog(string.format("Palette blueprint spawned!"))

		WaitingBlueprintAssets[interceptedBP:GetFName():ToString()](interceptedBP)

		--Clear the asset
		WaitingBlueprintAssets[interceptedBP:GetFName():ToString()] = nil
	end
end)