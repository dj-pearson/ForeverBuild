local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Load core modules
local GameManager = require(ReplicatedStorage.shared.core.GameManager)
local CurrencyManager = require(ReplicatedStorage.shared.core.economy.CurrencyManager)
local InteractionManager = require(ReplicatedStorage.shared.core.interaction.InteractionManager)

-- Create RemoteEvents folder if it doesn't exist
if not ReplicatedStorage:FindFirstChild("RemoteEvents") then
    local remoteEvents = Instance.new("Folder")
    remoteEvents.Name = "RemoteEvents"
    remoteEvents.Parent = ReplicatedStorage
end

-- Create remote events and functions
local remoteEvents = ReplicatedStorage.RemoteEvents
local events = {
    "BuyItem",
    "PlaceItem",
    "MoveItem",
    "RotateItem",
    "ChangeColor",
    "RemoveItem",
    "InteractWithItem",
    "AddToInventory",
    "ApplyItemEffect",
    "ShowItemDescription",
    "NotifyPlayer",
    "UpdateBalance"
}

local functions = {
    "GetInventory",
    "GetItemData",
    "GetAvailableInteractions"
}

-- Create RemoteEvents
for _, eventName in ipairs(events) do
    if not remoteEvents:FindFirstChild(eventName) then
        local event = Instance.new("RemoteEvent")
        event.Name = eventName
        event.Parent = remoteEvents
    end
end

-- Create RemoteFunctions
for _, functionName in ipairs(functions) do
    if not remoteEvents:FindFirstChild(functionName) then
        local func = Instance.new("RemoteFunction")
        func.Name = functionName
        func.Parent = remoteEvents
    end
end

-- Initialize managers
local gameManager = GameManager.new()
local currencyManager = CurrencyManager.new()
local interactionManager = InteractionManager.new()

gameManager:Initialize()
currencyManager:Initialize()
interactionManager:Initialize()

-- Set up event handlers
remoteEvents.BuyItem.OnServerEvent:Connect(function(player, itemId)
    gameManager:HandleBuyItem(player, itemId)
end)

remoteEvents.PlaceItem.OnServerEvent:Connect(function(player, itemId, position, rotation)
    gameManager:HandlePlaceItem(player, itemId, position, rotation)
end)

remoteEvents.MoveItem.OnServerEvent:Connect(function(player, itemId, newPosition)
    gameManager:HandleMoveItem(player, itemId, newPosition)
end)

remoteEvents.RotateItem.OnServerEvent:Connect(function(player, itemId, newRotation)
    gameManager:HandleRotateItem(player, itemId, newRotation)
end)

remoteEvents.ChangeColor.OnServerEvent:Connect(function(player, itemId, newColor)
    gameManager:HandleChangeColor(player, itemId, newColor)
end)

remoteEvents.RemoveItem.OnServerEvent:Connect(function(player, itemId)
    gameManager:HandleRemoveItem(player, itemId)
end)

remoteEvents.GetInventory.OnServerInvoke = function(player)
    return gameManager:GetPlayerInventory(player)
end

remoteEvents.GetItemData.OnServerInvoke = function(player, itemId)
    return gameManager:GetItemData(itemId)
end

remoteEvents.InteractWithItem.OnServerEvent:Connect(function(player, placedItem, interactionType)
    -- Get the placement data
    local placement = gameManager:GetItemPlacement(placedItem.id)
    if not placement then return end
    
    -- Handle the interaction
    local success = interactionManager:HandleInteraction(player, placedItem.id, interactionType, placement)
    
    -- Notify player of result
    if not success then
        remoteEvents.NotifyPlayer:FireClient(player, "Cannot interact with this item!")
    end
end)

remoteEvents.GetAvailableInteractions.OnServerInvoke = function(player, placedItem)
    -- Get the placement data
    local placement = gameManager:GetItemPlacement(placedItem.id)
    if not placement then return {} end
    
    -- Get item data
    local itemData = gameManager:GetItemData(placedItem.id)
    if not itemData then return {} end
    
    -- Get available interactions
    local interactions = {"examine"} -- All items can be examined
    
    -- Add pickup if item is not locked
    if not placement.locked then
        table.insert(interactions, "pickup")
    end
    
    -- Add use if item has use effect
    if itemData.useEffect then
        table.insert(interactions, "use")
    end
    
    -- Add custom interactions
    if itemData.customInteractions then
        for _, interaction in ipairs(itemData.customInteractions) do
            table.insert(interactions, interaction)
        end
    end
    
    return interactions
end

remoteEvents.AddToInventory.OnServerEvent:Connect(function(player, itemId)
    gameManager:AddToInventory(player, itemId)
end)

remoteEvents.ApplyItemEffect.OnServerEvent:Connect(function(player, itemId, placement)
    gameManager:ApplyItemEffect(player, itemId, placement)
end)

print("Server initialized successfully") 