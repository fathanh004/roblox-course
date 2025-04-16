-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.RoactHooks)
local RoduxHooks = require(ReplicatedStorage.Packages.RoduxHooks)
local roactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local function DiamondUI(_, hooks)
	local DiamondState = RoduxHooks.useSelector(hooks, function(state)
		return state.DiamondReducer
	end)

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.798, 0),
		BorderColor3 = Color3.fromHex("000000"),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(239, 67),
	}, {
		DiamondImage = Roact.createElement("ImageLabel", {
			Image = "http://www.roblox.com/asset/?id=139748225070288",
			BorderColor3 = Color3.fromHex("000000"),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(30, 30),
		}),
		DiamondCountText = Roact.createElement("TextLabel", {
			Text = DiamondState.Diamonds,
			TextWrapped = true,
			TextColor3 = Color3.fromHex("ffffff"),
			BorderColor3 = Color3.fromHex("000000"),
			Size = UDim2.fromOffset(173, 31),
			TextStrokeTransparency = 0.19,
			Position = UDim2.fromScale(0.276, 0.269),
			Font = 3,
			BackgroundTransparency = 1,
			TextXAlignment = 0,
			TextScaled = true,
			TextSize = 17,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromHex("ffffff"),
		}),
		UIListLayout = Roact.createElement("UIListLayout", {
			VerticalAlignment = 0,
			FillDirection = 0,
			SortOrder = 2,
			Padding = UDim.new(0.03, 0),
		}),
	})
end

DiamondUI = RoactHooks.new(Roact)(DiamondUI)
return DiamondUI
