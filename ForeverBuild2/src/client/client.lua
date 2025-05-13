local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Core modules
local SharedModule = require(ReplicatedStorage.shared)
local GameManager = SharedModule.GameManager
local Constants = SharedModule.Constants

-- UI Modules
local PurchaseDialog = SharedModule.UI.PurchaseDialog
local InventoryUI = SharedModule.UI.InventoryUI
local PlacedItemDialog = SharedModule.UI.PlacedItemDialog

-- Remote events/functions
local Remotes = GameManager.Remotes
local PurchaseItem = Remotes:WaitForChild("PurchaseItem")
local RequestInventory = Remotes:WaitForChild("RequestInventory")
local PlaceItem = Remotes:WaitForChild("PlaceItem")
local PlacedItemAction = Remotes:WaitForChild("PlacedItemAction")

-- State
local currentInventory = {}
local currentCurrency = 0
local isPlacingItem = false
local selectedItem = nil
local placementPreview = nil
local lastError = nil

-- Helper to safely call RemoteFunctions
local function safeInvoke(remote, ...)
    local ok, result = pcall(function(...)
        return remote:InvokeServer(...)
    end, ...)
    if not ok then
        lastError = "A network error occurred. Please try again."
        warn("RemoteFunction error:", result)
        return { success = false, message = lastError }
    end
    if not result or not result.success then
        lastError = (result and result.message) or "Unknown error."
        return { success = false, message = lastError }
    end
    lastError = nil
    return result
end

-- Create inventory button
local function createInventoryButton(parent)
    local button = Instance.new("TextButton")
    button.Name = "InventoryButton"
    button.Size = UDim2.new(0, 120, 0, 40)
    button.Position = UDim2.new(1, -140, 0, 20)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.Font = Enum.Font.GothamBold
    button.Text = "Inventory"
    button.TextSize = 18
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Parent = parent
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    -- Add hover effect
    button.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        }):Play()
    end)
    
    -- Set up click handler
    button.MouseButton1Click:Connect(function()
        if lastError then
            inventoryUI:ShowError(lastError)
            return
        end
        local result = safeInvoke(RequestInventory)
        if result.success then
            currentInventory = result.inventory
            currentCurrency = result.currency
            inventoryUI:UpdateInventory(currentInventory, currentCurrency)
            inventoryUI:Show()
        else
            inventoryUI:ShowError(result.message)
        end
    end)
    
    return button
end

-- Initialize UI
local function initializeUI()
    -- Create main UI container
    local uiContainer = Instance.new("ScreenGui")
    uiContainer.Name = "ItemSystemUI"
    uiContainer.ResetOnSpawn = false
    uiContainer.Parent = player.PlayerGui
    
    -- Create inventory button
    createInventoryButton(uiContainer)
    
    -- Initialize UI modules
    local purchaseDialog = PurchaseDialog.new()
    purchaseDialog:Initialize(uiContainer)

    local inventoryUI = InventoryUI.new()
    inventoryUI:Initialize(uiContainer)

    local placedItemDialog = PlacedItemDialog.new()
    placedItemDialog:Initialize(uiContainer)
    
    -- Set up item selection
    inventoryUI.OnItemSelected = function(itemName)
        if lastError then
            inventoryUI:ShowError(lastError)
            return
        end
        if not currentInventory[itemName] or currentInventory[itemName] <= 0 then
            inventoryUI:ShowError("You do not own this item.")
            return
        end
        -- Start placement mode
        isPlacingItem = true
        selectedItem = itemName
        inventoryUI:Hide()
        -- Create placement preview
        if placementPreview then
            placementPreview:Destroy()
        end
        -- TODO: Create actual preview model based on item
        placementPreview = Instance.new("Part")
        placementPreview.Name = "PlacementPreview"
        placementPreview.Anchored = true
        placementPreview.CanCollide = false
        placementPreview.Transparency = 0.5
        placementPreview.Size = Vector3.new(4, 4, 4)
        placementPreview.BrickColor = BrickColor.new("Bright blue")
        placementPreview.Parent = workspace
    end
    
    -- Set up placed item interaction
    placedItemDialog.OnActionSelected = function(itemId, action)
        PlacedItemAction:FireServer(itemId, action)
    end
end

-- Handle proximity prompts
local function setupProximityPrompts()
    -- Find all items with proximity prompts
    local function onItemFound(item)
        if item:GetAttribute("item") then
            local prompt = item:FindFirstChild("ProximityPrompt")
            if not prompt then
                prompt = Instance.new("ProximityPrompt")
                prompt.Name = "ItemPrompt"
                prompt.ActionText = "Purchase"
                prompt.ObjectText = item:GetAttribute("item")
                prompt.HoldDuration = 0
                prompt.MaxActivationDistance = 10
                prompt.Parent = item
            end
            
            prompt.Triggered:Connect(function()
                if lastError then
                    purchaseDialog:ShowError(lastError)
                    return
                end
                local itemName = item:GetAttribute("item")
                if itemName then
                    purchaseDialog:Show(itemName, function(quantity)
                        local result = safeInvoke(PurchaseItem, itemName, quantity)
                        if result.success then
                            currentInventory = result.newInventory
                            currentCurrency = result.newCurrency
                            inventoryUI:UpdateInventory(currentInventory, currentCurrency)
                        else
                            purchaseDialog:ShowError(result.message)
                        end
                    end)
                end
            end)
        end
    end
    
    -- Set up existing items
    for _, item in ipairs(workspace:GetDescendants()) do
        onItemFound(item)
    end
    
    -- Watch for new items
    workspace.DescendantAdded:Connect(onItemFound)
end

-- Handle item placement
local function setupPlacement()
    local mouse = player:GetMouse()
    
    -- Handle mouse movement
    RunService.RenderStepped:Connect(function()
        if not isPlacingItem or not selectedItem or not placementPreview then return end
        
        -- Update preview position
        local hit, position, normal = workspace:FindPartOnRay(
            Ray.new(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 100),
            placementPreview
        )
        
        if hit then
            placementPreview.CFrame = CFrame.new(position) * CFrame.new(0, placementPreview.Size.Y/2, 0)
        end
    end)
    
    -- Handle mouse clicks
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if isPlacingItem and selectedItem and placementPreview then
                -- Place item
                local position = placementPreview.Position
                local rotation = placementPreview.Orientation
                PlaceItem:FireServer(selectedItem, position, rotation)
                
                -- Reset placement mode
                isPlacingItem = false
                selectedItem = nil
                placementPreview:Destroy()
                placementPreview = nil
            end
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            if isPlacingItem then
                -- Cancel placement
                isPlacingItem = false
                selectedItem = nil
                if placementPreview then
                    placementPreview:Destroy()
                    placementPreview = nil
                end
            end
        end
    end)
end

-- Initialize
print("Client script starting...")
initializeUI()
setupProximityPrompts()
setupPlacement()

-- Handle character respawning
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    -- Reset placement mode if active
    if isPlacingItem and placementPreview then
        isPlacingItem = false
        selectedItem = nil
        placementPreview:Destroy()
        placementPreview = nil
    end
end)

-- Initial inventory load
local result = safeInvoke(RequestInventory)
if result.success then
    currentInventory = result.inventory
    currentCurrency = result.currency
    inventoryUI:UpdateInventory(currentInventory, currentCurrency)
else
    inventoryUI:ShowError(result.message)
end 