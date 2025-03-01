RegisterCustomEvent("ChangeFacialAnims", function(ParamContext, ParamCharacterName, ParamSkinName, ParamPaletteName, ParamNewFacialAnims)
	local charName = ParamCharacterName:get()
	local skinName = ParamSkinName:get()
	local palName = ParamPaletteName:get()
	
	local facialAnims = ParamNewFacialAnims:get()
	
	local expectedTypeTable = {
		charName = "FString",
		skinName = "FString",
		palName = "FString",
		facialAnims = "FString"
	}
	
	local providedParams = {
		charName = charName,
		skinName = skinName,
		palName = palName,
		facialAnims = facialAnims
	}
	
	ValidateTypes(expectedTypeTable, providedParams)
	
	--Adjust charName with skin/pal specifics
	local adjustedCharName = AdjustCharName(charName:ToString(), skinName:ToString(), palName:ToString())

	local isDuplicateEntry = CheckIfDuplicateEntry(adjustedCharName, "ChangeFacialAnims")
	
	if (isDuplicateEntry) then
		return
	end
	
	--Convert to a standalone table to avoid corruption
	local passingParameters = {
		FacialAnims = { facialAnims:ToString() }
	}
	
	--Store character data
	StoreCharData("ChangeFacialAnims", adjustedCharName, passingParameters)
end)