-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionsService = game:GetService("CollectionService")

-- Knit packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local QuestBoardService
local QuestsController

-- Player
local player = Players.LocalPlayer

-- QuestBoard
local QuestBoards = CollectionsService:GetTagged("QuestBoard")

-- TemplateController
local QuestBoardController = Knit.CreateController({
	Name = "QuestBoardController",
})

--|| Local Functions ||--

--|| Functions ||--
function QuestBoardController:GivePlayerQuest(questName)
	QuestBoardService:GivePlayerQuest(questName)
end

function QuestBoardController:KnitStart()
	for _, questBoard in pairs(QuestBoards) do
		local proximityPrompt = questBoard:FindFirstChildWhichIsA("ProximityPrompt")
		local questName = questBoard:GetAttribute("QuestName")
		if proximityPrompt and questName then
			proximityPrompt.Triggered:Connect(function(player)
				if player == Players.LocalPlayer then
					self:GivePlayerQuest(questName)
				end
			end)
		end
	end

	QuestsController:RegisterEvents("OnQuestFinished", function(name) end)
end

function QuestBoardController:KnitInit()
	QuestBoardService = Knit.GetService("QuestBoardService")
	QuestsController = Knit.GetController("QuestsController")
end

return QuestBoardController
