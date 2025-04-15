--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- || Imports ||--

-- Knit & Core
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Knit = require(ReplicatedStorage.Packages.Knit)
--local Core = require(Packages:WaitForChild("Core"))

-- Modules
local Modules = script:FindFirstAncestor("src"):WaitForChild("Modules")

local Utils = require(Modules:WaitForChild("Utils"))
local Settings = require(Modules:WaitForChild("Settings"))

local CONFIG_MODULE_PATH = Settings.Path.Config

local ConfigurationModule = Utils.findByPath(ReplicatedStorage, CONFIG_MODULE_PATH)
local ConfigurationSource = require(ConfigurationModule)
local Configuration = nil

--|| Knit Services ||--

--|| Controller ||--
local Controller = Knit.CreateController({
	Name = "EggsController",
})

--|| Functions ||--
local function HandleConfiguration()
	Configuration = table.clone(ConfigurationSource)
	for _, eggTable in Configuration do
		Utils.normalizeChances(eggTable.Pets)
	end
end

local function GetEggTableKey(table, key, eggName)
	local value = table[key]

	if not value then
		error(`{key} not found in eggTable {eggName}`)
	end

	return value
end

--|| Methods ||--

-- Get
function Controller:GetEggTable(eggName)
	local eggTable = Configuration[eggName]
	if not eggTable then
		error(`{eggName} not found in configuration file.`)
	end

	return eggTable
end

function Controller:GetEggPrice(eggName)
	local eggTable = self:GetEggTable(eggName)
	return GetEggTableKey(eggTable, "Price", eggName)
end

function Controller:GetEggDisplayName(eggName)
	local eggTable = self:GetEggTable(eggName)
	return GetEggTableKey(eggTable, "DisplayName", eggName)
end

function Controller:GetEggName(eggName)
	local eggTable = self:GetEggTable(eggName)
	return GetEggTableKey(eggTable, "Name", eggName)
end

function Controller:GetEggCurrency(eggName)
	local eggTable = self:GetEggTable(eggName)
	return GetEggTableKey(eggTable, "Currency", eggName)
end

function Controller:GetEggDistrubution(eggName)
	local eggTable = self:GetEggTable(eggName)
	return GetEggTableKey(eggTable, "Pets", eggName)
end

-- Random
function Controller:GetEggRandomPet(eggName)
	local distribution = self:GetEggDistrubution(eggName)
	local pet = Utils.chooseRandomPet(distribution)

	return pet
end

function Controller:GetEggRandomPets(eggName, amount)
	local pets = {}

	for _ = 1, amount do
		local pet = self:GetEggRandomPet(eggName)
		table.insert(pets, pet)
	end

	return pets
end

--|| Knit Lifecycle ||--
function Controller:KnitInit()
	-- normalize
	HandleConfiguration()
end

function Controller:KnitStart() end

return Controller
