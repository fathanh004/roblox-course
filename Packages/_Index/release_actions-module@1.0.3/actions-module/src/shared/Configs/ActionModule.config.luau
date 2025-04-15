return table.freeze({
	["Fight"] = {
		["Key"] = Enum.KeyCode.E,
		["Cooldown"] = 1000 * 5,
		["DefaultCallback"] = function(_: Player)
			print("Fight Action has been called.")
			return true
		end,
	},
})
