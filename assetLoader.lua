local assetTables = {
	assetTable = {},
	mkAssetLibraryTable = {}
}

local function isDuplicateAsset(asstTable, element)
	for _, asset in ipairs(asstTable) do
		if asset:ToString() == element:ToString() then
			--Duplicate asset
			return true
		end
	end
	
	return false
end

local function populateAssetTable(assetTArray, assetTable)
	--Populate assetTable
	assetTArray:ForEach(function(_, elem)
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
	
	populateAssetTable(assetPaths, assetTables.assetTable)
end)

RegisterCustomEvent("LoadMKAssetLibraries", function(ParamContext, ParamMKAssetLibraries)
	local mkAssetLibraries = ParamMKAssetLibraries:get()
	
	local expectedTypeTable = {
		mkAssetLibraries = "TArray"
	}
	
	local params = {
		mkAssetLibraries = mkAssetLibraries
	}
	
	ValidateTypes(expectedTypeTable, params)
	
	populateAssetTable(mkAssetLibraries, assetTables.mkAssetLibraryTable)
end)

return assetTables