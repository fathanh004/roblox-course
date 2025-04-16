--|| Game Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--|| Modules ||--
local Rodux = require(ReplicatedStorage.Packages.Rodux)

--|| Reducer ||--
return Rodux.createReducer({
	Coins = 0,
	Wins = 0,
	Spins = 0,

	Pets = {
		[1] = {
			name = "Bee",
			imageId = "rbxassetid://16345630964",
		},
		[2] = {
			name = "Horse",
			imageId = "rbxassetid://16345634296",
		},
		[3] = {
			name = "Noob",
			imageId = "rbxassetid://16345627149",
		},
		[4] = {
			name = "Orange Dragon",
			imageId = "rbxassetid://16345638810",
		},
		[5] = {
			name = "Squid",
			imageId = "rbxassetid://16345629063",
		},
		[6] = {
			name = "Bat",
			imageId = "rbxassetid://16345644445",
		},
		[7] = {
			name = "Scorpion",
			imageId = "rbxassetid://16345646363",
		},
		[8] = {
			name = "Spider",
			imageId = "rbxassetid://16345648047",
		},
		[9] = {
			name = "Toucan",
			imageId = "rbxassetid://16345642352",
		},
		[10] = {
			name = "Corgi",
			imageId = "rbxassetid://16340918704",
		},
		[11] = {
			name = "Elephant",
			imageId = "rbxassetid://16340920732",
		},
		[12] = {
			name = "Hamster",
			imageId = "rbxassetid://16340915675",
		},
		[13] = {
			name = "Monkey",
			imageId = "rbxassetid://16340922252",
		},
	},
}, {
	setCoins = function(state, action)
		local newState = table.clone(state)
		newState.Coins = action.value
		return newState
	end,

	setWins = function(state, action)
		local newState = table.clone(state)
		newState.Wins = action.value
		return newState
	end,

	setSpins = function(state, action)
		local newState = table.clone(state)
		newState.Spins = action.value
		return newState
	end,
})
