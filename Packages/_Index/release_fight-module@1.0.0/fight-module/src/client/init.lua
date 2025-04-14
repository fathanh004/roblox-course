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

--|| Controller ||--
local FightController = Knit.CreateController({
	Name = "FightController",

	NPCs = {},
})

--|| Knit Services ||--
local FightService = nil

--|| Methods ||--
function FightController:RegisterEvents(eventName: string, callback: () -> any)
	if not eventName or not callback then
		warn("[Fight Controller] - Missing or incorrect parameters.")
		return Core.ErrorCodes.MISSING_PARAMS
	end

	if FightService[eventName] == nil then
		warn("[Settings Module] - Event not found.")
		return Core.ErrorCodes.NOT_FOUND
	end

	FightService[eventName]:Connect(callback)
end

--|| Knit Lifecycle ||--
function FightController:KnitInit()
	FightService = Knit.GetService("FightService")

	FightService.OnNpcCreated:Connect(function(NPC: table)
		self.NPCs[NPC.name] = NPC
	end)

	FightService.OnNpcUpdated:Connect(function(NPC: table)
		self.NPCs[NPC.name] = NPC
	end)
end

return FightController
