local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local InventoryUI = {}

-- UI Elements
local screenGui
local mainFrame
local itemList
local closeButton

-- Create UI
function InventoryUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "InventoryUI"
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
    title.Text = "Inventory"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Create item list
    itemList = Instance.new("ScrollingFrame")
    itemList.Name = "ItemList"
    itemList.Size = UDim2.new(1, -20, 1, -50)
    itemList.Position = UDim2.new(0, 10, 0, 50)
    itemList.BackgroundTransparency = 1
    itemList.BorderSizePixel = 0
    itemList.ScrollBarThickness = 6
    itemList.CanvasSize = UDim2.new(0, 0, 0, 0)
    itemList.Parent = mainFrame
    
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
        InventoryUI.hide()
    end)
end

-- Create item slot
function InventoryUI.createItemSlot(item)
    local slot = Instance.new("Frame")
    slot.Name = item.id
    slot.Size = UDim2.new(1, 0, 0, 60)
    slot.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    slot.BorderSizePixel = 0
    slot.Parent = itemList
    
    -- Create item icon
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 40, 0, 40)
    icon.Position = UDim2.new(0, 10, 0, 10)
    icon.BackgroundTransparency = 1
    icon.Image = item.icon
    icon.Parent = slot
    
    -- Create item name
    local name = Instance.new("TextLabel")
    name.Name = "Name"
    name.Size = UDim2.new(0.5, -60, 0, 20)
    name.Position = UDim2.new(0, 60, 0, 10)
    name.BackgroundTransparency = 1
    name.Text = item.name
    name.TextColor3 = Color3.fromRGB(255, 255, 255)
    name.TextSize = 16
    name.Font = Enum.Font.GothamBold
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = slot
    
    -- Create item description
    local description = Instance.new("TextLabel")
    description.Name = "Description"
    description.Size = UDim2.new(0.5, -60, 0, 20)
    description.Position = UDim2.new(0, 60, 0, 30)
    description.BackgroundTransparency = 1
    description.Text = item.description
    description.TextColor3 = Color3.fromRGB(200, 200, 200)
    description.TextSize = 14
    description.Font = Enum.Font.Gotham
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.Parent = slot
    
    -- Create item count
    local count = Instance.new("TextLabel")
    count.Name = "Count"
    count.Size = UDim2.new(0, 40, 0, 20)
    count.Position = UDim2.new(1, -50, 0, 20)
    count.BackgroundTransparency = 1
    count.Text = tostring(item.count)
    count.TextColor3 = Color3.fromRGB(255, 255, 255)
    count.TextSize = 16
    count.Font = Enum.Font.GothamBold
    count.TextXAlignment = Enum.TextXAlignment.Right
    count.Parent = slot
    
    -- Set up click events
    slot.MouseButton1Click:Connect(function()
        RemoteManager:fireServer(Constants.RemoteEvents.UseItem, item.id)
    end)
    
    -- Set up hover effects
    slot.MouseEnter:Connect(function()
        slot.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    end)
    
    slot.MouseLeave:Connect(function()
        slot.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end)
    
    return slot
end

-- Show UI
function InventoryUI.show()
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
function InventoryUI.hide()
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

-- Update inventory
function InventoryUI.updateInventory(items)
    -- Clear existing items
    for _, child in ipairs(itemList:GetChildren()) do
        child:Destroy()
    end
    
    -- Add new items
    local yOffset = 0
    for _, item in ipairs(items) do
        local slot = InventoryUI.createItemSlot(item)
        slot.Position = UDim2.new(0, 0, 0, yOffset)
        yOffset = yOffset + 70
    end
    
    -- Update canvas size
    itemList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Initialize
function InventoryUI.init()
    InventoryUI.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.InventoryUpdate, function(items)
        InventoryUI.updateInventory(items)
    end)
    
    -- Set up keyboard shortcut
    local UserInputService = game:GetService("UserInputService")
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.I then
            if mainFrame.Visible then
                InventoryUI.hide()
            else
                InventoryUI.show()
            end
        end
    end)
end

return InventoryUI 