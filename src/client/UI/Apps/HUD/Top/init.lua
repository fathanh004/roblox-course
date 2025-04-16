local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
	
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.RoactHooks)

local FramesFolder = script

local FrameRandomUUID = HttpService:GenerateGUID(false)
local FrameName = "Top" .. "_" .. FrameRandomUUID

function Top(_, hooks)
    return Roact.createElement("Frame", {
    AnchorPoint=Vector2.new(0.5,0.5),
    BackgroundTransparency=1,
    Position=UDim2.fromScale(0.5,0.08),
    BorderColor3=Color3.fromHex('000000'),
    BackgroundColor3=Color3.fromHex('ffffff'),
    BorderSizePixel=0,
    Size=UDim2.fromScale(0.55,0.08),
}, {
        UIListLayout = Roact.createElement("UIListLayout", {
    VerticalAlignment=0,
    SortOrder=2,
    HorizontalAlignment=0,
    Padding=UDim.new(0.05,0),
    FillDirection=0,
}),
Money3 = Roact.createElement(require(FramesFolder.Money3)),
Money2 = Roact.createElement(require(FramesFolder.Money2)),
Money1 = Roact.createElement(require(FramesFolder.Money1)),

    })
end

Top = RoactHooks.new(Roact)(Top)
return Top