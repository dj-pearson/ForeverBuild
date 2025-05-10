local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)
local ObjectManager = require(ReplicatedStorage.Modules.ObjectManager)
local GameManager = require(ReplicatedStorage.Modules.GameManager)

-- Remote events
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local pickupDropEvent = Instance.new("RemoteEvent")
pickupDropEvent.Name = "PickupDrop"
pickupDropEvent.Parent = remotes

local RandomDropManager = {}

-- Active drops
local activeDrops = {}

-- Create glow effect
local function createGlowEffect(object)
    local glow = Instance.new("Part")
    glow.Name = "Glow"
    glow.Size = Constants.RANDOM_DROP.GLOW.SIZE
    glow.Transparency = Constants.RANDOM_DROP.GLOW.TRANSPARENCY
    glow.Color = Constants.RANDOM_DROP.GLOW.COLOR
    glow.Material = Enum.Material.Neon
    glow.Anchored = true
    glow.CanCollide = false
    glow.Parent = object
    
    -- Create pulse animation
    local tweenInfo = TweenInfo.new(
        Constants.RANDOM_DROP.GLOW.PULSE_SPEED,
        Enum.EasingStyle.Sine,
        Enum.EasingDirection.InOut,
        -1, -- Infinite
        true -- Reverses
    )
    
    local tween = TweenService:Create(glow, tweenInfo, {
        Transparency = Constants.RANDOM_DROP.GLOW.PULSE_MAX
    })
    tween:Play()
    
    return glow
end

-- Spawn random drop
function RandomDropManager.spawnRandomDrop()
    -- Check if we've reached the maximum number of active drops
    if #activeDrops >= Constants.RANDOM_DROP.MAX_ACTIVE_DROPS then
        return nil
    end
    
    -- Get random position
    local position = Vector3.new(
        math.random(Constants.SPAWN_BOUNDS.MIN_X, Constants.SPAWN_BOUNDS.MAX_X),
        Constants.SPAWN_BOUNDS.Y,
        math.random(Constants.SPAWN_BOUNDS.MIN_Z, Constants.SPAWN_BOUNDS.MAX_Z)
    )
    
    -- Create random object
    local objectType = ObjectManager.getRandomObjectType()
    local object = ObjectManager.createObject(objectType)
    if not object then return nil end
    
    -- Position object
    object:SetPrimaryPartCFrame(CFrame.new(position))
    object.Parent = workspace
    
    -- Add glow effect
    local glow = createGlowEffect(object)
    
    -- Add to active drops
    table.insert(activeDrops, {
        object = object,
        glow = glow,
        type = objectType
    })
    
    return object
end

-- Check for player pickups
local function checkPickups()
    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if not character then continue end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then continue end
        
        -- Check each active drop
        for i = #activeDrops, 1, -1 do
            local drop = activeDrops[i]
            local distance = (drop.object.PrimaryPart.Position - humanoidRootPart.Position).Magnitude
            
            if distance <= Constants.RANDOM_DROP.PICKUP_RADIUS then
                -- Add to player's inventory
                local data = GameManager.getPlayerData(player)
                if data then
                    table.insert(data.inventory, {
                        type = drop.type,
                        purchaseTime = os.time()
                    })
                    
                    -- Update stats
                    GameManager.updatePlayerStats(player, data)
                end
                
                -- Remove glow and object
                drop.glow:Destroy()
                drop.object:Destroy()
                table.remove(activeDrops, i)
                
                -- Notify client
                pickupDropEvent:FireClient(player, true, drop.type)
            end
        end
    end
end

-- Start random drop spawning
function RandomDropManager.startRandomDropSpawning()
    while true do
        wait(Constants.RANDOM_DROP.SPAWN_INTERVAL)
        task.spawn(function()
            RandomDropManager.spawnRandomDrop()
        end)
    end
end

-- Initialize
function RandomDropManager.init()
    -- Start random drop spawning
    task.spawn(RandomDropManager.startRandomDropSpawning)
    
    -- Start pickup checking
    game:GetService("RunService").Heartbeat:Connect(checkPickups)
    
    print("Random drop manager initialized")
end

return RandomDropManager 