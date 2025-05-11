local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Logger = require(script.Parent.Logger)
local NetworkManager = require(script.Parent.NetworkManager)

local UIManager = {}

-- Constants
local UI_TRANSITION_TIME = 0.3
local ERROR_DISPLAY_TIME = 5
local LOADING_FADE_TIME = 0.5
local MAX_ERRORS_DISPLAYED = 3

-- UI storage
local activeScreens = {}
local loadingStates = {}
local errorQueue = {}
local uiSubscribers = {}

-- Utility: Create UI element
local function createUIElement(className, properties)
    local element = Instance.new(className)
    for property, value in pairs(properties) do
        element[property] = value
    end
    return element
end

-- Utility: Create loading screen
local function createLoadingScreen()
    local screen = createUIElement("ScreenGui", {
        Name = "LoadingScreen",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local frame = createUIElement("Frame", {
        Name = "LoadingFrame",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        Visible = false
    })

    local loadingText = createUIElement("TextLabel", {
        Name = "LoadingText",
        Size = UDim2.fromScale(0.3, 0.1),
        Position = UDim2.fromScale(0.35, 0.45),
        BackgroundTransparency = 1,
        Text = "Loading...",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 24,
        Font = Enum.Font.GothamBold
    })

    local spinner = createUIElement("ImageLabel", {
        Name = "Spinner",
        Size = UDim2.fromScale(0.1, 0.1),
        Position = UDim2.fromScale(0.45, 0.35),
        BackgroundTransparency = 1,
        Image = "rbxassetid://1234567890", -- Replace with actual spinner image
        ImageTransparency = 0
    })

    loadingText.Parent = frame
    spinner.Parent = frame
    frame.Parent = screen

    return screen
end

-- Utility: Create error message
local function createErrorMessage(message)
    local messageFrame = createUIElement("Frame", {
        Name = "ErrorMessage",
        Size = UDim2.fromScale(0.4, 0.1),
        Position = UDim2.fromScale(0.3, 0.8),
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0
    })

    local messageText = createUIElement("TextLabel", {
        Name = "MessageText",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 18,
        Font = Enum.Font.GothamMedium
    })

    messageText.Parent = messageFrame
    return messageFrame
end

-- Public API: Screen Management
function UIManager.showScreen(screenName, properties)
    if activeScreens[screenName] then
        Logger.warn("Screen already active", { screen = screenName })
        return false
    end

    local screen = createUIElement("ScreenGui", {
        Name = screenName .. "Screen",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local frame = createUIElement("Frame", {
        Name = "ContentFrame",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1
    })

    -- Apply custom properties
    if properties then
        for property, value in pairs(properties) do
            frame[property] = value
        end
    end

    frame.Parent = screen
    screen.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    activeScreens[screenName] = screen

    -- Notify subscribers
    for _, callback in ipairs(uiSubscribers.screenShown or {}) do
        task.spawn(function()
            pcall(callback, screenName, screen)
        end)
    end

    return true
end

function UIManager.hideScreen(screenName)
    local screen = activeScreens[screenName]
    if not screen then
        Logger.warn("Screen not found", { screen = screenName })
        return false
    end

    -- Fade out animation
    local tweenInfo = TweenInfo.new(UI_TRANSITION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(screen, tweenInfo, { BackgroundTransparency = 1 })
    
    tween:Play()
    tween.Completed:Connect(function()
        screen:Destroy()
        activeScreens[screenName] = nil
        
        -- Notify subscribers
        for _, callback in ipairs(uiSubscribers.screenHidden or {}) do
            task.spawn(function()
                pcall(callback, screenName)
            end)
        end
    end)

    return true
end

-- Public API: Loading State Management
function UIManager.showLoading(message)
    if not loadingStates.screen then
        loadingStates.screen = createLoadingScreen()
        loadingStates.screen.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    local frame = loadingStates.screen:FindFirstChild("LoadingFrame")
    if frame then
        frame.Visible = true
        frame:FindFirstChild("LoadingText").Text = message or "Loading..."
        
        -- Fade in animation
        local tweenInfo = TweenInfo.new(LOADING_FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(frame, tweenInfo, { BackgroundTransparency = 0.5 })
        tween:Play()
    end

    loadingStates.active = true
end

function UIManager.hideLoading()
    if not loadingStates.screen then return end

    local frame = loadingStates.screen:FindFirstChild("LoadingFrame")
    if frame then
        -- Fade out animation
        local tweenInfo = TweenInfo.new(LOADING_FADE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local tween = TweenService:Create(frame, tweenInfo, { BackgroundTransparency = 1 })
        
        tween:Play()
        tween.Completed:Connect(function()
            frame.Visible = false
        end)
    end

    loadingStates.active = false
end

-- Public API: Error Message Management
function UIManager.showError(message, duration)
    duration = duration or ERROR_DISPLAY_TIME

    -- Create error message
    local errorFrame = createErrorMessage(message)
    errorFrame.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Position the error message
    local position = #errorQueue * 0.12
    errorFrame.Position = UDim2.fromScale(0.3, 0.8 - position)

    -- Add to queue
    table.insert(errorQueue, {
        frame = errorFrame,
        startTime = os.time()
    })

    -- Trim queue if too long
    while #errorQueue > MAX_ERRORS_DISPLAYED do
        local oldest = table.remove(errorQueue, 1)
        if oldest.frame then
            oldest.frame:Destroy()
        end
    end

    -- Auto-hide after duration
    task.delay(duration, function()
        for i, error in ipairs(errorQueue) do
            if error.frame == errorFrame then
                -- Fade out animation
                local tweenInfo = TweenInfo.new(UI_TRANSITION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                local tween = TweenService:Create(errorFrame, tweenInfo, { BackgroundTransparency = 1 })
                
                tween:Play()
                tween.Completed:Connect(function()
                    errorFrame:Destroy()
                    table.remove(errorQueue, i)
                end)
                break
            end
        end
    end)

    -- Notify subscribers
    for _, callback in ipairs(uiSubscribers.errorShown or {}) do
        task.spawn(function()
            pcall(callback, message)
        end)
    end
end

-- Public API: UI Subscription
function UIManager.subscribe(eventType, callback)
    if not uiSubscribers[eventType] then
        uiSubscribers[eventType] = {}
    end
    table.insert(uiSubscribers[eventType], callback)
    
    return function()
        for i, cb in ipairs(uiSubscribers[eventType]) do
            if cb == callback then
                table.remove(uiSubscribers[eventType], i)
                break
            end
        end
    end
end

-- Public API: UI State
function UIManager.isScreenActive(screenName)
    return activeScreens[screenName] ~= nil
end

function UIManager.isLoading()
    return loadingStates.active
end

function UIManager.getActiveScreens()
    return activeScreens
end

-- Initialize the UIManager
function UIManager.init()
    Logger.info("Initializing UIManager")
    
    -- Subscribe to network errors
    NetworkManager.subscribeToErrors(function(error, context)
        UIManager.showError("Network Error: " .. tostring(error))
    end)
    
    Logger.info("UIManager initialized successfully")
end

return UIManager 