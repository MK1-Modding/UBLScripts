local function performBloodChange(CDO, bloodAssetParam)
	local UserData = CDO:GetPropertyValue("UserData")
	local bloodAsset = bloodAssetParam.bloodAsset
	
	if UserData then
		local bloodData = UserData.BloodProperties.BloodData
		
		DebugLog("Proceeding to change blood properties...")
		
		local bloodPropertiesInst = UserData.BloodProperties
		
		bloodPropertiesInst.BloodData = bloodAsset
		DebugLog(string.format("Successful blood replacement for: %s", string.gsub(bloodAsset:GetFName():ToString(), "_newBlood", "")))
		
		bloodData = CDO.UserData.BloodProperties.BloodData
		
		if CDO.UserData.BloodProperties.BloodData then
			DebugLog("BloodData is valid.")
		else
			error("Error: BloodData is nil or invalid.\n")
		end
		
		--Verify new colour
		if bloodData then
			DebugLog(string.format("New blood color: R:%f, G:%f, B:%f, A:%f\n", 
			bloodData.BloodColor.R, 
			bloodData.BloodColor.G, 
			bloodData.BloodColor.B,
			bloodData.BloodColor.A))
		else
			error("Invalid new blood data.\n")
		end
		
	else
		DebugLog(string.format("Cannot retrieve UserData!"))
	end
end

return performBloodChange