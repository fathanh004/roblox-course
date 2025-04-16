--[=[
 	Owner: CategoryTheory
 	Version: 0.0.1
 	Contact owner if any question, concern or feedback
 ]=]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Rodux = require(ReplicatedStorage.Packages.Rodux)

local PetActions = {
	addPet = Rodux.makeActionCreator("addPet", function(petUUID, pet)
		return {
			petUUID = petUUID,
			pet = pet,
		}
	end),
	setSomeType = Rodux.makeActionCreator("setSomeType", function(someType)
		return {
			someType = someType,
		}
	end),
}

return PetActions
