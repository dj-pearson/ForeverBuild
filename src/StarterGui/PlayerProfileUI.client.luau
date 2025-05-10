local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local PlayerProfileUI = {}

-- UI Elements
local screenGui
local mainFrame
local profileFrame
local showcaseFrame
local editButton

-- Remote events
local getProfileEvent = ReplicatedStorage.Remotes.GetPlayerProfile
local updateProfileEvent = ReplicatedStorage.Remotes.UpdatePlayerProfile
local getShowcaseEvent = ReplicatedStorage.Remotes.GetShowcaseArea
local updateShowcaseEvent = ReplicatedStorage.Remotes.UpdateShowcaseArea

-- Current profile
local currentUserId = nil

-- Create UI
function PlayerProfileUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PlayerProfileUI"
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
    title.Text = "Player Profile"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Create profile frame
    profileFrame = Instance.new("Frame")
    profileFrame.Name = "ProfileFrame"
    profileFrame.Size = UDim2.new(0.4, -20, 1, -70)
    profileFrame.Position = UDim2.new(0, 10, 0, 60)
    profileFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    profileFrame.BorderSizePixel = 0
    profileFrame.Parent = mainFrame
    
    -- Create showcase frame
    showcaseFrame = Instance.new("Frame")
    showcaseFrame.Name = "ShowcaseFrame"
    showcaseFrame.Size = UDim2.new(0.6, -20, 1, -70)
    showcaseFrame.Position = UDim2.new(0.4, 10, 0, 60)
    showcaseFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    showcaseFrame.BorderSizePixel = 0
    showcaseFrame.Parent = mainFrame
    
    -- Create edit button
    editButton = Instance.new("TextButton")
    editButton.Name = "EditButton"
    editButton.Size = UDim2.new(0, 100, 0, 30)
    editButton.Position = UDim2.new(1, -110, 0, 10)
    editButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    editButton.BorderSizePixel = 0
    editButton.Text = "Edit Profile"
    editButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    editButton.TextSize = 16
    editButton.Font = Enum.Font.Gotham
    editButton.Parent = mainFrame
    
    -- Set up button events
    editButton.MouseButton1Click:Connect(function()
        if currentUserId == Players.LocalPlayer.UserId then
            PlayerProfileUI.showEditDialog()
        end
    end)
end

-- Show edit dialog
function PlayerProfileUI.showEditDialog()
    local dialog = Instance.new("Frame")
    dialog.Name = "EditDialog"
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
    title.Text = "Edit Profile"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = dialog
    
    -- Bio input
    local bioLabel = Instance.new("TextLabel")
    bioLabel.Name = "BioLabel"
    bioLabel.Size = UDim2.new(1, -20, 0, 30)
    bioLabel.Position = UDim2.new(0, 10, 0, 60)
    bioLabel.BackgroundTransparency = 1
    bioLabel.Text = "Bio:"
    bioLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    bioLabel.TextSize = 18
    bioLabel.Font = Enum.Font.Gotham
    bioLabel.TextXAlignment = Enum.TextXAlignment.Left
    bioLabel.Parent = dialog
    
    local bioInput = Instance.new("TextBox")
    bioInput.Name = "BioInput"
    bioInput.Size = UDim2.new(1, -20, 0, 100)
    bioInput.Position = UDim2.new(0, 10, 0, 90)
    bioInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    bioInput.BorderSizePixel = 0
    bioInput.Text = ""
    bioInput.PlaceholderText = "Enter your bio..."
    bioInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    bioInput.TextSize = 16
    bioInput.Font = Enum.Font.Gotham
    bioInput.MultiLine = true
    bioInput.Parent = dialog
    
    -- Theme selection
    local themeLabel = Instance.new("TextLabel")
    themeLabel.Name = "ThemeLabel"
    themeLabel.Size = UDim2.new(1, -20, 0, 30)
    themeLabel.Position = UDim2.new(0, 10, 0, 200)
    themeLabel.BackgroundTransparency = 1
    themeLabel.Text = "Showcase Theme:"
    themeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    themeLabel.TextSize = 18
    themeLabel.Font = Enum.Font.Gotham
    themeLabel.TextXAlignment = Enum.TextXAlignment.Left
    themeLabel.Parent = dialog
    
    local themeDropdown = Instance.new("TextButton")
    themeDropdown.Name = "ThemeDropdown"
    themeDropdown.Size = UDim2.new(1, -20, 0, 40)
    themeDropdown.Position = UDim2.new(0, 10, 0, 230)
    themeDropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    themeDropdown.BorderSizePixel = 0
    themeDropdown.Text = "Select Theme"
    themeDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    themeDropdown.TextSize = 16
    themeDropdown.Font = Enum.Font.Gotham
    themeDropdown.Parent = dialog
    
    -- Layout selection
    local layoutLabel = Instance.new("TextLabel")
    layoutLabel.Name = "LayoutLabel"
    layoutLabel.Size = UDim2.new(1, -20, 0, 30)
    layoutLabel.Position = UDim2.new(0, 10, 0, 280)
    layoutLabel.BackgroundTransparency = 1
    layoutLabel.Text = "Showcase Layout:"
    layoutLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    layoutLabel.TextSize = 18
    layoutLabel.Font = Enum.Font.Gotham
    layoutLabel.TextXAlignment = Enum.TextXAlignment.Left
    layoutLabel.Parent = dialog
    
    local layoutDropdown = Instance.new("TextButton")
    layoutDropdown.Name = "LayoutDropdown"
    layoutDropdown.Size = UDim2.new(1, -20, 0, 40)
    layoutDropdown.Position = UDim2.new(0, 10, 0, 310)
    layoutDropdown.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    layoutDropdown.BorderSizePixel = 0
    layoutDropdown.Text = "Select Layout"
    layoutDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    layoutDropdown.TextSize = 16
    layoutDropdown.Font = Enum.Font.Gotham
    layoutDropdown.Parent = dialog
    
    -- Save button
    local saveButton = Instance.new("TextButton")
    saveButton.Name = "SaveButton"
    saveButton.Size = UDim2.new(0, 150, 0, 40)
    saveButton.Position = UDim2.new(0.5, -75, 1, -50)
    saveButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    saveButton.BorderSizePixel = 0
    saveButton.Text = "Save"
    saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveButton.TextSize = 18
    saveButton.Font = Enum.Font.Gotham
    saveButton.Parent = dialog
    
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
    
    -- Set up theme dropdown
    local selectedTheme = nil
    themeDropdown.MouseButton1Click:Connect(function()
        local menu = Instance.new("Frame")
        menu.Name = "ThemeMenu"
        menu.Size = UDim2.new(1, 0, 0, 120)
        menu.Position = UDim2.new(0, 0, 1, 0)
        menu.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        menu.BorderSizePixel = 0
        menu.Parent = themeDropdown
        
        local themes = {
            "default",
            "dark",
            "light",
            "colorful",
            "minimal"
        }
        
        for i, theme in ipairs(themes) do
            local button = Instance.new("TextButton")
            button.Name = theme
            button.Size = UDim2.new(1, 0, 0, 40)
            button.Position = UDim2.new(0, 0, 0, (i-1) * 40)
            button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            button.BorderSizePixel = 0
            button.Text = theme
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.TextSize = 16
            button.Font = Enum.Font.Gotham
            button.Parent = menu
            
            button.MouseButton1Click:Connect(function()
                selectedTheme = theme
                themeDropdown.Text = theme
                menu:Destroy()
            end)
        end
    end)
    
    -- Set up layout dropdown
    local selectedLayout = nil
    layoutDropdown.MouseButton1Click:Connect(function()
        local menu = Instance.new("Frame")
        menu.Name = "LayoutMenu"
        menu.Size = UDim2.new(1, 0, 0, 120)
        menu.Position = UDim2.new(0, 0, 1, 0)
        menu.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        menu.BorderSizePixel = 0
        menu.Parent = layoutDropdown
        
        local layouts = {
            "default",
            "grid",
            "list",
            "carousel",
            "masonry"
        }
        
        for i, layout in ipairs(layouts) do
            local button = Instance.new("TextButton")
            button.Name = layout
            button.Size = UDim2.new(1, 0, 0, 40)
            button.Position = UDim2.new(0, 0, 0, (i-1) * 40)
            button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
            button.BorderSizePixel = 0
            button.Text = layout
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.TextSize = 16
            button.Font = Enum.Font.Gotham
            button.Parent = menu
            
            button.MouseButton1Click:Connect(function()
                selectedLayout = layout
                layoutDropdown.Text = layout
                menu:Destroy()
            end)
        end
    end)
    
    -- Set up save button
    saveButton.MouseButton1Click:Connect(function()
        local profileData = {
            bio = bioInput.Text
        }
        
        local showcaseData = {
            theme = selectedTheme,
            layout = selectedLayout
        }
        
        local success = updateProfileEvent:InvokeServer(profileData)
        if success then
            success = updateShowcaseEvent:InvokeServer(showcaseData)
            if success then
                dialog:Destroy()
                PlayerProfileUI.refreshProfile()
            end
        end
    end)
    
    -- Set up close button
    closeButton.MouseButton1Click:Connect(function()
        dialog:Destroy()
    end)
end

-- Update profile display
function PlayerProfileUI.updateProfile(profile)
    -- Clear existing profile
    for _, child in ipairs(profileFrame:GetChildren()) do
        child:Destroy()
    end
    
    -- Username
    local username = Instance.new("TextLabel")
    username.Name = "Username"
    username.Size = UDim2.new(1, -20, 0, 40)
    username.Position = UDim2.new(0, 10, 0, 10)
    username.BackgroundTransparency = 1
    username.Text = profile.username
    username.TextColor3 = Color3.fromRGB(255, 255, 255)
    username.TextSize = 24
    username.Font = Enum.Font.GothamBold
    username.TextXAlignment = Enum.TextXAlignment.Left
    username.Parent = profileFrame
    
    -- Bio
    local bio = Instance.new("TextLabel")
    bio.Name = "Bio"
    bio.Size = UDim2.new(1, -20, 0, 60)
    bio.Position = UDim2.new(0, 10, 0, 60)
    bio.BackgroundTransparency = 1
    bio.Text = profile.bio
    bio.TextColor3 = Color3.fromRGB(200, 200, 200)
    bio.TextSize = 16
    bio.Font = Enum.Font.Gotham
    bio.TextXAlignment = Enum.TextXAlignment.Left
    bio.TextWrapped = true
    bio.Parent = profileFrame
    
    -- Stats
    local stats = Instance.new("TextLabel")
    stats.Name = "Stats"
    stats.Size = UDim2.new(1, -20, 0, 30)
    stats.Position = UDim2.new(0, 10, 0, 130)
    stats.BackgroundTransparency = 1
    stats.Text = "Stats"
    stats.TextColor3 = Color3.fromRGB(255, 255, 255)
    stats.TextSize = 18
    stats.Font = Enum.Font.GothamBold
    stats.TextXAlignment = Enum.TextXAlignment.Left
    stats.Parent = profileFrame
    
    local y = 170
    for stat, value in pairs(profile.stats) do
        local statLabel = Instance.new("TextLabel")
        statLabel.Name = stat
        statLabel.Size = UDim2.new(1, -20, 0, 20)
        statLabel.Position = UDim2.new(0, 10, 0, y)
        statLabel.BackgroundTransparency = 1
        statLabel.Text = stat .. ": " .. value
        statLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        statLabel.TextSize = 14
        statLabel.Font = Enum.Font.Gotham
        statLabel.TextXAlignment = Enum.TextXAlignment.Left
        statLabel.Parent = profileFrame
        y = y + 25
    end
    
    -- Achievements
    local achievements = Instance.new("TextLabel")
    achievements.Name = "Achievements"
    achievements.Size = UDim2.new(1, -20, 0, 30)
    achievements.Position = UDim2.new(0, 10, 0, y + 10)
    achievements.BackgroundTransparency = 1
    achievements.Text = "Achievements"
    achievements.TextColor3 = Color3.fromRGB(255, 255, 255)
    achievements.TextSize = 18
    achievements.Font = Enum.Font.GothamBold
    achievements.TextXAlignment = Enum.TextXAlignment.Left
    achievements.Parent = profileFrame
    
    y = y + 50
    for _, achievement in ipairs(profile.achievements) do
        local achievementLabel = Instance.new("TextLabel")
        achievementLabel.Name = achievement.id
        achievementLabel.Size = UDim2.new(1, -20, 0, 40)
        achievementLabel.Position = UDim2.new(0, 10, 0, y)
        achievementLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        achievementLabel.BorderSizePixel = 0
        achievementLabel.Text = achievement.name .. "\n" .. achievement.description
        achievementLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        achievementLabel.TextSize = 14
        achievementLabel.Font = Enum.Font.Gotham
        achievementLabel.TextXAlignment = Enum.TextXAlignment.Left
        achievementLabel.TextWrapped = true
        achievementLabel.Parent = profileFrame
        y = y + 45
    end
end

-- Update showcase display
function PlayerProfileUI.updateShowcase(showcase)
    -- Clear existing showcase
    for _, child in ipairs(showcaseFrame:GetChildren()) do
        child:Destroy()
    end
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -20, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Showcase Area"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = showcaseFrame
    
    -- Objects grid
    local grid = Instance.new("Frame")
    grid.Name = "ObjectsGrid"
    grid.Size = UDim2.new(1, -20, 1, -50)
    grid.Position = UDim2.new(0, 10, 0, 50)
    grid.BackgroundTransparency = 1
    grid.Parent = showcaseFrame
    
    -- Add objects
    local x, y = 0, 0
    local cellSize = 150
    local padding = 10
    local columns = math.floor((grid.AbsoluteSize.X + padding) / (cellSize + padding))
    
    for i, objectId in ipairs(showcase.objects) do
        local objectFrame = Instance.new("Frame")
        objectFrame.Name = "Object" .. objectId
        objectFrame.Size = UDim2.new(0, cellSize, 0, cellSize)
        objectFrame.Position = UDim2.new(0, x * (cellSize + padding), 0, y * (cellSize + padding))
        objectFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        objectFrame.BorderSizePixel = 0
        objectFrame.Parent = grid
        
        -- Object preview
        local preview = Instance.new("ImageLabel")
        preview.Name = "Preview"
        preview.Size = UDim2.new(1, -20, 1, -20)
        preview.Position = UDim2.new(0, 10, 0, 10)
        preview.BackgroundTransparency = 1
        preview.Image = "rbxassetid://" .. objectId -- TODO: Get actual preview image
        preview.Parent = objectFrame
        
        -- Remove button (if owner)
        if currentUserId == Players.LocalPlayer.UserId then
            local removeButton = Instance.new("TextButton")
            removeButton.Name = "RemoveButton"
            removeButton.Size = UDim2.new(0, 30, 0, 30)
            removeButton.Position = UDim2.new(1, -35, 0, 5)
            removeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            removeButton.BorderSizePixel = 0
            removeButton.Text = "X"
            removeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            removeButton.TextSize = 16
            removeButton.Font = Enum.Font.GothamBold
            removeButton.Parent = objectFrame
            
            removeButton.MouseButton1Click:Connect(function()
                local success = updateShowcaseEvent:InvokeServer({
                    objects = showcase.objects,
                    removeObject = objectId
                })
                if success then
                    PlayerProfileUI.refreshShowcase()
                end
            end)
        end
        
        x = x + 1
        if x >= columns then
            x = 0
            y = y + 1
        end
    end
end

-- Refresh profile
function PlayerProfileUI.refreshProfile()
    if not currentUserId then return end
    
    local profile = getProfileEvent:InvokeServer(currentUserId)
    if profile then
        PlayerProfileUI.updateProfile(profile)
    end
end

-- Refresh showcase
function PlayerProfileUI.refreshShowcase()
    if not currentUserId then return end
    
    local showcase = getShowcaseEvent:InvokeServer(currentUserId)
    if showcase then
        PlayerProfileUI.updateShowcase(showcase)
    end
end

-- Show UI for player
function PlayerProfileUI.showForPlayer(userId)
    currentUserId = userId
    mainFrame.Visible = true
    editButton.Visible = userId == Players.LocalPlayer.UserId
    PlayerProfileUI.refreshProfile()
    PlayerProfileUI.refreshShowcase()
end

-- Hide UI
function PlayerProfileUI.hide()
    currentUserId = nil
    mainFrame.Visible = false
end

-- Initialize
function PlayerProfileUI.init()
    PlayerProfileUI.create()
end

return PlayerProfileUI 