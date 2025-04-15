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
local function setEggTransparency(transparency: number)
	if EggIncubator then
		local egg = EggIncubator:FindFirstChild("Egg")
		if egg then
			egg.Transparency = transparency
		end
	end
end

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
				self:HatchEgg("CommonEgg")
			end)
		end
		setEggTransparency(1)
	end

	-- Handle egg hatching visuals
	local billboard = EggIncubator:FindFirstChildWhichIsA("BillboardGui")
	local eggNameLabel
	local timeLabel

	if billboard then
		eggNameLabel = billboard:FindFirstChild("EggName")
		if eggNameLabel and eggNameLabel:IsA("TextLabel") then
			eggNameLabel.Text = "Hatch Here!"
		end

		timeLabel = billboard:FindFirstChild("Time")
		if timeLabel and timeLabel:IsA("TextLabel") then
			timeLabel.Visible = false
			timeLabel.Text = ""
		end
	end

	MyEggService.OnStartHatchEgg:Connect(function(eggName: string, hatchTime: number)
		setEggTransparency(0)

		local billboard = EggIncubator:FindFirstChildWhichIsA("BillboardGui")
		if billboard and eggNameLabel and timeLabel then
			if eggNameLabel and eggNameLabel:IsA("TextLabel") then
				eggNameLabel.Text = eggName
			end

			if timeLabel and timeLabel:IsA("TextLabel") then
				-- Countdown logic
				local remaining = hatchTime
				timeLabel.Visible = true

				task.spawn(function()
					while remaining > 0 do
						timeLabel.Text = string.format("Hatching: %ds", remaining)
						task.wait(1)
						remaining -= 1
					end
					timeLabel.Text = "Ready!"
				end)
			end
		end
	end)

	MyEggService.OnEndHatchEgg:Connect(function()
		setEggTransparency(1)

		if billboard then
			if eggNameLabel and eggNameLabel:IsA("TextLabel") then
				eggNameLabel.Text = "Hatch Here!"
			end

			if timeLabel and timeLabel:IsA("TextLabel") then
				timeLabel.Visible = false
				timeLabel.Text = ""
			end
		end
	end)

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
