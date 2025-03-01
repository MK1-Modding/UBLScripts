RegisterCustomEvent("ChangeAnimBlueprint", function(ParamContext, ParamCharacterName, ParamSkinName, ParamPaletteName, ParamNewAnimBlueprint)
	local charName = ParamCharacterName:get()
	local skinName = ParamSkinName:get()
	local palName = ParamPaletteName:get()
	
	local newAnimBlueprint = ParamNewAnimBlueprint:get()
	
	local expectedTypeTable = {
		charName = "FString",
		skinName = "FString",
		palName = "FString",
		newAnimBlueprint = "FString"
	}
	
	local providedParams = {
		charName = charName,
		skinName = skinName,
		palName = palName,
		newAnimBlueprint = newAnimBlueprint
	}
	
	ValidateTypes(expectedTypeTable, providedParams)
	
	--Adjust charName with skin/pal specifics
	local adjustedCharName = AdjustCharName(charName:ToString(), skinName:ToString(), palName:ToString())

	local isDuplicateEntry = CheckIfDuplicateEntry(adjustedCharName, "ChangeAnimBlueprint")
	
	if (isDuplicateEntry) then
		return
	end
	
	--Convert to a standalone table to avoid corruption
	local passingParameters = {
		AnimBlueprint = { newAnimBlueprint:ToString() }
	}
	
	--Store character data
	StoreCharData("ChangeAnimBlueprint", adjustedCharName, passingParameters)
end)