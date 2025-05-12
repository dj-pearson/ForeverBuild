local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemSpawner = {}
ItemSpawner.__index = ItemSpawner

-- Get the InventorySystem module using require if available, or wait for it
local InventorySystem
local success, result = pcall(function()
    return require(ReplicatedStorage.shared.Modules.InventorySystem)
end)

if success then
    InventorySystem = result
else
    warn("ItemSpawner: Failed to load InventorySystem module:", result)
    -- Will attempt to load it later in Initialize
end

-- Initialize a new item spawner
function ItemSpawner.new()
    local self = setmetatable({}, ItemSpawner)
    self.itemModels = {}
    self:Initialize()
    return self
end

-- Initialize the item spawner
function ItemSpawner:Initialize()
    -- Try to get InventorySystem again if it failed earlier
    if not InventorySystem then
        local success, result = pcall(function()
            return require(ReplicatedStorage.shared.Modules.InventorySystem)
        end)
        
        if success then
            InventorySystem = result
        else
            warn("ItemSpawner (Initialize): Failed to load InventorySystem module:", result)
            -- Continue without it, but functionality will be limited
        end
    end
    
    -- Create references to item models folder
    self.itemModelsFolder = ReplicatedStorage:FindFirstChild("ItemModels")
    if not self.itemModelsFolder then
        self.itemModelsFolder = Instance.new("Folder")
        self.itemModelsFolder.Name = "ItemModels"
        self.itemModelsFolder.Parent = ReplicatedStorage
    end
    
    -- Cache item templates if InventorySystem is available
    if InventorySystem then
        self.itemTemplates = InventorySystem.ITEM_TEMPLATES or {}
    else
        self.itemTemplates = {}
    end
end

-- Spawn a physical item in the world
function ItemSpawner:SpawnItem(itemId, position, canPickup)
    if not self.itemTemplates[itemId] then
        warn("ItemSpawner: Invalid item ID:", itemId)
        return nil
    end
    
    -- Get the item template
    local itemTemplate = self.itemTemplates[itemId]
    
    -- Check if we have a model for this item
    local itemModel = self.itemModelsFolder:FindFirstChild(itemId)
    if not itemModel then
        -- Create a simple model if one doesn't exist
        itemModel = self:CreateBasicItemModel(itemTemplate)
        itemModel.Parent = self.itemModelsFolder
    end
    
    -- Clone the model for placement
    local newItem = itemModel:Clone()
    newItem.Name = itemTemplate.name
    
    -- Position the item
    newItem:SetPrimaryPartCFrame(CFrame.new(position))
    
    -- Set attributes based on the item template
    for key, value in pairs(itemTemplate) do
        if key ~= "stats" then -- Handle stats separately
            newItem:SetAttribute(key, value)
        end
    end
    
    -- Set stats as attributes
    if itemTemplate.stats then
        for statName, statValue in pairs(itemTemplate.stats) do
            newItem:SetAttribute(statName, statValue)
        end
    end
    
    -- Add pickup functionality if enabled
    if canPickup then
        self:MakeItemPickable(newItem, itemTemplate)
    end
    
    newItem.Parent = workspace
    return newItem
end

-- Create a basic model for an item
function ItemSpawner:CreateBasicItemModel(itemTemplate)
    local model = Instance.new("Model")
    model.Name = itemTemplate.id
    
    local mainPart = Instance.new("Part")
    mainPart.Name = "MainPart"
    mainPart.Size = Vector3.new(1, 1, 1)
    mainPart.Anchored = true
    mainPart.CanCollide = true
    
    -- Color the part based on rarity
    if itemTemplate.rarity == "Common" then
        mainPart.BrickColor = BrickColor.new("Bright blue")
    elseif itemTemplate.rarity == "Uncommon" then
        mainPart.BrickColor = BrickColor.new("Lime green")
    elseif itemTemplate.rarity == "Rare" then
        mainPart.BrickColor = BrickColor.new("Royal purple")
    elseif itemTemplate.rarity == "Epic" then
        mainPart.BrickColor = BrickColor.new("Bright violet")
    elseif itemTemplate.rarity == "Legendary" then
        mainPart.BrickColor = BrickColor.new("Bright orange")
    else
        mainPart.BrickColor = BrickColor.new("Medium stone grey")
    end
    
    mainPart.Parent = model
    model.PrimaryPart = mainPart
    
    -- Create a billboard GUI for the item name
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "NameLabel"
    billboardGui.Size = UDim2.new(0, 100, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.Adornee = mainPart
    billboardGui.Parent = mainPart
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Label"
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Text = itemTemplate.name
    nameLabel.TextScaled = true
    nameLabel.Parent = billboardGui
    
    return model
end

-- Make an item pickable by players
function ItemSpawner:MakeItemPickable(itemModel, itemTemplate)
    local mainPart = itemModel.PrimaryPart
    
    -- Add ProximityPrompt
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "PickupPrompt"
    prompt.ObjectText = itemTemplate.name
    prompt.ActionText = "Pick Up"
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.HoldDuration = 0
    prompt.RequiresLineOfSight = false
    prompt.Parent = mainPart
    
    -- Connect the prompt's triggered event
    prompt.Triggered:Connect(function(player)
        -- This will fire a remote event that your server script needs to handle
        local itemId = itemModel:GetAttribute("id")
        
        -- Fire remote event to add item to player's inventory
        local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if Remotes then
            local pickupEvent = Remotes:FindFirstChild("PickupItem")
            if pickupEvent then
                pickupEvent:FireServer(itemId, 1) -- itemId and quantity
                
                -- You might want to destroy the item now or wait for server confirmation
                -- For now, we'll just destroy it immediately
                itemModel:Destroy()
            else
                warn("ItemSpawner: PickupItem remote event not found")
            end
        else
            warn("ItemSpawner: Remotes folder not found")
        end
    end)
end

-- Spawn a random item at a position
function ItemSpawner:SpawnRandomItem(position, canPickup, itemType)
    local validItems = {}
    
    -- Filter items by type if specified
    for itemId, template in pairs(self.itemTemplates) do
        if not itemType or template.type == itemType then
            table.insert(validItems, itemId)
        end
    end
    
    if #validItems == 0 then
        warn("ItemSpawner: No valid items found for random spawn")
        return nil
    end
    
    -- Select a random item
    local randomItemId = validItems[math.random(1, #validItems)]
    return self:SpawnItem(randomItemId, position, canPickup)
end

return ItemSpawner
