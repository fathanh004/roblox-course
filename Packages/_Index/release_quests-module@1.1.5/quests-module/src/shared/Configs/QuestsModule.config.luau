return table.freeze({
	["MaxQuestsPerUser"] = 3, -- Basé sur la configuration de tes tests

	["Quests"] = {
		["Gather Apples"] = {
			["Type"] = "Collect",
			["Goal"] = 10,

			["Reward"] = {
				["Type"] = "Economy",
				["Economy"] = "FoodPoint",
				["Amount"] = 150,
			},
		},

		["Defeat Monsters"] = {
			["Type"] = "Combat",
			["Goal"] = 5,

			["Reward"] = {
				["Type"] = "Item",
				["Item"] = "MonsterTrophy",
			},
		},

		["Extra Quest"] = {
			["Type"] = "Explore",
			["Goal"] = 3, -- Exemple : explorer 3 zones

			["Reward"] = {
				["Type"] = "Economy",
				["Economy"] = "TravelPoints",
				["Amount"] = 200,
			},
		},

		["Yet Another Quest"] = {
			["Type"] = "Custom",
			["Goal"] = 1, -- Exemple de quête sur mesure

			["Reward"] = {
				["Type"] = "Economy",
				["Economy"] = "SpecialTokens",
				["Amount"] = 50,
			},
		},

		["Yet Another Quest 2"] = {
			["Type"] = "Custom",
			["Goal"] = 2, -- Exemple de quête sur mesure

			["Reward"] = {
				["Type"] = "Economy",
				["Economy"] = "SpecialTokens",
				["Amount"] = 50,
			},
		},
	},
})
