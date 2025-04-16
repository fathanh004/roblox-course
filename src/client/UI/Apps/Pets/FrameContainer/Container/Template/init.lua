local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.RoactHooks)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local FramesFolder = script

function Template(props, hooks)
	local petName = props.PetName or "Bee"
	local petImageId = props.PetImageId or "rbxassetid://16345630964"
	local transparency = props.Transparency or 0
	local scale = props.Scale or 1
	local layoutOrder = props.LayoutOrder or 1

	local styles, api = RoactSpring.useSpring(hooks, function()
		return {
			rotation = 0,
			size = UDim2.fromScale(0.75, 0.9),
			config = { duration = 0.1 },
		}
	end)

	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.fromHex("f6f7fa"),
		BorderColor3 = Color3.fromHex("000000"),
		ZIndex = 2,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(100, 100),
		BackgroundTransparency = transparency,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		LayoutOrder = layoutOrder,

		[Roact.Event.MouseEnter] = function()
			api.start({
				rotation = -15,
			})
		end,

		[Roact.Event.MouseLeave] = function()
			api.start({
				rotation = 0,
			})
		end,
	}, {
		Name = Roact.createElement("TextLabel", {
			TextWrapped = true,
			TextColor3 = Color3.fromHex("ffffff"),
			BorderColor3 = Color3.fromHex("000000"),
			Text = petName,
			Size = UDim2.fromScale(1, 0.225),
			TextSize = 14,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Font = 26,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 1),
			TextScaled = true,
			ZIndex = 4,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromHex("ffffff"),
			TextTransparency = transparency,
		}, {
			UIStroke = Roact.createElement("UIStroke", {
				Thickness = 2,
				Transparency = transparency,
			}),
		}),
		Background = Roact.createElement(require(FramesFolder.Background)),
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
		UIStroke = Roact.createElement("UIStroke", {
			Color = Color3.fromHex("e5e5e5"),
			Transparency = transparency,
		}),
		Icon = Roact.createElement("ImageButton", {
			ScaleType = 3,
			BorderColor3 = Color3.fromHex("000000"),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = petImageId,
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = styles.size,
			ZIndex = 4,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromHex("ffffff"),
			ImageTransparency = transparency,
			Rotation = styles.rotation,

			[Roact.Event.MouseButton1Down] = function()
				api.start({
					size = UDim2.fromScale(0.65, 0.8),
				})
			end,

			[Roact.Event.MouseButton1Up] = function()
				api.start({
					size = UDim2.fromScale(0.75, 0.9),
				})
			end,
		}),
		UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {}),
		UIScale = Roact.createElement("UIScale", {
			Scale = scale,
		}),
	})
end

Template = RoactHooks.new(Roact)(Template)
return Template
