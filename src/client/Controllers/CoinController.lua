-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Modules
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)
local Sound = require(Packages.Sound)
local VFX = require(Packages.VFX)
local Quest = require(Packages.Quest)

local CoinService

-- Assets
local GoldCoin = ReplicatedStorage.Assets.Coins.GoldCoin
local VFXFolder = ReplicatedStorage.Assets.VFX

-- Player
local player = Players.LocalPlayer

-- Menyimpan semua koneksi animasi dan status koin dalam tabel
local animationConnections = {}
local coinStates = {} -- Melacak status animasi tanpa menggunakan atribut
local dynamicTouchConnections = {} -- Menyimpan koneksi sentuhan untuk fase pergerakan dinamis

-- CoinController
local CoinController = Knit.CreateController({
	Name = "CoinController",

	-- Properti yang dapat dikonfigurasi (hanya visual, server yang mengatur spawn)
	HoverHeight = 0.5,
	HoverSpeed = 1,
	SpinSpeed = 1,
	CollectSpinSpeed = 3,
	BaseMovementSpeed = 30,
	SpeedIncreaseFactor = 1.5,
	CollectTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), -- Tween untuk pengambilan koin

	-- Properti internal
	_activeCoins = {}, -- Melacak koin berdasarkan ID
	_coinFolder = nil,
})

-- Fungsi animasi koin yang ditingkatkan
function CoinController:AnimateCoin(coin, coinId)
	local startTime = tick()
	local startY = coin.Position.Y

	-- Buat koneksi baru untuk koin ini
	local connection = RunService.Heartbeat:Connect(function()
		-- Hentikan jika koin sudah tidak ada
		if not coin or not coin.Parent then
			if animationConnections[coinId] then
				animationConnections[coinId]:Disconnect()
				animationConnections[coinId] = nil
			end
			return
		end

		-- Periksa jika koin sedang dikumpulkan
		if coinStates[coinId] and coinStates[coinId].collecting then
			if animationConnections[coinId] then
				animationConnections[coinId]:Disconnect()
				animationConnections[coinId] = nil
			end
			return
		end

		local currentTime = tick() - startTime

		-- Buat koin melayang naik turun
		local hoverY = startY + math.sin(currentTime * self.HoverSpeed) * self.HoverHeight

		-- Buat koin berputar
		local spinAngle = currentTime * self.SpinSpeed * 360

		-- Terapkan kedua animasi
		coin.CFrame = CFrame.new(coin.Position.X, hoverY, coin.Position.Z) * CFrame.Angles(0, math.rad(spinAngle), 0)
	end)

	-- Simpan koneksi ke dalam tabel
	animationConnections[coinId] = connection
end

-- Animasi pengambilan koin yang ditingkatkan
function CoinController:HandleCoinCollected(coinId, playerWhoCollected)
	local coinData = self._activeCoins[coinId]
	if not coinData or not coinData.instance then
		return
	end

	local coin = coinData.instance

	-- Tandai bahwa koin sedang dikumpulkan untuk menghentikan animasi normal
	if coinStates[coinId] then
		coinStates[coinId].collecting = true
	else
		coinStates[coinId] = { collecting = true, upwardComplete = false }
	end

	-- Hentikan animasi normal
	if animationConnections[coinId] then
		animationConnections[coinId]:Disconnect()
		animationConnections[coinId] = nil
	end

	-- Hanya mainkan animasi jika koin masih ada
	if coin and coin.Parent then
		-- Nonaktifkan collide
		if coin:IsA("BasePart") then
			coin.CanCollide = false
			if coin:FindFirstChild("TouchInterest") then
				coin.TouchInterest.Enabled = false
			end
		end

		-- Mainkan suara pengambilan
		Sound:PlayAndDestroySound("UI_CollectCoin", coin)

		-- Fase pertama: Buat koin terbang ke atas
		local initialPosition = coin.Position
		local upwardPosition = initialPosition + Vector3.new(0, 7, 0)

		-- Waktu mulai untuk animasi spin
		local spinStartTime = tick()

		-- Buat animasi spin cepat saat pengambilan
		local spinConnection
		spinConnection = RunService.Heartbeat:Connect(function()
			if not coin or not coin.Parent then
				if spinConnection then
					spinConnection:Disconnect()
				end
				return
			end

			if coinStates[coinId] and coinStates[coinId].upwardComplete then
				spinConnection:Disconnect()
				return
			end

			local currentTime = tick() - spinStartTime
			local spinAngle = currentTime * self.CollectSpinSpeed * 360

			local currentPos = coin.Position
			coin.CFrame = CFrame.new(currentPos) * CFrame.Angles(0, math.rad(spinAngle), 0)
		end)

		-- Buat tween gerakan ke atas
		local upwardTween = TweenService:Create(coin, self.CollectTweenInfo, {
			Position = upwardPosition,
			Size = coin.Size * 0.8,
			Transparency = 0.2,
		})

		-- Ketika tween selesai, bergerak menuju pemain atau menghilang
		upwardTween.Completed:Connect(function()
			if coinStates[coinId] then
				coinStates[coinId].upwardComplete = true
			else
				coinStates[coinId] = { collecting = true, upwardComplete = true }
			end

			if not coin or not coin.Parent then
				return
			end

			local character = playerWhoCollected.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				-- Fase kedua: Gerak dinamis ke arah pemain menggunakan RunService
				local moveSpeed = self.BaseMovementSpeed
				local shrinkRate = 0.7
				local finalTransparency = 0.8

				local dynamicStartTime = tick()
				local duration = 5.0
				local collectSpinStartTime = tick()

				local runServiceConnection
				runServiceConnection = RunService.Heartbeat:Connect(function(deltaTime)
					if not coin or not coin.Parent or not humanoidRootPart or not humanoidRootPart.Parent then
						if runServiceConnection then
							runServiceConnection:Disconnect()
						end
						if coin and coin.Parent then
							coin:Destroy()
						end

						self._activeCoins[coinId] = nil
						coinStates[coinId] = nil
						return
					end

					local timeInDynamicPhase = tick() - dynamicStartTime
					local currentSpeed = moveSpeed * (1 + timeInDynamicPhase * self.SpeedIncreaseFactor)
					local direction = (humanoidRootPart.Position - coin.Position).Unit
					local distanceToMove = currentSpeed * deltaTime
					local newPosition = coin.Position + direction * distanceToMove

					local currentSpinTime = tick() - collectSpinStartTime
					local spinAngle = currentSpinTime * self.CollectSpinSpeed * 2 * 360

					coin.CFrame = CFrame.new(newPosition) * CFrame.Angles(0, math.rad(spinAngle), 0)

					local elapsedTime = tick() - dynamicStartTime
					local progress = math.min(elapsedTime / duration, 1)

					coin.Size = coin.Size:Lerp(coin.Size * shrinkRate, progress * deltaTime * 10)
					coin.Transparency = math.min(
						coin.Transparency + (finalTransparency - coin.Transparency) * progress * deltaTime * 10,
						finalTransparency
					)

					if progress >= 1 or (humanoidRootPart.Position - coin.Position).Magnitude < 1 then
						runServiceConnection:Disconnect()

						task.spawn(function()
							VFX:Emit(
								VFXFolder.CollectCoin:FindFirstChild("Charge"),
								30,
								playerWhoCollected.Character.HumanoidRootPart,
								false
							)
						end)

						self._activeCoins[coinId] = nil
						coinStates[coinId] = nil
						coin:Destroy()
					end
				end)
			else
				-- Jika tidak ada karakter, animasikan hilang
				local fadeTween =
					TweenService:Create(coin, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = coin.Size * 0.5,
						Transparency = 1,
					})

				fadeTween.Completed:Connect(function()
					if coin and coin.Parent then
						coin:Destroy()
					end

					self._activeCoins[coinId] = nil
					coinStates[coinId] = nil
				end)

				fadeTween:Play()
			end
		end)

		upwardTween:Play()
	else
		self._activeCoins[coinId] = nil
		coinStates[coinId] = nil
	end
end

-- Membuat koin baru berdasarkan data dari server
function CoinController:SpawnCoin(coinId, coinPosition)
	if self._activeCoins[coinId] then
		return
	end

	local coin = GoldCoin:Clone()
	coin.Name = "Coin_" .. coinId
	coin.CFrame = coinPosition
	coin.Parent = self._coinFolder

	coinStates[coinId] = {
		collecting = false,
		upwardComplete = false,
	}

	Sound:PreloadSound("MISC_CollectCoin", coin)

	self._activeCoins[coinId] = {
		id = coinId,
		instance = coin,
	}

	self:AnimateCoin(coin, coinId)

	return coin
end

-- Menghapus semua koin dari dunia
function CoinController:ClearAllCoins()
	for coinId, coinData in pairs(self._activeCoins) do
		local coin = coinData.instance
		if coin and coin.Parent then
			Sound:DestroySound("MISC_CollectCoin", coin)
			if animationConnections[coinId] then
				animationConnections[coinId]:Disconnect()
				animationConnections[coinId] = nil
			end
			coin:Destroy()
		end
	end
	self._activeCoins = {}
	coinStates = {}

	for coinId, connection in pairs(dynamicTouchConnections) do
		if connection then
			connection:Disconnect()
		end
	end
	dynamicTouchConnections = {}
end

-- Dipanggil ketika Knit mulai
function CoinController:KnitStart()
	self._coinFolder = Instance.new("Folder")
	self._coinFolder.Name = "Coins"
	self._coinFolder.Parent = workspace

	-- Mengambil semua koin yang ada di server di awal join
	local existingCoins = CoinService:GetAllCoins()
	for _, coinData in ipairs(existingCoins) do
		self:SpawnCoin(coinData.id, coinData.position)
	end

	-- Menghubungkan event dari CoinService
	CoinService.CoinSpawned:Connect(function(coinId, coinPosition)
		self:SpawnCoin(coinId, coinPosition)
	end)

	CoinService.CoinCollected:Connect(function(coinId, playerWhoCollected)
		if coinId == "all" then
			self:ClearAllCoins()
			return
		end
		self:HandleCoinCollected(coinId, playerWhoCollected)
	end)

	Quest:RegisterEvents("OnQuestUpdated", function(name, quest)
		print("Quest diperbarui:", name, "Progres:", quest.Current, "/", quest.Quest.Goal)
	end)
end

function CoinController:KnitInit()
	CoinService = Knit.GetService("CoinService")
end

return CoinController
