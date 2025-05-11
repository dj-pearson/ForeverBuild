--[[
    AccessControlIntegration.server.luau
    Part of DataStore Manager Pro
    
    This module integrates the Access Control feature with the DataExplorer,
    connecting the UI and functionality to the main plugin interface.
]]

local AccessControl = require(script.Parent.AccessControl)
local AccessControlUI = require(script.Parent.AccessControlUI)

local AccessControlIntegration = {}

-- Initialize the integration
function AccessControlIntegration.initialize(dataExplorer)
    print("AccessControlIntegration: Initializing...")
    
    -- Initialize the AccessControl module
    AccessControl.initialize()
    
    -- Create a tab in the DataExplorer for Access Control
    AccessControlIntegration.createAccessControlTab(dataExplorer)
    
    return true
end

-- Create the Access Control tab in the DataExplorer
function AccessControlIntegration.createAccessControlTab(dataExplorer)
    -- Add a reference for the Access Control UI container
    dataExplorer.accessControlContainer = nil
    
    -- Create the tab button
    local tabButton = dataExplorer.createTab("Access Control", "rbxassetid://131528732541")
    
    -- Connect the tab button click event
    tabButton.MouseButton1Click:Connect(function()
        dataExplorer.showTab("Access Control")
        
        -- Create the container if it doesn't exist
        if not dataExplorer.accessControlContainer then
            local container = Instance.new("Frame")
            container.Name = "AccessControlContainer"
            container.BackgroundTransparency = 1
            container.Size = UDim2.new(1, 0, 1, 0)
            container.Parent = dataExplorer.tabContents
            
            -- Initialize the Access Control UI
            AccessControlUI.initialize(container)
            
            -- Store the container reference
            dataExplorer.accessControlContainer = container
        end
    end)
end

-- Check if a user has permission to perform an action
-- This can be called from other parts of the plugin
function AccessControlIntegration.hasPermission(permissionId)
    return AccessControl.hasPermission(nil, permissionId)
end

-- Log an action for audit purposes
-- This can be called from other parts of the plugin
function AccessControlIntegration.logAction(action, details)
    return AccessControl.logAction(nil, action, details)
end

return AccessControlIntegration
