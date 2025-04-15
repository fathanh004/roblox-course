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

--|| Service ||--
local ActionService = Knit.CreateService({
	Name = "ActionService",

	Actions = {},
	PlayerCooldowns = {},

	Client = {
		OnActionPerformed = Knit.CreateSignal(),
	},
})

--|| Client Methods ||--

function ActionService.Client:PerformAction(player: Player, actionName: string)
	return self.Server:PerformAction(player, actionName, true)
end

--|| Server Methods ||--

-- Create an action on the server
function ActionService:CreateAction(actionName: string, cooldown: number, callback: () -> any)
	if not actionName or not cooldown or not callback then
		return error(Core.ErrorCodes.MISSING_PARAMS)
	end

	if self.Actions[actionName] ~= nil then
		return error(Core.ErrorCodes.ALREADY_EXISTS)
	end

	self.Actions[actionName] = Core.Class.Action.new(actionName, cooldown, callback)
	return self.Actions[actionName]
end

-- Perform an action
function ActionService:PerformAction(player: Player, actionName: string, fromController: boolean)
	if not player or not actionName then
		if not fromController then
			return error(Core.ErrorCodes.MISSING_PARAMS)
		end

		return Core.ErrorCodes.MISSING_PARAMS
	end

	local Action = self.Actions[actionName]
	if Action == nil then
		if not fromController then
			return error(Core.ErrorCodes.NOT_FOUND)
		end

		return Core.ErrorCodes.NOT_FOUND
	end

	if Action.callback == nil then
		if not fromController then
			return error(Core.ErrorCodes.NO_CALLBACK)
		end

		return Core.ErrorCodes.NO_CALLBACK
	end

	local PlayerCooldown = self.PlayerCooldowns[player]
	if PlayerCooldown == nil then
		self.PlayerCooldowns[player] = {}
		PlayerCooldown = self.PlayerCooldowns[player]
	end

	if PlayerCooldown ~= nil and PlayerCooldown[Action.name] ~= nil then
		if DateTime.now().UnixTimestampMillis - PlayerCooldown[Action.name] < Action.cooldown then
			if not fromController then
				return error(Core.ErrorCodes.COOLDOWN)
			end

			return Core.ErrorCodes.COOLDOWN
		end
	end

	PlayerCooldown[Action.name] = DateTime.now().UnixTimestampMillis

	local Performed = Action:Perform(player)
	if Performed and Core.Utils.IsPlayer(player) then
		self.Client.OnActionPerformed:Fire(player, Action.name)
	end
end

function ActionService:KnitInit()
	local Configuration = require(ReplicatedStorage.Shared:FindFirstChild("ActionModule.config", true))
	if Configuration then
		for Action, Config in Configuration do
			self:CreateAction(Action, Config.Cooldown, Config.DefaultCallback)
		end
	end
end

return ActionService
