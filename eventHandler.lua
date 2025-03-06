local function changeOverrideMaterials(newOverrideMaterialsTable)
	local newOverrideMats = {}

	--Check mats table
	if #newOverrideMaterialsTable > 0 then
		DebugLog("Override mats table is not empty, proceed to populate...")

		for _, mat in pairs(newOverrideMaterialsTable) do
			--Check if value of none is provided
			if mat ~= "None" then
				local matInstanceClass = StaticFindObject("/Script/Engine.MaterialInstanceConstant")
				local matClass = StaticFindObject("/Script/Engine.Material")

				if not matInstanceClass:IsValid() then
					error("Mat Instance class is not valid! This should not be happening!")
				end

				if not matClass:IsValid() then
					error("Mat class is not valid! This should not be happening!")
				end

				local foundMaterial = FindObject(matInstanceClass, nil, mat, true)

				--DebugLog(string.format("Mat name: %s, mat full path: %s", matInstance:GetFName():ToString(), matInstance:GetFullName()))

				if not foundMaterial:IsValid() then
					--Try for normal mat class
					foundMaterial = FindObject(matClass, nil, mat, true)

					if not foundMaterial:IsValid() then
						print(string.format("Material: %s is not valid! Make sure you are loading it through the loadAssets function beforehand!", mat))
					end
				else
					table.insert(newOverrideMats, foundMaterial)
				end
			else
				table.insert(newOverrideMats, FName("None"))
			end
		end
	end

	return newOverrideMats
end

local funcTable = {
	Hair = { "SkeletalMesh" },
	Face = { "SkeletalMesh" },
	Body = { "SkeletalMesh" },
	ClothMesh = { "SkeletalMesh" },
	HavokCloth = { "ClothAsset" },
	AnimBlueprint = { "AnimClass" },
	OverrideMats = { "OverrideMaterials", changeOverrideMaterials }
}

local function changeProperty(component, newAsset, targetMesh)
	local targetProperty = funcTable[targetMesh][1]
	local property = component:GetPropertyValue(targetProperty)

	if property:IsValid() then
		local newPropertyValue

		--Do we need additional handling?
		if funcTable[targetMesh][2] then
			newPropertyValue = funcTable[targetMesh][2](newAsset)
		else
			newPropertyValue = newAsset
		end

		component:SetPropertyValue(targetProperty, newPropertyValue)

		DebugLog(string.format("Successfully set new property for: %s!", component:GetFName():ToString()))
	end
end

local function performChange(className, newAssetClassName, componentName, alternativeName, newMesh, targetMesh, outer)
	local class = StaticFindObject(className)

	if not class:IsValid() then
		error(string.format("[UBL] Class: %s is not valid! This should not be happening!\n", className))
	end

	local newAsset

	if type(newMesh) ~= "table" then
		if newMesh ~= "None" then
			DebugLog(string.format("Looking for new asset: %s...", newMesh))
			newAsset = FindObject(newAssetClassName, newMesh)
		else
			DebugLog("Setting asset to 'None'")
			newAsset = FName("None")
		end
	
		if newMesh ~= "None" and not newAsset:IsValid() then
			error(string.format("[UBL] Provided new asset: %s is not a valid! Make sure the asset is loaded in by using the loadAssets function!\n", newMesh))
		end
	
		DebugLog(string.format("New asset: %s is valid!", newMesh))
	else
		newAsset = newMesh
	end

	local component = FindObject(class, outer, componentName, true)

	if not component:IsValid() then
		if alternativeName then
			DebugLog(string.format("[UBL] Retrieved component: %s is not valid! Checking for alternative naming (Thanks NRS)...\n", componentName))

			component = FindObject(class, outer, alternativeName, true)
		end

		if not component:IsValid() then
			error(string.format("[UBL] Retrieved component: %s is not valid! This should not be happening!\n", componentName))
		end
	end

	DebugLog(string.format("Component: %s is valid. Proceeding...", component:GetFName():ToString()))

	--Perform actual change
	changeProperty(component, newAsset, targetMesh)
end

local function performFacialAnimsChange(newFacialAnims, CDO)
	local newFacialAnimsAsset = FindObject("MKAssetLibrary", newFacialAnims)

	if not newFacialAnimsAsset:IsValid() then
		print(string.format("[UBL] Provided new facial anims asset: %s is not valid! Make sure you are loading it through the LoadAssets function first!\n", newFacialAnims))
	end

	local currentFacialAnims = CDO:GetPropertyValue("FacialAnims")

	if currentFacialAnims:IsValid() then
		CDO:SetPropertyValue("FacialAnims", newFacialAnimsAsset)
		DebugLog(string.format("Successfully set new facial anims asset to: %s!", newFacialAnimsAsset:GetFName():ToString()))
	end
end

local function handleEvents(CDO, meshParams, interceptedBp)
	local currentCDO = CDO
	local interceptedBlueprint = interceptedBp
	
	--Check specified meshes and change them if needed
	for targetMesh, newMeshTable in pairs(meshParams) do
		local newMesh = newMeshTable[1]
		
		if targetMesh == "OverrideMats" then
			local overrideMatsTable = newMesh
			local targetedMesh = newMeshTable[2]

			local componentClass = "/Script/HierarchicalAnimation.HierarchicalSkeletalMeshComponent"
			local componentName
			local outer = interceptedBlueprint
			local alternativeName = nil

			if targetedMesh == "Hair" then
				componentName = "Hair_GEN_VARIABLE"
			elseif targetedMesh == "Face" then
				componentName = "FaceMesh_GEN_VARIABLE"
			elseif targetedMesh == "Body" then
				componentName = "PrimaryMeshComponent"
				outer = currentCDO
			elseif targetedMesh == "Cloth" then
				componentName = "ClothMesh_GEN_VARIABLE"
				componentClass = "/Script/Engine.SkeletalMeshComponent"
				alternativeName = "Cloth Mesh_GEN_VARIABLE"
			end

			performChange(
						componentClass,
						nil,
						componentName,
						alternativeName,
						overrideMatsTable,
						targetMesh,
						outer
					)
		elseif targetMesh == "AnimBlueprint" then
			performChange(
						"/Script/HierarchicalAnimation.HierarchicalSkeletalMeshComponent",
						"AnimBlueprintGeneratedClass",
						"PrimaryMeshComponent",
						nil,
						newMesh,
						targetMesh,
						currentCDO
					)
		elseif targetMesh == "HavokCloth" then
			performChange(
						"/Script/Dismemberment.DismembermentHavokClothComponent",
						"HavokClothAsset",
						"DismembermentHavokCloth_GEN_VARIABLE",
						nil,
						newMesh,
						targetMesh,
						interceptedBlueprint
					)
		elseif targetMesh == "ClothMesh" then
			performChange(
						"/Script/Engine.SkeletalMeshComponent",
						"SkeletalMesh",
						"ClothMesh_GEN_VARIABLE",
						"Cloth Mesh_GEN_VARIABLE",
						newMesh,
						targetMesh,
						interceptedBlueprint
					)
		elseif targetMesh == "FacialAnims" then
			performFacialAnimsChange(newMesh, currentCDO)
		else
			local componentName
			local outer = interceptedBlueprint

			if targetMesh == "Hair" then
				componentName = "Hair_GEN_VARIABLE"
			elseif targetMesh == "Face" then
				componentName = "FaceMesh_GEN_VARIABLE"
			elseif targetMesh == "Body" then
				componentName = "PrimaryMeshComponent"
				outer = currentCDO
			end

			performChange(
						"/Script/HierarchicalAnimation.HierarchicalSkeletalMeshComponent",
						"SkeletalMesh",
						componentName,
						nil,
						newMesh,
						targetMesh,
						outer
					)
		end
	end
end

return handleEvents