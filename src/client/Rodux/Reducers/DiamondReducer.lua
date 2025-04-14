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
local DiamondReducer = Rodux.createReducer({
	Diamonds = 0,
}, {
	setDiamonds = function(state, action)
		local newState = table.clone(state)
		newState.Diamonds = action.value
		return newState
	end,
})

return DiamondReducer
