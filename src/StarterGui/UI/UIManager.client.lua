local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UIManager = {}
UIManager.__index = UIManager

-- Constants
local UI_TYPES = {
    HUD = "HUD",
    MENU = "MENU",
    DIALOG = "DIALOG",
    NOTIFICATION = "NOTIFICATION"
}

-- Private variables
local activeUIs = {}
local uiQueue = {}
local isTransitioning = false

-- Initialize a new UI manager
function UIManager.new()
    local self = setmetatable({}, UIManager)
    self:Initialize()
    return self
end

-- Initialize the UI manager
function UIManager:Initialize()
    -- Set up UI containers
    self.containers = {
        [UI_TYPES.HUD] = self:CreateUIContainer("HUD"),
        [UI_TYPES.MENU] = self:CreateUIContainer("Menu"),
        [UI_TYPES.DIALOG] = self:CreateUIContainer("Dialog"),
        [UI_TYPES.NOTIFICATION] = self:CreateUIContainer("Notification")
    }
    
    -- Set up input handling
    self:SetupInputHandling()
end

-- Create a UI container
function UIManager:CreateUIContainer(name)
    local container = Instance.new("ScreenGui")
    container.Name = name .. "Container"
    container.ResetOnSpawn = false
    container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Set up container properties based on type
    if name == "HUD" then
        container.DisplayOrder = 1
    elseif name == "Menu" then
        container.DisplayOrder = 2
    elseif name == "Dialog" then
        container.DisplayOrder = 3
    elseif name == "Notification" then
        container.DisplayOrder = 4
    end
    
    container.Parent = LocalPlayer:WaitForChild("PlayerGui")
    return container
end

-- Set up input handling
function UIManager:SetupInputHandling()
    -- Handle escape key for menus
    LocalPlayer:GetAttributeChangedSignal("MenuOpen"):Connect(function()
        if LocalPlayer:GetAttribute("MenuOpen") then
            self:ShowUI(UI_TYPES.MENU, "MainMenu")
        else
            self:HideUI(UI_TYPES.MENU)
        end
    end)
end

-- Show a UI element
function UIManager:ShowUI(uiType, uiName, data)
    if not UI_TYPES[uiType] then
        warn("Invalid UI type:", uiType)
        return
    end
    
    -- Queue the UI show request
    table.insert(uiQueue, {
        type = "show",
        uiType = uiType,
        uiName = uiName,
        data = data
    })
    
    -- Process queue if not already processing
    if not isTransitioning then
        self:ProcessUIQueue()
    end
end

-- Hide a UI element
function UIManager:HideUI(uiType, uiName)
    if not UI_TYPES[uiType] then
        warn("Invalid UI type:", uiType)
        return
    end
    
    -- Queue the UI hide request
    table.insert(uiQueue, {
        type = "hide",
        uiType = uiType,
        uiName = uiName
    })
    
    -- Process queue if not already processing
    if not isTransitioning then
        self:ProcessUIQueue()
    end
end

-- Process the UI queue
function UIManager:ProcessUIQueue()
    if isTransitioning or #uiQueue == 0 then return end
    
    isTransitioning = true
    
    local nextAction = table.remove(uiQueue, 1)
    local container = self.containers[nextAction.uiType]
    
    if nextAction.type == "show" then
        -- Create or show the UI
        local ui = container:FindFirstChild(nextAction.uiName)
        if not ui then
            ui = self:CreateUI(nextAction.uiName, nextAction.uiType)
        end
        
        if ui then
            ui.Visible = true
            if nextAction.data then
                self:UpdateUI(ui, nextAction.data)
            end
        end
    elseif nextAction.type == "hide" then
        -- Hide the UI
        if nextAction.uiName then
            local ui = container:FindFirstChild(nextAction.uiName)
            if ui then
                ui.Visible = false
            end
        else
            -- Hide all UIs of this type
            for _, child in ipairs(container:GetChildren()) do
                child.Visible = false
            end
        end
    end
    
    isTransitioning = false
    
    -- Process next item in queue
    if #uiQueue > 0 then
        task.spawn(function()
            self:ProcessUIQueue()
        end)
    end
end

-- Create a UI element
function UIManager:CreateUI(uiName, uiType)
    -- This would typically load a UI template from ReplicatedStorage
    -- For now, we'll create a basic frame
    local frame = Instance.new("Frame")
    frame.Name = uiName
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    
    frame.Parent = self.containers[uiType]
    return frame
end

-- Update a UI element with data
function UIManager:UpdateUI(ui, data)
    -- This would typically update UI elements based on the provided data
    -- For now, we'll just store the data
    ui:SetAttribute("Data", data)
end

-- Show a notification
function UIManager:ShowNotification(message, duration)
    duration = duration or 3
    
    local notification = Instance.new("TextLabel")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 200, 0, 50)
    notification.Position = UDim2.new(0.5, -100, 0.1, 0)
    notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notification.BackgroundTransparency = 0.5
    notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    notification.Text = message
    notification.TextScaled = true
    
    notification.Parent = self.containers[UI_TYPES.NOTIFICATION]
    
    -- Animate in
    notification.Position = UDim2.new(0.5, -100, 0, -50)
    notification.BackgroundTransparency = 1
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = game:GetService("TweenService"):Create(notification, tweenInfo, {
        Position = UDim2.new(0.5, -100, 0.1, 0),
        BackgroundTransparency = 0.5
    })
    tween:Play()
    
    -- Remove after duration
    task.delay(duration, function()
        local fadeOut = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local tween = game:GetService("TweenService"):Create(notification, fadeOut, {
            Position = UDim2.new(0.5, -100, 0, -50),
            BackgroundTransparency = 1
        })
        tween:Play()
        
        tween.Completed:Connect(function()
            notification:Destroy()
        end)
    end)
end

return UIManager 