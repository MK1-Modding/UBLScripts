local function performSkinFXChange(CDO, data)
	local UserData = CDO:GetPropertyValue("UserData")
	local params = data.params
	
	if UserData then
		local skinFXColour = UserData.SkinFXColorProperties.BaseColor
		
		DebugLog("Proceeding to change lightning properties...")
		
		local skinFXColorPropertiesInst = UserData.SkinFXColorProperties
		
		skinFXColour.R = params.SkinFXColour.R
		skinFXColour.G = params.SkinFXColour.G
		skinFXColour.B = params.SkinFXColour.B
		
		skinFXColour = CDO.UserData.SkinFXColorProperties.BaseColor
		
		if not CDO.UserData.SkinFXColorProperties.BaseColor:IsValid() then
			error("SkinFX colour not valid! This should not be happening!")
		end
		
		--Verify new colour
		if skinFXColour then
			DebugLog(string.format("New SkinFX: R:%f, G:%f, B:%f, A:%f\n", 
			skinFXColour.R,
			skinFXColour.G,
			skinFXColour.B,
			skinFXColour.A))
		else
			error("Invalid new SkinFX.\n")
		end
		
	else
		DebugLog(string.format("Cannot retrieve UserData! This shouldn't be happening!"))
	end
end

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

return performSkinFXChange