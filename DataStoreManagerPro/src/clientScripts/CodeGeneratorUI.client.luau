--[[
    CodeGeneratorUI.luau
    Part of DataStore Manager Pro
    
    This module provides the user interface for the Code Generator feature,
    allowing users to generate code templates from schemas.
]]

local SchemaManager = require(script.Parent.SchemaManager)
local CodeGenerator = require(script.Parent.CodeGenerator)

local CodeGeneratorUI = {}

-- Initialize the UI for the code generator
function CodeGeneratorUI.initialize()
    print("CodeGeneratorUI: Initializing module...")
    
    -- Make sure the CodeGenerator is initialized
    CodeGenerator.initialize()
    
    return true
end

-- Create UI for the code generator panel
function CodeGeneratorUI.createUI(container)
    if not container then
        warn("CodeGeneratorUI: No container provided for the UI")
        return
    end
    
    print("CodeGeneratorUI: Creating UI...")
    
    -- Clear existing UI
    for _, child in ipairs(container:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
    
    -- Add layout if not present
    if not container:FindFirstChildOfClass("UIListLayout") then
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = container
    end
    
    -- Add padding if not present
    if not container:FindFirstChildOfClass("UIPadding") then
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 8)
        padding.PaddingRight = UDim.new(0, 8)
        padding.PaddingTop = UDim.new(0, 8)
        padding.PaddingBottom = UDim.new(0, 8)
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
    titleLabel.Text = "Code Generator"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 24
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleSection
    
    -- Schema selection section
    local schemaSection = Instance.new("Frame")
    schemaSection.Size = UDim2.new(1, 0, 0, 70)
    schemaSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    schemaSection.BorderSizePixel = 0
    schemaSection.Name = "SchemaSection"
    schemaSection.LayoutOrder = 2
    schemaSection.Parent = container
    
    local schemaLabel = Instance.new("TextLabel")
    schemaLabel.Size = UDim2.new(1, 0, 0, 24)
    schemaLabel.Position = UDim2.new(0, 0, 0, 0)
    schemaLabel.BackgroundTransparency = 1
    schemaLabel.Text = "Select Schema:"
    schemaLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    schemaLabel.TextSize = 14
    schemaLabel.Font = Enum.Font.SourceSans
    schemaLabel.TextXAlignment = Enum.TextXAlignment.Left
    schemaLabel.Parent = schemaSection
    
    local schemaDropdown = Instance.new("Frame")
    schemaDropdown.Size = UDim2.new(1, 0, 0, 36)
    schemaDropdown.Position = UDim2.new(0, 0, 0, 24)
    schemaDropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    schemaDropdown.BorderSizePixel = 0
    schemaDropdown.Name = "SchemaDropdown"
    schemaDropdown.Parent = schemaSection
    
    -- Round the corners
    local cornerRadius = Instance.new("UICorner")
    cornerRadius.CornerRadius = UDim.new(0, 4)
    cornerRadius.Parent = schemaDropdown
    
    local schemaButton = Instance.new("TextButton")
    schemaButton.Size = UDim2.new(1, 0, 1, 0)
    schemaButton.BackgroundTransparency = 1
    schemaButton.Text = "Select a schema..."
    schemaButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    schemaButton.TextSize = 14
    schemaButton.Font = Enum.Font.SourceSans
    schemaButton.TextXAlignment = Enum.TextXAlignment.Left
    schemaButton.Name = "SchemaButton"
    schemaButton.Parent = schemaDropdown
    
    -- Add padding to the button text
    local buttonPadding = Instance.new("UIPadding")
    buttonPadding.PaddingLeft = UDim.new(0, 8)
    buttonPadding.Parent = schemaButton
    
    -- Add a dropdown arrow
    local dropdownArrow = Instance.new("ImageLabel")
    dropdownArrow.Size = UDim2.new(0, 12, 0, 12)
    dropdownArrow.Position = UDim2.new(1, -24, 0.5, -6)
    dropdownArrow.BackgroundTransparency = 1
    dropdownArrow.Image = "rbxassetid://7072706620" -- Dropdown arrow icon
    dropdownArrow.Parent = schemaDropdown
    
    -- Code type selection section
    local codeTypeSection = Instance.new("Frame")
    codeTypeSection.Size = UDim2.new(1, 0, 0, 120)
    codeTypeSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    codeTypeSection.BorderSizePixel = 0
    codeTypeSection.Name = "CodeTypeSection"
    codeTypeSection.LayoutOrder = 3
    codeTypeSection.Parent = container
    
    local codeTypeLabel = Instance.new("TextLabel")
    codeTypeLabel.Size = UDim2.new(1, 0, 0, 24)
    codeTypeLabel.Position = UDim2.new(0, 0, 0, 0)
    codeTypeLabel.BackgroundTransparency = 1
    codeTypeLabel.Text = "Code Type:"
    codeTypeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    codeTypeLabel.TextSize = 14
    codeTypeLabel.Font = Enum.Font.SourceSans
    codeTypeLabel.TextXAlignment = Enum.TextXAlignment.Left
    codeTypeLabel.Parent = codeTypeSection
    
    -- Create radio buttons for code types
    local codeTypes = {"Server Script", "Client Script", "Module Script", "Documentation"}
    local codeTypeValues = {"server", "client", "module", "docs"}
    local buttonSize = UDim2.new(0.5, -4, 0, 30)
    local selectedCodeType = codeTypeValues[1] -- Default selected type
    
    for i, codeType in ipairs(codeTypes) do
        local row = math.floor((i-1) / 2)
        local col = (i-1) % 2
        
        local radioButton = Instance.new("Frame")
        radioButton.Size = buttonSize
        radioButton.Position = UDim2.new(col * 0.5, col * 4, 0, 24 + row * 34)
        radioButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        radioButton.BorderSizePixel = 0
        radioButton.Name = codeTypeValues[i] .. "Radio"
        radioButton.Parent = codeTypeSection
        
        -- Round corners
        local radioCorner = Instance.new("UICorner")
        radioCorner.CornerRadius = UDim.new(0, 4)
        radioCorner.Parent = radioButton
        
        local radioLabel = Instance.new("TextLabel")
        radioLabel.Size = UDim2.new(1, -30, 1, 0)
        radioLabel.Position = UDim2.new(0, 30, 0, 0)
        radioLabel.BackgroundTransparency = 1
        radioLabel.Text = codeType
        radioLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        radioLabel.TextSize = 14
        radioLabel.Font = Enum.Font.SourceSans
        radioLabel.TextXAlignment = Enum.TextXAlignment.Left
        radioLabel.Parent = radioButton
        
        local radioCircle = Instance.new("Frame")
        radioCircle.Size = UDim2.new(0, 16, 0, 16)
        radioCircle.Position = UDim2.new(0, 8, 0.5, -8)
        radioCircle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        radioCircle.BorderSizePixel = 0
        radioCircle.Name = "RadioCircle"
        radioCircle.Parent = radioButton
        
        -- Make the circle round
        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(1, 0) -- Full circle
        circleCorner.Parent = radioCircle
        
        -- Selection indicator
        local selectionDot = Instance.new("Frame")
        selectionDot.Size = UDim2.new(0, 8, 0, 8)
        selectionDot.Position = UDim2.new(0.5, -4, 0.5, -4)
        selectionDot.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        selectionDot.BorderSizePixel = 0
        selectionDot.Name = "SelectionDot"
        selectionDot.Visible = (codeTypeValues[i] == selectedCodeType)
        selectionDot.Parent = radioCircle
        
        -- Make the selection dot round
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0) -- Full circle
        dotCorner.Parent = selectionDot
        
        -- Make the radio button clickable
        local radioClickArea = Instance.new("TextButton")
        radioClickArea.Size = UDim2.new(1, 0, 1, 0)
        radioClickArea.BackgroundTransparency = 1
        radioClickArea.Text = ""
        radioClickArea.Name = "RadioClickArea"
        radioClickArea.Parent = radioButton
        
        -- Set up click handler
        radioClickArea.MouseButton1Click:Connect(function()
            -- Update the selected code type
            selectedCodeType = codeTypeValues[i]
            
            -- Update UI
            for j, typeValue in ipairs(codeTypeValues) do
                local otherRadio = codeTypeSection:FindFirstChild(typeValue .. "Radio")
                if otherRadio then
                    local otherDot = otherRadio:FindFirstChild("RadioCircle"):FindFirstChild("SelectionDot")
                    if otherDot then
                        otherDot.Visible = (typeValue == selectedCodeType)
                    end
                end
            end
        end)
    end
    
    -- Options section
    local optionsSection = Instance.new("Frame")
    optionsSection.Size = UDim2.new(1, 0, 0, 76)
    optionsSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    optionsSection.BorderSizePixel = 0
    optionsSection.Name = "OptionsSection"
    optionsSection.LayoutOrder = 4
    optionsSection.Parent = container
    
    local optionsLabel = Instance.new("TextLabel")
    optionsLabel.Size = UDim2.new(1, 0, 0, 24)
    optionsLabel.Position = UDim2.new(0, 0, 0, 0)
    optionsLabel.BackgroundTransparency = 1
    optionsLabel.Text = "Options:"
    optionsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    optionsLabel.TextSize = 14
    optionsLabel.Font = Enum.Font.SourceSans
    optionsLabel.TextXAlignment = Enum.TextXAlignment.Left
    optionsLabel.Parent = optionsSection
    
    -- DataStore name input
    local dsNameLabel = Instance.new("TextLabel")
    dsNameLabel.Size = UDim2.new(0.4, 0, 0, 20)
    dsNameLabel.Position = UDim2.new(0, 0, 0, 26)
    dsNameLabel.BackgroundTransparency = 1
    dsNameLabel.Text = "DataStore Name:"
    dsNameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    dsNameLabel.TextSize = 14
    dsNameLabel.Font = Enum.Font.SourceSans
    dsNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    dsNameLabel.Parent = optionsSection
    
    local dsNameInput = Instance.new("TextBox")
    dsNameInput.Size = UDim2.new(0.6, -4, 0, 24)
    dsNameInput.Position = UDim2.new(0.4, 0, 0, 24)
    dsNameInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    dsNameInput.BorderSizePixel = 0
    dsNameInput.Text = ""
    dsNameInput.PlaceholderText = "Optional (default: SchemaNameStore)"
    dsNameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    dsNameInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    dsNameInput.TextSize = 14
    dsNameInput.Font = Enum.Font.SourceSans
    dsNameInput.TextXAlignment = Enum.TextXAlignment.Left
    dsNameInput.Name = "DataStoreNameInput"
    dsNameInput.ClearTextOnFocus = false
    dsNameInput.Parent = optionsSection
    
    -- Add padding to the TextBox
    local inputPadding = Instance.new("UIPadding")
    inputPadding.PaddingLeft = UDim.new(0, 8)
    inputPadding.Parent = dsNameInput
    
    -- Round corners for input
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = dsNameInput
    
    -- Template selection
    local templateLabel = Instance.new("TextLabel")
    templateLabel.Size = UDim2.new(0.4, 0, 0, 20)
    templateLabel.Position = UDim2.new(0, 0, 0, 52)
    templateLabel.BackgroundTransparency = 1
    templateLabel.Text = "Template:"
    templateLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    templateLabel.TextSize = 14
    templateLabel.Font = Enum.Font.SourceSans
    templateLabel.TextXAlignment = Enum.TextXAlignment.Left
    templateLabel.Parent = optionsSection
    
    local templateInput = Instance.new("TextBox")
    templateInput.Size = UDim2.new(0.6, -4, 0, 24)
    templateInput.Position = UDim2.new(0.4, 0, 0, 50)
    templateInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    templateInput.BorderSizePixel = 0
    templateInput.Text = "default"
    templateInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    templateInput.TextSize = 14
    templateInput.Font = Enum.Font.SourceSans
    templateInput.TextXAlignment = Enum.TextXAlignment.Left
    templateInput.Name = "TemplateInput"
    templateInput.ClearTextOnFocus = false
    templateInput.Parent = optionsSection
    
    -- Add padding to the template input
    local tempInputPadding = Instance.new("UIPadding")
    tempInputPadding.PaddingLeft = UDim.new(0, 8)
    tempInputPadding.Parent = templateInput
    
    -- Round corners for template input
    local tempInputCorner = Instance.new("UICorner")
    tempInputCorner.CornerRadius = UDim.new(0, 4)
    tempInputCorner.Parent = templateInput
    
    -- Preview/Generate section
    local previewSection = Instance.new("Frame")
    previewSection.Size = UDim2.new(1, 0, 0, 36)
    previewSection.BackgroundTransparency = 1
    previewSection.Name = "PreviewSection"
    previewSection.LayoutOrder = 5
    previewSection.Parent = container
    
    local generateButton = Instance.new("TextButton")
    generateButton.Size = UDim2.new(0.48, 0, 1, 0)
    generateButton.Position = UDim2.new(0, 0, 0, 0)
    generateButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    generateButton.BorderSizePixel = 0
    generateButton.Text = "Generate Code"
    generateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    generateButton.TextSize = 16
    generateButton.Font = Enum.Font.SourceSansSemibold
    generateButton.Name = "GenerateButton"
    generateButton.Parent = previewSection
    
    -- Round corners for generate button
    local genButtonCorner = Instance.new("UICorner")
    genButtonCorner.CornerRadius = UDim.new(0, 4)
    genButtonCorner.Parent = generateButton
    
    local copyButton = Instance.new("TextButton")
    copyButton.Size = UDim2.new(0.48, 0, 1, 0)
    copyButton.Position = UDim2.new(0.52, 0, 0, 0)
    copyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    copyButton.BorderSizePixel = 0
    copyButton.Text = "Copy to Clipboard"
    copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyButton.TextSize = 16
    copyButton.Font = Enum.Font.SourceSansSemibold
    copyButton.Name = "CopyButton"
    copyButton.Parent = previewSection
    
    -- Round corners for copy button
    local copyButtonCorner = Instance.new("UICorner")
    copyButtonCorner.CornerRadius = UDim.new(0, 4)
    copyButtonCorner.Parent = copyButton
    
    -- Output preview section
    local outputSection = Instance.new("Frame")
    outputSection.Size = UDim2.new(1, 0, 1, -342) -- Adjust based on total height of previous sections
    outputSection.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    outputSection.BorderSizePixel = 0
    outputSection.Name = "OutputSection"
    outputSection.LayoutOrder = 6
    outputSection.Parent = container
    
    -- Round the corners of output section
    local outputCorner = Instance.new("UICorner")
    outputCorner.CornerRadius = UDim.new(0, 4)
    outputCorner.Parent = outputSection
    
    local outputScrollFrame = Instance.new("ScrollingFrame")
    outputScrollFrame.Size = UDim2.new(1, -16, 1, -16)
    outputScrollFrame.Position = UDim2.new(0, 8, 0, 8)
    outputScrollFrame.BackgroundTransparency = 1
    outputScrollFrame.BorderSizePixel = 0
    outputScrollFrame.ScrollBarThickness = 6
    outputScrollFrame.ElasticBehavior = Enum.ElasticBehavior.Always
    outputScrollFrame.CanvasSize = UDim2.new(1, -6, 2, 0) -- Will be adjusted based on content
    outputScrollFrame.Parent = outputSection
    
    local outputText = Instance.new("TextBox")
    outputText.Size = UDim2.new(1, 0, 1, 0)
    outputText.BackgroundTransparency = 1
    outputText.BorderSizePixel = 0
    outputText.Text = "-- Generated code will appear here"
    outputText.TextColor3 = Color3.fromRGB(200, 200, 200)
    outputText.TextSize = 14
    outputText.Font = Enum.Font.Code
    outputText.TextXAlignment = Enum.TextXAlignment.Left
    outputText.TextYAlignment = Enum.TextYAlignment.Top
    outputText.TextWrapped = false
    outputText.ClearTextOnFocus = false
    outputText.MultiLine = true
    outputText.Parent = outputScrollFrame
    
    -- Add padding to the output text
    local outputPadding = Instance.new("UIPadding")
    outputPadding.PaddingLeft = UDim.new(0, 8)
    outputPadding.PaddingRight = UDim.new(0, 8)
    outputPadding.Parent = outputText
    
    -- Set up dropdown functionality for schema selection
    local dropdownContent = nil
    
    -- Set up schema dropdown functionality
    schemaButton.MouseButton1Click:Connect(function()
        if dropdownContent then
            dropdownContent:Destroy()
            dropdownContent = nil
            return
        end
        
        -- Get available schemas
        local schemas = SchemaManager.getSchemas()
        
        -- Create dropdown content
        dropdownContent = Instance.new("Frame")
        dropdownContent.Size = UDim2.new(1, 0, 0, #schemas * 30)
        dropdownContent.Position = UDim2.new(0, 0, 1, 4)
        dropdownContent.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        dropdownContent.BorderSizePixel = 0
        dropdownContent.ZIndex = 10
        dropdownContent.Name = "DropdownContent"
        dropdownContent.Parent = schemaDropdown
        
        -- Round the corners
        local dropdownCorner = Instance.new("UICorner")
        dropdownCorner.CornerRadius = UDim.new(0, 4)
        dropdownCorner.Parent = dropdownContent
        
        -- Add layout for dropdown items
        local dropdownLayout = Instance.new("UIListLayout")
        dropdownLayout.Padding = UDim.new(0, 0)
        dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
        dropdownLayout.Parent = dropdownContent
        
        -- Add schema options to dropdown
        for i, schemaName in ipairs(schemas) do
            local option = Instance.new("TextButton")
            option.Size = UDim2.new(1, 0, 0, 30)
            option.BackgroundTransparency = 1
            option.Text = schemaName
            option.TextColor3 = Color3.fromRGB(255, 255, 255)
            option.TextSize = 14
            option.Font = Enum.Font.SourceSans
            option.TextXAlignment = Enum.TextXAlignment.Left
            option.LayoutOrder = i
            option.ZIndex = 10
            option.Parent = dropdownContent
            
            -- Add padding to the option text
            local optionPadding = Instance.new("UIPadding")
            optionPadding.PaddingLeft = UDim.new(0, 8)
            optionPadding.Parent = option
            
            -- Set up click handler for the option
            option.MouseButton1Click:Connect(function()
                schemaButton.Text = schemaName
                
                -- Auto-fill the DataStore name based on schema selection
                if dsNameInput.Text == "" then
                    dsNameInput.Text = schemaName .. "Store"
                end
                
                -- Close the dropdown
                dropdownContent:Destroy()
                dropdownContent = nil
            end)
        end
    end)
    
    -- Handle generating code
    generateButton.MouseButton1Click:Connect(function()
        local schemaName = schemaButton.Text
        
        -- Validate schema selection
        if schemaName == "Select a schema..." then
            outputText.Text = "-- Please select a schema first"
            return
        end
        
        -- Gather options
        local options = {
            dataStoreName = dsNameInput.Text ~= "" and dsNameInput.Text or nil,
            template = templateInput.Text ~= "" and templateInput.Text or "default"
        }
        
        -- Generate code
        local generatedCode, error = CodeGenerator.generateModuleFromSchema(schemaName, {
            moduleType = selectedCodeType,
            template = options.template,
            dataStoreName = options.dataStoreName
        })
        
        if error then
            outputText.Text = "-- Error: " .. error
        elseif generatedCode then
            outputText.Text = generatedCode
            
            -- Adjust the canvas size based on content
            local textLines = string.split(generatedCode, "\n")
            outputScrollFrame.CanvasSize = UDim2.new(1, -6, 0, #textLines * 16 + 20)
        else
            outputText.Text = "-- Error: Failed to generate code"
        end
    end)
    
    -- Handle copying to clipboard
    copyButton.MouseButton1Click:Connect(function()
        local code = outputText.Text
        
        if code ~= "-- Generated code will appear here" and code:sub(1, 10) ~= "-- Error: " then
            -- TODO: Can't directly use the clipboard API in Roblox, but we can store in a variable
            -- for later export or manual copy
            outputText.Text = "-- Code copied! (Not really, this is a placeholder since Roblox doesn't allow clipboard access)\n\n" .. code
        end
    end)
    
    return container
end

return CodeGeneratorUI
