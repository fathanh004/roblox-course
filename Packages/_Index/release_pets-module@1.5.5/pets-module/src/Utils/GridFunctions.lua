--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--|| Imports ||--
local ImportFolder = ReplicatedStorage:FindFirstChild("Packages")

local src = script
while src and src.Name ~= "src" do
	src = src:FindFirstAncestorWhichIsA("Folder")
end

local function importPackage(name: string)
	local RootFolder = src and src:FindFirstAncestorWhichIsA("Folder") or nil

	return RootFolder and require(RootFolder[name]) or require(ImportFolder:FindFirstChild(name))
end

local Core = importPackage("core")

local GridFunctions = {}

local GetTableAmount = Core.Utils.Table.GetTableAmount
local DeepCopy = Core.Utils.Table.DeepCopy
local TemplateForPet = require(script.Parent.InfoTemplate)

local function GetPlacementInformation(PetAmount)
	local Rows = math.round(math.sqrt(PetAmount)) --// Squareroot the pet amount to get a  x by x amount and round it
	local Columns = math.ceil(PetAmount / Rows) --// Take total pet amount and divide by amount of rows
	return Rows, Columns
end

function GridFunctions.GetGrids(Pets, OldGrids, Player)
	local Grids = {}

	local TotalPetAmount = GetTableAmount(Pets)

	local Rows, Columns, RemainderColumns = GetPlacementInformation(TotalPetAmount)
	local RowIndex = 1
	local ColumnIndex = 0
	local LoopedIndex = 0

	for i, v in pairs(Pets) do
		if ColumnIndex == Columns then --// Reset columns and add a row to the index
			RowIndex = RowIndex + 1
			ColumnIndex = 0
		end
		ColumnIndex = ColumnIndex + 1

		local IsOnFinalRow = (tonumber(RowIndex) == tonumber(Rows) and true) or false --// If final row then find the remainder columnms
		if IsOnFinalRow and RemainderColumns == nil then
			RemainderColumns = #Pets - LoopedIndex
		end

		local Template

		if OldGrids[i] then
			Template = OldGrids[i]
		else
			Template = DeepCopy(TemplateForPet)
		end

		Template.Index = i

		Template.Row = RowIndex
		Template.Column = ColumnIndex

		--[[if IsOnFinalRow then
            if TotalPetAmount % 5 == 2 then
                if LoopedIndex + 1 == TotalPetAmount then Template.Column += 2
                else Template.Column += 1 end
            end
        end]]
		--

		if Template.PetData == "None" then
			Template.PetData = v
		end

		if Template.Information.Target == nil then
			local Character = Player.Character or Player.CharacterAdded:Wait()
			Template.Information.Target = Character:WaitForChild("HumanoidRootPart")
		end

		Template.TotalRows = Rows
		Template.TotalColumns = --[[(IsOnFinalRow == true and RemainderColumns) or]]
			Columns

		Grids[i] = Template
		LoopedIndex = LoopedIndex + 1
	end

	return Grids
end

return GridFunctions
