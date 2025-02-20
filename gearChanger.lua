local function changePropClass(genVariableComponent, newBlueprintClass)
	--Retrieve mask class property
	local propClass = genVariableComponent:GetPropertyValue("PropClass")
	
	if propClass:IsValid() then
		genVariableComponent:SetPropertyValue("PropClass", newBlueprintClass)
		
		if newBlueprintClass ~= FName("None") then
			DebugLog(string.format("Successfully set the new prop class for: %s to be %s!", genVariableComponent:GetFName():ToString(), newBlueprintClass:GetFName():ToString()))
		else
			DebugLog(string.format("Successfully set the new prop class for: %s to be 'None'!", genVariableComponent:GetFName():ToString()))
		end
	else
		error("[UBL] Retrieved prop class property is not valid! This should not be happening!\n")
	end
end

local function changeGear(gearCDO, newGearBp, target)
    local classOverridesProperty = gearCDO:GetPropertyValue("ClassOverrides")

    if classOverridesProperty:IsValid() then
		classOverridesProperty:ForEach(function(_, elem)
			if (target == "GearMask" and elem:get().Key:ToString() == "Mask") or 
			(target == "GearCowl" and elem:get().Key:ToString() == "Cowl") then
					--Set elem value to new gear bp
					elem:get().Value = newGearBp
					DebugLog(string.format("Successfully set new gear blueprint for: %s!", gearCDO:GetFName():ToString()))
			end
		end)

        DebugLog(string.format("Successfully set the new gear for: %s!", gearCDO:GetFName():ToString()))
    else
        error("[UBL] Retrieved mask class property is not valid! This should not be happening!\n")
    end
end

local function performGenVariableChange(newClass, interceptedBlueprint, target, charName)
	--Verify prop instance class is loaded (which it always should be)
	local propInstanceComponentClass = StaticFindObject("/Script/MKAnim.MKPropInstanceComponent")

	if not propInstanceComponentClass:IsValid() then
		error("[UBL] MKPropInstanceComponent class is not valid! This should not be happening!\n")
	end

	--Find provided blueprint class
	local newBlueprintClass

	if newClass ~= "None" then
		DebugLog(string.format("Looking for provided blueprint class: %s...", newClass))
		newBlueprintClass = FindObject("BlueprintGeneratedClass", newClass)
	else
		newBlueprintClass = FName("None")
	end

	if newClass ~= "None" and not newBlueprintClass:IsValid() then
		error("[UBL] Provided blueprint class is not a valid class! Make sure the blueprint class is loaded in by using the loadAssets function!\n")
	end

	DebugLog(string.format("New class: %s is valid!", newClass))

	--DebugLog(string.format("Looking for mask class, interceptedBp: %s, Mask class: %s", interceptedBlueprint:GetFName():ToString(), propInstanceComponentClass:GetFName():ToString()))

    local parentBlueprint = FindObject("BlueprintGeneratedClass", "BP_" .. charName .. "_Char_C")

    if not parentBlueprint:IsValid() then
        error("[UBL] Parent blueprint is not valid! This should not be happening!\n")
    end

    local genVariableComponent

	if target == "MaskClass" then
        genVariableComponent = FindObject(propInstanceComponentClass, interceptedBlueprint, "Mask_GEN_VARIABLE", true)

        if not genVariableComponent:IsValid() then
            DebugLog("Retrieved mask component is not valid! Trying for parent blueprint...")
    
            genVariableComponent = FindObject(propInstanceComponentClass, parentBlueprint, "Mask_GEN_VARIABLE", true)
    
            if not genVariableComponent:IsValid() then
                DebugLog("Retrieved mask component is not valid! Skipping...")
                return
            end
        end
    elseif target == "CowlClass" then
        genVariableComponent = FindObject(propInstanceComponentClass, parentBlueprint, "Cowl_GEN_VARIABLE", true)

        if not genVariableComponent:IsValid() then
            DebugLog("Retrieved cowl component is not valid! Skipping...")
            return
        end
    end
		
	--DebugLog(string.format("Mask component: %s is valid.", maskComponent:GetFName():ToString()))

	--Proceed to change prop class if all is good
	changePropClass(genVariableComponent, newBlueprintClass)
end

local function waitForGearCDO(gearBpClass, callback)
	LoopAsync(5, function()

		if not gearBpClass:IsValid() then
			callback(false)
			return true
		end

		local gearCDO = gearBpClass:GetCDO()

		if not gearCDO:IsValid() then
			DebugLog("Gear CDO not valid! Delaying...")
			return false
		end

		callback(true, gearCDO)
		return true
	end)
end

local function performOnceGearLoaded(gearBpClass, newGear, target)
	local gearCDO = gearBpClass:GetCDO()

	if not gearCDO:IsValid() then
		DebugLog("Gear CDO not valid! Delaying...")

		waitForGearCDO(gearBpClass, function(isValid, gearCDO)
			if isValid then
				local newGearBp

				if newGear ~= "None" then
					newGearBp = FindObject("BlueprintGeneratedClass", newGear)
			
					if not newGearBp:IsValid() then
						error(string.format("[UBL] Specified gear blueprint: %s is not valid! Please make sure you are specifying a valid gear blueprint, refer to the documentation for more information!", newGear))
					end
			
					DebugLog(string.format("Set newGearBp to: %s!", newGearBp:GetFName():ToString()))
				else
					--Set it to nothing
					newGearBp = FName("None")
				end
			
				--Proceed to gear change if all is good
				changeGear(gearCDO, newGearBp, target)
				return true
			end
		end)
	else
		local newGearBp

		if newGear ~= "None" then
			newGearBp = FindObject("BlueprintGeneratedClass", newGear)
	
			if not newGearBp:IsValid() then
				error(string.format("[UBL] Specified gear blueprint: %s is not valid! Please make sure you are specifying a valid gear blueprint, refer to the documentation for more information!", newGear))
			end
	
			DebugLog(string.format("Set newGearBp to: %s!", newGearBp:GetFName():ToString()))
		else
			--Set it to nothing
			newGearBp = FName("None")
		end
	
		--Proceed to gear change if all is good
		changeGear(gearCDO, newGearBp, target)
		return true
	end
end

local function performGearChange(targetGear, newGear, target)
    local gearBpClass = FindObject("BlueprintGeneratedClass", targetGear)

	if gearBpClass:IsValid() then
		performOnceGearLoaded(gearBpClass, newGear, target)
		return
	end

	WaitingBlueprintAssets[targetGear] = function(loadedGearBp)
		performOnceGearLoaded(loadedGearBp, newGear, target)
	end
end

local function performChange(_, params, interceptedBp)
	local interceptedBlueprint = interceptedBp

    for target, newTable in pairs(params) do
		DebugLog(string.format("Target: %s", target))

        if target == "MaskClass" or
        target == "CowlClass" then
            local newClass = newTable[1]
            local charName = newTable[2]

            --Do simple mask change
            performGenVariableChange(newClass, interceptedBlueprint, target, charName)
        elseif target == "GearMask" or
        target == "GearCowl" then
            local targetGear = newTable[1]
            local newGear = newTable[2]

            --Do gear "mask" change
            performGearChange(targetGear, newGear, target)
        end
    end
end

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

return performChange