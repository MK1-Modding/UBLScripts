RegisterCustomEvent("ChangeGearMask", function(ParamContext, ParamCharacterName, ParamSkinName, ParamPaletteName, ParamTargetGear, ParamNewGearMask, ParamNewMaskClass)
	local charName = ParamCharacterName:get()
	local skinName = ParamSkinName:get()
	local palName = ParamPaletteName:get()
	
    local targetGear = ParamTargetGear:get()
    local newGearMask = ParamNewGearMask:get()
	local newMaskClass = ParamNewMaskClass:get()
	
	local expectedTypeTable = {
		charName = "FString",
		skinName = "FString",
		palName = "FString",
        targetGear = "FString",
        newGearMask = "FString",
		newMaskClass = "FString"
	}
	
	local providedParams = {
		charName = charName,
		skinName = skinName,
		palName = palName,
        targetGear = targetGear,
        newGearMask = newGearMask,
		newMaskClass = newMaskClass
	}
	
	ValidateTypes(expectedTypeTable, providedParams)
	
	--Adjust charName with skin/pal specifics
	local adjustedCharName = AdjustCharName(charName:ToString(), skinName:ToString(), palName:ToString())

	local isDuplicateEntry = CheckIfDuplicateEntry(adjustedCharName, "ChangeGearMask")
	
	if (isDuplicateEntry) then
		return
	end
	
	--Convert to a standalone table to avoid corruption
	local passingParameters = {}

	--Add mask gear or class to passing params if necessary
	if targetGear:ToString() ~= "" then
		passingParameters.GearMask = {
			targetGear:ToString(),
			newGearMask:ToString()
		}
	end

	if newMaskClass:ToString() ~= "" then
		passingParameters.MaskClass = {
			newMaskClass:ToString(),
			charName:ToString()
		}
	end
	
	--Store character data
	StoreCharData("ChangeGearMask", adjustedCharName, passingParameters)
end)

RegisterCustomEvent("ChangeGearCowl", function(ParamContext, ParamCharacterName, ParamSkinName, ParamPaletteName, ParamTargetGear, ParamNewGearCowl, ParamNewCowlClass)
	local charName = ParamCharacterName:get()
	local skinName = ParamSkinName:get()
	local palName = ParamPaletteName:get()
	
    local targetGear = ParamTargetGear:get()
    local newGearCowl = ParamNewGearCowl:get()
	local newCowlClass = ParamNewCowlClass:get()
	
	local expectedTypeTable = {
		charName = "FString",
		skinName = "FString",
		palName = "FString",
        targetGear = "FString",
        newGearCowl = "FString",
		newCowlClass = "FString"
	}
	
	local providedParams = {
		charName = charName,
		skinName = skinName,
		palName = palName,
        targetGear = targetGear,
        newGearCowl = newGearCowl,
		newCowlClass = newCowlClass
	}
	
	ValidateTypes(expectedTypeTable, providedParams)
	
	--Adjust charName with skin/pal specifics
	local adjustedCharName = AdjustCharName(charName:ToString(), skinName:ToString(), palName:ToString())

	local isDuplicateEntry = CheckIfDuplicateEntry(adjustedCharName, "ChangeGearCowl")
	
	if (isDuplicateEntry) then
		return
	end
	
	--Convert to a standalone table to avoid corruption
	local passingParameters = {}

	--Add cowl gear or class to passing params if necessary
	if targetGear:ToString() ~= "" then
		passingParameters.GearCowl = {
			targetGear:ToString(),
			newGearCowl:ToString()
		}
	end

	if newCowlClass:ToString() ~= "" then
		passingParameters.CowlClass = {
			newCowlClass:ToString(),
			charName:ToString()
		}
	end

	--Store character data
	StoreCharData("ChangeGearCowl", adjustedCharName, passingParameters)
end)