local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local SocialHubManager = {}

-- Hub types and their properties
local HUB_TYPES = {
    GATHERING = {
        name = "Gathering Space",
        maxPlayers = 50,
        description = "A space for players to gather and socialize",
        defaultSettings = {
            allowBuilding = true,
            allowTrading = false,
            allowEvents = true
        }
    },
    EVENT = {
        name = "Event Venue",
        maxPlayers = 100,
        description = "A venue for hosting events and competitions",
        defaultSettings = {
            allowBuilding = false,
            allowTrading = false,
            allowEvents = true
        }
    },
    TRADING = {
        name = "Trading Zone",
        maxPlayers = 30,
        description = "A dedicated space for player trading",
        defaultSettings = {
            allowBuilding = false,
            allowTrading = true,
            allowEvents = false
        }
    }
}

-- Local state
local hubs = {}
local playerHubs = {}

-- Initialize social hub system
function SocialHubManager.init()
    -- Create remote events
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    
    local createHubEvent = Instance.new("RemoteFunction")
    createHubEvent.Name = "CreateHub"
    createHubEvent.Parent = remotes
    
    local joinHubEvent = Instance.new("RemoteFunction")
    joinHubEvent.Name = "JoinHub"
    joinHubEvent.Parent = remotes
    
    local leaveHubEvent = Instance.new("RemoteEvent")
    leaveHubEvent.Name = "LeaveHub"
    leaveHubEvent.Parent = remotes
    
    local updateHubSettingsEvent = Instance.new("RemoteEvent")
    updateHubSettingsEvent.Name = "UpdateHubSettings"
    updateHubSettingsEvent.Parent = remotes
    
    local getHubInfoEvent = Instance.new("RemoteFunction")
    getHubInfoEvent.Name = "GetHubInfo"
    getHubInfoEvent.Parent = remotes
    
    -- Set up event handlers
    createHubEvent.OnServerInvoke = function(player, hubType, name, description, settings)
        return SocialHubManager.createHub(player, hubType, name, description, settings)
    end
    
    joinHubEvent.OnServerInvoke = function(player, hubId)
        return SocialHubManager.joinHub(player, hubId)
    end
    
    leaveHubEvent.OnServerEvent:Connect(function(player)
        SocialHubManager.leaveHub(player)
    end)
    
    updateHubSettingsEvent.OnServerEvent:Connect(function(player, hubId, settings)
        SocialHubManager.updateHubSettings(player, hubId, settings)
    end)
    
    getHubInfoEvent.OnServerInvoke = function(player, hubId)
        return SocialHubManager.getHubInfo(hubId)
    end
    
    -- Set up player connection/disconnection handlers
    Players.PlayerAdded:Connect(function(player)
        SocialHubManager.handlePlayerJoin(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        SocialHubManager.handlePlayerLeave(player)
    end)
end

-- Handle player joining
function SocialHubManager.handlePlayerJoin(player)
    playerHubs[player.UserId] = nil
end

-- Handle player leaving
function SocialHubManager.handlePlayerLeave(player)
    local userId = player.UserId
    if playerHubs[userId] then
        SocialHubManager.leaveHub(player)
    end
end

-- Create a new hub
function SocialHubManager.createHub(player, hubType, name, description, settings)
    local userId = player.UserId
    
    -- Validate hub type
    if not HUB_TYPES[hubType] then
        return false, "Invalid hub type"
    end
    
    -- Check if player already has a hub
    if playerHubs[userId] then
        return false, "You already have an active hub"
    end
    
    -- Create hub
    local hubId = userId .. "_" .. os.time()
    local hub = {
        id = hubId,
        ownerId = userId,
        type = hubType,
        name = name,
        description = description,
        settings = settings or HUB_TYPES[hubType].defaultSettings,
        players = {},
        created = os.time(),
        lastActive = os.time()
    }
    
    hubs[hubId] = hub
    playerHubs[userId] = hubId
    
    -- Notify players
    SocialHubManager.notifyHubUpdate(hubId)
    
    return true, hubId
end

-- Join a hub
function SocialHubManager.joinHub(player, hubId)
    local userId = player.UserId
    
    -- Check if player is already in a hub
    if playerHubs[userId] then
        return false, "You are already in a hub"
    end
    
    -- Get hub
    local hub = hubs[hubId]
    if not hub then
        return false, "Hub not found"
    end
    
    -- Check if hub is full
    if #hub.players >= HUB_TYPES[hub.type].maxPlayers then
        return false, "Hub is full"
    end
    
    -- Add player to hub
    table.insert(hub.players, userId)
    playerHubs[userId] = hubId
    hub.lastActive = os.time()
    
    -- Notify players
    SocialHubManager.notifyHubUpdate(hubId)
    
    return true
end

-- Leave current hub
function SocialHubManager.leaveHub(player)
    local userId = player.UserId
    local hubId = playerHubs[userId]
    
    if not hubId then return end
    
    local hub = hubs[hubId]
    if not hub then return end
    
    -- Remove player from hub
    for i, playerId in ipairs(hub.players) do
        if playerId == userId then
            table.remove(hub.players, i)
            break
        end
    end
    
    playerHubs[userId] = nil
    hub.lastActive = os.time()
    
    -- Delete hub if empty and not owned by player
    if #hub.players == 0 and hub.ownerId ~= userId then
        hubs[hubId] = nil
    else
        -- Notify players
        SocialHubManager.notifyHubUpdate(hubId)
    end
end

-- Update hub settings
function SocialHubManager.updateHubSettings(player, hubId, settings)
    local userId = player.UserId
    local hub = hubs[hubId]
    
    if not hub or hub.ownerId ~= userId then
        return false, "Not authorized"
    end
    
    -- Update settings
    hub.settings = settings
    hub.lastActive = os.time()
    
    -- Notify players
    SocialHubManager.notifyHubUpdate(hubId)
    
    return true
end

-- Get hub information
function SocialHubManager.getHubInfo(hubId)
    local hub = hubs[hubId]
    if not hub then return nil end
    
    return {
        id = hub.id,
        type = hub.type,
        name = hub.name,
        description = hub.description,
        settings = hub.settings,
        playerCount = #hub.players,
        maxPlayers = HUB_TYPES[hub.type].maxPlayers,
        created = hub.created,
        lastActive = hub.lastActive
    }
end

-- Notify players of hub update
function SocialHubManager.notifyHubUpdate(hubId)
    local hub = hubs[hubId]
    if not hub then return end
    
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    local updateEvent = remotes:WaitForChild("HubUpdate")
    
    for _, playerId in ipairs(hub.players) do
        local player = Players:GetPlayerByUserId(playerId)
        if player then
            updateEvent:FireClient(player, SocialHubManager.getHubInfo(hubId))
        end
    end
end

-- Get all hubs
function SocialHubManager.getAllHubs()
    local hubList = {}
    for hubId, hub in pairs(hubs) do
        table.insert(hubList, SocialHubManager.getHubInfo(hubId))
    end
    return hubList
end

-- Get player's current hub
function SocialHubManager.getPlayerHub(player)
    local userId = player.UserId
    local hubId = playerHubs[userId]
    if not hubId then return nil end
    
    return SocialHubManager.getHubInfo(hubId)
end

return SocialHubManager 