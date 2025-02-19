local function changeSkeletalMesh(meshComponent, newSkeletalMesh)
	--Retrieve skeletalMesh property
	local sm = meshComponent:GetPropertyValue("SkeletalMesh")
	
	if sm:IsValid() then
		meshComponent:SetPropertyValue("SkeletalMesh", newSkeletalMesh)
		
		if newSkeletalMesh ~= FName("None") then
			DebugLog(string.format("Successfully set the new skeletalMesh for: %s to be %s!", meshComponent:GetFName():ToString(), newSkeletalMesh:GetFName():ToString()))
		else
			DebugLog(string.format("Successfully set the new skeletalMesh for: %s to be 'None'!", meshComponent:GetFName():ToString()))
		end
	else
		error("Retrieved skeletalMesh is not valid!\n")
	end
end

local function changeAnimBlueprint(primaryMeshComponent, animClass)
	--Retrieve anim class property
	local animClassProperty = primaryMeshComponent:GetPropertyValue("AnimClass")
	
	if animClassProperty:IsValid() then
		primaryMeshComponent:SetPropertyValue("AnimClass", animClass)
		
		if animClass ~= FName("None") then
			DebugLog(string.format("Successfully set the new anim class for: %s to be %s!", primaryMeshComponent:GetFName():ToString(), animClass:GetFName():ToString()))
		else
			DebugLog(string.format("Successfully set the new anim class for: %s to be 'None'!", primaryMeshComponent:GetFName():ToString()))
		end
	else
		error("Retrieved anim class property is not valid!\n")
	end
end

local function changeHavokCloth(havokClothComponent, newHavokClothAsset)
	--Retrieve ClothAsset property
	local clothAsset = havokClothComponent:GetPropertyValue("ClothAsset")
	
	if clothAsset:IsValid() then
		havokClothComponent:SetPropertyValue("ClothAsset", newHavokClothAsset)
		
		if newHavokClothAsset ~= FName("None") then
			DebugLog(string.format("Successfully set the new havok cloth asset for: %s to be %s!", havokClothComponent:GetFName():ToString(), newHavokClothAsset:GetFName():ToString()))
		else
			DebugLog(string.format("Successfully set the new havok cloth asset for: %s to be 'None'!", havokClothComponent:GetFName():ToString()))
		end
	else
		error("Retrieved cloth asset property is not valid!\n")
	end
end

local function changeOverrideMaterials(meshComponent, newOverrideMaterialsTable)
	--Retrieve override materials
	local overrideMats = meshComponent:GetPropertyValue("OverrideMaterials")
	
	if overrideMats:IsValid() then
		local newOverrideMats = {}

		--Check mats table
		if #newOverrideMaterialsTable > 0 then
			DebugLog("Override mats table is not empty, proceed to populate...")

			for _, mat in pairs(newOverrideMaterialsTable) do
				--Check if value of none is provided
				if mat ~= "None" then
					local matClass = StaticFindObject("/Script/Engine.MaterialInstanceConstant")

					if not matClass:IsValid() then
						error("Mat class is not valid! This should not be happening!")
					end

					local matInstance = FindObject(matClass, nil, mat, true)

					--DebugLog(string.format("Mat name: %s, mat full path: %s", matInstance:GetFName():ToString(), matInstance:GetFullName()))

					if not matInstance:IsValid() then
						print(string.format("Material: %s is not valid! Make sure you are loading it through the loadAssets function beforehand!", mat))
					else
						table.insert(newOverrideMats, matInstance)
					end
				else
					table.insert(newOverrideMats, FName("None"))
				end
			end
		end

		meshComponent:SetPropertyValue("OverrideMaterials", newOverrideMats)
		
		DebugLog(string.format("Successfully set the new override materials for: %s!", meshComponent:GetFName():ToString()))
	end
end

--[[local function checkIfInGame()
	local mkGameModeManagers = FindAllOf("MKGameModeManager")
	local mkgmManager
	
	for _, mkManager in pairs(mkGameModeManagers) do
		if mkManager:IsValid() and mkManager:GetFName():ToString() ~= "Default__MKGameModeManager" then
			mkgmManager = mkManager
			DebugLog(string.format("Found proper game mode manager: %s", mkgmManager:GetFName():ToString()))
		end
	end
	
	local currentGms = mkgmManager:GetPropertyValue("mActiveGameModeStack")
	
	if currentGms:GetArrayNum() == 1 then
		--DebugLog("Player is in game.")
		return true
	end
	
	--DebugLog("Player is NOT in game.")
	return false
end]]

local function performAnimBlueprintChange(newAnimClass, CDO)
	local meshClass = StaticFindObject("/Script/HierarchicalAnimation.HierarchicalSkeletalMeshComponent")
	
	if not meshClass:IsValid() then
		error("[UBL] HierarchicalSkeletalMeshComponent class is not valid! This should not be happening!\n")
	end
	
	--Find primary mesh component
	local primaryMeshComponent = FindObject(meshClass, CDO, "PrimaryMeshComponent", true)
	
	if not primaryMeshComponent:IsValid() then
		error("[UBL] Retrieved primary mesh component is not valid! What???!\n")
	end
	
	--DebugLog(string.format("PrimaryMeshComponent: %s is valid.", primaryMeshComponent:GetFName():ToString()))
	
	--Look for new anim blueprint class
	local newAnimBpClass
	
	if newAnimBpClass ~= "None" then
		DebugLog(string.format("Looking for new anim class: %s...", newAnimClass))
		newAnimBpClass = FindObject("AnimBlueprintGeneratedClass", newAnimClass)
	else
		DebugLog("Setting anim class to 'None'")
		newAnimBpClass = FName("None")
	end

	
	if newAnimClass ~= "None" and not newAnimBpClass:IsValid() then
		error("[UBL] Retrieved anim class is not valid! Please make sure you are loading in the anim class beforehand (or load in the character blueprint itself)\n")
	end
	
	--Perform anim class change
	changeAnimBlueprint(primaryMeshComponent, newAnimBpClass)
end

local function performHavokClothAssetChange(newMesh, interceptedBlueprint)
	--Find havok cloth class
	local havokClass = StaticFindObject("/Script/Dismemberment.DismembermentHavokClothComponent")
	
	if not havokClass:IsValid() then
		error("[UBL] DismembermentHavokClothComponent class is not valid! This should not be happening!\n")
	end
	
	local newHavokClothAsset
	
	if newMesh ~= "None" then
		DebugLog(string.format("Looking for new havok cloth asset: %s...", newMesh))
		newHavokClothAsset = FindObject("HavokClothAsset", newMesh)
	else
		DebugLog("Setting havok cloth asset to 'None'")
		newHavokClothAsset = FName("None")
	end
	
	if newMesh ~= "None" and not newHavokClothAsset:IsValid() then
		error("[UBL] Provided havok cloth asset is not a valid! Make sure the asset is loaded in by using the loadAssets function!\n")
	end
	
	DebugLog(string.format("New havok cloth asset: %s is valid!", newMesh))
	
	local havokClothComponent = FindObject(havokClass, interceptedBlueprint, "DismembermentHavokCloth_GEN_VARIABLE", true)
	
	if not havokClothComponent:IsValid() then
		error("[UBL] Retrieved havok cloth component: %s is not valid! What???!\n")
	end
	
	DebugLog(string.format("Havok cloth component: %s is valid.", havokClothComponent:GetFName():ToString()))
	
	--Perform havok cloth asset change
	changeHavokCloth(havokClothComponent, newHavokClothAsset)
end

local function performClothAssetChange(newMesh, interceptedBlueprint)
	--Find skeletal mesh component class
	local skeletalMeshCompClass = StaticFindObject("/Script/Engine.SkeletalMeshComponent")
	
	if not skeletalMeshCompClass:IsValid() then
		error("[UBL] SkeletalMeshComponent class is not valid! This should not be happening!\n")
	end
	
	local newClothAsset
	
	if newMesh ~= "None" then
		DebugLog(string.format("Looking for new cloth asset: %s...", newMesh))
		newClothAsset = FindObject("SkeletalMesh", newMesh)
	else
		DebugLog("Setting cloth asset to 'None'")
		newClothAsset = FName("None")
	end
	
	if newMesh ~= "None" and not newClothAsset:IsValid() then
		error("[UBL] Provided cloth asset is not a valid! Make sure the asset is loaded in by using the loadAssets function!\n")
	end
	
	DebugLog(string.format("New cloth asset: %s is valid!", newMesh))
	
	local skeletalMeshComponent = FindObject(skeletalMeshCompClass, interceptedBlueprint, "ClothMesh_GEN_VARIABLE", true)
	
	if not skeletalMeshComponent:IsValid() then
		DebugLog("[UBL] Retrieved skeletal mesh component is not valid! Checking for alternative naming (Thanks NRS)...\n")
		
		skeletalMeshComponent = FindObject(skeletalMeshCompClass, interceptedBlueprint, "Cloth Mesh_GEN_VARIABLE", true)
		
		if not skeletalMeshComponent:IsValid() then
			error("[UBL] Retrieved skeletal mesh component: %s is not valid! What????!\n")
		end
	end
	
	DebugLog(string.format("Skeletal mesh component: %s is valid.", skeletalMeshComponent:GetFName():ToString()))
	
	--Perform cloth asset change
	changeSkeletalMesh(skeletalMeshComponent, newClothAsset)
end

local function performMeshChange(newMesh, targetMesh, interceptedBlueprint, currentCDO)
	local meshClass = StaticFindObject("/Script/HierarchicalAnimation.HierarchicalSkeletalMeshComponent")
				
	if not meshClass:IsValid() then
		error("[UBL] HierarchicalSkeletalMeshComponent class is not valid! This should not be happening!\n")
	end
	
	--Check if specified skeletal mesh is valid and loaded
	local newSkeletalMesh
	
	if newMesh ~= "None" then
		DebugLog(string.format("Looking for new skeletalmesh: %s...", newMesh))
		newSkeletalMesh = FindObject("SkeletalMesh", newMesh)
	else
		DebugLog("Setting mesh to 'None'")
		newSkeletalMesh = FName("None")
	end
	
	if newMesh ~= "None" and not newSkeletalMesh:IsValid() then
		error("[UBL] Provided mesh is not a valid mesh! Make sure the mesh is loaded in by using the loadAssets function!\n")
	end
	
	DebugLog(string.format("New skeletalmesh: %s is valid!", newMesh))
	
	local meshComponent
	
	--Identify what mesh we want to change
	if targetMesh == "Face" then
		--DebugLog(string.format("Looking for face mesh component, interceptedBP: %s, Mesh Class: %s", interceptedBlueprint:GetFName():ToString(), meshClass:GetFName():ToString()))
		meshComponent = FindObject(meshClass, interceptedBlueprint, "FaceMesh_GEN_VARIABLE", true)
	elseif targetMesh == "Body" then
		--DebugLog(string.format("Looking for body mesh component, CDO: %s, Mesh Class: %s", currentCDO:GetFName():ToString(), meshClass:GetFName():ToString()))
		meshComponent = FindObject(meshClass, currentCDO, "PrimaryMeshComponent", true)
	elseif targetMesh == "Hair" then
		--DebugLog(string.format("Looking for Hair mesh component, CDO: %s, Mesh Class: %s", interceptedBlueprint:GetFName():ToString(), meshClass:GetFName():ToString()))
		meshComponent = FindObject(meshClass, interceptedBlueprint, "Hair_GEN_VARIABLE", true)
	end
	
	if not meshComponent:IsValid() then
		DebugLog(string.format("[UBL] Retrieved mesh component: %s is not valid! Skipping...\n", targetMesh))
		return
	end
	
	--Proceed to change the mesh
	changeSkeletalMesh(meshComponent, newSkeletalMesh)
end

local function performOverrideMatsChange(overrideMatsTable, targetedMesh, CDO, interceptedBp)
	local meshComponentClass = StaticFindObject("/Script/HierarchicalAnimation.HierarchicalSkeletalMeshComponent")

	if not meshComponentClass:IsValid() then
		error("[UBL] HierarchicalSkeletalMeshComponent class is not valid! This should not be happening!\n")
	end

	local meshComponent

	--Do stuff based on what mesh we are targeting
	if targetedMesh == "Face" then
		meshComponent = FindObject(meshComponentClass, interceptedBp, "FaceMesh_GEN_VARIABLE", true)
	elseif targetedMesh == "Body" then
		meshComponent = FindObject(meshComponentClass, CDO, "PrimaryMeshComponent", true)
	elseif targetedMesh == "Hair" then
		meshComponent = FindObject(meshComponentClass, interceptedBp, "Hair_GEN_VARIABLE", true)
	elseif targetedMesh == "Cloth" then
		local skeletalMeshCompClass = StaticFindObject("/Script/Engine.SkeletalMeshComponent")
	
		if not skeletalMeshCompClass:IsValid() then
			error("[UBL] SkeletalMeshComponent class is not valid! This should not be happening!\n")
		end

		meshComponent = FindObject(skeletalMeshCompClass, interceptedBp, "ClothMesh_GEN_VARIABLE", true)
	
		if not meshComponent:IsValid() then
			DebugLog("[UBL] Retrieved skeletal mesh component is not valid! Checking for alternative naming (Thanks NRS)...\n")
			
			meshComponent = FindObject(skeletalMeshCompClass, interceptedBp, "Cloth Mesh_GEN_VARIABLE", true)
		end
	else
		error(string.format("[UBL] Targeted mesh: %s is not valid for ChangeOverrideMaterials! Please specify a valid target mesh!\n", targetedMesh))
	end

	--Ensure mesh comp is valid
	if not meshComponent:IsValid() then
		error("[UBL] Retrieved mesh component is not valid! This should not be happening!\n")
	end

	--Perform override mat change
	changeOverrideMaterials(meshComponent, overrideMatsTable)
end

local function performChange(CDO, meshParams, interceptedBp)
	local currentCDO = CDO
	local interceptedBlueprint = interceptedBp
	
	--Check specified meshes and change them if needed
	for targetMesh, newMeshTable in pairs(meshParams) do
		local newMesh = newMeshTable[1]
		
		if targetMesh == "OverrideMats" then
			local overrideMatsTable = newMesh
			local targetedMesh = newMeshTable[2]

			--Change override mats
			performOverrideMatsChange(overrideMatsTable, targetedMesh, currentCDO, interceptedBlueprint)
		elseif targetMesh == "AnimBlueprint" then
			--Do anim class change
			performAnimBlueprintChange(newMesh, currentCDO)
		elseif targetMesh == "HavokCloth" then
			--Do havok cloth asset change
			performHavokClothAssetChange(newMesh, interceptedBlueprint)
		elseif targetMesh == "ClothMesh" then
			--Do cloth asset change
			performClothAssetChange(newMesh, interceptedBlueprint)
		else
			--Do mesh changes
			performMeshChange(newMesh, targetMesh, interceptedBlueprint, currentCDO)
		end
	end
end

local function convertOverrideMats(overrideMats)
	local overrideMatsTable = {}

	overrideMats:ForEach(function(_, elem)
		table.insert(overrideMatsTable, elem:get():ToString())
	end)

	return overrideMatsTable
end

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

return performChange