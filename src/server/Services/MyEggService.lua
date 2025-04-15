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

	Client = {},
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
		table.insert(self.EggsOwned[player], eggName)
		print("Player " .. player.Name .. " has received egg: " .. eggName)
	end
end

function MyEggService:HatchEgg(player, eggName)
	if not self.EggsOwned[player] then
		print("Player " .. player.Name .. " does not own any eggs.")
		return
	end

	local egg
	for i, ownedEgg in ipairs(self.EggsOwned[player]) do
		if ownedEgg == eggName then
			egg = ownedEgg
			if egg then
				-- Logic to hatch the egg and give the player a pet
				print("Hatching egg: " .. eggName .. " for player: " .. player.Name)
				local pet = EggsService:GetEggRandomPet(eggName)
				if pet then
					local petUUID = PetsService:AddPet(player, pet.Name)
					PetsService:EquipPet(player, petUUID)

					-- delete egg from player inventory
					table.remove(self.EggsOwned[player], i)
				else
					print("No pet found for egg: " .. eggName)
				end
			else
				print("Player " .. player.Name .. " does not own egg: " .. eggName)
			end
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
