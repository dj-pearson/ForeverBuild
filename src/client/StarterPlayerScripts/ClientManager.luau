local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Load shared modules
local Shared = require(ReplicatedStorage.Shared)
local Constants = Shared.Constants
local Types = Shared.Types
local RemoteManager = Shared.RemoteManager

local InventoryUI = require(ReplicatedStorage.Modules.InventoryUI)
local MarketplaceUI = require(ReplicatedStorage.Modules.MarketplaceUI)
local DailyRewardsUI = require(ReplicatedStorage.Modules.DailyRewardsUI)
local ObjectInteractionManager = require(ReplicatedStorage.Modules.ObjectInteractionManager)
local LeaderboardUI = require(ReplicatedStorage.Modules.LeaderboardUI)
local AchievementUI = require(ReplicatedStorage.Modules.AchievementUI)
local TutorialManager = require(ReplicatedStorage.Modules.TutorialManager)

local ClientManager = {}

-- Get remote events
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local purchaseEvent = remotes:WaitForChild("PurchaseObject")
local placeObjectEvent = remotes:WaitForChild("PlaceObject")
local getMarketplaceItemsEvent = ReplicatedStorage.Remotes.GetMarketplaceItems
local getAvailableToolsEvent = ReplicatedStorage.Remotes.GetAvailableTools
local groupObjectsEvent = ReplicatedStorage.Remotes.GroupObjects
local ungroupObjectsEvent = ReplicatedStorage.Remotes.UngroupObjects

-- Local state
local localPlayer = Players.LocalPlayer
local currentInventory = {}
local selectedItem = nil
local isPlacing = false

-- UI Elements
local screenGui
local mainFrame
local inventoryButton
local marketplaceButton
local dailyRewardsButton
local coinsLabel

-- Create interaction buttons
local interactionButtons = {}

-- Create UI
function ClientManager.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MainUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 200, 0, 300)
    mainFrame.Position = UDim2.new(0, 10, 0.5, -150)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Create coins label
    coinsLabel = Instance.new("TextLabel")
    coinsLabel.Name = "CoinsLabel"
    coinsLabel.Size = UDim2.new(1, 0, 0, 40)
    coinsLabel.Position = UDim2.new(0, 0, 0, 0)
    coinsLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    coinsLabel.BorderSizePixel = 0
    coinsLabel.Text = "Coins: 0"
    coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    coinsLabel.TextSize = 24
    coinsLabel.Font = Enum.Font.GothamBold
    coinsLabel.Parent = mainFrame
    
    -- Create inventory button
    inventoryButton = Instance.new("TextButton")
    inventoryButton.Name = "InventoryButton"
    inventoryButton.Size = UDim2.new(1, -20, 0, 50)
    inventoryButton.Position = UDim2.new(0, 10, 0, 50)
    inventoryButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    inventoryButton.BorderSizePixel = 0
    inventoryButton.Text = "Inventory"
    inventoryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    inventoryButton.TextSize = 24
    inventoryButton.Font = Enum.Font.GothamBold
    inventoryButton.Parent = mainFrame
    
    -- Create marketplace button
    marketplaceButton = Instance.new("TextButton")
    marketplaceButton.Name = "MarketplaceButton"
    marketplaceButton.Size = UDim2.new(1, -20, 0, 50)
    marketplaceButton.Position = UDim2.new(0, 10, 0, 110)
    marketplaceButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    marketplaceButton.BorderSizePixel = 0
    marketplaceButton.Text = "Marketplace"
    marketplaceButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    marketplaceButton.TextSize = 24
    marketplaceButton.Font = Enum.Font.GothamBold
    marketplaceButton.Parent = mainFrame
    
    -- Create daily rewards button
    dailyRewardsButton = Instance.new("TextButton")
    dailyRewardsButton.Name = "DailyRewardsButton"
    dailyRewardsButton.Size = UDim2.new(1, -20, 0, 50)
    dailyRewardsButton.Position = UDim2.new(0, 10, 0, 170)
    dailyRewardsButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    dailyRewardsButton.BorderSizePixel = 0
    dailyRewardsButton.Text = "Daily Rewards"
    dailyRewardsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    dailyRewardsButton.TextSize = 24
    dailyRewardsButton.Font = Enum.Font.GothamBold
    dailyRewardsButton.Parent = mainFrame
    
    -- Create leaderboard button
    local leaderboardButton = Instance.new("TextButton")
    leaderboardButton.Name = "LeaderboardButton"
    leaderboardButton.Size = UDim2.new(1, -20, 0, 50)
    leaderboardButton.Position = UDim2.new(0, 10, 0, 230)
    leaderboardButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    leaderboardButton.BorderSizePixel = 0
    leaderboardButton.Text = "Leaderboard"
    leaderboardButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    leaderboardButton.TextSize = 24
    leaderboardButton.Font = Enum.Font.GothamBold
    leaderboardButton.Parent = mainFrame
    
    -- Create achievements button
    local achievementsButton = Instance.new("TextButton")
    achievementsButton.Name = "AchievementsButton"
    achievementsButton.Size = UDim2.new(1, -20, 0, 50)
    achievementsButton.Position = UDim2.new(0, 10, 0, 290)
    achievementsButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    achievementsButton.BorderSizePixel = 0
    achievementsButton.Text = "Achievements"
    achievementsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    achievementsButton.TextSize = 24
    achievementsButton.Font = Enum.Font.GothamBold
    achievementsButton.Parent = mainFrame
    
    -- Set up button events
    inventoryButton.MouseButton1Click:Connect(function()
        InventoryUI.show()
    end)
    
    marketplaceButton.MouseButton1Click:Connect(function()
        MarketplaceUI.show()
    end)
    
    dailyRewardsButton.MouseButton1Click:Connect(function()
        DailyRewardsUI.show()
    end)
    
    leaderboardButton.MouseButton1Click:Connect(function()
        LeaderboardUI.show()
    end)
    
    achievementsButton.MouseButton1Click:Connect(function()
        AchievementUI.show()
    end)
end

-- Create interaction buttons
function ClientManager.createInteractionButtons()
    -- Create interaction buttons container
    local container = Instance.new("Frame")
    container.Name = "InteractionButtons"
    container.Size = UDim2.new(0, 200, 0, 200) -- Increased height for new buttons
    container.Position = UDim2.new(0, 10, 0.5, -100)
    container.BackgroundTransparency = 1
    container.Visible = false
    container.Parent = mainFrame
    
    -- Create move button
    local moveButton = Instance.new("TextButton")
    moveButton.Name = "MoveButton"
    moveButton.Size = UDim2.new(1, 0, 0, 40)
    moveButton.Position = UDim2.new(0, 0, 0, 0)
    moveButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    moveButton.BorderSizePixel = 0
    moveButton.Text = "Move (" .. Constants.PRICES.ACTIONS.MOVE .. " coins)"
    moveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    moveButton.TextSize = 20
    moveButton.Font = Enum.Font.Gotham
    moveButton.Parent = container
    
    -- Create clone button
    local cloneButton = Instance.new("TextButton")
    cloneButton.Name = "CloneButton"
    cloneButton.Size = UDim2.new(1, 0, 0, 40)
    cloneButton.Position = UDim2.new(0, 0, 0, 50)
    cloneButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    cloneButton.BorderSizePixel = 0
    cloneButton.Text = "Clone (" .. Constants.PRICES.ACTIONS.CLONE .. " coins)"
    cloneButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cloneButton.TextSize = 20
    cloneButton.Font = Enum.Font.Gotham
    cloneButton.Parent = container
    
    -- Create remove button
    local removeButton = Instance.new("TextButton")
    removeButton.Name = "RemoveButton"
    removeButton.Size = UDim2.new(1, 0, 0, 40)
    removeButton.Position = UDim2.new(0, 0, 0, 100)
    removeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    removeButton.BorderSizePixel = 0
    removeButton.Text = "Remove (" .. Constants.PRICES.ACTIONS.REMOVE .. " coins)"
    removeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    removeButton.TextSize = 20
    removeButton.Font = Enum.Font.Gotham
    removeButton.Parent = container
    
    -- Create group button
    local groupButton = Instance.new("TextButton")
    groupButton.Name = "GroupButton"
    groupButton.Size = UDim2.new(1, 0, 0, 40)
    groupButton.Position = UDim2.new(0, 0, 0, 150)
    groupButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    groupButton.BorderSizePixel = 0
    groupButton.Text = "Group Selected"
    groupButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    groupButton.TextSize = 20
    groupButton.Font = Enum.Font.Gotham
    groupButton.Parent = container
    
    -- Set up button events
    moveButton.MouseButton1Click:Connect(function()
        ObjectInteractionManager.startInteraction("move")
    end)
    
    cloneButton.MouseButton1Click:Connect(function()
        ObjectInteractionManager.startInteraction("clone")
    end)
    
    removeButton.MouseButton1Click:Connect(function()
        ObjectInteractionManager.startInteraction("remove")
    end)
    
    groupButton.MouseButton1Click:Connect(function()
        -- Get selected objects
        local selectedObjects = {}
        for _, object in ipairs(workspace:GetChildren()) do
            if object:FindFirstChild("Highlight") then
                table.insert(selectedObjects, object:GetFullName())
            end
        end
        
        if #selectedObjects > 1 then
            -- Group objects
            groupObjectsEvent:FireServer(selectedObjects)
        end
    end)
    
    interactionButtons = {
        container = container,
        moveButton = moveButton,
        cloneButton = cloneButton,
        removeButton = removeButton,
        groupButton = groupButton,
    }
end

-- Handle object purchase
function ClientManager.purchaseObject(objectType)
    purchaseEvent:FireServer(objectType)
end

-- Handle purchase response
purchaseEvent.OnClientEvent:Connect(function(success, result)
    if success then
        table.insert(currentInventory, result)
        -- Update UI
        InventoryUI.updateInventory(currentInventory)
    else
        -- Show error message
        print("Purchase failed:", result)
    end
end)

-- Handle object placement
function ClientManager.placeObject(itemId, position, rotation)
    placeObjectEvent:FireServer(itemId, position, rotation)
end

-- Handle placement response
placeObjectEvent.OnClientEvent:Connect(function(success, result)
    if success then
        -- Remove from inventory
        for i, item in ipairs(currentInventory) do
            if item.id == result.id then
                table.remove(currentInventory, i)
                break
            end
        end
        -- Update UI
        InventoryUI.updateInventory(currentInventory)
    else
        -- Show error message
        print("Placement failed:", result)
    end
end)

-- Handle input for object placement
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 and selectedItem then
        -- Get mouse position in world space
        local mouse = Players.LocalPlayer:GetMouse()
        local ray = workspace.CurrentCamera:ScreenPointToRay(mouse.X, mouse.Y)
        local hit, position = workspace:FindPartOnRay(ray)
        
        if hit then
            -- Place object at hit position
            ClientManager.placeObject(selectedItem.id, position, Vector3.new(0, 0, 0))
        end
    end
end)

-- Update coins display
function ClientManager.updateCoins(amount)
    coinsLabel.Text = "Coins: " .. amount
end

-- Handle object selection
function ClientManager.selectObject(object)
    if object then
        -- Show interaction buttons
        interactionButtons.container.Visible = true
        
        -- Update group button text based on selection
        if object:GetAttribute("ObjectType") == "group" then
            interactionButtons.groupButton.Text = "Ungroup"
            interactionButtons.groupButton.MouseButton1Click:Connect(function()
                ungroupObjectsEvent:FireServer(object:GetFullName())
            end)
        else
            interactionButtons.groupButton.Text = "Group Selected"
            interactionButtons.groupButton.MouseButton1Click:Connect(function()
                -- Get selected objects
                local selectedObjects = {}
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj:FindFirstChild("Highlight") then
                        table.insert(selectedObjects, obj:GetFullName())
                    end
                end
                
                if #selectedObjects > 1 then
                    -- Group objects
                    groupObjectsEvent:FireServer(selectedObjects)
                end
            end)
        end
    else
        -- Hide interaction buttons
        interactionButtons.container.Visible = false
    end
    
    -- Update ObjectInteractionManager
    ObjectInteractionManager.selectObject(object)
end

-- Handle input for object selection
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        -- Get mouse position in world space
        local mouse = Players.LocalPlayer:GetMouse()
        local ray = workspace.CurrentCamera:ScreenPointToRay(mouse.X, mouse.Y)
        local hit, position = workspace:FindPartOnRay(ray)
        
        if hit then
            -- Check if hit object is a placed object
            local object = hit:FindFirstAncestorWhichIsA("Model")
            if object and object:GetAttribute("ObjectType") then
                ClientManager.selectObject(object)
            else
                ClientManager.selectObject(nil)
            end
        else
            ClientManager.selectObject(nil)
        end
    end
end)

-- Initialize
function ClientManager.init()
    ClientManager.create()
    ClientManager.createInteractionButtons()
    
    -- Initialize UI modules
    InventoryUI.init()
    MarketplaceUI.init()
    DailyRewardsUI.init()
    ObjectInteractionManager.init()
    LeaderboardUI.init()
    AchievementUI.init()
    TutorialManager.init()
    
    -- Get initial marketplace items
    local marketplaceItems = getMarketplaceItemsEvent:InvokeServer()
    if marketplaceItems then
        MarketplaceUI.setItems(marketplaceItems)
    end
    
    -- Get initial available tools
    local availableTools = getAvailableToolsEvent:InvokeServer()
    if availableTools then
        MarketplaceUI.setTools(availableTools)
    end

    -- Set up remote event handlers
    RemoteManager:onClientEvent(Constants.RemoteEvents.PlayerUpdate, function(data)
        ClientManager.handlePlayerUpdate(data)
    end)
    
    RemoteManager:onClientEvent(Constants.RemoteEvents.DataSync, function(data)
        ClientManager.handleDataSync(data)
    end)
end

-- Handle player updates
function ClientManager.handlePlayerUpdate(data)
    -- Implementation
end

-- Handle data sync
function ClientManager.handleDataSync(data)
    -- Implementation
end

-- Start the client
ClientManager.init()

return ClientManager 