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
local FightReducer = Rodux.createReducer({
	enemy = {},
}, {
	addEnemy = function(state, action)
		local newState = table.clone(state)
		table.insert(newState.enemy, action.enemy)
		return newState
	end,
})

return FightReducer
