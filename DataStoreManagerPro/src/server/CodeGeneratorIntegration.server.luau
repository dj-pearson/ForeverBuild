--[[
    CodeGeneratorIntegration.server.luau
    Part of DataStore Manager Pro
    
    This module integrates the Code Generator feature with the DataExplorer,
    allowing seamless access to code generation functionality.
]]

local CodeGeneratorUI = require(script.Parent.CodeGeneratorUI)

local CodeGeneratorIntegration = {}

-- Initialize the Code Generator Integration
function CodeGeneratorIntegration.initialize()
    print("CodeGeneratorIntegration: Initializing module...")
    
    -- Make sure UI is initialized
    CodeGeneratorUI.initialize()
    
    return true
end

-- Initialize the Code Generator UI in the provided container
function CodeGeneratorIntegration.initCodeGeneratorUI(DataExplorer)
    print("CodeGeneratorIntegration: Initializing UI...")
    
    if not DataExplorer then
        warn("CodeGeneratorIntegration: DataExplorer not provided for UI initialization")
        return false
    end
    
    -- Create a tab for the Code Generator in the content pane
    local contentPane = DataExplorer.contentPane
    if not contentPane then
        warn("CodeGeneratorIntegration: Content pane not found")
        return false
    end
    
    -- Create the container for the Code Generator UI if it doesn't exist
    if not DataExplorer.codeGeneratorContainer then
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        container.Name = "CodeGeneratorContainer"
        container.Visible = false
        container.Parent = contentPane
        DataExplorer.codeGeneratorContainer = container
    end
    
    -- Create a tab button for the Code Generator
    if DataExplorer.createTabButton then
        DataExplorer.createTabButton("Code Generator", function()
            -- Hide all other content panes
            for _, child in ipairs(contentPane:GetChildren()) do
                if child:IsA("Frame") and child.Name:match("Container$") then
                    child.Visible = false
                end
            end
            
            -- Show the Code Generator container
            DataExplorer.codeGeneratorContainer.Visible = true
        end)
    end
    
    -- Create the UI in the container
    CodeGeneratorUI.createUI(DataExplorer.codeGeneratorContainer)
    
    return true
end

-- Generate code from a schema with the specified options
function CodeGeneratorIntegration.generateCode(schemaName, options)
    local CodeGenerator = require(script.Parent.CodeGenerator)
    
    return CodeGenerator.generateModuleFromSchema(schemaName, options)
end

-- Get available templates for a specific module type
function CodeGeneratorIntegration.getTemplates(moduleType)
    local CodeGenerator = require(script.Parent.CodeGenerator)
    
    moduleType = moduleType or "module"
    
    if CodeGenerator.templates[moduleType] then
        local templates = {}
        for templateName, _ in pairs(CodeGenerator.templates[moduleType]) do
            table.insert(templates, templateName)
        end
        return templates
    end
    
    return {"default"} -- Default template always exists
end

return CodeGeneratorIntegration
