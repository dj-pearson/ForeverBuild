--[[
    APIIntegrationUI.luau
    Part of DataStore Manager Pro
    
    This module provides the user interface for configuring and managing
    API integrations, webhooks, and third-party analytics.
]]

local APIIntegration = require(script.Parent.APIIntegration)

local APIIntegrationUI = {}

-- Initialize the UI for the API integration
function APIIntegrationUI.initialize()
    print("APIIntegrationUI: Initializing module...")
    
    -- Make sure the APIIntegration module is initialized
    APIIntegration.initialize()
    
    return true
end

-- Create UI for the API integration panel
function APIIntegrationUI.createUI(container)
    if not container then
        warn("APIIntegrationUI: No container provided for the UI")
        return
    end
    
    print("APIIntegrationUI: Creating UI...")
    
    -- Clear existing UI
    for _, child in ipairs(container:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
    
    -- Add layout if not present
    if not container:FindFirstChildOfClass("UIListLayout") then
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 10)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = container
    end
    
    -- Add padding if not present
    if not container:FindFirstChildOfClass("UIPadding") then
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 10)
        padding.PaddingRight = UDim.new(0, 10)
        padding.PaddingTop = UDim.new(0, 10)
        padding.PaddingBottom = UDim.new(0, 10)
        padding.Parent = container
    end
    
    -- Title section
    local titleSection = Instance.new("Frame")
    titleSection.Size = UDim2.new(1, 0, 0, 40)
    titleSection.BackgroundTransparency = 1
    titleSection.Name = "TitleSection"
    titleSection.LayoutOrder = 1
    titleSection.Parent = container
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "API Integration"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 24
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleSection
    
    -- Create tab buttons
    local tabButtonsFrame = Instance.new("Frame")
    tabButtonsFrame.Size = UDim2.new(1, 0, 0, 40)
    tabButtonsFrame.BackgroundTransparency = 1
    tabButtonsFrame.Name = "TabButtonsFrame"
    tabButtonsFrame.LayoutOrder = 2
    tabButtonsFrame.Parent = container
    
    -- Add button layout
    local buttonLayout = Instance.new("UIListLayout")
    buttonLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonLayout.Padding = UDim.new(0, 10)
    buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    buttonLayout.Parent = tabButtonsFrame
    
    -- Tab content container
    local tabContent = Instance.new("Frame")
    tabContent.Size = UDim2.new(1, 0, 1, -90) -- Adjust for title and tabs height
    tabContent.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tabContent.BorderSizePixel = 0
    tabContent.Name = "TabContent"
    tabContent.LayoutOrder = 3
    tabContent.Parent = container
    
    -- Add rounded corners to tab content
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 8)
    contentCorner.Parent = tabContent
    
    -- Tab pages
    local openCloudAPIPage = APIIntegrationUI.createOpenCloudAPIPage()
    openCloudAPIPage.Name = "OpenCloudAPIPage"
    openCloudAPIPage.Parent = tabContent
    openCloudAPIPage.Visible = true -- Default visible tab
    
    local webhooksPage = APIIntegrationUI.createWebhooksPage()
    webhooksPage.Name = "WebhooksPage"
    webhooksPage.Parent = tabContent
    webhooksPage.Visible = false
    
    local analyticsPage = APIIntegrationUI.createAnalyticsPage()
    analyticsPage.Name = "AnalyticsPage"
    analyticsPage.Parent = tabContent
    analyticsPage.Visible = false
    
    local pluginExtensionsPage = APIIntegrationUI.createPluginExtensionsPage()
    pluginExtensionsPage.Name = "PluginExtensionsPage"
    pluginExtensionsPage.Parent = tabContent
    pluginExtensionsPage.Visible = false
    
    -- Create tab buttons
    local tabNames = {
        "Open Cloud API",
        "Webhooks",
        "Analytics",
        "Plugin Extensions"
    }
    
    local tabPages = {
        openCloudAPIPage,
        webhooksPage,
        analyticsPage,
        pluginExtensionsPage
    }
    
    local activeTab = 1 -- Track the active tab
    
    -- Create buttons for each tab
    for i, tabName in ipairs(tabNames) do
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(0.25, -8, 1, 0)
        tabButton.BackgroundColor3 = i == activeTab and Color3.fromRGB(60, 120, 190) or Color3.fromRGB(60, 60, 60)
        tabButton.BorderSizePixel = 0
        tabButton.Text = tabName
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.TextSize = 14
        tabButton.Font = Enum.Font.SourceSansSemibold
        tabButton.Name = tabName .. "Button"
        tabButton.LayoutOrder = i
        tabButton.Parent = tabButtonsFrame
        
        -- Add rounded corners to button
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = tabButton
        
        -- Set up click handler
        tabButton.MouseButton1Click:Connect(function()
            -- Hide all pages
            for j, page in ipairs(tabPages) do
                page.Visible = (i == j)
                
                -- Update button colors
                local btn = tabButtonsFrame:FindFirstChild(tabNames[j] .. "Button")
                if btn then
                    btn.BackgroundColor3 = (i == j) and Color3.fromRGB(60, 120, 190) or Color3.fromRGB(60, 60, 60)
                end
            end
            
            -- Update active tab
            activeTab = i
        end)
    end
    
    return container
end

-- Create the Open Cloud API configuration page
function APIIntegrationUI.createOpenCloudAPIPage()
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -20, 1, -20) -- Add padding
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 6
    page.CanvasSize = UDim2.new(0, 0, 0, 500) -- Will adjust based on content
    page.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    
    -- Add layout
    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 15)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Parent = page
    
    -- Description section
    local descriptionFrame = Instance.new("Frame")
    descriptionFrame.Size = UDim2.new(1, 0, 0, 60)
    descriptionFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    descriptionFrame.BorderSizePixel = 0
    descriptionFrame.LayoutOrder = 1
    descriptionFrame.Parent = page
    
    -- Add rounded corners
    local descCorner = Instance.new("UICorner")
    descCorner.CornerRadius = UDim.new(0, 8)
    descCorner.Parent = descriptionFrame
    
    local descriptionLabel = Instance.new("TextLabel")
    descriptionLabel.Size = UDim2.new(1, -20, 1, -10)
    descriptionLabel.Position = UDim2.new(0, 10, 0, 5)
    descriptionLabel.BackgroundTransparency = 1
    descriptionLabel.Text = "Configure the Open Cloud API to access DataStores outside of Roblox Studio. This enables external tools to read and write data to your game's DataStores."
    descriptionLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    descriptionLabel.TextSize = 14
    descriptionLabel.Font = Enum.Font.SourceSans
    descriptionLabel.TextWrapped = true
    descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    descriptionLabel.TextYAlignment = Enum.TextYAlignment.Top
    descriptionLabel.Parent = descriptionFrame
    
    -- Enable/Disable section
    local enableFrame = Instance.new("Frame")
    enableFrame.Size = UDim2.new(1, 0, 0, 40)
    enableFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    enableFrame.BorderSizePixel = 0
    enableFrame.LayoutOrder = 2
    enableFrame.Parent = page
    
    -- Add rounded corners
    local enableCorner = Instance.new("UICorner")
    enableCorner.CornerRadius = UDim.new(0, 8)
    enableCorner.Parent = enableFrame
    
    local enableLabel = Instance.new("TextLabel")
    enableLabel.Size = UDim2.new(0.7, 0, 1, 0)
    enableLabel.BackgroundTransparency = 1
    enableLabel.Text = "Enable Open Cloud API"
    enableLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    enableLabel.TextSize = 14
    enableLabel.Font = Enum.Font.SourceSansSemibold
    enableLabel.TextXAlignment = Enum.TextXAlignment.Left
    enableLabel.Parent = enableFrame
    
    -- Add padding to label
    local labelPadding = Instance.new("UIPadding")
    labelPadding.PaddingLeft = UDim.new(0, 10)
    labelPadding.Parent = enableLabel
    
    -- Create toggle switch
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 50, 0, 24)
    toggleFrame.Position = UDim2.new(1, -60, 0.5, -12)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- Off state color
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Name = "ToggleFrame"
    toggleFrame.Parent = enableFrame
    
    -- Add rounded corners to toggle frame
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0) -- Fully rounded
    toggleCorner.Parent = toggleFrame
    
    -- Toggle indicator
    local toggleIndicator = Instance.new("Frame")
    toggleIndicator.Size = UDim2.new(0, 20, 0, 20)
    toggleIndicator.Position = UDim2.new(0, 2, 0.5, -10) -- Left position for off state
    toggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleIndicator.BorderSizePixel = 0
    toggleIndicator.Name = "Indicator"
    toggleIndicator.Parent = toggleFrame
    
    -- Add rounded corners to indicator
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0) -- Fully rounded
    indicatorCorner.Parent = toggleIndicator
    
    -- Toggle click detection
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.BackgroundTransparency = 1
    toggleButton.Text = ""
    toggleButton.Parent = toggleFrame
    
    local isEnabled = false
    
    toggleButton.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        
        -- Update visual state
        toggleFrame.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 120, 210) or Color3.fromRGB(80, 80, 80)
        toggleIndicator.Position = isEnabled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        
        -- TODO: Update API Integration configuration
        -- APIIntegration.configureOpenCloudAPI({enabled = isEnabled})
    end)
    
    -- API Key section
    local apiKeyFrame = Instance.new("Frame")
    apiKeyFrame.Size = UDim2.new(1, 0, 0, 80)
    apiKeyFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    apiKeyFrame.BorderSizePixel = 0
    apiKeyFrame.LayoutOrder = 3
    apiKeyFrame.Parent = page
    
    -- Add rounded corners
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 8)
    keyCorner.Parent = apiKeyFrame
    
    local apiKeyLabel = Instance.new("TextLabel")
    apiKeyLabel.Size = UDim2.new(1, -20, 0, 20)
    apiKeyLabel.Position = UDim2.new(0, 10, 0, 10)
    apiKeyLabel.BackgroundTransparency = 1
    apiKeyLabel.Text = "API Key"
    apiKeyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    apiKeyLabel.TextSize = 14
    apiKeyLabel.Font = Enum.Font.SourceSansSemibold
    apiKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
    apiKeyLabel.Parent = apiKeyFrame
    
    local apiKeyInput = Instance.new("TextBox")
    apiKeyInput.Size = UDim2.new(1, -20, 0, 30)
    apiKeyInput.Position = UDim2.new(0, 10, 0, 40)
    apiKeyInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    apiKeyInput.BorderSizePixel = 0
    apiKeyInput.Text = ""
    apiKeyInput.PlaceholderText = "Enter your Open Cloud API Key"
    apiKeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    apiKeyInput.TextSize = 14
    apiKeyInput.Font = Enum.Font.SourceSans
    apiKeyInput.ClearTextOnFocus = false
    apiKeyInput.Parent = apiKeyFrame
    
    -- Add rounded corners to input
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = apiKeyInput
    
    -- Add padding to input
    local inputPadding = Instance.new("UIPadding")
    inputPadding.PaddingLeft = UDim.new(0, 10)
    inputPadding.Parent = apiKeyInput
    
    -- Universe ID section
    local universeFrame = Instance.new("Frame")
    universeFrame.Size = UDim2.new(1, 0, 0, 80)
    universeFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    universeFrame.BorderSizePixel = 0
    universeFrame.LayoutOrder = 4
    universeFrame.Parent = page
    
    -- Add rounded corners
    local universeCorner = Instance.new("UICorner")
    universeCorner.CornerRadius = UDim.new(0, 8)
    universeCorner.Parent = universeFrame
    
    local universeLabel = Instance.new("TextLabel")
    universeLabel.Size = UDim2.new(1, -20, 0, 20)
    universeLabel.Position = UDim2.new(0, 10, 0, 10)
    universeLabel.BackgroundTransparency = 1
    universeLabel.Text = "Universe ID"
    universeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    universeLabel.TextSize = 14
    universeLabel.Font = Enum.Font.SourceSansSemibold
    universeLabel.TextXAlignment = Enum.TextXAlignment.Left
    universeLabel.Parent = universeFrame
    
    local universeInput = Instance.new("TextBox")
    universeInput.Size = UDim2.new(1, -20, 0, 30)
    universeInput.Position = UDim2.new(0, 10, 0, 40)
    universeInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    universeInput.BorderSizePixel = 0
    universeInput.Text = tostring(game.GameId)
    universeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    universeInput.TextSize = 14
    universeInput.Font = Enum.Font.SourceSans
    universeInput.ClearTextOnFocus = false
    universeInput.Parent = universeFrame
    
    -- Add rounded corners to input
    local uInputCorner = Instance.new("UICorner")
    uInputCorner.CornerRadius = UDim.new(0, 4)
    uInputCorner.Parent = universeInput
    
    -- Add padding to input
    local uInputPadding = Instance.new("UIPadding")
    uInputPadding.PaddingLeft = UDim.new(0, 10)
    uInputPadding.Parent = universeInput
    
    -- Advanced settings section
    local advancedFrame = Instance.new("Frame")
    advancedFrame.Size = UDim2.new(1, 0, 0, 120)
    advancedFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    advancedFrame.BorderSizePixel = 0
    advancedFrame.LayoutOrder = 5
    advancedFrame.Parent = page
    
    -- Add rounded corners
    local advancedCorner = Instance.new("UICorner")
    advancedCorner.CornerRadius = UDim.new(0, 8)
    advancedCorner.Parent = advancedFrame
    
    local advancedLabel = Instance.new("TextLabel")
    advancedLabel.Size = UDim2.new(1, -20, 0, 20)
    advancedLabel.Position = UDim2.new(0, 10, 0, 10)
    advancedLabel.BackgroundTransparency = 1
    advancedLabel.Text = "Advanced Settings"
    advancedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    advancedLabel.TextSize = 14
    advancedLabel.Font = Enum.Font.SourceSansBold
    advancedLabel.TextXAlignment = Enum.TextXAlignment.Left
    advancedLabel.Parent = advancedFrame
    
    -- Timeout setting
    local timeoutLabel = Instance.new("TextLabel")
    timeoutLabel.Size = UDim2.new(0.5, -15, 0, 20)
    timeoutLabel.Position = UDim2.new(0, 10, 0, 40)
    timeoutLabel.BackgroundTransparency = 1
    timeoutLabel.Text = "Request Timeout (seconds)"
    timeoutLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    timeoutLabel.TextSize = 14
    timeoutLabel.Font = Enum.Font.SourceSans
    timeoutLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeoutLabel.Parent = advancedFrame
    
    local timeoutInput = Instance.new("TextBox")
    timeoutInput.Size = UDim2.new(0.5, -15, 0, 30)
    timeoutInput.Position = UDim2.new(0.5, 5, 0, 35)
    timeoutInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    timeoutInput.BorderSizePixel = 0
    timeoutInput.Text = "30"
    timeoutInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    timeoutInput.TextSize = 14
    timeoutInput.Font = Enum.Font.SourceSans
    timeoutInput.ClearTextOnFocus = false
    timeoutInput.Parent = advancedFrame
    
    -- Add rounded corners to timeout input
    local timeoutCorner = Instance.new("UICorner")
    timeoutCorner.CornerRadius = UDim.new(0, 4)
    timeoutCorner.Parent = timeoutInput
    
    -- Add padding to timeout input
    local timeoutPadding = Instance.new("UIPadding")
    timeoutPadding.PaddingLeft = UDim.new(0, 10)
    timeoutPadding.Parent = timeoutInput
    
    -- Auto retry setting
    local retryLabel = Instance.new("TextLabel")
    retryLabel.Size = UDim2.new(0.5, -15, 0, 20)
    retryLabel.Position = UDim2.new(0, 10, 0, 80)
    retryLabel.BackgroundTransparency = 1
    retryLabel.Text = "Auto Retry Failed Requests"
    retryLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    retryLabel.TextSize = 14
    retryLabel.Font = Enum.Font.SourceSans
    retryLabel.TextXAlignment = Enum.TextXAlignment.Left
    retryLabel.Parent = advancedFrame
    
    -- Create retry toggle
    local retryToggle = toggleFrame:Clone()
    retryToggle.Position = UDim2.new(0.5, 5, 0, 75)
    retryToggle.Parent = advancedFrame
    
    local isRetryEnabled = true
    retryToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 210) -- Initially enabled
    retryToggle.Indicator.Position = UDim2.new(1, -22, 0.5, -10) -- Right position for on state
    
    retryToggle.TextButton.MouseButton1Click:Connect(function()
        isRetryEnabled = not isRetryEnabled
        
        -- Update visual state
        retryToggle.BackgroundColor3 = isRetryEnabled and Color3.fromRGB(0, 120, 210) or Color3.fromRGB(80, 80, 80)
        retryToggle.Indicator.Position = isRetryEnabled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        
        -- TODO: Update API Integration configuration
    end)
    
    -- Save button section
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 50)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.LayoutOrder = 6
    buttonFrame.Parent = page
    
    local saveButton = Instance.new("TextButton")
    saveButton.Size = UDim2.new(0, 150, 0, 40)
    saveButton.Position = UDim2.new(0.5, -75, 0, 5)
    saveButton.BackgroundColor3 = Color3.fromRGB(0, 120, 210)
    saveButton.BorderSizePixel = 0
    saveButton.Text = "Save Configuration"
    saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveButton.TextSize = 16
    saveButton.Font = Enum.Font.SourceSansBold
    saveButton.Parent = buttonFrame
    
    -- Add rounded corners to button
    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0, 8)
    saveCorner.Parent = saveButton
    
    -- Handle save button click
    saveButton.MouseButton1Click:Connect(function()
        -- Validate and parse universe ID
        local universeId = tonumber(universeInput.Text)
        if not universeId then
            universeId = game.GameId -- Default to current game ID
        end
        
        -- Validate and parse timeout
        local timeout = tonumber(timeoutInput.Text)
        if not timeout or timeout < 1 then
            timeout = 30 -- Default to 30 seconds
        end
        
        -- Create configuration
        local config = {
            enabled = isEnabled,
            apiKey = apiKeyInput.Text,
            universeId = universeId,
            requestTimeout = timeout,
            autoRetry = isRetryEnabled,
            maxRetries = 3 -- Default
        }
        
        -- Save configuration
        local success, error = APIIntegration.configureOpenCloudAPI(config)
        
        -- TODO: Show success or error message
        print("Configuration saved:", success, error)
    end)
    
    -- Status section
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(1, 0, 0, 60)
    statusFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    statusFrame.BorderSizePixel = 0
    statusFrame.LayoutOrder = 7
    statusFrame.Parent = page
    
    -- Add rounded corners
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 8)
    statusCorner.Parent = statusFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 20)
    statusLabel.Position = UDim2.new(0, 10, 0, 10)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Connection Status"
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.SourceSansSemibold
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = statusFrame
    
    local statusValue = Instance.new("TextLabel")
    statusValue.Size = UDim2.new(1, -20, 0, 20)
    statusValue.Position = UDim2.new(0, 10, 0, 30)
    statusValue.BackgroundTransparency = 1
    statusValue.Text = "Not Connected"
    statusValue.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusValue.TextSize = 14
    statusValue.Font = Enum.Font.SourceSans
    statusValue.TextXAlignment = Enum.TextXAlignment.Left
    statusValue.Parent = statusFrame
    
    -- Test connection button
    local testButton = Instance.new("TextButton")
    testButton.Size = UDim2.new(0, 120, 0, 30)
    testButton.Position = UDim2.new(1, -130, 0.5, -15)
    testButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    testButton.BorderSizePixel = 0
    testButton.Text = "Test Connection"
    testButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    testButton.TextSize = 14
    testButton.Font = Enum.Font.SourceSansSemibold
    testButton.Parent = statusFrame
    
    -- Add rounded corners to button
    local testCorner = Instance.new("UICorner")
    testCorner.CornerRadius = UDim.new(0, 6)
    testCorner.Parent = testButton
    
    -- Handle test button click
    testButton.MouseButton1Click:Connect(function()
        -- TODO: Implement connection test
        statusValue.Text = "Testing connection..."
        statusValue.TextColor3 = Color3.fromRGB(255, 200, 0)
        
        -- Simulate a test
        task.delay(1, function()
            if isEnabled and apiKeyInput.Text ~= "" then
                statusValue.Text = "Connected"
                statusValue.TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                statusValue.Text = "Not Connected (Missing API Key)"
                statusValue.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end)
    end)
    
    return page
end

-- Create the Webhooks configuration page
function APIIntegrationUI.createWebhooksPage()
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -20, 1, -20) -- Add padding
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 6
    page.CanvasSize = UDim2.new(0, 0, 0, 600) -- Will adjust based on content
    page.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    
    -- Add layout
    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 15)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Parent = page
    
    -- Description section
    local descriptionFrame = Instance.new("Frame")
    descriptionFrame.Size = UDim2.new(1, 0, 0, 60)
    descriptionFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    descriptionFrame.BorderSizePixel = 0
    descriptionFrame.LayoutOrder = 1
    descriptionFrame.Parent = page
    
    -- Add rounded corners
    local descCorner = Instance.new("UICorner")
    descCorner.CornerRadius = UDim.new(0, 8)
    descCorner.Parent = descriptionFrame
    
    local descriptionLabel = Instance.new("TextLabel")
    descriptionLabel.Size = UDim2.new(1, -20, 1, -10)
    descriptionLabel.Position = UDim2.new(0, 10, 0, 5)
    descriptionLabel.BackgroundTransparency = 1
    descriptionLabel.Text = "Configure webhooks to notify external services when data changes occur. Useful for integration with custom backends, Discord bots, or other notification systems."
    descriptionLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    descriptionLabel.TextSize = 14
    descriptionLabel.Font = Enum.Font.SourceSans
    descriptionLabel.TextWrapped = true
    descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    descriptionLabel.TextYAlignment = Enum.TextYAlignment.Top
    descriptionLabel.Parent = descriptionFrame
    
    -- Webhooks list section
    local webhooksListFrame = Instance.new("Frame")
    webhooksListFrame.Size = UDim2.new(1, 0, 0, 200)
    webhooksListFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    webhooksListFrame.BorderSizePixel = 0
    webhooksListFrame.LayoutOrder = 2
    webhooksListFrame.Parent = page
    
    -- Add rounded corners
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 8)
    listCorner.Parent = webhooksListFrame
    
    -- Header and add button
    local listHeaderFrame = Instance.new("Frame")
    listHeaderFrame.Size = UDim2.new(1, 0, 0, 40)
    listHeaderFrame.BackgroundTransparency = 1
    listHeaderFrame.Parent = webhooksListFrame
    
    local listLabel = Instance.new("TextLabel")
    listLabel.Size = UDim2.new(0.7, 0, 1, 0)
    listLabel.BackgroundTransparency = 1
    listLabel.Text = "Configured Webhooks"
    listLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    listLabel.TextSize = 16
    listLabel.Font = Enum.Font.SourceSansBold
    listLabel.TextXAlignment = Enum.TextXAlignment.Left
    listLabel.Parent = listHeaderFrame
    
    -- Add padding to label
    local labelPadding = Instance.new("UIPadding")
    labelPadding.PaddingLeft = UDim.new(0, 10)
    labelPadding.Parent = listLabel
    
    local addButton = Instance.new("TextButton")
    addButton.Size = UDim2.new(0, 120, 0, 30)
    addButton.Position = UDim2.new(1, -130, 0.5, -15)
    addButton.BackgroundColor3 = Color3.fromRGB(0, 120, 210)
    addButton.BorderSizePixel = 0
    addButton.Text = "Add Webhook"
    addButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    addButton.TextSize = 14
    addButton.Font = Enum.Font.SourceSansSemibold
    addButton.Parent = listHeaderFrame
    
    -- Add rounded corners to button
    local addCorner = Instance.new("UICorner")
    addCorner.CornerRadius = UDim.new(0, 6)
    addCorner.Parent = addButton
    
    -- Webhooks list container
    local listContainer = Instance.new("ScrollingFrame")
    listContainer.Size = UDim2.new(1, -20, 0, 150)
    listContainer.Position = UDim2.new(0, 10, 0, 40)
    listContainer.BackgroundTransparency = 1
    listContainer.BorderSizePixel = 0
    listContainer.ScrollBarThickness = 6
    listContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    listContainer.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
    listContainer.ScrollingDirection = Enum.ScrollingDirection.Y
    listContainer.Parent = webhooksListFrame
    
    -- Add layout for list items
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listContainer
    
    -- Add some sample webhooks (would be populated from stored configurations)
    local sampleWebhooks = {
        {name = "Discord Notifications", url = "https://discord.com/api/webhooks/...", events = {"create", "update"}},
        {name = "Backend Integration", url = "https://example.com/api/webhook", events = {"delete"}}
    }
    
    for i, webhookData in ipairs(sampleWebhooks) do
        local webhookItem = Instance.new("Frame")
        webhookItem.Size = UDim2.new(1, 0, 0, 60)
        webhookItem.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
        webhookItem.BorderSizePixel = 0
        webhookItem.LayoutOrder = i
        webhookItem.Parent = listContainer
        
        -- Add rounded corners
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 6)
        itemCorner.Parent = webhookItem
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.4, -10, 0, 20)
        nameLabel.Position = UDim2.new(0, 10, 0, 10)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = webhookData.name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = webhookItem
        
        local urlLabel = Instance.new("TextLabel")
        urlLabel.Size = UDim2.new(0.6, -10, 0, 20)
        urlLabel.Position = UDim2.new(0.4, 0, 0, 10)
        urlLabel.BackgroundTransparency = 1
        urlLabel.Text = webhookData.url
        urlLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        urlLabel.TextSize = 12
        urlLabel.Font = Enum.Font.SourceSans
        urlLabel.TextXAlignment = Enum.TextXAlignment.Left
        urlLabel.TextTruncate = Enum.TextTruncate.AtEnd
        urlLabel.Parent = webhookItem
        
        local eventsLabel = Instance.new("TextLabel")
        eventsLabel.Size = UDim2.new(0.7, -10, 0, 20)
        eventsLabel.Position = UDim2.new(0, 10, 0, 30)
        eventsLabel.BackgroundTransparency = 1
        eventsLabel.Text = "Events: " .. table.concat(webhookData.events, ", ")
        eventsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        eventsLabel.TextSize = 12
        eventsLabel.Font = Enum.Font.SourceSans
        eventsLabel.TextXAlignment = Enum.TextXAlignment.Left
        eventsLabel.Parent = webhookItem
        
        -- Edit button
        local editButton = Instance.new("TextButton")
        editButton.Size = UDim2.new(0, 60, 0, 25)
        editButton.Position = UDim2.new(1, -130, 0.5, -12.5)
        editButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        editButton.BorderSizePixel = 0
        editButton.Text = "Edit"
        editButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        editButton.TextSize = 12
        editButton.Font = Enum.Font.SourceSansSemibold
        editButton.Parent = webhookItem
        
        -- Add rounded corners to button
        local editCorner = Instance.new("UICorner")
        editCorner.CornerRadius = UDim.new(0, 4)
        editCorner.Parent = editButton
        
        -- Delete button
        local deleteButton = Instance.new("TextButton")
        deleteButton.Size = UDim2.new(0, 60, 0, 25)
        deleteButton.Position = UDim2.new(1, -65, 0.5, -12.5)
        deleteButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        deleteButton.BorderSizePixel = 0
        deleteButton.Text = "Delete"
        deleteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        deleteButton.TextSize = 12
        deleteButton.Font = Enum.Font.SourceSansSemibold
        deleteButton.Parent = webhookItem
        
        -- Add rounded corners to button
        local deleteCorner = Instance.new("UICorner")
        deleteCorner.CornerRadius = UDim.new(0, 4)
        deleteCorner.Parent = deleteButton
    end
    
    -- Webhook configuration form
    local configSection = Instance.new("Frame")
    configSection.Size = UDim2.new(1, 0, 0, 300)
    configSection.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    configSection.BorderSizePixel = 0
    configSection.LayoutOrder = 3
    configSection.Parent = page
    
    -- Add rounded corners
    local configCorner = Instance.new("UICorner")
    configCorner.CornerRadius = UDim.new(0, 8)
    configCorner.Parent = configSection
    
    local configLabel = Instance.new("TextLabel")
    configLabel.Size = UDim2.new(1, -20, 0, 30)
    configLabel.Position = UDim2.new(0, 10, 0, 10)
    configLabel.BackgroundTransparency = 1
    configLabel.Text = "New Webhook Configuration"
    configLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    configLabel.TextSize = 16
    configLabel.Font = Enum.Font.SourceSansBold
    configLabel.TextXAlignment = Enum.TextXAlignment.Left
    configLabel.Parent = configSection
    
    -- Form fields
    -- Name field
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.3, -20, 0, 20)
    nameLabel.Position = UDim2.new(0, 10, 0, 50)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Webhook Name"
    nameLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.SourceSans
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = configSection
    
    local nameInput = Instance.new("TextBox")
    nameInput.Size = UDim2.new(0.7, -20, 0, 30)
    nameInput.Position = UDim2.new(0.3, 0, 0, 45)
    nameInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    nameInput.BorderSizePixel = 0
    nameInput.Text = ""
    nameInput.PlaceholderText = "Enter webhook name"
    nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameInput.TextSize = 14
    nameInput.Font = Enum.Font.SourceSans
    nameInput.ClearTextOnFocus = false
    nameInput.Parent = configSection
    
    -- Add rounded corners and padding
    local nameCorner = Instance.new("UICorner")
    nameCorner.CornerRadius = UDim.new(0, 4)
    nameCorner.Parent = nameInput
    
    local namePadding = Instance.new("UIPadding")
    namePadding.PaddingLeft = UDim.new(0, 10)
    namePadding.Parent = nameInput
    
    -- URL field
    local urlLabel = Instance.new("TextLabel")
    urlLabel.Size = UDim2.new(0.3, -20, 0, 20)
    urlLabel.Position = UDim2.new(0, 10, 0, 90)
    urlLabel.BackgroundTransparency = 1
    urlLabel.Text = "Webhook URL"
    urlLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    urlLabel.TextSize = 14
    urlLabel.Font = Enum.Font.SourceSans
    urlLabel.TextXAlignment = Enum.TextXAlignment.Left
    urlLabel.Parent = configSection
    
    local urlInput = Instance.new("TextBox")
    urlInput.Size = UDim2.new(0.7, -20, 0, 30)
    urlInput.Position = UDim2.new(0.3, 0, 0, 85)
    urlInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    urlInput.BorderSizePixel = 0
    urlInput.Text = ""
    urlInput.PlaceholderText = "https://example.com/webhook"
    urlInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    urlInput.TextSize = 14
    urlInput.Font = Enum.Font.SourceSans
    urlInput.ClearTextOnFocus = false
    urlInput.Parent = configSection
    
    -- Add rounded corners and padding
    local urlCorner = Instance.new("UICorner")
    urlCorner.CornerRadius = UDim.new(0, 4)
    urlCorner.Parent = urlInput
    
    local urlPadding = Instance.new("UIPadding")
    urlPadding.PaddingLeft = UDim.new(0, 10)
    urlPadding.Parent = urlInput
    
    -- Events selection
    local eventsLabel = Instance.new("TextLabel")
    eventsLabel.Size = UDim2.new(0.3, -20, 0, 20)
    eventsLabel.Position = UDim2.new(0, 10, 0, 130)
    eventsLabel.BackgroundTransparency = 1
    eventsLabel.Text = "Trigger Events"
    eventsLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    eventsLabel.TextSize = 14
    eventsLabel.Font = Enum.Font.SourceSans
    eventsLabel.TextXAlignment = Enum.TextXAlignment.Left
    eventsLabel.Parent = configSection
    
    -- Checkboxes for events
    local eventTypes = {"Create", "Update", "Delete"}
    local eventValues = {}
    
    for i, eventType in ipairs(eventTypes) do
        local checkboxFrame = Instance.new("Frame")
        checkboxFrame.Size = UDim2.new(0.2, -10, 0, 30)
        checkboxFrame.Position = UDim2.new(0.3 + (i-1) * 0.2, 0, 0, 125)
        checkboxFrame.BackgroundTransparency = 1
        checkboxFrame.Parent = configSection
        
        local checkbox = Instance.new("Frame")
        checkbox.Size = UDim2.new(0, 20, 0, 20)
        checkbox.Position = UDim2.new(0, 0, 0.5, -10)
        checkbox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        checkbox.BorderSizePixel = 0
        checkbox.Name = "Checkbox"
        checkbox.Parent = checkboxFrame
        
        -- Add rounded corners
        local checkCorner = Instance.new("UICorner")
        checkCorner.CornerRadius = UDim.new(0, 4)
        checkCorner.Parent = checkbox
        
        local checkLabel = Instance.new("TextLabel")
        checkLabel.Size = UDim2.new(0, 100, 0, 20)
        checkLabel.Position = UDim2.new(0, 30, 0.5, -10)
        checkLabel.BackgroundTransparency = 1
        checkLabel.Text = eventType
        checkLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        checkLabel.TextSize = 14
        checkLabel.Font = Enum.Font.SourceSans
        checkLabel.TextXAlignment = Enum.TextXAlignment.Left
        checkLabel.Parent = checkboxFrame
        
        -- Checkmark
        local checkmark = Instance.new("ImageLabel")
        checkmark.Size = UDim2.new(0, 16, 0, 16)
        checkmark.Position = UDim2.new(0.5, -8, 0.5, -8)
        checkmark.BackgroundTransparency = 1
        checkmark.Image = "rbxassetid://5228200082" -- Checkmark asset
        checkmark.Visible = false
        checkmark.Parent = checkbox
        
        -- Click detection
        local clickArea = Instance.new("TextButton")
        clickArea.Size = UDim2.new(1, 30, 1, 0)
        clickArea.BackgroundTransparency = 1
        clickArea.Text = ""
        clickArea.Parent = checkboxFrame
        
        -- Track state
        eventValues[eventType:lower()] = false
        
        clickArea.MouseButton1Click:Connect(function()
            eventValues[eventType:lower()] = not eventValues[eventType:lower()]
            checkmark.Visible = eventValues[eventType:lower()]
            checkbox.BackgroundColor3 = eventValues[eventType:lower()] 
                and Color3.fromRGB(0, 120, 210) 
                or Color3.fromRGB(60, 60, 60)
        end)
    end
    
    -- DataStore filters
    local storesLabel = Instance.new("TextLabel")
    storesLabel.Size = UDim2.new(0.3, -20, 0, 20)
    storesLabel.Position = UDim2.new(0, 10, 0, 170)
    storesLabel.BackgroundTransparency = 1
    storesLabel.Text = "DataStore Filters"
    storesLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    storesLabel.TextSize = 14
    storesLabel.Font = Enum.Font.SourceSans
    storesLabel.TextXAlignment = Enum.TextXAlignment.Left
    storesLabel.Parent = configSection
    
    local storesInput = Instance.new("TextBox")
    storesInput.Size = UDim2.new(0.7, -20, 0, 30)
    storesInput.Position = UDim2.new(0.3, 0, 0, 165)
    storesInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    storesInput.BorderSizePixel = 0
    storesInput.Text = ""
    storesInput.PlaceholderText = "All DataStores (comma-separated for specific stores)"
    storesInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    storesInput.TextSize = 14
    storesInput.Font = Enum.Font.SourceSans
    storesInput.ClearTextOnFocus = false
    storesInput.Parent = configSection
    
    -- Add rounded corners and padding
    local storesCorner = Instance.new("UICorner")
    storesCorner.CornerRadius = UDim.new(0, 4)
    storesCorner.Parent = storesInput
    
    local storesPadding = Instance.new("UIPadding")
    storesPadding.PaddingLeft = UDim.new(0, 10)
    storesPadding.Parent = storesInput
    
    -- Include metadata option
    local metadataLabel = Instance.new("TextLabel")
    metadataLabel.Size = UDim2.new(0.5, -20, 0, 20)
    metadataLabel.Position = UDim2.new(0, 10, 0, 210)
    metadataLabel.BackgroundTransparency = 1
    metadataLabel.Text = "Include Metadata in Payload"
    metadataLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    metadataLabel.TextSize = 14
    metadataLabel.Font = Enum.Font.SourceSans
    metadataLabel.TextXAlignment = Enum.TextXAlignment.Left
    metadataLabel.Parent = configSection
    
    -- Create metadata toggle
    local metadataToggle = Instance.new("Frame")
    metadataToggle.Size = UDim2.new(0, 50, 0, 24)
    metadataToggle.Position = UDim2.new(0.5, 0, 0, 208)
    metadataToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 210) -- Initially enabled
    metadataToggle.BorderSizePixel = 0
    metadataToggle.Name = "MetadataToggle"
    metadataToggle.Parent = configSection
    
    -- Add rounded corners to toggle frame
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0) -- Fully rounded
    toggleCorner.Parent = metadataToggle
    
    -- Toggle indicator
    local toggleIndicator = Instance.new("Frame")
    toggleIndicator.Size = UDim2.new(0, 20, 0, 20)
    toggleIndicator.Position = UDim2.new(1, -22, 0.5, -10) -- Right position for on state
    toggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleIndicator.BorderSizePixel = 0
    toggleIndicator.Name = "Indicator"
    toggleIndicator.Parent = metadataToggle
    
    -- Add rounded corners to indicator
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0) -- Fully rounded
    indicatorCorner.Parent = toggleIndicator
    
    -- Toggle click detection
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, 0, 1, 0)
    toggleButton.BackgroundTransparency = 1
    toggleButton.Text = ""
    toggleButton.Parent = metadataToggle
    
    local includeMetadata = true
    
    toggleButton.MouseButton1Click:Connect(function()
        includeMetadata = not includeMetadata
        
        -- Update visual state
        metadataToggle.BackgroundColor3 = includeMetadata and Color3.fromRGB(0, 120, 210) or Color3.fromRGB(80, 80, 80)
        toggleIndicator.Position = includeMetadata and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    end)
    
    -- Save button
    local saveButton = Instance.new("TextButton")
    saveButton.Size = UDim2.new(0, 150, 0, 40)
    saveButton.Position = UDim2.new(0.5, -75, 0, 250)
    saveButton.BackgroundColor3 = Color3.fromRGB(0, 120, 210)
    saveButton.BorderSizePixel = 0
    saveButton.Text = "Save Webhook"
    saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveButton.TextSize = 16
    saveButton.Font = Enum.Font.SourceSansBold
    saveButton.Parent = configSection
    
    -- Add rounded corners to button
    local saveCorner = Instance.new("UICorner")
    saveCorner.CornerRadius = UDim.new(0, 8)
    saveCorner.Parent = saveButton
    
    -- Handle save button click
    saveButton.MouseButton1Click:Connect(function()
        -- Validate inputs
        if nameInput.Text == "" then
            print("Webhook name is required")
            return
        end
        
        if urlInput.Text == "" then
            print("Webhook URL is required")
            return
        end
        
        -- Collect events
        local events = {}
        for event, isSelected in pairs(eventValues) do
            if isSelected then
                table.insert(events, event)
            end
        end
        
        if #events == 0 then
            print("At least one event must be selected")
            return
        end
        
        -- Parse DataStore filters
        local dataStores = {}
        if storesInput.Text ~= "" then
            for store in string.gmatch(storesInput.Text, "[^,%s]+") do
                table.insert(dataStores, store)
            end
        end
        
        -- Create configuration
        local config = {
            enabled = true,
            url = urlInput.Text,
            events = events,
            dataStores = dataStores,
            includeMetadata = includeMetadata,
            retryOnFailure = true
        }
        
        -- Save webhook configuration
        local success, error = APIIntegration.configureWebhook(nameInput.Text, config)
        
        -- TODO: Show success or error message
        print("Webhook saved:", success, error)
        
        -- Reset form
        nameInput.Text = ""
        urlInput.Text = ""
        storesInput.Text = ""
        
        -- Reset checkboxes
        for eventType, _ in pairs(eventValues) do
            eventValues[eventType] = false
        end
        
        for _, child in ipairs(configSection:GetChildren()) do
            if child:IsA("Frame") and child.Name == "Checkbox" then
                child:FindFirstChild("ImageLabel").Visible = false
                child.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            end
        end
        
        -- TODO: Refresh webhook list
    end)
    
    return page
end

-- Create the Analytics configuration page
function APIIntegrationUI.createAnalyticsPage()
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, -20, 1, -20) -- Add padding
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    
    -- Add a "Coming Soon" label
    local comingSoonLabel = Instance.new("TextLabel")
    comingSoonLabel.Size = UDim2.new(1, 0, 0, 40)
    comingSoonLabel.Position = UDim2.new(0, 0, 0.4, 0)
    comingSoonLabel.BackgroundTransparency = 1
    comingSoonLabel.Text = "Analytics Integration - Coming Soon"
    comingSoonLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    comingSoonLabel.TextSize = 20
    comingSoonLabel.Font = Enum.Font.SourceSansBold
    comingSoonLabel.Parent = page
    
    return page
end

-- Create the Plugin Extensions page
function APIIntegrationUI.createPluginExtensionsPage()
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, -20, 1, -20) -- Add padding
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    
    -- Add a "Coming Soon" label
    local comingSoonLabel = Instance.new("TextLabel")
    comingSoonLabel.Size = UDim2.new(1, 0, 0, 40)
    comingSoonLabel.Position = UDim2.new(0, 0, 0.4, 0)
    comingSoonLabel.BackgroundTransparency = 1
    comingSoonLabel.Text = "Plugin Extensions - Coming Soon"
    comingSoonLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    comingSoonLabel.TextSize = 20
    comingSoonLabel.Font = Enum.Font.SourceSansBold
    comingSoonLabel.Parent = page
    
    return page
end

return APIIntegrationUI
