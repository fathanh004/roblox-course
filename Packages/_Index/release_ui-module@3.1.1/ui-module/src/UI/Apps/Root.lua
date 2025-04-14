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
local Roact = importPackage("roact")

function Generate(frames: table)
	if not frames then
		warn("[UI Module] - Missing or incorrect parameters.")
		return Core.ErrorCodes.MISSING_PARAMS
	end

	local _frames = {}
	local _counts = {}
	for name, frame in frames do
		local _name = name:match("^(.*)_([^_]*)$") or name

		if not _counts[_name] then
			_counts[_name] = 0
		else
			_counts[_name] += 1
		end

		local count = _counts[_name]
		local new_name = (count == 0) and _name or (_name .. "_" .. count)
		_frames[new_name] = Roact.createElement(frame)
	end

	local function GameFrame()
		return Roact.createElement("ScreenGui", {
			IgnoreGuiInset = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Global,
			ResetOnSpawn = false,
		}, _frames)
	end

	return GameFrame
end

return Generate
