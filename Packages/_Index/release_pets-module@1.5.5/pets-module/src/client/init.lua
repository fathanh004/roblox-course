--|| Services ||--
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

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
local Core = importPackage("core")

local Update = require(script.Parent.Utils.Update)
local GridFunctions = require(script.Parent.Utils.GridFunctions)

--|| Knit Services ||--
local PetsService = nil

--|| Constants ||--
local RaycastExcludeModels = {}

--|| Controller ||--
local PetsController = Knit.CreateController({
	Name = "PetsController",

	Pets = {},
	PetInstances = {},
	PetsInSession = {},
	PetsVisible = true,

	PetsConfiguration = nil,

	PlayerPets = {},
	PlayerEquippedPets = {},
	FollowDisabledPlayers = {},

	MaxOwned = nil,
	MaxEquipped = nil,
})

--|| Methods ||--

function PetsController:SetPetsVisible(visible: boolean)
	if not visible then
		warn("[Pets Module] - Missing or incorrect parameters.")
		return Core.ErrorCodes.MISSING_PARAMS
	end

	self.PetsVisible = visible

	if self.PetsVisible then
		self:AddAllPets()
	else
		self:RemoveAllPets()
	end
end

function PetsController:RegisterEvents(eventName: string, callback: () -> any)
	if not eventName or not callback then
		warn("[Pets Module] - Missing or incorrect parameters.")
		return Core.ErrorCodes.MISSING_PARAMS
	end

	if PetsService[eventName] == nil then
		warn("[Pets Module] - Event not found.")
		return Core.ErrorCodes.NOT_FOUND
	end

	PetsService[eventName]:Connect(callback)
end

function PetsController:CreatePet(name: string, config: table)
	if not name or not config then
		warn("[Pets Module] - Missing or incorrect parameters.")
		return Core.ErrorCodes.MISSING_PARAMS
	end

	if self.Pets[name] ~= nil then
		warn("[Pets Module] - Pet already exists.")
		return Core.ErrorCodes.ALREADY_EXISTS
	end

	self.Pets[name] = Core.Class.Pet.new(name, config.Multiplier, config.Rarity, config.Movement)
	return self.Pets[name]
end

function PetsController:EquipPet(id: string)
	if not id then
		warn("[Pets Module] - Missing or incorrect parameters.")
		return Core.ErrorCodes.MISSING_PARAMS
	end

	local success, errorCode = PetsService:EquipPet(id):await()

	if success then
		return Core.ErrorCodes.SUCCESS
	end

	return errorCode
end

function PetsController:UnequipPet(id: string)
	if not id then
		warn("[Pets Module] - Missing or incorrect parameters.")
		return Core.ErrorCodes.MISSING_PARAMS
	end

	local success, errorCode = PetsService:UnequipPet(id):await()

	if success then
		return Core.ErrorCodes.SUCCESS
	end

	return errorCode
end

function PetsController:AddPets(player: Player, Pets: table)
	if not player or not Pets then
		warn("[Pets Module] - Missing or incorrect parameters.")
		return Core.ErrorCodes.MISSING_PARAMS
	end

	if not self.PetsInSession[player] then
		self.PetsInSession[player] = {}
	end

	local GeneratedPets = GridFunctions.GetGrids(Pets, self.PetsInSession[player], player)
	for i, v in GeneratedPets do
		if not self.PetsInSession[player][i] then
			self.PetsInSession[player][i] = v
		end
	end

	for i, _ in self.PetsInSession[player] do
		if not GeneratedPets[i] then
			self.PetsInSession[player][i] = nil
			if self.PetInstances:FindFirstChild(player.Name .. "_" .. tostring(i)) then
				self.PetInstances:FindFirstChild(player.Name .. "_" .. tostring(i)):Destroy()
			end
		end
	end
end

function PetsController:AddAllPets()
	task.spawn(function()
		for _, Player in Players:GetPlayers() do
			local _ = Player.Character or Player.CharacterAdded:Wait()
			local success, Pets = PetsService:GetEquippedPets(Player):await()
			if success and self.PetsVisible then
				self:AddPets(Player, Pets)
			end
		end
	end)
end

function PetsController:RespawnPets(pets: table)
	if self.PetsVisible then
		self:AddPets(Players.LocalPlayer, {})
		self:AddPets(Players.LocalPlayer, pets)
	end
end

function PetsController:RemoveAllPets()
	for _, p in Players:GetPlayers() do
		for i, _ in self.PetsInSession[p] do
			self.PetsInSession[p][i] = nil
			if self.PetInstances:FindFirstChild(p.Name .. "_" .. tostring(i)) then
				self.PetInstances:FindFirstChild(p.Name .. "_" .. tostring(i)):Destroy()
			end
		end
	end
end

function PetsController:GetPets()
	if next(self.PlayerPets) == nil then
		local success, pets = PetsService:GetPets():await()

		if success then
			self.PlayerPets = pets
			return self.PlayerPets
		end

		return {}
	end

	return self.PlayerPets
end

function PetsController:GetEquippedPets()
	if next(self.PlayerEquippedPets) == nil then
		local success, pets = PetsService:GetEquippedPets():await()

		if success then
			self.PlayerEquippedPets = pets
			return self.PlayerEquippedPets
		end

		return {}
	end

	return self.PlayerEquippedPets
end

function PetsController:GetMaxOwned()
	if self.MaxOwned == nil then
		local success, max = PetsService:GetMaxOwned():await()

		if success then
			self.MaxOwned = max
			return self.MaxOwned
		end

		return 70
	end

	return self.MaxOwned
end

function PetsController:GetMaxEquipped()
	if self.MaxEquipped == nil then
		local success, max = PetsService:GetMaxEquipped():await()

		if success then
			self.MaxEquipped = max
			return self.MaxEquipped
		end

		return 70
	end

	return self.MaxEquipped
end

--=============================================--
--=============================================--
--======                                 ======--
--======             EVENTS              ======--
--======                                 ======--
--=============================================--
--=============================================--

function PetsController:_handlePetAdded()
	task.spawn(function()
		self.PetInstances.ChildAdded:Connect(function(Pet: Model)
			local Name = Pet:GetAttribute("Pet")
			local PetConfig = self.PetsConfiguration[Name]

			if PetConfig and PetConfig.IdleAnim then
				local Animator = Pet:FindFirstChild("Animator", true)
				if Animator then
					local Animation = Instance.new("Animation")
					Animation.AnimationId = PetConfig.IdleAnim

					local Track = Animator:LoadAnimation(Animation)
					Track.Looped = true
					Track:Play()
				end
			end

			local PetName =
				Core.Utils.FindChildFromPath(ReplicatedStorage, self.PetsConfiguration.NameFramePath.Template)
			if not PetName then
				warn(
					"[Pets Module] - Missing PetName frame. ReplicatedStorage/"
						.. table.concat(
							self.PetsConfiguration.NameFramePath,
							"/",
							1,
							#self.PetsConfiguration.NameFramePath
						)
				)
				return Core.ErrorCodes.NOT_FOUND
			end

			PetName = PetName:Clone()
			PetName.Parent = Pet

			local NameTL = Core.Utils.FindChildFromPath(PetName, self.PetsConfiguration.NameFramePath.NameTextLabel)
			local RarityTL = Core.Utils.FindChildFromPath(PetName, self.PetsConfiguration.NameFramePath.RarityTextLabel)

			NameTL.Text = Name

			local SplittedName = string.split(Name, " ")
			if Core.Utils.GetColor(SplittedName[1]) ~= nil then
				NameTL.TextColor3 = Core.Utils.GetColor(SplittedName[1])
			end

			RarityTL.Text = self.Pets[Name].Rarity
			RarityTL.TextColor3 = Core.Utils.GetColor(RarityTL.Text)
		end)

		PetsService.OnPetAdded:Connect(function(uuid, pet)
			if self:GetPets()[uuid] == nil then
				self.PlayerPets[uuid] = pet
			end
		end)
	end)
end

function PetsController:_handlePetMove()
	task.spawn(function()
		RunService:BindToRenderStep("Pets", Enum.RenderPriority.Last.Value, function(Delta: number)
			if self.PetsVisible then
				Update(
					Delta,
					{
						GetTableAmount = Core.Utils.Table.GetTableAmount,
						GetAngleDistance = Core.Utils.Math.GetAngleDistance,
						DeepCopy = Core.Utils.Table.DeepCopy,
						GetPetModel = require(script.Parent.Utils.GetPetModel),
						ModelsPath = Core.Utils.FindChildFromPath(ReplicatedStorage, self.PetsConfiguration.ModelsPath),
					},
					self.PetsInSession,
					self.Pets,
					self.PetInstances,
					RaycastExcludeModels,
					self.FollowDisabledPlayers,
					self.PetsConfiguration.Settings
				)
			end
		end)
	end)
end

function PetsController:_handlePlayerAdded()
	task.spawn(function()
		self:AddAllPets()

		Players.PlayerAdded:Connect(function(player: Player)
			local success, Pets = PetsService:GetEquippedPets(player):await()
			if success and self.PetsVisible then
				self:AddPets(player, Pets)
			end
		end)
	end)
end

function PetsController:_handlePlayerRemove()
	task.spawn(function()
		Players.PlayerRemoving:Connect(function(player: Player)
			if self.PetsInSession[player] then
				local FoundPets = Core.Utils.Table.Filter(self.PetInstances:GetChildren(), function(Pet: Model)
					return Pet:GetAttribute("Owner") == player.Name
				end) :: { Model }

				for _, Pet in FoundPets do
					local ExcludeIndex = table.find(RaycastExcludeModels, Pet)
					if ExcludeIndex then
						table.remove(RaycastExcludeModels, ExcludeIndex)
					end

					Pet:Destroy()
				end

				for Index, Model in RaycastExcludeModels do
					if Model.Name == player.Name then
						table.remove(RaycastExcludeModels, Index)
					end
				end

				self.PetsInSession[player] = nil
			end
		end)
	end)
end

function PetsController:_handlePlayerPetsUpdated()
	task.spawn(function()
		PetsService.OnPlayerPetsUpdated:Connect(function(player: Player, pets: table)
			if self.PetsVisible then
				self:AddPets(player, pets)
			end
		end)
	end)
end

function PetsController:_handlePetsUpdated()
	task.spawn(function()
		PetsService.OnPetsUpdated:Connect(function(pets: table, equippedPets: table)
			self.PlayerPets = pets
			self.PlayerEquippedPets = equippedPets
		end)
	end)
end

function PetsController:_handleLimitsUpdated()
	task.spawn(function()
		PetsService.OnMaxOwnedUpdated:Connect(function(maxOwned: number)
			self.MaxOwned = maxOwned
		end)

		PetsService.OnMaxEquippedUpdated:Connect(function(maxEquipped: number)
			self.MaxEquipped = maxEquipped
		end)
	end)
end

function PetsController:_handleFollowUpdate()
	task.spawn(function()
		PetsService.OnPetFollowDisabled:Connect(function(player: Player)
			table.insert(self.FollowDisabledPlayers, player)
		end)

		PetsService.OnPetFollowEnabled:Connect(function(player: Player)
			local index = table.find(self.FollowDisabledPlayers, player)
			if index then
				table.remove(self.FollowDisabledPlayers, index)
			end
		end)
	end)
end

--|| Knit Lifecycle ||--
function PetsController:KnitInit()
	self.PetInstances = Instance.new("Model")
	self.PetInstances.Parent = workspace
	self.PetInstances.Name = "Pets"

	PetsService = Knit.GetService("PetsService")

	local success, Configuration = pcall(function()
		return require(Core.Utils.FindChildFromPath(ReplicatedStorage, { "Shared", "Configs", "PetsModule.config" }))
	end)

	if not success or not Configuration.Settings then
		return warn("[ Pets Module ] - Missing configuration, check documentation.")
	end

	self.PetsConfiguration = Configuration

	for Name, Config in self.PetsConfiguration do
		if Config.Name ~= nil then
			self:CreatePet(Name, Config)
		end
	end

	self:_handlePetAdded()
	self:_handlePetMove()
	self:_handlePlayerAdded()
	self:_handlePlayerRemove()
	self:_handlePlayerPetsUpdated()
	self:_handlePetsUpdated()
	self:_handleLimitsUpdated()
	self:_handleFollowUpdate()
end

return PetsController
