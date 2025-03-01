local function convertOverrideMats(overrideMats)
	local overrideMatsTable = {}

	overrideMats:ForEach(function(_, elem)
		table.insert(overrideMatsTable, elem:get():ToString())
	end)

	return overrideMatsTable
end

RegisterCustomEvent("ChangeFaceOverrideMaterials", function(ParamContext, ParamCharacterName, ParamSkinName, ParamPaletteName, ParamOverrideMaterials)
	local charName = ParamCharacterName:get()
	local skinName = ParamSkinName:get()
	local palName = ParamPaletteName:get()
	
	local overrideMats = ParamOverrideMaterials:get()
	
	local expectedTypeTable = {
		charName = "FString",
		skinName = "FString",
		palName = "FString",
		overrideMats = "TArray"
	}
	
	local providedParams = {
		charName = charName,
		skinName = skinName,
		palName = palName,
		overrideMats = overrideMats
	}
	
	ValidateTypes(expectedTypeTable, providedParams)

	local overrideMatsTable = convertOverrideMats(overrideMats)
	
	--Adjust charName with skin/pal specifics
	local adjustedCharName = AdjustCharName(charName:ToString(), skinName:ToString(), palName:ToString())

	local isDuplicateEntry = CheckIfDuplicateEntry(adjustedCharName, "ChangeFaceOverrideMaterials")
	
	if (isDuplicateEntry) then
		return
	end
	
	--Convert to a standalone table to avoid corruption
	local passingParameters = {
		OverrideMats = { overrideMatsTable, "Face" }
	}
	
	--Store character data
	StoreCharData("ChangeFaceOverrideMaterials", adjustedCharName, passingParameters)
end)

RegisterCustomEvent("ChangeBodyOverrideMaterials", function(ParamContext, ParamCharacterName, ParamSkinName, ParamPaletteName, ParamOverrideMaterials)
	local charName = ParamCharacterName:get()
	local skinName = ParamSkinName:get()
	local palName = ParamPaletteName:get()
	
	local overrideMats = ParamOverrideMaterials:get()
	
	local expectedTypeTable = {
		charName = "FString",
		skinName = "FString",
		palName = "FString",
		overrideMats = "TArray"
	}
	
	local providedParams = {
		charName = charName,
		skinName = skinName,
		palName = palName,
		overrideMats = overrideMats
	}
	
	ValidateTypes(expectedTypeTable, providedParams)

	local overrideMatsTable = convertOverrideMats(overrideMats)
	
	--Adjust charName with skin/pal specifics
	local adjustedCharName = AdjustCharName(charName:ToString(), skinName:ToString(), palName:ToString())

	local isDuplicateEntry = CheckIfDuplicateEntry(adjustedCharName, "ChangeBodyOverrideMaterials")
	
	if (isDuplicateEntry) then
		return
	end
	
	--Convert to a standalone table to avoid corruption
	local passingParameters = {
		OverrideMats = { overrideMatsTable, "Body" }
	}
	
	--Store character data
	StoreCharData("ChangeBodyOverrideMaterials", adjustedCharName, passingParameters)
end)

RegisterCustomEvent("ChangeHairOverrideMaterials", function(ParamContext, ParamCharacterName, ParamSkinName, ParamPaletteName, ParamOverrideMaterials)
	local charName = ParamCharacterName:get()
	local skinName = ParamSkinName:get()
	local palName = ParamPaletteName:get()
	
	local overrideMats = ParamOverrideMaterials:get()
	
	local expectedTypeTable = {
		charName = "FString",
		skinName = "FString",
		palName = "FString",
		overrideMats = "TArray"
	}
	
	local providedParams = {
		charName = charName,
		skinName = skinName,
		palName = palName,
		overrideMats = overrideMats
	}
	
	ValidateTypes(expectedTypeTable, providedParams)

	local overrideMatsTable = convertOverrideMats(overrideMats)
	
	--Adjust charName with skin/pal specifics
	local adjustedCharName = AdjustCharName(charName:ToString(), skinName:ToString(), palName:ToString())

	local isDuplicateEntry = CheckIfDuplicateEntry(adjustedCharName, "ChangeHairOverrideMaterials")
	
	if (isDuplicateEntry) then
		return
	end
	
	--Convert to a standalone table to avoid corruption
	local passingParameters = {
		OverrideMats = { overrideMatsTable, "Hair" }
	}
	
	--Store character data
	StoreCharData("ChangeHairOverrideMaterials", adjustedCharName, passingParameters)
end)

RegisterCustomEvent("ChangeClothOverrideMaterials", function(ParamContext, ParamCharacterName, ParamSkinName, ParamPaletteName, ParamOverrideMaterials)
	local charName = ParamCharacterName:get()
	local skinName = ParamSkinName:get()
	local palName = ParamPaletteName:get()
	
	local overrideMats = ParamOverrideMaterials:get()
	
	local expectedTypeTable = {
		charName = "FString",
		skinName = "FString",
		palName = "FString",
		overrideMats = "TArray"
	}
	
	local providedParams = {
		charName = charName,
		skinName = skinName,
		palName = palName,
		overrideMats = overrideMats
	}
	
	ValidateTypes(expectedTypeTable, providedParams)

	local overrideMatsTable = convertOverrideMats(overrideMats)
	
	--Adjust charName with skin/pal specifics
	local adjustedCharName = AdjustCharName(charName:ToString(), skinName:ToString(), palName:ToString())

	local isDuplicateEntry = CheckIfDuplicateEntry(adjustedCharName, "ChangeClothOverrideMaterials")
	
	if (isDuplicateEntry) then
		return
	end
	
	--Convert to a standalone table to avoid corruption
	local passingParameters = {
		OverrideMats = { overrideMatsTable, "Cloth" }
	}
	
	--Store character data
	StoreCharData("ChangeClothOverrideMaterials", adjustedCharName, passingParameters)
end)