local PlacementManager = {}
PlacementManager.__index = PlacementManager

function PlacementManager.new()
    local self = setmetatable({}, PlacementManager)
    self.placedItems = {}
    return self
end

function PlacementManager:Initialize()
    print("Initializing PlacementManager...")
    -- Initialize placement grid
end

function PlacementManager:PlaceItem(player, itemId, position, rotation)
    local userId = typeof(player) == "number" and player or player.UserId
    
    -- Generate unique ID for this placement
    local placementId = userId .. "_" .. itemId .. "_" .. os.time()
    
    -- Record the placement
    self.placedItems[placementId] = {
        id = placementId,
        itemId = itemId,
        position = position,
        rotation = rotation,
        owner = userId,
        placedTime = os.time()
    }
    
    return placementId
end

function PlacementManager:MoveItem(player, placementId, newPosition, newRotation)
    if not self.placedItems[placementId] then
        return false, "Item not found"
    end
    
    local userId = typeof(player) == "number" and player or player.UserId
    if self.placedItems[placementId].owner ~= userId then
        return false, "Not the owner of this item"
    end
    
    -- Update the position and rotation
    self.placedItems[placementId].position = newPosition
    self.placedItems[placementId].rotation = newRotation
    
    return true
end

function PlacementManager:RemoveItem(player, placementId)
    if not self.placedItems[placementId] then
        return false, "Item not found"
    end
    
    local userId = typeof(player) == "number" and player or player.UserId
    if self.placedItems[placementId].owner ~= userId then
        return false, "Not the owner of this item"
    end
    
    -- Remove the item
    self.placedItems[placementId] = nil
    
    return true
end

return PlacementManager
