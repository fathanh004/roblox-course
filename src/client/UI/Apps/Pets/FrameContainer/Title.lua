local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.RoactHooks)

function Title(_, hooks)
	return Roact.createElement("Frame", {
		BorderColor3 = Color3.fromHex("000000"),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Rotation = -5,
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.25, -0.025),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		ZIndex = 5,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.5, 0.2),
	}, {
		Main = Roact.createElement("TextLabel", {
			TextWrapped = true,
			Size = UDim2.fromScale(1, 1),
			TextColor3 = Color3.fromHex("ffffff"),
			BorderColor3 = Color3.fromHex("000000"),
			Text = "PETS",
			Position = UDim2.fromScale(0.5, 0.5),
			TextSize = 14,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Font = 26,
			BackgroundTransparency = 1,
			TextXAlignment = 0,
			TextScaled = true,
			ZIndex = 7,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromHex("ffffff"),
		}, { UIStroke = Roact.createElement("UIStroke", {
			Thickness = 2,
		}) }),
		Shadow = Roact.createElement("TextLabel", {
			TextWrapped = true,
			Size = UDim2.fromScale(1, 1),
			TextColor3 = Color3.fromHex("000000"),
			BorderColor3 = Color3.fromHex("000000"),
			Text = "PETS",
			Position = UDim2.fromScale(0.525, 0.55),
			TextSize = 14,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Font = 26,
			BackgroundTransparency = 1,
			TextXAlignment = 0,
			TextScaled = true,
			ZIndex = 6,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromHex("ffffff"),
		}, { UIStroke = Roact.createElement("UIStroke", {
			Thickness = 2,
		}) }),
	})
end

Title = RoactHooks.new(Roact)(Title)
return Title
