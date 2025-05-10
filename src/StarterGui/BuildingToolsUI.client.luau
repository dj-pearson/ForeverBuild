local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local BuildingToolsUI = {}

-- UI Elements
local screenGui
local toolsFrame
local gridSnapButton
local rotationSnapButton
local copyButton
local pasteButton
local groupButton
local ungroupButton

-- Remote events
local selectObjectEvent = ReplicatedStorage.Remotes.SelectObject
local deselectObjectEvent = ReplicatedStorage.Remotes.DeselectObject
local copyObjectsEvent = ReplicatedStorage.Remotes.CopyObjects
local pasteObjectsEvent = ReplicatedStorage.Remotes.PasteObjects
local groupObjectsEvent = ReplicatedStorage.Remotes.GroupObjects
local ungroupObjectsEvent = ReplicatedStorage.Remotes.UngroupObjects
local setGridSnapEvent = ReplicatedStorage.Remotes.SetGridSnap
local setRotationSnapEvent = ReplicatedStorage.Remotes.SetRotationSnap

-- Create UI
function BuildingToolsUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BuildingToolsUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create tools frame
    toolsFrame = Instance.new("Frame")
    toolsFrame.Name = "ToolsFrame"
    toolsFrame.Size = UDim2.new(0, 200, 0, 300)
    toolsFrame.Position = UDim2.new(0, 10, 0.5, -150)
    toolsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    toolsFrame.BorderSizePixel = 0
    toolsFrame.Visible = false
    toolsFrame.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    title.BorderSizePixel = 0
    title.Text = "Building Tools"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = toolsFrame
    
    -- Create buttons
    local buttonHeight = 40
    local buttonSpacing = 10
    local y = 50
    
    -- Grid snap button
    gridSnapButton = BuildingToolsUI.createButton("Grid Snap", y)
    gridSnapButton.Parent = toolsFrame
    y = y + buttonHeight + buttonSpacing
    
    -- Rotation snap button
    rotationSnapButton = BuildingToolsUI.createButton("Rotation Snap", y)
    rotationSnapButton.Parent = toolsFrame
    y = y + buttonHeight + buttonSpacing
    
    -- Copy button
    copyButton = BuildingToolsUI.createButton("Copy", y)
    copyButton.Parent = toolsFrame
    y = y + buttonHeight + buttonSpacing
    
    -- Paste button
    pasteButton = BuildingToolsUI.createButton("Paste", y)
    pasteButton.Parent = toolsFrame
    y = y + buttonHeight + buttonSpacing
    
    -- Group button
    groupButton = BuildingToolsUI.createButton("Group", y)
    groupButton.Parent = toolsFrame
    y = y + buttonHeight + buttonSpacing
    
    -- Ungroup button
    ungroupButton = BuildingToolsUI.createButton("Ungroup", y)
    ungroupButton.Parent = toolsFrame
    
    -- Set up button events
    gridSnapButton.MouseButton1Click:Connect(function()
        BuildingToolsUI.toggleGridSnap()
    end)
    
    rotationSnapButton.MouseButton1Click:Connect(function()
        BuildingToolsUI.toggleRotationSnap()
    end)
    
    copyButton.MouseButton1Click:Connect(function()
        BuildingToolsUI.copyObjects()
    end)
    
    pasteButton.MouseButton1Click:Connect(function()
        BuildingToolsUI.pasteObjects()
    end)
    
    groupButton.MouseButton1Click:Connect(function()
        BuildingToolsUI.groupObjects()
    end)
    
    ungroupButton.MouseButton1Click:Connect(function()
        BuildingToolsUI.ungroupObjects()
    end)
    
    -- Set up keyboard shortcuts
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.G then
            BuildingToolsUI.toggleGridSnap()
        elseif input.KeyCode == Enum.KeyCode.R then
            BuildingToolsUI.toggleRotationSnap()
        elseif input.KeyCode == Enum.KeyCode.C and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            BuildingToolsUI.copyObjects()
        elseif input.KeyCode == Enum.KeyCode.V and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            BuildingToolsUI.pasteObjects()
        elseif input.KeyCode == Enum.KeyCode.G and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            BuildingToolsUI.groupObjects()
        elseif input.KeyCode == Enum.KeyCode.U and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            BuildingToolsUI.ungroupObjects()
        end
    end)
end

-- Create button
function BuildingToolsUI.createButton(text, y)
    local button = Instance.new("TextButton")
    button.Name = text .. "Button"
    button.Size = UDim2.new(1, -20, 0, 40)
    button.Position = UDim2.new(0, 10, 0, y)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.Font = Enum.Font.Gotham
    
    return button
end

-- Toggle grid snap
function BuildingToolsUI.toggleGridSnap()
    local success, message = setGridSnapEvent:InvokeServer(not gridSnapButton.BackgroundColor3:IsClose(Color3.fromRGB(0, 170, 0)))
    if success then
        gridSnapButton.BackgroundColor3 = gridSnapButton.BackgroundColor3:IsClose(Color3.fromRGB(0, 170, 0))
            and Color3.fromRGB(45, 45, 45)
            or Color3.fromRGB(0, 170, 0)
    end
end

-- Toggle rotation snap
function BuildingToolsUI.toggleRotationSnap()
    local success, message = setRotationSnapEvent:InvokeServer(not rotationSnapButton.BackgroundColor3:IsClose(Color3.fromRGB(0, 170, 0)))
    if success then
        rotationSnapButton.BackgroundColor3 = rotationSnapButton.BackgroundColor3:IsClose(Color3.fromRGB(0, 170, 0))
            and Color3.fromRGB(45, 45, 45)
            or Color3.fromRGB(0, 170, 0)
    end
end

-- Copy objects
function BuildingToolsUI.copyObjects()
    local success, message = copyObjectsEvent:InvokeServer()
    if success then
        BuildingToolsUI.showNotification("Objects copied to clipboard")
    else
        BuildingToolsUI.showError(message)
    end
end

-- Paste objects
function BuildingToolsUI.pasteObjects()
    local success, message = pasteObjectsEvent:InvokeServer()
    if success then
        BuildingToolsUI.showNotification("Objects pasted")
    else
        BuildingToolsUI.showError(message)
    end
end

-- Group objects
function BuildingToolsUI.groupObjects()
    local success, message = groupObjectsEvent:InvokeServer()
    if success then
        BuildingToolsUI.showNotification("Objects grouped")
    else
        BuildingToolsUI.showError(message)
    end
end

-- Ungroup objects
function BuildingToolsUI.ungroupObjects()
    local success, message = ungroupObjectsEvent:InvokeServer()
    if success then
        BuildingToolsUI.showNotification("Objects ungrouped")
    else
        BuildingToolsUI.showError(message)
    end
end

-- Show notification
function BuildingToolsUI.showNotification(message)
    -- Create notification
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 200, 0, 40)
    notification.Position = UDim2.new(0.5, -100, 0.1, 0)
    notification.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    notification.BorderSizePixel = 0
    notification.Parent = screenGui
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, 0, 1, 0)
    messageLabel.Position = UDim2.new(0, 0, 0, 0)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextSize = 16
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.Parent = notification
    
    -- Animate notification
    notification.BackgroundTransparency = 1
    messageLabel.TextTransparency = 1
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    local showTween = game:GetService("TweenService"):Create(notification, tweenInfo, {
        BackgroundTransparency = 0
    })
    
    local showTextTween = game:GetService("TweenService"):Create(messageLabel, tweenInfo, {
        TextTransparency = 0
    })
    
    showTween:Play()
    showTextTween:Play()
    
    -- Hide notification after delay
    task.delay(2, function()
        local hideTween = game:GetService("TweenService"):Create(notification, tweenInfo, {
            BackgroundTransparency = 1
        })
        
        local hideTextTween = game:GetService("TweenService"):Create(messageLabel, tweenInfo, {
            TextTransparency = 1
        })
        
        hideTween:Play()
        hideTextTween:Play()
        
        hideTween.Completed:Connect(function()
            notification:Destroy()
        end)
    end)
end

-- Show error
function BuildingToolsUI.showError(message)
    -- Create error dialog
    local errorDialog = Instance.new("Frame")
    errorDialog.Name = "ErrorDialog"
    errorDialog.Size = UDim2.new(0, 300, 0, 150)
    errorDialog.Position = UDim2.new(0.5, -150, 0.5, -75)
    errorDialog.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    errorDialog.BorderSizePixel = 0
    errorDialog.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    title.BorderSizePixel = 0
    title.Text = "Error"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = errorDialog
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -20, 0, 60)
    messageLabel.Position = UDim2.new(0, 10, 0, 50)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextSize = 16
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextWrapped = true
    messageLabel.Parent = errorDialog
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 100, 0, 30)
    closeButton.Position = UDim2.new(0.5, -50, 1, -40)
    closeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "Close"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.Gotham
    closeButton.Parent = errorDialog
    
    closeButton.MouseButton1Click:Connect(function()
        errorDialog:Destroy()
    end)
end

-- Show tools
function BuildingToolsUI.showTools()
    toolsFrame.Visible = true
end

-- Hide tools
function BuildingToolsUI.hideTools()
    toolsFrame.Visible = false
end

-- Initialize
function BuildingToolsUI.init()
    BuildingToolsUI.create()
end

return BuildingToolsUI 