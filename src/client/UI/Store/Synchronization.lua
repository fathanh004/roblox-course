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

	-- DataService.OnProfileInit:Connect(function(data: table)
	-- 	Store:dispatch(PlayerAction.setCoins(data.Coins))
	-- 	Store:dispatch(PlayerAction.setWins(data.Wins))
	-- 	Store:dispatch(PlayerAction.setSpins(data.Spins))
	-- end)

	PetsService.OnPetAdded:Connect(function(petUUID: string, pet: table)
		Store:dispatch(PetAction.addPet(petUUID, pet))
	end)
end

return Sync
