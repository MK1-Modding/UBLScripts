RegisterCustomEvent("ChangeFace", function(ParamContext, ParamCharacterName, ParamSkinName, ParamPaletteName, ParamNewFace)
	local charName = ParamCharacterName:get()
	local skinName = ParamSkinName:get()
	local palName = ParamPaletteName:get()
	
	local newFace = ParamNewFace:get()
	
	local expectedTypeTable = {
		charName = "FString",
		skinName = "FString",
		palName = "FString",
		newFace = "FString"
	}
	
	local providedParams = {
		charName = charName,
		skinName = skinName,
		palName = palName,
		newFace = newFace
	}
	
	ValidateTypes(expectedTypeTable, providedParams)
	
	--Adjust charName with skin/pal specifics
	local adjustedCharName = AdjustCharName(charName:ToString(), skinName:ToString(), palName:ToString())

	local isDuplicateEntry = CheckIfDuplicateEntry(AdjustCharName, "ChangeFace")
	
	if (isDuplicateEntry) then
		return
	end
	
	--Convert to a standalone table to avoid corruption
	local passingParameters = {
		Face = { newFace:ToString() }
	}
	
	--Store character data
	StoreCharData("ChangeFace", adjustedCharName, passingParameters)
end)

RegisterCustomEvent("ChangeHair", function(ParamContext, ParamCharacterName, ParamSkinName, ParamPaletteName, ParamNewHair)
	local charName = ParamCharacterName:get()
	local skinName = ParamSkinName:get()
	local palName = ParamPaletteName:get()
	
	local newHair = ParamNewHair:get()
	
	local expectedTypeTable = {
		charName = "FString",
		skinName = "FString",
		palName = "FString",
		newHair = "FString"
	}
	
	local providedParams = {
		charName = charName,
		skinName = skinName,
		palName = palName,
		newHair = newHair
	}
	
	ValidateTypes(expectedTypeTable, providedParams)
	
	--Adjust charName with skin/pal specifics
	local adjustedCharName = AdjustCharName(charName:ToString(), skinName:ToString(), palName:ToString())

	local isDuplicateEntry = CheckIfDuplicateEntry(adjustedCharName, "ChangeHair")
	
	if (isDuplicateEntry) then
		return
	end
	
	--Convert to a standalone table to avoid corruption
	local passingParameters = {
		Hair = { newHair:ToString() }
	}
	
	--Store character data
	StoreCharData("ChangeHair", adjustedCharName, passingParameters)
end)

RegisterCustomEvent("ChangeBody", function(ParamContext, ParamCharacterName, ParamSkinName, ParamPaletteName, ParamNewBody)
	local charName = ParamCharacterName:get()
	local skinName = ParamSkinName:get()
	local palName = ParamPaletteName:get()
	
	local newBody = ParamNewBody:get()
	
	local expectedTypeTable = {
		charName = "FString",
		skinName = "FString",
		palName = "FString",
		newBody = "FString"
	}
	
	local providedParams = {
		charName = charName,
		skinName = skinName,
		palName = palName,
		newBody = newBody
	}
	
	ValidateTypes(expectedTypeTable, providedParams)
	
	--Adjust charName with skin/pal specifics
	local adjustedCharName = AdjustCharName(charName:ToString(), skinName:ToString(), palName:ToString())

	local isDuplicateEntry = CheckIfDuplicateEntry(adjustedCharName, "ChangeBody")
	
	if (isDuplicateEntry) then
		return
	end
	
	--Convert to a standalone table to avoid corruption
	local passingParameters = {
		Body = { newBody:ToString() }
	}
	
	--Store character data
	StoreCharData("ChangeBody", adjustedCharName, passingParameters)
end)

RegisterCustomEvent("ChangeCloth", function(ParamContext, ParamCharacterName, ParamSkinName, ParamPaletteName, ParamNewHavokAsset, ParamNewClothMesh)
	local charName = ParamCharacterName:get()
	local skinName = ParamSkinName:get()
	local palName = ParamPaletteName:get()
	
	local newHavokAsset = ParamNewHavokAsset:get()
	local newClothMesh = ParamNewClothMesh:get()
	
	local expectedTypeTable = {
		charName = "FString",
		skinName = "FString",
		palName = "FString",
		newHavokAsset = "FString",
		newClothMesh = "FString"
	}
	
	local providedParams = {
		charName = charName,
		skinName = skinName,
		palName = palName,
		newHavokAsset = newHavokAsset,
		newClothMesh = newClothMesh
	}
	
	ValidateTypes(expectedTypeTable, providedParams)
	
	--Adjust charName with skin/pal specifics
	local adjustedCharName = AdjustCharName(charName:ToString(), skinName:ToString(), palName:ToString())

	local isDuplicateEntry = CheckIfDuplicateEntry(adjustedCharName, "ChangeCloth")
	
	if (isDuplicateEntry) then
		return
	end
	
	--Convert to a standalone table to avoid corruption
	local passingParameters = {
		HavokCloth = { newHavokAsset:ToString() },
		ClothMesh = { newClothMesh:ToString() }
	}
	
	--Store character data
	StoreCharData("ChangeCloth", adjustedCharName, passingParameters)
end)

RegisterCustomEvent("ChangeHairCloth", function(ParamContext, ParamCharacterName, ParamSkinName, ParamPaletteName, ParamNewHavokAsset, ParamNewHairClothMesh)
	local charName = ParamCharacterName:get()
	local skinName = ParamSkinName:get()
	local palName = ParamPaletteName:get()
	
	local newHavokAsset = ParamNewHavokAsset:get()
	local newHairClothMesh = ParamNewHairClothMesh:get()
	
	local expectedTypeTable = {
		charName = "FString",
		skinName = "FString",
		palName = "FString",
		newHavokAsset = "FString",
		newHairClothMesh = "FString"
	}
	
	local providedParams = {
		charName = charName,
		skinName = skinName,
		palName = palName,
		newHavokAsset = newHavokAsset,
		newHairClothMesh = newHairClothMesh
	}
	
	ValidateTypes(expectedTypeTable, providedParams)
	
	--Adjust charName with skin/pal specifics
	local adjustedCharName = AdjustCharName(charName:ToString(), skinName:ToString(), palName:ToString())

	local isDuplicateEntry = CheckIfDuplicateEntry(adjustedCharName, "ChangeHairCloth")
	
	if (isDuplicateEntry) then
		return
	end
	
	--Convert to a standalone table to avoid corruption
	local passingParameters = {
		Hair_HavokCloth = { newHavokAsset:ToString() },
		Hair_ClothMesh = { newHairClothMesh:ToString() }
	}
	
	--Store character data
	StoreCharData("ChangeHairCloth", adjustedCharName, passingParameters)
end)