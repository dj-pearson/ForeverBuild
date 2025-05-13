local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local Constants = require(ReplicatedStorage.shared.core.Constants)

local CurrencyUI = {}
CurrencyUI.__index = CurrencyUI

-- Initialize a new CurrencyUI
function CurrencyUI.new()
    local self = setmetatable({}, CurrencyUI)
    self.player = Players.LocalPlayer
    self.ui = nil
    self:Initialize()
    return self
end

-- Initialize the CurrencyUI
function CurrencyUI:Initialize()
    -- Create UI
    self:CreateUI()
    
    -- Set up event handling
    self:SetupEventHandling()
    
    -- Initial balance update
    self:UpdateBalance(self.player:GetAttribute("Coins") or 0)
end

-- Create UI
function CurrencyUI:CreateUI()
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CurrencyUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = self.player:WaitForChild("PlayerGui")
    
    -- Create main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 200, 0, 50)
    mainFrame.Position = UDim2.new(1, -220, 0, 20)
    mainFrame.BackgroundTransparency = 0.5
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Create coin icon
    local coinIcon = Instance.new("ImageLabel")
    coinIcon.Name = "CoinIcon"
    coinIcon.Size = UDim2.new(0, 40, 0, 40)
    coinIcon.Position = UDim2.new(0, 5, 0.5, -20)
    coinIcon.BackgroundTransparency = 1
    coinIcon.Image = "rbxassetid://101567167458494" -- TODO: Replace with actual coin icon
    coinIcon.Parent = mainFrame
    
    -- Create balance label
    local balanceLabel = Instance.new("TextLabel")
    balanceLabel.Name = "BalanceLabel"
    balanceLabel.Size = UDim2.new(1, -50, 1, 0)
    balanceLabel.Position = UDim2.new(0, 50, 0, 0)
    balanceLabel.BackgroundTransparency = 1
    balanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    balanceLabel.TextSize = 24
    balanceLabel.Font = Enum.Font.GothamBold
    balanceLabel.Text = "0"
    balanceLabel.TextXAlignment = Enum.TextXAlignment.Left
    balanceLabel.Parent = mainFrame
    
    -- Create purchase button
    local purchaseButton = Instance.new("TextButton")
    purchaseButton.Name = "PurchaseButton"
    purchaseButton.Size = UDim2.new(0, 100, 0, 30)
    purchaseButton.Position = UDim2.new(1, -110, 1, 10)
    purchaseButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    purchaseButton.BorderSizePixel = 0
    purchaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    purchaseButton.TextSize = 18
    purchaseButton.Font = Enum.Font.GothamBold
    purchaseButton.Text = "Buy Coins"
    purchaseButton.Parent = mainFrame
    
    -- Store UI reference
    self.ui = screenGui
end

-- Set up event handling
function CurrencyUI:SetupEventHandling()
    -- Handle balance updates
    ReplicatedStorage.Remotes.UpdateBalance.OnClientEvent:Connect(function(balance)
        self:UpdateBalance(balance)
    end)
    
    -- Handle purchase button click
    self.ui.MainFrame.PurchaseButton.MouseButton1Click:Connect(function()
        self:ShowPurchaseMenu()
    end)
end

-- Update balance display
function CurrencyUI:UpdateBalance(balance)
    self.ui.MainFrame.BalanceLabel.Text = tostring(balance)
end

-- Show purchase menu
function CurrencyUI:ShowPurchaseMenu()
    -- Create purchase menu
    local purchaseMenu = Instance.new("Frame")
    purchaseMenu.Name = "PurchaseMenu"
    purchaseMenu.Size = UDim2.new(0, 300, 0, 400)
    purchaseMenu.Position = UDim2.new(0.5, -150, 0.5, -200)
    purchaseMenu.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    purchaseMenu.BorderSizePixel = 0
    purchaseMenu.Parent = self.ui
    
    -- Create title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Text = "Purchase Coins"
    title.Parent = purchaseMenu
    
    -- Create close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "X"
    closeButton.Parent = purchaseMenu
    
    -- Create purchase options
    local yOffset = 60
    for _, product in ipairs(Constants.CURRENCY.PRODUCTS) do
        local option = self:CreatePurchaseOption(product, yOffset)
        option.Parent = purchaseMenu
        yOffset = yOffset + 80
    end
    
    -- Handle close button
    closeButton.MouseButton1Click:Connect(function()
        purchaseMenu:Destroy()
    end)
end

-- Create purchase option
function CurrencyUI:CreatePurchaseOption(product, yOffset)
    local option = Instance.new("Frame")
    option.Name = "Option_" .. product.id
    option.Size = UDim2.new(1, -40, 0, 70)
    option.Position = UDim2.new(0, 20, 0, yOffset)
    option.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    option.BorderSizePixel = 0
    
    -- Create coin amount
    local coinAmount = Instance.new("TextLabel")
    coinAmount.Name = "CoinAmount"
    coinAmount.Size = UDim2.new(0.6, 0, 1, 0)
    coinAmount.BackgroundTransparency = 1
    coinAmount.TextColor3 = Color3.fromRGB(255, 255, 255)
    coinAmount.TextSize = 20
    coinAmount.Font = Enum.Font.GothamBold
    coinAmount.Text = tostring(product.coins) .. " Coins"
    coinAmount.TextXAlignment = Enum.TextXAlignment.Left
    coinAmount.Parent = option
    
    -- Create price
    local price = Instance.new("TextLabel")
    price.Name = "Price"
    price.Size = UDim2.new(0.4, 0, 1, 0)
    price.Position = UDim2.new(0.6, 0, 0, 0)
    price.BackgroundTransparency = 1
    price.TextColor3 = Color3.fromRGB(255, 255, 255)
    price.TextSize = 20
    price.Font = Enum.Font.GothamBold
    price.Text = tostring(product.robux) .. " R$"
    price.TextXAlignment = Enum.TextXAlignment.Right
    price.Parent = option
    
    -- Create purchase button
    local purchaseButton = Instance.new("TextButton")
    purchaseButton.Name = "PurchaseButton"
    purchaseButton.Size = UDim2.new(1, 0, 0, 30)
    purchaseButton.Position = UDim2.new(0, 0, 1, 10)
    purchaseButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    purchaseButton.BorderSizePixel = 0
    purchaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    purchaseButton.TextSize = 18
    purchaseButton.Font = Enum.Font.GothamBold
    purchaseButton.Text = "Purchase"
    purchaseButton.Parent = option
    
    -- Handle purchase button
    purchaseButton.MouseButton1Click:Connect(function()
        self:PurchaseCoins(product.id)
    end)
    
    return option
end

-- Purchase coins
function CurrencyUI:PurchaseCoins(productId)
    MarketplaceService:PromptProductPurchase(self.player, productId)
end

return CurrencyUI 