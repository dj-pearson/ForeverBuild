local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local Marketplace = {}

-- UI Elements
local screenGui
local mainFrame
local itemList
local closeButton

-- Create UI
function Marketplace.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MarketplaceUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.5, 0, 0.7, 0)
    mainFrame.Position = UDim2.new(0.25, 0, 0.15, 0)
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
    title.Text = "Marketplace"
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
        Marketplace.hide()
    end)
end

-- Show UI
function Marketplace.show()
    mainFrame.Visible = true
end

-- Hide UI
function Marketplace.hide()
    mainFrame.Visible = false
end

-- Update item list
function Marketplace.updateItems(items)
    -- Clear existing items
    for _, child in ipairs(itemList:GetChildren()) do
        child:Destroy()
    end
    
    -- Add new items
    local yOffset = 0
    for _, item in ipairs(items) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Name = item.id
        itemFrame.Size = UDim2.new(1, 0, 0, 100)
        itemFrame.Position = UDim2.new(0, 0, 0, yOffset)
        itemFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        itemFrame.BorderSizePixel = 0
        itemFrame.Parent = itemList
        
        -- Item image
        local image = Instance.new("ImageLabel")
        image.Name = "Image"
        image.Size = UDim2.new(0, 80, 0, 80)
        image.Position = UDim2.new(0, 10, 0, 10)
        image.BackgroundTransparency = 1
        image.Image = item.imageUrl
        image.Parent = itemFrame
        
        -- Item name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "Name"
        nameLabel.Size = UDim2.new(0.6, -20, 0, 30)
        nameLabel.Position = UDim2.new(0, 100, 0, 10)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = item.name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 18
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = itemFrame
        
        -- Item description
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "Description"
        descLabel.Size = UDim2.new(0.6, -20, 0, 40)
        descLabel.Position = UDim2.new(0, 100, 0, 40)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = item.description
        descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        descLabel.TextSize = 14
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextWrapped = true
        descLabel.Parent = itemFrame
        
        -- Item price
        local priceLabel = Instance.new("TextLabel")
        priceLabel.Name = "Price"
        priceLabel.Size = UDim2.new(0, 100, 0, 30)
        priceLabel.Position = UDim2.new(1, -110, 0, 10)
        priceLabel.BackgroundTransparency = 1
        priceLabel.Text = item.price .. " coins"
        priceLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        priceLabel.TextSize = 16
        priceLabel.Font = Enum.Font.GothamBold
        priceLabel.TextXAlignment = Enum.TextXAlignment.Right
        priceLabel.Parent = itemFrame
        
        -- Buy button
        local buyButton = Instance.new("TextButton")
        buyButton.Name = "BuyButton"
        buyButton.Size = UDim2.new(0, 100, 0, 30)
        buyButton.Position = UDim2.new(1, -110, 0, 50)
        buyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        buyButton.BorderSizePixel = 0
        buyButton.Text = "Buy"
        buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        buyButton.TextSize = 16
        buyButton.Font = Enum.Font.Gotham
        buyButton.Parent = itemFrame
        
        -- Set up buy button event
        buyButton.MouseButton1Click:Connect(function()
            RemoteManager:fireServer(Constants.RemoteEvents.PurchaseItem, item.id)
        end)
        
        yOffset = yOffset + 110
    end
    
    -- Update canvas size
    itemList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Initialize
function Marketplace.init()
    Marketplace.create()
    
    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.ItemUpdate, function(items)
        Marketplace.updateItems(items)
    end)
end

return Marketplace 