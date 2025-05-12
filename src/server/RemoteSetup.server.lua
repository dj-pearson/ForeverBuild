local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Get the game systems manager
local GameSystemsManager
local success, result = pcall(function()
    return require(ServerScriptService.GameSystemsManager)
end)

if success then
    GameSystemsManager = result
else
    GameSystemsManager = require(script.Parent.GameSystemsManager)
end

-- Create Remotes folder if it doesn't exist
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not Remotes then
    Remotes = Instance.new("Folder")
    Remotes.Name = "Remotes"
    Remotes.Parent = ReplicatedStorage
end

-- Create RemoteEvents for item interactions
local remoteEvents = {
    "PickupItem",      -- For picking up items in the world
    "DropItem",        -- For dropping items from inventory
    "UseItem",         -- For using/consuming items
    "EquipItem",       -- For equipping weapons/armor
    "PlaceObject",     -- For placing building objects in the world
    "MoveObject",      -- For moving placed objects
    "RemoveObject"     -- For removing placed objects
}

for _, eventName in ipairs(remoteEvents) do
    if not Remotes:FindFirstChild(eventName) then
        local event = Instance.new("RemoteEvent")
        event.Name = eventName
        event.Parent = Remotes
    end
end

-- Set up remote event handlers
local function setupRemoteHandlers()
    -- Handle picking up items
    Remotes.PickupItem.OnServerEvent:Connect(function(player, itemId, quantity)
        -- Add item to player's inventory
        local success, message = GameSystemsManager:AddItemToInventory(player, itemId, quantity)
        
        -- Let the client know if it succeeded
        local ResultEvent = Remotes:FindFirstChild("ActionResult")
        if ResultEvent then
            ResultEvent:FireClient(player, "PickupItem", success, message)
        end
    end)
    
    -- Handle dropping items
    Remotes.DropItem.OnServerEvent:Connect(function(player, itemId, quantity, position)
        -- Remove item from player's inventory
        local success, message = GameSystemsManager:RemoveItemFromInventory(player, itemId, quantity)
        
        if success then
            -- Spawn the physical item in the world
            -- This would typically use the ItemSpawner module we created
            local ItemSpawner = require(ReplicatedStorage.shared.Modules.ItemSpawner)
            ItemSpawner:SpawnItem(itemId, position, true)
        end
        
        -- Let the client know if it succeeded
        local ResultEvent = Remotes:FindFirstChild("ActionResult")
        if ResultEvent then
            ResultEvent:FireClient(player, "DropItem", success, message)
        end
    end)
    
    -- Handle using items
    Remotes.UseItem.OnServerEvent:Connect(function(player, itemId)
        -- Get player's inventory
        local inventory = GameSystemsManager:GetPlayerInventory(player)
        if not inventory then return end
        
        -- Use the item
        local success, message = GameSystemsManager.inventorySystem:UseConsumable(inventory, itemId, player)
        
        -- Let the client know if it succeeded
        local ResultEvent = Remotes:FindFirstChild("ActionResult")
        if ResultEvent then
            ResultEvent:FireClient(player, "UseItem", success, message)
        end
    end)
    
    -- Handle equipping items
    Remotes.EquipItem.OnServerEvent:Connect(function(player, itemId)
        -- Get player's inventory
        local inventory = GameSystemsManager:GetPlayerInventory(player)
        if not inventory then return end
        
        -- Equip the item
        local success, message = GameSystemsManager.inventorySystem:EquipItem(inventory, itemId, player)
        
        -- Let the client know if it succeeded
        local ResultEvent = Remotes:FindFirstChild("ActionResult")
        if ResultEvent then
            ResultEvent:FireClient(player, "EquipItem", success, message)
        end
    end)
    
    -- Handle placing building objects
    Remotes.PlaceObject.OnServerEvent:Connect(function(player, objectType, position, rotation)
        -- This would typically check if the player has the object in their inventory
        -- and then place it in the world
        
        -- For now, we'll just assume the player can place it
        local ItemSpawner = require(ReplicatedStorage.shared.Modules.ItemSpawner)
        local newObject = ItemSpawner:SpawnItem(objectType, position, false)
        
        if newObject and newObject.PrimaryPart then
            -- Apply rotation
            newObject:SetPrimaryPartCFrame(CFrame.new(position) * CFrame.Angles(rotation.X, rotation.Y, rotation.Z))
            
            -- Make it non-pickable (it's a placed building object)
            -- You might want to add other functionality like editing instead
        end
        
        -- Let the client know if it succeeded
        local ResultEvent = Remotes:FindFirstChild("ActionResult")
        if ResultEvent then
            ResultEvent:FireClient(player, "PlaceObject", newObject ~= nil, newObject and "Object placed successfully" or "Failed to place object")
        end
    end)
end

-- Create a result event for sending feedback to clients
if not Remotes:FindFirstChild("ActionResult") then
    local resultEvent = Instance.new("RemoteEvent")
    resultEvent.Name = "ActionResult"
    resultEvent.Parent = Remotes
end

-- Set up the handlers
setupRemoteHandlers()

print("Remote events for item interactions have been set up")
