--|| Services ||--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--|| Imports ||--
local ImportFolder = ReplicatedStorage:FindFirstChild("Packages")

local src = script
while src and src.Name ~= "src" do
	src = src:FindFirstAncestorWhichIsA("Folder")
end

local function importPackage(name: string)
	local RootFolder = src and src:FindFirstAncestorWhichIsA("Folder") or nil

	return RootFolder and require(RootFolder[name]) or require(ImportFolder:FindFirstChild(name))
end

local Knit = importPackage("knit")
local Core = importPackage("core")
local Signal = importPackage("signal")

--|| Service ||--
local QuestsService = Knit.CreateService({
	Name = "QuestsService",

	OnQuestFinished = Signal.new(),

	Client = {
		OnQuestAdded = Knit.CreateSignal(),
		OnQuestRemoved = Knit.CreateSignal(),
		OnQuestUpdated = Knit.CreateSignal(),

		OnQuestFinished = Knit.CreateSignal(),
	},

	Configuration = nil,
	PlayerQuests = {},
})

--|| Client Methods ||--

function QuestsService.Client:GetQuests(player: Player)
	return self.Server:GetQuests(player)
end

function QuestsService.Client:GetQuest(player: Player, name: string)
	return self.Server:GetQuest(player, name)
end

--|| Server Methods ||--

function QuestsService:GetQuests(player: Player)
	if not player then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	if self.PlayerQuests[player] == nil then
		self.PlayerQuests[player] = {}
	end

	return self.PlayerQuests[player]
end

function QuestsService:GetQuest(player: Player, name: string)
	if not player or not name then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	if self:GetQuests(player) == nil or self:GetQuests(player)[name] == nil then
		return error(Core.ErrorCodes.NOT_FOUND)
	end

	return self:GetQuests(player)[name]
end

function QuestsService:SetQuests(player: Player, quests: table)
	if not player or not quests then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	self.PlayerQuests[player] = quests

	return self:GetQuests(player)
end

function QuestsService:AddQuest(player: Player, name: string)
	if not player or not name then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	local quests = self:GetQuests(player)

	if Core.Utils.Table.GetTableAmount(quests) == self.Configuration.MaxQuestsPerUser then
		return error(Core.ErrorCodes.CANT_NOW)
	end

	local Quest = self.Configuration.Quests[name]
	if Quest == nil then
		return error(Core.ErrorCodes.NOT_FOUND)
	end

	if quests[name] ~= nil then
		if quests[name].Status == "Finished" then
			print("Quest sudah diclaim dan selesai")
			return
		end
		return error(Core.ErrorCodes.ALREADY_EXISTS)
	end

	self.PlayerQuests[player][name] = {
		Current = 0,
		Quest = Quest,
	}

	if Core.Utils.IsPlayer(player) then
		self.Client.OnQuestAdded:Fire(player, name, quests[name])
	end
end

function QuestsService:RemoveQuest(player: Player, name: string)
	if not player or not name then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	local quests = self:GetQuests(player)

	if quests[name] == nil then
		return error(Core.ErrorCodes.NOT_FOUND)
	end

	self.PlayerQuests[player][name] = nil

	if Core.Utils.IsPlayer(player) then
		self.Client.OnQuestRemoved:Fire(player, name)
	end
end

function QuestsService:IncreaseCount(player: Player, questType: string, count: number)
	if not player or not questType or not count then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	local quests = self:GetQuests(player)

	for questName, infos in quests do
		if infos.Quest.Status == "Finished" then
			continue
		end
		if infos.Quest.Type == questType then
			self.PlayerQuests[player][questName].Current += count
			if Core.Utils.IsPlayer(player) then
				self.Client.OnQuestUpdated:Fire(player, questName, quests[questName])
			end

			if quests[questName].Current >= quests[questName].Quest.Goal then
				if Core.Utils.IsPlayer(player) then
					self.PlayerQuests[player][questName].Quest.Status = "Finished"
					self.OnQuestFinished:Fire(player, quests[questName].Quest)
					self.Client.OnQuestFinished:Fire(player, questName)
				end
			end
		end
	end
end

--|| Knit Lifecycle ||--
function QuestsService:KnitInit()
	self.Configuration =
		require(Core.Utils.FindChildFromPath(ReplicatedStorage, { "Shared", "Configs", "QuestsModule.config" }))

	if not self.Configuration then
		return error(Core.ErrorCodes.NOT_FOUND)
	end

	Players.PlayerRemoving:Connect(function(player: Player)
		task.delay(2, function()
			self.PlayerQuests[player] = nil
		end)
	end)
end

return QuestsService
