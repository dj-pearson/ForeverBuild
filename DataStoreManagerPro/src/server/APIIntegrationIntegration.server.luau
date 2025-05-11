--[[
    APIIntegrationIntegration.server.luau
    Part of DataStore Manager Pro
    
    This module integrates API Integration features with the DataExplorer,
    handling the initialization and UI creation.
]]

local APIIntegrationUI = require(script.Parent.APIIntegrationUI)

local APIIntegrationIntegration = {}

-- Initialize the API Integration Integration
function APIIntegrationIntegration.initialize()
    print("APIIntegrationIntegration: Initializing module...")
    
    -- Make sure UI is initialized
    APIIntegrationUI.initialize()
    
    return true
end

-- Initialize the API Integration UI in the provided container
function APIIntegrationIntegration.initAPIIntegrationUI(DataExplorer)
    print("APIIntegrationIntegration: Initializing UI...")
    
    if not DataExplorer then
        warn("APIIntegrationIntegration: DataExplorer not provided for UI initialization")
        return false
    end
    
    -- Create a tab for the API Integration in the content pane
    local contentPane = DataExplorer.contentPane
    if not contentPane then
        warn("APIIntegrationIntegration: Content pane not found")
        return false
    end
    
    -- Create the container for the API Integration UI if it doesn't exist
    if not DataExplorer.apiIntegrationContainer then
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        container.Name = "APIIntegrationContainer"
        container.Visible = false
        container.Parent = contentPane
        DataExplorer.apiIntegrationContainer = container
    end
    
    -- Create a tab button for the API Integration
    if DataExplorer.createTabButton then
        DataExplorer.createTabButton("API Integration", function()
            -- Hide all other content panes
            for _, child in ipairs(contentPane:GetChildren()) do
                if child:IsA("Frame") and child.Name:match("Container$") then
                    child.Visible = false
                end
            end
            
            -- Show the API Integration container
            DataExplorer.apiIntegrationContainer.Visible = true
        end)
    end
    
    -- Create the UI in the container
    APIIntegrationUI.createUI(DataExplorer.apiIntegrationContainer)
    
    return true
end

-- Get all configured webhooks
function APIIntegrationIntegration.getWebhooks()
    local APIIntegration = require(script.Parent.APIIntegration)
    return APIIntegration.getWebhooks()
end

-- Configure a webhook
function APIIntegrationIntegration.configureWebhook(name, config)
    local APIIntegration = require(script.Parent.APIIntegration)
    return APIIntegration.configureWebhook(name, config)
end

-- Configure Open Cloud API
function APIIntegrationIntegration.configureOpenCloudAPI(config)
    local APIIntegration = require(script.Parent.APIIntegration)
    return APIIntegration.configureOpenCloudAPI(config)
end

-- Trigger a webhook event
function APIIntegrationIntegration.triggerWebhook(name, event, data)
    local APIIntegration = require(script.Parent.APIIntegration)
    return APIIntegration.triggerWebhook(name, event, data)
end

return APIIntegrationIntegration
