local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Load core modules
local GameManager = require(script.Parent.Parent.core.GameManager)
local CurrencyManager = require(script.Parent.CurrencyManager)

-- Create RemoteEvents folder
local remoteEvents = Instance.new("Folder")
remoteEvents.Name = "RemoteEvents"
remoteEvents.Parent = ReplicatedStorage

-- Create remote events
local events = {
    "BuyItem",
    "PlaceItem",
    "MoveItem",
    "RotateItem",
    "ChangeItemColor",
    "RemoveItem",
    "GetInventory",
    "GetItemData"
}

for _, eventName in ipairs(events) do
    local event = Instance.new("RemoteEvent")
    event.Name = eventName
    event.Parent = remoteEvents
end

-- Initialize managers
local gameManager = GameManager.new()
local currencyManager = CurrencyManager.new()
gameManager:Initialize()

-- Initialize game manager
gameManager:Initialize()

-- Set up remote event handlers
remoteEvents.BuyItem.OnServerEvent:Connect(function(player, itemId)
    local success, message = gameManager:BuyItem(player, itemId)
    remoteEvents.BuyItem:FireClient(player, success, message)
end)

remoteEvents.PlaceItem.OnServerEvent:Connect(function(player, itemId, position, rotation)
    local success, message = gameManager:PlaceItem(player, itemId, position, rotation)
    remoteEvents.PlaceItem:FireClient(player, success, message)
end)

remoteEvents.MoveItem.OnServerEvent:Connect(function(player, placedItem, newPosition)
    local success, message = gameManager:MoveItem(player, placedItem, newPosition)
    remoteEvents.MoveItem:FireClient(player, success, message)
end)

remoteEvents.RotateItem.OnServerEvent:Connect(function(player, placedItem, newRotation)
    local success, message = gameManager:RotateItem(player, placedItem, newRotation)
    remoteEvents.RotateItem:FireClient(player, success, message)
end)

remoteEvents.ChangeItemColor.OnServerEvent:Connect(function(player, placedItem, newColor)
    local success, message = gameManager:ChangeItemColor(player, placedItem, newColor)
    remoteEvents.ChangeItemColor:FireClient(player, success, message)
end)

remoteEvents.RemoveItem.OnServerEvent:Connect(function(player, placedItem)
    local success, message = gameManager:RemoveItem(player, placedItem)
    remoteEvents.RemoveItem:FireClient(player, success, message)
end)

remoteEvents.GetInventory.OnServerInvoke = function(player)
    return gameManager:GetPlayerInventory(player)
end

remoteEvents.GetItemData.OnServerInvoke = function(player, itemId)
    return gameManager:GetItemData(itemId)
end

print("Server initialized successfully") 