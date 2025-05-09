local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local InventoryUI = {}

-- UI Elements
local screenGui
local inventoryFrame
local itemSlots = {}

-- Create UI
function InventoryUI.createUI()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "InventoryUI"
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create main frame
    inventoryFrame = Instance.new("Frame")
    inventoryFrame.Name = "InventoryFrame"
    inventoryFrame.Size = UDim2.new(0, 400, 0, 500)
    inventoryFrame.Position = UDim2.new(1, -420, 0.5, -250)
    inventoryFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    inventoryFrame.BorderSizePixel = 0
    inventoryFrame.Parent = screenGui
    
    -- Create title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    title.Text = "Inventory"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = inventoryFrame
    
    -- Create grid layout
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = Constants.UI.INVENTORY_SLOT_SIZE
    gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
    gridLayout.Parent = inventoryFrame
    
    -- Create item slots
    for i = 1, Constants.MAX_INVENTORY_SLOTS do
        local slot = Instance.new("Frame")
        slot.Name = "Slot" .. i
        slot.Size = Constants.UI.INVENTORY_SLOT_SIZE
        slot.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        slot.BorderSizePixel = 0
        slot.Parent = inventoryFrame
        
        -- Add hover effect
        local hoverEffect = Instance.new("Frame")
        hoverEffect.Name = "HoverEffect"
        hoverEffect.Size = UDim2.new(1, 0, 1, 0)
        hoverEffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        hoverEffect.BackgroundTransparency = 0.9
        hoverEffect.Visible = false
        hoverEffect.Parent = slot
        
        -- Add click detection
        local button = Instance.new("TextButton")
        button.Name = "Button"
        button.Size = UDim2.new(1, 0, 1, 0)
        button.BackgroundTransparency = 1
        button.Text = ""
        button.Parent = slot
        
        -- Store reference
        itemSlots[i] = {
            frame = slot,
            button = button,
            item = nil
        }
        
        -- Add hover effects
        button.MouseEnter:Connect(function()
            hoverEffect.Visible = true
        end)
        
        button.MouseLeave:Connect(function()
            hoverEffect.Visible = false
        end)
    end
end

-- Update inventory display
function InventoryUI.updateInventory(items)
    -- Clear all slots
    for _, slot in ipairs(itemSlots) do
        slot.item = nil
        -- Clear slot contents
        for _, child in ipairs(slot.frame:GetChildren()) do
            if child.Name ~= "HoverEffect" and child.Name ~= "Button" then
                child:Destroy()
            end
        end
    end
    
    -- Fill slots with items
    for i, item in ipairs(items) do
        if i <= Constants.MAX_INVENTORY_SLOTS then
            local slot = itemSlots[i]
            slot.item = item
            
            -- Create item preview
            local preview = Instance.new("ImageLabel")
            preview.Name = "Preview"
            preview.Size = UDim2.new(0.8, 0, 0.8, 0)
            preview.Position = UDim2.new(0.1, 0, 0.1, 0)
            preview.BackgroundTransparency = 1
            preview.Image = "rbxassetid://" -- Add default image ID
            preview.Parent = slot.frame
            
            -- Add price label
            local priceLabel = Instance.new("TextLabel")
            priceLabel.Name = "Price"
            priceLabel.Size = UDim2.new(1, 0, 0, 20)
            priceLabel.Position = UDim2.new(0, 0, 1, -20)
            priceLabel.BackgroundTransparency = 1
            priceLabel.Text = tostring(item.price) .. " R$"
            priceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            priceLabel.TextSize = 14
            priceLabel.Font = Enum.Font.Gotham
            priceLabel.Parent = slot.frame
        end
    end
end

-- Initialize
function InventoryUI.init()
    InventoryUI.createUI()
    print("Inventory UI initialized")
end

return InventoryUI 