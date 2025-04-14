--|| Services ||--
local Players = game:GetService("Players")
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

local Core = importPackage("core")
local Knit = importPackage("knit")
local Roact = importPackage("roact")
local Rodux = importPackage("rodux")
local RoduxHooks = importPackage("rodux-hooks")

if not Roact or not Rodux or not RoduxHooks then
	warn("[UI Module] - Roact, Rodux and RoduxHooks modules required for this module to work.")
	return Core.ErrorCodes.NOT_FOUND
end

--|| Controller ||--
local UIController = Knit.CreateController({
	Name = "UIController",

	Frames = {},
	Reducers = {},

	Cache = {},

	Store = nil,
})

--|| Methods ||--

function UIController:RegisterAPI(frame: string, api)
	if not frame or not api then
		return warn("[ UI Handler ] - Missing parameters.")
	end

	if self.Cache[frame] == nil then
		self.Cache[frame] = {}
	end

	self.Cache[frame] = api
end

function UIController:ClearAnimations(frame: string)
	if not frame then
		return warn("[ UI Handler ] - Missing parameters.")
	end

	if self.Cache[frame] == nil then
		return
	end

	self.Cache[frame].stop()
	self.Cache[frame] = nil
end

function UIController:AddFrame(name: string, frame: ModuleScript)
	if not name or not frame then
		warn("[UI Module] - Missing or incorrect parameters.")
		return Core.ErrorCodes.MISSING_PARAMS
	end

	if self.Frames[name] ~= nil then
		warn("[UI Module] - Frame already exists.")
		return Core.ErrorCodes.ALREADY_EXISTS
	end

	if self.Store == nil then
		warn(
			"[UI Module] - You need to call the CreateStore function before adding frames. More informations in 'Add Reducers' page."
		)

		return Core.ErrorCodes.CANT_NOW
	end

	self.Frames[name] = require(frame)
end

function UIController:RemoveFrame(name: string)
	if not name then
		warn("[UI Module] - Missing or incorrect parameters.")
		return Core.ErrorCodes.MISSING_PARAMS
	end

	if not self.Frames[name] then
		warn("[UI Module] - Frame not found.")
		return Core.ErrorCodes.NOT_FOUND
	end

	self.Frames[name] = nil
end

function UIController:AddReducer(name: string, reducer: table)
	if not name or not reducer then
		warn("[UI Module] - Missing or incorrect parameters.")
		return Core.ErrorCodes.MISSING_PARAMS
	end

	if self.Reducers[name] ~= nil then
		warn("[UI Module] - Reducer already exists.")
		return Core.ErrorCodes.ALREADY_EXISTS
	end

	self.Reducers[name] = reducer
end

function UIController:RemoveReducer(name: string)
	if not name then
		warn("[UI Module] - Missing or incorrect parameters.")
		return Core.ErrorCodes.MISSING_PARAMS
	end

	if not self.Reducers[name] then
		warn("[UI Module] - Reducer not found.")
		return Core.ErrorCodes.NOT_FOUND
	end

	self.Reducers[name] = nil
end

function UIController:CreateStore()
	local CombinedReducers = Rodux.combineReducers(self.Reducers)

	self.Store = Rodux.Store.new(CombinedReducers, nil, {})
	return self.Store
end

function UIController:GetGlobalStore()
	return self.Store
end

function UIController:CreateApplication()
	local RootGenerator = require(script.Parent.UI.Apps.Root)
	local Root = RootGenerator(self.Frames)

	Roact.mount(
		Roact.createElement(RoduxHooks.Provider, {
			store = self.Store,
		}, {
			Game = Roact.createElement(Root),
		}),
		Players.LocalPlayer.PlayerGui,
		"UI"
	)
end

--|| Knit Lifecycle ||--
function UIController:KnitInit() end

return UIController
