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
screenGui.Name = "AdminReportUI"
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 800, 0, 600)
mainFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Report Review"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 24
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local reportsList = Instance.new("ScrollingFrame")
reportsList.Name = "ReportsList"
reportsList.Size = UDim2.new(0.3, -20, 1, -60)
reportsList.Position = UDim2.new(0, 10, 0, 50)
reportsList.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
reportsList.BorderSizePixel = 0
reportsList.ScrollBarThickness = 6
reportsList.Parent = mainFrame

local reportDetails = Instance.new("Frame")
reportDetails.Name = "ReportDetails"
reportDetails.Size = UDim2.new(0.7, -30, 1, -60)
reportDetails.Position = UDim2.new(0.3, 20, 0, 50)
reportDetails.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
reportDetails.BorderSizePixel = 0
reportDetails.Parent = mainFrame

local reportInfo = Instance.new("TextLabel")
reportInfo.Name = "ReportInfo"
reportInfo.Size = UDim2.new(1, -40, 0, 100)
reportInfo.Position = UDim2.new(0, 20, 0, 20)
reportInfo.BackgroundTransparency = 1
reportInfo.Text = "Select a report to review"
reportInfo.TextColor3 = Color3.new(1, 1, 1)
reportInfo.TextSize = 16
reportInfo.TextWrapped = true
reportInfo.TextXAlignment = Enum.TextXAlignment.Left
reportInfo.Parent = reportDetails

local actionButtons = Instance.new("Frame")
actionButtons.Name = "ActionButtons"
actionButtons.Size = UDim2.new(1, -40, 0, 40)
actionButtons.Position = UDim2.new(0, 20, 1, -60)
actionButtons.BackgroundTransparency = 1
actionButtons.Parent = reportDetails

local removeButton = Instance.new("TextButton")
removeButton.Name = "RemoveButton"
removeButton.Size = UDim2.new(0.3, -10, 1, 0)
removeButton.Position = UDim2.new(0, 0, 0, 0)
removeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
removeButton.Text = "Remove Object"
removeButton.TextColor3 = Color3.new(1, 1, 1)
removeButton.TextSize = 16
removeButton.Parent = actionButtons

local warnButton = Instance.new("TextButton")
warnButton.Name = "WarnButton"
warnButton.Size = UDim2.new(0.3, -10, 1, 0)
warnButton.Position = UDim2.new(0.35, 0, 0, 0)
warnButton.BackgroundColor3 = Color3.fromRGB(200, 200, 0)
warnButton.Text = "Warn Owner"
warnButton.TextColor3 = Color3.new(0, 0, 0)
warnButton.TextSize = 16
warnButton.Parent = actionButtons

local dismissButton = Instance.new("TextButton")
dismissButton.Name = "DismissButton"
dismissButton.Size = UDim2.new(0.3, -10, 1, 0)
dismissButton.Position = UDim2.new(0.7, 0, 0, 0)
dismissButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
dismissButton.Text = "Dismiss"
dismissButton.TextColor3 = Color3.new(1, 1, 1)
dismissButton.TextSize = 16
dismissButton.Parent = actionButtons

local notesBox = Instance.new("TextBox")
notesBox.Name = "NotesBox"
notesBox.Size = UDim2.new(1, -40, 0, 100)
notesBox.Position = UDim2.new(0, 20, 1, -120)
notesBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
notesBox.Text = ""
notesBox.TextColor3 = Color3.new(1, 1, 1)
notesBox.TextSize = 16
notesBox.TextWrapped = true
notesBox.MultiLine = true
notesBox.PlaceholderText = "Add review notes here..."
notesBox.Parent = reportDetails

-- Variables
local activeReports = {}
local selectedReport = nil

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
    selectedReport = nil
end

local function updateReportDetails()
    if not selectedReport then
        reportInfo.Text = "Select a report to review"
        return
    end
    
    local info = string.format(
        "Report #%d\nType: %s\nReporter: %s\nDescription: %s\nStatus: %s",
        selectedReport.id,
        selectedReport.reportType,
        selectedReport.reporter.Name,
        selectedReport.description,
        selectedReport.status
    )
    
    reportInfo.Text = info
end

local function updateReportsList()
    -- Clear existing buttons
    for _, child in ipairs(reportsList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Add report buttons
    for i, report in ipairs(activeReports) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -20, 0, 40)
        button.Position = UDim2.new(0, 10, 0, (i-1) * 50)
        button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        button.Text = string.format("Report #%d - %s", report.id, report.reportType)
        button.TextColor3 = Color3.new(1, 1, 1)
        button.TextSize = 14
        button.TextXAlignment = Enum.TextXAlignment.Left
        button.TextWrapped = true
        button.Parent = reportsList
        
        button.MouseButton1Click:Connect(function()
            selectedReport = report
            updateReportDetails()
        end)
    end
end

local function handleReportAction(action)
    if not selectedReport then return end
    
    local notes = notesBox.Text
    reportObjectEvent:FireServer("review", selectedReport.id, action, notes)
    notesBox.Text = ""
    selectedReport = nil
    updateReportDetails()
end

-- Event handlers
reportObjectEvent.OnClientEvent:Connect(function(report)
    if report.type == "new" then
        table.insert(activeReports, report)
        updateReportsList()
    elseif report.type == "update" then
        for i, r in ipairs(activeReports) do
            if r.id == report.id then
                activeReports[i] = report
                break
            end
        end
        updateReportsList()
    end
end)

removeButton.MouseButton1Click:Connect(function()
    handleReportAction("remove")
end)

warnButton.MouseButton1Click:Connect(function()
    handleReportAction("warn")
end)

dismissButton.MouseButton1Click:Connect(function()
    handleReportAction("dismiss")
end)

-- Export functions
local AdminReportUI = {}

function AdminReportUI.show()
    showUI()
end

function AdminReportUI.hide()
    hideUI()
end

return AdminReportUI 