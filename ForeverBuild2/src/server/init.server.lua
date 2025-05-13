local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local SharedModule = require(ReplicatedStorage.shared)
local GameManager = SharedModule.GameManager
local CurrencyManager = SharedModule.Economy.CurrencyManager
local InteractionManagerModule = SharedModule.Interaction.Manager
local interactionManager = InteractionManagerModule.new()
interactionManager:Initialize()

-- Create Remotes folder if it doesn't exist
if not ReplicatedStorage:FindFirstChild("Remotes") then
    local remotes = Instance.new("Folder")
    remotes.Name = "Remotes"
    remotes.Parent = ReplicatedStorage
end

-- Create remote events and functions
local remotes = ReplicatedStorage.Remotes
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
    if not remotes:FindFirstChild(eventName) then
        local event = Instance.new("RemoteEvent")
        event.Name = eventName
        event.Parent = remotes
    end
end

-- Create RemoteFunctions
for _, functionName in ipairs(functions) do
    if not remotes:FindFirstChild(functionName) then
        local func = Instance.new("RemoteFunction")
        func.Name = functionName
        func.Parent = remotes
    end
end

-- Initialize managers
local currencyManager = CurrencyManager.new()
-- If you want to use OOP, ensure the module returns a constructor
-- For now, use as modules
-- local gameManager = GameManager.new()
-- local interactionManager = InteractionManager.new()

if GameManager.Initialize then GameManager.Initialize() end
-- interactionManager is already initialized above

-- Set up event handlers
remotes.BuyItem.OnServerEvent:Connect(function(player, itemId)
    if GameManager.HandleBuyItem then
        GameManager.HandleBuyItem(player, itemId)
    end
end)

remotes.PlaceItem.OnServerEvent:Connect(function(player, itemId, position, rotation)
    if GameManager.HandlePlaceItem then
        GameManager.HandlePlaceItem(player, itemId, position, rotation)
    end
end)

remotes.MoveItem.OnServerEvent:Connect(function(player, itemId, newPosition)
    if GameManager.HandleMoveItem then
        GameManager.HandleMoveItem(player, itemId, newPosition)
    end
end)

remotes.RotateItem.OnServerEvent:Connect(function(player, itemId, newRotation)
    if GameManager.HandleRotateItem then
        GameManager.HandleRotateItem(player, itemId, newRotation)
    end
end)

remotes.ChangeColor.OnServerEvent:Connect(function(player, itemId, newColor)
    if GameManager.HandleChangeColor then
        GameManager.HandleChangeColor(player, itemId, newColor)
    end
end)

remotes.RemoveItem.OnServerEvent:Connect(function(player, itemId)
    if GameManager.HandleRemoveItem then
        GameManager.HandleRemoveItem(player, itemId)
    end
end)

remotes.GetInventory.OnServerInvoke = function(player)
    if GameManager.GetPlayerInventory then
        return GameManager.GetPlayerInventory(player)
    end
end

remotes.GetItemData.OnServerInvoke = function(player, itemId)
    if GameManager.GetItemData then
        return GameManager.GetItemData(itemId)
    end
end

remotes.InteractWithItem.OnServerEvent:Connect(function(player, placedItem, interactionType)
    if not GameManager.GetItemPlacement then return end
    local placement = GameManager.GetItemPlacement(placedItem.id)
    if not placement then return end
    local success = interactionManager:HandleInteraction(player, placedItem.id, interactionType, placement)
    if not success and remotes.NotifyPlayer then
        remotes.NotifyPlayer:FireClient(player, "Cannot interact with this item!")
    end
end)

remotes.GetAvailableInteractions.OnServerInvoke = function(player, placedItem)
    if not GameManager.GetItemPlacement then return {} end
    local placement = GameManager.GetItemPlacement(placedItem.id)
    if not placement then return {} end
    if not GameManager.GetItemData then return {} end
    local itemData = GameManager.GetItemData(placedItem.id)
    if not itemData then return {} end
    local interactions = {"examine"}
    if not placement.locked then
        table.insert(interactions, "pickup")
    end
    if itemData.useEffect then
        table.insert(interactions, "use")
    end
    if itemData.customInteractions then
        for _, interaction in ipairs(itemData.customInteractions) do
            table.insert(interactions, interaction)
        end
    end
    return interactions
end

remotes.AddToInventory.OnServerEvent:Connect(function(player, itemId)
    if GameManager.AddToInventory then
        GameManager.AddToInventory(player, itemId)
    end
end)

remotes.ApplyItemEffect.OnServerEvent:Connect(function(player, itemId, placement)
    if GameManager.ApplyItemEffect then
        GameManager.ApplyItemEffect(player, itemId, placement)
    end
end)

print("Server initialized successfully") 