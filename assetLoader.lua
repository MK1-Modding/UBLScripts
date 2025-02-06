local assetTable = {}

local function isDuplicateAsset(asstTable, element)
	for _, asset in ipairs(asstTable) do
		if asset:ToString() == element:ToString() then
			--Duplicate asset
			return true
		end
	end
	
	return false
end

local function populateAssetTable(assetPaths)
	--Populate assetTable
	assetPaths:ForEach(function(index, elem)
		if not isDuplicateAsset(assetTable, elem:get()) then
			table.insert(assetTable, elem:get())
			--DebugLog(string.format("Inserted element: %s into assetTable.", elem:get():ToString()))
		end
	end)
end

RegisterCustomEvent("LoadAssets", function(ParamContext, ParamAssetPaths)
	local assetPaths = ParamAssetPaths:get()
	
	local expectedTypeTable = {
		assetPaths = "TArray"
	}
	
	local params = {
		assetPaths = assetPaths
	}
	
	ValidateTypes(expectedTypeTable, params)
	
	populateAssetTable(assetPaths)
end)

return assetTable