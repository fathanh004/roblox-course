-- Knit Packages
local MarketplaceService = game:GetService("MarketplaceService")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Services
local Players = game:GetService("Players")
local DataService

local PetsService = require(ReplicatedStorage.Packages.petsModule)

local MyPetService = Knit.CreateService({
	Name = "MyPetService",
	Client = {},
})

--|| Client Functions ||--

function MyPetService.Client:TestEvent(player: Player): boolean
	local playerData = DataService:GetData(player)

	return false
end

-- KNIT START
function MyPetService:KnitStart()
	DataService = Knit.GetService("DataService")

	local function characterAdded(player: Player, character: Instance) end

	local function playerAdded(player: Player)
		player.CharacterAdded:Connect(function(character)
			characterAdded(player, character)
		end)

		-- code playeradded
		-- local playerPets = PetsService:GetPets(player)
		-- print("PlayerPets ", playerPets)

		-- local petUUID = PetsService:AddPet(player, "Dog")
		-- playerPets = PetsService:GetPets(player)
		-- print("PlayerPets ", playerPets)

		-- local equippedPets = PetsService:GetEquippedPets(player)
		-- print("EquippedPets ", equippedPets)

		-- PetsService:EquipPet(player, petUUID)
		-- equippedPets = PetsService:GetEquippedPets(player)
		-- print("EquippedPets ", equippedPets)
	end

	Players.PlayerAdded:Connect(playerAdded)
	for _, player in pairs(Players:GetChildren()) do
		playerAdded(player)
	end
end

return MyPetService
