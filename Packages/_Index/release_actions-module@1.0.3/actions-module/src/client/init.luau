--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

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
local ActionService = nil

--|| Controller ||--
local ActionController = Knit.CreateController({
	Name = "ActionController",

	Keys = {},
})
--|| Methods ||--

-- Bind Keyboard Key to a callback function. Can take multiple middlewares that will be checked before running callback.
function ActionController:BindKey(key: Enum.KeyCode | Enum.UserInputType, action: string)
	if not key or not action then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	if self.Keys[key] ~= nil then
		return error(Core.ErrorCodes.ALREADY_EXISTS)
	end

	self.Keys[key] = action
end

-- Register callback when server event is called.
function ActionController:RegisterEvents(eventName: string, callback: () -> any)
	if not eventName or not callback then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	if ActionService[eventName] == nil then
		return error(Core.ErrorCodes.NOT_FOUND)
	end

	ActionService[eventName]:Connect(callback)
end

function ActionController:KnitInit()
	ActionService = Knit.GetService("ActionService")

	local Configuration = require(ReplicatedStorage.Shared:FindFirstChild("ActionModule.config", true))
	for Action, Config in Configuration do
		self:BindKey(Config.Key, Action)
	end

	UserInputService.InputBegan:Connect(function(input: InputObject, _: boolean)
		if self.Keys[input.KeyCode] ~= nil then
			pcall(function()
				return ActionService:PerformAction(self.Keys[input.KeyCode]):await()
			end)
		end

		if self.Keys[input.UserInputType] ~= nil then
			pcall(function()
				return ActionService:PerformAction(self.Keys[input.UserInputType]):await()
			end)
		end
	end)
end

return ActionController
