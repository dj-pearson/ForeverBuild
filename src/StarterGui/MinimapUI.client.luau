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
local teamDots
local objectiveMarkers

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
    mainFrame.Position = UDim2.new(1, -220, 1, -220)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BackgroundTransparency = 0.5
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Create map frame
    mapFrame = Instance.new("Frame")
    mapFrame.Name = "MapFrame"
    mapFrame.Size = UDim2.new(1, -20, 1, -20)
    mapFrame.Position = UDim2.new(0, 10, 0, 10)
    mapFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    mapFrame.BorderSizePixel = 0
    mapFrame.Parent = mainFrame
    
    -- Create player dot
    playerDot = Instance.new("Frame")
    playerDot.Name = "PlayerDot"
    playerDot.Size = UDim2.new(0, 8, 0, 8)
    playerDot.Position = UDim2.new(0.5, -4, 0.5, -4)
    playerDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    playerDot.BorderSizePixel = 0
    playerDot.Parent = mapFrame
    
    -- Create team dots container
    teamDots = Instance.new("Frame")
    teamDots.Name = "TeamDots"
    teamDots.Size = UDim2.new(1, 0, 1, 0)
    teamDots.Position = UDim2.new(0, 0, 0, 0)
    teamDots.BackgroundTransparency = 1
    teamDots.Parent = mapFrame
    
    -- Create objective markers container
    objectiveMarkers = Instance.new("Frame")
    objectiveMarkers.Name = "ObjectiveMarkers"
    objectiveMarkers.Size = UDim2.new(1, 0, 1, 0)
    objectiveMarkers.Position = UDim2.new(0, 0, 0, 0)
    objectiveMarkers.BackgroundTransparency = 1
    objectiveMarkers.Parent = mapFrame
end

-- Create team dot
function MinimapUI.createTeamDot(playerData)
    local dot = Instance.new("Frame")
    dot.Name = playerData.name
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0.5, -3, 0.5, -3)
    dot.BackgroundColor3 = playerData.team == "Red" and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 0, 255)
    dot.BorderSizePixel = 0
    dot.Parent = teamDots
    
    return dot
end

-- Create objective marker
function MinimapUI.createObjectiveMarker(objectiveData)
    local marker = Instance.new("Frame")
    marker.Name = objectiveData.name
    marker.Size = UDim2.new(0, 12, 0, 12)
    marker.Position = UDim2.new(0.5, -6, 0.5, -6)
    marker.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
    marker.BorderSizePixel = 0
    marker.Parent = objectiveMarkers
    
    return marker
end

-- Update player position
function MinimapUI.updatePlayerPosition(position, rotation)
    -- Convert world position to minimap position
    local mapSize = mapFrame.AbsoluteSize
    local worldSize = Constants.WorldSize
    local x = (position.X + worldSize/2) / worldSize
    local z = (position.Z + worldSize/2) / worldSize
    
    -- Update player dot position
    playerDot.Position = UDim2.new(x, -4, z, -4)
    
    -- Update player dot rotation
    playerDot.Rotation = rotation
end

-- Update team positions
function MinimapUI.updateTeamPositions(teamData)
    -- Clear existing team dots
    for _, child in ipairs(teamDots:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Create new team dots
    for _, playerData in ipairs(teamData) do
        local dot = MinimapUI.createTeamDot(playerData)
        
        -- Convert world position to minimap position
        local mapSize = mapFrame.AbsoluteSize
        local worldSize = Constants.WorldSize
        local x = (playerData.position.X + worldSize/2) / worldSize
        local z = (playerData.position.Z + worldSize/2) / worldSize
        
        dot.Position = UDim2.new(x, -3, z, -3)
    end
end

-- Update objective positions
function MinimapUI.updateObjectivePositions(objectiveData)
    -- Clear existing objective markers
    for _, child in ipairs(objectiveMarkers:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Create new objective markers
    for _, objective in ipairs(objectiveData) do
        local marker = MinimapUI.createObjectiveMarker(objective)
        
        -- Convert world position to minimap position
        local mapSize = mapFrame.AbsoluteSize
        local worldSize = Constants.WorldSize
        local x = (objective.position.X + worldSize/2) / worldSize
        local z = (objective.position.Z + worldSize/2) / worldSize
        
        marker.Position = UDim2.new(x, -6, z, -6)
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
    RemoteManager:onClientEvent(Constants.RemoteEvents.TeamPositionsUpdate, function(teamData)
        MinimapUI.updateTeamPositions(teamData)
    end)
    
    RemoteManager:onClientEvent(Constants.RemoteEvents.ObjectivesUpdate, function(objectiveData)
        MinimapUI.updateObjectivePositions(objectiveData)
    end)
    
    -- Update player position every frame
    RunService.RenderStepped:Connect(function()
        local character = Players.LocalPlayer.Character
        if character then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                MinimapUI.updatePlayerPosition(humanoidRootPart.Position, humanoidRootPart.Orientation.Y)
            end
        end
    end)
end

return MinimapUI 