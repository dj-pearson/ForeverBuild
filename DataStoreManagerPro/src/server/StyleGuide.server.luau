--luau
-- DataStore Plugin/StyleGuide.luau

-- Get module resolver from init script or define a local one
local resolver = script.Parent:FindFirstChild("ModuleResolver")
local resolveModule = resolver and require(resolver).resolveModule or function(name)
    local success, result = pcall(function()
        return require(script.Parent:FindFirstChild(name))
    end)
    
    if success and result then
        return result
    end
    
    warn("Failed to resolve module: " .. name)
    return {
        initialize = function() return true end,
        createUI = function() return Instance.new("Frame") end
    }
end

local StyleGuide = {}

-- Color scheme
StyleGuide.Colors = {
    -- Primary UI colors
    Primary = Color3.fromRGB(30, 30, 40),
    Secondary = Color3.fromRGB(40, 40, 60),
    Accent = Color3.fromRGB(60, 120, 255),
    
    -- Text colors
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(200, 200, 220),
    TextAccent = Color3.fromRGB(120, 180, 255),
    
    -- Status colors
    Success = Color3.fromRGB(60, 180, 60),
    Warning = Color3.fromRGB(255, 180, 60),
    Error = Color3.fromRGB(220, 60, 60),
    
    -- Element colors
    Button = Color3.fromRGB(60, 60, 90),
    ButtonHover = Color3.fromRGB(80, 80, 120),
    Input = Color3.fromRGB(50, 50, 70),
    InputFocus = Color3.fromRGB(60, 60, 90),
    Border = Color3.fromRGB(70, 70, 100),
    
    -- Data types
    StringType = Color3.fromRGB(180, 255, 180),
    NumberType = Color3.fromRGB(255, 200, 150),
    BooleanType = Color3.fromRGB(255, 160, 160),
    TableType = Color3.fromRGB(180, 180, 255),
    NilType = Color3.fromRGB(200, 200, 200),
}

-- Fonts
StyleGuide.Fonts = {
    Title = Enum.Font.SourceSansBold,
    Heading = Enum.Font.SourceSansSemibold,
    Body = Enum.Font.SourceSans,
    Code = Enum.Font.Code,
    Mono = Enum.Font.RobotoMono,
}

-- Font sizes
StyleGuide.FontSizes = {
    Title = 22,
    SubTitle = 18,
    Heading = 16,
    SubHeading = 14,
    Body = 14,
    Small = 12,
    Tiny = 10,
}

-- Element sizes
StyleGuide.Sizes = {
    ButtonHeight = 36,
    InputHeight = 32,
    TabHeight = 30,
    IconSize = 16,
    BorderRadius = 4,  -- Not directly applicable but useful for reference
    Padding = 10,
    BorderSize = 1,
}

-- Helper functions for styling
function StyleGuide.applyButtonStyle(button, style)
    style = style or "default"
    
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    button.Font = StyleGuide.Fonts.Body
    button.TextSize = StyleGuide.FontSizes.Body
    
    if style == "default" then
        button.BackgroundColor3 = StyleGuide.Colors.Button
        button.TextColor3 = StyleGuide.Colors.TextPrimary
    elseif style == "primary" then
        button.BackgroundColor3 = StyleGuide.Colors.Accent
        button.TextColor3 = StyleGuide.Colors.TextPrimary
    elseif style == "success" then
        button.BackgroundColor3 = StyleGuide.Colors.Success
        button.TextColor3 = StyleGuide.Colors.TextPrimary
    elseif style == "danger" then
        button.BackgroundColor3 = StyleGuide.Colors.Error
        button.TextColor3 = StyleGuide.Colors.TextPrimary
    elseif style == "warning" then
        button.BackgroundColor3 = StyleGuide.Colors.Warning
        button.TextColor3 = StyleGuide.Colors.Primary
    end
    
    -- Add hover effect
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = StyleGuide.Colors.ButtonHover
    end)
    
    button.MouseLeave:Connect(function()
        if style == "default" then
            button.BackgroundColor3 = StyleGuide.Colors.Button
        elseif style == "primary" then
            button.BackgroundColor3 = StyleGuide.Colors.Accent
        elseif style == "success" then
            button.BackgroundColor3 = StyleGuide.Colors.Success
        elseif style == "danger" then
            button.BackgroundColor3 = StyleGuide.Colors.Error
        elseif style == "warning" then
            button.BackgroundColor3 = StyleGuide.Colors.Warning
        end
    end)
end

function StyleGuide.applyInputStyle(input)
    input.BackgroundColor3 = StyleGuide.Colors.Input
    input.BorderColor3 = StyleGuide.Colors.Border
    input.TextColor3 = StyleGuide.Colors.TextPrimary
    input.PlaceholderColor3 = StyleGuide.Colors.TextSecondary
    input.Font = StyleGuide.Fonts.Body
    input.TextSize = StyleGuide.FontSizes.Body
    
    -- Add focus effect
    input.Focused:Connect(function()
        input.BorderColor3 = StyleGuide.Colors.Accent
    end)
    
    input.FocusLost:Connect(function()
        input.BorderColor3 = StyleGuide.Colors.Border
    end)
end

function StyleGuide.applyScrollingFrameStyle(frame)
    frame.BackgroundColor3 = StyleGuide.Colors.Primary
    frame.BorderColor3 = StyleGuide.Colors.Border
    frame.ScrollBarThickness = 6
    frame.ScrollBarImageColor3 = StyleGuide.Colors.Button
end

function StyleGuide.createShadow(parent)
    local shadow = Instance.new("Frame")
    shadow.BackgroundColor3 = Color3.new(0, 0, 0)
    shadow.BackgroundTransparency = 0.7
    shadow.Size = UDim2.new(1, 6, 1, 6)
    shadow.Position = UDim2.new(0, 3, 0, 3)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent
    
    return shadow
end

-- Create styled elements
function StyleGuide.createStyledButton(text, parent, style)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 100, 0, StyleGuide.Sizes.ButtonHeight)
    button.Text = text
    StyleGuide.applyButtonStyle(button, style)
    
    if parent then
        button.Parent = parent
    end
    
    return button
end

function StyleGuide.createStyledTextBox(placeholder, parent)
    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, 0, 0, StyleGuide.Sizes.InputHeight)
    textBox.PlaceholderText = placeholder
    textBox.Text = ""
    textBox.ClearTextOnFocus = false
    
    StyleGuide.applyInputStyle(textBox)
    
    if parent then
        textBox.Parent = parent
    end
    
    return textBox
end

function StyleGuide.createHeader(text, parent)
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = StyleGuide.Colors.Secondary
    header.BorderSizePixel = 0
    
    local headerText = Instance.new("TextLabel")
    headerText.Size = UDim2.new(1, -20, 1, 0)
    headerText.Position = UDim2.new(0, 10, 0, 0)
    headerText.BackgroundTransparency = 1
    headerText.Text = text
    headerText.TextColor3 = StyleGuide.Colors.TextPrimary
    headerText.Font = StyleGuide.Fonts.Heading
    headerText.TextSize = StyleGuide.FontSizes.Heading
    headerText.TextXAlignment = Enum.TextXAlignment.Left
    headerText.Parent = header
    
    if parent then
        header.Parent = parent
    end
    
    return header
end

function StyleGuide.createDivider(parent)
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.BackgroundColor3 = StyleGuide.Colors.Border
    divider.BorderSizePixel = 0
    
    if parent then
        divider.Parent = parent
    end
    
    return divider
end

function StyleGuide.createDropdown(options, parent)
    local dropdownContainer = Instance.new("Frame")
    dropdownContainer.Size = UDim2.new(1, 0, 0, StyleGuide.Sizes.InputHeight)
    dropdownContainer.BackgroundColor3 = StyleGuide.Colors.Input
    dropdownContainer.BorderColor3 = StyleGuide.Colors.Border
    
    local selectedLabel = Instance.new("TextButton")
    selectedLabel.Size = UDim2.new(1, 0, 1, 0)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Text = options[1] or "Select..."
    selectedLabel.TextColor3 = StyleGuide.Colors.TextPrimary
    selectedLabel.Font = StyleGuide.Fonts.Body
    selectedLabel.TextSize = StyleGuide.FontSizes.Body
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectedLabel.Parent = dropdownContainer
    
    local dropdownIcon = Instance.new("ImageLabel")
    dropdownIcon.Size = UDim2.new(0, 12, 0, 12)
    dropdownIcon.Position = UDim2.new(1, -20, 0.5, -6)
    dropdownIcon.BackgroundTransparency = 1
    dropdownIcon.Image = "rbxassetid://6031091004" -- Triangle icon
    dropdownIcon.Parent = dropdownContainer
    
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Size = UDim2.new(1, 0, 0, #options * StyleGuide.Sizes.InputHeight)
    optionsFrame.Position = UDim2.new(0, 0, 1, 2)
    optionsFrame.BackgroundColor3 = StyleGuide.Colors.Secondary
    optionsFrame.BorderColor3 = StyleGuide.Colors.Border
    optionsFrame.Visible = false
    optionsFrame.ZIndex = 10
    optionsFrame.Parent = dropdownContainer
    
    local optionsList = Instance.new("UIListLayout")
    optionsList.FillDirection = Enum.FillDirection.Vertical
    optionsList.SortOrder = Enum.SortOrder.LayoutOrder
    optionsList.Parent = optionsFrame
    
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, 0, 0, StyleGuide.Sizes.InputHeight)
        optionButton.BackgroundColor3 = StyleGuide.Colors.Input
        optionButton.BorderSizePixel = 0
        optionButton.Text = option
        optionButton.TextColor3 = StyleGuide.Colors.TextPrimary
        optionButton.Font = StyleGuide.Fonts.Body
        optionButton.TextSize = StyleGuide.FontSizes.Body
        optionButton.TextXAlignment = Enum.TextXAlignment.Left
        optionButton.ZIndex = 10
        optionButton.Parent = optionsFrame
        
        optionButton.MouseButton1Click:Connect(function()
            selectedLabel.Text = option
            optionsFrame.Visible = false
            dropdownContainer:SetAttribute("SelectedOption", option)
            dropdownContainer.Changed:Fire("SelectedOption")
        end)
        
        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundColor3 = StyleGuide.Colors.ButtonHover
        end)
        
        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundColor3 = StyleGuide.Colors.Input
        end)
    end
    
    selectedLabel.MouseButton1Click:Connect(function()
        optionsFrame.Visible = not optionsFrame.Visible
    end)
    
    if parent then
        dropdownContainer.Parent = parent
    end
    
    return dropdownContainer
end

function StyleGuide.getDataTypeColor(dataType)
    if dataType == "string" then
        return StyleGuide.Colors.StringType
    elseif dataType == "number" then
        return StyleGuide.Colors.NumberType
    elseif dataType == "boolean" then
        return StyleGuide.Colors.BooleanType
    elseif dataType == "table" then
        return StyleGuide.Colors.TableType
    else
        return StyleGuide.Colors.NilType
    end
end

return StyleGuide
