--[[
    AccessControl.luau
    Part of DataStore Manager Pro
    
    This module provides access control functionality for the plugin,
    including user permissions, audit logging, and data protection.
]]

local HttpService = game:GetService("HttpService")

local AccessControl = {}

-- Access control configuration
AccessControl.configuration = {
    enabled = false,
    roles = {},
    users = {},
    permissions = {}
}

-- Initialize the Access Control module
function AccessControl.initialize()
    print("AccessControl: Initializing module...")
    
    -- Load any saved configuration
    -- In a real implementation, this would load from a saved state
    AccessControl.setupDefaultConfiguration()
    
    return true
end

-- Set up default roles and permissions
function AccessControl.setupDefaultConfiguration()
    -- Define default roles
    AccessControl.configuration.roles = {
        ["admin"] = {
            name = "Administrator",
            description = "Full access to all features"
        },
        ["developer"] = {
            name = "Developer",
            description = "Can view and modify all data, but cannot change permissions"
        },
        ["dataManager"] = {
            name = "Data Manager",
            description = "Can view and modify data, but cannot access system settings"
        },
        ["viewer"] = {
            name = "Viewer",
            description = "Can only view data, not modify it"
        }
    }
    
    -- Define default permissions
    AccessControl.configuration.permissions = {
        ["viewData"] = {
            name = "View Data",
            description = "Can view data store contents",
            roles = {"admin", "developer", "dataManager", "viewer"}
        },
        ["editData"] = {
            name = "Edit Data",
            description = "Can modify data store contents",
            roles = {"admin", "developer", "dataManager"}
        },
        ["deleteData"] = {
            name = "Delete Data",
            description = "Can delete keys or entire data stores",
            roles = {"admin", "developer"}
        },
        ["manageSchemas"] = {
            name = "Manage Schemas",
            description = "Can create, edit, and delete schemas",
            roles = {"admin", "developer"}
        },
        ["manageSessions"] = {
            name = "Manage Sessions",
            description = "Can view and manage active sessions",
            roles = {"admin", "developer", "dataManager"}
        },
        ["viewAnalytics"] = {
            name = "View Analytics",
            description = "Can view performance analytics",
            roles = {"admin", "developer", "dataManager", "viewer"}
        },
        ["configureSettings"] = {
            name = "Configure Settings",
            description = "Can change plugin settings",
            roles = {"admin"}
        },
        ["managePermissions"] = {
            name = "Manage Permissions",
            description = "Can assign roles and permissions",
            roles = {"admin"}
        },
        ["auditLogs"] = {
            name = "View Audit Logs",
            description = "Can view audit logs of actions",
            roles = {"admin", "developer"}
        }
    }
    
    -- Define default users (in a real implementation this would be loaded from a saved state)
    AccessControl.configuration.users = {
        ["default"] = {
            name = "Default User",
            role = "admin" -- Default role is admin since this is a plugin
        }
    }
    
    -- Enable access control by default
    AccessControl.configuration.enabled = true
end

-- Check if a user has permission for an action
function AccessControl.hasPermission(userId, permissionId)
    -- If access control is disabled, all permissions are granted
    if not AccessControl.configuration.enabled then
        return true
    end
    
    -- Get the user record
    local user = AccessControl.configuration.users[userId or "default"]
    if not user then
        -- If user doesn't exist, use default
        user = AccessControl.configuration.users["default"]
        if not user then
            -- If default doesn't exist, deny permission
            return false
        end
    end
    
    -- Get the permission record
    local permission = AccessControl.configuration.permissions[permissionId]
    if not permission then
        -- If permission doesn't exist, deny
        return false
    end
    
    -- Check if the user's role is included in the permission's roles
    for _, role in ipairs(permission.roles) do
        if role == user.role then
            return true
        end
    end
    
    return false
end

-- Create a new role
function AccessControl.createRole(roleId, name, description)
    -- Validate input
    if not roleId or type(roleId) ~= "string" or roleId == "" then
        return false, "Invalid role ID"
    end
    
    -- Check if the role already exists
    if AccessControl.configuration.roles[roleId] then
        return false, "Role already exists with ID: " .. roleId
    end
    
    -- Create the role
    AccessControl.configuration.roles[roleId] = {
        name = name or roleId,
        description = description or ""
    }
    
    return true
end

-- Update an existing role
function AccessControl.updateRole(roleId, name, description)
    -- Validate input
    if not roleId or not AccessControl.configuration.roles[roleId] then
        return false, "Role not found: " .. tostring(roleId)
    end
    
    -- Update the role
    local role = AccessControl.configuration.roles[roleId]
    role.name = name or role.name
    role.description = description or role.description
    
    return true
end

-- Delete a role
function AccessControl.deleteRole(roleId)
    -- Validate input
    if not roleId or not AccessControl.configuration.roles[roleId] then
        return false, "Role not found: " .. tostring(roleId)
    end
    
    -- Check if any users have this role
    for userId, user in pairs(AccessControl.configuration.users) do
        if user.role == roleId then
            return false, "Cannot delete role that is assigned to users"
        end
    end
    
    -- Delete the role
    AccessControl.configuration.roles[roleId] = nil
    
    -- Remove role from permissions
    for _, permission in pairs(AccessControl.configuration.permissions) do
        for i, role in ipairs(permission.roles) do
            if role == roleId then
                table.remove(permission.roles, i)
                break
            end
        end
    end
    
    return true
end

-- Create a new user
function AccessControl.createUser(userId, name, role)
    -- Validate input
    if not userId or type(userId) ~= "string" or userId == "" then
        return false, "Invalid user ID"
    end
    
    -- Check if the user already exists
    if AccessControl.configuration.users[userId] then
        return false, "User already exists with ID: " .. userId
    end
    
    -- Validate role
    role = role or "viewer" -- Default to viewer role
    if not AccessControl.configuration.roles[role] then
        return false, "Invalid role: " .. tostring(role)
    end
    
    -- Create the user
    AccessControl.configuration.users[userId] = {
        name = name or userId,
        role = role
    }
    
    return true
end

-- Update an existing user
function AccessControl.updateUser(userId, name, role)
    -- Validate input
    if not userId or not AccessControl.configuration.users[userId] then
        return false, "User not found: " .. tostring(userId)
    end
    
    -- Validate role if provided
    if role and not AccessControl.configuration.roles[role] then
        return false, "Invalid role: " .. tostring(role)
    end
    
    -- Update the user
    local user = AccessControl.configuration.users[userId]
    user.name = name or user.name
    user.role = role or user.role
    
    return true
end

-- Delete a user
function AccessControl.deleteUser(userId)
    -- Validate input
    if not userId or not AccessControl.configuration.users[userId] then
        return false, "User not found: " .. tostring(userId)
    end
    
    -- Prevent deleting the default user
    if userId == "default" then
        return false, "Cannot delete the default user"
    end
    
    -- Delete the user
    AccessControl.configuration.users[userId] = nil
    
    return true
end

-- Grant a permission to a role
function AccessControl.grantPermission(permissionId, roleId)
    -- Validate input
    if not permissionId or not AccessControl.configuration.permissions[permissionId] then
        return false, "Permission not found: " .. tostring(permissionId)
    end
    
    if not roleId or not AccessControl.configuration.roles[roleId] then
        return false, "Role not found: " .. tostring(roleId)
    end
    
    -- Check if the role already has this permission
    local permission = AccessControl.configuration.permissions[permissionId]
    for _, role in ipairs(permission.roles) do
        if role == roleId then
            return true -- Already granted
        end
    end
    
    -- Grant the permission
    table.insert(permission.roles, roleId)
    
    return true
end

-- Revoke a permission from a role
function AccessControl.revokePermission(permissionId, roleId)
    -- Validate input
    if not permissionId or not AccessControl.configuration.permissions[permissionId] then
        return false, "Permission not found: " .. tostring(permissionId)
    end
    
    if not roleId or not AccessControl.configuration.roles[roleId] then
        return false, "Role not found: " .. tostring(roleId)
    end
    
    -- Remove the role from the permission
    local permission = AccessControl.configuration.permissions[permissionId]
    for i, role in ipairs(permission.roles) do
        if role == roleId then
            table.remove(permission.roles, i)
            return true
        end
    end
    
    return false, "Role does not have this permission"
end

-- Create a new permission
function AccessControl.createPermission(permissionId, name, description, roles)
    -- Validate input
    if not permissionId or type(permissionId) ~= "string" or permissionId == "" then
        return false, "Invalid permission ID"
    end
    
    -- Check if the permission already exists
    if AccessControl.configuration.permissions[permissionId] then
        return false, "Permission already exists with ID: " .. permissionId
    end
    
    -- Validate roles
    roles = roles or {}
    for _, roleId in ipairs(roles) do
        if not AccessControl.configuration.roles[roleId] then
            return false, "Invalid role: " .. tostring(roleId)
        end
    end
    
    -- Create the permission
    AccessControl.configuration.permissions[permissionId] = {
        name = name or permissionId,
        description = description or "",
        roles = roles
    }
    
    return true
end

-- Update an existing permission
function AccessControl.updatePermission(permissionId, name, description)
    -- Validate input
    if not permissionId or not AccessControl.configuration.permissions[permissionId] then
        return false, "Permission not found: " .. tostring(permissionId)
    end
    
    -- Update the permission
    local permission = AccessControl.configuration.permissions[permissionId]
    permission.name = name or permission.name
    permission.description = description or permission.description
    
    return true
end

-- Delete a permission
function AccessControl.deletePermission(permissionId)
    -- Validate input
    if not permissionId or not AccessControl.configuration.permissions[permissionId] then
        return false, "Permission not found: " .. tostring(permissionId)
    end
    
    -- Delete the permission
    AccessControl.configuration.permissions[permissionId] = nil
    
    return true
end

-- Get all roles
function AccessControl.getRoles()
    local roles = {}
    for id, role in pairs(AccessControl.configuration.roles) do
        roles[id] = {
            id = id,
            name = role.name,
            description = role.description
        }
    end
    return roles
end

-- Get all users
function AccessControl.getUsers()
    local users = {}
    for id, user in pairs(AccessControl.configuration.users) do
        users[id] = {
            id = id,
            name = user.name,
            role = user.role
        }
    end
    return users
end

-- Get all permissions
function AccessControl.getPermissions()
    local permissions = {}
    for id, permission in pairs(AccessControl.configuration.permissions) do
        permissions[id] = {
            id = id,
            name = permission.name,
            description = permission.description,
            roles = table.clone(permission.roles)
        }
    end
    return permissions
end

-- Enable or disable access control
function AccessControl.setEnabled(enabled)
    AccessControl.configuration.enabled = enabled == true
    return true
end

-- Check if access control is enabled
function AccessControl.isEnabled()
    return AccessControl.configuration.enabled
end

-- Get permissions for a role
function AccessControl.getRolePermissions(roleId)
    -- Validate input
    if not roleId or not AccessControl.configuration.roles[roleId] then
        return nil, "Role not found: " .. tostring(roleId)
    end
    
    local rolePermissions = {}
    for id, permission in pairs(AccessControl.configuration.permissions) do
        for _, role in ipairs(permission.roles) do
            if role == roleId then
                table.insert(rolePermissions, id)
                break
            end
        end
    end
    
    return rolePermissions
end

-- Audit logging functionality
AccessControl.auditLogs = {}

-- Log an action for audit purposes
function AccessControl.logAction(userId, action, details)
    userId = userId or "default"
    details = details or {}
    
    local logEntry = {
        timestamp = os.time(),
        userId = userId,
        action = action,
        details = details
    }
    
    table.insert(AccessControl.auditLogs, logEntry)
    
    -- Keep logs to a reasonable size (1000 entries)
    if #AccessControl.auditLogs > 1000 then
        table.remove(AccessControl.auditLogs, 1)
    end
    
    return true
end

-- Get audit logs with optional filtering
function AccessControl.getAuditLogs(filter)
    filter = filter or {}
    
    -- If no filter, return all logs
    if not next(filter) then
        return table.clone(AccessControl.auditLogs)
    end
    
    -- Apply filters
    local filteredLogs = {}
    for _, log in ipairs(AccessControl.auditLogs) do
        local matches = true
        
        -- Filter by user ID
        if filter.userId and log.userId ~= filter.userId then
            matches = false
        end
        
        -- Filter by action
        if filter.action and log.action ~= filter.action then
            matches = false
        end
        
        -- Filter by time range
        if filter.startTime and log.timestamp < filter.startTime then
            matches = false
        end
        
        if filter.endTime and log.timestamp > filter.endTime then
            matches = false
        end
        
        -- Add matching log entry
        if matches then
            table.insert(filteredLogs, table.clone(log))
        end
    end
    
    return filteredLogs
end

-- Data encryption functionality

-- Encrypt sensitive data (stub implementation)
function AccessControl.encryptData(data, key)
    -- In a real implementation, this would use proper encryption
    -- For this demo, we'll just do a simple encoding
    
    local dataStr
    if type(data) == "table" then
        dataStr = HttpService:JSONEncode(data)
    else
        dataStr = tostring(data)
    end
    
    -- Simple XOR "encryption" - NOT for actual use, just for demo
    local encrypted = {}
    local keyBytes = {}
    
    -- Convert key to bytes
    for i = 1, #key do
        keyBytes[i] = string.byte(key, i)
    end
    
    -- "Encrypt" the data
    for i = 1, #dataStr do
        local keyByte = keyBytes[(i - 1) % #keyBytes + 1]
        encrypted[i] = string.char(bit32.bxor(string.byte(dataStr, i), keyByte))
    end
    
    return table.concat(encrypted)
end

-- Decrypt sensitive data (stub implementation)
function AccessControl.decryptData(encryptedData, key)
    -- This is the reverse of the encrypt function
    -- Again, this is just a simple demo implementation
    
    local decrypted = {}
    local keyBytes = {}
    
    -- Convert key to bytes
    for i = 1, #key do
        keyBytes[i] = string.byte(key, i)
    end
    
    -- "Decrypt" the data
    for i = 1, #encryptedData do
        local keyByte = keyBytes[(i - 1) % #keyBytes + 1]
        decrypted[i] = string.char(bit32.bxor(string.byte(encryptedData, i), keyByte))
    end
    
    local decryptedStr = table.concat(decrypted)
    
    -- Try to parse as JSON
    local success, result = pcall(function()
        return HttpService:JSONDecode(decryptedStr)
    end)
    
    if success then
        return result
    else
        return decryptedStr
    end
end

return AccessControl
