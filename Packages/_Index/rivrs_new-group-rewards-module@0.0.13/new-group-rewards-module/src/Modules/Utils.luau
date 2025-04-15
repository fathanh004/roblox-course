local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local Utils = {}

function Utils.findByPath(parent: Instance, path: string, time: number?)
	local pathParts = string.split(path, "/")
	local instance = parent
	for _, pathPart in pathParts do
		local child
		if time then
			child = instance:WaitForChild(pathPart, time)
		else
			child = instance:FindFirstChild(pathPart)
		end
		if child == nil then
			error(`failed to find {pathPart} in {instance:GetFullName()} (full path: {path}`, 2)
		end
		instance = child
	end

	return instance
end

function Utils.partToRegion(part)
	local position = part.Position
	local size = part.Size
	local region = Region3.new(position - size / 2, position + size / 2)

	return region
end

function Utils.connectCharacterInRegionEvent(
	regionPart: BasePart,
	callback: (character: Model, player: Player) -> (),
	debounceTime
)
	debounceTime = debounceTime or 0

	local debounceTable = {}

	local region = Utils.partToRegion(regionPart)

	local function checkRegion()
		local partsInRegion = Workspace:FindPartsInRegion3(region, nil, math.huge)

		for _, part in ipairs(partsInRegion) do
			local character = part.Parent
			local player = Players:GetPlayerFromCharacter(character)

			if character and player then
				local userId = player.UserId

				if debounceTable[userId] then
					return
				end

				debounceTable[userId] = true

				callback(character, player)

				if debounceTime > 0 then
					task.delay(debounceTime, function()
						debounceTable[userId] = nil
					end)
				else
					debounceTable[userId] = nil
				end
			end
		end
	end

	local connection
	connection = game:GetService("RunService").Heartbeat:Connect(function()
		checkRegion()
	end)

	return connection
end

-- Define a type for the callback function that will be executed when the player is added
type PlayerCallback = (Player) -> ()
-- Function to safely execute a callback for all current and future players
function Utils.connectPlayerAddedEvent(callback: PlayerCallback)
	-- Connect to the PlayerAdded event for future players
	Players.PlayerAdded:Connect(callback)

	-- Execute the callback for all players currently in the game
	for _, player in ipairs(Players:GetPlayers()) do
		callback(player)
	end
end

-- Define a type for the callback function that will be executed when the character is added
type CharacterCallback = (Model, Player) -> ()

-- Function to connect to CharacterAdded for all current and future players
function Utils.connectCharacterAddedEvent(callback: CharacterCallback)
	-- Function to handle CharacterAdded event for a single player
	local function connectCharacter(player)
		player.CharacterAdded:Connect(function(character)
			callback(character, player)
		end)

		if player.Character then
			callback(player.Character, player)
		end
	end

	Utils.connectPlayerAddedEvent(connectCharacter)
end

-- Define a type for the callback function that will be executed when the attribute change
type AttributeCallback = (Instance, any) -> ()

function Utils.connectAttributeEvent(instance, attributeName: string, callback: AttributeCallback)
	-- Execute the callback for a specific object
	local function executeCallback(object: Instance)
		if object then
			local newValue = instance:GetAttribute(attributeName)
			callback(newValue)
		end
	end

	executeCallback(instance)
	instance:GetAttributeChangedSignal(attributeName):Connect(function()
		executeCallback(instance)
	end)
end

-- Define a type for the callback function that will be executed when the tag is added
type TagCallback = (Instance) -> ()

-- Function to safely execute a callback for all objects with a specific tag
function Utils.connectTagEvent(tagName: string, callback: TagCallback)
	-- Execute the callback for a specific object
	local function executeCallback(object: Instance)
		if object then
			callback(object)
		end
	end

	-- Execute the callback for all currently tagged objects
	local taggedObjects: { Instance } = CollectionService:GetTagged(tagName)
	for _, object in ipairs(taggedObjects) do
		executeCallback(object)
	end

	-- Execute the callback for future objects that will be tagged
	CollectionService:GetInstanceAddedSignal(tagName):Connect(executeCallback)
end

-- Function to safely execute a callback for all current and future players
function Utils.connectPlayerRemovingEvent(callback: PlayerCallback)
	-- Connect to the PlayerRemoving event for future players
	Players.PlayerRemoving:Connect(callback)
end

-- Define a type for the callback function that will be executed when a character touches the part
type CharacterTouchedCallback = (Model, Player) -> ()

-- Function to connect a Touched event with optional debounce, executing the callback only if a character is detected
function Utils.connectCharacterTouchedEvent(part: BasePart, callback: CharacterTouchedCallback, debounceTime: number?)
	-- Set a default debounce time of 0 seconds if debounceTime is not provided
	debounceTime = debounceTime or 0

	-- Table to track debounce state for each player
	local debounceTable = {}

	-- Connect to the Touched event for the specified part
	local conn = part.Touched:Connect(function(hit)
		-- Get the character from the part that touched (if any)
		local character = hit:FindFirstAncestorWhichIsA("Model")
		local player = Players:GetPlayerFromCharacter(character)

		-- Check if a player is associated with the character
		if player then
			-- Get the player's unique UserId
			local userId = player.UserId

			-- Check if the player is already in the debounce table and has an active cooldown
			if debounceTable[userId] then
				return
			end

			-- Set debounce for the player
			debounceTable[userId] = true
			callback(character, player)

			-- Reset debounce after the specified debounce time, if it's greater than 0
			if debounceTime > 0 then
				task.delay(debounceTime, function()
					debounceTable[userId] = nil
				end)
			else
				-- Remove immediately if debounceTime is 0, allowing continuous triggers
				debounceTable[userId] = nil
			end
		end
	end)

	return conn
end

return Utils
