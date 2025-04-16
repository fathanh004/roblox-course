local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.RoactHooks)
local RoduxHooks = require(ReplicatedStorage.Packages.RoduxHooks)

local FramesFolder = script

local FrameRandomUUID = HttpService:GenerateGUID(false)
local FrameName = "Money1" .. "_" .. FrameRandomUUID

function Money1(_, hooks)
	local PlayerReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.PlayerReducer
	end)

	return Roact.createElement("Frame", {
		LayoutOrder = 1,
		BorderColor3 = Color3.fromHex("000000"),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.275, 0.8),
	}, {
		UIGradient = Roact.createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHex("ff821f")),
				ColorSequenceKeypoint.new(1, Color3.fromHex("faf886")),
			}),
		}),
		Amount = Roact.createElement("TextLabel", {
			TextWrapped = true,
			TextColor3 = Color3.fromHex("ffffff"),
			BorderColor3 = Color3.fromHex("000000"),
			Text = PlayerReducer.Coins,
			Size = UDim2.fromScale(0.5, 0.55),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Font = 34,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.55, 0.5),
			TextScaled = true,
			TextSize = 14,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromHex("ffffff"),
		}, { UIStroke = Roact.createElement("UIStroke", {
			Thickness = 1.25,
		}) }),
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("ffffff"),
			Thickness = 2,
		}),
		Icon = Roact.createElement("ImageLabel", {
			ScaleType = 3,
			BorderColor3 = Color3.fromHex("000000"),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = "rbxassetid://136131917641767",
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.1, 0.5),
			BackgroundColor3 = Color3.fromHex("ffffff"),
			Rotation = 10,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.3, 1.4),
		}),
	})
end

Money1 = RoactHooks.new(Roact)(Money1)
return Money1
