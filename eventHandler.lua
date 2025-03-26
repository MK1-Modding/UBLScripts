local HelperFunctions = require("helpers.eventHelperFuncs")

local funcTable = {
	Hair = { "SkeletalMesh" },
	Face = { "SkeletalMesh" },
	Body = { "SkeletalMesh" },
	ClothMesh = { "SkeletalMesh" },
	HavokCloth = { "ClothAsset" },
	Hair_ClothMesh = { "SkeletalMesh" },
	Hair_HavokCloth = { "ClothAsset" },
	AnimBlueprint = { "AnimClass" },
	OverrideMats = { "OverrideMaterials", HelperFunctions.changeOverrideMaterials },
	FacialAnims = { "FacialAnims" },
	Moveset = { "mScriptAsset" },
	AddonMoveset = { "MovesetScript" }
}

local function changeProperty(component, newAsset, targetMesh)
	local targetProperty = funcTable[targetMesh][1]
	local property = component:GetPropertyValue(targetProperty)

	if property:IsValid() or property == FName("None") then
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

local function performChange(className, alternativeClassName, newAssetClassName, componentName, alternativeName, newMesh, targetMesh, outer, simpleSearch)
	local class
	
	if className then
		class = StaticFindObject(className)

		if not class:IsValid() then
			error(string.format("[UBL] Class: %s is not valid! This should not be happening!\n", className))
		end
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

	local component
	
	--Default to self if no component name provided
	if componentName then
		--Simple or advanced search
		if simpleSearch then
			component = FindObject(class, componentName)
		else
			component = FindObject(class, outer, componentName, true)
		end
		
	else
		component = outer
	end

	if not component:IsValid() then
		local altClass

		--First, check for alt class name
		if alternativeClassName then
			DebugLog(string.format("[UBL] Retrieved component: %s is not valid! Trying alternative class name...\n", componentName))
			altClass = StaticFindObject(alternativeClassName)

			if not altClass:IsValid() then
				error(string.format("[UBL] Class: %s is not valid! This should not be happening!\n", alternativeClassName))
			end

			component = FindObject(altClass, outer, componentName, true)
		end

		--Then for alt name of the component itself
		if not component:IsValid() then
			if alternativeName then
				DebugLog(string.format("[UBL] Retrieved component: %s is not valid! Checking for alternative naming (Thanks NRS)...\n", componentName))
	
				component = FindObject(class, outer, alternativeName, true)
			end
		end

		--Final check (alt comp name and alt class name)
		if not component:IsValid() then
			if alternativeClassName and alternativeName then
				DebugLog(string.format("[UBL] Retrieved component: %s is not valid! Doing final check...\n", alternativeName))

				DebugLog(string.format("alt class: %s", altClass:GetFName():ToString()))
				component = FindObject(altClass, outer, alternativeName, true)
			end
		end

		if not component:IsValid() then
			error(string.format("[UBL] Retrieved component: %s is not valid! This should not be happening!\n", alternativeName))
		end
	end

	DebugLog(string.format("Component: %s is valid. Proceeding...", component:GetFName():ToString()))

	--Perform actual change
	changeProperty(component, newAsset, targetMesh)
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
						nil,
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
						nil,
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
						"/Script/HierarchicalAnimation.HierarchicalSkeletalMeshComponent",
						"SkeletalMesh",
						"ClothMesh_GEN_VARIABLE",
						"Cloth Mesh_GEN_VARIABLE",
						newMesh,
						targetMesh,
						interceptedBlueprint
					)
		elseif targetMesh == "Hair_HavokCloth" then
			performChange(
				"/Script/Dismemberment.DismembermentHavokClothComponent",
				nil,
				"HavokClothAsset",
				"Hair DismembermentHavokCloth_GEN_VARIABLE",
				nil,
				newMesh,
				targetMesh,
				interceptedBlueprint
			)
		elseif targetMesh == "Hair_ClothMesh" then
			performChange(
				"/Script/Engine.SkeletalMeshComponent",
				nil,
				"SkeletalMesh",
				"Hair ClothMesh_GEN_VARIABLE",
				"HairClothMesh_GEN_VARIABLE",
				newMesh,
				targetMesh,
				interceptedBlueprint
			)
		elseif targetMesh == "FacialAnims" then
			performChange(
						nil,
						nil,
						"MKAssetLibrary",
						nil,
						nil,
						newMesh,
						targetMesh,
						currentCDO
					)
		elseif targetMesh == "Moveset" then
			local charName = newMeshTable[2]

			performChange(
						"/Script/MK12.CharacterContentDefinition",
						nil,
						"MKScriptAsset",
						charName,
						nil,
						newMesh,
						targetMesh,
						nil,
						true
					)
		elseif targetMesh == "AddonMoveset" then
			local charName = newMeshTable[2]
			local addonMovesetTable = newMeshTable[1]

			HelperFunctions.addAddonMovesetCompatibility(charName, addonMovesetTable)
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
						nil,
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