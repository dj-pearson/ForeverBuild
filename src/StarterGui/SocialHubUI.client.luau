local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local SocialHubUI = {}

-- UI Elements
local screenGui
local mainFrame
local hubList
local createHubButton
local hubDetailsFrame
local settingsFrame

-- Remote events
local createHubEvent = ReplicatedStorage.Remotes.CreateHub
local joinHubEvent = ReplicatedStorage.Remotes.JoinHub
local leaveHubEvent = ReplicatedStorage.Remotes.LeaveHub
local updateHubSettingsEvent = ReplicatedStorage.Remotes.UpdateHubSettings
local getHubInfoEvent = ReplicatedStorage.Remotes.GetHubInfo
local hubUpdateEvent = ReplicatedStorage.Remotes.HubUpdate

-- Create UI
function SocialHubUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SocialHubUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 800, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Create title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    title.BorderSizePixel = 0
    title.Text = "Social Hubs"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Create hub list
    hubList = Instance.new("ScrollingFrame")
    hubList.Name = "HubList"
    hubList.Size = UDim2.new(0.4, -20, 1, -70)
    hubList.Position = UDim2.new(0, 10, 0, 60)
    hubList.BackgroundTransparency = 1
    hubList.BorderSizePixel = 0
    hubList.ScrollBarThickness = 6
    hubList.Parent = mainFrame
    
    -- Create hub details frame
    hubDetailsFrame = Instance.new("Frame")
    hubDetailsFrame.Name = "HubDetails"
    hubDetailsFrame.Size = UDim2.new(0.6, -20, 1, -70)
    hubDetailsFrame.Position = UDim2.new(0.4, 10, 0, 60)
    hubDetailsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    hubDetailsFrame.BorderSizePixel = 0
    hubDetailsFrame.Parent = mainFrame
    
    -- Create create hub button
    createHubButton = Instance.new("TextButton")
    createHubButton.Name = "CreateHubButton"
    createHubButton.Size = UDim2.new(0, 150, 0, 40)
    createHubButton.Position = UDim2.new(0.5, -75, 1, -50)
    createHubButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    createHubButton.BorderSizePixel = 0
    createHubButton.Text = "Create Hub"
    createHubButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    createHubButton.TextSize = 18
    createHubButton.Font = Enum.Font.Gotham
    createHubButton.Parent = mainFrame
    
    -- Set up button events
    createHubButton.MouseButton1Click:Connect(function()
        SocialHubUI.showCreateHubDialog()
    end)
end

-- Show create hub dialog
function SocialHubUI.showCreateHubDialog()
    local dialog = Instance.new("Frame")
    dialog.Name = "CreateHubDialog"
    dialog.Size = UDim2.new(0, 400, 0, 500)
    dialog.Position = UDim2.new(0.5, -200, 0.5, -250)
    dialog.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    dialog.BorderSizePixel = 0
    dialog.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    title.BorderSizePixel = 0
    title.Text = "Create Social Hub"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = dialog
    
    -- Hub type selection
    local typeLabel = Instance.new("TextLabel")
    typeLabel.Name = "TypeLabel"
    typeLabel.Size = UDim2.new(1, -20, 0, 30)
    typeLabel.Position = UDim2.new(0, 10, 0, 60)
    typeLabel.BackgroundTransparency = 1
    typeLabel.Text = "Hub Type:"
    typeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    typeLabel.TextSize = 18
    typeLabel.Font = Enum.Font.Gotham
    typeLabel.TextXAlignment = Enum.TextXAlignment.Left
    typeLabel.Parent = dialog
    
    local typeDropdown = Instance.new("TextButton")
    typeDropdown.Name = "TypeDropdown"
    typeDropdown.Size = UDim2.new(1, -20, 0, 40)
    typeDropdown.Position = UDim2.new(0, 10, 0, 90)
    typeDropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    typeDropdown.BorderSizePixel = 0
    typeDropdown.Text = "Select Type"
    typeDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    typeDropdown.TextSize = 16
    typeDropdown.Font = Enum.Font.Gotham
    typeDropdown.Parent = dialog
    
    -- Name input
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, -20, 0, 30)
    nameLabel.Position = UDim2.new(0, 10, 0, 140)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Hub Name:"
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 18
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = dialog
    
    local nameInput = Instance.new("TextBox")
    nameInput.Name = "NameInput"
    nameInput.Size = UDim2.new(1, -20, 0, 40)
    nameInput.Position = UDim2.new(0, 10, 0, 170)
    nameInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    nameInput.BorderSizePixel = 0
    nameInput.Text = ""
    nameInput.PlaceholderText = "Enter hub name"
    nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameInput.TextSize = 16
    nameInput.Font = Enum.Font.Gotham
    nameInput.Parent = dialog
    
    -- Description input
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "DescLabel"
    descLabel.Size = UDim2.new(1, -20, 0, 30)
    descLabel.Position = UDim2.new(0, 10, 0, 220)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = "Description:"
    descLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    descLabel.TextSize = 18
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = dialog
    
    local descInput = Instance.new("TextBox")
    descInput.Name = "DescInput"
    descInput.Size = UDim2.new(1, -20, 0, 80)
    descInput.Position = UDim2.new(0, 10, 0, 250)
    descInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    descInput.BorderSizePixel = 0
    descInput.Text = ""
    descInput.PlaceholderText = "Enter hub description"
    descInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    descInput.TextSize = 16
    descInput.Font = Enum.Font.Gotham
    descInput.MultiLine = true
    descInput.Parent = dialog
    
    -- Create button
    local createButton = Instance.new("TextButton")
    createButton.Name = "CreateButton"
    createButton.Size = UDim2.new(0, 150, 0, 40)
    createButton.Position = UDim2.new(0.5, -75, 1, -50)
    createButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    createButton.BorderSizePixel = 0
    createButton.Text = "Create"
    createButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    createButton.TextSize = 18
    createButton.Font = Enum.Font.Gotham
    createButton.Parent = dialog
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = dialog
    
    -- Set up type dropdown
    local selectedType = nil
    typeDropdown.MouseButton1Click:Connect(function()
        local menu = Instance.new("Frame")
        menu.Name = "TypeMenu"
        menu.Size = UDim2.new(1, 0, 0, 120)
        menu.Position = UDim2.new(0, 0, 1, 0)
        menu.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        menu.BorderSizePixel = 0
        menu.Parent = typeDropdown
        
        local types = {
            {name = "Gathering Space", type = "GATHERING"},
            {name = "Event Venue", type = "EVENT"},
            {name = "Trading Zone", type = "TRADING"}
        }
        
        for i, typeInfo in ipairs(types) do
            local button = Instance.new("TextButton")
            button.Name = typeInfo.type
            button.Size = UDim2.new(1, 0, 0, 40)
            button.Position = UDim2.new(0, 0, 0, (i-1) * 40)
            button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            button.BorderSizePixel = 0
            button.Text = typeInfo.name
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.TextSize = 16
            button.Font = Enum.Font.Gotham
            button.Parent = menu
            
            button.MouseButton1Click:Connect(function()
                selectedType = typeInfo.type
                typeDropdown.Text = typeInfo.name
                menu:Destroy()
            end)
        end
    end)
    
    -- Set up create button
    createButton.MouseButton1Click:Connect(function()
        if not selectedType then return end
        if nameInput.Text == "" then return end
        
        local success, hubId = createHubEvent:InvokeServer(
            selectedType,
            nameInput.Text,
            descInput.Text
        )
        
        if success then
            dialog:Destroy()
            SocialHubUI.refreshHubList()
        end
    end)
    
    -- Set up close button
    closeButton.MouseButton1Click:Connect(function()
        dialog:Destroy()
    end)
end

-- Update hub list
function SocialHubUI.updateHubList(hubs)
    -- Clear existing hubs
    for _, child in ipairs(hubList:GetChildren()) do
        child:Destroy()
    end
    
    -- Add hubs
    for i, hub in ipairs(hubs) do
        local entry = Instance.new("Frame")
        entry.Name = "Hub" .. hub.id
        entry.Size = UDim2.new(1, 0, 0, 80)
        entry.Position = UDim2.new(0, 0, 0, (i-1) * 85)
        entry.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(45, 45, 45)
        entry.BorderSizePixel = 0
        entry.Parent = hubList
        
        -- Name
        local name = Instance.new("TextLabel")
        name.Name = "Name"
        name.Size = UDim2.new(1, -10, 0, 30)
        name.Position = UDim2.new(0, 5, 0, 5)
        name.BackgroundTransparency = 1
        name.Text = hub.name
        name.TextColor3 = Color3.fromRGB(255, 255, 255)
        name.TextSize = 18
        name.Font = Enum.Font.GothamBold
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = entry
        
        -- Type
        local type = Instance.new("TextLabel")
        type.Name = "Type"
        type.Size = UDim2.new(1, -10, 0, 20)
        type.Position = UDim2.new(0, 5, 0, 35)
        type.BackgroundTransparency = 1
        type.Text = hub.type
        type.TextColor3 = Color3.fromRGB(200, 200, 200)
        type.TextSize = 14
        type.Font = Enum.Font.Gotham
        type.TextXAlignment = Enum.TextXAlignment.Left
        type.Parent = entry
        
        -- Player count
        local count = Instance.new("TextLabel")
        count.Name = "Count"
        count.Size = UDim2.new(1, -10, 0, 20)
        count.Position = UDim2.new(0, 5, 0, 55)
        count.BackgroundTransparency = 1
        count.Text = hub.playerCount .. "/" .. hub.maxPlayers .. " players"
        count.TextColor3 = Color3.fromRGB(200, 200, 200)
        count.TextSize = 14
        count.Font = Enum.Font.Gotham
        count.TextXAlignment = Enum.TextXAlignment.Left
        count.Parent = entry
        
        -- Join button
        local joinButton = Instance.new("TextButton")
        joinButton.Name = "JoinButton"
        joinButton.Size = UDim2.new(0, 80, 0, 30)
        joinButton.Position = UDim2.new(1, -85, 0.5, -15)
        joinButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        joinButton.BorderSizePixel = 0
        joinButton.Text = "Join"
        joinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        joinButton.TextSize = 16
        joinButton.Font = Enum.Font.Gotham
        joinButton.Parent = entry
        
        joinButton.MouseButton1Click:Connect(function()
            local success = joinHubEvent:InvokeServer(hub.id)
            if success then
                SocialHubUI.refreshHubList()
            end
        end)
    end
end

-- Update hub details
function SocialHubUI.updateHubDetails(hub)
    -- Clear existing details
    for _, child in ipairs(hubDetailsFrame:GetChildren()) do
        child:Destroy()
    end
    
    if not hub then return end
    
    -- Name
    local name = Instance.new("TextLabel")
    name.Name = "Name"
    name.Size = UDim2.new(1, -20, 0, 40)
    name.Position = UDim2.new(0, 10, 0, 10)
    name.BackgroundTransparency = 1
    name.Text = hub.name
    name.TextColor3 = Color3.fromRGB(255, 255, 255)
    name.TextSize = 24
    name.Font = Enum.Font.GothamBold
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = hubDetailsFrame
    
    -- Type
    local type = Instance.new("TextLabel")
    type.Name = "Type"
    type.Size = UDim2.new(1, -20, 0, 30)
    type.Position = UDim2.new(0, 10, 0, 50)
    type.BackgroundTransparency = 1
    type.Text = "Type: " .. hub.type
    type.TextColor3 = Color3.fromRGB(200, 200, 200)
    type.TextSize = 18
    type.Font = Enum.Font.Gotham
    type.TextXAlignment = Enum.TextXAlignment.Left
    type.Parent = hubDetailsFrame
    
    -- Description
    local desc = Instance.new("TextLabel")
    desc.Name = "Description"
    desc.Size = UDim2.new(1, -20, 0, 60)
    desc.Position = UDim2.new(0, 10, 0, 80)
    desc.BackgroundTransparency = 1
    desc.Text = hub.description
    desc.TextColor3 = Color3.fromRGB(200, 200, 200)
    desc.TextSize = 16
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextWrapped = true
    desc.Parent = hubDetailsFrame
    
    -- Player count
    local count = Instance.new("TextLabel")
    count.Name = "Count"
    count.Size = UDim2.new(1, -20, 0, 30)
    count.Position = UDim2.new(0, 10, 0, 140)
    count.BackgroundTransparency = 1
    count.Text = "Players: " .. hub.playerCount .. "/" .. hub.maxPlayers
    count.TextColor3 = Color3.fromRGB(200, 200, 200)
    count.TextSize = 18
    count.Font = Enum.Font.Gotham
    count.TextXAlignment = Enum.TextXAlignment.Left
    count.Parent = hubDetailsFrame
    
    -- Settings
    local settings = Instance.new("TextLabel")
    settings.Name = "Settings"
    settings.Size = UDim2.new(1, -20, 0, 30)
    settings.Position = UDim2.new(0, 10, 0, 170)
    settings.BackgroundTransparency = 1
    settings.Text = "Settings:"
    settings.TextColor3 = Color3.fromRGB(255, 255, 255)
    settings.TextSize = 18
    settings.Font = Enum.Font.GothamBold
    settings.TextXAlignment = Enum.TextXAlignment.Left
    settings.Parent = hubDetailsFrame
    
    -- Settings list
    local y = 200
    for setting, value in pairs(hub.settings) do
        local settingLabel = Instance.new("TextLabel")
        settingLabel.Name = setting
        settingLabel.Size = UDim2.new(1, -20, 0, 25)
        settingLabel.Position = UDim2.new(0, 10, 0, y)
        settingLabel.BackgroundTransparency = 1
        settingLabel.Text = setting .. ": " .. (value and "Yes" or "No")
        settingLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        settingLabel.TextSize = 16
        settingLabel.Font = Enum.Font.Gotham
        settingLabel.TextXAlignment = Enum.TextXAlignment.Left
        settingLabel.Parent = hubDetailsFrame
        y = y + 25
    end
    
    -- Leave button
    local leaveButton = Instance.new("TextButton")
    leaveButton.Name = "LeaveButton"
    leaveButton.Size = UDim2.new(0, 150, 0, 40)
    leaveButton.Position = UDim2.new(0.5, -75, 1, -50)
    leaveButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    leaveButton.BorderSizePixel = 0
    leaveButton.Text = "Leave Hub"
    leaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    leaveButton.TextSize = 18
    leaveButton.Font = Enum.Font.Gotham
    leaveButton.Parent = hubDetailsFrame
    
    leaveButton.MouseButton1Click:Connect(function()
        leaveHubEvent:FireServer()
        SocialHubUI.refreshHubList()
    end)
end

-- Refresh hub list
function SocialHubUI.refreshHubList()
    local hubs = getHubInfoEvent:InvokeServer()
    if hubs then
        SocialHubUI.updateHubList(hubs)
    end
end

-- Show UI
function SocialHubUI.show()
    mainFrame.Visible = true
    SocialHubUI.refreshHubList()
end

-- Hide UI
function SocialHubUI.hide()
    mainFrame.Visible = false
end

-- Initialize
function SocialHubUI.init()
    SocialHubUI.create()
    
    -- Set up event handlers
    hubUpdateEvent.OnClientEvent:Connect(function(hub)
        SocialHubUI.updateHubDetails(hub)
    end)
end

return SocialHubUI 