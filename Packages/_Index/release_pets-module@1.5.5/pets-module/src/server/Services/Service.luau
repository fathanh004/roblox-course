--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

--|| Service ||--
local PetsService = Knit.CreateService({
	Name = "PetsService",

	Pets = {},
	PlayerPets = {},
	PlayerEquippedPets = {},

	MaxOwned = {},
	MaxEquipped = {},

	-- Events

	OnPetAdded = Signal.new(),
	OnPetRemoved = Signal.new(),

	OnMaxOwnedUpdated = Signal.new(),
	OnMaxEquippedUpdated = Signal.new(),

	OnPetsUpdated = Signal.new(),

	Client = {
		-- Added or removed from player's pets list
		OnPetAdded = Knit.CreateSignal(),
		OnPetRemoved = Knit.CreateSignal(),

		OnMaxOwnedUpdated = Knit.CreateSignal(),
		OnMaxEquippedUpdated = Knit.CreateSignal(),

		OnPetsUpdated = Knit.CreateSignal(),
		OnPlayerPetsUpdated = Knit.CreateSignal(),

		OnPetFollowDisabled = Knit.CreateSignal(),
		OnPetFollowEnabled = Knit.CreateSignal(),
	},
})

--|| Client Methods ||--

function PetsService.Client:EquipPet(player: Player, petUuid: string)
	return self.Server:EquipPet(player, petUuid)
end

function PetsService.Client:UnequipPet(player: Player, petUuid: string)
	return self.Server:UnequipPet(player, petUuid)
end

function PetsService.Client:EquipBestPets(player: Player)
	return self.Server:EquipBestPets(player)
end

function PetsService.Client:DeletePet(player: Player, petUuid: string)
	return self.Server:DeletePet(player, petUuid)
end

function PetsService.Client:GetPets(player: Player)
	return self.Server:GetPets(player)
end

function PetsService.Client:GetEquippedPets(player: Player)
	return self.Server:GetEquippedPets(player)
end

function PetsService.Client:GetMaxOwned(player: Player)
	return self.Server:GetMaxOwned(player)
end

function PetsService.Client:GetMaxEquipped(player: Player)
	return self.Server:GetMaxEquipped(player)
end

--|| Server Methods ||--

function PetsService:CreatePet(name: string, config: table)
	if not name or not config then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	if self.Pets[name] ~= nil then
		return error(Core.ErrorCodes.ALREADY_EXISTS)
	end

	self.Pets[name] = Core.Class.Pet.new(name, config.Power, config.Rarity, config.Movement)
	return self.Pets[name]
end

function PetsService:SetPets(player: Player, pets: table)
	if not player or not pets then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	self.PlayerPets[player] = pets
	self.OnPetsUpdated:Fire(player, self:GetPets(player), self:GetEquippedPets(player))
	self.Client.OnPetsUpdated:Fire(player, self:GetPets(player), self:GetEquippedPets(player))
end

function PetsService:SetEquippedPets(player: Player, pets: table)
	if not player or not pets then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	self.PlayerEquippedPets[player] = pets

	self.OnPetsUpdated:Fire(player, self:GetPets(player), self:GetEquippedPets(player))
	self.Client.OnPetsUpdated:Fire(player, self:GetPets(player), self:GetEquippedPets(player))
	self.Client.OnPlayerPetsUpdated:FireAll(player, self:GetEquippedPets(player))
end

function PetsService:AddPet(player: Player, name: string)
	if not player or not name then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	if self.Pets[name] == nil then
		return error(Core.ErrorCodes.NOT_FOUND)
	end

	if Core.Utils.Table.GetTableAmount(self:GetPets(player)) >= self:GetMaxOwned(player) then
		return error(Core.ErrorCodes.CANT_NOW)
	end

	local UUID = Core.Utils.GenerateGUID(2)
	self.PlayerPets[player][UUID] = self.Pets[name]

	if Core.Utils.IsPlayer(player) then
		self.OnPetAdded:Fire(player, self.PlayerPets[player][UUID])
		self.Client.OnPetAdded:Fire(player, UUID, self.PlayerPets[player][UUID])
	end

	return UUID
end

function PetsService:EquipPet(player: Player, petUuid: string)
	if not player or not petUuid then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	if self:GetPets(player) == nil or self:GetPets(player)[petUuid] == nil then
		return error(Core.ErrorCodes.NOT_FOUND)
	end

	if Core.Utils.Table.GetTableAmount(self:GetEquippedPets(player)) >= self:GetMaxEquipped(player) then
		return error(Core.ErrorCodes.CANT_NOW)
	end

	if self:GetEquippedPets(player)[petUuid] ~= nil then
		return error(Core.ErrorCodes.ALREADY_EXISTS)
	end

	self.PlayerEquippedPets[player][petUuid] = self:GetPets(player)[petUuid]

	if Core.Utils.IsPlayer(player) then
		self.OnPetsUpdated:Fire(player, self:GetPets(player), self:GetEquippedPets(player))
		self.Client.OnPetsUpdated:Fire(player, self:GetPets(player), self:GetEquippedPets(player))
	end

	self.Client.OnPlayerPetsUpdated:FireAll(player, self:GetEquippedPets(player))
end

function PetsService:UnequipPet(player: Player, petUuid: string)
	if not player or not petUuid then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	if self:GetPets(player) == nil or self:GetPets(player)[petUuid] == nil then
		return error(Core.ErrorCodes.NOT_FOUND)
	end

	if self:GetEquippedPets(player)[petUuid] == nil then
		return error(Core.ErrorCodes.NOT_FOUND)
	end

	self.PlayerEquippedPets[player][petUuid] = nil

	if Core.Utils.IsPlayer(player) then
		self.OnPetsUpdated:Fire(player, self:GetPets(player), self:GetEquippedPets(player))
		self.Client.OnPetsUpdated:Fire(player, self:GetPets(player), self:GetEquippedPets(player))
	end

	self.Client.OnPlayerPetsUpdated:FireAll(player, self:GetEquippedPets(player))
end

function PetsService:EquipBestPets(player: Player)
	if not player then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	for uuid, _ in self:GetEquippedPets(player) do
		self:UnequipPet(player, uuid)
	end

	local keys = {}
	for key in pairs(self:GetPets(player)) do
		table.insert(keys, key)
	end

	table.sort(keys, function(a, b)
		return self:GetPets(player)[a].Power > self:GetPets(player)[b].Power
	end)

	for i = 1, math.min(self:GetMaxEquipped(player), #keys) do
		local key = keys[i]
		self:EquipPet(player, key)
	end
end

function PetsService:DeletePet(player: Player, petUuid: string)
	if not player or not petUuid then
		warn("[Pets Module] - Missing or incorrect parameters.")
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	if self:GetPets(player) == nil or self:GetPets(player)[petUuid] == nil then
		return error(Core.ErrorCodes.NOT_FOUND)
	end

	local pet = self:GetPets(player)[petUuid]

	self.PlayerPets[player][petUuid] = nil
	self.PlayerEquippedPets[player][petUuid] = nil

	if Core.Utils.IsPlayer(player) then
		self.OnPetsUpdated:Fire(player, self:GetPets(player), self:GetEquippedPets(player))
		self.OnPetRemoved:Fire(player, pet)

		self.Client.OnPetsUpdated:Fire(player, self:GetPets(player), self:GetEquippedPets(player))
		self.Client.OnPetRemoved:Fire(player, petUuid)
	end

	self.Client.OnPlayerPetsUpdated:FireAll(player, self:GetEquippedPets(player))
end

function PetsService:GetPets(player: Player)
	if not player then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	if self.PlayerPets[player] == nil then
		self.PlayerPets[player] = {}
	end

	return self.PlayerPets[player]
end

function PetsService:GetEquippedPets(player: Player)
	if not player then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	if self.PlayerEquippedPets[player] == nil then
		self.PlayerEquippedPets[player] = {}
	end

	return self.PlayerEquippedPets[player]
end

function PetsService:SetMaxOwned(player: Player, max: number)
	if not player or not max then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	if self:GetMaxOwned(player) == max then
		return
	end

	if Core.Utils.IsPlayer(player) then
		self.OnMaxOwnedUpdated:Fire(player, max)
		self.Client.OnMaxOwnedUpdated:Fire(player, max)
	end

	self.MaxOwned[player] = max
end

function PetsService:SetMaxEquipped(player: Player, max: number)
	if not player or not max then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	if self:GetMaxEquipped(player) == max then
		return
	end

	if Core.Utils.IsPlayer(player) then
		self.OnMaxEquippedUpdated:Fire(player, max)
		self.Client.OnMaxEquippedUpdated:Fire(player, max)
	end

	self.MaxEquipped[player] = max
end

function PetsService:GetMaxOwned(player: Player)
	if not player then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	if self.MaxOwned[player] == nil then
		self.MaxOwned[player] = 70
	end

	return self.MaxOwned[player]
end

function PetsService:GetMaxEquipped(player: Player)
	if not player then
		warn("[Pets Module] - Missing or incorrect parameters.")
		return Core.ErrorCodes.MISSING_PARAMS
	end

	if self.MaxEquipped[player] == nil then
		self.MaxEquipped[player] = 4
	end

	return self.MaxEquipped[player]
end

function PetsService:DisableFollow(player: Player)
	if not player then
		warn("[Pets Module] - Missing or incorrect parameters.")
		return Core.ErrorCodes.MISSING_PARAMS
	end

	self.Client.OnPetFollowDisabled:FireAll(player)
end

function PetsService:EnableFollow(player: Player)
	if not player then
		warn("[Pets Module] - Missing or incorrect parameters.")
		return Core.ErrorCodes.MISSING_PARAMS
	end

	self.Client.OnPetFollowEnabled:FireAll(player)
end

--|| Knit Lifecycle ||--
function PetsService:KnitInit()
	local success, Configuration = pcall(function()
		return require(Core.Utils.FindChildFromPath(ReplicatedStorage, { "Shared", "Configs", "PetsModule.config" }))
	end)

	if not success then
		return warn("[ Pets Module ] - Missing configuratin, check documentation.")
	end

	for Name, Config in Configuration do
		if Config.Name ~= nil then
			self:CreatePet(Name, Config)
		end
	end
end

return PetsService
