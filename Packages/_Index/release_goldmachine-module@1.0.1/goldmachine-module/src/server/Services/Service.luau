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
local PetsModule = importPackage("pets-module")

--|| Service ||--
local GoldMachineService = Knit.CreateService({
	Name = "GoldMachineService",

	PlayerCrafts = {},

	OnCraftSucceeded = Signal.new(),
	OnCraftFailed = Signal.new(),

	Client = {
		OnPetsUpdated = Knit.CreateSignal(),

		OnCraftSucceeded = Knit.CreateSignal(),
		OnCraftFailed = Knit.CreateSignal(),
	},
})

--|| Client Methods ||--

function GoldMachineService.Client:AddPet(player: Player, petUuid: string, petName: string)
	return self.Server:AddPet(player, petUuid, petName)
end

function GoldMachineService.Client:RemovePet(player: Player, petUuid: string)
	return self.Server:RemovePet(player, petUuid)
end

function GoldMachineService.Client:Craft(player: Player)
	return self.Server:Craft(player)
end

function GoldMachineService.Client:ClearCraft(player: Player)
	return self.Server:ClearCraft(player)
end

function GoldMachineService.Client:GetCraftPets(player: Player)
	return self.Server:GetCraftPets(player)
end

--|| Server Methods ||--

function GoldMachineService:AddPet(player: Player, petUuid: string)
	if not player or not petUuid then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	local pets = PetsModule:GetPets(player)

	local pet = pets[petUuid]
	if not pet then
		return error(Core.ErrorCodes.NOT_FOUND)
	end

	for _, name in self:GetCraftPets(player) do
		if name ~= pet.Name then
			return error(Core.ErrorCodes.NOT_FOUND)
		end
	end

	if Core.Utils.Table.GetTableAmount(self:GetCraftPets(player)) == 4 then
		return error(Core.ErrorCodes.CANT_NOW)
	end

	self.PlayerCrafts[player][petUuid] = pet.Name

	if Core.Utils.IsPlayer(player) then
		self.Client.OnPetsUpdated:Fire(player, self:GetCraftPets(player))
	end
end

function GoldMachineService:RemovePet(player: Player, petUuid: string)
	if not player or not petUuid then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	local pets = self:GetCraftPets(player)

	if pets[petUuid] == nil then
		return error(Core.ErrorCodes.NOT_FOUND)
	end

	self.PlayerCrafts[player][petUuid] = nil

	if Core.Utils.IsPlayer(player) then
		self.Client.OnPetsUpdated:Fire(player, self:GetCraftPets(player))
	end
end

function GoldMachineService:Craft(player: Player)
	if not player then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	local PetName = nil
	for _, name in self:GetCraftPets(player) do
		PetName = name
		break
	end

	local GoldName = "Gold " .. PetName
	local Chance = 25 * Core.Utils.Table.GetTableAmount(self:GetCraftPets(player))

	if PetsModule.Pets[GoldName] == nil then
		return error(Core.ErrorCodes.NOT_FOUND)
	end

	if math.random(1, 100) <= Chance then
		self.OnCraftSucceeded:Fire(player, self:GetCraftPets(player), PetsModule.Pets[GoldName])

		if Core.Utils.IsPlayer(player) then
			self.Client.OnCraftSucceeded:Fire(player, PetsModule.Pets[GoldName])
		end
	else
		self.OnCraftFailed:Fire(player, self:GetCraftPets(player))
		if Core.Utils.IsPlayer(player) then
			self.Client.OnCraftFailed:Fire(player, GoldName)
		end
	end

	self.PlayerCrafts[player] = nil

	if Core.Utils.IsPlayer(player) then
		self.Client.OnPetsUpdated:Fire(player, self:GetCraftPets(player))
	end
end

function GoldMachineService:ClearCraft(player: Player)
	if not player then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	self.PlayerCrafts[player] = nil

	if Core.Utils.IsPlayer(player) then
		self.Client.OnPetsUpdated:Fire(player, {})
	end
end

function GoldMachineService:GetCraftPets(player: Player)
	if not player then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	if self.PlayerCrafts[player] == nil then
		self.PlayerCrafts[player] = {}
	end

	return self.PlayerCrafts[player]
end

--|| Knit Lifecycle ||--
function GoldMachineService:KnitInit() end

return GoldMachineService
