--[=[ 
	Owner: CategoryTheory 
	Version: 0.0.1 
	Contact owner if any question, concern or feedback 
]=]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules

local Rodux = require(ReplicatedStorage.Packages.Rodux)

local QuestActions = {
	updateQuest = Rodux.makeActionCreator("updateQuest", function(questName, progress)
		return {
			questName = questName,
			progress = progress,
		}
	end),

	addQuest = Rodux.makeActionCreator("addQuest", function(questName, progress, goal)
		return {
			questName = questName,
			progress = progress,
			goal = goal,
		}
	end),

	removeQuest = Rodux.makeActionCreator("removeQuest", function(questName)
		return {
			questName = questName,
		}
	end),

	finishQuest = Rodux.makeActionCreator("finishQuest", function(questName)
		return {
			questName = questName,
		}
	end),
}

return QuestActions
