local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

-- Get necessary modules
local GameSystemsManager
pcall(function()
    GameSystemsManager = require(ServerScriptService.GameSystemsManager)
end)

-- Set up the remote events handler
local function setupRemoteEvents()
    -- Create Remotes folder if it doesn't exist
    local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if not Remotes then
        Remotes = Instance.new("Folder")
        Remotes.Name = "Remotes"
        Remotes.Parent = ReplicatedStorage
    end
    
    -- Create remote events for building
    local buildingEvents = {
        "PlaceObject",       -- For placing objects in the world
        "MoveObject",        -- For moving objects
        "RemoveObject",      -- For removing objects
        "PickupItem",        -- For picking up items
        "ActionResult"       -- For sending results back to clients
    }
    
    for _, eventName in ipairs(buildingEvents) do
        if not Remotes:FindFirstChild(eventName) then
            local event = Instance.new("RemoteEvent")
            event.Name = eventName
            event.Parent = Remotes
        end
    end
    
    -- Set up event handlers
    
    -- Handle placing objects
    local placeObjectEvent = Remotes:FindFirstChild("PlaceObject")
    if placeObjectEvent then
        placeObjectEvent.OnServerEvent:Connect(function(player, itemId, position, rotation)
            local success, result = placeObject(player, itemId, position, rotation)
            
            -- Send result to client
            local resultEvent = Remotes:FindFirstChild("ActionResult")
            if resultEvent then
                resultEvent:FireClient(player, "PlaceObject", success, result)
            end
        end)
    end
    
    -- Handle moving objects
    local moveObjectEvent = Remotes:FindFirstChild("MoveObject")
    if moveObjectEvent then
        moveObjectEvent.OnServerEvent:Connect(function(player, objectId, newPosition, newRotation)
            local success, result = moveObject(player, objectId, newPosition, newRotation)
            
            -- Send result to client
            local resultEvent = Remotes:FindFirstChild("ActionResult")
            if resultEvent then
                resultEvent:FireClient(player, "MoveObject", success, result)
            end
        end)
    end
    
    -- Handle removing objects
    local removeObjectEvent = Remotes:FindFirstChild("RemoveObject")
    if removeObjectEvent then
        removeObjectEvent.OnServerEvent:Connect(function(player, objectId)
            local success, result = removeObject(player, objectId)
            
            -- Send result to client
            local resultEvent = Remotes:FindFirstChild("ActionResult")
            if resultEvent then
                resultEvent:FireClient(player, "RemoveObject", success, result)
            end
        end)
    end
    
    -- Handle picking up items
    local pickupItemEvent = Remotes:FindFirstChild("PickupItem")
    if pickupItemEvent then
        pickupItemEvent.OnServerEvent:Connect(function(player, itemId, quantity)
            local success, result = pickupItem(player, itemId, quantity)
            
            -- Send result to client
            local resultEvent = Remotes:FindFirstChild("ActionResult")
            if resultEvent then
                resultEvent:FireClient(player, "PickupItem", success, result)
            end
        end)
    end
end

-- Place an object in the world
function placeObject(player, itemId, position, rotation)
    -- Validate the player's position relative to placement position
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false, "Character not found"
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local distance = (rootPart.Position - position).Magnitude
    if distance > 20 then
        return false, "Too far away to place object"
    end
    
    -- Check if the player has the item in their inventory (if it's an inventory item)
    if GameSystemsManager then
        local inventory = GameSystemsManager:GetPlayerInventory(player)
        if inventory then
            local item = GameSystemsManager.inventorySystem:FindItem(inventory, itemId)
            if item and item.quantity > 0 then
                -- Remove the item from inventory if it's not a building material
                -- Building materials are often considered unlimited or have special handling
                local itemModels = ReplicatedStorage:FindFirstChild("ItemModels")
                if itemModels then
                    local foundInBuilding = false
                    for _, category in ipairs(itemModels:GetChildren()) do
                        if category:IsA("Folder") and category.Name ~= "Items" and category:FindFirstChild(itemId) then
                            foundInBuilding = true
                            break
                        end
                    end
                    
                    if not foundInBuilding then
                        -- It's an inventory item, remove it
                        GameSystemsManager:RemoveItemFromInventory(player, itemId, 1)
                    end
                end
            else
                -- Special case for unlimited building materials
                local isUnlimitedBuildingMaterial = itemId:find("foundation_") or itemId:find("wall_") or itemId:find("floor_")
                if not isUnlimitedBuildingMaterial then
                    return false, "Item not in inventory"
                end
            end
        end
    end
    
    -- Find the item model
    local itemModels = ReplicatedStorage:FindFirstChild("ItemModels")
    if not itemModels then
        return false, "Item models not found"
    end
    
    -- Look for the item in all categories
    local itemModel = nil
    for _, category in ipairs(itemModels:GetChildren()) do
        if category:IsA("Folder") then
            local model = category:FindFirstChild(itemId)
            if model then
                itemModel = model
                break
            end
        end
    end
    
    if not itemModel then
        return false, "Item model not found: " .. itemId
    end
    
    -- Clone the model and place it in the world
    local newObject = itemModel:Clone()
    newObject.Name = itemId .. "_" .. os.time() -- Add timestamp to make it unique
    
    -- Set the position and rotation
    if newObject.PrimaryPart then
        newObject:SetPrimaryPartCFrame(CFrame.new(position) * CFrame.Angles(rotation.X, rotation.Y, rotation.Z))
    else
        warn("BuildingManager: Object has no PrimaryPart:", itemId)
        for _, part in ipairs(newObject:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Position = position
                part.CFrame = part.CFrame * CFrame.Angles(rotation.X, rotation.Y, rotation.Z)
            end
        end
    end
    
    -- Add owner attribute
    newObject:SetAttribute("Owner", player.UserId)
    newObject:SetAttribute("PlacedTime", os.time())
    
    -- Get the BuildingItems folder
    local buildingItemsFolder = Workspace:FindFirstChild("BuildingItems")
    if not buildingItemsFolder then
        buildingItemsFolder = Instance.new("Folder")
        buildingItemsFolder.Name = "BuildingItems"
        buildingItemsFolder.Parent = Workspace
    end
    
    -- Put the object in the correct category folder
    local category = newObject:GetAttribute("Category") or "Miscellaneous"
    local categoryFolder = buildingItemsFolder:FindFirstChild(category)
    if not categoryFolder then
        categoryFolder = Instance.new("Folder")
        categoryFolder.Name = category
        categoryFolder.Parent = buildingItemsFolder
    end
    
    newObject.Parent = categoryFolder
    
    return true, newObject.Name
end

-- Move an object
function moveObject(player, objectId, newPosition, newRotation)
    -- Find the object
    local object = nil
    local buildingItemsFolder = Workspace:FindFirstChild("BuildingItems")
    if buildingItemsFolder then
        for _, category in ipairs(buildingItemsFolder:GetChildren()) do
            if category:IsA("Folder") then
                object = category:FindFirstChild(objectId)
                if object then
                    break
                end
            end
        end
    end
    
    if not object then
        return false, "Object not found"
    end
    
    -- Check ownership
    local owner = object:GetAttribute("Owner")
    if owner ~= player.UserId then
        return false, "You don't own this object"
    end
    
    -- Validate the player's position relative to the object
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false, "Character not found"
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local distance = (rootPart.Position - object:GetPrimaryPartCFrame().Position).Magnitude
    if distance > 20 then
        return false, "Too far away to move object"
    end
    
    -- Update the position and rotation
    if object.PrimaryPart then
        object:SetPrimaryPartCFrame(CFrame.new(newPosition) * CFrame.Angles(newRotation.X, newRotation.Y, newRotation.Z))
    else
        warn("BuildingManager: Object has no PrimaryPart:", objectId)
        for _, part in ipairs(object:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Position = newPosition
                part.CFrame = part.CFrame * CFrame.Angles(newRotation.X, newRotation.Y, newRotation.Z)
            end
        end
    end
    
    return true, "Object moved successfully"
end

-- Remove an object
function removeObject(player, objectId)
    -- Find the object
    local object = nil
    local buildingItemsFolder = Workspace:FindFirstChild("BuildingItems")
    if buildingItemsFolder then
        for _, category in ipairs(buildingItemsFolder:GetChildren()) do
            if category:IsA("Folder") then
                object = category:FindFirstChild(objectId)
                if object then
                    break
                end
            end
        end
    end
    
    if not object then
        return false, "Object not found"
    end
    
    -- Check ownership
    local owner = object:GetAttribute("Owner")
    if owner ~= player.UserId then
        return false, "You don't own this object"
    end
    
    -- Validate the player's position relative to the object
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false, "Character not found"
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local objectPosition = object.PrimaryPart and object.PrimaryPart.Position or object:GetModelCFrame().Position
    local distance = (rootPart.Position - objectPosition).Magnitude
    if distance > 20 then
        return false, "Too far away to remove object"
    end
    
    -- If the object is a placed inventory item, return it to the player's inventory
    local itemId = object:GetAttribute("ItemId")
    local allowPickup = object:GetAttribute("AllowPickup")
    
    if itemId and allowPickup and GameSystemsManager then
        -- Add the item back to the player's inventory
        GameSystemsManager:AddItemToInventory(player, itemId, 1)
    end
    
    -- Remove the object
    object:Destroy()
    
    return true, "Object removed successfully"
end

-- Pick up an item
function pickupItem(player, itemId, quantity)
    -- Check if the item exists in the GameSystemsManager
    if not GameSystemsManager then
        return false, "Game systems manager not initialized"
    end
    
    -- Add the item to the player's inventory
    local success, message = GameSystemsManager:AddItemToInventory(player, itemId, quantity or 1)
    return success, message
end

-- Set up ProximityPrompt connections for all items in the workspace
local function setupProximityPrompts()
    local function connectPrompt(prompt, item)
        prompt.Triggered:Connect(function(player)
            local itemId = item:GetAttribute("ItemId")
            if itemId then
                local success, message = pickupItem(player, itemId, 1)
                if success then
                    item:Destroy()
                end
            end
        end)
    end
    
    -- Connect existing prompts
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item:IsA("Model") and item:GetAttribute("ItemId") and item:GetAttribute("AllowPickup") then
            for _, part in ipairs(item:GetDescendants()) do
                if part:IsA("BasePart") then
                    local prompt = part:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then
                        connectPrompt(prompt, item)
                    end
                end
            end
        end
    end
    
    -- Connect future prompts
    Workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("ProximityPrompt") then
            local item = descendant:FindFirstAncestorOfClass("Model")
            if item and item:GetAttribute("ItemId") and item:GetAttribute("AllowPickup") then
                connectPrompt(descendant, item)
            end
        end
    end)
end

-- Initialize the building manager
local function initialize()
    setupRemoteEvents()
    setupProximityPrompts()
    print("BuildingManager: Initialized")
end

initialize()
