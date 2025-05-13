local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(script.Parent.Parent.Constants)

local InteractionManager = {}
InteractionManager.__index = InteractionManager

function InteractionManager.new()
    local self = setmetatable({}, InteractionManager)
    self.interactions = {}
    return self
end

function InteractionManager:Initialize()
    print("InteractionManager initialized")
    self:RegisterDefaultInteractions()
end

function InteractionManager:RegisterInteraction(itemId, interactionType, callback)
    if not self.interactions[itemId] then
        self.interactions[itemId] = {}
    end
    
    self.interactions[itemId][interactionType] = callback
end

function InteractionManager:UnregisterInteraction(itemId, interactionType)
    if self.interactions[itemId] then
        self.interactions[itemId][interactionType] = nil
    end
end

function InteractionManager:HandleInteraction(player, itemId, interactionType, ...)
    if not self.interactions[itemId] or not self.interactions[itemId][interactionType] then
        -- Try default interactions if specific ones don't exist
        if self.interactions["default"] and self.interactions["default"][interactionType] then
            return self.interactions["default"][interactionType](player, itemId, ...)
        end
        return false
    end
    
    return self.interactions[itemId][interactionType](player, ...)
end

-- Default interactions
function InteractionManager:RegisterDefaultInteractions()
    -- Pick up interaction
    self:RegisterInteraction("default", "pickup", function(player, itemId, placement)
        -- Check if player can pick up the item
        if not placement or not placement.model then return false end
        
        -- Get player's inventory
        local inventory = ReplicatedStorage.Remotes.GetInventory:InvokeServer(player)
        if not inventory then return false end
        
        -- Check if inventory has space
        if #inventory >= Constants.GAME.MAX_INVENTORY_SIZE then
            -- Notify player inventory is full
            ReplicatedStorage.Remotes.NotifyPlayer:FireClient(player, "Inventory is full!")
            return false
        end
        
        -- Remove item from world
        placement.model:Destroy()
        
        -- Add to inventory
        ReplicatedStorage.Remotes.AddToInventory:FireServer(player, itemId)
        
        return true
    end)
    
    -- Use interaction
    self:RegisterInteraction("default", "use", function(player, itemId, placement)
        -- Check if item can be used
        if not placement or not placement.model then return false end
        
        -- Get item data
        local itemData = ReplicatedStorage.Remotes.GetItemData:InvokeServer(itemId)
        if not itemData then return false end
        
        -- Check if item has use effect
        if itemData.useEffect then
            -- Apply effect
            ReplicatedStorage.Remotes.ApplyItemEffect:FireServer(player, itemId, placement)
        end
        
        return true
    end)
    
    -- Examine interaction
    self:RegisterInteraction("default", "examine", function(player, itemId, placement)
        -- Get item data
        local itemData = ReplicatedStorage.Remotes.GetItemData:InvokeServer(itemId)
        if not itemData then return false end
        
        -- Show item description
        ReplicatedStorage.Remotes.ShowItemDescription:FireClient(player, itemData.description)
        
        return true
    end)
    
    -- Custom interactions for specific items
    self:RegisterInteraction("glow_cube", "change_color", function(player, itemId, placement)
        if not placement or not placement.model then return false end
        
        -- Get current color
        local currentColor = placement.model:GetAttribute("Color") or "White"
        
        -- Get next color
        local colors = {"Red", "Green", "Blue", "Yellow", "Purple", "White"}
        local currentIndex = table.find(colors, currentColor) or 1
        local nextIndex = (currentIndex % #colors) + 1
        local newColor = colors[nextIndex]
        
        -- Update color
        placement.model:SetAttribute("Color", newColor)
        
        -- Update visual
        for _, part in ipairs(placement.model:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Color = Constants.UI_COLORS[newColor:upper()]
            end
        end
        
        return true
    end)
end

return InteractionManager 