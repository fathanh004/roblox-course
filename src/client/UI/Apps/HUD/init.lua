local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.RoactHooks)
local RoduxHooks = require(ReplicatedStorage.Packages.RoduxHooks)

local FramesFolder = script

local FrameName = "HUD"

function HUD(_, hooks)
	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
	end)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		BorderColor3 = Color3.fromHex("000000"),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Visible = UIReducer.CurrentFrame == FrameName,
	}, {
		Top = Roact.createElement(require(FramesFolder.Top)),
		Left = Roact.createElement(require(FramesFolder.Left)),
	})
end

HUD = RoactHooks.new(Roact)(HUD)
return HUD
