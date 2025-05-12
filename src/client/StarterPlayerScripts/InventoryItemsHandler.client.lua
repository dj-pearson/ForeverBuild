local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Get remote events
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local placeObjectEvent = Remotes:WaitForChild("PlaceObject")
local pickupItemEvent = Remotes:WaitForChild("PickupItem")
local actionResultEvent = Remotes:WaitForChild("ActionResult")

-- Wait for BuildingToolHandler to be available
local BuildingToolHandler = _G.BuildingToolHandler

-- Create the inventory items handler
local InventoryItemsHandler = {}

-- List of inventory items that can be placed in the world
local PLACEABLE_ITEM_TYPES = {
    "Weapon",
    "Armor",
    "Consumable"
}

-- Local variables
local isPlacingItem = false
local currentItemId = nil
local currentItemPreview = nil
local currentRotation = CFrame.Angles(0, 0, 0)

-- Function to check if an item type can be placed
function InventoryItemsHandler.isItemPlaceable(itemType)
    for _, placeable in ipairs(PLACEABLE_ITEM_TYPES) do
        if itemType == placeable then
            return true
        end
    end
    return false
end

-- Function to create a preview of the item
function InventoryItemsHandler.createItemPreview(itemId)
    -- Try to find the item model in ReplicatedStorage
    local itemModels = ReplicatedStorage:FindFirstChild("ItemModels")
    if not itemModels then
        warn("InventoryItemsHandler: ItemModels folder not found")
        return nil
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
        warn("InventoryItemsHandler: Item model not found:", itemId)
        return nil
    end
    
    -- Clone the model and modify it for preview
    local preview = itemModel:Clone()
    preview.Name = "ItemPreview"
    
    -- Make the model transparent
    for _, part in ipairs(preview:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Transparency = 0.5
            
            -- Create a selection box to highlight it
            local selectionBox = Instance.new("SelectionBox")
            selectionBox.Adornee = part
            selectionBox.LineThickness = 0.02
            selectionBox.Color3 = Color3.fromRGB(0, 162, 255)
            selectionBox.Parent = part
        end
    end
    
    preview.Parent = workspace
    return preview
end

-- Function to update the preview position
function InventoryItemsHandler.updatePreviewPosition()
    if not currentItemPreview or not currentItemPreview.PrimaryPart then
        return
    end
    
    -- Raycast from camera to get position
    local mouse = LocalPlayer:GetMouse()
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {currentItemPreview, LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local camera = workspace.CurrentCamera
    local mouseRay = camera:ScreenPointToRay(mouse.X, mouse.Y)
    local raycastResult = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 1000, raycastParams)
    
    if raycastResult then
        -- Adjust the position based on item type and size
        local position = raycastResult.Position
        local itemSize = currentItemPreview.PrimaryPart.Size
        
        -- Apply position and rotation
        currentItemPreview:SetPrimaryPartCFrame(CFrame.new(position) * currentRotation)
    end
end

-- Function to start placing an item
function InventoryItemsHandler.startPlacingItem(itemId)
    -- Stop any current placement
    if isPlacingItem then
        InventoryItemsHandler.stopPlacingItem()
    end
    
    -- Create the preview
    currentItemPreview = InventoryItemsHandler.createItemPreview(itemId)
    if not currentItemPreview then
        return false
    end
    
    currentItemId = itemId
    isPlacingItem = true
    
    -- Start updating the preview position
    RunService:BindToRenderStep("UpdateItemPreview", Enum.RenderPriority.Camera.Value + 1, function()
        InventoryItemsHandler.updatePreviewPosition()
    end)
    
    return true
end

-- Function to stop placing an item
function InventoryItemsHandler.stopPlacingItem()
    if currentItemPreview then
        currentItemPreview:Destroy()
        currentItemPreview = nil
    end
    
    RunService:UnbindFromRenderStep("UpdateItemPreview")
    
    currentItemId = nil
    isPlacingItem = false
    currentRotation = CFrame.Angles(0, 0, 0)
end

-- Function to place the current item
function InventoryItemsHandler.placeItem()
    if not isPlacingItem or not currentItemPreview or not currentItemPreview.PrimaryPart then
        return false
    end
    
    -- Get position and rotation
    local position = currentItemPreview.PrimaryPart.Position
    local rotation = Vector3.new(currentRotation:ToEulerAnglesXYZ())
    
    -- Send request to server
    placeObjectEvent:FireServer(currentItemId, position, rotation)
    
    -- Stop placing
    InventoryItemsHandler.stopPlacingItem()
    
    return true
end

-- Function to rotate the preview
function InventoryItemsHandler.rotatePreview(axis)
    if not isPlacingItem or not currentItemPreview then
        return
    end
    
    local rotationAmount = math.rad(90) -- 90 degrees
    
    if axis == "X" then
        currentRotation = currentRotation * CFrame.Angles(rotationAmount, 0, 0)
    elseif axis == "Y" then
        currentRotation = currentRotation * CFrame.Angles(0, rotationAmount, 0)
    elseif axis == "Z" then
        currentRotation = currentRotation * CFrame.Angles(0, 0, rotationAmount)
    end
    
    InventoryItemsHandler.updatePreviewPosition()
end

-- Function to pick up an item in front of the player
function InventoryItemsHandler.pickupItemInFront()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    -- Raycast from the character's position forward
    local raycastResult = workspace:Raycast(rootPart.Position, rootPart.CFrame.LookVector * 5, raycastParams)
    if not raycastResult then
        return false
    end
    
    -- Check if the hit object is a placeable item
    local hitPart = raycastResult.Instance
    local itemModel = hitPart:FindFirstAncestorOfClass("Model")
    if not itemModel or not itemModel:GetAttribute("ItemId") or not itemModel:GetAttribute("AllowPickup") then
        return false
    end
    
    -- Send pickup request to server
    local itemId = itemModel:GetAttribute("ItemId")
    pickupItemEvent:FireServer(itemId, 1)
    
    return true
end

-- Set up input handlers
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if isPlacingItem then
        -- Place item on left click
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            InventoryItemsHandler.placeItem()
        end
        
        -- Cancel on right click or escape
        if input.UserInputType == Enum.UserInputType.MouseButton2 or input.KeyCode == Enum.KeyCode.Escape then
            InventoryItemsHandler.stopPlacingItem()
        end
        
        -- Rotate on X, Y, Z keys
        if input.KeyCode == Enum.KeyCode.X then
            InventoryItemsHandler.rotatePreview("X")
        elseif input.KeyCode == Enum.KeyCode.Y then
            InventoryItemsHandler.rotatePreview("Y")
        elseif input.KeyCode == Enum.KeyCode.Z then
            InventoryItemsHandler.rotatePreview("Z")
        end
    end
    
    -- Pickup item on F key
    if input.KeyCode == Enum.KeyCode.F then
        InventoryItemsHandler.pickupItemInFront()
    end
end)

-- Handle action results from the server
actionResultEvent.OnClientEvent:Connect(function(action, success, message)
    if not success then
        -- Show an error message to the player
        -- This would typically use a notification UI
        print("Action failed:", action, message)
    end
end)

-- Make the handler accessible to other scripts
_G.InventoryItemsHandler = InventoryItemsHandler

return InventoryItemsHandler
