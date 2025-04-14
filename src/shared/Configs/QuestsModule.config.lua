return table.freeze({
	MaxQuestsPerUser = 3,

	Quests = {
		["Gather Coins"] = {
			Type = "Gather Coins",
			Goal = 3,
			Status = "Not Finished",

			Reward = {
				Type = "Economy",
				Economy = "Diamonds",
				Amount = 50,
			},
		},

		["Gather 10 Coins"] = {
			Type = "Gather Coins",
			Goal = 10,
			Status = "Not Finished",

			Reward = {
				Type = "Economy",
				Economy = "Diamonds",
				Amount = 150,
			},
		},
	},
})
