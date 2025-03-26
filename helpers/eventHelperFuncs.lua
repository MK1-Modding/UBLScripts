local HelperFunctions = {}


function HelperFunctions.changeOverrideMaterials(newOverrideMaterialsTable)
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

function HelperFunctions.addAddonMovesetCompatibility(charName, addonMovesetTable)
	local charDefinition = FindObject("CharacterContentDefinition", charName)

	if not charDefinition:IsValid() then
		error(string.format("Character definition for %s is not valid!", charName))
	end

	local addonMovesetsProperty = charDefinition:GetPropertyValue("mAddOnMovesets")

	if addonMovesetsProperty:IsValid() then
		DebugLog(string.format("Proceeding to add addon moveset to %s character definition", charName))

		local emptyTable = {{}}

		charDefinition:SetPropertyValue("mAddOnMovesets", emptyTable)

		--Retrieve addonMovesets property again
		addonMovesetsProperty = charDefinition:GetPropertyValue("mAddOnMovesets")

		addonMovesetsProperty[1].Mid = addonMovesetTable.Mid
		addonMovesetsProperty[1].mMoveset = addonMovesetTable.mMoveset
		addonMovesetsProperty[1].mSkin = addonMovesetTable.mSkin

		DebugLog(string.format("Successfully added addon moveset for %s!", charName))
	end
end

return HelperFunctions