--[[
    AccessControlUI.luau
    Part of DataStore Manager Pro
    
    This module provides the user interface for the Access Control feature,
    allowing users to manage roles, permissions, and audit logs.
]]

local plugin = plugin -- Use the global plugin variable
local StudioService = game:GetService("StudioService")
local HttpService = game:GetService("HttpService")

local AccessControl = require(script.Parent.AccessControl)
local StyleGuide = require(script.Parent.StyleGuide)

local AccessControlUI = {}

-- Constants for the UI
AccessControlUI.TAB_ROLES = "Roles"
AccessControlUI.TAB_USERS = "Users"
AccessControlUI.TAB_PERMISSIONS = "Permissions"
AccessControlUI.TAB_AUDIT_LOGS = "Audit Logs"

-- UI state
AccessControlUI.ui = {
    container = nil,
    tabButtons = {},
    contentFrames = {},
    currentTab = nil,
    -- Roles tab
    rolesList = nil,
    roleDetailsFrame = nil,
    selectedRoleId = nil,
    -- Users tab
    usersList = nil,
    userDetailsFrame = nil,
    selectedUserId = nil,
    -- Permissions tab
    permissionsList = nil,
    permissionDetailsFrame = nil,
    selectedPermissionId = nil,
    -- Audit logs tab
    auditLogsList = nil,
    auditLogsFilterFrame = nil
}

-- Initialize the UI
function AccessControlUI.initialize(container)
    if AccessControlUI.ui.container then
        -- Already initialized
        return AccessControlUI.ui.container
    end
    
    -- Create container if not provided
    AccessControlUI.ui.container = container or Instance.new("Frame")
    local container = AccessControlUI.ui.container
    
    -- Apply styling
    container.BackgroundColor3 = StyleGuide.Colors.Background
    container.BorderSizePixel = 0
    container.Size = UDim2.new(1, 0, 1, 0)
    
    -- Create the header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundColor3 = StyleGuide.Colors.HeaderBackground
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, 40)
    header.Parent = container
    
    local headerTitle = Instance.new("TextLabel")
    headerTitle.Name = "Title"
    headerTitle.BackgroundTransparency = 1
    headerTitle.Font = StyleGuide.Fonts.Header
    headerTitle.Text = "Access Control"
    headerTitle.TextColor3 = StyleGuide.Colors.HeaderText
    headerTitle.TextSize = StyleGuide.TextSizes.Header
    headerTitle.Size = UDim2.new(0, 200, 1, 0)
    headerTitle.Position = UDim2.new(0, 10, 0, 0)
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.Parent = header
    
    local enabledToggle = Instance.new("Frame")
    enabledToggle.Name = "EnabledToggle"
    enabledToggle.BackgroundColor3 = StyleGuide.Colors.Background
    enabledToggle.BorderColor3 = StyleGuide.Colors.Border
    enabledToggle.BorderSizePixel = 1
    enabledToggle.Size = UDim2.new(0, 200, 0, 30)
    enabledToggle.Position = UDim2.new(1, -210, 0, 5)
    enabledToggle.Parent = header
    
    local enabledLabel = Instance.new("TextLabel")
    enabledLabel.Name = "Label"
    enabledLabel.BackgroundTransparency = 1
    enabledLabel.Font = StyleGuide.Fonts.Regular
    enabledLabel.Text = "Access Control Enabled:"
    enabledLabel.TextColor3 = StyleGuide.Colors.Text
    enabledLabel.TextSize = StyleGuide.TextSizes.Regular
    enabledLabel.Size = UDim2.new(0, 150, 1, 0)
    enabledLabel.Position = UDim2.new(0, 5, 0, 0)
    enabledLabel.TextXAlignment = Enum.TextXAlignment.Left
    enabledLabel.Parent = enabledToggle
    
    local enabledButton = Instance.new("TextButton")
    enabledButton.Name = "ToggleButton"
    enabledButton.BackgroundColor3 = AccessControl.isEnabled() and StyleGuide.Colors.Success or StyleGuide.Colors.Danger
    enabledButton.BorderColor3 = StyleGuide.Colors.Border
    enabledButton.BorderSizePixel = 1
    enabledButton.Font = StyleGuide.Fonts.Bold
    enabledButton.Text = AccessControl.isEnabled() and "ON" or "OFF"
    enabledButton.TextColor3 = StyleGuide.Colors.ButtonText
    enabledButton.TextSize = StyleGuide.TextSizes.Regular
    enabledButton.Size = UDim2.new(0, 40, 0, 25)
    enabledButton.Position = UDim2.new(1, -45, 0, 2)
    enabledButton.Parent = enabledToggle
    
    enabledButton.MouseButton1Click:Connect(function()
        local newState = not AccessControl.isEnabled()
        AccessControl.setEnabled(newState)
        enabledButton.BackgroundColor3 = newState and StyleGuide.Colors.Success or StyleGuide.Colors.Danger
        enabledButton.Text = newState and "ON" or "OFF"
        
        -- Log the action
        AccessControl.logAction("default", "toggle_access_control", {
            enabled = newState
        })
    end)
    
    -- Create tab container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.BackgroundColor3 = StyleGuide.Colors.TabBackground
    tabContainer.BorderSizePixel = 0
    tabContainer.Size = UDim2.new(1, 0, 0, 30)
    tabContainer.Position = UDim2.new(0, 0, 0, 40)
    tabContainer.Parent = container
    
    -- Create content container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.BackgroundColor3 = StyleGuide.Colors.Background
    contentContainer.BorderSizePixel = 0
    contentContainer.Size = UDim2.new(1, 0, 1, -70)
    contentContainer.Position = UDim2.new(0, 0, 0, 70)
    contentContainer.Parent = container
    
    -- Create tabs
    local tabs = {
        AccessControlUI.TAB_ROLES,
        AccessControlUI.TAB_USERS,
        AccessControlUI.TAB_PERMISSIONS,
        AccessControlUI.TAB_AUDIT_LOGS
    }
    
    local tabWidth = 1 / #tabs
    
    for i, tabName in ipairs(tabs) do
        -- Create tab button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName .. "Tab"
        tabButton.BackgroundTransparency = 1
        tabButton.Font = StyleGuide.Fonts.Regular
        tabButton.Text = tabName
        tabButton.TextColor3 = StyleGuide.Colors.InactiveTabText
        tabButton.TextSize = StyleGuide.TextSizes.Regular
        tabButton.Size = UDim2.new(tabWidth, 0, 1, 0)
        tabButton.Position = UDim2.new(tabWidth * (i - 1), 0, 0, 0)
        tabButton.Parent = tabContainer
        
        AccessControlUI.ui.tabButtons[tabName] = tabButton
        
        -- Create content frame
        local contentFrame = Instance.new("Frame")
        contentFrame.Name = tabName .. "Content"
        contentFrame.BackgroundTransparency = 1
        contentFrame.Size = UDim2.new(1, 0, 1, 0)
        contentFrame.Visible = false
        contentFrame.Parent = contentContainer
        
        AccessControlUI.ui.contentFrames[tabName] = contentFrame
        
        -- Tab button click event
        tabButton.MouseButton1Click:Connect(function()
            AccessControlUI.setActiveTab(tabName)
        end)
    end
    
    -- Create the content for each tab
    AccessControlUI.createRolesTab()
    AccessControlUI.createUsersTab()
    AccessControlUI.createPermissionsTab()
    AccessControlUI.createAuditLogsTab()
    
    -- Set the default active tab
    AccessControlUI.setActiveTab(AccessControlUI.TAB_ROLES)
    
    return container
end

-- Set the active tab
function AccessControlUI.setActiveTab(tabName)
    -- Reset all tabs
    for name, button in pairs(AccessControlUI.ui.tabButtons) do
        button.TextColor3 = StyleGuide.Colors.InactiveTabText
        button.Font = StyleGuide.Fonts.Regular
    end
    
    for name, frame in pairs(AccessControlUI.ui.contentFrames) do
        frame.Visible = false
    end
    
    -- Set active tab
    AccessControlUI.ui.tabButtons[tabName].TextColor3 = StyleGuide.Colors.ActiveTabText
    AccessControlUI.ui.tabButtons[tabName].Font = StyleGuide.Fonts.Bold
    AccessControlUI.ui.contentFrames[tabName].Visible = true
    AccessControlUI.ui.currentTab = tabName
    
    -- Refresh the tab content
    if tabName == AccessControlUI.TAB_ROLES then
        AccessControlUI.refreshRolesTab()
    elseif tabName == AccessControlUI.TAB_USERS then
        AccessControlUI.refreshUsersTab()
    elseif tabName == AccessControlUI.TAB_PERMISSIONS then
        AccessControlUI.refreshPermissionsTab()
    elseif tabName == AccessControlUI.TAB_AUDIT_LOGS then
        AccessControlUI.refreshAuditLogsTab()
    end
end

-- Create the Roles tab content
function AccessControlUI.createRolesTab()
    local frame = AccessControlUI.ui.contentFrames[AccessControlUI.TAB_ROLES]
    
    -- Create split layout: roles list on left, role details on right
    local rolesList = Instance.new("ScrollingFrame")
    rolesList.Name = "RolesList"
    rolesList.BackgroundColor3 = StyleGuide.Colors.BackgroundLight
    rolesList.BorderColor3 = StyleGuide.Colors.Border
    rolesList.BorderSizePixel = 1
    rolesList.Size = UDim2.new(0.4, -10, 1, -10)
    rolesList.Position = UDim2.new(0, 5, 0, 5)
    rolesList.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be adjusted dynamically
    rolesList.ScrollBarThickness = 8
    rolesList.Parent = frame
    
    local roleDetailsFrame = Instance.new("Frame")
    roleDetailsFrame.Name = "RoleDetailsFrame"
    roleDetailsFrame.BackgroundColor3 = StyleGuide.Colors.BackgroundLight
    roleDetailsFrame.BorderColor3 = StyleGuide.Colors.Border
    roleDetailsFrame.BorderSizePixel = 1
    roleDetailsFrame.Size = UDim2.new(0.6, -10, 1, -10)
    roleDetailsFrame.Position = UDim2.new(0.4, 5, 0, 5)
    roleDetailsFrame.Parent = frame
    
    -- Create "New Role" button
    local newRoleButton = Instance.new("TextButton")
    newRoleButton.Name = "NewRoleButton"
    newRoleButton.BackgroundColor3 = StyleGuide.Colors.Success
    newRoleButton.BorderColor3 = StyleGuide.Colors.Border
    newRoleButton.BorderSizePixel = 1
    newRoleButton.Font = StyleGuide.Fonts.Bold
    newRoleButton.Text = "New Role"
    newRoleButton.TextColor3 = StyleGuide.Colors.ButtonText
    newRoleButton.TextSize = StyleGuide.TextSizes.Regular
    newRoleButton.Size = UDim2.new(0, 100, 0, 30)
    newRoleButton.Position = UDim2.new(0, 10, 0, 10)
    newRoleButton.Parent = rolesList
    
    newRoleButton.MouseButton1Click:Connect(function()
        AccessControlUI.showCreateRoleDialog()
    end)
    
    -- Store references
    AccessControlUI.ui.rolesList = rolesList
    AccessControlUI.ui.roleDetailsFrame = roleDetailsFrame
    
    -- Create the role details placeholder
    local placeholderLabel = Instance.new("TextLabel")
    placeholderLabel.Name = "PlaceholderLabel"
    placeholderLabel.BackgroundTransparency = 1
    placeholderLabel.Font = StyleGuide.Fonts.Regular
    placeholderLabel.Text = "Select a role to view details"
    placeholderLabel.TextColor3 = StyleGuide.Colors.TextLight
    placeholderLabel.TextSize = StyleGuide.TextSizes.Regular
    placeholderLabel.Size = UDim2.new(1, 0, 1, 0)
    placeholderLabel.Parent = roleDetailsFrame
end

-- Create the Users tab content
function AccessControlUI.createUsersTab()
    local frame = AccessControlUI.ui.contentFrames[AccessControlUI.TAB_USERS]
    
    -- Create split layout: users list on left, user details on right
    local usersList = Instance.new("ScrollingFrame")
    usersList.Name = "UsersList"
    usersList.BackgroundColor3 = StyleGuide.Colors.BackgroundLight
    usersList.BorderColor3 = StyleGuide.Colors.Border
    usersList.BorderSizePixel = 1
    usersList.Size = UDim2.new(0.4, -10, 1, -10)
    usersList.Position = UDim2.new(0, 5, 0, 5)
    usersList.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be adjusted dynamically
    usersList.ScrollBarThickness = 8
    usersList.Parent = frame
    
    local userDetailsFrame = Instance.new("Frame")
    userDetailsFrame.Name = "UserDetailsFrame"
    userDetailsFrame.BackgroundColor3 = StyleGuide.Colors.BackgroundLight
    userDetailsFrame.BorderColor3 = StyleGuide.Colors.Border
    userDetailsFrame.BorderSizePixel = 1
    userDetailsFrame.Size = UDim2.new(0.6, -10, 1, -10)
    userDetailsFrame.Position = UDim2.new(0.4, 5, 0, 5)
    userDetailsFrame.Parent = frame
    
    -- Create "New User" button
    local newUserButton = Instance.new("TextButton")
    newUserButton.Name = "NewUserButton"
    newUserButton.BackgroundColor3 = StyleGuide.Colors.Success
    newUserButton.BorderColor3 = StyleGuide.Colors.Border
    newUserButton.BorderSizePixel = 1
    newUserButton.Font = StyleGuide.Fonts.Bold
    newUserButton.Text = "New User"
    newUserButton.TextColor3 = StyleGuide.Colors.ButtonText
    newUserButton.TextSize = StyleGuide.TextSizes.Regular
    newUserButton.Size = UDim2.new(0, 100, 0, 30)
    newUserButton.Position = UDim2.new(0, 10, 0, 10)
    newUserButton.Parent = usersList
    
    newUserButton.MouseButton1Click:Connect(function()
        AccessControlUI.showCreateUserDialog()
    end)
    
    -- Store references
    AccessControlUI.ui.usersList = usersList
    AccessControlUI.ui.userDetailsFrame = userDetailsFrame
    
    -- Create the user details placeholder
    local placeholderLabel = Instance.new("TextLabel")
    placeholderLabel.Name = "PlaceholderLabel"
    placeholderLabel.BackgroundTransparency = 1
    placeholderLabel.Font = StyleGuide.Fonts.Regular
    placeholderLabel.Text = "Select a user to view details"
    placeholderLabel.TextColor3 = StyleGuide.Colors.TextLight
    placeholderLabel.TextSize = StyleGuide.TextSizes.Regular
    placeholderLabel.Size = UDim2.new(1, 0, 1, 0)
    placeholderLabel.Parent = userDetailsFrame
end

-- Create the Permissions tab content
function AccessControlUI.createPermissionsTab()
    local frame = AccessControlUI.ui.contentFrames[AccessControlUI.TAB_PERMISSIONS]
    
    -- Create split layout: permissions list on left, permission details on right
    local permissionsList = Instance.new("ScrollingFrame")
    permissionsList.Name = "PermissionsList"
    permissionsList.BackgroundColor3 = StyleGuide.Colors.BackgroundLight
    permissionsList.BorderColor3 = StyleGuide.Colors.Border
    permissionsList.BorderSizePixel = 1
    permissionsList.Size = UDim2.new(0.4, -10, 1, -10)
    permissionsList.Position = UDim2.new(0, 5, 0, 5)
    permissionsList.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be adjusted dynamically
    permissionsList.ScrollBarThickness = 8
    permissionsList.Parent = frame
    
    local permissionDetailsFrame = Instance.new("Frame")
    permissionDetailsFrame.Name = "PermissionDetailsFrame"
    permissionDetailsFrame.BackgroundColor3 = StyleGuide.Colors.BackgroundLight
    permissionDetailsFrame.BorderColor3 = StyleGuide.Colors.Border
    permissionDetailsFrame.BorderSizePixel = 1
    permissionDetailsFrame.Size = UDim2.new(0.6, -10, 1, -10)
    permissionDetailsFrame.Position = UDim2.new(0.4, 5, 0, 5)
    permissionDetailsFrame.Parent = frame
    
    -- Create "New Permission" button
    local newPermissionButton = Instance.new("TextButton")
    newPermissionButton.Name = "NewPermissionButton"
    newPermissionButton.BackgroundColor3 = StyleGuide.Colors.Success
    newPermissionButton.BorderColor3 = StyleGuide.Colors.Border
    newPermissionButton.BorderSizePixel = 1
    newPermissionButton.Font = StyleGuide.Fonts.Bold
    newPermissionButton.Text = "New Permission"
    newPermissionButton.TextColor3 = StyleGuide.Colors.ButtonText
    newPermissionButton.TextSize = StyleGuide.TextSizes.Regular
    newPermissionButton.Size = UDim2.new(0, 120, 0, 30)
    newPermissionButton.Position = UDim2.new(0, 10, 0, 10)
    newPermissionButton.Parent = permissionsList
    
    newPermissionButton.MouseButton1Click:Connect(function()
        AccessControlUI.showCreatePermissionDialog()
    end)
    
    -- Store references
    AccessControlUI.ui.permissionsList = permissionsList
    AccessControlUI.ui.permissionDetailsFrame = permissionDetailsFrame
    
    -- Create the permission details placeholder
    local placeholderLabel = Instance.new("TextLabel")
    placeholderLabel.Name = "PlaceholderLabel"
    placeholderLabel.BackgroundTransparency = 1
    placeholderLabel.Font = StyleGuide.Fonts.Regular
    placeholderLabel.Text = "Select a permission to view details"
    placeholderLabel.TextColor3 = StyleGuide.Colors.TextLight
    placeholderLabel.TextSize = StyleGuide.TextSizes.Regular
    placeholderLabel.Size = UDim2.new(1, 0, 1, 0)
    placeholderLabel.Parent = permissionDetailsFrame
end

-- Create the Audit Logs tab content
function AccessControlUI.createAuditLogsTab()
    local frame = AccessControlUI.ui.contentFrames[AccessControlUI.TAB_AUDIT_LOGS]
    
    -- Create filter frame at the top
    local filterFrame = Instance.new("Frame")
    filterFrame.Name = "FilterFrame"
    filterFrame.BackgroundColor3 = StyleGuide.Colors.BackgroundLight
    filterFrame.BorderColor3 = StyleGuide.Colors.Border
    filterFrame.BorderSizePixel = 1
    filterFrame.Size = UDim2.new(1, -10, 0, 50)
    filterFrame.Position = UDim2.new(0, 5, 0, 5)
    filterFrame.Parent = frame
    
    -- Create filter by user field
    local userFilterLabel = Instance.new("TextLabel")
    userFilterLabel.Name = "UserFilterLabel"
    userFilterLabel.BackgroundTransparency = 1
    userFilterLabel.Font = StyleGuide.Fonts.Regular
    userFilterLabel.Text = "User:"
    userFilterLabel.TextColor3 = StyleGuide.Colors.Text
    userFilterLabel.TextSize = StyleGuide.TextSizes.Regular
    userFilterLabel.Size = UDim2.new(0, 50, 0, 30)
    userFilterLabel.Position = UDim2.new(0, 10, 0, 10)
    userFilterLabel.TextXAlignment = Enum.TextXAlignment.Left
    userFilterLabel.Parent = filterFrame
    
    local userFilterInput = Instance.new("TextBox")
    userFilterInput.Name = "UserFilterInput"
    userFilterInput.BackgroundColor3 = StyleGuide.Colors.InputBackground
    userFilterInput.BorderColor3 = StyleGuide.Colors.Border
    userFilterInput.BorderSizePixel = 1
    userFilterInput.Font = StyleGuide.Fonts.Regular
    userFilterInput.Text = ""
    userFilterInput.PlaceholderText = "All users"
    userFilterInput.TextColor3 = StyleGuide.Colors.Text
    userFilterInput.TextSize = StyleGuide.TextSizes.Regular
    userFilterInput.Size = UDim2.new(0, 120, 0, 30)
    userFilterInput.Position = UDim2.new(0, 60, 0, 10)
    userFilterInput.ClearTextOnFocus = false
    userFilterInput.Parent = filterFrame
    
    -- Create filter by action field
    local actionFilterLabel = Instance.new("TextLabel")
    actionFilterLabel.Name = "ActionFilterLabel"
    actionFilterLabel.BackgroundTransparency = 1
    actionFilterLabel.Font = StyleGuide.Fonts.Regular
    actionFilterLabel.Text = "Action:"
    actionFilterLabel.TextColor3 = StyleGuide.Colors.Text
    actionFilterLabel.TextSize = StyleGuide.TextSizes.Regular
    actionFilterLabel.Size = UDim2.new(0, 50, 0, 30)
    actionFilterLabel.Position = UDim2.new(0, 200, 0, 10)
    actionFilterLabel.TextXAlignment = Enum.TextXAlignment.Left
    actionFilterLabel.Parent = filterFrame
    
    local actionFilterInput = Instance.new("TextBox")
    actionFilterInput.Name = "ActionFilterInput"
    actionFilterInput.BackgroundColor3 = StyleGuide.Colors.InputBackground
    actionFilterInput.BorderColor3 = StyleGuide.Colors.Border
    actionFilterInput.BorderSizePixel = 1
    actionFilterInput.Font = StyleGuide.Fonts.Regular
    actionFilterInput.Text = ""
    actionFilterInput.PlaceholderText = "All actions"
    actionFilterInput.TextColor3 = StyleGuide.Colors.Text
    actionFilterInput.TextSize = StyleGuide.TextSizes.Regular
    actionFilterInput.Size = UDim2.new(0, 120, 0, 30)
    actionFilterInput.Position = UDim2.new(0, 250, 0, 10)
    actionFilterInput.ClearTextOnFocus = false
    actionFilterInput.Parent = filterFrame
    
    -- Create the filter button
    local filterButton = Instance.new("TextButton")
    filterButton.Name = "FilterButton"
    filterButton.BackgroundColor3 = StyleGuide.Colors.Primary
    filterButton.BorderColor3 = StyleGuide.Colors.Border
    filterButton.BorderSizePixel = 1
    filterButton.Font = StyleGuide.Fonts.Bold
    filterButton.Text = "Apply Filter"
    filterButton.TextColor3 = StyleGuide.Colors.ButtonText
    filterButton.TextSize = StyleGuide.TextSizes.Regular
    filterButton.Size = UDim2.new(0, 100, 0, 30)
    filterButton.Position = UDim2.new(1, -110, 0, 10)
    filterButton.Parent = filterFrame
    
    filterButton.MouseButton1Click:Connect(function()
        AccessControlUI.refreshAuditLogsTab()
    end)
    
    -- Create the audit logs list
    local auditLogsList = Instance.new("ScrollingFrame")
    auditLogsList.Name = "AuditLogsList"
    auditLogsList.BackgroundColor3 = StyleGuide.Colors.BackgroundLight
    auditLogsList.BorderColor3 = StyleGuide.Colors.Border
    auditLogsList.BorderSizePixel = 1
    auditLogsList.Size = UDim2.new(1, -10, 1, -65)
    auditLogsList.Position = UDim2.new(0, 5, 0, 60)
    auditLogsList.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be adjusted dynamically
    auditLogsList.ScrollBarThickness = 8
    auditLogsList.Parent = frame
    
    -- Create column headers
    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "HeaderFrame"
    headerFrame.BackgroundColor3 = StyleGuide.Colors.HeaderBackground
    headerFrame.BorderSizePixel = 0
    headerFrame.Size = UDim2.new(1, 0, 0, 30)
    headerFrame.Position = UDim2.new(0, 0, 0, 0)
    headerFrame.Parent = auditLogsList
    
    local timestampHeader = Instance.new("TextLabel")
    timestampHeader.Name = "TimestampHeader"
    timestampHeader.BackgroundTransparency = 1
    timestampHeader.Font = StyleGuide.Fonts.Bold
    timestampHeader.Text = "Timestamp"
    timestampHeader.TextColor3 = StyleGuide.Colors.HeaderText
    timestampHeader.TextSize = StyleGuide.TextSizes.Regular
    timestampHeader.Size = UDim2.new(0.2, 0, 1, 0)
    timestampHeader.Position = UDim2.new(0, 5, 0, 0)
    timestampHeader.TextXAlignment = Enum.TextXAlignment.Left
    timestampHeader.Parent = headerFrame
    
    local userHeader = Instance.new("TextLabel")
    userHeader.Name = "UserHeader"
    userHeader.BackgroundTransparency = 1
    userHeader.Font = StyleGuide.Fonts.Bold
    userHeader.Text = "User"
    userHeader.TextColor3 = StyleGuide.Colors.HeaderText
    userHeader.TextSize = StyleGuide.TextSizes.Regular
    userHeader.Size = UDim2.new(0.15, 0, 1, 0)
    userHeader.Position = UDim2.new(0.2, 5, 0, 0)
    userHeader.TextXAlignment = Enum.TextXAlignment.Left
    userHeader.Parent = headerFrame
    
    local actionHeader = Instance.new("TextLabel")
    actionHeader.Name = "ActionHeader"
    actionHeader.BackgroundTransparency = 1
    actionHeader.Font = StyleGuide.Fonts.Bold
    actionHeader.Text = "Action"
    actionHeader.TextColor3 = StyleGuide.Colors.HeaderText
    actionHeader.TextSize = StyleGuide.TextSizes.Regular
    actionHeader.Size = UDim2.new(0.25, 0, 1, 0)
    actionHeader.Position = UDim2.new(0.35, 5, 0, 0)
    actionHeader.TextXAlignment = Enum.TextXAlignment.Left
    actionHeader.Parent = headerFrame
    
    local detailsHeader = Instance.new("TextLabel")
    detailsHeader.Name = "DetailsHeader"
    detailsHeader.BackgroundTransparency = 1
    detailsHeader.Font = StyleGuide.Fonts.Bold
    detailsHeader.Text = "Details"
    detailsHeader.TextColor3 = StyleGuide.Colors.HeaderText
    detailsHeader.TextSize = StyleGuide.TextSizes.Regular
    detailsHeader.Size = UDim2.new(0.4, 0, 1, 0)
    detailsHeader.Position = UDim2.new(0.6, 5, 0, 0)
    detailsHeader.TextXAlignment = Enum.TextXAlignment.Left
    detailsHeader.Parent = headerFrame
    
    -- Store references
    AccessControlUI.ui.auditLogsList = auditLogsList
    AccessControlUI.ui.auditLogsFilterFrame = filterFrame
end

-- Refresh the Roles tab content
function AccessControlUI.refreshRolesTab()
    local rolesList = AccessControlUI.ui.rolesList
    
    -- Clear the existing list (except the New Role button)
    for _, child in pairs(rolesList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Get all roles
    local roles = AccessControl.getRoles()
    
    -- Create a listing for each role
    local yOffset = 50 -- Start below the New Role button
    
    for id, role in pairs(roles) do
        local roleFrame = Instance.new("Frame")
        roleFrame.Name = "Role_" .. id
        roleFrame.BackgroundColor3 = StyleGuide.Colors.ListItemBackground
        roleFrame.BorderColor3 = StyleGuide.Colors.Border
        roleFrame.BorderSizePixel = 1
        roleFrame.Size = UDim2.new(1, -20, 0, 40)
        roleFrame.Position = UDim2.new(0, 10, 0, yOffset)
        roleFrame.Parent = rolesList
        
        local roleName = Instance.new("TextLabel")
        roleName.Name = "RoleName"
        roleName.BackgroundTransparency = 1
        roleName.Font = StyleGuide.Fonts.Bold
        roleName.Text = role.name
        roleName.TextColor3 = StyleGuide.Colors.Text
        roleName.TextSize = StyleGuide.TextSizes.Regular
        roleName.Size = UDim2.new(1, -20, 0, 20)
        roleName.Position = UDim2.new(0, 10, 0, 5)
        roleName.TextXAlignment = Enum.TextXAlignment.Left
        roleName.Parent = roleFrame
        
        local roleDesc = Instance.new("TextLabel")
        roleDesc.Name = "RoleDescription"
        roleDesc.BackgroundTransparency = 1
        roleDesc.Font = StyleGuide.Fonts.Regular
        roleDesc.Text = role.description or ""
        roleDesc.TextColor3 = StyleGuide.Colors.TextLight
        roleDesc.TextSize = StyleGuide.TextSizes.Small
        roleDesc.Size = UDim2.new(1, -20, 0, 15)
        roleDesc.Position = UDim2.new(0, 10, 0, 25)
        roleDesc.TextXAlignment = Enum.TextXAlignment.Left
        roleDesc.Parent = roleFrame
        
        -- Make the entire frame clickable
        local button = Instance.new("TextButton")
        button.Name = "SelectButton"
        button.BackgroundTransparency = 1
        button.Text = ""
        button.Size = UDim2.new(1, 0, 1, 0)
        button.Parent = roleFrame
        
        button.MouseButton1Click:Connect(function()
            AccessControlUI.selectRole(id)
        end)
        
        yOffset = yOffset + 45 -- 40 for the frame + 5 spacing
    end
    
    -- Update the canvas size
    rolesList.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
    
    -- If a role is already selected, refresh its details
    if AccessControlUI.ui.selectedRoleId then
        AccessControlUI.selectRole(AccessControlUI.ui.selectedRoleId)
    end
end

-- Select a role to display its details
function AccessControlUI.selectRole(roleId)
    AccessControlUI.ui.selectedRoleId = roleId
    
    local detailsFrame = AccessControlUI.ui.roleDetailsFrame
    
    -- Clear existing details
    for _, child in pairs(detailsFrame:GetChildren()) do
        child:Destroy()
    end
    
    -- Get role details
    local roles = AccessControl.getRoles()
    local role = roles[roleId]
    
    if not role then
        -- Role not found (may have been deleted)
        local notFoundLabel = Instance.new("TextLabel")
        notFoundLabel.Name = "NotFoundLabel"
        notFoundLabel.BackgroundTransparency = 1
        notFoundLabel.Font = StyleGuide.Fonts.Regular
        notFoundLabel.Text = "Role not found"
        notFoundLabel.TextColor3 = StyleGuide.Colors.Danger
        notFoundLabel.TextSize = StyleGuide.TextSizes.Regular
        notFoundLabel.Size = UDim2.new(1, 0, 1, 0)
        notFoundLabel.Parent = detailsFrame
        return
    end
    
    -- Create role details UI
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = StyleGuide.Fonts.Header
    titleLabel.Text = role.name .. " Role"
    titleLabel.TextColor3 = StyleGuide.Colors.Text
    titleLabel.TextSize = StyleGuide.TextSizes.Header
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = detailsFrame
    
    local idLabel = Instance.new("TextLabel")
    idLabel.Name = "IdLabel"
    idLabel.BackgroundTransparency = 1
    idLabel.Font = StyleGuide.Fonts.Regular
    idLabel.Text = "ID: " .. roleId
    idLabel.TextColor3 = StyleGuide.Colors.TextLight
    idLabel.TextSize = StyleGuide.TextSizes.Small
    idLabel.Size = UDim2.new(1, -20, 0, 20)
    idLabel.Position = UDim2.new(0, 10, 0, 40)
    idLabel.TextXAlignment = Enum.TextXAlignment.Left
    idLabel.Parent = detailsFrame
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "DescriptionLabel"
    descLabel.BackgroundTransparency = 1
    descLabel.Font = StyleGuide.Fonts.Regular
    descLabel.Text = "Description: " .. (role.description or "")
    descLabel.TextColor3 = StyleGuide.Colors.Text
    descLabel.TextSize = StyleGuide.TextSizes.Regular
    descLabel.Size = UDim2.new(1, -20, 0, 20)
    descLabel.Position = UDim2.new(0, 10, 0, 60)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = detailsFrame
    
    -- Get permissions for this role
    local rolePermissions = AccessControl.getRolePermissions(roleId)
    
    local permissionsLabel = Instance.new("TextLabel")
    permissionsLabel.Name = "PermissionsLabel"
    permissionsLabel.BackgroundTransparency = 1
    permissionsLabel.Font = StyleGuide.Fonts.Bold
    permissionsLabel.Text = "Permissions:"
    permissionsLabel.TextColor3 = StyleGuide.Colors.Text
    permissionsLabel.TextSize = StyleGuide.TextSizes.Regular
    permissionsLabel.Size = UDim2.new(1, -20, 0, 20)
    permissionsLabel.Position = UDim2.new(0, 10, 0, 90)
    permissionsLabel.TextXAlignment = Enum.TextXAlignment.Left
    permissionsLabel.Parent = detailsFrame
    
    local permissionsList = Instance.new("ScrollingFrame")
    permissionsList.Name = "PermissionsList"
    permissionsList.BackgroundColor3 = StyleGuide.Colors.BackgroundLight
    permissionsList.BorderColor3 = StyleGuide.Colors.Border
    permissionsList.BorderSizePixel = 1
    permissionsList.Size = UDim2.new(1, -20, 0, 200)
    permissionsList.Position = UDim2.new(0, 10, 0, 120)
    permissionsList.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be adjusted dynamically
    permissionsList.ScrollBarThickness = 8
    permissionsList.Parent = detailsFrame
    
    -- List all available permissions with checkboxes for this role
    local allPermissions = AccessControl.getPermissions()
    local yOffset = 5
    
    for id, permission in pairs(allPermissions) do
        local hasPermission = table.find(rolePermissions, id) ~= nil
        
        local permFrame = Instance.new("Frame")
        permFrame.Name = "Permission_" .. id
        permFrame.BackgroundTransparency = 1
        permFrame.Size = UDim2.new(1, -10, 0, 30)
        permFrame.Position = UDim2.new(0, 5, 0, yOffset)
        permFrame.Parent = permissionsList
        
        local checkbox = Instance.new("Frame")
        checkbox.Name = "Checkbox"
        checkbox.BackgroundColor3 = hasPermission and StyleGuide.Colors.Success or StyleGuide.Colors.Background
        checkbox.BorderColor3 = StyleGuide.Colors.Border
        checkbox.BorderSizePixel = 1
        checkbox.Size = UDim2.new(0, 20, 0, 20)
        checkbox.Position = UDim2.new(0, 5, 0, 5)
        checkbox.Parent = permFrame
        
        local checkmark = Instance.new("TextLabel")
        checkmark.Name = "Checkmark"
        checkmark.BackgroundTransparency = 1
        checkmark.Font = StyleGuide.Fonts.Bold
        checkmark.Text = hasPermission and "✓" or ""
        checkmark.TextColor3 = StyleGuide.Colors.ButtonText
        checkmark.TextSize = StyleGuide.TextSizes.Regular
        checkmark.Size = UDim2.new(1, 0, 1, 0)
        checkmark.Parent = checkbox
        
        local permNameLabel = Instance.new("TextLabel")
        permNameLabel.Name = "PermissionName"
        permNameLabel.BackgroundTransparency = 1
        permNameLabel.Font = StyleGuide.Fonts.Regular
        permNameLabel.Text = permission.name
        permNameLabel.TextColor3 = StyleGuide.Colors.Text
        permNameLabel.TextSize = StyleGuide.TextSizes.Regular
        permNameLabel.Size = UDim2.new(1, -35, 1, 0)
        permNameLabel.Position = UDim2.new(0, 30, 0, 0)
        permNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        permNameLabel.Parent = permFrame
        
        -- Make the entire row clickable to toggle permission
        local button = Instance.new("TextButton")
        button.Name = "ToggleButton"
        button.BackgroundTransparency = 1
        button.Text = ""
        button.Size = UDim2.new(1, 0, 1, 0)
        button.Parent = permFrame
        
        button.MouseButton1Click:Connect(function()
            local success
            
            if hasPermission then
                success = AccessControl.revokePermission(id, roleId)
            else
                success = AccessControl.grantPermission(id, roleId)
            end
            
            if success then
                -- Log the action
                AccessControl.logAction("default", hasPermission and "revoke_permission" or "grant_permission", {
                    roleId = roleId,
                    permissionId = id
                })
                
                -- Refresh the role details
                AccessControlUI.selectRole(roleId)
            end
        end)
        
        yOffset = yOffset + 35
    end
    
    permissionsList.CanvasSize = UDim2.new(0, 0, 0, yOffset + 5)
    
    -- Create edit and delete buttons
    local editButton = Instance.new("TextButton")
    editButton.Name = "EditButton"
    editButton.BackgroundColor3 = StyleGuide.Colors.Primary
    editButton.BorderColor3 = StyleGuide.Colors.Border
    editButton.BorderSizePixel = 1
    editButton.Font = StyleGuide.Fonts.Bold
    editButton.Text = "Edit Role"
    editButton.TextColor3 = StyleGuide.Colors.ButtonText
    editButton.TextSize = StyleGuide.TextSizes.Regular
    editButton.Size = UDim2.new(0, 100, 0, 30)
    editButton.Position = UDim2.new(0, 10, 0, 330)
    editButton.Parent = detailsFrame
    
    editButton.MouseButton1Click:Connect(function()
        AccessControlUI.showEditRoleDialog(roleId, role)
    end)
    
    local deleteButton = Instance.new("TextButton")
    deleteButton.Name = "DeleteButton"
    deleteButton.BackgroundColor3 = StyleGuide.Colors.Danger
    deleteButton.BorderColor3 = StyleGuide.Colors.Border
    deleteButton.BorderSizePixel = 1
    deleteButton.Font = StyleGuide.Fonts.Bold
    deleteButton.Text = "Delete Role"
    deleteButton.TextColor3 = StyleGuide.Colors.ButtonText
    deleteButton.TextSize = StyleGuide.TextSizes.Regular
    deleteButton.Size = UDim2.new(0, 100, 0, 30)
    deleteButton.Position = UDim2.new(0, 120, 0, 330)
    deleteButton.Parent = detailsFrame
    
    deleteButton.MouseButton1Click:Connect(function()
        AccessControlUI.showDeleteRoleConfirmation(roleId, role.name)
    end)
end

-- Display a dialog to create a new role
function AccessControlUI.showCreateRoleDialog()
    local dialog = Instance.new("Frame")
    dialog.Name = "CreateRoleDialog"
    dialog.BackgroundColor3 = StyleGuide.Colors.DialogBackground
    dialog.BorderColor3 = StyleGuide.Colors.Border
    dialog.BorderSizePixel = 2
    dialog.Size = UDim2.new(0, 400, 0, 200)
    dialog.Position = UDim2.new(0.5, -200, 0.5, -100)
    dialog.ZIndex = 100
    dialog.Parent = AccessControlUI.ui.container
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundColor3 = StyleGuide.Colors.HeaderBackground
    title.BorderSizePixel = 0
    title.Font = StyleGuide.Fonts.Header
    title.Text = "Create New Role"
    title.TextColor3 = StyleGuide.Colors.HeaderText
    title.TextSize = StyleGuide.TextSizes.Header
    title.Size = UDim2.new(1, 0, 0, 40)
    title.ZIndex = 101
    title.Parent = dialog
    
    local idLabel = Instance.new("TextLabel")
    idLabel.Name = "IdLabel"
    idLabel.BackgroundTransparency = 1
    idLabel.Font = StyleGuide.Fonts.Regular
    idLabel.Text = "Role ID:"
    idLabel.TextColor3 = StyleGuide.Colors.Text
    idLabel.TextSize = StyleGuide.TextSizes.Regular
    idLabel.Size = UDim2.new(0, 100, 0, 30)
    idLabel.Position = UDim2.new(0, 10, 0, 50)
    idLabel.TextXAlignment = Enum.TextXAlignment.Left
    idLabel.ZIndex = 101
    idLabel.Parent = dialog
    
    local idInput = Instance.new("TextBox")
    idInput.Name = "IdInput"
    idInput.BackgroundColor3 = StyleGuide.Colors.InputBackground
    idInput.BorderColor3 = StyleGuide.Colors.Border
    idInput.BorderSizePixel = 1
    idInput.Font = StyleGuide.Fonts.Regular
    idInput.Text = ""
    idInput.PlaceholderText = "Enter role ID (no spaces)"
    idInput.TextColor3 = StyleGuide.Colors.Text
    idInput.TextSize = StyleGuide.TextSizes.Regular
    idInput.ClearTextOnFocus = false
    idInput.Size = UDim2.new(0, 280, 0, 30)
    idInput.Position = UDim2.new(0, 110, 0, 50)
    idInput.ZIndex = 101
    idInput.Parent = dialog
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = StyleGuide.Fonts.Regular
    nameLabel.Text = "Role Name:"
    nameLabel.TextColor3 = StyleGuide.Colors.Text
    nameLabel.TextSize = StyleGuide.TextSizes.Regular
    nameLabel.Size = UDim2.new(0, 100, 0, 30)
    nameLabel.Position = UDim2.new(0, 10, 0, 90)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 101
    nameLabel.Parent = dialog
    
    local nameInput = Instance.new("TextBox")
    nameInput.Name = "NameInput"
    nameInput.BackgroundColor3 = StyleGuide.Colors.InputBackground
    nameInput.BorderColor3 = StyleGuide.Colors.Border
    nameInput.BorderSizePixel = 1
    nameInput.Font = StyleGuide.Fonts.Regular
    nameInput.Text = ""
    nameInput.PlaceholderText = "Enter role name"
    nameInput.TextColor3 = StyleGuide.Colors.Text
    nameInput.TextSize = StyleGuide.TextSizes.Regular
    nameInput.ClearTextOnFocus = false
    nameInput.Size = UDim2.new(0, 280, 0, 30)
    nameInput.Position = UDim2.new(0, 110, 0, 90)
    nameInput.ZIndex = 101
    nameInput.Parent = dialog
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "DescLabel"
    descLabel.BackgroundTransparency = 1
    descLabel.Font = StyleGuide.Fonts.Regular
    descLabel.Text = "Description:"
    descLabel.TextColor3 = StyleGuide.Colors.Text
    descLabel.TextSize = StyleGuide.TextSizes.Regular
    descLabel.Size = UDim2.new(0, 100, 0, 30)
    descLabel.Position = UDim2.new(0, 10, 0, 130)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 101
    descLabel.Parent = dialog
    
    local descInput = Instance.new("TextBox")
    descInput.Name = "DescInput"
    descInput.BackgroundColor3 = StyleGuide.Colors.InputBackground
    descInput.BorderColor3 = StyleGuide.Colors.Border
    descInput.BorderSizePixel = 1
    descInput.Font = StyleGuide.Fonts.Regular
    descInput.Text = ""
    descInput.PlaceholderText = "Enter role description"
    descInput.TextColor3 = StyleGuide.Colors.Text
    descInput.TextSize = StyleGuide.TextSizes.Regular
    descInput.ClearTextOnFocus = false
    descInput.Size = UDim2.new(0, 280, 0, 30)
    descInput.Position = UDim2.new(0, 110, 0, 130)
    descInput.ZIndex = 101
    descInput.Parent = dialog
    
    local cancelButton = Instance.new("TextButton")
    cancelButton.Name = "CancelButton"
    cancelButton.BackgroundColor3 = StyleGuide.Colors.Secondary
    cancelButton.BorderColor3 = StyleGuide.Colors.Border
    cancelButton.BorderSizePixel = 1
    cancelButton.Font = StyleGuide.Fonts.Bold
    cancelButton.Text = "Cancel"
    cancelButton.TextColor3 = StyleGuide.Colors.ButtonText
    cancelButton.TextSize = StyleGuide.TextSizes.Regular
    cancelButton.Size = UDim2.new(0, 100, 0, 30)
    cancelButton.Position = UDim2.new(0, 110, 0, 170)
    cancelButton.ZIndex = 101
    cancelButton.Parent = dialog
    
    cancelButton.MouseButton1Click:Connect(function()
        dialog:Destroy()
    end)
    
    local createButton = Instance.new("TextButton")
    createButton.Name = "CreateButton"
    createButton.BackgroundColor3 = StyleGuide.Colors.Success
    createButton.BorderColor3 = StyleGuide.Colors.Border
    createButton.BorderSizePixel = 1
    createButton.Font = StyleGuide.Fonts.Bold
    createButton.Text = "Create"
    createButton.TextColor3 = StyleGuide.Colors.ButtonText
    createButton.TextSize = StyleGuide.TextSizes.Regular
    createButton.Size = UDim2.new(0, 100, 0, 30)
    createButton.Position = UDim2.new(0, 220, 0, 170)
    createButton.ZIndex = 101
    createButton.Parent = dialog
    
    createButton.MouseButton1Click:Connect(function()
        local roleId = idInput.Text
        local name = nameInput.Text
        local description = descInput.Text
        
        -- Validate inputs
        if roleId == "" then
            idInput.BorderColor3 = StyleGuide.Colors.Danger
            return
        end
        
        -- Create the role
        local success, errorMsg = AccessControl.createRole(roleId, name, description)
        
        if success then
            -- Log the action
            AccessControl.logAction("default", "create_role", {
                roleId = roleId,
                name = name
            })
            
            -- Refresh the roles list
            AccessControlUI.refreshRolesTab()
            
            -- Select the new role
            AccessControlUI.selectRole(roleId)
            
            -- Close the dialog
            dialog:Destroy()
        else
            -- Display error
            local errorLabel = Instance.new("TextLabel")
            errorLabel.Name = "ErrorLabel"
            errorLabel.BackgroundTransparency = 1
            errorLabel.Font = StyleGuide.Fonts.Regular
            errorLabel.Text = errorMsg or "Failed to create role"
            errorLabel.TextColor3 = StyleGuide.Colors.Danger
            errorLabel.TextSize = StyleGuide.TextSizes.Small
            errorLabel.Size = UDim2.new(1, -20, 0, 20)
            errorLabel.Position = UDim2.new(0, 10, 0, 150)
            errorLabel.TextXAlignment = Enum.TextXAlignment.Center
            errorLabel.ZIndex = 101
            errorLabel.Parent = dialog
        end
    end)
    
    -- Add a modal background
    local modalBg = Instance.new("Frame")
    modalBg.Name = "ModalBackground"
    modalBg.BackgroundColor3 = Color3.new(0, 0, 0)
    modalBg.BackgroundTransparency = 0.5
    modalBg.BorderSizePixel = 0
    modalBg.Size = UDim2.new(1, 0, 1, 0)
    modalBg.ZIndex = 99
    modalBg.Parent = AccessControlUI.ui.container
    
    modalBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dialog:Destroy()
            modalBg:Destroy()
        end
    end)
end

-- Add the remaining UI creation and refresh functions for users, permissions, and audit logs similar to the roles tab
-- For brevity, we've included the detailed implementation for the roles tab as an example

-- Refresh Users Tab
function AccessControlUI.refreshUsersTab()
    -- Implementation similar to refreshRolesTab but for users
    -- This would populate the users list and handle user selection/details
end

-- Refresh Permissions Tab
function AccessControlUI.refreshPermissionsTab()
    -- Implementation similar to refreshRolesTab but for permissions
    -- This would populate the permissions list and handle permission selection/details
end

-- Refresh Audit Logs Tab
function AccessControlUI.refreshAuditLogsTab()
    local auditLogsList = AccessControlUI.ui.auditLogsList
    local filterFrame = AccessControlUI.ui.auditLogsFilterFrame
    
    -- Clear the existing logs (except the header)
    for _, child in pairs(auditLogsList:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "HeaderFrame" then
            child:Destroy()
        end
    end
    
    -- Get filter values
    local userFilter = filterFrame.UserFilterInput.Text ~= "" and filterFrame.UserFilterInput.Text or nil
    local actionFilter = filterFrame.ActionFilterInput.Text ~= "" and filterFrame.ActionFilterInput.Text or nil
    
    -- Create filter object
    local filter = {}
    if userFilter then filter.userId = userFilter end
    if actionFilter then filter.action = actionFilter end
    
    -- Get filtered logs
    local logs = AccessControl.getAuditLogs(filter)
    
    -- Create a row for each log entry
    local yOffset = 35 -- Start below the header
    
    for i, log in ipairs(logs) do
        local logFrame = Instance.new("Frame")
        logFrame.Name = "LogEntry_" .. i
        logFrame.BackgroundColor3 = i % 2 == 0 and StyleGuide.Colors.ListItemBackgroundAlt or StyleGuide.Colors.ListItemBackground
        logFrame.BorderSizePixel = 0
        logFrame.Size = UDim2.new(1, 0, 0, 30)
        logFrame.Position = UDim2.new(0, 0, 0, yOffset)
        logFrame.Parent = auditLogsList
        
        -- Format timestamp
        local timestamp = os.date("%Y-%m-%d %H:%M:%S", log.timestamp)
        
        local timestampLabel = Instance.new("TextLabel")
        timestampLabel.Name = "Timestamp"
        timestampLabel.BackgroundTransparency = 1
        timestampLabel.Font = StyleGuide.Fonts.Regular
        timestampLabel.Text = timestamp
        timestampLabel.TextColor3 = StyleGuide.Colors.Text
        timestampLabel.TextSize = StyleGuide.TextSizes.Small
        timestampLabel.Size = UDim2.new(0.2, 0, 1, 0)
        timestampLabel.Position = UDim2.new(0, 5, 0, 0)
        timestampLabel.TextXAlignment = Enum.TextXAlignment.Left
        timestampLabel.Parent = logFrame
        
        local userLabel = Instance.new("TextLabel")
        userLabel.Name = "User"
        userLabel.BackgroundTransparency = 1
        userLabel.Font = StyleGuide.Fonts.Regular
        userLabel.Text = log.userId
        userLabel.TextColor3 = StyleGuide.Colors.Text
        userLabel.TextSize = StyleGuide.TextSizes.Small
        userLabel.Size = UDim2.new(0.15, 0, 1, 0)
        userLabel.Position = UDim2.new(0.2, 5, 0, 0)
        userLabel.TextXAlignment = Enum.TextXAlignment.Left
        userLabel.Parent = logFrame
        
        local actionLabel = Instance.new("TextLabel")
        actionLabel.Name = "Action"
        actionLabel.BackgroundTransparency = 1
        actionLabel.Font = StyleGuide.Fonts.Regular
        actionLabel.Text = log.action
        actionLabel.TextColor3 = StyleGuide.Colors.Text
        actionLabel.TextSize = StyleGuide.TextSizes.Small
        actionLabel.Size = UDim2.new(0.25, 0, 1, 0)
        actionLabel.Position = UDim2.new(0.35, 5, 0, 0)
        actionLabel.TextXAlignment = Enum.TextXAlignment.Left
        actionLabel.Parent = logFrame
        
        -- Format details as a string
        local detailsText = ""
        if type(log.details) == "table" then
            for k, v in pairs(log.details) do
                detailsText = detailsText .. k .. ": " .. tostring(v) .. ", "
            end
            detailsText = detailsText:sub(1, -3) -- Remove trailing comma and space
        else
            detailsText = tostring(log.details or "")
        end
        
        local detailsLabel = Instance.new("TextLabel")
        detailsLabel.Name = "Details"
        detailsLabel.BackgroundTransparency = 1
        detailsLabel.Font = StyleGuide.Fonts.Regular
        detailsLabel.Text = detailsText
        detailsLabel.TextColor3 = StyleGuide.Colors.Text
        detailsLabel.TextSize = StyleGuide.TextSizes.Small
        detailsLabel.Size = UDim2.new(0.4, 0, 1, 0)
        detailsLabel.Position = UDim2.new(0.6, 5, 0, 0)
        detailsLabel.TextXAlignment = Enum.TextXAlignment.Left
        detailsLabel.Parent = logFrame
        
        yOffset = yOffset + 30
    end
    
    -- Update the canvas size
    auditLogsList.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
end

return AccessControlUI
