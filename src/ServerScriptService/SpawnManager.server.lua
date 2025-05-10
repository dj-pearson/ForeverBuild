local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)
local ObjectManager = require(ReplicatedStorage.Modules.ObjectManager)

local SpawnManager = {}

-- Spawn area boundaries
local SPAWN_BOUNDS = {
    minX = -1000,
    maxX = 1000,
    minZ = -1000,
    maxZ = 1000
}

-- Get random position within bounds
local function getRandomPosition()
    return Vector3.new(
        math.random(SPAWN_BOUNDS.minX, SPAWN_BOUNDS.maxX),
        0, -- Objects spawn at ground level
        math.random(SPAWN_BOUNDS.minZ, SPAWN_BOUNDS.maxZ)
    )
end

-- Check if position is valid for spawning
local function isValidSpawnPosition(position)
    -- Check if there's already an object nearby
    local radius = 10 -- Minimum distance between objects
    local part = Instance.new("Part")
    part.Size = Vector3.new(radius * 2, 1, radius * 2)
    part.Position = position
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    
    local parts = workspace:GetPartsInPart(part)
    part:Destroy()
    
    return #parts == 0
end

-- Spawn random object
function SpawnManager.spawnRandomObject()
    local position = getRandomPosition()
    
    -- Try to find a valid position
    local attempts = 0
    while not isValidSpawnPosition(position) and attempts < 10 do
        position = getRandomPosition()
        attempts = attempts + 1
    end
    
    if attempts >= 10 then
        warn("Could not find valid spawn position after 10 attempts")
        return nil
    end
      -- Get random object type
    local objectType = ObjectManager.getRandomObjectType()
    
    -- Create object
    local model = ObjectManager.createObject(objectType)
    if model then
        model:SetPrimaryPartCFrame(CFrame.new(position))
        model.Parent = workspace
        return model
    end
    
    return nil
end

-- Start random spawning
function SpawnManager.startRandomSpawning()    while true do
        wait(Constants.FREE_OBJECT_SPAWN_INTERVAL)
        
        -- Spawn multiple objects
        local objectCount = math.random(1, Constants.MAX_FREE_OBJECTS_PER_SPAWN)
        for _ = 1, objectCount do
            task.spawn(function()
                SpawnManager.spawnRandomObject()
            end)
        end
    end
end

-- Initialize
function SpawnManager.init()
    -- Start random spawning
    task.spawn(SpawnManager.startRandomSpawning)
    print("Spawn manager initialized")
end

return SpawnManager 