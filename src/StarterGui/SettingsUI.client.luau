local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local SettingsUI = {}

-- UI Elements
local screenGui
local mainFrame
local settingsList
local closeButton

-- Create UI
function SettingsUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SettingsUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.4, 0, 0.6, 0)
    mainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Create title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    title.BorderSizePixel = 0
    title.Text = "Settings"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Create settings list
    settingsList = Instance.new("ScrollingFrame")
    settingsList.Name = "SettingsList"
    settingsList.Size = UDim2.new(1, -20, 1, -50)
    settingsList.Position = UDim2.new(0, 10, 0, 50)
    settingsList.BackgroundTransparency = 1
    settingsList.BorderSizePixel = 0
    settingsList.ScrollBarThickness = 6
    settingsList.CanvasSize = UDim2.new(0, 0, 0, 0)
    settingsList.Parent = mainFrame
    
    -- Create close button
    closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame
    
    -- Set up button events
    closeButton.MouseButton1Click:Connect(function()
        SettingsUI.hide()
    end)
end

-- Create setting
function SettingsUI.createSetting(name, type, value, callback)
    local setting = Instance.new("Frame")
    setting.Name = name
    setting.Size = UDim2.new(1, 0, 0, 50)
    setting.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    setting.BorderSizePixel = 0
    setting.Parent = settingsList
    
    -- Create name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(0.5, -10, 1, 0)
    nameLabel.Position = UDim2.new(0, 10, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = setting
    
    -- Create control based on type
    if type == "toggle" then
        local toggle = Instance.new("TextButton")
        toggle.Name = "Toggle"
        toggle.Size = UDim2.new(0, 40, 0, 20)
        toggle.Position = UDim2.new(1, -50, 0, 15)
        toggle.BackgroundColor3 = value and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
        toggle.BorderSizePixel = 0
        toggle.Text = ""
        toggle.Parent = setting
        
        -- Create toggle handle
        local handle = Instance.new("Frame")
        handle.Name = "Handle"
        handle.Size = UDim2.new(0, 16, 0, 16)
        handle.Position = UDim2.new(value and 1 or 0, -2, 0, 2)
        handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        handle.BorderSizePixel = 0
        handle.Parent = toggle
        
        -- Set up toggle events
        toggle.MouseButton1Click:Connect(function()
            value = not value
            toggle.BackgroundColor3 = value and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
            
            local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(handle, tweenInfo, {
                Position = UDim2.new(value and 1 or 0, -2, 0, 2)
            })
            tween:Play()
            
            if callback then
                callback(value)
            end
        end)
    elseif type == "slider" then
        local slider = Instance.new("Frame")
        slider.Name = "Slider"
        slider.Size = UDim2.new(0, 200, 0, 4)
        slider.Position = UDim2.new(1, -210, 0, 23)
        slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        slider.BorderSizePixel = 0
        slider.Parent = setting
        
        local fill = Instance.new("Frame")
        fill.Name = "Fill"
        fill.Size = UDim2.new(value, 0, 1, 0)
        fill.Position = UDim2.new(0, 0, 0, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        fill.BorderSizePixel = 0
        fill.Parent = slider
        
        local handle = Instance.new("Frame")
        handle.Name = "Handle"
        handle.Size = UDim2.new(0, 16, 0, 16)
        handle.Position = UDim2.new(value, 0, 0, -6)
        handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        handle.BorderSizePixel = 0
        handle.Parent = slider
        
        -- Create value label
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Name = "Value"
        valueLabel.Size = UDim2.new(0, 40, 0, 20)
        valueLabel.Position = UDim2.new(1, -50, 0, 15)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = string.format("%d%%", math.floor(value * 100))
        valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        valueLabel.TextSize = 14
        valueLabel.Font = Enum.Font.Gotham
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = setting
        
        -- Set up slider events
        local dragging = false
        
        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        handle.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                local sliderPos = slider.AbsolutePosition
                local sliderSize = slider.AbsoluteSize
                
                local newValue = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
                value = newValue
                
                fill.Size = UDim2.new(value, 0, 1, 0)
                handle.Position = UDim2.new(value, 0, 0, -6)
                valueLabel.Text = string.format("%d%%", math.floor(value * 100))
                
                if callback then
                    callback(value)
                end
            end
        end)
    elseif type == "dropdown" then
        local dropdown = Instance.new("TextButton")
        dropdown.Name = "Dropdown"
        dropdown.Size = UDim2.new(0, 200, 0, 30)
        dropdown.Position = UDim2.new(1, -210, 0, 10)
        dropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        dropdown.BorderSizePixel = 0
        dropdown.Text = value
        dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropdown.TextSize = 14
        dropdown.Font = Enum.Font.Gotham
        dropdown.Parent = setting
        
        -- Create dropdown list
        local list = Instance.new("Frame")
        list.Name = "List"
        list.Size = UDim2.new(1, 0, 0, 0)
        list.Position = UDim2.new(0, 0, 1, 0)
        list.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        list.BorderSizePixel = 0
        list.Visible = false
        list.Parent = dropdown
        
        -- Set up dropdown events
        dropdown.MouseButton1Click:Connect(function()
            list.Visible = not list.Visible
            
            if list.Visible then
                -- Create options
                for _, option in ipairs(value.options) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Name = option
                    optionButton.Size = UDim2.new(1, 0, 0, 30)
                    optionButton.Position = UDim2.new(0, 0, 0, #list:GetChildren() * 30)
                    optionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    optionButton.BorderSizePixel = 0
                    optionButton.Text = option
                    optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    optionButton.TextSize = 14
                    optionButton.Font = Enum.Font.Gotham
                    optionButton.Parent = list
                    
                    optionButton.MouseButton1Click:Connect(function()
                        value = option
                        dropdown.Text = value
                        list.Visible = false
                        
                        if callback then
                            callback(value)
                        end
                    end)
                end
                
                list.Size = UDim2.new(1, 0, 0, #value.options * 30)
            end
        end)
    end
    
    return setting
end

-- Show UI
function SettingsUI.show()
    mainFrame.Visible = true
    
    -- Animate in
    mainFrame.Position = UDim2.new(0.3, 0, 0.4, 0)
    mainFrame.BackgroundTransparency = 1
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        Position = UDim2.new(0.3, 0, 0.2, 0),
        BackgroundTransparency = 0
    })
    tween:Play()
end

-- Hide UI
function SettingsUI.hide()
    -- Animate out
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local tween = TweenService:Create(mainFrame, tweenInfo, {
        Position = UDim2.new(0.3, 0, 0.4, 0),
        BackgroundTransparency = 1
    })
    tween:Play()
    
    -- Hide after animation
    task.delay(0.5, function()
        mainFrame.Visible = false
    end)
end

-- Update settings
function SettingsUI.updateSettings(settings)
    -- Clear existing settings
    for _, child in ipairs(settingsList:GetChildren()) do
        child:Destroy()
    end
    
    -- Add new settings
    local yOffset = 0
    for _, setting in ipairs(settings) do
        local settingFrame = SettingsUI.createSetting(setting.name, setting.type, setting.value, setting.callback)
        settingFrame.Position = UDim2.new(0, 0, 0, yOffset)
        yOffset = yOffset + 60
    end
    
    -- Update canvas size
    settingsList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Initialize
function SettingsUI.init()
    SettingsUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.SettingsUpdate, function(settings)
        SettingsUI.updateSettings(settings)
    end)
    
    -- Set up keyboard shortcut
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.F3 then
            if mainFrame.Visible then
                SettingsUI.hide()
            else
                SettingsUI.show()
            end
        end
    end)
end

return SettingsUI 