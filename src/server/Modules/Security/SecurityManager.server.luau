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
SecurityManager.__index = SecurityManager

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

-- Role definitions
local ROLES = {
    ADMIN = {
        name = "Admin",
        permissions = {
            "admin.commands",
            "admin.reports",
            "admin.ban",
            "admin.kick",
            "admin.mute",
            "admin.warn"
        }
    },
    MODERATOR = {
        name = "Moderator",
        permissions = {
            "admin.reports",
            "admin.kick",
            "admin.mute",
            "admin.warn"
        }
    },
    USER = {
        name = "User",
        permissions = {}
    }
}

-- User role mapping (in production, this would be stored in a database)
local userRoles = {
    -- Example: [123456789] = "ADMIN"
}

-- Get user role
function SecurityManager.GetUserRole(userId)
    return userRoles[tostring(userId)] or "USER"
end

-- Check if user has permission
function SecurityManager.HasPermission(userId, permission)
    local role = SecurityManager.GetUserRole(userId)
    local roleData = ROLES[role]
    
    if not roleData then
        Logger:warn("Invalid role for user", { userId = userId, role = role })
        return false
    end
    
    return table.find(roleData.permissions, permission) ~= nil
end

-- Check if user is admin
function SecurityManager.IsAdmin(userId)
    return SecurityManager.GetUserRole(userId) == "ADMIN"
end

-- Check if user is moderator
function SecurityManager.IsModerator(userId)
    local role = SecurityManager.GetUserRole(userId)
    return role == "ADMIN" or role == "MODERATOR"
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

-- Public API: Validate admin action
function SecurityManager.validateAdminAction(player, action)
    if not SecurityManager.IsAdmin(player.UserId) then
        Logger.warn("Unauthorized admin action attempt", {
            playerId = player.UserId,
            action = action
        })
        return false, "Unauthorized"
    end
    
    return true
end

-- Initialize
function SecurityManager.Initialize()
    -- Set up remote event handlers
    RemoteManager:setServerCallback("CheckPermission", function(player, permission)
        return SecurityManager.HasPermission(player.UserId, permission)
    end)
    
    RemoteManager:setServerCallback("IsAdmin", function(player)
        return SecurityManager.IsAdmin(player.UserId)
    end)
    
    RemoteManager:setServerCallback("IsModerator", function(player)
        return SecurityManager.IsModerator(player.UserId)
    end)
    
    Logger:info("SecurityManager initialized successfully")
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