--|| Services ||--
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--|| Imports ||--
local ImportFolder = ReplicatedStorage:FindFirstChild("Packages")

local src = script
while src and src.Name ~= "src" do
	src = src:FindFirstAncestorWhichIsA("Folder")
end

local function importPackage(name: string)
	local RootFolder = src and src:FindFirstAncestorWhichIsA("Folder") or nil

	return RootFolder and require(RootFolder[name]) or require(ImportFolder:FindFirstChild(name))
end

local Knit = importPackage("knit")
local Signal = importPackage("signal")
local Core = importPackage("core")

--|| FightService ||--
local FightService = Knit.CreateService({
	Name = "FightService",

	Fights = {},
	NPCs = {},

	OnFightWin = Signal.new(), -- Listen to this server side to be notified when player won fight.
	OnFightLoose = Signal.new(), -- Listen to this server side to be notified when player lost fight.
	OnPlayerDisconnect = Signal.new(), -- Listen to this server side to retrieve player NPCs configuration when he disconnects.

	Client = {
		OnFightStarted = Knit.CreateSignal(),
		OnFightWin = Knit.CreateSignal(),
		OnFightLoose = Knit.CreateSignal(),

		OnNpcCreated = Knit.CreateSignal(),
		OnNpcUpdated = Knit.CreateSignal(),
	},
})

--|| Client Methods ||--

function FightService.Client:Startfight(player: Player, npc: string)
	return self.Server:StartFight(player, npc)
end

function FightService.Client:EndFight(player: Player, npc: string, won: boolean)
	return self.Server:EndFight(player, npc, won)
end

--|| Server Methods ||--

function FightService:CreateNpc(player: Player, npcName: string, config: table)
	if not npcName or not config then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	if self.NPCs[player] == nil then
		self.NPCs[player] = {}
	end

	if self.NPCs[player][npcName] ~= nil then
		return error(Core.ErrorCodes.ALREADY_EXISTS)
	end

	self.NPCs[player][npcName] = Core.Class.NPC.new(npcName, config.Area, config.Power, config.Reward, config.Boss)
	self.Client.OnNpcCreated:Fire(player, self.NPCs[player][npcName])
	return self.NPCs[player][npcName]
end

function FightService:StartFight(player: Player, npc: string)
	if not player or not npc then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	if self.Fights[player] ~= nil then
		return error(Core.ErrorCodes.ALREADY_EXISTS)
	end

	local PlayerNPCs = self.NPCs[player]
	if PlayerNPCs == nil or PlayerNPCs[npc] == nil then
		return error(Core.ErrorCodes.CONFIG_ERROR)
	end

	local NPC = PlayerNPCs[npc]
	if NPC.model == nil then
		return error(Core.ErrorCodes.NOT_FOUND)
	end

	if NPC.fightable == false then
		return error(Core.ErrorCodes.CANT_NOW)
	end

	NPC.fightable = false

	self.Fights[player] = NPC

	if Core.Utils.IsPlayer(player) then
		self.Client.OnFightStarted:Fire(player, NPC)
		self.Client.OnNpcUpdated:Fire(player, NPC)
	end
end

function FightService:EndFight(player: Player, npc: string, won: boolean)
	if not player or not npc then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	if self.Fights[player] == nil then
		return error(Core.ErrorCodes.NOT_FOUND)
	end

	local PlayerNPCs = self.NPCs[player]

	if PlayerNPCs == nil or PlayerNPCs[npc] == nil then
		return error(Core.ErrorCodes.CONFIG_ERROR)
	end

	local NPC = self.Fights[player]
	if NPC.model == nil then
		return error(Core.ErrorCodes.NOT)
	end

	if NPC.name ~= npc or NPC.fightable == true then
		return error(Core.ErrorCodes.INTERNAL)
	end

	NPC.fightable = true

	self.Fights[player] = nil
	if won == true then
		NPC.beaten = true
		self.OnFightWin:Fire(player, NPC) -- Send to other services

		if Core.Utils.IsPlayer(player) then
			self.Client.OnFightWin:Fire(player, NPC) -- Send to client
		end
	else
		self.OnFightLoose:Fire(player, NPC) -- Send to other services

		if Core.Utils.IsPlayer(player) then
			self.Client.OnFightLoose:Fire(player, NPC) -- Send to client
		end
	end

	if Core.Utils.IsPlayer(player) then
		self.Client.OnNpcUpdated:Fire(player, NPC)
	end
end

function FightService:ConfigureNpc(player: Player, npc: string, config: table)
	if not player or not npc or not config then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	local PlayerNPCs = self.NPCs[player]
	if PlayerNPCs == nil or PlayerNPCs[npc] == nil then
		return error(Core.ErrorCodes.CONFIG_ERROR)
	end

	local NPC = self.NPCs[player][npc]
	NPC.fightable = true
	NPC.beaten = config.beaten

	NPC:LoadModel()

	self.NPCs[player][npc] = NPC
	if Core.Utils.IsPlayer(player) then
		self.Client.OnNpcUpdated:Fire(player, NPC)
	end
end

--|| Knit Lifecycle ||--

function FightService:KnitInit()
	local Configuration = require(ReplicatedStorage.Shared:FindFirstChild("FightModule.config", true))

	Players.PlayerAdded:Connect(function(player: Player)
		if Configuration then
			for NPC, Config in Configuration do
				local CreateNpc = self:CreateNpc(player, NPC, Config)
				self.Client.OnNpcCreated:Fire(player, CreateNpc)
				local npcModel = CreateNpc:LoadModel()
				if npcModel then
					CollectionService:AddTag(npcModel, "NPC")
					npcModel:SetAttribute("NpcName", NPC)
					local proximityPrompt = Instance.new("ProximityPrompt")
					proximityPrompt.ActionText = "Fight"
					proximityPrompt.ObjectText = NPC
					proximityPrompt.Parent = npcModel
				end
			end
		end
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		if self.NPCs[player] ~= nil then
			self.OnPlayerDisconnect:Fire(player, self.NPCs[player])
		end
	end)
end

return FightService
