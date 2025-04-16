local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
	
local Roact = require(ReplicatedStorage.Packages.Roact)
local RoactHooks = require(ReplicatedStorage.Packages.RoactHooks)

local FramesFolder = script

local FrameRandomUUID = HttpService:GenerateGUID(false)
local FrameName = "Notification" .. "_" .. FrameRandomUUID

function Notification(_, hooks)
    return Roact.createElement("Frame", {
    BorderColor3=Color3.fromHex('000000'),
    AnchorPoint=Vector2.new(0.5,0.5),
    Rotation=5,
    BackgroundTransparency=1,
    Position=UDim2.fromScale(0.9,0.1),
    BackgroundColor3=Color3.fromHex('ffffff'),
    ZIndex=3,
    BorderSizePixel=0,
    Size=UDim2.fromScale(0.3,0.3),
}, {
        UICorner = Roact.createElement("UICorner", {
    CornerRadius=UDim.new(0.2,0),
}),
Mark = Roact.createElement("TextLabel", {
    TextWrapped=true,
    TextColor3=Color3.fromHex('ff5733'),
    BorderColor3=Color3.fromHex('000000'),
    Text="!",
    Size=UDim2.fromScale(1,1),
    AnchorPoint=Vector2.new(0.5,0.5),
    Font=32,
    BackgroundTransparency=1,
    Position=UDim2.fromScale(0.5,0.5),
    TextScaled=true,
    TextSize=14,
    BorderSizePixel=0,
    BackgroundColor3=Color3.fromHex('ffffff'),
}, {UIStroke = Roact.createElement("UIStroke", {
    Thickness=2,
}),
}),

    })
end

Notification = RoactHooks.new(Roact)(Notification)
return Notification