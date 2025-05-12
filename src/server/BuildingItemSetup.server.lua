local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local ITEM_CATEGORIES = {
    "Foundations",
    "Walls",
    "Floors",
    "Roofs",
    "Doors",
    "Windows",
    "Furniture",
    "Decorations"
}

local ITEM_DEFAULTS = {
    -- Foundations
    foundation_wood = {
        name = "Wood Foundation",
        category = "Foundations",
        size = Vector3.new(4, 0.5, 4),
        color = Color3.fromRGB(139, 69, 19),
        buildable = true,
        allowPickup = false,
    },
    foundation_stone = {
        name = "Stone Foundation",
        category = "Foundations",
        size = Vector3.new(4, 0.5, 4),
        color = Color3.fromRGB(150, 150, 150),
        buildable = true,
        allowPickup = false,
    },
    
    -- Walls
    wall_wood = {
        name = "Wood Wall",
        category = "Walls",
        size = Vector3.new(0.3, 4, 4),
        color = Color3.fromRGB(160, 82, 45),
        buildable = true,
        allowPickup = false,
    },
    wall_stone = {
        name = "Stone Wall",
        category = "Walls",
        size = Vector3.new(0.3, 4, 4),
        color = Color3.fromRGB(130, 130, 130),
        buildable = true,
        allowPickup = false,
    },
    
    -- Floors
    floor_wood = {
        name = "Wood Floor",
        category = "Floors",
        size = Vector3.new(4, 0.3, 4),
        color = Color3.fromRGB(205, 133, 63),
        buildable = true,
        allowPickup = false,
    },
    floor_stone = {
        name = "Stone Floor",
        category = "Floors",
        size = Vector3.new(4, 0.3, 4),
        color = Color3.fromRGB(169, 169, 169),
        buildable = true,
        allowPickup = false,
    },
    
    -- Items from inventory system that can be placed
    sword_1 = {
        name = "Basic Sword",
        category = "Items",
        size = Vector3.new(0.5, 0.1, 2),
        color = Color3.fromRGB(192, 192, 192),
        buildable = false,
        allowPickup = true,
    },
    armor_1 = {
        name = "Leather Armor",
        category = "Items",
        size = Vector3.new(1, 1.5, 0.5),
        color = Color3.fromRGB(101, 67, 33),
        buildable = false,
        allowPickup = true,
    },
    health_potion = {
        name = "Health Potion",
        category = "Items",
        size = Vector3.new(0.3, 0.5, 0.3),
        color = Color3.fromRGB(255, 0, 0),
        buildable = false,
        allowPickup = true,
    }
}

-- Create a model for a specific item
local function createItemModel(itemId)
    local itemData = ITEM_DEFAULTS[itemId]
    if not itemData then
        warn("BuildingItemSetup: No data for item:", itemId)
        return nil
    end
    
    local model = Instance.new("Model")
    model.Name = itemId
    
    local part = Instance.new("Part")
    part.Name = "MainPart"
    part.Size = itemData.size
    part.Color = itemData.color
    part.Material = Enum.Material.SmoothPlastic
    part.Anchored = true
    part.CanCollide = true
    part.Parent = model
    
    model.PrimaryPart = part
    
    -- Add attributes to the model
    model:SetAttribute("ItemId", itemId)
    model:SetAttribute("ItemName", itemData.name)
    model:SetAttribute("Category", itemData.category)
    model:SetAttribute("Buildable", itemData.buildable)
    model:SetAttribute("AllowPickup", itemData.allowPickup)
    
    -- Add a billboard GUI with the item's name
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "NameLabel"
    billboardGui.Size = UDim2.new(0, 100, 0, 25)
    billboardGui.StudsOffset = Vector3.new(0, itemData.size.Y/2 + 0.5, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = part
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Label"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 0.5
    textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Text = itemData.name
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboardGui
    
    -- Add interaction functionality based on item type
    if itemData.allowPickup then
        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "PickupPrompt"
        prompt.ObjectText = itemData.name
        prompt.ActionText = "Pick Up"
        prompt.KeyboardKeyCode = Enum.KeyCode.E
        prompt.HoldDuration = 0
        prompt.RequiresLineOfSight = false
        prompt.Parent = part
    end
    
    return model
end

-- Create an ItemModels folder in ReplicatedStorage
local function setupItemModels()
    local itemModelsFolder = ReplicatedStorage:FindFirstChild("ItemModels")
    if not itemModelsFolder then
        itemModelsFolder = Instance.new("Folder")
        itemModelsFolder.Name = "ItemModels"
        itemModelsFolder.Parent = ReplicatedStorage
    end
    
    -- Create category folders
    for _, category in ipairs(ITEM_CATEGORIES) do
        local categoryFolder = itemModelsFolder:FindFirstChild(category)
        if not categoryFolder then
            categoryFolder = Instance.new("Folder")
            categoryFolder.Name = category
            categoryFolder.Parent = itemModelsFolder
        end
    end
    
    -- Create item models
    for itemId, itemData in pairs(ITEM_DEFAULTS) do
        local categoryFolder = itemModelsFolder:FindFirstChild(itemData.category)
        if not categoryFolder and itemData.category ~= "Items" then
            categoryFolder = itemModelsFolder
        elseif itemData.category == "Items" then
            -- Create an Items category if it doesn't exist
            local itemsFolder = itemModelsFolder:FindFirstChild("Items")
            if not itemsFolder then
                itemsFolder = Instance.new("Folder")
                itemsFolder.Name = "Items"
                itemsFolder.Parent = itemModelsFolder
            end
            categoryFolder = itemsFolder
        end
        
        -- Check if the model already exists
        if not categoryFolder:FindFirstChild(itemId) then
            local model = createItemModel(itemId)
            if model then
                model.Parent = categoryFolder
            end
        end
    end
    
    print("BuildingItemSetup: Item models have been set up")
end

-- Set up the building items container in the workspace
local function setupBuildingItemsContainer()
    local buildingItemsFolder = Workspace:FindFirstChild("BuildingItems")
    if not buildingItemsFolder then
        buildingItemsFolder = Instance.new("Folder")
        buildingItemsFolder.Name = "BuildingItems"
        buildingItemsFolder.Parent = Workspace
    end
    
    print("BuildingItemSetup: Building items container has been set up")
end

-- Initialize everything
local function initialize()
    setupItemModels()
    setupBuildingItemsContainer()
end

initialize()
