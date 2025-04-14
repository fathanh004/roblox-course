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

--|| Knit Services ||--
local QuestsService = nil

--|| Controller ||--
local QuestsController = Knit.CreateController({
	Name = "QuestsController",

	Quests = {},
})

--|| Methods ||--

function QuestsController:GetQuests()
	if next(self.Quests) == nil then
		local success, quests = QuestsService:GetQuests():await()

		if success then
			self.Quests = quests
			return self.Quests
		end
	end

	return self.Quests
end

function QuestsController:GetQuest(name: string)
	local Quests = self:GetQuests()
	return Quests[name] or Core.ErrorCodes.NOT_FOUND
end

function QuestsController:RegisterEvents(eventName: string, callback: () -> any)
	if not eventName or not callback then
		warn("[Quests Module] - Missing or incorrect parameters.")
		return Core.ErrorCodes.MISSING_PARAMS
	end

	if QuestsService[eventName] == nil then
		warn("[Quests Module] - Event not found.")
		return Core.ErrorCodes.NOT_FOUND
	end

	QuestsService[eventName]:Connect(callback)
end

--|| Knit Lifecycle ||--
function QuestsController:KnitInit()
	QuestsService = Knit.GetService("QuestsService")

	self:GetQuests()

	QuestsService.OnQuestUpdated:Connect(function(name, quest)
		self:GetQuests()[name] = quest
	end)

	QuestsService.OnQuestAdded:Connect(function(name, quest)
		self:GetQuests()[name] = quest
	end)

	QuestsService.OnQuestRemoved:Connect(function(name)
		self:GetQuests()[name] = nil
	end)
end

return QuestsController
