local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(script.Parent.Parent.Constants)

local ItemManager = {}
ItemManager.__index = ItemManager

function ItemManager.new()
    local self = setmetatable({}, ItemManager)
    self.items = {}
    self.adminUsers = {} -- List of user IDs that are admins
    return self
end

function ItemManager:Initialize()
    print("ItemManager initialized")
    self:LoadItems()
end

function ItemManager:LoadItems()
    -- TODO: Load items from a data source
    -- For now, we'll use some example items
    self.items = {
        {
            id = "cube_red",
            name = "Red Cube",
            price = 100,
            model = nil -- TODO: Load model
        },
        {
            id = "cube_blue",
            name = "Blue Cube",
            price = 150,
            model = nil -- TODO: Load model
        }
    }
end

function ItemManager:IsAdmin(player)
    return self.adminUsers[player.UserId] == true
end

function ItemManager:IsItemFree(itemId, player)
    -- Use the new pricing logic
    local price = self:GetActionPrice(itemId, Constants.ITEM_ACTIONS.BUY, player)
    return price == 0
end

function ItemManager:GetActionPrice(itemId, action, player)
    -- Look for the item model in Workspace > Items
    local itemsFolder = workspace:FindFirstChild("Items")
    if itemsFolder then
        for _, model in ipairs(itemsFolder:GetChildren()) do
            if model:IsA("Model") and model:GetAttribute("item") and model.Name == itemId then
                local tier = model:GetAttribute("item")
                local price = Constants.ITEM_PRICING[tier]
                if price then
                    return price
                end
            end
        end
    end
    -- Fallback to old logic if not found
    local item = self:GetItemData(itemId)
    return item and item.price or nil
end

function ItemManager:GetItemData(itemId)
    for _, item in ipairs(self.items) do
        if item.id == itemId then
            return item
        end
    end
    return nil
end

function ItemManager:GetItemModel(itemId)
    local item = self:GetItemData(itemId)
    return item and item.model
end

return ItemManager
