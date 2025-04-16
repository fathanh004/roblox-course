-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

-- Directories
local Reducers = StarterPlayer.StarterPlayerScripts.Client.Rodux.Reducers
local TemplateReducer = require(Reducers.TemplateReducer)
local CoinReducer = require(Reducers.CoinReducer)
local QuestReducer = require(Reducers.QuestReducer)
local DiamondReducer = require(Reducers.DiamondReducer)
local FightReducer = require(Reducers.FightReducer)
local BattleReducer = require(Reducers.BattleReducer)
local PetReducer = require(Reducers.PetReducer)

-- Modules
local Rodux = require(ReplicatedStorage.Packages.Rodux)

-- Store
local StoreReducer = Rodux.combineReducers({
	TemplateReducer = TemplateReducer,
	CoinReducer = CoinReducer,
	QuestReducer = QuestReducer,
	DiamondReducer = DiamondReducer,
	FightReducer = FightReducer,
	BattleReducer = BattleReducer,
	PetReducer = PetReducer,
})

local Store = Rodux.Store.new(StoreReducer, nil, {})

return Store
