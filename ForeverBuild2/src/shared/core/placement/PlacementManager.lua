local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(script.Parent.Parent.Constants)

local PlacementManager = {}
PlacementManager.__index = PlacementManager

function PlacementManager.new()
    local self = setmetatable({}, PlacementManager)
    self.placements = {}
    self.lastPlacementTime = {}
    self.interactionManager = nil
    return self
end

function PlacementManager:Initialize()
    print("PlacementManager initialized")
    
    -- Initialize interaction manager
    self.interactionManager = require(script.Parent.Parent.interaction.InteractionManager).new()
    self.interactionManager:Initialize()
    self.interactionManager:RegisterDefaultInteractions()
end

function PlacementManager:PlaceItem(player, itemId, position, rotation)
    -- Check cooldown
    if not self:CheckPlacementCooldown(player) then
        return false
    end
    
    -- Create placement
    local placement = {
        id = itemId,
        position = position,
        rotation = rotation,
        owner = player.UserId,
        model = nil, -- TODO: Create actual model
        interactions = {
            enabled = true,
            types = {"pickup", "use", "examine"}
        }
    }
    
    -- Add to placements
    table.insert(self.placements, placement)
    
    -- Update last placement time
    self.lastPlacementTime[player.UserId] = os.time()
    
    return true
end

function PlacementManager:MoveItem(player, placedItem, newPosition)
    -- Find placement
    local placement = self:FindPlacement(placedItem)
    if not placement then return false end
    
    -- Check ownership
    if placement.owner ~= player.UserId then return false end
    
    -- Update position
    placement.position = newPosition
    
    return true
end

function PlacementManager:RotateItem(player, placedItem, newRotation)
    -- Find placement
    local placement = self:FindPlacement(placedItem)
    if not placement then return false end
    
    -- Check ownership
    if placement.owner ~= player.UserId then return false end
    
    -- Update rotation
    placement.rotation = newRotation
    
    return true
end

function PlacementManager:ChangeItemColor(player, placedItem, newColor)
    -- Find placement
    local placement = self:FindPlacement(placedItem)
    if not placement then return false end
    
    -- Check ownership
    if placement.owner ~= player.UserId then return false end
    
    -- Update color
    placement.color = newColor
    
    return true
end

function PlacementManager:RemoveItem(player, placedItem)
    -- Find placement
    local placement = self:FindPlacement(placedItem)
    if not placement then return false end
    
    -- Check ownership
    if placement.owner ~= player.UserId then return false end
    
    -- Remove placement
    for i, p in ipairs(self.placements) do
        if p == placement then
            table.remove(self.placements, i)
            break
        end
    end
    
    return true
end

function PlacementManager:FindPlacement(placedItem)
    for _, placement in ipairs(self.placements) do
        if placement == placedItem then
            return placement
        end
    end
    return nil
end

function PlacementManager:CheckPlacementCooldown(player)
    local lastTime = self.lastPlacementTime[player.UserId]
    if not lastTime then return true end
    
    return os.time() - lastTime >= Constants.GAME.PLACEMENT_COOLDOWN
end

-- Interaction methods
function PlacementManager:EnableInteractions(placedItem)
    local placement = self:FindPlacement(placedItem)
    if not placement then return false end
    
    placement.interactions.enabled = true
    return true
end

function PlacementManager:DisableInteractions(placedItem)
    local placement = self:FindPlacement(placedItem)
    if not placement then return false end
    
    placement.interactions.enabled = false
    return true
end

function PlacementManager:AddInteractionType(placedItem, interactionType)
    local placement = self:FindPlacement(placedItem)
    if not placement then return false end
    
    if not table.find(placement.interactions.types, interactionType) then
        table.insert(placement.interactions.types, interactionType)
    end
    
    return true
end

function PlacementManager:RemoveInteractionType(placedItem, interactionType)
    local placement = self:FindPlacement(placedItem)
    if not placement then return false end
    
    for i, type in ipairs(placement.interactions.types) do
        if type == interactionType then
            table.remove(placement.interactions.types, i)
            break
        end
    end
    
    return true
end

function PlacementManager:HandleInteraction(player, placedItem, interactionType)
    local placement = self:FindPlacement(placedItem)
    if not placement then return false end
    
    -- Check if interactions are enabled
    if not placement.interactions.enabled then return false end
    
    -- Check if interaction type is allowed
    if not table.find(placement.interactions.types, interactionType) then return false end
    
    -- Handle the interaction
    return self.interactionManager:HandleInteraction(player, placement.id, interactionType, placement)
end

return PlacementManager
