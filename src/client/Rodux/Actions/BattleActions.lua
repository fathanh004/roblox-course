--[=[
 	Owner: CategoryTheory
 	Version: 0.0.1
 	Contact owner if any question, concern or feedback
 ]=]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Rodux = require(ReplicatedStorage.Packages.Rodux)

local BattleActions = {
	setEnemies = Rodux.makeActionCreator("setEnemies", function(enemies)
		return {
			enemies = enemies,
		}
	end),

	addEnemy = Rodux.makeActionCreator("addEnemy", function(npcData)
		return {
			npcData = npcData,
		}
	end),

	updateEnemyHealth = Rodux.makeActionCreator("updateEnemyHealth", function(npcName, currentHealth)
		return {
			npcName = npcName,
			currentHealth = currentHealth,
		}
	end),

	removeEnemy = Rodux.makeActionCreator("removeEnemy", function(npcName)
		return {
			npcName = npcName,
		}
	end),
}

return BattleActions
