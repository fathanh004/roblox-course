local Pets = {
	["NameFramePath"] = {
		["Template"] = { "Assets", "Frames", "PetName" },
		["NameTextLabel"] = { "Name" },
		["RarityTextLabel"] = { "Rarity" },
	},

	["ModelsPath"] = { "Assets", "Pets" },

	["Settings"] = {
		XSpacing = 4,
		ZSpacing = 4,
		YSpacing = 0,
		PlayerSpacing = 3.5,

		FlyMaxHeight = 1,
		FlySpeed = 2.3,
		FlyForwardAngle = math.rad(6),
		FlyBackwardAngle = math.rad(6),

		GroundMaxHeight = 2.3,
		GroundSpeed = 10,
		GroundForwardAngle = math.rad(15),
		GroundBackwardAngle = math.rad(15),

		RaycastSpeed = 25,
	},

	["Cat"] = {
		["Name"] = "Cat",
		["Power"] = 10,
		["Rarity"] = "Common",
		["Movement"] = "Walk",
	},

	["Dog"] = {
		["Name"] = "Dog",
		["Power"] = 100,
		["Rarity"] = "Rare",
		["Movement"] = "Walk",
	},

	-- Additional pets...
}

-- Auto-generate gold variants
for Pet, Info in Pets do
	if Info.Name ~= nil and not string.find(Info.Name, "Gold") then
		local GoldName = "Gold " .. Pet
		Pets[GoldName] = {
			["Name"] = GoldName,
			["Power"] = Info.Power * 2,
			["Rarity"] = Info.Rarity,
			["Movement"] = Info.Movement,
		}
	end
end

return Pets
