return function(Data: { [any]: any }, Path: Instance)
	local PetName = Data.Name
	local PetModel = Path:FindFirstChild(PetName, true)
	if PetModel == nil then
		warn("[Core Model] - Can't find pet model: " .. PetName)
		return
	end
	for _, v in PetModel:GetDescendants() do
		pcall(function()
			v.CanCollide = false
			v.CanQuery = false
		end)
	end
	return PetModel
end
