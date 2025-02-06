local function changeVoiceOrGrunts(mkAudioComponent, newAkSwitchValue, isVoice)
	local mSwitches = mkAudioComponent:GetPropertyValue("mSwitches")
	
	if mSwitches:IsValid() then
		--Perform change based on what needs to be changed
		if isVoice then
			mSwitches[1] = newAkSwitchValue
			DebugLog(string.format("Successfully set the new voice value for: %s to be %s!", mkAudioComponent:GetFName():ToString(), newAkSwitchValue:GetFName():ToString()))
		else
			mSwitches[2] = newAkSwitchValue
			DebugLog(string.format("Successfully set the new grunts value for: %s to be %s!", mkAudioComponent:GetFName():ToString(), newAkSwitchValue:GetFName():ToString()))
		end
	end
end

local function performChange(CDO, soundParams, interceptedBp)
	local currentCDO = CDO
	local interceptedBlueprint = interceptedBp
	local parentBlueprint = interceptedBlueprint:GetSuperStruct()
	
	for targetSound, newSound in pairs(soundParams) do
		if newSound ~= "" then
			--Do basic things required for all sound changes
			
			local mkAudioClass = StaticFindObject("/Script/MKAudio.MKAudioComponent")
			
			if not mkAudioClass:IsValid() then
				error("[UBL] MKAudioComponent class is not valid! This should not be happening!\n")
			end
			
			local newAkSwitchValue
			
			if newSound ~= "None" then
				DebugLog(string.format("Looking for new sound object: %s for: %s", newSound, targetSound))
				newAkSwitchValue = FindObject("AkSwitchValue", newSound)
			else
				DebugLog(string.format("Setting new sound object: %s to None", targetSound))
				newAkSwitchValue = nil
			end
			
			if newSound ~= "None" and not newAkSwitchValue:IsValid() then
				error("[UBL] Provided sound object is not a valid sound object! Make sure the sound object is loaded in by using the loadAssets function!\n")
			end
			
			DebugLog(string.format("New sound object: %s is valid!", newSound))
			
			--Handle specific sound components
			if targetSound == "Voice" or targetSound == "Grunts" then
				local mkAudioComponent = FindObject(mkAudioClass, parentBlueprint, "Voice_GEN_VARIABLE", true)
				
				if not mkAudioComponent:IsValid() then
					error("[UBL] Retrieved mkAudio component: %s is not valid! What???!\n")
				end
				
				--Perform sound change based on voice or grunts
				if targetSound == "Voice" then
					changeVoiceOrGrunts(mkAudioComponent, newAkSwitchValue, true)
				elseif targetSound == "Grunts" then
					changeVoiceOrGrunts(mkAudioComponent, newAkSwitchValue, false)
				end
			end
		else
			DebugLog(string.format("No new sound specified for %s", targetSound))
		end
		
	end
end

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

return performChange