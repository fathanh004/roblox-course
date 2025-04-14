-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionsService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")

-- Knit packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local FightController = require(ReplicatedStorage.Packages.fightModule)

local DataService
local BattleService

-- Npcs
local Npcs = CollectionsService:GetTagged("NPC")

-- Player
local player = Players.LocalPlayer

-- TemplateController
local BattleController = Knit.CreateController({
	Name = "BattleController",
})

--|| Local Functions ||--

--|| Functions ||--

function BattleController:DeleteDeadEnemy(npcName)
	for i, npc in Npcs do
		if npc:GetAttribute("NpcName") == npcName then
			npc:Destroy()
			break
		end
	end
end

function BattleController:FightNpc(npc)
	local npcName = npc:GetAttribute("NpcName")
	BattleService:FightNpc(npcName)
end

function BattleController:KnitStart()
	local targetNpc = nil

	-- Pantau posisi dekat NPC
	for _, npc in ipairs(Npcs) do
		local proximityPrompt = npc:FindFirstChildWhichIsA("ProximityPrompt")
		if proximityPrompt then
			proximityPrompt.Triggered:Connect(function()
				self:FightNpc(npc)
			end)
		end

		-- Periksa jika player mendekati NPC
		local regionPart = npc:FindFirstChild("Torso") or npc:FindFirstChild("HumanoidRootPart")
		if regionPart then
			task.spawn(function()
				while true do
					task.wait(0.2)
					if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
						local dist = (player.Character.HumanoidRootPart.Position - regionPart.Position).Magnitude
						if dist <= 10 then -- Dalam jarak 10 studs
							targetNpc = npc
						elseif targetNpc == npc then
							targetNpc = nil
						end
					end
				end
			end)
		end
	end

	-- Saat tombol E ditekan
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if input.KeyCode == Enum.KeyCode.F and targetNpc then
			BattleService:DamageEnemy(targetNpc:GetAttribute("NpcName"), 10)
		end
	end)

	FightController:RegisterEvents("OnFightStarted", function(npc)
		BattleService:AddNpcAsEnemy(npc)
	end)

	BattleService.OnNpcDead:Connect(function(npcName)
		self:DeleteDeadEnemy(npcName)
	end)
end

function BattleController:KnitInit()
	BattleService = Knit.GetService("BattleService")
	DataService = Knit.GetService("DataService")
end

return BattleController
