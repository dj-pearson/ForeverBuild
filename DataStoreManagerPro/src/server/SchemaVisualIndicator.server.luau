--luau
-- DataStore Plugin/SchemaVisualIndicator.luau
-- Module to create and update visual indicators for schema validation status

local SchemaVisualIndicator = {}

-- Creates a visual indicator frame for schema validation status
function SchemaVisualIndicator.createIndicator(parent)
    local indicatorFrame = Instance.new("Frame")
    indicatorFrame.Name = "ValidationIndicator"
    indicatorFrame.Size = UDim2.new(1, -20, 0, 40)
    indicatorFrame.Position = UDim2.new(0, 10, 0, 10)
    indicatorFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    indicatorFrame.BackgroundTransparency = 0.3
    indicatorFrame.BorderSizePixel = 0
    indicatorFrame.Visible = false
    indicatorFrame.Parent = parent
    
    -- Add rounded corners
    local cornerRadius = Instance.new("UICorner")
    cornerRadius.CornerRadius = UDim.new(0, 6)
    cornerRadius.Parent = indicatorFrame
    
    -- Status icon
    local statusIcon = Instance.new("Frame")
    statusIcon.Size = UDim2.new(0, 20, 0, 20)
    statusIcon.Position = UDim2.new(0, 10, 0.5, -10)
    statusIcon.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    statusIcon.BorderSizePixel = 0
    statusIcon.Parent = indicatorFrame
    
    -- Make the icon circular
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(1, 0)
    iconCorner.Parent = statusIcon
    
    -- Status message
    local statusMessage = Instance.new("TextLabel")
    statusMessage.Size = UDim2.new(1, -50, 1, 0)
    statusMessage.Position = UDim2.new(0, 40, 0, 0)
    statusMessage.BackgroundTransparency = 1
    statusMessage.Text = "Validation status will appear here"
    statusMessage.TextColor3 = Color3.fromRGB(220, 220, 220)
    statusMessage.Font = Enum.Font.SourceSans
    statusMessage.TextSize = 14
    statusMessage.TextWrapped = true
    statusMessage.TextXAlignment = Enum.TextXAlignment.Left
    statusMessage.Parent = indicatorFrame
    
    return {
        frame = indicatorFrame,
        icon = statusIcon,
        message = statusMessage
    }
end

-- Updates the validation indicator with status
function SchemaVisualIndicator.updateStatus(indicator, isValid, message)
    if not indicator or not indicator.frame then return end
    
    indicator.frame.Visible = true
    
    if isValid then
        -- Success styling
        indicator.frame.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
        indicator.icon.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        indicator.message.TextColor3 = Color3.fromRGB(220, 255, 220)
    else
        -- Error styling
        indicator.frame.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
        indicator.icon.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        indicator.message.TextColor3 = Color3.fromRGB(255, 220, 220)
    end
    
    indicator.message.Text = message or (isValid and "Valid" or "Invalid")
end

-- Hides the validation indicator
function SchemaVisualIndicator.hide(indicator)
    if indicator and indicator.frame then
        indicator.frame.Visible = false
    end
end

return SchemaVisualIndicator
