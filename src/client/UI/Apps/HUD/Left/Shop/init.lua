local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local StarterPlayer = game:GetService("StarterPlayer")

local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.RoactHooks)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local UIModule = require(ReplicatedStorage.Packages.uiModule)
local Store = UIModule:GetGlobalStore()

local UIAction = require(StarterPlayer.StarterPlayerScripts.Client.UI.Store.Actions.UIAction)

local FramesFolder = script

local FrameRandomUUID = HttpService:GenerateGUID(false)
local FrameName = "Shop" .. "_" .. FrameRandomUUID

function Shop(_, hooks)
	local styles, api = RoactSpring.useSpring(hooks, function()
		return {
			rotation = 0,
			size = UDim2.fromScale(0.9, 0.9),
			config = { duration = 0.1 },
		}
	end)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderColor3 = Color3.fromHex("000000"),
		LayoutOrder = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(100, 100),
	}, {
		Image = Roact.createElement("ImageButton", {
			ScaleType = 3,
			BorderColor3 = Color3.fromHex("000000"),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = "rbxassetid://16007843340",
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			ZIndex = 2,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromHex("ffffff"),
			Size = styles.size,
			Rotation = styles.rotation,

			[Roact.Event.MouseButton1Click] = function()
				Store:dispatch(UIAction.setCurrentFrame("Shop"))
			end,

			[Roact.Event.MouseEnter] = function()
				api.start({ rotation = -15 })
			end,

			[Roact.Event.MouseLeave] = function()
				api.start({ rotation = 0 })
			end,

			[Roact.Event.MouseButton1Down] = function()
				api.start({ size = UDim2.fromScale(0.8, 0.8) })
			end,

			[Roact.Event.MouseButton1Up] = function()
				api.start({ size = UDim2.fromScale(0.9, 0.9) })
			end,
		}, { Notification = Roact.createElement(require(FramesFolder.Notification)) }),
		UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {}),
		Title = Roact.createElement("TextLabel", {
			TextWrapped = true,
			TextColor3 = Color3.fromHex("ffffff"),
			BorderColor3 = Color3.fromHex("000000"),
			Text = "SHOP",
			Size = UDim2.fromScale(1, 0.235),
			TextSize = 14,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Font = 26,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.925),
			TextScaled = true,
			ZIndex = 3,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromHex("ffffff"),
		}, { UIStroke = Roact.createElement("UIStroke", {
			Thickness = 2,
		}) }),
	})
end

Shop = RoactHooks.new(Roact)(Shop)
return Shop
