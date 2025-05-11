local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get the remote manager
local Shared = require(ReplicatedStorage.Shared)
local remoteManager = Shared.Remotes

local ReportUI = {}

-- Create the report menu
local function createReportMenu()
    local player = Players.LocalPlayer
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ReportMenu"
    screenGui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Name = "ReportFrame"
    frame.Size = UDim2.new(0, 400, 0, 300)
    frame.Position = UDim2.new(0.5, -200, 0.5, -150)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    title.Text = "Report Object"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 20
    title.Parent = frame
    
    local reasonInput = Instance.new("TextBox")
    reasonInput.Name = "ReasonInput"
    reasonInput.Size = UDim2.new(0.9, 0, 0, 100)
    reasonInput.Position = UDim2.new(0.05, 0, 0.2, 0)
    reasonInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    reasonInput.TextColor3 = Color3.new(1, 1, 1)
    reasonInput.TextSize = 16
    reasonInput.MultiLine = true
    reasonInput.PlaceholderText = "Enter reason for report..."
    reasonInput.Parent = frame
    
    local submitButton = Instance.new("TextButton")
    submitButton.Name = "SubmitButton"
    submitButton.Size = UDim2.new(0.4, 0, 0, 40)
    submitButton.Position = UDim2.new(0.3, 0, 0.8, 0)
    submitButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    submitButton.Text = "Submit Report"
    submitButton.TextColor3 = Color3.new(1, 1, 1)
    submitButton.TextSize = 16
    submitButton.Parent = frame
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextSize = 16
    closeButton.Parent = frame
    
    screenGui.Parent = player.PlayerGui
    return screenGui
end

-- Show the report menu
function ReportUI.showReportMenu(object)
    local reportMenu = createReportMenu()
    local frame = reportMenu.ReportFrame
    frame.Visible = true
    
    -- Update title with object name
    frame.Title.Text = "Report: " .. object.Name
    
    -- Handle submit button
    frame.SubmitButton.MouseButton1Click:Connect(function()
        local reason = frame.ReasonInput.Text
        if reason and reason ~= "" then
            -- Send report to server
            remoteManager:fireRemote("SubmitReport", {
                objectId = object:GetFullName(),
                reason = reason,
                timestamp = os.time()
            })
            
            -- Show confirmation
            frame.Title.Text = "Report Submitted"
            frame.Title.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
            task.wait(2)
            frame.Visible = false
            reportMenu:Destroy()
        end
    end)
    
    -- Handle close button
    frame.CloseButton.MouseButton1Click:Connect(function()
        frame.Visible = false
        reportMenu:Destroy()
    end)
end

return ReportUI 