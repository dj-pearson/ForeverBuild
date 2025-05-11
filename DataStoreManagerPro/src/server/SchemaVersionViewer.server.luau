--luau
-- DataStore Plugin/SchemaVersionViewer.luau
-- Module for viewing schema version history

local SchemaVersioning = require(script.Parent.SchemaVersioning)

local SchemaVersionViewer = {}

-- Create UI for viewing schema version history
function SchemaVersionViewer.createVersionHistoryUI(parent, dataStoreName, keyName)
    -- Main container for version history
    local container = Instance.new("Frame")
    container.Name = "VersionHistoryContainer"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    container.BorderSizePixel = 0
    container.Parent = parent
    
    -- Header
    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "Header"
    headerFrame.Size = UDim2.new(1, 0, 0, 40)
    headerFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    headerFrame.BorderSizePixel = 0
    headerFrame.Parent = container
    
    local headerText = Instance.new("TextLabel")
    headerText.Size = UDim2.new(1, -20, 1, 0)
    headerText.Position = UDim2.new(0, 10, 0, 0)
    headerText.BackgroundTransparency = 1
    headerText.Text = "Schema Version History - " .. dataStoreName .. " / " .. keyName
    headerText.TextColor3 = Color3.fromRGB(255, 255, 255)
    headerText.Font = Enum.Font.SourceSansBold
    headerText.TextSize = 16
    headerText.TextXAlignment = Enum.TextXAlignment.Left
    headerText.Parent = headerFrame
    
    -- Back button
    local backButton = Instance.new("TextButton")
    backButton.Size = UDim2.new(0, 100, 0, 30)
    backButton.Position = UDim2.new(0, 10, 0, 50)
    backButton.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    backButton.BorderSizePixel = 0
    backButton.Text = "Back"
    backButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    backButton.Font = Enum.Font.SourceSansSemibold
    backButton.TextSize = 14
    backButton.Parent = container
    
    -- Rounded corners for back button
    local backButtonCorner = Instance.new("UICorner")
    backButtonCorner.CornerRadius = UDim.new(0, 4)
    backButtonCorner.Parent = backButton
    
    -- Connect back button
    backButton.MouseButton1Click:Connect(function()
        container:Destroy()
    end)
    
    -- Versions list scroll frame
    local versionsScroll = Instance.new("ScrollingFrame")
    versionsScroll.Name = "VersionsScroll"
    versionsScroll.Size = UDim2.new(1, -20, 1, -90)
    versionsScroll.Position = UDim2.new(0, 10, 0, 90)
    versionsScroll.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    versionsScroll.BorderColor3 = Color3.fromRGB(80, 80, 90)
    versionsScroll.BorderSizePixel = 1
    versionsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    versionsScroll.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
    versionsScroll.ScrollBarThickness = 6
    versionsScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    versionsScroll.Parent = container
    
    -- Layout for versions
    local versionsLayout = Instance.new("UIListLayout")
    versionsLayout.Padding = UDim.new(0, 5)
    versionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    versionsLayout.Parent = versionsScroll
    
    -- Get all versions
    local versions = SchemaVersioning.getVersions(dataStoreName, keyName)
    
    -- Sort versions by timestamp (newest first)
    table.sort(versions, function(a, b)
        return (a.timestamp or 0) > (b.timestamp or 0)
    end)
    
    -- Create entry for each version
    for i, version in ipairs(versions) do
        local versionFrame = Instance.new("Frame")
        versionFrame.Size = UDim2.new(1, -10, 0, 80)
        versionFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        versionFrame.BorderColor3 = Color3.fromRGB(70, 70, 80)
        versionFrame.BorderSizePixel = 1
        versionFrame.LayoutOrder = i
        versionFrame.Parent = versionsScroll
        
        -- Version number and date
        local versionHeader = Instance.new("TextLabel")
        versionHeader.Size = UDim2.new(1, -20, 0, 25)
        versionHeader.Position = UDim2.new(0, 10, 0, 5)
        versionHeader.BackgroundTransparency = 1
        versionHeader.Text = "Version " .. i .. " - " .. os.date("%Y-%m-%d %H:%M:%S", version.timestamp or 0)
        versionHeader.TextColor3 = Color3.fromRGB(220, 220, 255)
        versionHeader.Font = Enum.Font.SourceSansSemibold
        versionHeader.TextSize = 14
        versionHeader.TextXAlignment = Enum.TextXAlignment.Left
        versionHeader.Parent = versionFrame
        
        -- Version description
        local description = Instance.new("TextLabel")
        description.Size = UDim2.new(1, -20, 0, 40)
        description.Position = UDim2.new(0, 10, 0, 30)
        description.BackgroundTransparency = 1
        description.Text = version.description or "No description"
        description.TextColor3 = Color3.fromRGB(200, 200, 200)
        description.Font = Enum.Font.SourceSans
        description.TextSize = 14
        description.TextWrapped = true
        description.TextXAlignment = Enum.TextXAlignment.Left
        description.Parent = versionFrame
        
        -- Restore button
        local restoreButton = Instance.new("TextButton")
        restoreButton.Size = UDim2.new(0, 100, 0, 24)
        restoreButton.Position = UDim2.new(1, -110, 0, 5)
        restoreButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
        restoreButton.BorderSizePixel = 0
        restoreButton.Text = "Restore"
        restoreButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        restoreButton.Font = Enum.Font.SourceSans
        restoreButton.TextSize = 14
        restoreButton.Parent = versionFrame
        
        -- Connect restore button
        restoreButton.MouseButton1Click:Connect(function()
            local versionData = SchemaVersioning.getVersion(dataStoreName, keyName, version.id)
            if versionData and versionData.schema then
                -- Restore this version as the current schema
                require(script.Parent.SchemaManager.server).saveSchema(versionData.schema, dataStoreName, keyName)
                
                -- Refresh the view
                container:Destroy()
                SchemaVersionViewer.createVersionHistoryUI(parent, dataStoreName, keyName)
            end
        end)
    end
    
    return container
end

return SchemaVersionViewer
