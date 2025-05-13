local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Constants = require(ReplicatedStorage.shared.core.Constants)

local PurchaseDialog = {}
PurchaseDialog.__index = PurchaseDialog

function PurchaseDialog.new(itemId, tier, price, onPurchase)
    local self = setmetatable({}, PurchaseDialog)
    self.itemId = itemId
    self.tier = tier
    self.price = price
    self.onPurchase = onPurchase
    self.quantity = 1
    self:CreateUI()
    return self
end

function PurchaseDialog:CreateUI()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "PurchaseDialog"
    self.screenGui.Parent = playerGui
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local frame = Instance.new("Frame")
    frame.Name = "DialogFrame"
    frame.Size = UDim2.new(0, 320, 0, 200)
    frame.Position = UDim2.new(0.5, -160, 0.5, -100)
    frame.BackgroundColor3 = Constants.UI_COLORS.SECONDARY
    frame.BorderSizePixel = 0
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Parent = self.screenGui
    frame.ZIndex = 20

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Constants.UI_COLORS.TEXT
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.Text = string.format("Buy %s (%s)", self.itemId, self.tier:gsub("^%l", string.upper))
    title.Parent = frame
    title.ZIndex = 21

    local priceLabel = Instance.new("TextLabel")
    priceLabel.Name = "PriceLabel"
    priceLabel.Size = UDim2.new(1, -40, 0, 30)
    priceLabel.Position = UDim2.new(0, 20, 0, 50)
    priceLabel.BackgroundTransparency = 1
    priceLabel.TextColor3 = Constants.UI_COLORS.TEXT
    priceLabel.TextSize = 18
    priceLabel.Font = Enum.Font.Gotham
    priceLabel.Text = string.format("Price: %d Robux each", self.price)
    priceLabel.Parent = frame
    priceLabel.ZIndex = 21

    local quantityLabel = Instance.new("TextLabel")
    quantityLabel.Name = "QuantityLabel"
    quantityLabel.Size = UDim2.new(0, 100, 0, 30)
    quantityLabel.Position = UDim2.new(0, 20, 0, 90)
    quantityLabel.BackgroundTransparency = 1
    quantityLabel.TextColor3 = Constants.UI_COLORS.TEXT
    quantityLabel.TextSize = 18
    quantityLabel.Font = Enum.Font.Gotham
    quantityLabel.Text = "Quantity: 1"
    quantityLabel.Parent = frame
    quantityLabel.ZIndex = 21

    local minusButton = Instance.new("TextButton")
    minusButton.Name = "MinusButton"
    minusButton.Size = UDim2.new(0, 30, 0, 30)
    minusButton.Position = UDim2.new(0, 130, 0, 90)
    minusButton.BackgroundColor3 = Constants.UI_COLORS.PRIMARY
    minusButton.Text = "-"
    minusButton.TextColor3 = Constants.UI_COLORS.TEXT
    minusButton.TextSize = 22
    minusButton.Font = Enum.Font.GothamBold
    minusButton.Parent = frame
    minusButton.ZIndex = 21

    local plusButton = Instance.new("TextButton")
    plusButton.Name = "PlusButton"
    plusButton.Size = UDim2.new(0, 30, 0, 30)
    plusButton.Position = UDim2.new(0, 170, 0, 90)
    plusButton.BackgroundColor3 = Constants.UI_COLORS.PRIMARY
    plusButton.Text = "+"
    plusButton.TextColor3 = Constants.UI_COLORS.TEXT
    plusButton.TextSize = 22
    plusButton.Font = Enum.Font.GothamBold
    plusButton.Parent = frame
    plusButton.ZIndex = 21

    local purchaseButton = Instance.new("TextButton")
    purchaseButton.Name = "PurchaseButton"
    purchaseButton.Size = UDim2.new(0, 120, 0, 40)
    purchaseButton.Position = UDim2.new(0.5, -60, 1, -50)
    purchaseButton.BackgroundColor3 = Constants.UI_COLORS.PRIMARY
    purchaseButton.Text = "Purchase"
    purchaseButton.TextColor3 = Constants.UI_COLORS.TEXT
    purchaseButton.TextSize = 20
    purchaseButton.Font = Enum.Font.GothamBold
    purchaseButton.Parent = frame
    purchaseButton.ZIndex = 21

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundColor3 = Constants.UI_COLORS.ERROR
    closeButton.Text = "X"
    closeButton.TextColor3 = Constants.UI_COLORS.TEXT
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = frame
    closeButton.ZIndex = 21

    minusButton.MouseButton1Click:Connect(function()
        if self.quantity > 1 then
            self.quantity = self.quantity - 1
            quantityLabel.Text = "Quantity: " .. self.quantity
        end
    end)
    plusButton.MouseButton1Click:Connect(function()
        if self.quantity < 10 then
            self.quantity = self.quantity + 1
            quantityLabel.Text = "Quantity: " .. self.quantity
        end
    end)
    purchaseButton.MouseButton1Click:Connect(function()
        if self.onPurchase then
            self.onPurchase(self.itemId, self.tier, self.price, self.quantity)
        end
        self:Destroy()
    end)
    closeButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
end

function PurchaseDialog:Destroy()
    if self.screenGui then
        self.screenGui:Destroy()
        self.screenGui = nil
    end
end

return PurchaseDialog 