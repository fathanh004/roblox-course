-- ReplicatedStorage/Shared/Configs/GroupRewardsModule.config.lua

return {
	ChestRewards = {
		-- list of all rewards
		Rewards = {
			{
				Type = "Currency",
				Currency = "Wins",
				Amount = 10,
			},
		},
		Cooldown = 24 * 60 * 60, -- in seconds
		HitboxPath = "Workspace/MyHitboxPart", -- optional
	},
}
