--|| Game Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--|| Modules ||--
local Rodux = require(ReplicatedStorage.Packages.Rodux)

--|| Reducer ||--
return {
	setCoins = Rodux.makeActionCreator("setCoins", function(value)
		return { value = value }
	end),

	setDiamonds = Rodux.makeActionCreator("setDiamonds", function(value)
		return { value = value }
	end),

	setSpins = Rodux.makeActionCreator("setCoins", function(value)
		return { value = value }
	end),
}
