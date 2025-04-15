local Modules = script.Parent
local CurrencyModule: Instance? = Modules:FindFirstChild("CurrencyEnumExample")

if not CurrencyModule then
	error("Missing CurrencyEnum Module")
end

local CurrencyEnum = require(CurrencyModule)

return {
	DefaultEgg = {
		Name = "common_egg",
		DisplayName = "Common Egg",
		Price = 5,
		Currency = CurrencyEnum.Wins,
		Pets = {
			{
				Name = "dog",
				Chance = 35,
			},
			{
				Name = "cat",
				Chance = 25,
			},
			{
				Name = "pig",
				Chance = 20,
			},
			{
				Name = "cow",
				Chance = 15,
			},
			{
				Name = "bunny",
				Chance = 5,
			},
		},
	},
}
