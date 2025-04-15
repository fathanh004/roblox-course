local Pets = {
	["NameFramePath"] = { "Assets", "Frames", "PetName" },
	["ModelsPath"] = { "Assets", "Pets" },

	["Dog"] = {
		["Name"] = "Dog",
		["Power"] = 10,
		["Rarity"] = "Common",

		["Movement"] = "Walk",
	},

	["Bat"] = {
		["Name"] = "Bat",
		["Power"] = 10,
		["Rarity"] = "Common",

		["Movement"] = "Walk",
	},
}

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
