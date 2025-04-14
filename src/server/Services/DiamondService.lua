-- Knit Packages
local MarketplaceService = game:GetService("MarketplaceService")
local PathfindingService = game:GetService("PathfindingService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

-- Services
local Players = game:GetService("Players")
local DataService

local DiamondService = Knit.CreateService({
	Name = "DiamondService",
	Client = {
		DiamondsUpdated = Knit.CreateSignal(),
	},
})

--|| Client Functions ||--

function DiamondService.Client:TestEvent(player: Player): boolean
	local playerData = DataService:GetData(player)

	return false
end

--|| Functions ||--

function DiamondService:AddDiamonds(player: Player, amount: number)
	local playerData = DataService:GetData(player)
	if playerData then
		playerData.Diamonds = playerData.Diamonds + amount
		self.Client.DiamondsUpdated:Fire(player, playerData.Diamonds)
	end
end

-- KNIT START
function DiamondService:KnitStart()
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

return DiamondService
