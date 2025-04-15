-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Knit packages
local Packages = ReplicatedStorage.Packages
local Knit = require(Packages.Knit)

local PetsController = require(ReplicatedStorage.Packages.petsModule)

-- Player
local player = Players.LocalPlayer

-- MyPetController
local MyPetController = Knit.CreateController({
	Name = "MyPetController",
})

--|| Local Functions ||--

--|| Functions ||--

function MyPetController:KnitStart()
	PetsController:SetPetsVisible(true)
end

return MyPetController
