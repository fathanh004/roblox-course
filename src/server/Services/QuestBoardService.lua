-- Knit Packages
local MarketplaceService = game:GetService("MarketplaceService")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local Players = game:GetService("Players")
local DataService
local QuestsService
local FunnelsService
local DiamondService

local QuestBoardService = Knit.CreateService({
	Name = "QuestBoardService",
	Client = {},
})

--|| Client Functions ||--

function QuestBoardService.Client:TestEvent(player: Player): boolean
	local playerData = DataService:GetData(player)

	return false
end

function QuestBoardService.Client:GivePlayerQuest(player: Player, name: string)
	self.Server:GivePlayerQuest(player, name)
end

--|| Functions ||--
function QuestBoardService:GivePlayerQuest(player, name)
	QuestsService:AddQuest(player, name)
end

function QuestBoardService:GiveQuestReward(player, reward)
	if reward.Type == "Economy" then
		if reward.Economy == "Diamonds" then
			DiamondService:AddDiamonds(player, reward.Amount)
		end
	end
end

-- KNIT START
function QuestBoardService:KnitStart()
	DataService = Knit.GetService("DataService")
	QuestsService = Knit.GetService("QuestsService")
	FunnelsService = Knit.GetService("FunnelsService")
	DiamondService = Knit.GetService("DiamondService")

	QuestsService.OnQuestFinished:Connect(function(player, quest)
		self:GiveQuestReward(player, quest.Reward)
	end)

	local function characterAdded(player: Player, character: Instance) end

	local function playerAdded(player: Player)
		player.CharacterAdded:Connect(function(character)
			characterAdded(player, character)
		end)

		-- code playeradded
		FunnelsService:LogOnboardingStep(player, 2)
	end

	Players.PlayerAdded:Connect(playerAdded)
	for _, player in pairs(Players:GetChildren()) do
		playerAdded(player)
	end
end

return QuestBoardService
