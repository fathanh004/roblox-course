local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.Hooks)

local FrameRandomUUID = HttpService:GenerateGUID(false)
local FrameName = "HealthDisplay" .. "_" .. FrameRandomUUID

function HealthDisplay(props, hooks)
	local percent = 1
	if props.MaxHealth and props.CurrentHealth then
		percent = math.clamp(props.CurrentHealth / props.MaxHealth, 0, 1)
	end

	return Roact.createElement("Frame", {
		Position = UDim2.fromScale(0.003, 0.014),
		BorderColor3 = Color3.fromHex("000000"),
		BackgroundColor3 = Color3.fromHex("f00000"),
		BorderSizePixel = 0,
		Size = UDim2.new(percent, 0, 0, 35), -- 🔥 width sesuai persentase
	}, {})
end

HealthDisplay = RoactHooks.new(Roact)(HealthDisplay)
return HealthDisplay
