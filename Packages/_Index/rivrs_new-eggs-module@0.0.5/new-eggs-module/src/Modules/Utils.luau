local Utils = {}

function Utils.chooseRandomPet(pets)
	local randomValue = math.random()

	local cumulativeChance = 0
	for _, pet in ipairs(pets) do
		cumulativeChance = cumulativeChance + pet.Chance
		if randomValue <= cumulativeChance then
			return pet
		end
	end
	error(`Sums of weights not equal to 1, the table has not been normalized`)
end

function Utils.normalizeChances(pets)
	local totalChance = 0
	for _, pet in ipairs(pets) do
		totalChance = totalChance + pet.Chance
	end

	for _, pet in ipairs(pets) do
		pet.Chance = pet.Chance / totalChance
	end
end

function Utils.findByPath(parent: Instance, path: string, time: number?)
	local pathParts = string.split(path, "/")
	local instance = parent
	for _, pathPart in pathParts do
		local child
		if time then
			child = instance:WaitForChild(pathPart, time)
		else
			child = instance:FindFirstChild(pathPart)
		end
		if child == nil then
			error(`failed to find {pathPart} in {instance:GetFullName()} (full path: {path}`, 2)
		end
		instance = child
	end

	return instance
end

return Utils
