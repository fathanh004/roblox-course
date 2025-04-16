--|| Game Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--|| Modules ||--
local Rodux = require(ReplicatedStorage.Packages.Rodux)

--|| Reducer ||--
return Rodux.createReducer({
	CurrentFrame = "HUD",
}, {
	setCurrentFrame = function(state, action)
		local newState = table.clone(state)
		newState.CurrentFrame = action.value
		return newState
	end,

	resetCurrentFrame = function(state, _)
		local newState = table.clone(state)
		newState.CurrentFrame = "HUD"
		return newState
	end,
})
