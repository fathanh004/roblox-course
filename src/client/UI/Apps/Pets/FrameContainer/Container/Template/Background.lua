local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.RoactHooks)

local FramesFolder = script

local FrameRandomUUID = HttpService:GenerateGUID(false)
local FrameName = "Background" .. "_" .. FrameRandomUUID

function Background(_, hooks)
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(math.random(), math.random(), math.random()),
		BackgroundTransparency = 0.7,
		Position = UDim2.fromScale(0.5, 0.5),
		ZIndex = 3,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.8, 0.8),
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
	})
end

Background = RoactHooks.new(Roact)(Background)
return Background
