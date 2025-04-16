local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.RoactHooks)
local RoduxHooks = require(ReplicatedStorage.Packages.RoduxHooks)
local RoactSpring = require(ReplicatedStorage.Packages.RoactSpring)

local FramesFolder = script

function Container(_, hooks)
	local PlayerReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.PlayerReducer
	end)

	local UIReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.UIReducer
	end)

	local PetReducer = RoduxHooks.useSelector(hooks, function(state)
		return state.PetReducer
	end)

	local isOpen, setIsOpen = hooks.useState(UIReducer.CurrentFrame == "Pets")

	hooks.useEffect(function()
		setIsOpen(UIReducer.CurrentFrame == "Pets")
	end, { UIReducer })

	local props = {
		scale = if isOpen then 1 else 0,
		transparency = if isOpen then 0 else 1,
		delay = if isOpen then 0.05 else 0,
		config = {
			duration = if isOpen then 0.05 else 0,
		},
	}

	local petCount = #PetReducer.pets
	local petFrames = {}
	print(PetReducer.pets, petCount)
	if petCount > 0 then
		local springs, api = RoactSpring.useTrail(hooks, petCount, function()
			return props
		end)

		print("Springs: ", springs)
		hooks.useEffect(function()
			api.start(function()
				return props
			end)
		end, { isOpen })

		for i, pet in ipairs(PetReducer.pets) do
			petFrames[pet.uuid] = Roact.createElement(require(FramesFolder.Template), {
				PetName = pet.name,
				PetImageId = pet.imageId,
				Transparency = springs[i].transparency,
				Scale = springs[i].scale,
				LayoutOrder = i,
			})
		end
	end

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BorderColor3 = Color3.fromHex("000000"),
		BackgroundColor3 = Color3.fromHex("ffffff"),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(0.95, 0.95),
	}, {
		UIGridLayout = Roact.createElement("UIGridLayout", {
			CellPadding = UDim2.fromScale(0.02, 0.04),
			SortOrder = 2,
			HorizontalAlignment = 0,
			CellSize = UDim2.fromScale(0.18, 0.25),
		}),
		PetFrames = Roact.createFragment(petFrames),
	})
end

Container = RoactHooks.new(Roact)(Container)
return Container
