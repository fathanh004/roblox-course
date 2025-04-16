local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
	
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.RoactHooks)

local FramesFolder = script

local FrameRandomUUID = HttpService:GenerateGUID(false)
local FrameName = "Money2" .. "_" .. FrameRandomUUID

function Money2(_, hooks)
    return Roact.createElement("Frame", {
    LayoutOrder=2,
    BorderColor3=Color3.fromHex('000000'),
    BackgroundColor3=Color3.fromHex('ffffff'),
    BorderSizePixel=0,
    Size=UDim2.fromScale(0.275,0.8),
}, {
        UIGradient = Roact.createElement("UIGradient", {
    Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHex('68c53c')),ColorSequenceKeypoint.new(1,Color3.fromHex('9ff69f'))}),
}),
Amount = Roact.createElement("TextLabel", {
    TextWrapped=true,
    TextColor3=Color3.fromHex('ffffff'),
    BorderColor3=Color3.fromHex('000000'),
    Text="3.05k",
    Size=UDim2.fromScale(0.5,0.55),
    AnchorPoint=Vector2.new(0.5,0.5),
    Font=34,
    BackgroundTransparency=1,
    Position=UDim2.fromScale(0.55,0.5),
    TextScaled=true,
    TextSize=14,
    BorderSizePixel=0,
    BackgroundColor3=Color3.fromHex('ffffff'),
}, {UIStroke = Roact.createElement("UIStroke", {
    Thickness=1.25,
}),
}),
UICorner = Roact.createElement("UICorner", {
    CornerRadius=UDim.new(1,0),
}),
UIStroke = Roact.createElement("UIStroke", {
    Color=Color3.fromHex('ffffff'),
    Thickness=2,
}),
Icon = Roact.createElement("ImageLabel", {
    ScaleType=3,
    BorderColor3=Color3.fromHex('000000'),
    AnchorPoint=Vector2.new(0.5,0.5),
    Image="rbxassetid://16254845422",
    BackgroundTransparency=1,
    Position=UDim2.fromScale(0.1,0.5),
    BackgroundColor3=Color3.fromHex('ffffff'),
    Rotation=10,
    BorderSizePixel=0,
    Size=UDim2.fromScale(0.3,1.4),
}),

    })
end

Money2 = RoactHooks.new(Roact)(Money2)
return Money2