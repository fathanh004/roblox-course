-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.RoactHooks)
local RoduxHooks = require(ReplicatedStorage.Packages.RoduxHooks)
local roactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local function HUD(_, hooks)
	local CoinState = RoduxHooks.useSelector(hooks, function(state)
		return state.CoinReducer
	end)

	-- Animasi spring untuk koin
	local styles, api = roactSpring.useSpring(hooks, function()
		return {
			nbToDisplay = CoinState.Coins,
		}
	end)

	hooks.useEffect(function()
		api.start({
			nbToDisplay = CoinState.Coins,
		})
	end, { CoinState.Coins })

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		-- Bottom bar (Coin display)
		BottomFrame = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.965),
			Size = UDim2.fromScale(1, 0.13),
			ZIndex = 1,
			Name = "Bottom",
		}, {
			UIListLayout = Roact.createElement("UIListLayout", {
				Padding = UDim.new(0.03, 0),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),
			UIAspectRatio = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 4.5,
				AspectType = Enum.AspectType.FitWithinMaxSize,
				DominantAxis = Enum.DominantAxis.Width,
			}),
		}),

		-- Coin display
		CoinDisplay = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(0.08, 0.08),
			Position = UDim2.fromScale(0.1, 0.5),
		}, {
			mainText = Roact.createElement("TextLabel", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.8, 0.8),
				Position = UDim2.fromScale(0, 0),
				FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json"),
				Text = styles.nbToDisplay:map(function(nbToDisplay)
					return math.floor(nbToDisplay)
				end),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				TextSize = 14,
				ZIndex = 1,
			}, {
				UIStroke = Roact.createElement("UIStroke", {
					Color = Color3.new(0, 0, 0),
					Thickness = 1.75,
				}),
			}),

			CoinImage = Roact.createElement("ImageLabel", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.7, 0.7),
				Position = UDim2.fromScale(-0.15, 0.08),
				Image = "rbxassetid://136131917641767",
			}, {
				UIAspectRatio = Roact.createElement("UIAspectRatioConstraint", {
					AspectRatio = 1,
				}),
			}),

			UIAspectRatio = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 2,
			}),
		}),
	})
end

HUD = RoactHooks.new(Roact)(HUD)
return HUD
