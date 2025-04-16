--|| Game Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--|| Modules ||--
local Rodux = require(ReplicatedStorage.Packages.Rodux)

--|| Reducer ||--
return {
	setCurrentFrame = Rodux.makeActionCreator("setCurrentFrame", function(value)
		return { value = value }
	end),

	resetCurrentFrame = Rodux.makeActionCreator("resetCurrentFrame", function(value)
		return { value = value }
	end),
}
