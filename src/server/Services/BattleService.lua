-- Knit Packages
local MarketplaceService = game:GetService("MarketplaceService")
local PathfindingService = game:GetService("PathfindingService")
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

-- Services
local Players = game:GetService("Players")
local DataService
local FightService = require(ReplicatedStorage.Packages.fightModule)

local BattleService = Knit.CreateService({
	Name = "BattleService",
	Enemies = {},
	Client = {
		OnNpcDamaged = Knit.CreateSignal(),
		OnNpcDead = Knit.CreateSignal(),
	},
})

--|| Client Functions ||--

function BattleService.Client:TestEvent(player: Player): boolean
	local playerData = DataService:GetData(player)

	return false
end

function BattleService.Client:FightNpc(player: Player, npcName: string): boolean
	local playerData = DataService:GetData(player)
	if playerData then
		self.Server:FightNpc(player, npcName)
		return true
	else
		return false
	end
end

function BattleService.Client:DamageEnemy(player: Player, npcName: string, damage: number): boolean
	local playerData = DataService:GetData(player)
	if playerData then
		self.Server:DamageEnemy(player, npcName, damage)
		return true
	else
		return false
	end
end

function BattleService.Client:AddNpcAsEnemy(player: Player, npcData: table): boolean
	local playerData = DataService:GetData(player)
	if playerData then
		self.Server:AddNpcAsEnemy(player, npcData)
		return true
	else
		return false
	end
end

--|| Server Functions ||--

function BattleService:AddNpcAsEnemy(player, npcData)
	self.Enemies[player] = self.Enemies[player] or {}
	table.insert(self.Enemies[player], {
		NpcData = npcData,
		CurrentHealth = 100,
		MaxHealth = 100,
	})
end

function BattleService:FightNpc(player, npcName)
	FightService:StartFight(player, npcName)
end

function BattleService:DamageEnemy(player, npcName, damage: number)
	if not self.Enemies[player] then
		return
	end
	local enemyTarget = nil
	for i, enemy in self.Enemies[player] do
		if enemy.NpcData.name == npcName then
			enemyTarget = enemy
			if enemyTarget then
				enemyTarget.CurrentHealth = enemyTarget.CurrentHealth - damage
				if enemyTarget.CurrentHealth <= 0 then
					enemyTarget.CurrentHealth = 0
					self.Client.OnNpcDamaged:Fire(player, enemyTarget.NpcData.name, enemyTarget.CurrentHealth)
					self.Client.OnNpcDead:Fire(player, npcName)
					self.Enemies[player][i] = nil -- Remove the defeated enemy from the list
				else
					self.Client.OnNpcDamaged:Fire(player, enemyTarget.NpcData.name, enemyTarget.CurrentHealth)
				end
			end
			break
		end
	end
end

-- KNIT START
function BattleService:KnitStart()
	DataService = Knit.GetService("DataService")

	local function characterAdded(player: Player, character: Instance) end

	local function playerAdded(player: Player)
		player.CharacterAdded:Connect(function(character)
			characterAdded(player, character)
		end)
	end

	Players.PlayerAdded:Connect(playerAdded)
	for _, player in pairs(Players:GetChildren()) do
		playerAdded(player)
	end
end

return BattleService
