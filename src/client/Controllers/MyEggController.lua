-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

-- Knit packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local DataService
local MyEggService
local ActionController = require(ReplicatedStorage.Packages.actionModule)
local PetsController = require(ReplicatedStorage.Packages.petsModule)

-- Player
local player = Players.LocalPlayer

local Eggs = CollectionService:GetTagged("Egg")
local EggIncubator = CollectionService:GetTagged("EggIncubator")[1]

-- MyEggController
local MyEggController = Knit.CreateController({
	Name = "MyEggController",
})

--|| Local Functions ||--

--|| Functions ||--
function MyEggController:AddPlayerEgg(eggName: string)
	local playerData = DataService:GetData(player)

	if playerData then
		MyEggService:AddPlayerEgg(eggName)
	end
end

function MyEggController:HatchEgg(eggName: string)
	local playerData = DataService:GetData(player)

	if playerData then
		MyEggService:HatchEgg(eggName)
	end
end

function MyEggController:KnitStart()
	-- handle egg collection
	for _, egg in ipairs(Eggs) do
		local eggName = egg:GetAttribute("EggName")
		if eggName then
			--touch
			local touchPart = nil
			if egg:IsA("Part") or egg:IsA("MeshPart") then
				touchPart = egg
			else
				touchPart = egg:FindFirstChild("TouchPart")
			end
			if touchPart then
				touchPart.Touched:Connect(function(hit: Instance)
					local player = Players:GetPlayerFromCharacter(hit.Parent)
					if player then
						self:AddPlayerEgg(eggName)
						egg:Destroy()
					end
				end)
			end
		end
	end

	-- handle egg incubator
	if EggIncubator then
		local proximityPrompt = EggIncubator:FindFirstChild("ProximityPrompt")
		if proximityPrompt then
			proximityPrompt.Triggered:Connect(function(player: Player)
				self:HatchEgg("DefaultEgg")
			end)
		end
	end

	ActionController:RegisterEvents("OnActionPerformed", function(actionName)
		print("Action performed: " .. actionName)
		if actionName == "SummonPet" then
			PetsController:SetPetsVisible(true)
		end
	end)
end

function MyEggController:KnitInit()
	MyEggService = Knit.GetService("MyEggService")
	DataService = Knit.GetService("DataService")
end

return MyEggController
