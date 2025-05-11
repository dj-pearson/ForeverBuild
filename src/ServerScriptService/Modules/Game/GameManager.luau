local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)
local ObjectManager = require(ReplicatedStorage.Modules.ObjectManager)
local DataStoreManager = require(ServerScriptService.Server.Modules.Data.DataStoreManager)
local SpawnManager = require(ReplicatedStorage.Modules.SpawnManager)
local ToolsManager = require(ReplicatedStorage.Modules.ToolsManager)
local DailyRewardsManager = require(ReplicatedStorage.Modules.DailyRewardsManager)
local LeaderboardManager = require(ReplicatedStorage.Modules.LeaderboardManager)
local AchievementManager = require(ReplicatedStorage.Modules.AchievementManager)
local RandomDropManager = require(ReplicatedStorage.Modules.RandomDropManager)

local GameManager = {}

-- Remote events
local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage

local purchaseObjectEvent = Instance.new("RemoteEvent")
purchaseObjectEvent.Name = "PurchaseObject"
purchaseObjectEvent.Parent = remotes

local placeObjectEvent = Instance.new("RemoteEvent")
placeObjectEvent.Name = "PlaceObject"
placeObjectEvent.Parent = remotes

local getMarketplaceItemsEvent = Instance.new("RemoteFunction")
getMarketplaceItemsEvent.Name = "GetMarketplaceItems"
getMarketplaceItemsEvent.Parent = remotes

local purchaseToolEvent = Instance.new("RemoteEvent")
purchaseToolEvent.Name = "PurchaseTool"
purchaseToolEvent.Parent = remotes

local getAvailableToolsEvent = Instance.new("RemoteFunction")
getAvailableToolsEvent.Name = "GetAvailableTools"
getAvailableToolsEvent.Parent = remotes

local claimDailyRewardEvent = Instance.new("RemoteEvent")
claimDailyRewardEvent.Name = "ClaimDailyReward"
claimDailyRewardEvent.Parent = remotes

local getDailyRewardInfoEvent = Instance.new("RemoteFunction")
getDailyRewardInfoEvent.Name = "GetDailyRewardInfo"
getDailyRewardInfoEvent.Parent = remotes

local bulkPurchaseObjectEvent = Instance.new("RemoteEvent")
bulkPurchaseObjectEvent.Name = "BulkPurchaseObject"
bulkPurchaseObjectEvent.Parent = remotes

local moveObjectEvent = Instance.new("RemoteEvent")
moveObjectEvent.Name = "MoveObject"
moveObjectEvent.Parent = remotes

local cloneObjectEvent = Instance.new("RemoteEvent")
cloneObjectEvent.Name = "CloneObject"
cloneObjectEvent.Parent = remotes

local removeObjectEvent = Instance.new("RemoteEvent")
removeObjectEvent.Name = "RemoveObject"
removeObjectEvent.Parent = remotes

local rotateObjectEvent = Instance.new("RemoteEvent")
rotateObjectEvent.Name = "RotateObject"
rotateObjectEvent.Parent = remotes

local groupObjectsEvent = Instance.new("RemoteEvent")
groupObjectsEvent.Name = "GroupObjects"
groupObjectsEvent.Parent = remotes

local ungroupObjectsEvent = Instance.new("RemoteEvent")
ungroupObjectsEvent.Name = "UngroupObjects"
ungroupObjectsEvent.Parent = remotes

local getTutorialStatusEvent = Instance.new("RemoteFunction")
getTutorialStatusEvent.Name = "GetTutorialStatus"
getTutorialStatusEvent.Parent = remotes

local completeTutorialEvent = Instance.new("RemoteEvent")
completeTutorialEvent.Name = "CompleteTutorial"
completeTutorialEvent.Parent = remotes

-- Player data
local playerData = {}

-- Admin configuration
local ADMIN_ID = 7768610061

-- Helper function to check if player is admin
local function isAdmin(player)
    return player.UserId == ADMIN_ID
end

-- Initialize player data
local function initPlayerData(player)
    local data = DataStoreManager.LoadPlayerData(player)
    playerData[player.UserId] = data
end

-- Player joined
Players.PlayerAdded:Connect(function(player)
    initPlayerData(player)
    
    -- Load placed objects
    for _, objectData in ipairs(playerData[player.UserId].placedObjects) do
        local object = ObjectManager.createObject(objectData.type)
        if object then
            object:SetPrimaryPartCFrame(CFrame.new(objectData.position))
            object.Parent = workspace
        end
    end
    
    -- Send marketplace items to player
    getMarketplaceItemsEvent:Invoke(player)
end)

-- Player leaving
Players.PlayerRemoving:Connect(function(player)
    DataStoreManager.SavePlayerData(player)
    playerData[player.UserId] = nil
end)

-- Purchase object
purchaseObjectEvent.OnServerEvent:Connect(function(player, objectType)
    local data = playerData[player.UserId]
    if not data then return end
    
    local objectConfig = ObjectManager.getObjectConfig(objectType)
    if not objectConfig then return end
    
    -- Check if player is admin or has enough coins
    if isAdmin(player) or data.coins >= objectConfig.price then
        -- Only deduct coins if not admin
        if not isAdmin(player) then
            data.coins = data.coins - objectConfig.price
        end
        
        table.insert(data.inventory, {
            type = objectType,
            purchaseTime = os.time()
        })
        
        -- Update stats
        GameManager.updatePlayerStats(player, data)
        
        -- Notify client of successful purchase
        purchaseObjectEvent:FireClient(player, true, data.coins)
    else
        purchaseObjectEvent:FireClient(player, false, data.coins)
    end
end)

-- Bulk purchase objects
bulkPurchaseObjectEvent.OnServerEvent:Connect(function(player, objectTypes, quantity)
    local data = playerData[player.UserId]
    if not data then return end
    
    -- Calculate total cost
    local totalCost = 0
    for _, objectType in ipairs(objectTypes) do
        local objectConfig = ObjectManager.getObjectConfig(objectType)
        if objectConfig then
            totalCost = totalCost + (objectConfig.price * quantity)
        end
    end
    
    -- Check if player is admin or has enough coins
    if isAdmin(player) or data.coins >= totalCost then
        -- Only deduct coins if not admin
        if not isAdmin(player) then
            data.coins = data.coins - totalCost
        end
        
        -- Add items to inventory
        for _, objectType in ipairs(objectTypes) do
            for i = 1, quantity do
                table.insert(data.inventory, {
                    type = objectType,
                    purchaseTime = os.time()
                })
            end
        end
        
        -- Update stats
        GameManager.updatePlayerStats(player, data)
        
        -- Notify client of successful purchase
        bulkPurchaseObjectEvent:FireClient(player, true, data.coins)
    else
        bulkPurchaseObjectEvent:FireClient(player, false, data.coins)
    end
end)

-- Place object
placeObjectEvent.OnServerEvent:Connect(function(player, objectType, position)
    local data = playerData[player.UserId]
    if not data then return end
    
    -- Find object in inventory
    local objectIndex
    for i, item in ipairs(data.inventory) do
        if item.type == objectType then
            objectIndex = i
            break
        end
    end
    
    if not objectIndex then return end
    
    -- Create and place object
    local object = ObjectManager.createObject(objectType)
    if object then
        object:SetPrimaryPartCFrame(CFrame.new(position))
        object.Parent = workspace
        
        -- Add to placed objects
        table.insert(data.placedObjects, {
            type = objectType,
            position = position
        })
        
        -- Remove from inventory
        table.remove(data.inventory, objectIndex)
        
        -- Update stats
        GameManager.updatePlayerStats(player, data)
        
        -- Notify client of successful placement
        placeObjectEvent:FireClient(player, true)
    else
        placeObjectEvent:FireClient(player, false)
    end
end)

-- Get marketplace items
getMarketplaceItemsEvent.OnServerInvoke = function(player)
    return ObjectManager.getMarketplaceItems()
end

-- Purchase tool
purchaseToolEvent.OnServerEvent:Connect(function(player, toolType)
    local data = playerData[player.UserId]
    if not data then return end
    
    local toolConfig = ToolsManager.getAvailableTools()[toolType]
    if not toolConfig then return end
    
    -- Check if player already has this tool
    for _, tool in ipairs(data.tools) do
        if tool.type == toolType then
            purchaseToolEvent:FireClient(player, false, "Already owned")
            return
        end
    end
    
    -- Check if player is admin or has enough coins
    if isAdmin(player) or data.coins >= Constants.TOOL_PRICES[toolType] then
        -- Only deduct coins if not admin
        if not isAdmin(player) then
            data.coins = data.coins - Constants.TOOL_PRICES[toolType]
        end
        
        -- Create and give tool to player
        local tool = ToolsManager.createTool(toolType)
        if tool then
            tool.Parent = player.Backpack
            table.insert(data.tools, {
                type = toolType,
                purchaseTime = os.time()
            })
            
            -- Set up tool activation
            tool.Activated:Connect(function()
                ToolsManager.applyToolEffect(player, toolType)
            end)
            
            purchaseToolEvent:FireClient(player, true, data.coins)
        else
            purchaseToolEvent:FireClient(player, false, "Failed to create tool")
        end
    else
        purchaseToolEvent:FireClient(player, false, "Not enough coins")
    end
end)

-- Get available tools
getAvailableToolsEvent.OnServerInvoke = function(player)
    return ToolsManager.getAvailableTools()
end

-- Claim daily reward
claimDailyRewardEvent.OnServerEvent:Connect(function(player)
    local data = playerData[player.UserId]
    if not data then return end
    
    local success, result = DailyRewardsManager.claimReward(data)
    if success then
        -- Update stats
        GameManager.updatePlayerStats(player, data)
        
        -- Notify client of successful claim
        claimDailyRewardEvent:FireClient(player, true, {
            reward = result,
            nextDay = DailyRewardsManager.getNextRewardDay(data),
            streak = data.rewardStreak
        })
    else
        claimDailyRewardEvent:FireClient(player, false, result)
    end
end)

-- Get daily reward info
getDailyRewardInfoEvent.OnServerInvoke = function(player)
    local data = playerData[player.UserId]
    if not data then return nil end
    
    return {
        canClaim = DailyRewardsManager.canClaimReward(data),
        nextDay = DailyRewardsManager.getNextRewardDay(data),
        streak = data.rewardStreak,
        rewards = DailyRewardsManager.getAllRewards()
    }
end

-- Move object
moveObjectEvent.OnServerEvent:Connect(function(player, objectPath, newPosition)
    local data = playerData[player.UserId]
    if not data then return end
    
    -- Check if player is admin or has enough coins
    if isAdmin(player) or data.coins >= Constants.PRICES.ACTIONS.MOVE then
        -- Find object in workspace
        local object = workspace:FindFirstChild(objectPath)
        if not object then
            moveObjectEvent:FireClient(player, false, "Object not found")
            return
        end
        
        -- Check if player owns the object
        local isOwner = false
        for _, placedObject in ipairs(data.placedObjects) do
            if placedObject.path == objectPath then
                isOwner = true
                break
            end
        end
        
        if not isOwner then
            moveObjectEvent:FireClient(player, false, "You don't own this object")
            return
        end
        
        -- Move object
        object:PivotTo(CFrame.new(newPosition))
        
        -- Update placed object data
        for _, placedObject in ipairs(data.placedObjects) do
            if placedObject.path == objectPath then
                placedObject.position = newPosition
                break
            end
        end
        
        -- Only deduct coins if not admin
        if not isAdmin(player) then
            data.coins = data.coins - Constants.PRICES.ACTIONS.MOVE
        end
        
        -- Notify client
        moveObjectEvent:FireClient(player, true)
    else
        moveObjectEvent:FireClient(player, false, "Not enough coins")
    end
end)

-- Clone object
cloneObjectEvent.OnServerEvent:Connect(function(player, objectPath, newPosition)
    local data = playerData[player.UserId]
    if not data then return end
    
    -- Check if player is admin or has enough coins
    if isAdmin(player) or data.coins >= Constants.PRICES.ACTIONS.CLONE then
        -- Find object in workspace
        local object = workspace:FindFirstChild(objectPath)
        if not object then
            cloneObjectEvent:FireClient(player, false, "Object not found")
            return
        end
        
        -- Check if player owns the object
        local isOwner = false
        for _, placedObject in ipairs(data.placedObjects) do
            if placedObject.path == objectPath then
                isOwner = true
                break
            end
        end
        
        if not isOwner then
            cloneObjectEvent:FireClient(player, false, "You don't own this object")
            return
        end
        
        -- Clone object
        local clone = object:Clone()
        clone:PivotTo(CFrame.new(newPosition))
        clone.Parent = workspace
        
        -- Add to placed objects
        table.insert(data.placedObjects, {
            type = object:GetAttribute("ObjectType"),
            position = newPosition,
            path = clone:GetFullName()
        })
        
        -- Only deduct coins if not admin
        if not isAdmin(player) then
            data.coins = data.coins - Constants.PRICES.ACTIONS.CLONE
        end
        
        -- Notify client
        cloneObjectEvent:FireClient(player, true)
    else
        cloneObjectEvent:FireClient(player, false, "Not enough coins")
    end
end)

-- Remove object
removeObjectEvent.OnServerEvent:Connect(function(player, objectPath)
    local data = playerData[player.UserId]
    if not data then return end
    
    -- Check if player is admin or has enough coins
    if isAdmin(player) or data.coins >= Constants.PRICES.ACTIONS.REMOVE then
        -- Find object in workspace
        local object = workspace:FindFirstChild(objectPath)
        if not object then
            removeObjectEvent:FireClient(player, false, "Object not found")
            return
        end
        
        -- Check if player owns the object
        local objectIndex
        for i, placedObject in ipairs(data.placedObjects) do
            if placedObject.path == objectPath then
                objectIndex = i
                break
            end
        end
        
        if not objectIndex then
            removeObjectEvent:FireClient(player, false, "You don't own this object")
            return
        end
        
        -- Remove object
        object:Destroy()
        
        -- Remove from placed objects
        table.remove(data.placedObjects, objectIndex)
        
        -- Only deduct coins if not admin
        if not isAdmin(player) then
            data.coins = data.coins - Constants.PRICES.ACTIONS.REMOVE
        end
        
        -- Notify client
        removeObjectEvent:FireClient(player, true)
    else
        removeObjectEvent:FireClient(player, false, "Not enough coins")
    end
end)

-- Rotate object
rotateObjectEvent.OnServerEvent:Connect(function(player, objectPath, rotation)
    local data = playerData[player.UserId]
    if not data then return end
    
    -- Find object in workspace
    local object = workspace:FindFirstChild(objectPath)
    if not object then
        rotateObjectEvent:FireClient(player, false, "Object not found")
        return
    end
    
    -- Check if player owns the object
    local isOwner = false
    for _, placedObject in ipairs(data.placedObjects) do
        if placedObject.path == objectPath then
            isOwner = true
            break
        end
    end
    
    if not isOwner then
        rotateObjectEvent:FireClient(player, false, "You don't own this object")
        return
    end
    
    -- Rotate object
    local currentCFrame = object:GetPrimaryPartCFrame()
    local newCFrame = CFrame.new(currentCFrame.Position) * CFrame.Angles(0, math.rad(rotation), 0)
    object:PivotTo(newCFrame)
    
    -- Update placed object data
    for _, placedObject in ipairs(data.placedObjects) do
        if placedObject.path == objectPath then
            placedObject.rotation = rotation
            break
        end
    end
    
    -- Notify client
    rotateObjectEvent:FireClient(player, true)
end)

-- Group objects
groupObjectsEvent.OnServerEvent:Connect(function(player, objectPaths)
    local data = playerData[player.UserId]
    if not data then return end
    
    -- Check if player owns all objects
    local ownedObjects = {}
    for _, objectPath in ipairs(objectPaths) do
        local object = workspace:FindFirstChild(objectPath)
        if not object then
            groupObjectsEvent:FireClient(player, false, "Object not found: " .. objectPath)
            return
        end
        
        local isOwner = false
        for _, placedObject in ipairs(data.placedObjects) do
            if placedObject.path == objectPath then
                isOwner = true
                table.insert(ownedObjects, {
                    object = object,
                    data = placedObject
                })
                break
            end
        end
        
        if not isOwner then
            groupObjectsEvent:FireClient(player, false, "You don't own object: " .. objectPath)
            return
        end
    end
    
    -- Create group
    local group = Instance.new("Model")
    group.Name = "ObjectGroup"
    group.Parent = workspace
    
    -- Move objects into group
    for _, objData in ipairs(ownedObjects) do
        objData.object.Parent = group
    end
    
    -- Set primary part
    if #group:GetChildren() > 0 then
        group.PrimaryPart = group:GetChildren()[1]
    end
    
    -- Add group to placed objects
    table.insert(data.placedObjects, {
        type = "group",
        path = group:GetFullName(),
        objects = objectPaths
    })
    
    -- Remove individual objects from placed objects
    for _, objData in ipairs(ownedObjects) do
        for i, placedObject in ipairs(data.placedObjects) do
            if placedObject.path == objData.data.path then
                table.remove(data.placedObjects, i)
                break
            end
        end
    end
    
    -- Notify client
    groupObjectsEvent:FireClient(player, true)
end)

-- Ungroup objects
ungroupObjectsEvent.OnServerEvent:Connect(function(player, groupPath)
    local data = playerData[player.UserId]
    if not data then return end
    
    -- Find group in workspace
    local group = workspace:FindFirstChild(groupPath)
    if not group then
        ungroupObjectsEvent:FireClient(player, false, "Group not found")
        return
    end
    
    -- Check if player owns the group
    local groupData
    for _, placedObject in ipairs(data.placedObjects) do
        if placedObject.path == groupPath then
            groupData = placedObject
            break
        end
    end
    
    if not groupData then
        ungroupObjectsEvent:FireClient(player, false, "You don't own this group")
        return
    end
    
    -- Move objects out of group
    for _, object in ipairs(group:GetChildren()) do
        object.Parent = workspace
        -- Add back to placed objects
        table.insert(data.placedObjects, {
            type = object:GetAttribute("ObjectType"),
            path = object:GetFullName(),
            position = object:GetPrimaryPartCFrame().Position,
            rotation = object:GetPrimaryPartCFrame().Orientation
        })
    end
    
    -- Remove group from placed objects
    for i, placedObject in ipairs(data.placedObjects) do
        if placedObject.path == groupPath then
            table.remove(data.placedObjects, i)
            break
        end
    end
    
    -- Remove group
    group:Destroy()
    
    -- Notify client
    ungroupObjectsEvent:FireClient(player, true)
end)

-- Get tutorial status
getTutorialStatusEvent.OnServerInvoke = function(player)
    local data = playerData[player.UserId]
    if not data then return true end
    
    return not data.tutorialCompleted
end

-- Complete tutorial
completeTutorialEvent.OnServerEvent:Connect(function(player)
    local data = playerData[player.UserId]
    if not data then return end
    
    data.tutorialCompleted = true
    
    -- Give tutorial completion reward
    data.coins = data.coins + Constants.TUTORIAL_REWARD
    
    -- Update stats
    GameManager.updatePlayerStats(player, data)
end)

-- Add world objects saving/loading
local function loadWorldObjects()
    local worldObjects = DataStoreManager.LoadWorldObjects()
    for _, objectData in ipairs(worldObjects) do
        local object = ObjectManager.createObject(objectData.type)
        if object then
            object:SetPrimaryPartCFrame(CFrame.new(objectData.position))
            object.Parent = workspace
        end
    end
end

local function saveWorldObjects()
    local worldObjects = {}
    for _, object in ipairs(workspace:GetChildren()) do
        if object:IsA("Model") then
            table.insert(worldObjects, {
                type = object.Name,
                position = object:GetPrimaryPartCFrame().Position
            })
        end
    end
    DataStoreManager.SetWorldObjects(worldObjects, true)
end

-- Initialize
function GameManager.init()
    loadWorldObjects()
    SpawnManager.init()
    LeaderboardManager.init()
    AchievementManager.init()
    RandomDropManager.init()
    print("GameManager initialized")
end

-- Get player data
function GameManager.getPlayerData(player)
    return playerData[player.UserId]
end

-- Update player stats
function GameManager.updatePlayerStats(player, data)
    -- Update leaderboard
    LeaderboardManager.updatePlayerScore(player, "coins", data.coins)
    LeaderboardManager.updatePlayerScore(player, "objects_placed", #data.placedObjects)
    LeaderboardManager.updatePlayerScore(player, "daily_streak", data.rewardStreak)
    LeaderboardManager.updatePlayerScore(player, "total_purchases", #data.inventory)
    
    -- Check achievements
    AchievementManager.checkAchievements(player, {
        totalPurchases = #data.inventory,
        uniqueObjectsPlaced = #data.placedObjects,
        totalObjectsPlaced = #data.placedObjects,
        dailyStreak = data.rewardStreak,
        totalCoinsEarned = data.coins,
        uniqueShares = data.uniqueShares or 0
    })
end

-- Call saveWorldObjects in shutdown
game:BindToClose(function()
    saveWorldObjects()
end)

return GameManager