-- ReplicatedStorage/Shared/Configs/EggsModule.config.lua

return {
	CommonEgg = {
		Name = "CommonEgg",
		DisplayName = "Common Egg",
		Price = 5,
		Currency = "Wins",
		HatchTime = 5, -- in seconds
		Pets = {
			{
				Name = "Dog",
				Chance = 40,
			},
			{
				Name = "Cat",
				Chance = 60,
			},
		},
	},
}
