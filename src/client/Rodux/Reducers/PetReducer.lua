--[=[
 	Owner: rompionyoann
 	Version: 0.0.1
 	Contact owner if any question, concern or feedback
 ]=]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Rodux = require(ReplicatedStorage.Packages.Rodux)

-- Reducer
local PetReducer = Rodux.createReducer({
	pets = {},
}, {
	setPets = function(state, action)
		local newState = table.clone(state)
		newState.pets = action.pets
		return newState
	end,
	addPet = function(state, action)
		local newState = table.clone(state)
		local pet = {
			uuid = action.petUUID,
			name = action.pet.Name,
			-- image = action.pet.Image,
		}
		table.insert(newState.pets, pet)
		return newState
	end,
	removePet = function(state, action)
		local newState = table.clone(state)
		for i, pet in ipairs(newState.pets) do
			if pet.uuid == action.petUUID then
				table.remove(newState.pets, i)
				break
			end
		end
		return newState
	end,
})

return PetReducer
