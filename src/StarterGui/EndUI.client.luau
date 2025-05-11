local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local EndUI = {}

-- UI Elements
local screenGui
local mainFrame
local blurEffect
local resultFrame
local statsFrame
local playerList

-- Create UI
function EndUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EndUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create blur effect
    blurEffect = Instance.new("BlurEffect")
    blurEffect.Name = "BlurEffect"
    blurEffect.Size = 20
    blurEffect.Enabled = false
    blurEffect.Parent = screenGui
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 800, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Create result frame
    resultFrame = Instance.new("Frame")
    resultFrame.Name = "ResultFrame"
    resultFrame.Size = UDim2.new(1, 0, 0, 150)
    resultFrame.Position = UDim2.new(0, 0, 0, 0)
    resultFrame.BackgroundTransparency = 1
    resultFrame.Parent = mainFrame
    
    -- Create result title
    local resultTitle = Instance.new("TextLabel")
    resultTitle.Name = "ResultTitle"
    resultTitle.Size = UDim2.new(1, 0, 1, 0)
    resultTitle.Position = UDim2.new(0, 0, 0, 0)
    resultTitle.BackgroundTransparency = 1
    resultTitle.Text = ""
    resultTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    resultTitle.TextSize = 72
    resultTitle.Font = Enum.Font.GothamBold
    resultTitle.Parent = resultFrame
    
    -- Create stats frame
    statsFrame = Instance.new("Frame")
    statsFrame.Name = "StatsFrame"
    statsFrame.Size = UDim2.new(1, -40, 0, 100)
    statsFrame.Position = UDim2.new(0, 20, 0, 170)
    statsFrame.BackgroundTransparency = 1
    statsFrame.Parent = mainFrame
    
    -- Create stats labels
    local stats = {
        {name = "Kills", value = "0"},
        {name = "Deaths", value = "0"},
        {name = "K/D Ratio", value = "0.00"},
        {name = "Score", value = "0"}
    }
    
    for i, stat in ipairs(stats) do
        local statFrame = Instance.new("Frame")
        statFrame.Name = stat.name .. "Frame"
        statFrame.Size = UDim2.new(0.25, 0, 1, 0)
        statFrame.Position = UDim2.new(0.25 * (i - 1), 0, 0, 0)
        statFrame.BackgroundTransparency = 1
        statFrame.Parent = statsFrame
        
        local statName = Instance.new("TextLabel")
        statName.Name = "Name"
        statName.Size = UDim2.new(1, 0, 0, 30)
        statName.Position = UDim2.new(0, 0, 0, 0)
        statName.BackgroundTransparency = 1
        statName.Text = stat.name
        statName.TextColor3 = Color3.fromRGB(200, 200, 200)
        statName.TextSize = 18
        statName.Font = Enum.Font.Gotham
        statName.Parent = statFrame
        
        local statValue = Instance.new("TextLabel")
        statValue.Name = "Value"
        statValue.Size = UDim2.new(1, 0, 0, 40)
        statValue.Position = UDim2.new(0, 0, 0, 40)
        statValue.BackgroundTransparency = 1
        statValue.Text = stat.value
        statValue.TextColor3 = Color3.fromRGB(255, 255, 255)
        statValue.TextSize = 32
        statValue.Font = Enum.Font.GothamBold
        statValue.Parent = statFrame
    end
    
    -- Create player list
    playerList = Instance.new("ScrollingFrame")
    playerList.Name = "PlayerList"
    playerList.Size = UDim2.new(1, -40, 0, 300)
    playerList.Position = UDim2.new(0, 20, 0, 290)
    playerList.BackgroundTransparency = 1
    playerList.BorderSizePixel = 0
    playerList.ScrollBarThickness = 6
    playerList.ScrollingDirection = Enum.ScrollingDirection.Y
    playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
    playerList.Parent = mainFrame
    
    -- Create list header
    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "HeaderFrame"
    headerFrame.Size = UDim2.new(1, 0, 0, 40)
    headerFrame.Position = UDim2.new(0, 0, 0, 0)
    headerFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    headerFrame.BorderSizePixel = 0
    headerFrame.Parent = playerList
    
    local headers = {
        {text = "Player", width = 0.4},
        {text = "Kills", width = 0.15},
        {text = "Deaths", width = 0.15},
        {text = "K/D", width = 0.15},
        {text = "Score", width = 0.15}
    }
    
    local xOffset = 0
    for _, header in ipairs(headers) do
        local headerLabel = Instance.new("TextLabel")
        headerLabel.Name = header.text .. "Header"
        headerLabel.Size = UDim2.new(header.width, 0, 1, 0)
        headerLabel.Position = UDim2.new(xOffset, 0, 0, 0)
        headerLabel.BackgroundTransparency = 1
        headerLabel.Text = header.text
        headerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        headerLabel.TextSize = 18
        headerLabel.Font = Enum.Font.GothamBold
        headerLabel.Parent = headerFrame
        
        xOffset = xOffset + header.width
    end
end

-- Create player row
function EndUI.createPlayerRow(playerData)
    local rowFrame = Instance.new("Frame")
    rowFrame.Name = playerData.name
    rowFrame.Size = UDim2.new(1, 0, 0, 40)
    rowFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    rowFrame.BorderSizePixel = 0
    
    -- Create player name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = playerData.name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Padding.Left = UDim.new(0, 10)
    nameLabel.Parent = rowFrame
    
    -- Create kills
    local killsLabel = Instance.new("TextLabel")
    killsLabel.Name = "Kills"
    killsLabel.Size = UDim2.new(0.15, 0, 1, 0)
    killsLabel.Position = UDim2.new(0.4, 0, 0, 0)
    killsLabel.BackgroundTransparency = 1
    killsLabel.Text = tostring(playerData.kills)
    killsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    killsLabel.TextSize = 16
    killsLabel.Font = Enum.Font.Gotham
    killsLabel.Parent = rowFrame
    
    -- Create deaths
    local deathsLabel = Instance.new("TextLabel")
    deathsLabel.Name = "Deaths"
    deathsLabel.Size = UDim2.new(0.15, 0, 1, 0)
    deathsLabel.Position = UDim2.new(0.55, 0, 0, 0)
    deathsLabel.BackgroundTransparency = 1
    deathsLabel.Text = tostring(playerData.deaths)
    deathsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    deathsLabel.TextSize = 16
    deathsLabel.Font = Enum.Font.Gotham
    deathsLabel.Parent = rowFrame
    
    -- Create K/D
    local kdLabel = Instance.new("TextLabel")
    kdLabel.Name = "KD"
    kdLabel.Size = UDim2.new(0.15, 0, 1, 0)
    kdLabel.Position = UDim2.new(0.7, 0, 0, 0)
    kdLabel.BackgroundTransparency = 1
    kdLabel.Text = string.format("%.2f", playerData.kills / (playerData.deaths > 0 and playerData.deaths or 1))
    kdLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    kdLabel.TextSize = 16
    kdLabel.Font = Enum.Font.Gotham
    kdLabel.Parent = rowFrame
    
    -- Create score
    local scoreLabel = Instance.new("TextLabel")
    scoreLabel.Name = "Score"
    scoreLabel.Size = UDim2.new(0.15, 0, 1, 0)
    scoreLabel.Position = UDim2.new(0.85, 0, 0, 0)
    scoreLabel.BackgroundTransparency = 1
    scoreLabel.Text = tostring(playerData.score)
    scoreLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    scoreLabel.TextSize = 16
    scoreLabel.Font = Enum.Font.Gotham
    scoreLabel.Parent = rowFrame
    
    return rowFrame
end

-- Update end UI
function EndUI.updateEndUI(data)
    -- Update result title
    local resultTitle = resultFrame:FindFirstChild("ResultTitle")
    if resultTitle then
        resultTitle.Text = data.winner == "Red" and "RED TEAM WINS!" or "BLUE TEAM WINS!"
        resultTitle.TextColor3 = data.winner == "Red" and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 0, 255)
    end
    
    -- Update stats
    local stats = {
        {name = "Kills", value = tostring(data.stats.kills)},
        {name = "Deaths", value = tostring(data.stats.deaths)},
        {name = "K/D Ratio", value = string.format("%.2f", data.stats.kills / (data.stats.deaths > 0 and data.stats.deaths or 1))},
        {name = "Score", value = tostring(data.stats.score)}
    }
    
    for i, stat in ipairs(stats) do
        local statFrame = statsFrame:FindFirstChild(stat.name .. "Frame")
        if statFrame then
            local valueLabel = statFrame:FindFirstChild("Value")
            if valueLabel then
                valueLabel.Text = stat.value
            end
        end
    end
    
    -- Update player list
    for _, child in ipairs(playerList:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "HeaderFrame" then
            child:Destroy()
        end
    end
    
    local yOffset = 40
    for _, playerData in ipairs(data.players) do
        local row = EndUI.createPlayerRow(playerData)
        row.Position = UDim2.new(0, 0, 0, yOffset)
        row.Parent = playerList
        yOffset = yOffset + 40
    end
    
    playerList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Show end UI
function EndUI.show()
    mainFrame.Visible = true
    mainFrame.BackgroundTransparency = 1
    blurEffect.Enabled = true
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        BackgroundTransparency = 0.2
    })
    tween:Play()
end

-- Hide end UI
function EndUI.hide()
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        BackgroundTransparency = 1
    })
    tween:Play()
    
    task.delay(0.3, function()
        mainFrame.Visible = false
        blurEffect.Enabled = false
    end)
end

-- Initialize
function EndUI.init()
    EndUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.ShowEnd, function(data)
        EndUI.updateEndUI(data)
        EndUI.show()
    end)
    
    RemoteManager:onClientEvent(Constants.RemoteEvents.HideEnd, function()
        EndUI.hide()
    end)
end

return EndUI 