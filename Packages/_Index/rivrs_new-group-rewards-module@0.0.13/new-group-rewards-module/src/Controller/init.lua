--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
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

local localPlayer = Players.LocalPlayer

--|| Knit Services ||--
local GroupRewardsService = nil

--|| Controller ||--
local Controller = Knit.CreateController({
	Name = "GroupRewardsController",
	RewardType = Enums.RewardType,
	Attributes = Attributes,

	Events = {
		OnLocalPlayerClaim = Signal.new(),
		OnLocalPlayerInGroup = Signal.new(),
	},
})

assert(game.CreatorType == Enum.CreatorType.Group, `This game is not hold by a group`)

local _groupId = game.CreatorId
local _lastClaimedTimestamp = {}
local _diffTime = nil

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

--|| Methods ||--
-- Get
function Controller:GetRewardTable(rewardType)
	if rewardType == Enums.RewardType.Chest then
		return Configuration.ChestRewards
	else
		error(`{rewardType} enum unknown`)
	end
end

function Controller:GetRewards(rewardType)
	local rewardTable = self:GetRewardTable(rewardType)
	local rewardsTable = GetTableKey(rewardTable, "Rewards", rewardTable)

	return rewardsTable
end

function Controller:GetRewardCooldown(rewardType)
	local rewardTable = self:GetRewardTable(rewardType)
	return GetTableKey(rewardTable, "Cooldown", rewardType)
end

function Controller:GetHitboxPath(rewardType)
	local rewardTable = self:GetRewardTable(rewardType)
	return GetTableKey(rewardTable, "HitboxPath", rewardTable, true)
end

function Controller:SetLastTimeClaim(rewardType, value)
	_lastClaimedTimestamp[rewardType] = value
end

function Controller:GetLastTimeClaim(rewardType)
	return _lastClaimedTimestamp[rewardType]
end

function Controller:GetServerTime()
	return os.time() + _diffTime
end

function Controller:GetTimeUntilNextReward(rewardType)
	local currentTimestamp = self:GetServerTime()
	local lastClaimTimestamp = self:GetLastTimeClaim(rewardType)
	local rewardCooldown = self:GetRewardCooldown(rewardType)

	local timeUntilNextReward = rewardCooldown - (currentTimestamp - lastClaimTimestamp)

	if timeUntilNextReward > 0 then
		return timeUntilNextReward
	else
		return 0
	end
end

function Controller:getFormattedTimeUntilNextReward(rewardType)
	local timeUntilNextReward = self:GetTimeUntilNextReward(rewardType)

	local hours = math.floor(timeUntilNextReward / 3600)
	local minutes = math.floor((timeUntilNextReward % 3600) / 60)
	local seconds = timeUntilNextReward % 60

	local formattedTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)

	return formattedTime
end

function Controller:GetGroupId()
	return _groupId
end

function Controller:LocalPlayerIsInGroup()
	return localPlayer:GetAttribute(self.Attributes.IsInGroup)
end

--|| Knit Lifecycle ||--
function Controller:KnitInit()
	-- normalize
	HandleConfiguration()

	-- Service
	GroupRewardsService = Knit.GetService("GroupRewardsService")

	GroupRewardsService.PlayerLastClaimTimeUpdated:Connect(function(rewardType, newValue)
		self:SetLastTimeClaim(rewardType, newValue)
	end)

	-- Events
	GroupRewardsService.OnPlayerClaim:Connect(function(rewardType)
		self.Events.OnLocalPlayerClaim:Fire(rewardType)
	end)

	localPlayer:GetAttributeChangedSignal(self.Attributes.IsInGroup):Connect(function()
		if self:LocalPlayerIsInGroup() then
			self.Events.OnLocalPlayerInGroup:Fire()
		end
	end)
end

function Controller:KnitStart()
	local start = tick()
	local sucessServerTime, serverTime = GroupRewardsService:GetServerTime():await()
	local ping = tick() - start

	if sucessServerTime then
		_diffTime = serverTime - os.time() + ping / 2
	end

	local sucessLastTimeClaimTable, times = GroupRewardsService:GetLocalPlayerLastTimeClaimTable():await()
	if sucessLastTimeClaimTable then
		for rewardType, value in times do
			self:SetLastTimeClaim(rewardType, value)
		end
	end
end

return Controller
