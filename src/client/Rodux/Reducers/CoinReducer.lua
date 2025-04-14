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
local CoinReducer = Rodux.createReducer({
	Coins = 0,
}, {
	setCoins = function(state, action)
		local newState = table.clone(state)
		newState.Coins = action.value
		return newState
	end,
})

return CoinReducer
