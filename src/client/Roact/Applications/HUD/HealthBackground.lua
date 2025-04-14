local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)

local FramesFolder = script.Parent

local FrameRandomUUID = HttpService:GenerateGUID(false)
local FrameName = "HealthBackground" .. "_" .. FrameRandomUUID

function HealthBackground(props, hooks)
	return Roact.createElement("Frame", {
		Position = UDim2.fromScale(0.002, 0.368),
		BorderColor3 = Color3.fromHex("000000"),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderSizePixel = 3,
		Size = UDim2.fromOffset(535, 36),
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			VerticalAlignment = 0,
			SortOrder = 2,
		}),
		HealthDisplay = Roact.createElement(require(script.Parent.HealthDisplay), {
			CurrentHealth = props.CurrentHealth,
			MaxHealth = props.MaxHealth,
		}),
	})
end

HealthBackground = RoactHooks.new(Roact)(HealthBackground)
return HealthBackground
