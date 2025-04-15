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
local Core = importPackage("core")
local PetsModule = importPackage("pets-module")

--|| Knit Services ||--
local GoldMachineService = nil

--|| Controller ||--
local GoldMachineController = Knit.CreateController({
	Name = "GoldMachineController",

	Pets = {},
})

--|| Methods ||--

function GoldMachineController:RegisterEvents(eventName: string, callback: () -> any)
	if not eventName or not callback then
		warn("[GoldMachine Module] - Missing or incorrect parameters.")
		return Core.ErrorCodes.MISSING_PARAMS
	end

	if not GoldMachineService[eventName] then
		warn("[GoldMachine Module] - Event not found.")
		return Core.ErrorCodes.NOT_FOUND
	end

	GoldMachineService[eventName]:Connect(callback)
end

function GoldMachineController:AddPet(petUuid: string)
	if not petUuid then
		warn("[GoldMachine Module] - Missing or incorrect parameters.")
		return Core.ErrorCodes.MISSING_PARAMS
	end

	local PlayerPets = PetsModule:GetPets()
	if PlayerPets[petUuid] == nil then
		warn("[GoldMachine Module] - Pet not found with UUID : " .. petUuid)
		return Core.ErrorCodes.NOT_FOUND
	end

	local success = pcall(function()
		return GoldMachineService:AddPet(petUuid):await()
	end)

	if success then
		self.Pets[petUuid] = PlayerPets[petUuid].Name
	end
end

function GoldMachineController:RemovePet(petUuid: string)
	if not petUuid then
		warn("[GoldMachine Module] - Missing or incorrect parameters.")
		return Core.ErrorCodes.MISSING_PARAMS
	end

	local success = pcall(function()
		return GoldMachineService:RemovePet(petUuid):await()
	end)

	if success then
		self.Pets[petUuid] = nil
	end
end

function GoldMachineController:Craft()
	if next(self.Pets) == nil then
		warn("[GoldMachine Module] - Can't craft if no pets.")
		return Core.ErrorCodes.NOT_FOUND
	end

	local success = pcall(function()
		return GoldMachineService:Craft():await()
	end)

	if success then
		self.Pets = {}
	end
end

function GoldMachineController:ClearCraft()
	if next(self.Pets) == nil then
		warn("[GoldMachine Module] - Can't clear craft if no pets.")
		return Core.ErrorCodes.NOT_FOUND
	end

	local success = pcall(function()
		return GoldMachineService:ClearCraft():await()
	end)

	if success then
		self.Pets = {}
	end
end

--|| Knit Lifecycle ||--
function GoldMachineController:KnitInit()
	GoldMachineService = Knit.GetService("GoldMachineService")
end

return GoldMachineController
