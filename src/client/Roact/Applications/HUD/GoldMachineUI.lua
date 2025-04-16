-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local HttpService = game:GetService("HttpService")
-- local StarterPlayer = game:GetService("StarterPlayer")

-- local Roact = require(ReplicatedStorage.Packages.Roact)
-- local RoactHooks = require(ReplicatedStorage.Packages.RoactHooks)
-- local RoduxHooks = require(ReplicatedStorage.Packages.RoduxHooks)

-- local Knit = require(ReplicatedStorage.Packages.Knit)

-- -- local UIModule = require(ReplicatedStorage.Packages.uiModule)
-- -- local Store = UIModule:GetGlobalStore()

-- local FramesFolder = script.Parent

-- local FrameRandomUUID = HttpService:GenerateGUID(false)
-- local FrameName = "GoldMachineUI" .. "_" .. FrameRandomUUID

-- function GoldMachineUI(_, hooks)
-- 	return Roact.createElement("Frame", {
-- 		Position = UDim2.fromScale(0.247, 0.129),
-- 		BorderColor3 = Color3.fromHex("000000"),
-- 		BackgroundColor3 = Color3.fromHex("ffffff"),
-- 		BorderSizePixel = 0,
-- 		Size = UDim2.fromOffset(600, 500),
-- 	}, {
-- 		TextLabel = Roact.createElement("TextLabel", {
-- 			TextWrapped = true,
-- 			TextColor3 = Color3.fromHex("000000"),
-- 			BorderColor3 = Color3.fromHex("000000"),
-- 			Text = "Combine your pet into Gold Pet!",
-- 			Size = UDim2.fromOffset(600, 28),
-- 			Font = 3,
-- 			BackgroundTransparency = 1,
-- 			Position = UDim2.fromScale(0, 0.944),
-- 			TextScaled = true,
-- 			TextSize = 14,
-- 			BorderSizePixel = 0,
-- 			BackgroundColor3 = Color3.fromHex("ffffff"),
-- 		}),
-- 		UICorner = Roact.createElement("UICorner", {}),
-- 		UIStroke = Roact.createElement("UIStroke", {
-- 			Thickness = 2,
-- 		}),
-- 		PetList = Roact.createElement(require(FramesFolder.PetList)),
-- 		Title = Roact.createElement("TextLabel", {
-- 			TextWrapped = true,
-- 			TextColor3 = Color3.fromHex("ffeb0c"),
-- 			BorderColor3 = Color3.fromHex("000000"),
-- 			Text = "Gold Machine",
-- 			TextStrokeTransparency = 0,
-- 			Size = UDim2.fromOffset(487, 50),
-- 			Font = 4,
-- 			BackgroundTransparency = 1,
-- 			Position = UDim2.fromScale(0.095, 0),
-- 			TextScaled = true,
-- 			TextSize = 14,
-- 			BorderSizePixel = 0,
-- 			BackgroundColor3 = Color3.fromHex("ffffff"),
-- 		}),
-- 	})
-- end

-- GoldMachineUI = RoactHooks.new(Roact)(GoldMachineUI)
-- return GoldMachineUI
