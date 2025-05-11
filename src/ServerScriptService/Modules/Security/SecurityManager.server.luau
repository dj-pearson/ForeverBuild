local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager
local Logger = Shared.Logger

-- Load server modules
local DataStoreManager = require(ServerScriptService.Modules.Data.DataStoreManager)

local SecurityManager = {}

-- Constants
local RATE_LIMIT_WINDOW = 60 -- 1 minute
local MAX_REQUESTS_PER_WINDOW = 100
local MAX_STRING_LENGTH = 1000
local MAX_NUMBER_VALUE = 1e9
local MIN_NUMBER_VALUE = -1e9

-- Rate limiting
local requestCounts = {}
local lastRequestTime = {}

-- Input validation patterns
local VALIDATION_PATTERNS = {
    username = "^[%w_]{3,20}$",
    email = "^[%w.]+@[%w.]+%.[%w]+$",
    password = "^[%w!@#$%%^&*()_+{}|:<>?~]{8,}$"
}

-- Define roles and their permissions
local roles = {
    admin = {
        read = true,
        write = true,
        delete = true,
        manageSessions = true,
        manageSchemas = true,
        viewPerformance = true,
        viewCache = true
    },
    editor = {
        read = true,
        write = true,
        delete = false,
        manageSessions = false,
        manageSchemas = false,
        viewPerformance = true,
        viewCache = true
    },
    viewer = {
        read = true,
        write = false,
        delete = false,
        manageSessions = false,
        manageSchemas = false,
        viewPerformance = true,
        viewCache = true
    }
}

-- Placeholder mapping of UserIds to roles
-- In a real implementation, this would be loaded from a secure location
local userRoles = {
    [12345] = 'admin', -- Example Admin User ID
    [67890] = 'editor', -- Example Editor User ID
    [13579] = 'viewer' -- Example Viewer User ID
    -- Add other user mappings here
}

-- Function to get the role of a user
local function getUserRole(userId)
    return userRoles[userId]
end

-- Function to check if a user has a specific permission
function SecurityManager.hasPermission(userId, permission)
    local roleName = getUserRole(userId)
    if not roleName then
        -- User has no assigned role, grant no permissions
        return false
    end

    local rolePermissions = roles[roleName]
    if not rolePermissions then
        -- Role is not defined, grant no permissions
        return false
    end

    return rolePermissions[permission] == true
end

-- Utility: Clean rate limit data
local function cleanRateLimitData()
    local currentTime = os.time()
    for playerId, lastTime in pairs(lastRequestTime) do
        if currentTime - lastTime > RATE_LIMIT_WINDOW then
            requestCounts[playerId] = nil
            lastRequestTime[playerId] = nil
        end
    end
end

-- Utility: Check rate limit
local function checkRateLimit(player)
    local playerId = player.UserId
    local currentTime = os.time()
    
    -- Clean old data
    cleanRateLimitData()
    
    -- Initialize or update request count
    if not requestCounts[playerId] then
        requestCounts[playerId] = 1
        lastRequestTime[playerId] = currentTime
        return true
    end
    
    -- Check if within time window
    if currentTime - lastRequestTime[playerId] > RATE_LIMIT_WINDOW then
        requestCounts[playerId] = 1
        lastRequestTime[playerId] = currentTime
        return true
    end
    
    -- Check request count
    if requestCounts[playerId] >= MAX_REQUESTS_PER_WINDOW then
        Logger.warn("Rate limit exceeded", { playerId = playerId })
        return false
    end
    
    requestCounts[playerId] = requestCounts[playerId] + 1
    return true
end

-- Utility: Validate string input
local function validateString(value, pattern, minLength, maxLength)
    if type(value) ~= "string" then
        return false, "Value must be a string"
    end
    
    if minLength and #value < minLength then
        return false, string.format("String too short (minimum %d characters)", minLength)
    end
    
    if maxLength and #value > maxLength then
        return false, string.format("String too long (maximum %d characters)", maxLength)
    end
    
    if pattern and not value:match(pattern) then
        return false, "String does not match required pattern"
    end
    
    return true
end

-- Utility: Validate number input
local function validateNumber(value, minValue, maxValue)
    if type(value) ~= "number" then
        return false, "Value must be a number"
    end
    
    if minValue and value < minValue then
        return false, string.format("Number too small (minimum %d)", minValue)
    end
    
    if maxValue and value > maxValue then
        return false, string.format("Number too large (maximum %d)", maxValue)
    end
    
    return true
end

-- Forward declaration of validateValue
local validateValue

-- Utility: Validate table input
local function validateTable(value, schema)
    if type(value) ~= "table" then
        return false, "Value must be a table"
    end
    
    for field, fieldSchema in pairs(schema) do
        local fieldValue = value[field]
        local success, error = validateValue(fieldValue, fieldSchema)
        if not success then
            return false, string.format("Invalid field '%s': %s", field, error)
        end
    end
    
    return true
end

-- Utility: Validate any value
validateValue = function(value, schema)
    if type(schema) == "string" then
        return validateString(value, VALIDATION_PATTERNS[schema])
    elseif type(schema) == "number" then
        return validateNumber(value, MIN_NUMBER_VALUE, MAX_NUMBER_VALUE)
    elseif type(schema) == "table" then
        return validateTable(value, schema)
    end
    
    return false, "Invalid validation schema"
end

-- Public API: Validate input
function SecurityManager.validateInput(player, input, schema)
    -- Check rate limit
    if not checkRateLimit(player) then
        return false, "Rate limit exceeded"
    end
    
    -- Validate input
    local success, error = validateValue(input, schema)
    if not success then
        Logger.warn("Invalid input", {
            playerId = player.UserId,
            error = error,
            input = input
        })
        return false, error
    end
    
    return true
end

-- Public API: Sanitize string
function SecurityManager.sanitizeString(str)
    if type(str) ~= "string" then
        return ""
    end
    
    -- Remove control characters
    str = str:gsub("[%z\1-\31]", "")
    
    -- Limit length
    if #str > MAX_STRING_LENGTH then
        str = str:sub(1, MAX_STRING_LENGTH)
    end
    
    return str
end

-- Public API: Validate and sanitize remote event data
function SecurityManager.validateRemoteData(player, data, schema)
    -- Check rate limit
    if not checkRateLimit(player) then
        return false, "Rate limit exceeded"
    end
    
    -- Validate data structure
    local success, error = validateValue(data, schema)
    if not success then
        Logger.warn("Invalid remote data", {
            playerId = player.UserId,
            error = error,
            data = data
        })
        return false, error
    end
    
    -- Sanitize string values
    local function sanitizeTable(tbl)
        for k, v in pairs(tbl) do
            if type(v) == "string" then
                tbl[k] = SecurityManager.sanitizeString(v)
            elseif type(v) == "table" then
                sanitizeTable(v)
            end
        end
    end
    
    sanitizeTable(data)
    return true, data
end

-- Public API: Check if player is admin
function SecurityManager.isAdmin(player)
    return player:GetAttribute("IsAdmin") == true
end

-- Public API: Validate admin action
function SecurityManager.validateAdminAction(player, action)
    if not SecurityManager.isAdmin(player) then
        Logger.warn("Unauthorized admin action attempt", {
            playerId = player.UserId,
            action = action
        })
        return false, "Unauthorized"
    end
    
    return true
end

-- Initialize the SecurityManager
function SecurityManager.Initialize()
    print("SecurityManager: Initializing security system...")
    -- Add any initialization logic here
    return true
end

-- Handle admin commands
function SecurityManager.handleAdminCommand(player, command, args)
    -- Implementation
end

-- Handle reports
function SecurityManager.handleReport(player, reportData)
    -- Implementation
end

return SecurityManager 