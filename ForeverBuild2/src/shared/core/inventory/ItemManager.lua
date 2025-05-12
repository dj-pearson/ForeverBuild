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
    local item = self:GetItemData(itemId)
    return item and item.price == 0
end

function ItemManager:GetActionPrice(itemId, action, player)
    local item = self:GetItemData(itemId)
    if not item then return nil end
    
    -- TODO: Implement different prices for different actions
    return item.price
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
