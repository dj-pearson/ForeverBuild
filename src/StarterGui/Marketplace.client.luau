local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local MarketplaceUI = {}

-- UI Elements
local screenGui
local mainFrame
local itemGrid
local toolGrid
local closeButton
local bulkPurchaseButton
local quantitySelector
local selectedItems = {}

-- Remote events
local purchaseObjectEvent = ReplicatedStorage.Remotes.PurchaseObject
local purchaseToolEvent = ReplicatedStorage.Remotes.PurchaseTool

-- Create UI
function MarketplaceUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MarketplaceUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 800, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Create title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Marketplace"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 32
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Create item grid
    itemGrid = Instance.new("Frame")
    itemGrid.Name = "ItemGrid"
    itemGrid.Size = UDim2.new(1, -40, 0, 400)
    itemGrid.Position = UDim2.new(0, 20, 0, 60)
    itemGrid.BackgroundTransparency = 1
    itemGrid.Parent = mainFrame
    
    -- Create tool grid
    toolGrid = Instance.new("Frame")
    toolGrid.Name = "ToolGrid"
    toolGrid.Size = UDim2.new(1, -40, 0, 100)
    toolGrid.Position = UDim2.new(0, 20, 0, 470)
    toolGrid.BackgroundTransparency = 1
    toolGrid.Parent = mainFrame
    
    -- Create bulk purchase button
    bulkPurchaseButton = Instance.new("TextButton")
    bulkPurchaseButton.Name = "BulkPurchaseButton"
    bulkPurchaseButton.Size = UDim2.new(0, 200, 0, 50)
    bulkPurchaseButton.Position = UDim2.new(0.5, -100, 1, -70)
    bulkPurchaseButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    bulkPurchaseButton.BorderSizePixel = 0
    bulkPurchaseButton.Text = "Bulk Purchase"
    bulkPurchaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    bulkPurchaseButton.TextSize = 24
    bulkPurchaseButton.Font = Enum.Font.GothamBold
    bulkPurchaseButton.Parent = mainFrame
    
    -- Create quantity selector
    quantitySelector = Instance.new("Frame")
    quantitySelector.Name = "QuantitySelector"
    quantitySelector.Size = UDim2.new(0, 200, 0, 50)
    quantitySelector.Position = UDim2.new(0.5, -100, 1, -130)
    quantitySelector.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    quantitySelector.BorderSizePixel = 0
    quantitySelector.Visible = false
    quantitySelector.Parent = mainFrame
    
    -- Create quantity buttons
    local minusButton = Instance.new("TextButton")
    minusButton.Name = "MinusButton"
    minusButton.Size = UDim2.new(0, 50, 1, 0)
    minusButton.Position = UDim2.new(0, 0, 0, 0)
    minusButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    minusButton.BorderSizePixel = 0
    minusButton.Text = "-"
    minusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minusButton.TextSize = 24
    minusButton.Font = Enum.Font.GothamBold
    minusButton.Parent = quantitySelector
    
    local quantityLabel = Instance.new("TextLabel")
    quantityLabel.Name = "QuantityLabel"
    quantityLabel.Size = UDim2.new(0, 100, 1, 0)
    quantityLabel.Position = UDim2.new(0, 50, 0, 0)
    quantityLabel.BackgroundTransparency = 1
    quantityLabel.Text = "1"
    quantityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    quantityLabel.TextSize = 24
    quantityLabel.Font = Enum.Font.GothamBold
    quantityLabel.Parent = quantitySelector
    
    local plusButton = Instance.new("TextButton")
    plusButton.Name = "PlusButton"
    plusButton.Size = UDim2.new(0, 50, 1, 0)
    plusButton.Position = UDim2.new(0, 150, 0, 0)
    plusButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    plusButton.BorderSizePixel = 0
    plusButton.Text = "+"
    plusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    plusButton.TextSize = 24
    plusButton.Font = Enum.Font.GothamBold
    plusButton.Parent = quantitySelector
    
    -- Create close button
    closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -50, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 24
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame
    
    -- Set up button events
    minusButton.MouseButton1Click:Connect(function()
        local currentQuantity = tonumber(quantityLabel.Text)
        if currentQuantity > 1 then
            quantityLabel.Text = tostring(currentQuantity - 1)
        end
    end)
    
    plusButton.MouseButton1Click:Connect(function()
        local currentQuantity = tonumber(quantityLabel.Text)
        if currentQuantity < 10 then
            quantityLabel.Text = tostring(currentQuantity + 1)
        end
    end)
    
    bulkPurchaseButton.MouseButton1Click:Connect(function()
        if #selectedItems > 0 then
            quantitySelector.Visible = true
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        quantitySelector.Visible = false
    end)
end

-- Create item button
function MarketplaceUI.createItemButton(item, parent)
    local button = Instance.new("TextButton")
    button.Name = item.id
    button.Size = Constants.UI.MARKETPLACE_GRID_SIZE
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.BorderSizePixel = 0
    button.Text = item.name .. "\n" .. item.price .. " Coins"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.Font = Enum.Font.Gotham
    button.Parent = parent
    
    -- Create preview image
    local image = Instance.new("ImageLabel")
    image.Name = "PreviewImage"
    image.Size = UDim2.new(0.8, 0, 0.8, 0)
    image.Position = UDim2.new(0.1, 0, 0.1, 0)
    image.BackgroundTransparency = 1
    image.Image = item.previewImage
    image.Parent = button
    
    -- Set up button events
    button.MouseButton1Click:Connect(function()
        if selectedItems[item.id] then
            selectedItems[item.id] = nil
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        else
            selectedItems[item.id] = item
            button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        end
    end)
    
    return button
end

-- Set marketplace items
function MarketplaceUI.setItems(items)
    -- Clear existing items
    for _, child in ipairs(itemGrid:GetChildren()) do
        child:Destroy()
    end
    
    -- Create new item buttons
    local x, y = 0, 0
    for _, item in ipairs(items) do
        local button = MarketplaceUI.createItemButton(item, itemGrid)
        button.Position = UDim2.new(0, x * 110, 0, y * 110)
        
        x = x + 1
        if x >= 6 then
            x = 0
            y = y + 1
        end
    end
end

-- Set available tools
function MarketplaceUI.setTools(tools)
    -- Clear existing tools
    for _, child in ipairs(toolGrid:GetChildren()) do
        child:Destroy()
    end
    
    -- Create new tool buttons
    local x = 0
    for _, tool in ipairs(tools) do
        local button = Instance.new("TextButton")
        button.Name = tool.type
        button.Size = UDim2.new(0, 200, 0, 50)
        button.Position = UDim2.new(0, x * 210, 0, 0)
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        button.BorderSizePixel = 0
        button.Text = tool.name .. "\n" .. Constants.TOOL_PRICES[tool.type] .. " Coins"
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 16
        button.Font = Enum.Font.Gotham
        button.Parent = toolGrid
        
        -- Set up button events
        button.MouseButton1Click:Connect(function()
            purchaseToolEvent:FireServer(tool.type)
        end)
        
        x = x + 1
    end
end

-- Show UI
function MarketplaceUI.show()
    mainFrame.Visible = true
    selectedItems = {}
end

-- Hide UI
function MarketplaceUI.hide()
    mainFrame.Visible = false
    quantitySelector.Visible = false
    selectedItems = {}
end

-- Initialize
function MarketplaceUI.init()
    MarketplaceUI.create()
end

return MarketplaceUI 