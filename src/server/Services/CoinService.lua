-- Knit Packages
local MarketplaceService = game:GetService("MarketplaceService")
local PathfindingService = game:GetService("PathfindingService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataService
local FunnelsService = require(ReplicatedStorage.Packages.funnelsModule)
local QuestsService = require(ReplicatedStorage.Packages.Quest)

local Sound = require(ReplicatedStorage.Packages.Sound)
local VFX = require(ReplicatedStorage.Packages.VFX)

local CoinService = Knit.CreateService({
	Name = "CoinService",
	Client = {
		CoinsUpdated = Knit.CreateSignal(),
		CoinSpawned = Knit.CreateSignal(),
		CoinCollected = Knit.CreateSignal(),
	},

	-- Configurable properties
	SpawnRate = 1.5, -- Coins per second
	SpawnAreaX = 200, -- Area width in studs
	SpawnAreaZ = 200, -- Area depth in studs
	CoinHitboxSize = 2.3, -- Size of the hitbox in studs (configurable)

	-- Internal properties
	_spawnTimer = 0,
	_activeCoins = {}, -- Table to track all active coins by ID
	_nextCoinId = 1, -- Unique ID counter for coins
	_hitboxFolder = nil, -- Folder to store server-side hitboxes
})

--|| Client Functions ||--

function CoinService.Client:AddCoin(player: Player, value)
	return self.Server:AddCoin(player, value)
end

----|| Functions ||--

function CoinService:AddCoin(player, value)
	local playerData = DataService:GetData(player)

	if playerData then
		print(playerData.Diamonds)
		playerData.Coins += value
		self.Client.CoinsUpdated:Fire(player, playerData.Coins)
		FunnelsService:LogCustomEvent(player, "CoinCollected", playerData.Coins)
	end
end

-- Generate a random position for a coin
function CoinService:GenerateCoinPosition()
	-- Pick a random position
	local randomX = math.random(-self.SpawnAreaX / 2, self.SpawnAreaX / 2)
	local randomZ = math.random(-self.SpawnAreaZ / 2, self.SpawnAreaZ / 2)
	local height = 2 + math.random() -- Between 2-3 studs high

	local spawnPos = CFrame.new(0.000, 0.500, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000, 0.000, 0.000, 0.000, 1.000)
	local finalPos = spawnPos * CFrame.new(randomX, height, randomZ)

	return finalPos
end

-- Create a server-side hitbox for the coin
function CoinService:CreateHitbox(coinId, position)
	-- Create a hitbox part
	local hitbox = Instance.new("Part")
	hitbox.Name = "CoinHitbox_" .. coinId
	hitbox.Shape = Enum.PartType.Ball -- Use cylinder for better coin shape
	hitbox.Size = Vector3.new(self.CoinHitboxSize, self.CoinHitboxSize, self.CoinHitboxSize) -- Height is thin, diameter matches coin size
	hitbox.Orientation = Vector3.new(0, 0, 90) -- Lay cylinder flat
	hitbox.CFrame = position
	hitbox.Anchored = true
	hitbox.Massless = true
	hitbox.CanCollide = false -- Don't block movement
	hitbox.Transparency = 1 -- Invisible in game

	-- Add to hitbox folder
	hitbox.Parent = self._hitboxFolder

	-- Set up touch detection
	local touched = false -- Flag to prevent multiple rapid touches
	hitbox.Touched:Connect(function(hit)
		if touched then
			return
		end

		-- Check if it's a player character that touched the hitbox
		local hitPlayer = game.Players:GetPlayerFromCharacter(hit.Parent)
		if hitPlayer and self._activeCoins[coinId] then
			touched = true

			-- Process collection directly
			self:CollectCoin(hitPlayer, coinId)

			-- Allow another touch after a delay (in case collection fails)
			task.delay(1, function()
				touched = false
			end)
		end
	end)

	return hitbox
end

-- Spawn a new coin with server-side hitbox
function CoinService:SpawnCoin()
	local coinId = self._nextCoinId
	self._nextCoinId += 1

	-- Generate position for the coin
	local coinPosition = self:GenerateCoinPosition()

	-- Create server-side hitbox
	local hitbox = self:CreateHitbox(coinId, coinPosition)

	-- Store coin data on the server
	self._activeCoins[coinId] = {
		id = coinId,
		position = coinPosition,
		hitbox = hitbox,
		spawnTime = tick(),
	}

	-- Notify all clients about the new coin
	self.Client.CoinSpawned:FireAll(coinId, coinPosition)

	return coinId
end

-- Handle coin collection from a client touch or other collection method
function CoinService:CollectCoin(player, coinId)
	local coin = self._activeCoins[coinId]

	-- Make sure the coin exists and hasn't been collected
	if coin then
		-- Remove hitbox
		if coin.hitbox and coin.hitbox.Parent then
			coin.hitbox:Destroy()
		end

		-- Remove from tracking
		self._activeCoins[coinId] = nil

		-- Award coin to the player
		self:AddCoin(player, 10)
		QuestsService:IncreaseCount(player, "Gather Coins", 1)

		-- Notify all clients that this coin was collected
		self.Client.CoinCollected:FireAll(coinId, player)

		return true
	end

	return false
end

-- KNIT START
function CoinService:KnitStart()
	DataService = Knit.GetService("DataService")

	-- Create a folder on the server to store coin hitboxes
	self._hitboxFolder = Instance.new("Folder")
	self._hitboxFolder.Name = "CoinHitboxes"
	self._hitboxFolder.Parent = workspace

	-- Start the coin spawner loop on the server
	task.spawn(function()
		while true do
			task.wait(1 / self.SpawnRate)
			self:SpawnCoin()
		end
	end)

	local function characterAdded(player: Player, character: Instance)
		character.HumanoidRootPart.Anchored = false
		print(player.Name .. "'s character added")
	end

	local function playerAdded(player: Player)
		player.CharacterAdded:Connect(function(character)
			characterAdded(player, character)
		end)

		-- code playeradded
	end

	Players.PlayerAdded:Connect(playerAdded)
	for _, player in pairs(Players:GetChildren()) do
		playerAdded(player)
	end
end

-- Client calls this when they want to manually collect a coin (rarely needed now with server hitboxes)
function CoinService.Client:RequestCollectCoin(player, coinId)
	return self.Server:CollectCoin(player, coinId)
end

-- Get all current coins for a player who just joined
function CoinService.Client:GetAllCoins(player)
	local coinData = {}

	for id, coin in pairs(self.Server._activeCoins) do
		table.insert(coinData, {
			id = id,
			position = coin.position,
		})
	end

	return coinData
end

-- Remove all coins when the game ends or for reset
function CoinService:ClearAllCoins()
	for id, coinData in pairs(self._activeCoins) do
		if coinData.hitbox and coinData.hitbox.Parent then
			coinData.hitbox:Destroy()
		end
	end

	self._activeCoins = {}
	self.Client.CoinCollected:FireAll("all", nil) -- Signal clients to clear all coins
end

return CoinService
