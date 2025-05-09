local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local MarketplaceUI = {}

-- UI Elements
local screenGui
local marketplaceFrame
local itemGrid = {}

-- Create UI
function MarketplaceUI.createUI()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MarketplaceUI"
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    marketplaceFrame = Instance.new("Frame")
    marketplaceFrame.Name = "MarketplaceFrame"
    marketplaceFrame.Size = UDim2.new(0, 600, 0, 700)
    marketplaceFrame.Position = UDim2.new(0.5, -300, 0.5, -350)
    marketplaceFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    marketplaceFrame.BorderSizePixel = 0
    marketplaceFrame.Visible = false
    marketplaceFrame.Parent = screenGui
    
    -- Create title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    title.Text = "Marketplace"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 28
    title.Font = Enum.Font.GothamBold
    title.Parent = marketplaceFrame
    
    -- Create close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -50, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = marketplaceFrame
    
    -- Create grid layout
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = Constants.UI.MARKETPLACE_GRID_SIZE
    gridLayout.CellPadding = UDim2.new(0, 15, 0, 15)
    gridLayout.Parent = marketplaceFrame
    
    -- Create item grid
    local itemsPerRow = 4
    local itemsPerColumn = 5
    local totalItems = itemsPerRow * itemsPerColumn
    
    for i = 1, totalItems do
        local itemFrame = Instance.new("Frame")
        itemFrame.Name = "Item" .. i
        itemFrame.Size = Constants.UI.MARKETPLACE_GRID_SIZE
        itemFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        itemFrame.BorderSizePixel = 0
        itemFrame.Parent = marketplaceFrame
        
        -- Create item preview
        local preview = Instance.new("ImageLabel")
        preview.Name = "Preview"
        preview.Size = UDim2.new(0.8, 0, 0.6, 0)
        preview.Position = UDim2.new(0.1, 0, 0.1, 0)
        preview.BackgroundTransparency = 1
        preview.Image = "rbxassetid://" -- Add default image ID
        preview.Parent = itemFrame
        
        -- Create item name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "Name"
        nameLabel.Size = UDim2.new(0.9, 0, 0, 20)
        nameLabel.Position = UDim2.new(0.05, 0, 0.75, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "Item Name"
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 16
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.Parent = itemFrame
        
        -- Create price label
        local priceLabel = Instance.new("TextLabel")
        priceLabel.Name = "Price"
        priceLabel.Size = UDim2.new(0.9, 0, 0, 20)
        priceLabel.Position = UDim2.new(0.05, 0, 0.9, 0)
        priceLabel.BackgroundTransparency = 1
        priceLabel.Text = "0 R$"
        priceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        priceLabel.TextSize = 14
        priceLabel.Font = Enum.Font.Gotham
        priceLabel.Parent = itemFrame
        
        -- Create purchase button
        local purchaseButton = Instance.new("TextButton")
        purchaseButton.Name = "PurchaseButton"
        purchaseButton.Size = UDim2.new(0.8, 0, 0, 30)
        purchaseButton.Position = UDim2.new(0.1, 0, 0.85, 0)
        purchaseButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        purchaseButton.Text = "Purchase"
        purchaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        purchaseButton.TextSize = 14
        purchaseButton.Font = Enum.Font.GothamBold
        purchaseButton.Visible = false
        purchaseButton.Parent = itemFrame
        
        -- Store reference
        itemGrid[i] = {
            frame = itemFrame,
            preview = preview,
            nameLabel = nameLabel,
            priceLabel = priceLabel,
            purchaseButton = purchaseButton
        }
        
        -- Add hover effects
        itemFrame.MouseEnter:Connect(function()
            purchaseButton.Visible = true
        end)
        
        itemFrame.MouseLeave:Connect(function()
            purchaseButton.Visible = false
        end)
    end
    
    -- Connect close button
    closeButton.MouseButton1Click:Connect(function()
        marketplaceFrame.Visible = false
    end)
end

-- Update marketplace display
function MarketplaceUI.updateMarketplace(items)
    for i, item in ipairs(items) do
        if i <= #itemGrid then
            local gridItem = itemGrid[i]
            
            -- Update item details
            gridItem.preview.Image = item.previewImage
            gridItem.nameLabel.Text = item.name
            gridItem.priceLabel.Text = tostring(item.price) .. " R$"
            
            -- Connect purchase button
            gridItem.purchaseButton.MouseButton1Click:Connect(function()
                -- Fire purchase event
                local remotes = ReplicatedStorage:WaitForChild("Remotes")
                local purchaseEvent = remotes:WaitForChild("PurchaseObject")
                purchaseEvent:FireServer(item.objectType)
            end)
        end
    end
end

-- Toggle marketplace visibility
function MarketplaceUI.toggle()
    marketplaceFrame.Visible = not marketplaceFrame.Visible
end

-- Initialize
function MarketplaceUI.init()
    MarketplaceUI.createUI()
    print("Marketplace UI initialized")
end

return MarketplaceUI 