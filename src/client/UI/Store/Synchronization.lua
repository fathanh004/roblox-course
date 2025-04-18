--|| Game Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--|| Module ||--
local Knit = require(ReplicatedStorage.Packages.Knit)
local UIModule = require(ReplicatedStorage.Packages.uiModule)

--|| Actions ||--
local Folder = script.Parent.Actions
local PlayerAction = require(Folder.PlayerAction)
local PetAction = require(Folder.PetAction)

--|| Synchronization ||--
local Sync = {}

function Sync.init()
	local Store = UIModule:GetGlobalStore()

	local DataService = Knit.GetService("DataService")
	local PetsService = Knit.GetService("PetsService")
	local CoinService = Knit.GetService("CoinService")
	local DiamondService = Knit.GetService("DiamondService")

	-- DataService.OnProfileInit:Connect(function(data: table)
	-- 	Store:dispatch(PlayerAction.setCoins(data.Coins))
	-- 	Store:dispatch(PlayerAction.setWins(data.Wins))
	-- 	Store:dispatch(PlayerAction.setSpins(data.Spins))
	-- end)
	DataService:GetData():andThen(function(data)
		Store:dispatch(PlayerAction.setCoins(data.Coins))
		Store:dispatch(PlayerAction.setDiamonds(data.Diamonds))
	end)

	DiamondService.DiamondsUpdated:Connect(function(amount)
		Store:dispatch(PlayerAction.setDiamonds(amount))
	end)

	CoinService.CoinsUpdated:Connect(function(amount)
		Store:dispatch(PlayerAction.setCoins(amount))
	end)

	PetsService.OnPetAdded:Connect(function(petUUID: string, pet: table)
		Store:dispatch(PetAction.addPet(petUUID, pet))
	end)
end

return Sync
