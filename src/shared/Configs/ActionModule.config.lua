return table.freeze({
	["Attack"] = {
		["Key"] = Enum.KeyCode.F,
		["Cooldown"] = 1000 * 1, -- 5 seconds in milliseconds
		["DefaultCallback"] = function(_: Player)
			print("Fight Action has been called.")
			return true
		end,
	},
})
