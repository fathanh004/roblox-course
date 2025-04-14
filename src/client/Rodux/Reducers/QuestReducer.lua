--[=[ 
	Owner: rompionyoann 
	Version: 0.0.1 
	Contact owner if any question, concern or feedback 
]=]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Rodux = require(game:GetService("ReplicatedStorage").Packages.Rodux)

-- local initialState = {
-- 	ActiveQuests = {
-- 		{ Name = "Gather Coins", Progress = 0, Goal = 3 },
-- 	},
-- }

local QuestReducer = Rodux.createReducer({
	activeQuests = {},
}, {
	updateQuest = function(state, action)
		local newState = table.clone(state)
		for _, quest in ipairs(newState.activeQuests) do
			if quest.Name == action.questName then
				quest.Progress = action.progress
			end
		end
		return newState
	end,
	addQuest = function(state, action)
		local newState = table.clone(state)
		table.insert(newState.activeQuests, {
			Name = action.questName,
			Progress = action.progress,
			Goal = action.goal,
			Status = "Not Finished",
		})
		return newState
	end,
	removeQuest = function(state, action)
		local newState = table.clone(state)
		for i, quest in ipairs(newState.activeQuests) do
			if quest.Name == action.questName then
				table.remove(newState.activeQuests, i)
				break
			end
		end
		return newState
	end,
	finishQuest = function(state, action)
		local newState = table.clone(state)
		for _, quest in ipairs(newState.activeQuests) do
			if quest.Name == action.questName then
				quest.Status = "Finished"
			end
		end
		return newState
	end,
})

return QuestReducer
