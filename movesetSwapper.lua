local function performMovesetChange(_, params)
    local moveset = params.Moveset
    local charName = params.CharName

    --Find character content definition
    local ccd = FindObject("CharacterContentDefinition", charName)

    if not ccd:IsValid() then
        error(string.format("[UBL] Could not find CharacterContentDefinition for: %s. This should not be happening!\n", charName))
    end

    --Find provided moveset asset
    local movesetScriptAsset = FindObject("MKScriptAsset", moveset)

    if not movesetScriptAsset:IsValid() then
        error(string.format("[UBL] Provided moveset: %s is not valid! Please make sure you are loading it through the loadAssets event!", moveset))
    end

    local scriptAssetProperty = ccd:GetPropertyValue("mScriptAsset")

    --Perform moveset swap
    DebugLog(string.format("Original mScriptAsset: %s", scriptAssetProperty:GetFName():ToString()))

    ccd:SetPropertyValue("mScriptAsset", movesetScriptAsset)

    DebugLog(string.format("New Script asset: %s", ccd.mScriptAsset:GetFName():ToString()))
    DebugLog("Successful moveset swap!")
end

return performMovesetChange