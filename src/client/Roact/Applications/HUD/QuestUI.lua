local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.RoactHooks)
local RoduxHooks = require(ReplicatedStorage.Packages.RoduxHooks)

local function QuestUI(_, hooks)
	local QuestState = RoduxHooks.useSelector(hooks, function(state)
		return state.QuestReducer
	end)
	local QuestItems = {}
	for i, quest in ipairs(QuestState.activeQuests or {}) do
		if quest.Status == "Finished" then
			continue
		end

		table.insert(
			QuestItems,
			Roact.createElement("Frame", {
				Size = UDim2.fromOffset(338, 85),
				BackgroundColor3 = Color3.fromHex("ffffff"),
				BorderColor3 = Color3.fromHex("000000"),
				BorderSizePixel = 0,
			}, {
				QuestTitle = Roact.createElement("TextLabel", {
					Text = quest.Name,
					TextColor3 = Color3.fromHex("000000"),
					Font = Enum.Font.Gotham,
					Size = UDim2.fromOffset(338, 44),
					TextScaled = true,
					TextSize = 14,
					BackgroundColor3 = Color3.fromHex("ffffff"),
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
					Position = UDim2.fromScale(0, 0),
				}),
				QuestProgression = Roact.createElement("TextLabel", {
					Text = string.format("%d/%d", quest.Progress, quest.Goal),
					TextColor3 = Color3.fromHex("000000"),
					Font = Enum.Font.Gotham,
					Size = UDim2.fromOffset(181, 41),
					Position = UDim2.fromScale(0.231, 0.518),
					TextScaled = true,
					TextSize = 14,
					BackgroundColor3 = Color3.fromHex("ffffff"),
					BorderSizePixel = 0,
					BackgroundTransparency = 1,
				}),
			})
		)
	end

	-- Parent Frame + Layout
	return Roact.createElement("Frame", {
		Position = UDim2.fromScale(0.357, 0),
		Size = UDim2.new(0, 338, 0, 85 * #QuestItems),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
	}, {
		UIListLayout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4), -- jarak antar quest
		}),
		QuestItems = Roact.createFragment(QuestItems),
	})
end

QuestUI = RoactHooks.new(Roact)(QuestUI)
return QuestUI
