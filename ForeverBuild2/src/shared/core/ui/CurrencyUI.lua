local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local Constants = require(script.Parent.Parent.Parent.core.Constants)

local CurrencyUI = {}
CurrencyUI.__index = CurrencyUI

-- Initialize a new CurrencyUI
function CurrencyUI.new()
    local self = setmetatable({}, CurrencyUI)
    self.ui = nil
    return self
end

-- Initialize the CurrencyUI
function CurrencyUI:Initialize()
    -- Create UI
    self:CreateUI()
    
    -- Set up event handlers
    self:SetupEventHandlers()
    
    -- Initial balance update
    self:UpdateBalance(Constants.CURRENCY.STARTING_COINS)
end

-- Create UI
function CurrencyUI:CreateUI()
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CurrencyUI"
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 200, 0, 50)
    frame.Position = UDim2.new(1, -220, 0, 20)
    frame.BackgroundColor3 = Constants.UI_COLORS.SECONDARY
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    -- Create coin icon
    local coinIcon = Instance.new("ImageLabel")
    coinIcon.Name = "CoinIcon"
    coinIcon.Size = UDim2.new(0, 30, 0, 30)
    coinIcon.Position = UDim2.new(0, 10, 0.5, -15)
    coinIcon.BackgroundTransparency = 1
    coinIcon.Image = "rbxassetid://101567167458494" -- TODO: Add coin icon
    coinIcon.Parent = frame
    
    -- Create balance label
    local balanceLabel = Instance.new("TextLabel")
    balanceLabel.Name = "BalanceLabel"
    balanceLabel.Size = UDim2.new(0, 100, 1, 0)
    balanceLabel.Position = UDim2.new(0, 50, 0, 0)
    balanceLabel.BackgroundTransparency = 1
    balanceLabel.TextColor3 = Constants.UI_COLORS.TEXT
    balanceLabel.TextSize = 18
    balanceLabel.Font = Enum.Font.GothamBold
    balanceLabel.Text = "0"
    balanceLabel.Parent = frame
    
    -- Create purchase button
    local purchaseButton = Instance.new("TextButton")
    purchaseButton.Name = "PurchaseButton"
    purchaseButton.Size = UDim2.new(0, 30, 0, 30)
    purchaseButton.Position = UDim2.new(1, -40, 0.5, -15)
    purchaseButton.BackgroundColor3 = Constants.UI_COLORS.PRIMARY
    purchaseButton.Text = "+"
    purchaseButton.TextColor3 = Constants.UI_COLORS.TEXT
    purchaseButton.TextSize = 20
    purchaseButton.Font = Enum.Font.GothamBold
    purchaseButton.Parent = frame
    
    self.ui = screenGui
end

-- Set up event handlers
function CurrencyUI:SetupEventHandlers()
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
    local menu = Instance.new("Frame")
    menu.Name = "PurchaseMenu"
    menu.Size = UDim2.new(0, 300, 0, 400)
    menu.Position = UDim2.new(0.5, -150, 0.5, -200)
    menu.BackgroundColor3 = Constants.UI_COLORS.SECONDARY
    menu.BorderSizePixel = 0
    menu.Parent = self.ui
    
    -- Create close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundColor3 = Constants.UI_COLORS.ERROR
    closeButton.Text = "X"
    closeButton.TextColor3 = Constants.UI_COLORS.TEXT
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = menu
    
    -- Create purchase options
    local yOffset = 50
    for _, product in ipairs(Constants.CURRENCY.PRODUCTS) do
        local option = Instance.new("TextButton")
        option.Name = "Option_" .. product.id
        option.Size = UDim2.new(0, 260, 0, 60)
        option.Position = UDim2.new(0.5, -130, 0, yOffset)
        option.BackgroundColor3 = Constants.UI_COLORS.PRIMARY
        option.Text = string.format("%d Coins - %d Robux", product.coins, product.robux)
        option.TextColor3 = Constants.UI_COLORS.TEXT
        option.TextSize = 18
        option.Font = Enum.Font.GothamBold
        option.Parent = menu
        
        option.MouseButton1Click:Connect(function()
            MarketplaceService:PromptProductPurchase(Players.LocalPlayer, product.id)
        end)
        
        yOffset = yOffset + 70
    end
    
    -- Handle close button
    closeButton.MouseButton1Click:Connect(function()
        menu:Destroy()
    end)
end

return CurrencyUI 