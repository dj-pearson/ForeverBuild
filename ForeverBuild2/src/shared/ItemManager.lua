local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Constants = require(script.Parent.Constants)

local ItemManager = {}
ItemManager.__index = ItemManager

-- Initialize a new ItemManager
function ItemManager.new()
    local self = setmetatable({}, ItemManager)
    self.items = {}
    self.itemModels = {}
    self:Initialize()
    return self
end

-- Initialize the ItemManager
function ItemManager:Initialize()
    -- Create necessary folders if they don't exist
    self:SetupFolders()
    
    -- Load all items from the workspace structure
    self:LoadItems()
end

-- Set up necessary folders
function ItemManager:SetupFolders()
    -- Create Items folder in ReplicatedStorage if it doesn't exist
    if not ReplicatedStorage:FindFirstChild("Items") then
        local itemsFolder = Instance.new("Folder")
        itemsFolder.Name = "Items"
        itemsFolder.Parent = ReplicatedStorage
    end
    
    -- Create ItemModels folder in ServerStorage if it doesn't exist
    if not ServerStorage:FindFirstChild("ItemModels") then
        local itemModelsFolder = Instance.new("Folder")
        itemModelsFolder.Name = "ItemModels"
        itemModelsFolder.Parent = ServerStorage
    end
end

-- Load all items from the workspace structure
function ItemManager:LoadItems()
    local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
    if not itemsFolder then return end
    
    -- Load items from each category
    for _, category in pairs(Constants.ITEM_CATEGORIES) do
        local categoryFolder = itemsFolder:FindFirstChild(category)
        if categoryFolder then
            self:LoadCategoryItems(categoryFolder, category)
        end
    end
end

-- Load items from a specific category
function ItemManager:LoadCategoryItems(categoryFolder, category)
    for _, item in ipairs(categoryFolder:GetChildren()) do
        if item:IsA("Model") then
            self:RegisterItem(item, category)
        end
    end
end

-- Register an item
function ItemManager:RegisterItem(itemModel, category)
    local itemData = {
        id = itemModel.Name,
        name = itemModel.Name,
        category = category,
        model = itemModel,
        isFree = category == Constants.ITEM_CATEGORIES.FREEBIES,
        prices = self:GetItemPrices(category),
        properties = {
            rotation = 0,
            colorChanges = 0,
            originalColor = self:GetOriginalColor(itemModel)
        }
    }
    
    self.items[itemData.id] = itemData
    self.itemModels[itemData.id] = itemModel
    
    -- Store a copy in ServerStorage for spawning
    self:StoreItemModel(itemData)
end

-- Get item prices based on category
function ItemManager:GetItemPrices(category)
    if category == Constants.ITEM_CATEGORIES.FREEBIES then
        return {
            buy = 0,
            move = 0,
            destroy = 0,
            rotate = 0,
            color = 0
        }
    elseif category == Constants.ITEM_CATEGORIES.ADMIN then
        return {
            buy = 0,
            move = 0,
            destroy = 0,
            rotate = 0,
            color = 0
        }
    else
        return {
            buy = Constants.BASE_PRICES.BUY,
            move = Constants.BASE_PRICES.MOVE,
            destroy = Constants.BASE_PRICES.DESTROY,
            rotate = Constants.BASE_PRICES.ROTATE,
            color = Constants.BASE_PRICES.COLOR
        }
    end
end

-- Get original color of an item
function ItemManager:GetOriginalColor(itemModel)
    local primaryPart = itemModel.PrimaryPart
    if primaryPart then
        return primaryPart.Color
    end
    return Color3.new(1, 1, 1)
end

-- Store item model in ServerStorage
function ItemManager:StoreItemModel(itemData)
    local itemModelsFolder = ServerStorage:FindFirstChild("ItemModels")
    if not itemModelsFolder then return end
    
    -- Create a copy of the model
    local modelCopy = itemData.model:Clone()
    modelCopy.Parent = itemModelsFolder
end

-- Check if a player is an admin
function ItemManager:IsAdmin(player)
    return table.find(Constants.ADMIN_IDS, player.UserId) ~= nil
end

-- Get item data
function ItemManager:GetItemData(itemId)
    return self.items[itemId]
end

-- Get item model
function ItemManager:GetItemModel(itemId)
    return self.itemModels[itemId]
end

-- Check if an item is free for a player
function ItemManager:IsItemFree(itemId, player)
    local itemData = self:GetItemData(itemId)
    if not itemData then return false end
    
    return itemData.isFree or self:IsAdmin(player)
end

-- Get price for an action
function ItemManager:GetActionPrice(itemId, action, player)
    local itemData = self:GetItemData(itemId)
    if not itemData then return 0 end
    
    if self:IsItemFree(itemId, player) then
        return 0
    end
    
    return itemData.prices[action] or 0
end

-- Check if an item can be modified
function ItemManager:CanModifyItem(itemId, player)
    local itemData = self:GetItemData(itemId)
    if not itemData then return false end
    
    return self:IsItemFree(itemId, player) or itemData.category == Constants.ITEM_CATEGORIES.PAID
end

return ItemManager 