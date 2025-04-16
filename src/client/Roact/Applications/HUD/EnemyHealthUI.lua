local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.RoactHooks)
local RoduxHooks = require(ReplicatedStorage.Packages.RoduxHooks)

local FramesFolder = script.Parent

local FrameRandomUUID = HttpService:GenerateGUID(false)
local FrameName = "EnemyHealthUI" .. "_" .. FrameRandomUUID

function EnemyHealthUI(_, hooks)
	local BattleState = RoduxHooks.useSelector(hooks, function(state)
		return state.BattleReducer
	end)

	local enemyHealthItems = {}
	for i, enemy in ipairs(BattleState.enemies) do
		table.insert(
			enemyHealthItems,
			Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.273, 0.9),

				BorderColor3 = Color3.fromHex("000000"),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(538, 63),
			}, {
				UIListLayout = Roact.createElement("UIListLayout", {
					HorizontalAlignment = 0,
					SortOrder = 2,
				}),
				EnemyName = Roact.createElement("TextLabel", {
					TextWrapped = true,
					TextColor3 = Color3.fromHex("ff6969"),
					BorderColor3 = Color3.fromHex("000000"),
					Text = enemy.NpcData.name,
					TextStrokeTransparency = 0.5,
					Font = 4,
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(538, 27),
					TextScaled = true,
					TextSize = 14,
					BorderSizePixel = 0,
					BackgroundColor3 = Color3.fromHex("ffffff"),
				}),
				HealthBackground = Roact.createElement(require(FramesFolder.HealthBackground), {
					CurrentHealth = enemy.CurrentHealth,
					MaxHealth = enemy.MaxHealth,
				}),
			})
		)
	end

	return Roact.createElement("Frame", {
		Name = FrameName,
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.273, 0.9),
		Size = UDim2.new(0, 538, 0, 300), -- container size (height disesuaikan)
		AnchorPoint = Vector2.new(0, 1), -- agar tumbuh ke atas dari bawah
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4),
		}),
		Children = Roact.createFragment(enemyHealthItems),
	})
end

EnemyHealthUI = RoactHooks.new(Roact)(EnemyHealthUI)
return EnemyHealthUI
