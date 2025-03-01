local function changeVoiceOrGrunts(mkAudioComponent, newAkSwitchValue, isVoice)
	local mSwitches = mkAudioComponent:GetPropertyValue("mSwitches")
	
	if mSwitches:IsValid() then
		--Perform change based on what needs to be changed
		if isVoice then
			mSwitches[1] = newAkSwitchValue

			if newAkSwitchValue ~= FName("None") then
				DebugLog(string.format("Successfully set the new voice value for: %s to be %s!", mkAudioComponent:GetFName():ToString(), newAkSwitchValue:GetFName():ToString()))
			else
				DebugLog(string.format("Successfully set the new voice value for: %s to be 'None'!", mkAudioComponent:GetFName():ToString()))
			end
		else
			mSwitches[2] = newAkSwitchValue

			if newAkSwitchValue ~= FName("None") then
				DebugLog(string.format("Successfully set the new grunts value for: %s to be %s!", mkAudioComponent:GetFName():ToString(), newAkSwitchValue:GetFName():ToString()))
			else
				DebugLog(string.format("Successfully set the new grunts value for: %s to be 'None'!", mkAudioComponent:GetFName():ToString()))
			end
		end
	end
end

--[[local function constructVoiceGenVariable(class, template, interceptedBpName)
	local newVoiceGenVariable = StaticConstructObject(class, UEHelpers:GetGameInstance(), FName(interceptedBpName .. "_Voice_GEN_VARIABLE"), 0, 0, false, false, template)

	if not newVoiceGenVariable:IsValid() then
		error("[UBL] New Voice_GEN_VARIABLE object is not valid! This should not be happening!\n")
	end

	return newVoiceGenVariable
end]]

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
				newAkSwitchValue = FName("None")
			end
			
			if newSound ~= "None" and not newAkSwitchValue:IsValid() then
				error("[UBL] Provided sound object is not a valid sound object! Make sure the sound object is loaded in by using the loadAssets function!\n")
			end
			
			DebugLog(string.format("New sound object: %s is valid!", newSound))
			
			--Handle specific sound components
			if targetSound == "Voice" or targetSound == "Grunts" then
				local mkAudioComponentParent = FindObject(mkAudioClass, parentBlueprint, "Voice_GEN_VARIABLE", true)
				
				if not mkAudioComponentParent:IsValid() then
					error("[UBL] Retrieved parent mkAudio component: %s is not valid! This should not be happening!\n")
				end

				--[[Create new voice gen variable if it doesn't exist
				local mkAudioComponentChild = FindObject(mkAudioClass, interceptedBlueprint, "Voice_GEN_VARIABLE", true)

				if not mkAudioComponentChild:IsValid() then
					DebugLog("Child mkAudioComponent not valid, constructing...")
					mkAudioComponentChild = constructVoiceGenVariable(mkAudioClass, mkAudioComponentParent, interceptedBlueprint:GetFName():ToString())
					DebugLog(string.format("New child mkAudioComponent: %s constructed successfully!", mkAudioComponentChild:GetFName():ToString()))
				end]]
				
				--Perform sound change based on voice or grunts
				if targetSound == "Voice" then
					changeVoiceOrGrunts(mkAudioComponentParent, newAkSwitchValue, true)
				elseif targetSound == "Grunts" then
					changeVoiceOrGrunts(mkAudioComponentParent, newAkSwitchValue, false)
				end
			end
		else
			DebugLog(string.format("No new sound specified for %s", targetSound))
		end
		
	end
end

return performChange