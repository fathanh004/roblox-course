-- Knit Packages
local MarketplaceService = game:GetService("MarketplaceService")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local Players = game:GetService("Players")
local DataService

local EggsService = require(ReplicatedStorage.Packages["rivrs-eggs-module"])
local PetsService = require(ReplicatedStorage.Packages.petsModule)

local MyEggService = Knit.CreateService({
	Name = "MyEggService",

	EggsOwned = {},

	Client = {
		OnStartHatchEgg = Knit.CreateSignal(),
		OnEndHatchEgg = Knit.CreateSignal(),
	},
})

--|| Client Functions ||--

function MyEggService.Client:TestEvent(player: Player): boolean
	local playerData = DataService:GetData(player)

	return false
end

function MyEggService.Client:AddPlayerEgg(player: Player, eggName: string)
	local playerData = DataService:GetData(player)

	if playerData then
		self.Server:AddPlayerEgg(player, eggName)
	end
end

function MyEggService.Client:HatchEgg(player: Player, eggName: string)
	local playerData = DataService:GetData(player)

	if playerData then
		self.Server:HatchEgg(player, eggName)
	end
end

--|| Functions ||--

function MyEggService:AddPlayerEgg(player, eggName)
	local eggTable = EggsService:GetEggTable(eggName)
	if eggTable then
		if not self.EggsOwned[player] then
			self.EggsOwned[player] = {}
		end
		table.insert(self.EggsOwned[player], eggTable)
		print("Player " .. player.Name .. " has received egg: " .. eggTable.Name)
	end
end

function MyEggService:HatchEgg(player, eggName)
	if not self.EggsOwned[player] or #self.EggsOwned[player] == 0 then
		print("Player " .. player.Name .. " does not own any eggs.")
		return
	end

	for i, ownedEgg in ipairs(self.EggsOwned[player]) do
		if ownedEgg.Name == eggName then
			local egg = ownedEgg
			local hatchTime = egg.HatchTime or 3 -- default ke 3 detik jika tidak ada

			-- Trigger start hatching visual
			self.Client.OnStartHatchEgg:Fire(player, ownedEgg.DisplayName, hatchTime)

			task.delay(hatchTime, function()
				local pet = EggsService:GetEggRandomPet(eggName)
				if pet then
					local petUUID = PetsService:AddPet(player, pet.Name)
					PetsService:EquipPet(player, petUUID)

					-- Hapus telur dari inventori
					table.remove(self.EggsOwned[player], i)

					-- Trigger end hatching visual
					self.Client.OnEndHatchEgg:Fire(player, eggName)
				else
					warn("No pet found for egg: " .. eggName)
				end
			end)

			break
		end
	end
end

-- KNIT START
function MyEggService:KnitStart()
	DataService = Knit.GetService("DataService")

	local function characterAdded(player: Player, character: Instance) end

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

return MyEggService
