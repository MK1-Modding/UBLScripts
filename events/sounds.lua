RegisterCustomEvent("ChangeVoice", function(ParamContext, ParamCharacterName, ParamSkinName, ParamPaletteName, ParamNewVoice)
	local charName = ParamCharacterName:get()
	local skinName = ParamSkinName:get()
	local palName = ParamPaletteName:get()
	
	local isDuplicateEntry = CheckIfDuplicateEntry(charName:ToString(), "ChangeVoice")
	
	if (isDuplicateEntry) then
		return
	end
	
	local newVoice = ParamNewVoice:get()
	
	local expectedTypeTable = {
		charName = "FString",
		skinName = "FString",
		palName = "FString",
		newVoice = "FString"
	}
	
	local providedParams = {
		charName = charName,
		skinName = skinName,
		palName = palName,
		newVoice = newVoice
	}
	
	ValidateTypes(expectedTypeTable, providedParams)
	
	--Adjust charName with skin/pal specifics
	local adjustedCharName = AdjustCharName(charName:ToString(), skinName:ToString(), palName:ToString())
	
	--Convert to a standalone table to avoid corruption
	local passingParameters = {
		Voice = newVoice:ToString()
	}
	
	--Store character data
	StoreCharData("ChangeVoice", adjustedCharName, passingParameters)
end)

RegisterCustomEvent("ChangeGrunts", function(ParamContext, ParamCharacterName, ParamSkinName, ParamPaletteName, ParamNewGrunts)
	local charName = ParamCharacterName:get()
	local skinName = ParamSkinName:get()
	local palName = ParamPaletteName:get()
	
	local isDuplicateEntry = CheckIfDuplicateEntry(charName:ToString(), "ChangeGrunts")
	
	if (isDuplicateEntry) then
		return
	end
	
	local newGrunts = ParamNewGrunts:get()
	
	local expectedTypeTable = {
		charName = "FString",
		skinName = "FString",
		palName = "FString",
		newGrunts = "FString"
	}
	
	local providedParams = {
		charName = charName,
		skinName = skinName,
		palName = palName,
		newGrunts = newGrunts
	}
	
	ValidateTypes(expectedTypeTable, providedParams)
	
	--Adjust charName with skin/pal specifics
	local adjustedCharName = AdjustCharName(charName:ToString(), skinName:ToString(), palName:ToString())
	
	--Convert to a standalone table to avoid corruption
	local passingParameters = {
		Grunts = newGrunts:ToString()
	}
	
	--Store character data
	StoreCharData("ChangeGrunts", adjustedCharName, passingParameters)
end)