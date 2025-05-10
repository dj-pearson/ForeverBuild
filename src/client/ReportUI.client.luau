local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local reportObjectEvent = remotes:WaitForChild("ReportObject")
local reportResponseEvent = remotes:WaitForChild("ReportResponse")

-- Create UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ReportUI"
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Report Object"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 24
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local reportType = Instance.new("TextLabel")
reportType.Name = "ReportTypeLabel"
reportType.Size = UDim2.new(1, -40, 0, 20)
reportType.Position = UDim2.new(0, 20, 0, 50)
reportType.BackgroundTransparency = 1
reportType.Text = "Report Type:"
reportType.TextColor3 = Color3.new(1, 1, 1)
reportType.TextSize = 16
reportType.TextXAlignment = Enum.TextXAlignment.Left
reportType.Parent = mainFrame

local reportTypeDropdown = Instance.new("TextButton")
reportTypeDropdown.Name = "ReportTypeDropdown"
reportTypeDropdown.Size = UDim2.new(1, -40, 0, 30)
reportTypeDropdown.Position = UDim2.new(0, 20, 0, 70)
reportTypeDropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
reportTypeDropdown.Text = "Select Report Type"
reportTypeDropdown.TextColor3 = Color3.new(1, 1, 1)
reportTypeDropdown.TextSize = 16
reportTypeDropdown.Parent = mainFrame

local description = Instance.new("TextLabel")
description.Name = "DescriptionLabel"
description.Size = UDim2.new(1, -40, 0, 20)
description.Position = UDim2.new(0, 20, 0, 110)
description.BackgroundTransparency = 1
description.Text = "Description:"
description.TextColor3 = Color3.new(1, 1, 1)
description.TextSize = 16
description.TextXAlignment = Enum.TextXAlignment.Left
description.Parent = mainFrame

local descriptionBox = Instance.new("TextBox")
descriptionBox.Name = "DescriptionBox"
descriptionBox.Size = UDim2.new(1, -40, 0, 80)
descriptionBox.Position = UDim2.new(0, 20, 0, 130)
descriptionBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
descriptionBox.Text = ""
descriptionBox.TextColor3 = Color3.new(1, 1, 1)
descriptionBox.TextSize = 16
descriptionBox.TextWrapped = true
descriptionBox.MultiLine = true
descriptionBox.Parent = mainFrame

local submitButton = Instance.new("TextButton")
submitButton.Name = "SubmitButton"
submitButton.Size = UDim2.new(0.5, -30, 0, 40)
submitButton.Position = UDim2.new(0, 20, 1, -60)
submitButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
submitButton.Text = "Submit"
submitButton.TextColor3 = Color3.new(1, 1, 1)
submitButton.TextSize = 18
submitButton.Parent = mainFrame

local cancelButton = Instance.new("TextButton")
cancelButton.Name = "CancelButton"
cancelButton.Size = UDim2.new(0.5, -30, 0, 40)
cancelButton.Position = UDim2.new(0.5, 10, 1, -60)
cancelButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
cancelButton.Text = "Cancel"
cancelButton.TextColor3 = Color3.new(0, 0, 0)
cancelButton.TextSize = 18
cancelButton.Parent = mainFrame

-- Report types
local REPORT_TYPES = {
    "Inappropriate Content",
    "Harassment",
    "Exploitation",
    "Other"
}

-- Variables
local selectedObject = nil
local selectedReportType = nil

-- Functions
local function showUI()
    mainFrame.Visible = true
    mainFrame.BackgroundTransparency = 1
    TweenService:Create(mainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
end

local function hideUI()
    TweenService:Create(mainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    wait(0.3)
    mainFrame.Visible = false
    selectedObject = nil
    selectedReportType = nil
    reportTypeDropdown.Text = "Select Report Type"
    descriptionBox.Text = ""
end

local function showReportTypeDropdown()
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = "DropdownFrame"
    dropdownFrame.Size = UDim2.new(1, 0, 0, #REPORT_TYPES * 30)
    dropdownFrame.Position = UDim2.new(0, 0, 1, 0)
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Parent = reportTypeDropdown
    
    for i, reportType in ipairs(REPORT_TYPES) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 30)
        button.Position = UDim2.new(0, 0, 0, (i-1) * 30)
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        button.Text = reportType
        button.TextColor3 = Color3.new(1, 1, 1)
        button.TextSize = 16
        button.Parent = dropdownFrame
        
        button.MouseButton1Click:Connect(function()
            selectedReportType = reportType
            reportTypeDropdown.Text = reportType
            dropdownFrame:Destroy()
        end)
    end
end

-- Event handlers
reportTypeDropdown.MouseButton1Click:Connect(showReportTypeDropdown)

submitButton.MouseButton1Click:Connect(function()
    if not selectedObject then
        return
    end
    
    if not selectedReportType then
        return
    end
    
    local description = descriptionBox.Text
    if description == "" then
        return
    end
    
    reportObjectEvent:FireServer(selectedObject, selectedReportType, description)
    hideUI()
end)

cancelButton.MouseButton1Click:Connect(hideUI)

reportResponseEvent.OnClientEvent:Connect(function(success, message)
    -- Show response message to player
    local responseLabel = Instance.new("TextLabel")
    responseLabel.Size = UDim2.new(0, 200, 0, 50)
    responseLabel.Position = UDim2.new(0.5, -100, 0.8, 0)
    responseLabel.BackgroundColor3 = success and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    responseLabel.Text = message
    responseLabel.TextColor3 = Color3.new(1, 1, 1)
    responseLabel.TextSize = 16
    responseLabel.Parent = screenGui
    
    wait(3)
    responseLabel:Destroy()
end)

-- Export functions
local ReportUI = {}

function ReportUI.showReportMenu(object)
    selectedObject = object
    showUI()
end

return ReportUI 