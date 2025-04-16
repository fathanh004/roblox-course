-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local HttpService = game:GetService("HttpService")

-- local Roact = require(ReplicatedStorage.Packages.Roact)
-- local RoactHooks = require(ReplicatedStorage.Packages.RoactHooks)
-- local RoduxHooks = require(ReplicatedStorage.Packages.RoduxHooks)

-- local FramesFolder = script.Parent

-- local FrameRandomUUID = HttpService:GenerateGUID(false)
-- local FrameName = "PetList" .. "_" .. FrameRandomUUID

-- function PetList(_, hooks)
-- 	local PetState = RoduxHooks.useSelector(hooks, function(state)
-- 		return state.PetReducer
-- 	end)

-- 	local petElements = {}

-- 	for index, petData in ipairs(PetState.pets or {}) do
-- 		table.insert(
-- 			petElements,
-- 			Roact.createElement(require(FramesFolder.Pet), {
-- 				key = petData.uuid,
-- 				pet = petData,
-- 			})
-- 		)
-- 	end

-- 	print("PetList", petElements)

-- 	return Roact.createElement("Frame", {
-- 		Position = UDim2.fromScale(0.028, 0.1),
-- 		BorderColor3 = Color3.fromHex("000000"),
-- 		BackgroundColor3 = Color3.fromHex("ffffff"),
-- 		BorderSizePixel = 0,
-- 		Size = UDim2.fromOffset(566, 421),
-- 	}, {
-- 		UIGridLayout = Roact.createElement("UIGridLayout", {
-- 			SortOrder = Enum.SortOrder.LayoutOrder,
-- 			CellSize = UDim2.fromOffset(100, 130),
-- 			CellPadding = UDim2.fromOffset(16, 10),
-- 		}),
-- 		-- Tambahkan semua elemen pet ke dalam frame
-- 		Pets = Roact.createFragment(petElements),
-- 	})
-- end

-- PetList = RoactHooks.new(Roact)(PetList)
-- return PetList
