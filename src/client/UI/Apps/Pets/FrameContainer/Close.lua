local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.RoactHooks)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local UIModule = require(ReplicatedStorage.Packages.uiModule)
local Store = UIModule:GetGlobalStore()

local UIAction = require(StarterPlayer.StarterPlayerScripts.Client.UI.Store.Actions.UIAction)

function Close(_, hooks)
	local styles, api = RoactSpring.useSpring(hooks, function()
		return {
			rotation = 0,
			size = UDim2.fromScale(1, 1),
			config = { duration = 0.1 },
		}
	end)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(1, 0),
		BorderColor3 = Color3.fromHex("000000"),
		BackgroundColor3 = Color3.fromHex("d51800"),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.125, 0.2),
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0.075, 0),
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Thickness = 2,
		}),
		UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {}),
		Button = Roact.createElement("TextButton", {
			TextWrapped = true,
			TextColor3 = Color3.fromHex("ffffff"),
			BorderColor3 = Color3.fromHex("000000"),
			Text = "X",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Font = 42,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			TextScaled = true,
			BorderSizePixel = 0,
			TextSize = 14,
			BackgroundColor3 = Color3.fromHex("ffffff"),
			Size = styles.size,
			Rotation = styles.rotation,

			[Roact.Event.MouseButton1Click] = function()
				Store:dispatch(UIAction.resetCurrentFrame())
			end,

			[Roact.Event.MouseEnter] = function()
				api.start({ rotation = -10 })
			end,

			[Roact.Event.MouseLeave] = function()
				api.start({ rotation = 0 })
			end,

			[Roact.Event.MouseButton1Down] = function()
				api.start({ size = UDim2.fromScale(0.9, 0.9) })
			end,

			[Roact.Event.MouseButton1Up] = function()
				api.start({ size = UDim2.fromScale(1, 1) })
			end,
		}, { UIStroke = Roact.createElement("UIStroke", {
			Thickness = 2,
		}) }),
	})
end

Close = RoactHooks.new(Roact)(Close)
return Close
