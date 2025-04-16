local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.RoactHooks)

local FramesFolder = script

function FrameContainer(_, hooks)
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BorderColor3 = Color3.fromHex("000000"),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.5, 0.6),
	}, {
		Close = Roact.createElement(require(script.Close)),
		Title = Roact.createElement(require(script.Title)),
		UICorner = Roact.createElement("UICorner", {}),
		UIStroke = Roact.createElement("UIStroke", {
			Thickness = 2,
		}),
		ScrollingFrame = Roact.createElement("ScrollingFrame", {
			ScrollBarImageColor3 = Color3.fromHex("000000"),
			MidImage = "",
			Active = true,
			AutomaticCanvasSize = 2,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BorderColor3 = Color3.fromHex("000000"),
			TopImage = "",
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.99, 0.835),
			BottomImage = "",
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromHex("ffffff"),
		}, { Container = Roact.createElement(require(FramesFolder.Container)) }),
	})
end

FrameContainer = RoactHooks.new(Roact)(FrameContainer)
return FrameContainer
