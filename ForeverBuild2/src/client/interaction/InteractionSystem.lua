local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Constants = require(ReplicatedStorage.shared.core.Constants)

local InteractionSystem = {}
InteractionSystem.__index = InteractionSystem

function InteractionSystem.new()
    local self = setmetatable({}, InteractionSystem)
    self.player = Players.LocalPlayer
    self.mouse = self.player:GetMouse()
    self.currentTarget = nil
    self.interactionDistance = 10 -- Maximum distance for interaction
    self.ui = nil
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
    -- Check if part has a PlacedItem attribute
    if part:GetAttribute("PlacedItemId") then
        return {
            id = part:GetAttribute("PlacedItemId"),
            model = part.Parent
        }
    end
    
    -- Check parent for PlacedItem attribute
    if part.Parent and part.Parent:GetAttribute("PlacedItemId") then
        return {
            id = part.Parent:GetAttribute("PlacedItemId"),
            model = part.Parent
        }
    end
    
    return nil
end

function InteractionSystem:ShowInteractionUI(placedItem)
    local tooltip = self.ui.Tooltip
    local list = tooltip.InteractionList
    
    -- Clear existing interactions
    for _, child in ipairs(list:GetChildren()) do
        child:Destroy()
    end
    
    -- Get available interactions
    local interactions = self:GetAvailableInteractions(placedItem)
    
    -- Create interaction buttons
    local yOffset = 0
    for _, interactionType in ipairs(interactions) do
        local button = Instance.new("TextButton")
        button.Name = interactionType
        button.Size = UDim2.new(1, -20, 0, 30)
        button.Position = UDim2.new(0, 10, 0, yOffset)
        button.BackgroundColor3 = Constants.UI_COLORS.PRIMARY
        button.TextColor3 = Constants.UI_COLORS.TEXT
        button.TextSize = 16
        button.Font = Enum.Font.GothamBold
        button.Text = interactionType:gsub("^%l", string.upper)
        button.Parent = list
        
        button.MouseButton1Click:Connect(function()
            self:PerformInteraction(placedItem, interactionType)
        end)
        
        yOffset = yOffset + 35
    end
    
    -- Update tooltip size
    tooltip.Size = UDim2.new(0, 200, 0, 30 + (yOffset))
    
    -- Position tooltip near mouse
    local mousePos = self.mouse.X, self.mouse.Y
    tooltip.Position = UDim2.new(0, mousePos + Vector2.new(20, 20))
    
    -- Show tooltip
    tooltip.Visible = true
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
    return ReplicatedStorage.RemoteEvents.GetAvailableInteractions:InvokeServer(placedItem)
end

function InteractionSystem:PerformInteraction(placedItem, interactionType)
    -- Send interaction request to server
    ReplicatedStorage.RemoteEvents.InteractWithItem:FireServer(placedItem, interactionType)
end

function InteractionSystem:ShowInteractionMenu(interactions)
    -- Use the same UI as ShowInteractionUI
    self:ShowInteractionUI(self.currentTarget)
end

return InteractionSystem 