local function constructBloodAsset(passedParams, charName)
	local class = StaticFindObject("/Script/MK12.BloodPropertiesDataAsset")
	local newBloodAsset = StaticConstructObject(class, UEHelpers:GetGameInstance(), FName(charName .. "_newBlood"))
	
	if not newBloodAsset then
		error("Failed to construct new blood asset!\n")
	end
	
	DebugLog(string.format("Path of newBloodAsset: %s", newBloodAsset:GetFullName()))
	
	local properParams = {
		["BloodColor"] = passedParams.BloodColor,
		["BloodColorGameplay"] = passedParams.BloodColorGameplay,
		["SDF_SSColor"] = passedParams.SDF_SSColor,
		["SupplementaryTranslucentColor"] = passedParams.SupplementaryTranslucentColor
	}
	
	--Set custom values
	for propertyName, v in pairs(properParams) do
		local property = newBloodAsset:GetPropertyValue(propertyName)
		
		if property then
			property.R = v.R
			property.G = v.G
			property.B = v.B
			property.A = v.A
		end
	end
	
	--Set default values
	newBloodAsset.SDF_EmisIntensity = 40.0
	newBloodAsset.SDF_EmisPower = 1.9
	
	local bloodAssetParam = { bloodAsset = newBloodAsset }
	
	--Store character data
	StoreCharData("ChangeBlood", charName, bloodAssetParam)
end

RegisterCustomEvent("ChangeBlood", function(ParamContext, ParamCharacterName, ParamSkinName, ParamPaletteName, ParamBloodColor, ParamBloodColorGameplay, ParamSDF_SSColor, ParamSupplementaryTranslucentColor)
	local charName = ParamCharacterName:get()
	local skinName = ParamSkinName:get()
	local palName = ParamPaletteName:get()
	
	local bloodColor = ParamBloodColor:get()
	local bloodColorGameplay = ParamBloodColorGameplay:get()
	local SDF_SSColor = ParamSDF_SSColor:get()
	local supplementaryTranslucentColor = ParamSupplementaryTranslucentColor:get()
	
	local expectedTypeTable = {
		charName = "FString",
		skinName = "FString",
		palName = "FString",
		bloodColor = "UScriptStruct",
		bloodColorGameplay = "UScriptStruct",
		SDF_SSColor = "UScriptStruct",
		supplementaryTranslucentColor = "UScriptStruct"
	}
	
	local providedParams = {
		charName = charName,
		skinName = skinName,
		palName = palName,
		bloodColor = bloodColor,
		bloodColorGameplay = bloodColorGameplay,
		SDF_SSColor = SDF_SSColor,
		supplementaryTranslucentColor = supplementaryTranslucentColor
	}
	
	ValidateTypes(expectedTypeTable, providedParams)
	
	--Adjust charName with skin/pal specifics
	local adjustedCharName = AdjustCharName(charName:ToString(), skinName:ToString(), palName:ToString())

	local isDuplicateEntry = CheckIfDuplicateEntry(adjustedCharName, "ChangeBlood")
	
	if (isDuplicateEntry) then
		return
	end
	
	--Convert to a standalone table to avoid corruption
	local passingParameters = {
		BloodColor = {
			R = providedParams.bloodColor.R,
			G = providedParams.bloodColor.G,
			B = providedParams.bloodColor.B,
			A = providedParams.bloodColor.A,
		},
		BloodColorGameplay = {
			R = providedParams.bloodColorGameplay.R,
			G = providedParams.bloodColorGameplay.G,
			B = providedParams.bloodColorGameplay.B,
			A = providedParams.bloodColorGameplay.A,
		},
		SDF_SSColor = {
			R = providedParams.SDF_SSColor.R,
			G = providedParams.SDF_SSColor.G,
			B = providedParams.SDF_SSColor.B,
			A = providedParams.SDF_SSColor.A,
		},
		SupplementaryTranslucentColor = {
			R = providedParams.supplementaryTranslucentColor.R,
			G = providedParams.supplementaryTranslucentColor.G,
			B = providedParams.supplementaryTranslucentColor.B,
			A = providedParams.supplementaryTranslucentColor.A,
		}
	}
	
	--Generate new blood asset
	ExecuteWithDelay(10, function()
		constructBloodAsset(passingParameters, adjustedCharName)
	end)
end)

RegisterCustomEvent("ChangeSkinFX", function(ParamContext, ParamCharacterName, ParamSkinName, ParamPaletteName, ParamSkinFXColour)
	local charName = ParamCharacterName:get()
	local skinName = ParamSkinName:get()
	local palName = ParamPaletteName:get()
	
	local skinFX = ParamSkinFXColour:get()
	
	local expectedTypeTable = {
		charName = "FString",
		skinName = "FString",
		palName = "FString",
		skinFX = "UScriptStruct"
	}
	
	local params = {
		charName = charName,
		skinName = skinName,
		palName = palName,
		skinFX = skinFX
	}
	
	ValidateTypes(expectedTypeTable, params)
	
	--Adjust charName with skin/pal specifics
	local adjustedCharName = AdjustCharName(charName:ToString(), skinName:ToString(), palName:ToString())

	local isDuplicateEntry = CheckIfDuplicateEntry(adjustedCharName, "ChangeSkinFX")
	
	if (isDuplicateEntry) then
		return
	end
	
	--Convert to a standalone table to avoid corruption
	local safeParams = {
		SkinFXColour = {
			R = params.skinFX.R,
			G = params.skinFX.G,
			B = params.skinFX.B
		}
	}
	
	local paramsToStore = {params = safeParams}
	
	--Store character data
	StoreCharData("ChangeSkinFX", adjustedCharName, paramsToStore)
end)

RegisterCustomEvent("ChangeMoveset", function(ParamContext, ParamCharacterName, ParamSkinName, ParamPaletteName, ParamNewMoveset)
	local charName = ParamCharacterName:get()
	local skinName = ParamSkinName:get()
	local palName = ParamPaletteName:get()
	
	local newMoveset = ParamNewMoveset:get()
	
	local expectedTypeTable = {
		charName = "FString",
		skinName = "FString",
		palName = "FString",
		newMoveset = "FString"
	}
	
	local providedParams = {
		charName = charName,
		skinName = skinName,
		palName = palName,
		newMoveset = newMoveset
	}
	
	ValidateTypes(expectedTypeTable, providedParams)
	
	--Adjust charName with skin/pal specifics
	local adjustedCharName = AdjustCharName(charName:ToString(), skinName:ToString(), palName:ToString())

	local isDuplicateEntry = CheckIfDuplicateEntry(adjustedCharName, "ChangeMoveset")
	
	if (isDuplicateEntry) then
		return
	end
	
	--Convert to a standalone table to avoid corruption
	local passingParameters = {
        Moveset = { newMoveset:ToString(), charName:ToString() }
	}
	
	--Store character data
	StoreCharData("ChangeMoveset", adjustedCharName, passingParameters)
end)

RegisterCustomEvent("ForceAddonMoveset", function(ParamContext, ParamCharacterName, ParamSkinName, ParamPaletteName, ParamAddonMoveset)
	local charName = ParamCharacterName:get()
	local skinName = ParamSkinName:get()
	local palName = ParamPaletteName:get()
	
	local addonMovesetStruct = ParamAddonMoveset:get()
	
	local expectedTypeTable = {
		charName = "FString",
		skinName = "FString",
		palName = "FString",
		addonMovesetStruct = "UScriptStruct"
	}
	
	local providedParams = {
		charName = charName,
		skinName = skinName,
		palName = palName,
		addonMovesetStruct = addonMovesetStruct
	}
	
	ValidateTypes(expectedTypeTable, providedParams)
	
	--Adjust charName with skin/pal specifics
	local adjustedCharName = AdjustCharName(charName:ToString(), skinName:ToString(), palName:ToString())

	local isDuplicateEntry = CheckIfDuplicateEntry(adjustedCharName, "ForceAddonMoveset")
	
	if (isDuplicateEntry) then
		return
	end

	--Copy fields safely to a table
	local addonMovesetTable = {
		Mid = addonMovesetStruct.Mid,
		mMoveset = addonMovesetStruct.mMoveset,
		mSkin = addonMovesetStruct.mSkin
	}
	
	--Convert to a standalone table to avoid corruption
	local passingParameters = {
        AddonMoveset = { addonMovesetTable, charName:ToString() }
	}
	
	--Store character data
	StoreCharData("ForceAddonMoveset", adjustedCharName, passingParameters)
end)