-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Store = require(StarterPlayer.StarterPlayerScripts.Client.Rodux.Store)

-- Actions
local Actions = StarterPlayer.StarterPlayerScripts.Client.Rodux.Actions
local CoinActions = require(Actions.CoinActions)
local QuestActions = require(Actions.QuestActions)
local DiamondActions = require(Actions.DiamondActions)
local FightActions = require(Actions.FightActions)
local BattleActions = require(Actions.BattleActions)
local Data = {}

function Data:Init()
	local CoinService = Knit.GetService("CoinService")
	local DataService = Knit.GetService("DataService")
	local QuestsService = Knit.GetService("QuestsService")
	local DiamondService = Knit.GetService("DiamondService")
	local FightService = Knit.GetService("FightService")
	local BattleService = Knit.GetService("BattleService")

	-- Ambil data pemain dari DataService dan set koin
	DataService:GetData():andThen(function(data)
		Store:dispatch(CoinActions.setCoins(data.Coins))
		Store:dispatch(DiamondActions.setDiamonds(data.Diamonds))
	end)

	-- Update koin dan progres quest saat koin berubah
	CoinService.CoinsUpdated:Connect(function(amount)
		Store:dispatch(CoinActions.setCoins(amount))
	end)

	QuestsService.OnQuestAdded:Connect(function(questName, quest)
		Store:dispatch(QuestActions.addQuest(questName, quest.Current, quest.Quest.Goal))
	end)

	-- Update progres quest saat quest diperbarui
	QuestsService.OnQuestUpdated:Connect(function(questName, quest)
		Store:dispatch(QuestActions.updateQuest(questName, quest.Current))
	end)

	QuestsService.OnQuestRemoved:Connect(function(questName)
		Store:dispatch(QuestActions.removeQuest(questName))
	end)

	QuestsService.OnQuestFinished:Connect(function(questName)
		Store:dispatch(QuestActions.finishQuest(questName))
	end)

	DiamondService.DiamondsUpdated:Connect(function(amount)
		Store:dispatch(DiamondActions.setDiamonds(amount))
	end)

	FightService.OnFightStarted:Connect(function(npcData)
		Store:dispatch(BattleActions.addEnemy(npcData))
	end)

	BattleService.OnNpcDamaged:Connect(function(npcName, currentHealth)
		Store:dispatch(BattleActions.updateEnemyHealth(npcName, currentHealth))
	end)

	BattleService.OnNpcDead:Connect(function(npcName)
		Store:dispatch(BattleActions.removeEnemy(npcName))
	end)
end

return Data
