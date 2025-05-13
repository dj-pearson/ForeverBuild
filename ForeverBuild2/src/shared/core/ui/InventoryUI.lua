-- InventoryUI.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Constants = require(script.Parent.Parent.Constants)

local InventoryUI = {}

-- UI Constants
local INVENTORY_SIZE = UDim2.new(0, 600, 0, 400)
local INVENTORY_POSITION = UDim2.new(0.5, -300, 0.5, -200)
local ANIMATION_DURATION = 0.3
local ITEM_SIZE = UDim2.new(0, 100, 0, 120)
local ITEMS_PER_ROW = 5
local ITEM_PADDING = 10

-- Create the inventory UI
local function createInventory(parent)
    local inventory = Instance.new("Frame")
    inventory.Name = "InventoryUI"
    inventory.Size = INVENTORY_SIZE
    inventory.Position = INVENTORY_POSITION
    inventory.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    inventory.BorderSizePixel = 0
    inventory.Visible = false
    inventory.Parent = parent
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = inventory
    
    -- Add shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.ZIndex = -1
    shadow.Parent = inventory
    
    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = inventory
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "Inventory"
    title.TextSize = 24
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    local currency = Instance.new("TextLabel")
    currency.Name = "Currency"
    currency.Size = UDim2.new(0, 100, 1, 0)
    currency.Position = UDim2.new(1, -120, 0, 0)
    currency.BackgroundTransparency = 1
    currency.Font = Enum.Font.GothamBold
    currency.Text = "0"
    currency.TextSize = 20
    currency.TextColor3 = Color3.fromRGB(255, 215, 0)
    currency.TextXAlignment = Enum.TextXAlignment.Right
    currency.Parent = titleBar
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "X"
    closeButton.TextSize = 18
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton
    
    -- Items container
    local itemsContainer = Instance.new("ScrollingFrame")
    itemsContainer.Name = "ItemsContainer"
    itemsContainer.Size = UDim2.new(1, -40, 1, -70)
    itemsContainer.Position = UDim2.new(0, 20, 0, 60)
    itemsContainer.BackgroundTransparency = 1
    itemsContainer.BorderSizePixel = 0
    itemsContainer.ScrollBarThickness = 6
    itemsContainer.ScrollingDirection = Enum.ScrollingDirection.Y
    itemsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    itemsContainer.Parent = inventory
    
    -- Create grid layout
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = ITEM_SIZE
    gridLayout.CellPadding = UDim2.new(0, ITEM_PADDING, 0, ITEM_PADDING)
    gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    gridLayout.Parent = itemsContainer
    
    return inventory
end

-- Create an item button
local function createItemButton(itemName, itemData, quantity)
    local button = Instance.new("TextButton")
    button.Name = itemName
    button.Size = ITEM_SIZE
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.AutoButtonColor = false
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    -- Item icon (placeholder)
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(1, -20, 0, 60)
    icon.Position = UDim2.new(0, 10, 0, 10)
    icon.BackgroundTransparency = 1
    icon.Image = itemData.icon or "rbxassetid://0" -- Replace with actual icon
    icon.Parent = button
    
    -- Item name
    local name = Instance.new("TextLabel")
    name.Name = "Name"
    name.Size = UDim2.new(1, -20, 0, 20)
    name.Position = UDim2.new(0, 10, 0, 80)
    name.BackgroundTransparency = 1
    name.Font = Enum.Font.GothamBold
    name.Text = itemName
    name.TextSize = 14
    name.TextColor3 = Color3.new(1, 1, 1)
    name.TextTruncate = Enum.TextTruncate.AtEnd
    name.Parent = button
    
    -- Quantity
    local quantityLabel = Instance.new("TextLabel")
    quantityLabel.Name = "Quantity"
    quantityLabel.Size = UDim2.new(1, -20, 0, 20)
    quantityLabel.Position = UDim2.new(0, 10, 0, 100)
    quantityLabel.BackgroundTransparency = 1
    quantityLabel.Font = Enum.Font.Gotham
    quantityLabel.Text = "x" .. quantity
    quantityLabel.TextSize = 14
    quantityLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    quantityLabel.Parent = button
    
    -- Hover effect
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        }):Play()
    end)
    
    return button
end

-- Initialize the inventory UI
function InventoryUI.Initialize(parent)
    local inventory = createInventory(parent)
    
    -- Set up close button
    inventory.TitleBar.CloseButton.MouseButton1Click:Connect(function()
        InventoryUI.Hide()
    end)
    
    -- Store inventory reference
    InventoryUI._inventory = inventory
end

-- Update inventory display
function InventoryUI.UpdateInventory(inventory, currency)
    local ui = InventoryUI._inventory
    if not ui then return end
    
    -- Update currency
    ui.TitleBar.Currency.Text = tostring(currency or 0)
    
    -- Clear existing items
    local container = ui.ItemsContainer
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Add items
    local itemCount = 0
    for itemName, quantity in pairs(inventory) do
        if quantity > 0 then
            local itemData = Constants.ITEMS[itemName]
            if itemData then
                local button = createItemButton(itemName, itemData, quantity)
                button.Parent = container
                
                -- Set up click handler
                button.MouseButton1Click:Connect(function()
                    if InventoryUI.OnItemSelected then
                        InventoryUI.OnItemSelected(itemName)
                    end
                end)
                
                itemCount = itemCount + 1
            end
        end
    end
    
    -- Update canvas size
    local rows = math.ceil(itemCount / ITEMS_PER_ROW)
    container.CanvasSize = UDim2.new(0, 0, 0, rows * (ITEM_SIZE.Y.Offset + ITEM_PADDING) + ITEM_PADDING)
end

-- Show the inventory
function InventoryUI.Show()
    local inventory = InventoryUI._inventory
    if not inventory then return end
    
    inventory.Visible = true
    inventory.BackgroundTransparency = 1
    
    local showTween = TweenService:Create(inventory, TweenInfo.new(ANIMATION_DURATION), {
        BackgroundTransparency = 0
    })
    showTween:Play()
end

-- Hide the inventory
function InventoryUI.Hide()
    local inventory = InventoryUI._inventory
    if not inventory then return end
    
    local hideTween = TweenService:Create(inventory, TweenInfo.new(ANIMATION_DURATION), {
        BackgroundTransparency = 1
    })
    
    hideTween.Completed:Connect(function()
        inventory.Visible = false
    end)
    
    hideTween:Play()
end

return InventoryUI 