local Logger = {}

-- Log levels
Logger.Levels = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    FATAL = 5
}

-- Configuration
local config = {
    minLevel = Logger.Levels.INFO,
    includeTimestamp = true,
    includeStack = true,
    outputToConsole = true,
    outputToFile = false,
    logFilePath = "logs/game.log"
}

-- Utility function to get timestamp
local function getTimestamp()
    return os.date("%Y-%m-%d %H:%M:%S")
end

-- Utility function to get stack trace
local function getStackTrace()
    local stack = debug.traceback()
    return stack:match("stack traceback:\n(.*)")
end

-- Format log message
local function formatMessage(level, message, data)
    local parts = {}
    
    if config.includeTimestamp then
        table.insert(parts, string.format("[%s]", getTimestamp()))
    end
    
    table.insert(parts, string.format("[%s]", level))
    table.insert(parts, message)
    
    if data then
        table.insert(parts, string.format("Data: %s", game:GetService("HttpService"):JSONEncode(data)))
    end
    
    if config.includeStack then
        table.insert(parts, string.format("\nStack: %s", getStackTrace()))
    end
    
    return table.concat(parts, " ")
end

-- Core logging function
local function log(level, message, data)
    if level < config.minLevel then
        return
    end
    
    local formattedMessage = formatMessage(level, message, data)
    
    if config.outputToConsole then
        if level >= Logger.Levels.ERROR then
            warn(formattedMessage)
        else
            print(formattedMessage)
        end
    end
    
    if config.outputToFile then
        -- TODO: Implement file logging if needed
    end
end

-- Public logging methods
function Logger.debug(message, data)
    log(Logger.Levels.DEBUG, message, data)
end

function Logger.info(message, data)
    log(Logger.Levels.INFO, message, data)
end

function Logger.warn(message, data)
    log(Logger.Levels.WARN, message, data)
end

function Logger.error(message, data)
    log(Logger.Levels.ERROR, message, data)
end

function Logger.fatal(message, data)
    log(Logger.Levels.FATAL, message, data)
end

-- Configuration methods
function Logger.setConfig(newConfig)
    for key, value in pairs(newConfig) do
        config[key] = value
    end
end

function Logger.getConfig()
    return table.clone(config)
end

return Logger 