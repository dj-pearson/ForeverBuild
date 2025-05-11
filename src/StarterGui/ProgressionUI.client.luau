local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local ProgressionUI = {}

-- Local variables
local screenGui
local mainFrame
local levelFrame
local skillsFrame
local prestigeFrame
local currentTab = "level"

-- Remote events
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local getLevelEvent = remotes:WaitForChild("GetLevel")
local getSkillsEvent = remotes:WaitForChild("GetSkills")
local getPrestigeEvent = remotes:WaitForChild("GetPrestige")
local addXPEvent = remotes:WaitForChild("AddXP")
local upgradeSkillEvent = remotes:WaitForChild("UpgradeSkill")
local prestigeEvent = remotes:WaitForChild("Prestige")

-- Create UI
function ProgressionUI.create()
    -- Create main screen GUI
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ProgressionUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.4, 0, 0.3, 0)
    mainFrame.Position = UDim2.new(0.3, 0, 0.35, 0)
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
    title.Text = "Player Progression"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Create tab buttons
    local tabButtons = Instance.new("Frame")
    tabButtons.Name = "TabButtons"
    tabButtons.Size = UDim2.new(1, 0, 0.1, 0)
    tabButtons.Position = UDim2.new(0, 0, 0.1, 0)
    tabButtons.BackgroundTransparency = 1
    tabButtons.Parent = mainFrame
    
    -- Level tab button
    local levelTab = Instance.new("TextButton")
    levelTab.Name = "LevelTab"
    levelTab.Size = UDim2.new(0.33, 0, 1, 0)
    levelTab.Position = UDim2.new(0, 0, 0, 0)
    levelTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    levelTab.BorderSizePixel = 0
    levelTab.Text = "Level"
    levelTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    levelTab.TextScaled = true
    levelTab.Font = Enum.Font.GothamBold
    levelTab.Parent = tabButtons
    
    -- Skills tab button
    local skillsTab = Instance.new("TextButton")
    skillsTab.Name = "SkillsTab"
    skillsTab.Size = UDim2.new(0.33, 0, 1, 0)
    skillsTab.Position = UDim2.new(0.33, 0, 0, 0)
    skillsTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    skillsTab.BorderSizePixel = 0
    skillsTab.Text = "Skills"
    skillsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    skillsTab.TextScaled = true
    skillsTab.Font = Enum.Font.GothamBold
    skillsTab.Parent = tabButtons
    
    -- Prestige tab button
    local prestigeTab = Instance.new("TextButton")
    prestigeTab.Name = "PrestigeTab"
    prestigeTab.Size = UDim2.new(0.33, 0, 1, 0)
    prestigeTab.Position = UDim2.new(0.66, 0, 0, 0)
    prestigeTab.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    prestigeTab.BorderSizePixel = 0
    prestigeTab.Text = "Prestige"
    prestigeTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    prestigeTab.TextScaled = true
    prestigeTab.Font = Enum.Font.GothamBold
    prestigeTab.Parent = tabButtons
    
    -- Create content frames
    levelFrame = Instance.new("Frame")
    levelFrame.Name = "LevelFrame"
    levelFrame.Size = UDim2.new(1, 0, 0.8, 0)
    levelFrame.Position = UDim2.new(0, 0, 0.2, 0)
    levelFrame.BackgroundTransparency = 1
    levelFrame.Visible = true
    levelFrame.Parent = mainFrame
    
    skillsFrame = Instance.new("Frame")
    skillsFrame.Name = "SkillsFrame"
    skillsFrame.Size = UDim2.new(1, 0, 0.8, 0)
    skillsFrame.Position = UDim2.new(0, 0, 0.2, 0)
    skillsFrame.BackgroundTransparency = 1
    skillsFrame.Visible = false
    skillsFrame.Parent = mainFrame
    
    prestigeFrame = Instance.new("Frame")
    prestigeFrame.Name = "PrestigeFrame"
    prestigeFrame.Size = UDim2.new(1, 0, 0.8, 0)
    prestigeFrame.Position = UDim2.new(0, 0, 0.2, 0)
    prestigeFrame.BackgroundTransparency = 1
    prestigeFrame.Visible = false
    prestigeFrame.Parent = mainFrame
    
    -- Create level content
    local levelContent = Instance.new("Frame")
    levelContent.Name = "LevelContent"
    levelContent.Size = UDim2.new(0.8, 0, 0.8, 0)
    levelContent.Position = UDim2.new(0.1, 0, 0.1, 0)
    levelContent.BackgroundTransparency = 1
    levelContent.Parent = levelFrame
    
    -- Level display
    local levelDisplay = Instance.new("TextLabel")
    levelDisplay.Name = "LevelDisplay"
    levelDisplay.Size = UDim2.new(1, 0, 0.2, 0)
    levelDisplay.Position = UDim2.new(0, 0, 0, 0)
    levelDisplay.BackgroundTransparency = 1
    levelDisplay.Text = "Level: 1"
    levelDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
    levelDisplay.TextScaled = true
    levelDisplay.Font = Enum.Font.GothamBold
    levelDisplay.Parent = levelContent
    
    -- XP bar
    local xpBar = Instance.new("Frame")
    xpBar.Name = "XPBar"
    xpBar.Size = UDim2.new(1, 0, 0.1, 0)
    xpBar.Position = UDim2.new(0, 0, 0.3, 0)
    xpBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    xpBar.BorderSizePixel = 0
    xpBar.Parent = levelContent
    
    local xpFill = Instance.new("Frame")
    xpFill.Name = "XPFill"
    xpFill.Size = UDim2.new(0, 0, 1, 0)
    xpFill.Position = UDim2.new(0, 0, 0, 0)
    xpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    xpFill.BorderSizePixel = 0
    xpFill.Parent = xpBar
    
    local xpText = Instance.new("TextLabel")
    xpText.Name = "XPText"
    xpText.Size = UDim2.new(1, 0, 1, 0)
    xpText.Position = UDim2.new(0, 0, 0, 0)
    xpText.BackgroundTransparency = 1
    xpText.Text = "0/100 XP"
    xpText.TextColor3 = Color3.fromRGB(255, 255, 255)
    xpText.TextScaled = true
    xpText.Font = Enum.Font.GothamBold
    xpText.Parent = xpBar
    
    -- Create skills content
    local skillsContent = Instance.new("Frame")
    skillsContent.Name = "SkillsContent"
    skillsContent.Size = UDim2.new(0.8, 0, 0.8, 0)
    skillsContent.Position = UDim2.new(0.1, 0, 0.1, 0)
    skillsContent.BackgroundTransparency = 1
    skillsContent.Parent = skillsFrame
    
    -- Skills list
    local skillsList = Instance.new("ScrollingFrame")
    skillsList.Name = "SkillsList"
    skillsList.Size = UDim2.new(1, 0, 1, 0)
    skillsList.Position = UDim2.new(0, 0, 0, 0)
    skillsList.BackgroundTransparency = 1
    skillsList.BorderSizePixel = 0
    skillsList.ScrollBarThickness = 6
    skillsList.CanvasSize = UDim2.new(0, 0, 2, 0)
    skillsList.Parent = skillsContent
    
    -- Create prestige content
    local prestigeContent = Instance.new("Frame")
    prestigeContent.Name = "PrestigeContent"
    prestigeContent.Size = UDim2.new(0.8, 0, 0.8, 0)
    prestigeContent.Position = UDim2.new(0.1, 0, 0.1, 0)
    prestigeContent.BackgroundTransparency = 1
    prestigeContent.Parent = prestigeFrame
    
    -- Prestige level display
    local prestigeLevel = Instance.new("TextLabel")
    prestigeLevel.Name = "PrestigeLevel"
    prestigeLevel.Size = UDim2.new(1, 0, 0.2, 0)
    prestigeLevel.Position = UDim2.new(0, 0, 0, 0)
    prestigeLevel.BackgroundTransparency = 1
    prestigeLevel.Text = "Prestige Level: 0"
    prestigeLevel.TextColor3 = Color3.fromRGB(255, 255, 255)
    prestigeLevel.TextScaled = true
    prestigeLevel.Font = Enum.Font.GothamBold
    prestigeLevel.Parent = prestigeContent
    
    -- Prestige button
    local prestigeButton = Instance.new("TextButton")
    prestigeButton.Name = "PrestigeButton"
    prestigeButton.Size = UDim2.new(0.4, 0, 0.2, 0)
    prestigeButton.Position = UDim2.new(0.3, 0, 0.3, 0)
    prestigeButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    prestigeButton.BorderSizePixel = 0
    prestigeButton.Text = "Prestige"
    prestigeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    prestigeButton.TextScaled = true
    prestigeButton.Font = Enum.Font.GothamBold
    prestigeButton.Parent = prestigeContent
    
    -- Prestige requirements
    local prestigeRequirements = Instance.new("TextLabel")
    prestigeRequirements.Name = "PrestigeRequirements"
    prestigeRequirements.Size = UDim2.new(1, 0, 0.2, 0)
    prestigeRequirements.Position = UDim2.new(0, 0, 0.6, 0)
    prestigeRequirements.BackgroundTransparency = 1
    prestigeRequirements.Text = "Reach level 50 to prestige"
    prestigeRequirements.TextColor3 = Color3.fromRGB(255, 255, 255)
    prestigeRequirements.TextScaled = true
    prestigeRequirements.Font = Enum.Font.GothamBold
    prestigeRequirements.Parent = prestigeContent
    
    -- Set up event handlers
    levelTab.MouseButton1Click:Connect(function()
        ProgressionUI.switchTab("level")
    end)
    
    skillsTab.MouseButton1Click:Connect(function()
        ProgressionUI.switchTab("skills")
    end)
    
    prestigeTab.MouseButton1Click:Connect(function()
        ProgressionUI.switchTab("prestige")
    end)
    
    prestigeButton.MouseButton1Click:Connect(function()
        ProgressionUI.prestige()
    end)
    
    -- Set up keyboard shortcut
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.P then
            ProgressionUI.toggle()
        end
    end)
end

-- Switch between tabs
function ProgressionUI.switchTab(tab)
    currentTab = tab
    
    levelFrame.Visible = (tab == "level")
    skillsFrame.Visible = (tab == "skills")
    prestigeFrame.Visible = (tab == "prestige")
    
    -- Update tab button colors
    for _, button in ipairs(mainFrame.TabButtons:GetChildren()) do
        if button:IsA("TextButton") then
            button.BackgroundColor3 = (button.Name:lower():match(tab) and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(60, 60, 60))
        end
    end
    
    -- Refresh content
    if tab == "level" then
        ProgressionUI.refreshLevel()
    elseif tab == "skills" then
        ProgressionUI.refreshSkills()
    elseif tab == "prestige" then
        ProgressionUI.refreshPrestige()
    end
end

-- Refresh level display
function ProgressionUI.refreshLevel()
    local success, data = getLevelEvent:InvokeServer()
    if not success then return end
    
    -- Update level display
    local levelDisplay = levelFrame.LevelContent.LevelDisplay
    levelDisplay.Text = "Level: " .. data.level
    
    -- Update XP bar
    local xpBar = levelFrame.LevelContent.XPBar
    local xpFill = xpBar.XPFill
    local xpText = xpBar.XPText
    
    local fillAmount = data.xp / data.xpNeeded
    xpFill.Size = UDim2.new(fillAmount, 0, 1, 0)
    xpText.Text = data.xp .. "/" .. data.xpNeeded .. " XP"
end

-- Refresh skills display
function ProgressionUI.refreshSkills()
    local success, data = getSkillsEvent:InvokeServer()
    if not success then return end
    
    -- Clear existing skills
    local skillsList = skillsFrame.SkillsContent.SkillsList
    for _, child in ipairs(skillsList:GetChildren()) do
        child:Destroy()
    end
    
    -- Create skill buttons
    local yOffset = 0
    for treeName, tree in pairs(data) do
        -- Create tree header
        local treeHeader = Instance.new("TextLabel")
        treeHeader.Name = treeName .. "Header"
        treeHeader.Size = UDim2.new(1, 0, 0.1, 0)
        treeHeader.Position = UDim2.new(0, 0, 0, yOffset)
        treeHeader.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        treeHeader.BorderSizePixel = 0
        treeHeader.Text = treeName
        treeHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
        treeHeader.TextScaled = true
        treeHeader.Font = Enum.Font.GothamBold
        treeHeader.Parent = skillsList
        
        yOffset = yOffset + 0.1
        
        -- Create skill buttons
        for skillId, level in pairs(tree) do
            local skillButton = Instance.new("TextButton")
            skillButton.Name = skillId
            skillButton.Size = UDim2.new(0.9, 0, 0.15, 0)
            skillButton.Position = UDim2.new(0.05, 0, 0, yOffset)
            skillButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            skillButton.BorderSizePixel = 0
            skillButton.Text = skillId .. " (Level " .. level .. ")"
            skillButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            skillButton.TextScaled = true
            skillButton.Font = Enum.Font.GothamBold
            skillButton.Parent = skillsList
            
            -- Set up click handler
            skillButton.MouseButton1Click:Connect(function()
                ProgressionUI.upgradeSkill(skillId)
            end)
            
            yOffset = yOffset + 0.15
        end
        
        yOffset = yOffset + 0.05
    end
    
    -- Update canvas size
    skillsList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Refresh prestige display
function ProgressionUI.refreshPrestige()
    local success, data = getPrestigeEvent:InvokeServer()
    if not success then return end
    
    -- Update prestige level display
    local prestigeLevel = prestigeFrame.PrestigeContent.PrestigeLevel
    prestigeLevel.Text = "Prestige Level: " .. data.level
    
    -- Update prestige button and requirements
    local prestigeButton = prestigeFrame.PrestigeContent.PrestigeButton
    local prestigeRequirements = prestigeFrame.PrestigeContent.PrestigeRequirements
    
    -- Get current level
    local levelSuccess, levelData = getLevelEvent:InvokeServer()
    if not levelSuccess then return end
    
    -- Check if player can prestige
    if levelData.level >= 50 then
        prestigeButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
        prestigeButton.Text = "Prestige"
        prestigeRequirements.Text = "Ready to prestige!"
    else
        prestigeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        prestigeButton.Text = "Locked"
        prestigeRequirements.Text = "Reach level 50 to prestige"
    end
end

-- Upgrade skill
function ProgressionUI.upgradeSkill(skillId)
    local success, message = upgradeSkillEvent:InvokeServer(skillId)
    if not success then
        ProgressionUI.showError(message)
        return
    end
    
    -- Refresh skills display
    ProgressionUI.refreshSkills()
end

-- Prestige
function ProgressionUI.prestige()
    local success, message = prestigeEvent:InvokeServer()
    if not success then
        ProgressionUI.showError(message)
        return
    end
    
    -- Refresh all displays
    ProgressionUI.refreshLevel()
    ProgressionUI.refreshSkills()
    ProgressionUI.refreshPrestige()
end

-- Toggle UI visibility
function ProgressionUI.toggle()
    mainFrame.Visible = not mainFrame.Visible
    
    if mainFrame.Visible then
        -- Refresh current tab
        ProgressionUI.switchTab(currentTab)
    end
end

-- Show error message
function ProgressionUI.showError(message)
    -- TODO: Implement error display
    -- This could include:
    -- - Toast notification
    -- - Error dialog
    -- - Sound effect
end

-- Initialize UI
function ProgressionUI.init()
    ProgressionUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.ProgressionUpdate, function(level, currentXP, maxXP)
        ProgressionUI.updateProgression(level, currentXP, maxXP)
    end)
end

return ProgressionUI 