--[=[
	Owner: CategoryTheory
	Version: 0.0.1
	Contact owner if any question, concern or feedback
]=]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Directions
local Applications = StarterPlayer.StarterPlayerScripts.Client.Roact.Applications
local Contexts = StarterPlayer.StarterPlayerScripts.Client.Roact.Contexts
local AllowedApplicationsContext = require(Contexts.AllowedApplicationsContext)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)
local Contexts = StarterPlayer.StarterPlayerScripts.Client.Roact.Contexts
local ContextStack = require(Contexts.ContextStack)

-- Modules
local Roact = require(ReplicatedStorage.Packages.Roact)
local HUD = require(Applications.HUD.Application)
local QuestUI = require(Applications.HUD.QuestUI)
local DiamondUI = require(Applications.HUD.DiamondUI)
local EnemyHealthUI = require(Applications.HUD.EnemyHealthUI)

local function Root(props, hooks)
	return Roact.createElement(ContextStack, {
		providers = {
			AllowedApplicationsContext.Provider,
		},
	}, Roact.createFragment(props[Roact.Children]))
end
Root = RoactHooks.new(Roact)(Root)

-- Component
local function GameFrame()
	return Roact.createElement(Root, {}, {
		GameScreenGui = Roact.createElement("ScreenGui", {
			IgnoreGuiInset = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Global,
			ResetOnSpawn = false,
		}, {
			HUD = Roact.createElement(HUD),
			QuestUI = Roact.createElement(QuestUI),
			DiamondUI = Roact.createElement(DiamondUI),
			EnemyHealthUI = Roact.createElement(EnemyHealthUI),
		}),
	})
end

return {
	Game = GameFrame,
}
