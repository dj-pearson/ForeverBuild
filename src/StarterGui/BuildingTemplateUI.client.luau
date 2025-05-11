local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local BuildingTemplateUI = {}

-- UI Elements
local screenGui
local mainFrame
local templateList
local closeButton

-- Remote events
local saveTemplateEvent = ReplicatedStorage.Remotes.SaveTemplate
local loadTemplateEvent = ReplicatedStorage.Remotes.LoadTemplate
local shareTemplateEvent = ReplicatedStorage.Remotes.ShareTemplate
local likeTemplateEvent = ReplicatedStorage.Remotes.LikeTemplate
local commentTemplateEvent = ReplicatedStorage.Remotes.CommentTemplate
local getTemplatesEvent = ReplicatedStorage.Remotes.GetTemplates
local getFeaturedTemplatesEvent = ReplicatedStorage.Remotes.GetFeaturedTemplates

-- Create UI
function BuildingTemplateUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BuildingTemplateUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.4, 0, 0.6, 0)
    mainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Create title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    title.BorderSizePixel = 0
    title.Text = "Building Templates"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Create template list
    templateList = Instance.new("ScrollingFrame")
    templateList.Name = "TemplateList"
    templateList.Size = UDim2.new(1, -20, 1, -50)
    templateList.Position = UDim2.new(0, 10, 0, 50)
    templateList.BackgroundTransparency = 1
    templateList.BorderSizePixel = 0
    templateList.ScrollBarThickness = 6
    templateList.CanvasSize = UDim2.new(0, 0, 0, 0)
    templateList.Parent = mainFrame
    
    -- Create close button
    closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame
    
    -- Set up button events
    closeButton.MouseButton1Click:Connect(function()
        BuildingTemplateUI.hide()
    end)
end

-- Show UI
function BuildingTemplateUI.show()
    mainFrame.Visible = true
end

-- Hide UI
function BuildingTemplateUI.hide()
    mainFrame.Visible = false
end

-- Update template list
function BuildingTemplateUI.updateTemplates(templates)
    -- Clear existing templates
    for _, child in ipairs(templateList:GetChildren()) do
        child:Destroy()
    end
    
    -- Add new templates
    local yOffset = 0
    for _, template in ipairs(templates) do
        local templateButton = Instance.new("TextButton")
        templateButton.Name = template.id
        templateButton.Size = UDim2.new(1, 0, 0, 80)
        templateButton.Position = UDim2.new(0, 0, 0, yOffset)
        templateButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        templateButton.BorderSizePixel = 0
        templateButton.Text = template.name
        templateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        templateButton.TextSize = 16
        templateButton.Font = Enum.Font.GothamBold
        templateButton.Parent = templateList
        
        -- Template description
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "Description"
        descLabel.Size = UDim2.new(1, -20, 0, 40)
        descLabel.Position = UDim2.new(0, 10, 0, 30)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = template.description
        descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        descLabel.TextSize = 12
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextWrapped = true
        descLabel.Parent = templateButton
        
        -- Template button click handler
        templateButton.MouseButton1Click:Connect(function()
            RemoteManager:fireServer(Constants.RemoteEvents.LoadTemplate, template.id)
        end)
        
        yOffset = yOffset + 90
    end
    
    -- Update canvas size
    templateList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Initialize
function BuildingTemplateUI.init()
    BuildingTemplateUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.TemplateUpdate, function(templates)
        BuildingTemplateUI.updateTemplates(templates)
    end)
end

return BuildingTemplateUI 