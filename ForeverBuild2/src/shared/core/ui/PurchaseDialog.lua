-- PurchaseDialog.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Constants = require(script.Parent.Parent.Constants)

local PurchaseDialog = {}

-- UI Constants
local DIALOG_SIZE = UDim2.new(0, 400, 0, 300)
local DIALOG_POSITION = UDim2.new(0.5, -200, 0.5, -150)
local ANIMATION_DURATION = 0.3

-- Create the dialog UI
local function createDialog(parent)
    local dialog = Instance.new("Frame")
    dialog.Name = "PurchaseDialog"
    dialog.Size = DIALOG_SIZE
    dialog.Position = DIALOG_POSITION
    dialog.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    dialog.BorderSizePixel = 0
    dialog.Visible = false
    dialog.Parent = parent
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = dialog
    
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
    shadow.Parent = dialog
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Parent = dialog
    
    -- Item info
    local itemInfo = Instance.new("TextLabel")
    itemInfo.Name = "ItemInfo"
    itemInfo.Size = UDim2.new(1, -40, 0, 60)
    itemInfo.Position = UDim2.new(0, 20, 0, 50)
    itemInfo.BackgroundTransparency = 1
    itemInfo.Font = Enum.Font.Gotham
    itemInfo.TextSize = 16
    itemInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
    itemInfo.TextWrapped = true
    itemInfo.Parent = dialog
    
    -- Price
    local price = Instance.new("TextLabel")
    price.Name = "Price"
    price.Size = UDim2.new(1, -40, 0, 30)
    price.Position = UDim2.new(0, 20, 0, 120)
    price.BackgroundTransparency = 1
    price.Font = Enum.Font.GothamBold
    price.TextSize = 20
    price.TextColor3 = Color3.fromRGB(255, 215, 0)
    price.Parent = dialog
    
    -- Quantity selector
    local quantityFrame = Instance.new("Frame")
    quantityFrame.Name = "QuantityFrame"
    quantityFrame.Size = UDim2.new(1, -40, 0, 40)
    quantityFrame.Position = UDim2.new(0, 20, 0, 160)
    quantityFrame.BackgroundTransparency = 1
    quantityFrame.Parent = dialog
    
    local minusButton = Instance.new("TextButton")
    minusButton.Name = "MinusButton"
    minusButton.Size = UDim2.new(0, 40, 1, 0)
    minusButton.Position = UDim2.new(0, 0, 0, 0)
    minusButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    minusButton.Font = Enum.Font.GothamBold
    minusButton.Text = "-"
    minusButton.TextSize = 24
    minusButton.TextColor3 = Color3.new(1, 1, 1)
    minusButton.Parent = quantityFrame
    
    local quantityLabel = Instance.new("TextLabel")
    quantityLabel.Name = "Quantity"
    quantityLabel.Size = UDim2.new(1, -80, 1, 0)
    quantityLabel.Position = UDim2.new(0, 40, 0, 0)
    quantityLabel.BackgroundTransparency = 1
    quantityLabel.Font = Enum.Font.GothamBold
    quantityLabel.Text = "1"
    quantityLabel.TextSize = 20
    quantityLabel.TextColor3 = Color3.new(1, 1, 1)
    quantityLabel.Parent = quantityFrame
    
    local plusButton = Instance.new("TextButton")
    plusButton.Name = "PlusButton"
    plusButton.Size = UDim2.new(0, 40, 1, 0)
    plusButton.Position = UDim2.new(1, -40, 0, 0)
    plusButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    plusButton.Font = Enum.Font.GothamBold
    plusButton.Text = "+"
    plusButton.TextSize = 24
    plusButton.TextColor3 = Color3.new(1, 1, 1)
    plusButton.Parent = quantityFrame
    
    -- Add corner radius to buttons
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = minusButton
    
    local plusButtonCorner = buttonCorner:Clone()
    plusButtonCorner.Parent = plusButton
    
    -- Buttons
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Name = "ButtonFrame"
    buttonFrame.Size = UDim2.new(1, -40, 0, 40)
    buttonFrame.Position = UDim2.new(0, 20, 1, -60)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = dialog
    
    local cancelButton = Instance.new("TextButton")
    cancelButton.Name = "CancelButton"
    cancelButton.Size = UDim2.new(0.5, -10, 1, 0)
    cancelButton.Position = UDim2.new(0, 0, 0, 0)
    cancelButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    cancelButton.Font = Enum.Font.GothamBold
    cancelButton.Text = "Cancel"
    cancelButton.TextSize = 18
    cancelButton.TextColor3 = Color3.new(1, 1, 1)
    cancelButton.Parent = buttonFrame
    
    local purchaseButton = Instance.new("TextButton")
    purchaseButton.Name = "PurchaseButton"
    purchaseButton.Size = UDim2.new(0.5, -10, 1, 0)
    purchaseButton.Position = UDim2.new(0.5, 10, 0, 0)
    purchaseButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    purchaseButton.Font = Enum.Font.GothamBold
    purchaseButton.Text = "Purchase"
    purchaseButton.TextSize = 18
    purchaseButton.TextColor3 = Color3.new(1, 1, 1)
    purchaseButton.Parent = buttonFrame
    
    -- Add corner radius to buttons
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = cancelButton
    
    local purchaseButtonCorner = buttonCorner:Clone()
    purchaseButtonCorner.Parent = purchaseButton
    
    return dialog
end

-- Initialize the dialog
function PurchaseDialog.Initialize(parent)
    local dialog = createDialog(parent)
    local quantity = 1
    local currentItem = nil
    local onPurchase = nil
    
    -- Update price display
    local function updatePrice()
        if not currentItem then return end
        local itemData = Constants.ITEMS[currentItem]
        if not itemData then return end
        
        local totalPrice = itemData.price * quantity
        dialog.Price.Text = string.format("Price: %d", totalPrice)
    end
    
    -- Update quantity
    local function updateQuantity(newQuantity)
        quantity = math.max(1, math.min(99, newQuantity))
        dialog.QuantityFrame.Quantity.Text = tostring(quantity)
        updatePrice()
    end
    
    -- Set up quantity buttons
    dialog.QuantityFrame.MinusButton.MouseButton1Click:Connect(function()
        updateQuantity(quantity - 1)
    end)
    
    dialog.QuantityFrame.PlusButton.MouseButton1Click:Connect(function()
        updateQuantity(quantity + 1)
    end)
    
    -- Set up purchase button
    dialog.ButtonFrame.PurchaseButton.MouseButton1Click:Connect(function()
        if onPurchase then
            onPurchase(quantity)
        end
        PurchaseDialog.Hide()
    end)
    
    -- Set up cancel button
    dialog.ButtonFrame.CancelButton.MouseButton1Click:Connect(function()
        PurchaseDialog.Hide()
    end)
    
    -- Store dialog reference
    PurchaseDialog._dialog = dialog
end

-- Show the dialog
function PurchaseDialog.Show(itemName, callback)
    local dialog = PurchaseDialog._dialog
    if not dialog then return end
    
    local itemData = Constants.ITEMS[itemName]
    if not itemData then return end
    
    -- Update dialog content
    dialog.Title.Text = itemName
    dialog.ItemInfo.Text = itemData.description or "No description available"
    currentItem = itemName
    onPurchase = callback
    
    -- Reset quantity
    updateQuantity(1)
    
    -- Show dialog with animation
    dialog.Visible = true
    dialog.BackgroundTransparency = 1
    
    local showTween = TweenService:Create(dialog, TweenInfo.new(ANIMATION_DURATION), {
        BackgroundTransparency = 0
    })
    showTween:Play()
end

-- Hide the dialog
function PurchaseDialog.Hide()
    local dialog = PurchaseDialog._dialog
    if not dialog then return end
    
    local hideTween = TweenService:Create(dialog, TweenInfo.new(ANIMATION_DURATION), {
        BackgroundTransparency = 1
    })
    
    hideTween.Completed:Connect(function()
        dialog.Visible = false
    end)
    
    hideTween:Play()
end

-- Show error message
function PurchaseDialog.ShowError(message)
    local dialog = PurchaseDialog._dialog
    if not dialog then return end
    
    dialog.ItemInfo.Text = "Error: " .. message
    dialog.ItemInfo.TextColor3 = Color3.fromRGB(255, 100, 100)
    
    -- Reset color after 2 seconds
    task.delay(2, function()
        if dialog.ItemInfo then
            dialog.ItemInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end)
end

return PurchaseDialog 