local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.RoactHooks)

local FramesFolder = script

local FrameRandomUUID = HttpService:GenerateGUID(false)
local FrameName = "Left" .. "_" .. FrameRandomUUID

function Left(_, hooks)
	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.085, 0.5),
		BorderColor3 = Color3.fromHex("000000"),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.15, 0.4),
	}, {
		Pets = Roact.createElement(require(FramesFolder.Pets)),
		Shop = Roact.createElement(require(FramesFolder.Shop)),
		GoldMachine = Roact.createElement(require(FramesFolder.GoldMachine)),
		Friends = Roact.createElement(require(FramesFolder.Friends)),
		Travel = Roact.createElement(require(FramesFolder.Travel)),
		Rebirth = Roact.createElement(require(FramesFolder.Rebirth)),
		UIGridLayout = Roact.createElement("UIGridLayout", {
			VerticalAlignment = 0,
			SortOrder = 2,
			CellSize = UDim2.fromScale(0.45, 0.25),
			FillDirectionMaxCells = 2,
			CellPadding = UDim2.fromScale(0.05, 0.01),
			HorizontalAlignment = 0,
		}),
	})
end

Left = RoactHooks.new(Roact)(Left)
return Left
