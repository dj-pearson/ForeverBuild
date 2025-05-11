--luau
-- DataStore Plugin/SchemaBuilder.luau
-- DataStore Plugin/SchemaBuilder.luau

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

local SchemaManager = resolveModule('SchemaManager')

local SchemaBuilder = {}

function SchemaBuilder.createUI()
    -- Create the main frame for the Schema Builder widget
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 600) -- Example size for a widget
    mainFrame.Name = "SchemaBuilderFrame"

    -- Add a title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.Text = "Schema Builder"
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 18
    titleLabel.TextColor3 = Color3.new(1,1,1)
    titleLabel.Parent = mainFrame

    -- Form Frame
    local formFrame = Instance.new("Frame")
    formFrame.Size = UDim2.new(1, -20, 1, -80)
    formFrame.Position = UDim2.new(0, 10, 0, 40)
    formFrame.Parent = mainFrame

    -- Form Layout
    local formLayout = Instance.new("UIListLayout")
    formLayout.FillDirection = Enum.FillDirection.Vertical
    formLayout.SortOrder = Enum.SortOrder.LayoutOrder
    formLayout.Parent = formFrame

    -- Frame for Data Store
    local dataStoreFrame = Instance.new("Frame")
    dataStoreFrame.Size = UDim2.new(1, 0, 0, 30)
    dataStoreFrame.BackgroundTransparency = 1
    dataStoreFrame.Parent = formFrame

    local dataStoreLabel = Instance.new("TextLabel")
    dataStoreLabel.Size = UDim2.new(0.3, 0, 1, 0)
    dataStoreLabel.Text = "Data Store Name"
    dataStoreLabel.Parent = dataStoreFrame

    local dataStoreInput = Instance.new("TextBox")
    dataStoreInput.Size = UDim2.new(0.7, 0, 1, 0)
    dataStoreInput.Position = UDim2.new(0.3, 0, 0, 0)
    dataStoreInput.PlaceholderText = "Enter Data Store Name"
    dataStoreInput.Parent = dataStoreFrame

    -- Key Frame
    local keyFrame = Instance.new("Frame")
    keyFrame.Size = UDim2.new(1, 0, 0, 30)
    keyFrame.BackgroundTransparency = 1
    keyFrame.Parent = formFrame

    local formLayout = Instance.new("UIListLayout")
    formLayout.FillDirection = Enum.FillDirection.Vertical
    formLayout.SortOrder = Enum.SortOrder.LayoutOrder
    formLayout.Parent = formFrame

    -- Create InputFields table to hold created fields
    local inputFields = {}
    
    local keyLabel = Instance.new("TextLabel")
    keyLabel.Size = UDim2.new(0.3, 0, 1, 0)
    keyLabel.Text = "Key Name"
    keyLabel.Parent = keyFrame

    local keyInput = Instance.new("TextBox")
    keyInput.Size = UDim2.new(0.7, 0, 1, 0)
    keyInput.Position = UDim2.new(0.3, 0, 0, 0)
    keyInput.PlaceholderText = "Enter Key Name"
    keyInput.Parent = keyFrame

    local function createInputField(keyName, dataType)
        local inputFrame = Instance.new("Frame")
        local dataInput = Instance.new("TextBox")
        dataInput.Size = UDim2.new(0.7, 0, 1, 0)
        dataInput.Position = UDim2.new(0.3, 0, 0, 0)
        dataInput.PlaceholderText = dataType
        dataInput.Parent = inputFrame
        
        return dataInput
    end

    -- Frame for buttons
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, 0, 0, 40)
    buttonFrame.Position = UDim2.new(0, 0, 1, -40)
    buttonFrame.Parent = mainFrame

    -- Button Layout
    
    local buttonLayout = Instance.new("UIListLayout")
    buttonLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    buttonLayout.Padding = UDim.new(0, 5)
    buttonLayout.Parent = buttonFrame

    -- New Schema button
    local newSchemaButton = Instance.new("TextButton")
    newSchemaButton.Size = UDim2.new(0.5, -10, 1, 0)
    newSchemaButton.Name = "NewSchema"
    newSchemaButton.Text = "New Schema"
    newSchemaButton.Parent = buttonFrame

    -- Save Schema button
    local saveSchemaButton = Instance.new("TextButton")
    saveSchemaButton.Size = UDim2.new(0.5, -10, 1, 0)
    saveSchemaButton.Name = "SaveSchema"
    saveSchemaButton.Text = "Save Schema"
    saveSchemaButton.Parent = buttonFrame

    --create test fields
    inputFields["testKey1"] = createInputField("testKey1","string")
    inputFields["testKey2"] = createInputField("testKey2","number")
    inputFields["testKey3"] = createInputField("testKey3","boolean")
    
    
    local function clearForm()
        for _, child in ipairs(formFrame:GetChildren()) do
            child:Destroy()
        end
        inputFields = {}
    end
    
    -- Connect button events
    newSchemaButton.MouseButton1Click:Connect(function()
        print("New Schema button clicked")
        clearForm()
    end)

    saveSchemaButton.MouseButton1Click:Connect(function()
        print("Save Schema button clicked")
        -- Construct the schema data from input fields
        local schemaData = {}
        for key, field in pairs(inputFields) do
            local type = field.PlaceholderText
            schemaData[key] = type
        end

        local dataStoreName = dataStoreInput.Text
        local keyName = keyInput.Text
        
        if dataStoreName ~= "" and keyName ~= "" then
            SchemaManager.saveSchema(schemaData, dataStoreName, keyName)
        else
            print("Error: Data Store name and key name are required.")
        end
    end)

    return mainFrame
end

return SchemaBuilder