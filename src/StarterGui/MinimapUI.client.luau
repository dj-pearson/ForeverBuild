local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local MinimapUI = {}

-- UI Elements
local screenGui
local mainFrame
local mapFrame
local playerDot
local enemyDots = {}

-- Create UI
function MinimapUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MinimapUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 200, 0, 200)
    mainFrame.Position = UDim2.new(1, -220, 0, 20)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Create map frame
    mapFrame = Instance.new("Frame")
    mapFrame.Name = "MapFrame"
    mapFrame.Size = UDim2.new(1, -20, 1, -20)
    mapFrame.Position = UDim2.new(0, 10, 0, 10)
    mapFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mapFrame.BorderSizePixel = 0
    mapFrame.Parent = mainFrame
    
    -- Create player dot
    playerDot = Instance.new("Frame")
    playerDot.Name = "PlayerDot"
    playerDot.Size = UDim2.new(0, 8, 0, 8)
    playerDot.Position = UDim2.new(0.5, -4, 0.5, -4)
    playerDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    playerDot.BorderSizePixel = 0
    playerDot.Parent = mapFrame
    
    -- Create player direction indicator
    local directionIndicator = Instance.new("Frame")
    directionIndicator.Name = "DirectionIndicator"
    directionIndicator.Size = UDim2.new(0, 2, 0, 12)
    directionIndicator.Position = UDim2.new(0.5, -1, 0.5, -12)
    directionIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    directionIndicator.BorderSizePixel = 0
    directionIndicator.Parent = playerDot
end

-- Create enemy dot
function MinimapUI.createEnemyDot(player)
    local dot = Instance.new("Frame")
    dot.Name = player.Name
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0.5, -3, 0.5, -3)
    dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    dot.BorderSizePixel = 0
    dot.Parent = mapFrame
    
    enemyDots[player] = dot
    return dot
end

-- Update player position
function MinimapUI.updatePlayerPosition(position, rotation)
    -- Convert world position to minimap position
    local mapSize = mapFrame.AbsoluteSize
    local worldSize = workspace.CurrentMap.Size
    local relativeX = (position.X + worldSize.X/2) / worldSize.X
    local relativeZ = (position.Z + worldSize.Z/2) / worldSize.Z
    
    -- Update player dot position
    playerDot.Position = UDim2.new(relativeX, -4, relativeZ, -4)
    
    -- Update direction indicator rotation
    local directionIndicator = playerDot:FindFirstChild("DirectionIndicator")
    if directionIndicator then
        directionIndicator.Rotation = rotation.Y
    end
end

-- Update enemy positions
function MinimapUI.updateEnemyPositions(positions)
    -- Remove old enemy dots
    for player, dot in pairs(enemyDots) do
        if not positions[player] then
            dot:Destroy()
            enemyDots[player] = nil
        end
    end
    
    -- Update or create enemy dots
    for player, position in pairs(positions) do
        local dot = enemyDots[player]
        if not dot then
            dot = MinimapUI.createEnemyDot(player)
        end
        
        -- Convert world position to minimap position
        local mapSize = mapFrame.AbsoluteSize
        local worldSize = workspace.CurrentMap.Size
        local relativeX = (position.X + worldSize.X/2) / worldSize.X
        local relativeZ = (position.Z + worldSize.Z/2) / worldSize.Z
        
        -- Update dot position
        dot.Position = UDim2.new(relativeX, -3, relativeZ, -3)
    end
end

-- Show minimap
function MinimapUI.show()
    mainFrame.Visible = true
    mainFrame.BackgroundTransparency = 1
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        BackgroundTransparency = 0.2
    })
    tween:Play()
end

-- Hide minimap
function MinimapUI.hide()
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        BackgroundTransparency = 1
    })
    tween:Play()
    
    task.delay(0.3, function()
        mainFrame.Visible = false
    end)
end

-- Initialize
function MinimapUI.init()
    MinimapUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.MinimapUpdate, function(playerPosition, playerRotation, enemyPositions)
        MinimapUI.updatePlayerPosition(playerPosition, playerRotation)
        MinimapUI.updateEnemyPositions(enemyPositions)
    end)
    
    -- Set up render step for smooth updates
    RunService.RenderStepped:Connect(function()
        if mainFrame.Visible then
            local character = Players.LocalPlayer.Character
            if character then
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    MinimapUI.updatePlayerPosition(humanoidRootPart.Position, humanoidRootPart.Orientation)
                end
            end
        end
    end)
end

return MinimapUI 