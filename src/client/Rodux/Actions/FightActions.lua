--[=[
 	Owner: CategoryTheory
 	Version: 0.0.1
 	Contact owner if any question, concern or feedback
 ]=]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Rodux = require(ReplicatedStorage.Packages.Rodux)

local FightActions = {
	addEnemy = Rodux.makeActionCreator("addEnemy", function(enemy)
		return {
			enemy = enemy,
		}
	end),
}

return FightActions
