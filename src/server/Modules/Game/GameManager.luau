local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

-- Load server modules
local DataStoreManager = require(ServerScriptService.Modules.Data.DataStoreManager)

-- Load shared managers
local ObjectManager = require(ReplicatedStorage.Shared.Modules.ObjectManager)
local SpawnManager = require(ReplicatedStorage.Shared.Modules.SpawnManager)
local ToolsManager = require(ReplicatedStorage.Shared.Modules.ToolsManager)
local DailyRewardsManager = require(ReplicatedStorage.Shared.Modules.DailyRewardsManager)
local LeaderboardManager = require(ReplicatedStorage.Shared.Modules.LeaderboardManager)
local AchievementManager = require(ReplicatedStorage.Shared.Modules.AchievementManager)
local RandomDropManager = require(ReplicatedStorage.Shared.Modules.RandomDropManager)

local GameManager = {}

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
    RemoteManager:invokeClient(player, Constants.RemoteFunctions.GetMarketplaceItems)
end)

-- Player leaving
Players.PlayerRemoving:Connect(function(player)
    DataStoreManager.SavePlayerData(player)
    playerData[player.UserId] = nil
end)

-- Set up remote event handlers
RemoteManager:onServerEvent(Constants.RemoteEvents.PurchaseObject, function(player, objectType)
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
        RemoteManager:fireClient(player, Constants.RemoteEvents.PurchaseObject, true, data.coins)
    else
        RemoteManager:fireClient(player, Constants.RemoteEvents.PurchaseObject, false, data.coins)
    end
end)

RemoteManager:onServerEvent(Constants.RemoteEvents.BulkPurchaseObject, function(player, objectTypes, quantity)
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
        RemoteManager:fireClient(player, Constants.RemoteEvents.BulkPurchaseObject, true, data.coins)
    else
        RemoteManager:fireClient(player, Constants.RemoteEvents.BulkPurchaseObject, false, data.coins)
    end
end)

RemoteManager:onServerEvent(Constants.RemoteEvents.PlaceObject, function(player, objectType, position)
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
        RemoteManager:fireClient(player, Constants.RemoteEvents.PlaceObject, true)
    else
        RemoteManager:fireClient(player, Constants.RemoteEvents.PlaceObject, false)
    end
end)

-- Set up remote function handlers
RemoteManager:setServerCallback(Constants.RemoteFunctions.GetMarketplaceItems, function(player)
    return ObjectManager.getMarketplaceItems()
end)

RemoteManager:setServerCallback(Constants.RemoteFunctions.GetAvailableTools, function(player)
    return ToolsManager.getAvailableTools()
end)

RemoteManager:setServerCallback(Constants.RemoteFunctions.GetDailyRewardInfo, function(player)
    local data = playerData[player.UserId]
    if not data then return nil end
    
    return {
        canClaim = DailyRewardsManager.canClaimReward(data),
        nextDay = DailyRewardsManager.getNextRewardDay(data),
        streak = data.rewardStreak,
        rewards = DailyRewardsManager.getAllRewards()
    }
end)

RemoteManager:setServerCallback(Constants.RemoteFunctions.GetTutorialStatus, function(player)
    local data = playerData[player.UserId]
    if not data then return true end
    
    return not data.tutorialCompleted
end)

-- Purchase tool
RemoteManager:onServerEvent(Constants.RemoteEvents.PurchaseTool, function(player, toolType)
    local data = playerData[player.UserId]
    if not data then return end
    
    local toolConfig = ToolsManager.getAvailableTools()[toolType]
    if not toolConfig then return end
    
    -- Check if player already has this tool
    for _, tool in ipairs(data.tools) do
        if tool.type == toolType then
            RemoteManager:fireClient(player, Constants.RemoteEvents.PurchaseTool, false, "Already owned")
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
            
            RemoteManager:fireClient(player, Constants.RemoteEvents.PurchaseTool, true, data.coins)
        else
            RemoteManager:fireClient(player, Constants.RemoteEvents.PurchaseTool, false, "Failed to create tool")
        end
    else
        RemoteManager:fireClient(player, Constants.RemoteEvents.PurchaseTool, false, "Not enough coins")
    end
end)

-- Claim daily reward
RemoteManager:onServerEvent(Constants.RemoteEvents.ClaimDailyReward, function(player)
    local data = playerData[player.UserId]
    if not data then return end
    
    local success, result = DailyRewardsManager.claimReward(data)
    if success then
        -- Update stats
        GameManager.updatePlayerStats(player, data)
        
        -- Notify client of successful claim
        RemoteManager:fireClient(player, Constants.RemoteEvents.ClaimDailyReward, true, {
            reward = result,
            nextDay = DailyRewardsManager.getNextRewardDay(data),
            streak = data.rewardStreak
        })
    else
        RemoteManager:fireClient(player, Constants.RemoteEvents.ClaimDailyReward, false, result)
    end
end)

-- Move object
RemoteManager:onServerEvent(Constants.RemoteEvents.MoveObject, function(player, objectPath, newPosition)
    local data = playerData[player.UserId]
    if not data then return end
    
    -- Check if player is admin or has enough coins
    if isAdmin(player) or data.coins >= Constants.PRICES.ACTIONS.MOVE then
        -- Find object in workspace
        local object = workspace:FindFirstChild(objectPath)
        if not object then
            RemoteManager:fireClient(player, Constants.RemoteEvents.MoveObject, false, "Object not found")
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
            RemoteManager:fireClient(player, Constants.RemoteEvents.MoveObject, false, "You don't own this object")
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
        RemoteManager:fireClient(player, Constants.RemoteEvents.MoveObject, true)
    else
        RemoteManager:fireClient(player, Constants.RemoteEvents.MoveObject, false, "Not enough coins")
    end
end)

-- Clone object
RemoteManager:onServerEvent(Constants.RemoteEvents.CloneObject, function(player, objectPath, newPosition)
    local data = playerData[player.UserId]
    if not data then return end
    
    -- Check if player is admin or has enough coins
    if isAdmin(player) or data.coins >= Constants.PRICES.ACTIONS.CLONE then
        -- Find object in workspace
        local object = workspace:FindFirstChild(objectPath)
        if not object then
            RemoteManager:fireClient(player, Constants.RemoteEvents.CloneObject, false, "Object not found")
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
            RemoteManager:fireClient(player, Constants.RemoteEvents.CloneObject, false, "You don't own this object")
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
        RemoteManager:fireClient(player, Constants.RemoteEvents.CloneObject, true)
    else
        RemoteManager:fireClient(player, Constants.RemoteEvents.CloneObject, false, "Not enough coins")
    end
end)

-- Remove object
RemoteManager:onServerEvent(Constants.RemoteEvents.RemoveObject, function(player, objectPath)
    local data = playerData[player.UserId]
    if not data then return end
    
    -- Check if player is admin or has enough coins
    if isAdmin(player) or data.coins >= Constants.PRICES.ACTIONS.REMOVE then
        -- Find object in workspace
        local object = workspace:FindFirstChild(objectPath)
        if not object then
            RemoteManager:fireClient(player, Constants.RemoteEvents.RemoveObject, false, "Object not found")
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
            RemoteManager:fireClient(player, Constants.RemoteEvents.RemoveObject, false, "You don't own this object")
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
        RemoteManager:fireClient(player, Constants.RemoteEvents.RemoveObject, true)
    else
        RemoteManager:fireClient(player, Constants.RemoteEvents.RemoveObject, false, "Not enough coins")
    end
end)

-- Rotate object
RemoteManager:onServerEvent(Constants.RemoteEvents.RotateObject, function(player, objectPath, rotation)
    local data = playerData[player.UserId]
    if not data then return end
    
    -- Find object in workspace
    local object = workspace:FindFirstChild(objectPath)
    if not object then
        RemoteManager:fireClient(player, Constants.RemoteEvents.RotateObject, false, "Object not found")
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
        RemoteManager:fireClient(player, Constants.RemoteEvents.RotateObject, false, "You don't own this object")
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
    RemoteManager:fireClient(player, Constants.RemoteEvents.RotateObject, true)
end)

-- Group objects
RemoteManager:onServerEvent(Constants.RemoteEvents.GroupObjects, function(player, objectPaths)
    local data = playerData[player.UserId]
    if not data then return end
    
    -- Check if player owns all objects
    local ownedObjects = {}
    for _, objectPath in ipairs(objectPaths) do
        local object = workspace:FindFirstChild(objectPath)
        if not object then
            RemoteManager:fireClient(player, Constants.RemoteEvents.GroupObjects, false, "Object not found: " .. objectPath)
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
            RemoteManager:fireClient(player, Constants.RemoteEvents.GroupObjects, false, "You don't own object: " .. objectPath)
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
    RemoteManager:fireClient(player, Constants.RemoteEvents.GroupObjects, true)
end)

-- Ungroup objects
RemoteManager:onServerEvent(Constants.RemoteEvents.UngroupObjects, function(player, groupPath)
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