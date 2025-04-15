--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GroupService = game:GetService("GroupService")
local Players = game:GetService("Players")

-- || Imports ||--

-- Knit & Core
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Knit = require(Packages:WaitForChild("knit"))
--local Core = require(Packages:WaitForChild("Core"))

-- Folders
local src = script:FindFirstAncestorWhichIsA("Folder")
local origin = src:FindFirstAncestorWhichIsA("Folder")
local Modules = src:WaitForChild("Modules")
-- Utils
local Signal = require(origin:FindFirstChild("Signal"))

-- Modules
local Utils = require(Modules:WaitForChild("Utils"))
local Settings = require(Modules:WaitForChild("Settings"))
local Enums = require(Modules:WaitForChild("Enums"))
local Attributes = require(Modules:WaitForChild("Attributes"))

local CONFIG_MODULE_PATH = Settings.Path.Config

local ConfigurationModule = Utils.findByPath(ReplicatedStorage, CONFIG_MODULE_PATH)
local ConfigurationSource = require(ConfigurationModule)
local Configuration = table.clone(ConfigurationSource)

local _RunContext = {
	IsStudio = RunService:IsStudio(),
	IsClient = RunService:IsClient(),
	IsServer = RunService:IsServer(),
}

--|| Knit Services ||--

--|| Service ||--
local Service = Knit.CreateService({
	Name = "GroupRewardsService",
	RewardType = Enums.RewardType,
	Attributes = Attributes,

	Events = {
		PlayerClaimReward = Signal.new(),
		PlayerLastClaimTimeUpdated = Signal.new(),
		OnPlayerRemoving = Signal.new(),
	},

	Client = {
		PlayerLastClaimTimeUpdated = Knit.CreateSignal(),
		OnPlayerClaim = Knit.CreateSignal(),
	},
})

assert(game.CreatorType == Enum.CreatorType.Group, `This game is not hold by a group`)
local _groupId = game.CreatorId
local _playersLastTimeClaim = {}
local _playersLastCheckDebounce = {}

--|| Functions ||--
local function HandleConfiguration()
	Configuration = table.clone(ConfigurationSource)
	table.freeze(Configuration)
end

local function GetTableKey(table, key, rewardType, canBeNil)
	local value = table[key]

	if not value and not canBeNil then
		error(`{key} not found in rewardTable {rewardType}`)
	end

	return value
end

--|| Client ||--
function Service.Client:GetLocalPlayerLastTimeClaimTable(player)
	return self.Server:GetPlayerLastTimeClaimTable(player)
end

function Service.Client:GetServerTime()
	return os.time()
end
--|| Methods ||--

-- Get
function Service:GetRewardTable(rewardType)
	if rewardType == Enums.RewardType.Chest then
		return Configuration.ChestRewards
	else
		error(`{rewardType} enum unknown`)
	end
end

function Service:GetRewards(rewardType)
	local rewardTable = self:GetRewardTable(rewardType)
	local rewardsTable = GetTableKey(rewardTable, "Rewards", rewardTable)

	return rewardsTable
end

function Service:GetRewardCooldown(rewardType)
	local rewardTable = self:GetRewardTable(rewardType)
	return GetTableKey(rewardTable, "Cooldown", rewardType)
end

function Service:GetHitboxPath(rewardType)
	local rewardTable = self:GetRewardTable(rewardType)
	return GetTableKey(rewardTable, "HitboxPath", rewardTable, true)
end

function Service:SetPlayerLastTimeClaimTable(player, value)
	local key = tostring(player.UserId)

	_playersLastTimeClaim[key] = value
end

function Service:RemovePlayerTable(player)
	self:SetPlayerLastTimeClaimTable(player, nil)
end

function Service:GetPlayerLastTimeClaimTable(player)
	local key = tostring(player.UserId)
	if not _playersLastTimeClaim[key] then
		_playersLastTimeClaim[key] = {}
	end

	return _playersLastTimeClaim[key]
end

function Service:GetPlayerLastTimeClaim(player, rewardType)
	return self:GetPlayerLastTimeClaimTable(player)[rewardType]
end

function Service:SetPlayerLastTimeClaim(player, rewardType, value)
	local table = self:GetPlayerLastTimeClaimTable(player)
	table[rewardType] = value
	self.Events.PlayerLastClaimTimeUpdated:Fire(player, rewardType)
end

function Service:ResetPlayerLastTimeClaim(player, rewardType)
	self:SetPlayerLastTimeClaim(player, rewardType, os.time())
end

function Service:CanPlayerClaim(player, rewardType)
	-- check if player is in group
	if not self:IsInGroup(player) then
		return false
	end

	-- check the time
	local rewardTable = self:GetRewardTable(rewardType)
	local rewardCooldown = GetTableKey(rewardTable, "Cooldown", rewardTable)

	local lastClaimTime = self:GetPlayerLastTimeClaim(player, rewardType)
	local currentTime = os.time()

	local timeElapsed = currentTime - lastClaimTime

	if timeElapsed < rewardCooldown then
		return false
	end

	return true
end

function Service:PlayerClaim(player, rewardType)
	self.Events.PlayerClaimReward:Fire(player, rewardType)
end

function Service:FireClient(player, rewardType)
	self.Client.OnPlayerClaim:Fire(player, rewardType)
end

function Service:CheckPlayerIsInGroup(player, checkDebounce)
	if checkDebounce and _playersLastCheckDebounce[player.UserId] then
		return self:IsInGroup(player)
	end

	_playersLastCheckDebounce[player.UserId] = true

	task.delay(Settings.Variables.IsInGroupRefreshTime, function()
		_playersLastCheckDebounce[player.UserId] = nil
	end)

	-- can't use :IsInGroup from the Server (cache) (https://create.roblox.com/docs/reference/engine/classes/Player#IsInGroup)
	local groups = GroupService:GetGroupsAsync(player.UserId)

	for _, groupInfo in groups do
		if groupInfo.Id == self:GetGroupId() then
			return true
		end
	end
	return false
end

function Service:IsInGroup(player)
	return player:GetAttribute(self.Attributes.IsInGroup)
end

function Service:SetPlayerIsInGroup(player, value)
	player:SetAttribute(self.Attributes.IsInGroup, value)
end

function Service:GetGroupId()
	return _groupId
end

--|| Knit Lifecycle ||--
function Service:KnitInit()
	-- normalize
	HandleConfiguration()

	-- connect parts
	for _, rewardType in Enums.RewardType do
		local partPath = self:GetHitboxPath(rewardType)
		local part = Utils.findByPath(game, partPath)

		if part and typeof(part) == "Instance" and part.ClassName == "Part" then
			Utils.connectCharacterInRegionEvent(part, function(_, player)
				if self:CanPlayerClaim(player, rewardType) then
					self:PlayerClaim(player, rewardType)
				end
			end, 5)
		end
	end

	-- events
	self.Events.PlayerLastClaimTimeUpdated:Connect(function(player, rewardType)
		local newTime = self:GetPlayerLastTimeClaim(player, rewardType)
		self.Client.PlayerLastClaimTimeUpdated:Fire(player, rewardType, newTime)
	end)

	Utils.connectPlayerAddedEvent(function(player)
		if self:CheckPlayerIsInGroup(player, true) then
			self:SetPlayerIsInGroup(player, true)
		end
	end)

	Utils.connectPlayerRemovingEvent(function(player)
		self.Events.OnPlayerRemoving:Fire(player, self:GetPlayerLastTimeClaimTable(player))
		self:RemovePlayerTable(player)
	end)

	task.spawn(function()
		while true do
			for _, player in Players:GetPlayers() do
				if not self:IsInGroup(player) then
					-- try to update
					if self:CheckPlayerIsInGroup(player, true) then
						self:SetPlayerIsInGroup(player, true)
					end
				end
			end
			task.wait(Settings.Variables.IsInGroupRefreshTime)
		end
	end)
end

function Service:KnitStart() end

return Service
