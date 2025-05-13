local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")

local Constants = require(script.Parent.Parent.Constants)

local CurrencyManager = {}
CurrencyManager.__index = CurrencyManager

-- Initialize a new CurrencyManager
function CurrencyManager.new()
    local self = setmetatable({}, CurrencyManager)
    self.playerBalances = {}
    self.currencyStore = DataStoreService:GetDataStore("PlayerCurrency")
    self.rewardTimers = {}
    self:Initialize()
    return self
end

-- Initialize the CurrencyManager
function CurrencyManager:Initialize()
    -- Set up player handling
    self:SetupPlayerHandling()
    
    -- Set up marketplace handling
    self:SetupMarketplaceHandling()
end

-- Set up player handling
function CurrencyManager:SetupPlayerHandling()
    game.Players.PlayerAdded:Connect(function(player)
        self:OnPlayerJoined(player)
    end)
    
    game.Players.PlayerRemoving:Connect(function(player)
        self:OnPlayerLeaving(player)
    end)
end

-- Set up marketplace handling
function CurrencyManager:SetupMarketplaceHandling()
    -- Handle purchase requests
    MarketplaceService.ProcessReceipt = function(receiptInfo)
        local player = game.Players:GetPlayerByUserId(receiptInfo.PlayerId)
        if not player then
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end
        
        -- Process the purchase
        local success = self:ProcessPurchase(player, receiptInfo)
        if success then
            return Enum.ProductPurchaseDecision.PurchaseGranted
        else
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end
    end
end

-- Handle player joining
function CurrencyManager:OnPlayerJoined(player)
    -- Initialize player balance
    self:InitializePlayerBalance(player)
    
    -- Start reward timer
    self:StartRewardTimer(player)
    
    -- Check for daily/weekly/monthly bonuses
    self:CheckLoginBonuses(player)
end

-- Handle player leaving
function CurrencyManager:OnPlayerLeaving(player)
    -- Stop reward timer
    self:StopRewardTimer(player)
    
    -- Save player balance
    self:SavePlayerBalance(player)
end

-- Initialize player balance
function CurrencyManager:InitializePlayerBalance(player)
    local balance = {
        coins = 0,
        lastRewardTime = os.time(),
        lastDailyBonus = 0,
        lastWeeklyBonus = 0,
        lastMonthlyBonus = 0
    }
    
    self.playerBalances[player.UserId] = balance
    
    -- Load saved balance
    self:LoadPlayerBalance(player)
end

-- Load player balance from DataStore
function CurrencyManager:LoadPlayerBalance(player)
    local success, result = pcall(function()
        return self.currencyStore:GetAsync(player.UserId)
    end)
    
    if success and result then
        self.playerBalances[player.UserId] = result
    end
end

-- Save player balance to DataStore
function CurrencyManager:SavePlayerBalance(player)
    local balance = self.playerBalances[player.UserId]
    if not balance then return end
    
    pcall(function()
        self.currencyStore:SetAsync(player.UserId, balance)
    end)
end

-- Start reward timer for player
function CurrencyManager:StartRewardTimer(player)
    local timer = task.spawn(function()
        while player and player.Parent do
            task.wait(Constants.CURRENCY.REWARD_INTERVAL)
            self:GiveReward(player)
        end
    end)
    
    self.rewardTimers[player.UserId] = timer
end

-- Stop reward timer for player
function CurrencyManager:StopRewardTimer(player)
    local timer = self.rewardTimers[player.UserId]
    if timer then
        task.cancel(timer)
        self.rewardTimers[player.UserId] = nil
    end
end

-- Give reward to player
function CurrencyManager:GiveReward(player)
    local balance = self.playerBalances[player.UserId]
    if not balance then return end
    
    -- Calculate reward amount
    local rewardAmount = math.floor(Constants.CURRENCY.REWARD_RATE * (Constants.CURRENCY.REWARD_INTERVAL / 60))
    rewardAmount = math.clamp(rewardAmount, Constants.CURRENCY.MIN_REWARD_AMOUNT, Constants.CURRENCY.MAX_REWARD_AMOUNT)
    
    -- Add reward to balance
    balance.coins = balance.coins + rewardAmount
    balance.lastRewardTime = os.time()
    
    -- Update player
    self:UpdatePlayerBalance(player)
end

-- Check login bonuses
function CurrencyManager:CheckLoginBonuses(player)
    local balance = self.playerBalances[player.UserId]
    if not balance then return end
    
    local currentTime = os.time()
    
    -- Check daily bonus
    if currentTime - balance.lastDailyBonus >= 86400 then -- 24 hours
        balance.coins = balance.coins + Constants.CURRENCY.DAILY_BONUS
        balance.lastDailyBonus = currentTime
    end
    
    -- Check weekly bonus
    if currentTime - balance.lastWeeklyBonus >= 604800 then -- 7 days
        balance.coins = balance.coins + Constants.CURRENCY.WEEKLY_BONUS
        balance.lastWeeklyBonus = currentTime
    end
    
    -- Check monthly bonus
    if currentTime - balance.lastMonthlyBonus >= 2592000 then -- 30 days
        balance.coins = balance.coins + Constants.CURRENCY.MONTHLY_BONUS
        balance.lastMonthlyBonus = currentTime
    end
    
    -- Update player
    self:UpdatePlayerBalance(player)
end

-- Update player balance
function CurrencyManager:UpdatePlayerBalance(player)
    local balance = self.playerBalances[player.UserId]
    if not balance then return end
    
    -- Update player attributes
    player:SetAttribute("Coins", balance.coins)
    
    -- Fire client event
    ReplicatedStorage.Remotes.UpdateBalance:FireClient(player, balance.coins)
end

-- Get player balance
function CurrencyManager:GetBalance(player)
    local balance = self.playerBalances[player.UserId]
    return balance and balance.coins or 0
end

-- Add coins to player
function CurrencyManager:AddCoins(player, amount)
    local balance = self.playerBalances[player.UserId]
    if not balance then return false end
    
    balance.coins = balance.coins + amount
    self:UpdatePlayerBalance(player)
    return true
end

-- Remove coins from player
function CurrencyManager:RemoveCoins(player, amount)
    local balance = self.playerBalances[player.UserId]
    if not balance then return false end
    
    if balance.coins < amount then
        return false
    end
    
    balance.coins = balance.coins - amount
    self:UpdatePlayerBalance(player)
    return true
end

-- Process Robux purchase
function CurrencyManager:ProcessPurchase(player, receiptInfo)
    -- Get product info
    local productId = receiptInfo.ProductId
    local productInfo = self:GetProductInfo(productId)
    if not productInfo then return false end
    
    -- Add coins to player
    return self:AddCoins(player, productInfo.coins)
end

-- Get product info
function CurrencyManager:GetProductInfo(productId)
    -- TODO: Implement product info lookup
    return nil
end

-- Check if player can afford item
function CurrencyManager:CanAffordItem(player, itemId, useRobux)
    local balance = self.playerBalances[player.UserId]
    if not balance then return false end
    
    -- Get item price
    local price = self:GetItemPrice(itemId, useRobux)
    if not price then return false end
    
    if useRobux then
        -- Check Robux balance
        return player:GetAttribute("Robux") >= price
    else
        -- Check coin balance
        return balance.coins >= price
    end
end

-- Get item price
function CurrencyManager:GetItemPrice(itemId, useRobux)
    -- TODO: Implement item price lookup
    return nil
end

return CurrencyManager 