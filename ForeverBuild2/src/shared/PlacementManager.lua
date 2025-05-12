local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Constants = require(script.Parent.Constants)
local ItemManager = require(script.Parent.ItemManager)
local InventoryManager = require(script.Parent.InventoryManager)

local PlacementManager = {}
PlacementManager.__index = PlacementManager

-- Initialize a new PlacementManager
function PlacementManager.new()
    local self = setmetatable({}, PlacementManager)
    self.placedItems = {}
    self:Initialize()
    return self
end

-- Initialize the PlacementManager
function PlacementManager:Initialize()
    -- Create necessary folders
    self:SetupFolders()
    
    -- Load placed items from DataStore
    self:LoadPlacedItems()
end

-- Set up necessary folders
function PlacementManager:SetupFolders()
    -- Create PlacedItems folder in Workspace if it doesn't exist
    if not Workspace:FindFirstChild("PlacedItems") then
        local placedItemsFolder = Instance.new("Folder")
        placedItemsFolder.Name = "PlacedItems"
        placedItemsFolder.Parent = Workspace
    end
end

-- Load placed items from DataStore
function PlacementManager:LoadPlacedItems()
    -- TODO: Implement DataStore loading for placed items
end

-- Check if a position is within homebase
function PlacementManager:IsInHomebase(position)
    local distance = (position - Constants.HOMEBASE.CENTER).Magnitude
    return distance <= Constants.HOMEBASE.RADIUS
end

-- Place an item
function PlacementManager:PlaceItem(player, itemId, position, rotation)
    -- Check if player has the item
    if not InventoryManager:HasItem(player, itemId) then
        return false, "Item not in inventory"
    end
    
    -- Get item data
    local itemData = ItemManager:GetItemData(itemId)
    if not itemData then
        return false, "Item not found"
    end
    
    -- Check if player can place the item
    if not ItemManager:CanModifyItem(itemId, player) then
        return false, "Cannot place this item"
    end
    
    -- Create the item in the world
    local success, placedItem = self:CreatePlacedItem(itemData, position, rotation)
    if not success then
        return false, "Failed to place item"
    end
    
    -- Remove item from inventory
    local success, message = InventoryManager:RemoveItem(player, itemId)
    if not success then
        placedItem:Destroy()
        return false, message
    end
    
    -- Store placed item data
    self:StorePlacedItem(player, placedItem, itemId)
    
    return true, "Item placed successfully"
end

-- Create a placed item in the world
function PlacementManager:CreatePlacedItem(itemData, position, rotation)
    local model = itemData.model:Clone()
    model.Parent = Workspace.PlacedItems
    
    -- Set position and rotation
    model:SetPrimaryPartCFrame(CFrame.new(position) * CFrame.Angles(0, math.rad(rotation or 0), 0))
    
    -- Add attributes
    model:SetAttribute("ItemId", itemData.id)
    model:SetAttribute("PlacedBy", player.UserId)
    model:SetAttribute("PlaceTime", os.time())
    
    return true, model
end

-- Store placed item data
function PlacementManager:StorePlacedItem(player, placedItem, itemId)
    local itemData = {
        id = itemId,
        model = placedItem,
        position = placedItem.PrimaryPart.Position,
        rotation = placedItem.PrimaryPart.Orientation.Y,
        placedBy = player.UserId,
        placeTime = os.time()
    }
    
    table.insert(self.placedItems, itemData)
end

-- Move an item
function PlacementManager:MoveItem(player, placedItem, newPosition)
    -- Check if player can modify the item
    local itemId = placedItem:GetAttribute("ItemId")
    if not ItemManager:CanModifyItem(itemId, player) then
        return false, "Cannot modify this item"
    end
    
    -- Check if player has enough currency
    local price = ItemManager:GetActionPrice(itemId, Constants.ITEM_ACTIONS.MOVE, player)
    if price > 0 then
        -- TODO: Implement currency check and deduction
    end
    
    -- Move the item
    placedItem:SetPrimaryPartCFrame(CFrame.new(newPosition) * CFrame.Angles(0, math.rad(placedItem:GetAttribute("Rotation") or 0), 0))
    
    -- Update stored data
    self:UpdatePlacedItemData(placedItem)
    
    return true, "Item moved successfully"
end

-- Rotate an item
function PlacementManager:RotateItem(player, placedItem, newRotation)
    -- Check if player can modify the item
    local itemId = placedItem:GetAttribute("ItemId")
    if not ItemManager:CanModifyItem(itemId, player) then
        return false, "Cannot modify this item"
    end
    
    -- Validate rotation
    newRotation = newRotation % Constants.ITEM_PROPERTIES.MAX_ROTATION
    if newRotation < Constants.ITEM_PROPERTIES.MIN_ROTATION then
        newRotation = Constants.ITEM_PROPERTIES.MIN_ROTATION
    end
    
    -- Check if player has enough currency
    local price = ItemManager:GetActionPrice(itemId, Constants.ITEM_ACTIONS.ROTATE, player)
    if price > 0 then
        -- TODO: Implement currency check and deduction
    end
    
    -- Rotate the item
    local currentPosition = placedItem.PrimaryPart.Position
    placedItem:SetPrimaryPartCFrame(CFrame.new(currentPosition) * CFrame.Angles(0, math.rad(newRotation), 0))
    
    -- Update stored data
    placedItem:SetAttribute("Rotation", newRotation)
    self:UpdatePlacedItemData(placedItem)
    
    return true, "Item rotated successfully"
end

-- Change item color
function PlacementManager:ChangeItemColor(player, placedItem, newColor)
    -- Check if player can modify the item
    local itemId = placedItem:GetAttribute("ItemId")
    if not ItemManager:CanModifyItem(itemId, player) then
        return false, "Cannot modify this item"
    end
    
    -- Check color change limit
    local colorChanges = placedItem:GetAttribute("ColorChanges") or 0
    if colorChanges >= Constants.ITEM_PROPERTIES.MAX_COLOR_CHANGES then
        return false, "Maximum color changes reached"
    end
    
    -- Check if player has enough currency
    local price = ItemManager:GetActionPrice(itemId, Constants.ITEM_ACTIONS.COLOR, player)
    if price > 0 then
        -- TODO: Implement currency check and deduction
    end
    
    -- Change the color
    placedItem.PrimaryPart.Color = newColor
    placedItem:SetAttribute("ColorChanges", colorChanges + 1)
    
    -- Update stored data
    self:UpdatePlacedItemData(placedItem)
    
    return true, "Item color changed successfully"
end

-- Update placed item data
function PlacementManager:UpdatePlacedItemData(placedItem)
    for _, itemData in ipairs(self.placedItems) do
        if itemData.model == placedItem then
            itemData.position = placedItem.PrimaryPart.Position
            itemData.rotation = placedItem:GetAttribute("Rotation")
            break
        end
    end
end

-- Remove placed item
function PlacementManager:RemoveItem(player, placedItem)
    -- Check if player can modify the item
    local itemId = placedItem:GetAttribute("ItemId")
    if not ItemManager:CanModifyItem(itemId, player) then
        return false, "Cannot modify this item"
    end
    
    -- Check if player has enough currency
    local price = ItemManager:GetActionPrice(itemId, Constants.ITEM_ACTIONS.DESTROY, player)
    if price > 0 then
        -- TODO: Implement currency check and deduction
    end
    
    -- Return item to inventory
    local success, message = InventoryManager:AddItem(player, itemId)
    if not success then
        return false, message
    end
    
    -- Remove from placed items
    for i, itemData in ipairs(self.placedItems) do
        if itemData.model == placedItem then
            table.remove(self.placedItems, i)
            break
        end
    end
    
    -- Destroy the model
    placedItem:Destroy()
    
    return true, "Item removed successfully"
end

return PlacementManager 