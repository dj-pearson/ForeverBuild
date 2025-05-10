local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local ReportUI = require(script.Parent.ReportUI)

-- Create context menu
local contextMenu = Instance.new("Frame")
contextMenu.Name = "ReportContextMenu"
contextMenu.Size = UDim2.new(0, 200, 0, 40)
contextMenu.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
contextMenu.BorderSizePixel = 0
contextMenu.Visible = false
contextMenu.Parent = player.PlayerGui

local reportButton = Instance.new("TextButton")
reportButton.Name = "ReportButton"
reportButton.Size = UDim2.new(1, 0, 1, 0)
reportButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
reportButton.Text = "Report Object"
reportButton.TextColor3 = Color3.new(1, 1, 1)
reportButton.TextSize = 16
reportButton.Parent = contextMenu

-- Variables
local selectedObject = nil

-- Functions
local function showContextMenu()
    contextMenu.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
    contextMenu.Visible = true
end

local function hideContextMenu()
    contextMenu.Visible = false
    selectedObject = nil
end

-- Event handlers
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and not gameProcessed then
        local target = mouse.Target
        if target and target:IsA("BasePart") then
            selectedObject = target
            showContextMenu()
        end
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        hideContextMenu()
    end
end)

reportButton.MouseButton1Click:Connect(function()
    if selectedObject then
        ReportUI.showReportMenu(selectedObject)
        hideContextMenu()
    end
end)

-- Hide context menu when mouse moves
mouse.Move:Connect(function()
    if contextMenu.Visible then
        hideContextMenu()
    end
end) 