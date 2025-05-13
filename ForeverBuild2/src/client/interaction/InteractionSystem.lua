local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Add debug print to confirm module is loading
print("InteractionSystem module loading...")

local Constants = require(ReplicatedStorage.shared.core.Constants)
-- Fix path references to use ReplicatedStorage.shared.core.ui
local PurchaseDialog = require(ReplicatedStorage.shared.core.ui.PurchaseDialog)
local InventoryUI = require(ReplicatedStorage.shared.core.ui.InventoryUI)
local PlacedItemDialog = require(ReplicatedStorage.shared.core.ui.PlacedItemDialog)

local InteractionSystem = {}
InteractionSystem.__index = InteractionSystem

function InteractionSystem.new()
    local self = setmetatable({}, InteractionSystem)
    self.player = Players.LocalPlayer
    self.mouse = self.player:GetMouse()
    self.currentTarget = nil
    self.interactionDistance = 10 -- Maximum distance for interaction
    self.ui = nil
    self.remoteEvents = ReplicatedStorage.Remotes
    return self
end

function InteractionSystem:Initialize()
    print("InteractionSystem initialized")
    
    -- Create UI
    self:CreateUI()
    
    -- Set up input handling
    self:SetupInputHandling()
    
    -- Set up mouse movement
    self:SetupMouseHandling()
    
    -- Set up event handlers
    self:SetupEventHandlers()
    
    -- Set up inventory key
    self:SetupInventoryKey()
end

function InteractionSystem:CreateUI()
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "InteractionUI"
    screenGui.Parent = self.player:WaitForChild("PlayerGui")
    
    -- Create tooltip
    local tooltip = Instance.new("Frame")
    tooltip.Name = "Tooltip"
    tooltip.Size = UDim2.new(0, 200, 0, 100)
    tooltip.BackgroundColor3 = Constants.UI_COLORS.SECONDARY
    tooltip.BorderSizePixel = 0
    tooltip.Visible = false
    tooltip.Parent = screenGui
    
    -- Create title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.TextColor3 = Constants.UI_COLORS.TEXT
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Text = "Interact"
    title.Parent = tooltip
    
    -- Create interaction list
    local list = Instance.new("Frame")
    list.Name = "InteractionList"
    list.Size = UDim2.new(1, 0, 1, -30)
    list.Position = UDim2.new(0, 0, 0, 30)
    list.BackgroundTransparency = 1
    list.Parent = tooltip
    
    self.ui = screenGui
end

function InteractionSystem:SetupInputHandling()
    -- Handle interaction input (E key)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.E then
            self:AttemptInteraction()
        end
    end)
end

function InteractionSystem:SetupMouseHandling()
    -- Update current target on mouse movement
    game:GetService("RunService").RenderStepped:Connect(function()
        self:UpdateCurrentTarget()
    end)
end

function InteractionSystem:UpdateCurrentTarget()
    local target = self.mouse.Target
    if not target then
        self:ClearCurrentTarget()
        return
    end
    
    -- Check if target is a placed item
    local placedItem = self:GetPlacedItemFromPart(target)
    if not placedItem then
        self:ClearCurrentTarget()
        return
    end
    
    -- Check distance
    local distance = (target.Position - self.player.Character.HumanoidRootPart.Position).Magnitude
    if distance > self.interactionDistance then
        self:ClearCurrentTarget()
        return
    end
    
    -- Update current target
    self.currentTarget = placedItem
    
    -- Show interaction UI
    self:ShowInteractionUI(placedItem)
end

function InteractionSystem:ClearCurrentTarget()
    if self.currentTarget then
        self:HideInteractionUI()
        self.currentTarget = nil
    end
end

function InteractionSystem:GetPlacedItemFromPart(part)
    local current = part
    while current and current ~= workspace do
        if current:IsA("Model") and current:GetAttribute("item") then
            return {
                id = current.Name,
                model = current
            }
        end
        current = current.Parent
    end
    return nil
end

function InteractionSystem:ShowInteractionUI(placedItem)
    local tooltip = self.ui.Tooltip
    local list = tooltip.InteractionList
    tooltip.Visible = true -- Ensure tooltip is visible
    -- Clear existing interactions
    for _, child in ipairs(list:GetChildren()) do
        child:Destroy()
    end

    -- Get the item model from Workspace > Items
    local itemsFolder = workspace:FindFirstChild("Items")
    local itemModel = nil
    if itemsFolder then
        for _, model in ipairs(itemsFolder:GetDescendants()) do
            if model:IsA("Model") and model:GetAttribute("item") and model.Name == placedItem.id then
                itemModel = model
                break
            end
        end
    end

    -- Get tier and price
    local tier = itemModel and itemModel:GetAttribute("item") or "basic"
    local price = Constants.ITEM_PRICING[tier] or 0

    -- If this is a main item (not a placed item), show the purchase dialog
    if not placedItem.model:GetAttribute("PlacedByPlayer") then
        PurchaseDialog.Show(placedItem.id, function(quantity)
            local result = ReplicatedStorage.Remotes.BuyItem:InvokeServer(placedItem.id, quantity)
            if not result or not result.success then
                if result and result.message then
                    PurchaseDialog.ShowError(result.message)
                else
                    PurchaseDialog.ShowError("Purchase failed.")
                end
            end
        end)
        return
    end

    -- Otherwise, show the placed item dialog
    PlacedItemDialog.Show(placedItem.id, placedItem.model:GetAttribute("item"), function(action)
        if action == "clone" then
            ReplicatedStorage.Remotes.CloneItem:FireServer(placedItem)
        elseif action == "move" then
            ReplicatedStorage.Remotes.MoveItem:FireServer(placedItem)
        elseif action == "destroy" then
            ReplicatedStorage.Remotes.RemoveItem:FireServer(placedItem)
        elseif action == "rotate" then
            ReplicatedStorage.Remotes.RotateItem:FireServer(placedItem)
        end
    end)
end

function InteractionSystem:HideInteractionUI()
    self.ui.Tooltip.Visible = false
end

function InteractionSystem:AttemptInteraction()
    if not self.currentTarget then return end
    
    -- Get available interactions
    local interactions = self:GetAvailableInteractions(self.currentTarget)
    if not interactions or #interactions == 0 then return end
    
    -- If only one interaction is available, use it
    if #interactions == 1 then
        self:PerformInteraction(self.currentTarget, interactions[1])
        return
    end
    
    -- Show interaction menu
    self:ShowInteractionMenu(interactions)
end

function InteractionSystem:GetAvailableInteractions(placedItem)
    -- Request available interactions from server
    return ReplicatedStorage.Remotes.GetAvailableInteractions:InvokeServer(placedItem)
end

function InteractionSystem:PerformInteraction(placedItem, interactionType)
    -- Send interaction request to server
    ReplicatedStorage.Remotes.InteractWithItem:FireServer(placedItem, interactionType)
end

function InteractionSystem:ShowInteractionMenu(interactions)
    -- Use the same UI as ShowInteractionUI
    self:ShowInteractionUI(self.currentTarget)
end

function InteractionSystem:SetupEventHandlers()
    -- Handle interaction responses
    self.remoteEvents.NotifyPlayer.OnClientEvent:Connect(function(message)
        self:ShowNotification(message)
    end)
end

function InteractionSystem:ShowNotification(message)
    -- Create notification UI
    local notification = Instance.new("ScreenGui")
    notification.Name = "Notification"
    notification.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Name = "NotificationFrame"
    frame.Size = UDim2.new(0, 300, 0, 50)
    frame.Position = UDim2.new(0.5, -150, 0.1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = notification
    
    local label = Instance.new("TextLabel")
    label.Name = "MessageLabel"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 18
    label.Font = Enum.Font.GothamBold
    label.Text = message
    label.Parent = frame
    
    -- Animate and destroy
    game:GetService("Debris"):AddItem(notification, 3)
end

function InteractionSystem:SetupInventoryKey()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.I then
            self:OpenInventory()
        end
    end)
end

function InteractionSystem:OpenInventory()
    -- Fetch inventory from server
    local inventory = ReplicatedStorage.Remotes.GetInventory:InvokeServer()
    if not inventory or not inventory.success or not inventory.inventory or next(inventory.inventory) == nil then
        InventoryUI.ShowError("Your inventory is empty.")
        return
    end
    InventoryUI.Show()
    -- Add logic to update inventory display if needed
end

return InteractionSystem 