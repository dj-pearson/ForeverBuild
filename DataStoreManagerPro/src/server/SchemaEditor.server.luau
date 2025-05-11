--luau
-- DataStore Plugin/SchemaEditor.luau

local StyleGuide = require(script.Parent.StyleGuide)
local SchemaManager = require(script.Parent.SchemaManager.server)
local SchemaValidator = require(script.Parent.SchemaValidator.server)

local SchemaEditor = {}

function SchemaEditor.createSchemaEditorUI(parent, dataStoreName, keyName)
    -- Get current schema or create a new one
    local currentSchema = SchemaManager.loadSchema(dataStoreName, keyName) or {}
    
    -- Create main container
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundColor3 = StyleGuide.Colors.Primary
    container.BorderSizePixel = 0
    container.Parent = parent
    
    -- Create header
    local header = StyleGuide.createHeader("Schema Editor: " .. dataStoreName .. " / " .. keyName, container)
    
    -- Create toolbar
    local toolbar = Instance.new("Frame")
    toolbar.Size = UDim2.new(1, 0, 0, StyleGuide.Sizes.ButtonHeight + 10)
    toolbar.Position = UDim2.new(0, 0, 0, header.Size.Y.Offset)
    toolbar.BackgroundColor3 = StyleGuide.Colors.Secondary
    toolbar.BorderSizePixel = 0
    toolbar.Parent = container
    
    local toolbarLayout = Instance.new("UIListLayout")
    toolbarLayout.FillDirection = Enum.FillDirection.Horizontal
    toolbarLayout.Padding = UDim.new(0, 10)
    toolbarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    toolbarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    toolbarLayout.Parent = toolbar
    
    local saveButton = StyleGuide.createStyledButton("Save Schema", toolbar, "primary")
    saveButton.Size = UDim2.new(0, 120, 0, StyleGuide.Sizes.ButtonHeight)
    
    local validateButton = StyleGuide.createStyledButton("Validate", toolbar, "default")
    validateButton.Size = UDim2.new(0, 100, 0, StyleGuide.Sizes.ButtonHeight)
    
    local exportButton = StyleGuide.createStyledButton("Export", toolbar, "default")
    exportButton.Size = UDim2.new(0, 100, 0, StyleGuide.Sizes.ButtonHeight)
    
    local importButton = StyleGuide.createStyledButton("Import", toolbar, "default")
    importButton.Size = UDim2.new(0, 100, 0, StyleGuide.Sizes.ButtonHeight)
    
    -- Create split view
    local splitContainer = Instance.new("Frame")
    splitContainer.Size = UDim2.new(1, 0, 1, -(header.Size.Y.Offset + toolbar.Size.Y.Offset))
    splitContainer.Position = UDim2.new(0, 0, 0, header.Size.Y.Offset + toolbar.Size.Y.Offset)
    splitContainer.BackgroundTransparency = 1
    splitContainer.Parent = container
    
    -- Left side: Schema tree editor
    local treeContainer = Instance.new("ScrollingFrame")
    treeContainer.Size = UDim2.new(0.4, 0, 1, 0)
    treeContainer.BackgroundColor3 = StyleGuide.Colors.Primary
    treeContainer.BorderColor3 = StyleGuide.Colors.Border
    treeContainer.BorderSizePixel = 1
    treeContainer.ScrollBarThickness = 6
    treeContainer.ScrollingDirection = Enum.ScrollingDirection.Y
    treeContainer.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
    treeContainer.Parent = splitContainer
    
    local treeLayout = Instance.new("UIListLayout")
    treeLayout.FillDirection = Enum.FillDirection.Vertical
    treeLayout.Padding = UDim.new(0, 1)
    treeLayout.Parent = treeContainer
    
    -- Right side: Property editor
    local propertyContainer = Instance.new("Frame")
    propertyContainer.Size = UDim2.new(0.59, 0, 1, 0)
    propertyContainer.Position = UDim2.new(0.41, 0, 0, 0)
    propertyContainer.BackgroundColor3 = StyleGuide.Colors.Primary
    propertyContainer.BorderColor3 = StyleGuide.Colors.Border
    propertyContainer.BorderSizePixel = 1
    propertyContainer.Parent = splitContainer
    
    local propertyTitle = Instance.new("TextLabel")
    propertyTitle.Size = UDim2.new(1, 0, 0, 30)
    propertyTitle.BackgroundColor3 = StyleGuide.Colors.Secondary
    propertyTitle.BorderSizePixel = 0
    propertyTitle.Text = "Property Details"
    propertyTitle.TextColor3 = StyleGuide.Colors.TextPrimary
    propertyTitle.Font = StyleGuide.Fonts.Heading
    propertyTitle.TextSize = StyleGuide.FontSizes.Heading
    propertyTitle.Parent = propertyContainer
    
    local propertyEditor = Instance.new("ScrollingFrame")
    propertyEditor.Size = UDim2.new(1, 0, 1, -30)
    propertyEditor.Position = UDim2.new(0, 0, 0, 30)
    propertyEditor.BackgroundColor3 = StyleGuide.Colors.Primary
    propertyEditor.BorderSizePixel = 0
    propertyEditor.ScrollBarThickness = 6
    propertyEditor.ScrollingDirection = Enum.ScrollingDirection.Y
    propertyEditor.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
    propertyEditor.Parent = propertyContainer
    
    local propertyLayout = Instance.new("UIListLayout")
    propertyLayout.FillDirection = Enum.FillDirection.Vertical
    propertyLayout.Padding = UDim.new(0, 10)
    propertyLayout.Parent = propertyEditor
    
    -- Status message area
    local statusContainer = Instance.new("Frame")
    statusContainer.Size = UDim2.new(1, 0, 0, 30)
    statusContainer.Position = UDim2.new(0, 0, 1, -30)
    statusContainer.BackgroundColor3 = StyleGuide.Colors.Secondary
    statusContainer.BorderSizePixel = 0
    statusContainer.Visible = false
    statusContainer.ZIndex = 10
    statusContainer.Parent = container
    
    local statusMessage = Instance.new("TextLabel")
    statusMessage.Size = UDim2.new(1, -20, 1, 0)
    statusMessage.Position = UDim2.new(0, 10, 0, 0)
    statusMessage.BackgroundTransparency = 1
    statusMessage.TextColor3 = StyleGuide.Colors.Success
    statusMessage.Font = StyleGuide.Fonts.Body
    statusMessage.TextSize = StyleGuide.FontSizes.Body
    statusMessage.TextXAlignment = Enum.TextXAlignment.Left
    statusMessage.ZIndex = 10
    statusMessage.Parent = statusContainer
    
    -- Function to display a status message
    local function showStatus(message, isError)
        statusMessage.Text = message
        statusMessage.TextColor3 = isError and StyleGuide.Colors.Error or StyleGuide.Colors.Success
        statusContainer.Visible = true
        
        -- Hide after 5 seconds
        delay(5, function()
            statusContainer.Visible = false
        end)
    end
    
    -- Function to create a new property field UI
    local function createPropertyUI(parent, propertyName, propertyType, isRequired, defaultValue)
        local propertyFrame = Instance.new("Frame")
        propertyFrame.Size = UDim2.new(1, -20, 0, 30)
        propertyFrame.Position = UDim2.new(0, 10, 0, 0)
        propertyFrame.BackgroundTransparency = 1
        propertyFrame.Parent = parent
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.3, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = propertyName or "property"
        nameLabel.TextColor3 = StyleGuide.Colors.TextPrimary
        nameLabel.Font = StyleGuide.Fonts.Body
        nameLabel.TextSize = StyleGuide.FontSizes.Body
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = propertyFrame
        
        local typeDropdown = StyleGuide.createDropdown({"string", "number", "boolean", "table", "array"}, propertyFrame)
        typeDropdown.Size = UDim2.new(0.2, 0, 1, 0)
        typeDropdown.Position = UDim2.new(0.3, 5, 0, 0)
        
        -- Set initial value
        if propertyType then
            local selectedLabel = typeDropdown:FindFirstChild("TextButton")
            if selectedLabel then
                selectedLabel.Text = propertyType
            end
            typeDropdown:SetAttribute("SelectedOption", propertyType)
        end
        
        local requiredCheckbox = Instance.new("Frame")
        requiredCheckbox.Size = UDim2.new(0.15, 0, 1, 0)
        requiredCheckbox.Position = UDim2.new(0.5, 5, 0, 0)
        requiredCheckbox.BackgroundTransparency = 1
        requiredCheckbox.Parent = propertyFrame
        
        local requiredLabel = Instance.new("TextLabel")
        requiredLabel.Size = UDim2.new(0.7, 0, 1, 0)
        requiredLabel.BackgroundTransparency = 1
        requiredLabel.Text = "Required"
        requiredLabel.TextColor3 = StyleGuide.Colors.TextPrimary
        requiredLabel.Font = StyleGuide.Fonts.Body
        requiredLabel.TextSize = StyleGuide.FontSizes.Body
        requiredLabel.TextXAlignment = Enum.TextXAlignment.Left
        requiredLabel.Parent = requiredCheckbox
        
        local requiredToggle = Instance.new("TextButton")
        requiredToggle.Size = UDim2.new(0, 16, 0, 16)
        requiredToggle.Position = UDim2.new(0.7, 5, 0.5, -8)
        requiredToggle.BackgroundColor3 = isRequired and StyleGuide.Colors.Accent or StyleGuide.Colors.Input
        requiredToggle.BorderColor3 = StyleGuide.Colors.Border
        requiredToggle.Text = ""
        requiredToggle.Parent = requiredCheckbox
        requiredToggle:SetAttribute("IsChecked", isRequired or false)
        
        requiredToggle.MouseButton1Click:Connect(function()
            local checked = not requiredToggle:GetAttribute("IsChecked")
            requiredToggle:SetAttribute("IsChecked", checked)
            requiredToggle.BackgroundColor3 = checked and StyleGuide.Colors.Accent or StyleGuide.Colors.Input
        end)
        
        local defaultValueInput = Instance.new("TextBox")
        defaultValueInput.Size = UDim2.new(0.2, 0, 1, 0)
        defaultValueInput.Position = UDim2.new(0.65, 5, 0, 0)
        defaultValueInput.BackgroundColor3 = StyleGuide.Colors.Input
        defaultValueInput.BorderColor3 = StyleGuide.Colors.Border
        defaultValueInput.TextColor3 = StyleGuide.Colors.TextPrimary
        defaultValueInput.PlaceholderText = "Default"
        defaultValueInput.PlaceholderColor3 = StyleGuide.Colors.TextSecondary
        defaultValueInput.Text = defaultValue or ""
        defaultValueInput.Font = StyleGuide.Fonts.Body
        defaultValueInput.TextSize = StyleGuide.FontSizes.Body
        defaultValueInput.Parent = propertyFrame
        
        local deleteButton = Instance.new("TextButton")
        deleteButton.Size = UDim2.new(0.15, -10, 1, 0)
        deleteButton.Position = UDim2.new(0.85, 5, 0, 0)
        deleteButton.BackgroundColor3 = StyleGuide.Colors.Error
        deleteButton.BorderSizePixel = 0
        deleteButton.Text = "Delete"
        deleteButton.TextColor3 = StyleGuide.Colors.TextPrimary
        deleteButton.Font = StyleGuide.Fonts.Body
        deleteButton.TextSize = StyleGuide.FontSizes.Body
        deleteButton.Parent = propertyFrame
        
        deleteButton.MouseButton1Click:Connect(function()
            propertyFrame:Destroy()
        end)
        
        return propertyFrame
    end
    
    -- Function to create the schema tree nodes
    local function refreshSchemaTree()
        -- Clear existing nodes
        for _, child in ipairs(treeContainer:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        -- Create root node
        local rootNode = Instance.new("Frame")
        rootNode.Size = UDim2.new(1, 0, 0, 30)
        rootNode.BackgroundColor3 = StyleGuide.Colors.Secondary
        rootNode.BorderSizePixel = 0
        rootNode.Parent = treeContainer
        
        local rootLabel = Instance.new("TextLabel")
        rootLabel.Size = UDim2.new(0.7, 0, 1, 0)
        rootLabel.BackgroundTransparency = 1
        rootLabel.Text = "Root Schema"
        rootLabel.TextColor3 = StyleGuide.Colors.TextPrimary
        rootLabel.Font = StyleGuide.Fonts.Heading
        rootLabel.TextSize = StyleGuide.FontSizes.Heading
        rootLabel.TextXAlignment = Enum.TextXAlignment.Left
        rootLabel.Parent = rootNode
        
        local addPropertyButton = Instance.new("TextButton")
        addPropertyButton.Size = UDim2.new(0.3, -10, 1, -6)
        addPropertyButton.Position = UDim2.new(0.7, 0, 0, 3)
        addPropertyButton.BackgroundColor3 = StyleGuide.Colors.Success
        addPropertyButton.BorderSizePixel = 0
        addPropertyButton.Text = "Add Property"
        addPropertyButton.TextColor3 = StyleGuide.Colors.TextPrimary
        addPropertyButton.Font = StyleGuide.Fonts.Body
        addPropertyButton.TextSize = StyleGuide.FontSizes.Body
        addPropertyButton.Parent = rootNode
        
        addPropertyButton.MouseButton1Click:Connect(function()
            local newPropertyName = "property" .. math.random(1000, 9999)
            
            -- Create input for property name
            local nameInput = Instance.new("TextBox")
            nameInput.Size = UDim2.new(1, -20, 0, 30)
            nameInput.Position = UDim2.new(0, 10, 0, 10)
            nameInput.BackgroundColor3 = StyleGuide.Colors.Input
            nameInput.BorderColor3 = StyleGuide.Colors.Border
            nameInput.TextColor3 = StyleGuide.Colors.TextPrimary
            nameInput.PlaceholderText = "Enter property name"
            nameInput.Text = newPropertyName
            nameInput.Font = StyleGuide.Fonts.Body
            nameInput.TextSize = StyleGuide.FontSizes.Body
            nameInput.TextXAlignment = Enum.TextXAlignment.Left
            nameInput.ClearTextOnFocus = false
            nameInput.Parent = propertyEditor
            
            -- Clear other elements
            for _, child in ipairs(propertyEditor:GetChildren()) do
                if child:IsA("Frame") or (child:IsA("TextBox") and child ~= nameInput) then
                    child:Destroy()
                end
            end
            
            local confirmButton = StyleGuide.createStyledButton("Add Property", propertyEditor, "success")
            confirmButton.Size = UDim2.new(0.5, -15, 0, 30)
            confirmButton.Position = UDim2.new(0, 10, 0, 50)
            
            local cancelButton = StyleGuide.createStyledButton("Cancel", propertyEditor, "default")
            cancelButton.Size = UDim2.new(0.5, -15, 0, 30)
            cancelButton.Position = UDim2.new(0.5, 5, 0, 50)
            
            confirmButton.MouseButton1Click:Connect(function()
                local propName = nameInput.Text
                if propName and propName ~= "" then
                    -- Create the property in the schema tree
                    createPropertyUI(treeContainer, propName, "string", false, "")
                    
                    -- Clear property editor
                    for _, child in ipairs(propertyEditor:GetChildren()) do
                        if child:IsA("Frame") or child:IsA("TextBox") then
                            child:Destroy()
                        end
                    end
                    
                    -- Update currentSchema
                    currentSchema[propName] = {
                        type = "string",
                        required = false
                    }
                end
            end)
            
            cancelButton.MouseButton1Click:Connect(function()
                -- Clear property editor
                for _, child in ipairs(propertyEditor:GetChildren()) do
                    if child:IsA("Frame") or child:IsA("TextBox") then
                        child:Destroy()
                    end
                end
            end)
        end)
        
        -- Add existing properties
        for propName, propInfo in pairs(currentSchema) do
            if type(propInfo) == "table" then
                createPropertyUI(
                    treeContainer,
                    propName,
                    propInfo.type or "string",
                    propInfo.required or false,
                    propInfo.default
                )
            end
        end
    end
    
    -- Function to build schema from UI
    local function buildSchemaFromUI()
        local schema = {}
        
        for _, node in ipairs(treeContainer:GetChildren()) do
            if node:IsA("Frame") and node ~= treeContainer:FindFirstChild("UIListLayout") then
                -- Skip the root node
                if node:FindFirstChild("TextLabel") and node:FindFirstChild("TextLabel").Text == "Root Schema" then
                    continue
                end
                
                local nameLabel = node:FindFirstChild("TextLabel")
                local typeDropdown = node:FindFirstChildWhichIsA("Frame", true)
                local requiredToggle = node:FindFirstChild("TextButton", true)
                local defaultValueInput = node:FindFirstChild("TextBox")
                
                if nameLabel and typeDropdown then
                    local propName = nameLabel.Text
                    local propType = typeDropdown:GetAttribute("SelectedOption") or "string"
                    local required = requiredToggle and requiredToggle:GetAttribute("IsChecked") or false
                    local defaultValue = defaultValueInput and defaultValueInput.Text or nil
                    
                    -- Convert default value to appropriate type
                    if defaultValue and defaultValue ~= "" then
                        if propType == "number" then
                            defaultValue = tonumber(defaultValue) or 0
                        elseif propType == "boolean" then
                            defaultValue = defaultValue:lower() == "true"
                        elseif propType == "table" or propType == "array" then
                            local success, result = pcall(function()
                                return game:GetService("HttpService"):JSONDecode(defaultValue)
                            end)
                            defaultValue = success and result or {}
                        end
                    else
                        defaultValue = nil
                    end
                    
                    schema[propName] = {
                        type = propType,
                        required = required
                    }
                    
                    if defaultValue ~= nil then
                        schema[propName].default = defaultValue
                    end
                end
            end
        end
        
        return schema
    end
    
    -- Save button handler
    saveButton.MouseButton1Click:Connect(function()
        local schema = buildSchemaFromUI()
        local success = SchemaManager.saveSchema(dataStoreName, keyName, schema)
        
        if success then
            showStatus("Schema saved successfully", false)
        else
            showStatus("Failed to save schema", true)
        end
    end)
    
    -- Validate button handler
    validateButton.MouseButton1Click:Connect(function()
        local schema = buildSchemaFromUI()
        
        -- Let's test with some sample data
        local sampleData = {}
        
        for propName, propInfo in pairs(schema) do
            local propType = propInfo.type or "string"
            
            if propType == "string" then
                sampleData[propName] = "Example string"
            elseif propType == "number" then
                sampleData[propName] = 123
            elseif propType == "boolean" then
                sampleData[propName] = true
            elseif propType == "table" or propType == "array" then
                sampleData[propName] = propType == "array" and {1, 2, 3} or {key = "value"}
            end
        end
        
        -- Validate sample data against schema
        local isValid, validationResult = SchemaValidator.validate(sampleData, schema)
        
        if isValid then
            showStatus("Schema is valid!", false)
        else
            showStatus("Schema validation failed: " .. validationResult, true)
        end
    end)
    
    -- Export button handler
    exportButton.MouseButton1Click:Connect(function()
        local schema = buildSchemaFromUI()
        local jsonSchema = game:GetService("HttpService"):JSONEncode(schema)
        
        -- Create export dialog
        local exportDialog = Instance.new("Frame")
        exportDialog.Size = UDim2.new(0.8, 0, 0.8, 0)
        exportDialog.Position = UDim2.new(0.1, 0, 0.1, 0)
        exportDialog.BackgroundColor3 = StyleGuide.Colors.Secondary
        exportDialog.BorderColor3 = StyleGuide.Colors.Border
        exportDialog.ZIndex = 100
        exportDialog.Parent = container
        
        local exportTitle = Instance.new("TextLabel")
        exportTitle.Size = UDim2.new(1, 0, 0, 30)
        exportTitle.BackgroundColor3 = StyleGuide.Colors.Accent
        exportTitle.BorderSizePixel = 0
        exportTitle.Text = "Export Schema"
        exportTitle.TextColor3 = StyleGuide.Colors.TextPrimary
        exportTitle.Font = StyleGuide.Fonts.Heading
        exportTitle.TextSize = StyleGuide.FontSizes.Heading
        exportTitle.ZIndex = 100
        exportTitle.Parent = exportDialog
        
        local exportBox = Instance.new("TextBox")
        exportBox.Size = UDim2.new(1, -20, 1, -80)
        exportBox.Position = UDim2.new(0, 10, 0, 40)
        exportBox.BackgroundColor3 = StyleGuide.Colors.Input
        exportBox.BorderColor3 = StyleGuide.Colors.Border
        exportBox.TextColor3 = StyleGuide.Colors.TextPrimary
        exportBox.TextWrapped = true
        exportBox.TextXAlignment = Enum.TextXAlignment.Left
        exportBox.TextYAlignment = Enum.TextYAlignment.Top
        exportBox.Text = jsonSchema
        exportBox.Font = Enum.Font.Code
        exportBox.TextSize = StyleGuide.FontSizes.Small
        exportBox.ClearTextOnFocus = false
        exportBox.MultiLine = true
        exportBox.ZIndex = 100
        exportBox.Parent = exportDialog
        
        local closeButton = StyleGuide.createStyledButton("Close", exportDialog, "primary")
        closeButton.Size = UDim2.new(0.5, -15, 0, 30)
        closeButton.Position = UDim2.new(0.25, 5, 1, -35)
        closeButton.ZIndex = 100
        
        closeButton.MouseButton1Click:Connect(function()
            exportDialog:Destroy()
        end)
    end)
    
    -- Import button handler
    importButton.MouseButton1Click:Connect(function()
        -- Create import dialog
        local importDialog = Instance.new("Frame")
        importDialog.Size = UDim2.new(0.8, 0, 0.8, 0)
        importDialog.Position = UDim2.new(0.1, 0, 0.1, 0)
        importDialog.BackgroundColor3 = StyleGuide.Colors.Secondary
        importDialog.BorderColor3 = StyleGuide.Colors.Border
        importDialog.ZIndex = 100
        importDialog.Parent = container
        
        local importTitle = Instance.new("TextLabel")
        importTitle.Size = UDim2.new(1, 0, 0, 30)
        importTitle.BackgroundColor3 = StyleGuide.Colors.Accent
        importTitle.BorderSizePixel = 0
        importTitle.Text = "Import Schema"
        importTitle.TextColor3 = StyleGuide.Colors.TextPrimary
        importTitle.Font = StyleGuide.Fonts.Heading
        importTitle.TextSize = StyleGuide.FontSizes.Heading
        importTitle.ZIndex = 100
        importTitle.Parent = importDialog
        
        local importBox = Instance.new("TextBox")
        importBox.Size = UDim2.new(1, -20, 1, -80)
        importBox.Position = UDim2.new(0, 10, 0, 40)
        importBox.BackgroundColor3 = StyleGuide.Colors.Input
        importBox.BorderColor3 = StyleGuide.Colors.Border
        importBox.TextColor3 = StyleGuide.Colors.TextPrimary
        importBox.TextWrapped = true
        importBox.TextXAlignment = Enum.TextXAlignment.Left
        importBox.TextYAlignment = Enum.TextYAlignment.Top
        importBox.PlaceholderText = "Paste JSON schema here..."
        importBox.Font = Enum.Font.Code
        importBox.TextSize = StyleGuide.FontSizes.Small
        importBox.ClearTextOnFocus = false
        importBox.MultiLine = true
        importBox.ZIndex = 100
        importBox.Parent = importDialog
        
        local importButton = StyleGuide.createStyledButton("Import", importDialog, "primary")
        importButton.Size = UDim2.new(0.35, -15, 0, 30)
        importButton.Position = UDim2.new(0.15, 5, 1, -35)
        importButton.ZIndex = 100
        
        local cancelButton = StyleGuide.createStyledButton("Cancel", importDialog, "default")
        cancelButton.Size = UDim2.new(0.35, -15, 0, 30)
        cancelButton.Position = UDim2.new(0.5, 5, 1, -35)
        cancelButton.ZIndex = 100
        
        importButton.MouseButton1Click:Connect(function()
            local success, newSchema = pcall(function()
                return game:GetService("HttpService"):JSONDecode(importBox.Text)
            end)
            
            if success and type(newSchema) == "table" then
                currentSchema = newSchema
                refreshSchemaTree()
                importDialog:Destroy()
                showStatus("Schema imported successfully", false)
            else
                showStatus("Failed to import schema: Invalid JSON", true)
            end
        end)
        
        cancelButton.MouseButton1Click:Connect(function()
            importDialog:Destroy()
        end)
    end)
    
    -- Initialize the schema tree
    refreshSchemaTree()
    
    return container
end

return SchemaEditor
