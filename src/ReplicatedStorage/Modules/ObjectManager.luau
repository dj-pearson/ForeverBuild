local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ObjectManager = {}

-- Predefined object models
local OBJECT_MODELS = {
    -- Basic Blocks
    basic_block_1 = {
        id = "basic_block_1",
        name = "Basic Block",
        size = Vector3.new(4, 4, 4),
        material = Enum.Material.Plastic,
        color = Color3.fromRGB(200, 200, 200),
        price = 5,
        previewImage = "rbxassetid://1234567890", -- Replace with actual asset ID
    },
    basic_block_2 = {
        id = "basic_block_2",
        name = "Large Block",
        size = Vector3.new(8, 8, 8),
        material = Enum.Material.Plastic,
        color = Color3.fromRGB(180, 180, 180),
        price = 8,
        previewImage = "rbxassetid://1234567891",
    },
    
    -- Bricks
    brick_1 = {
        id = "brick_1",
        name = "Classic Brick",
        size = Vector3.new(4, 2, 8),
        material = Enum.Material.Brick,
        color = Color3.fromRGB(200, 100, 100),
        price = 6,
        previewImage = "rbxassetid://1234567892",
    },
    brick_2 = {
        id = "brick_2",
        name = "Stone Brick",
        size = Vector3.new(4, 2, 8),
        material = Enum.Material.Slate,
        color = Color3.fromRGB(150, 150, 150),
        price = 7,
        previewImage = "rbxassetid://1234567893",
    },
    
    -- Decorative Objects
    tree_1 = {
        id = "tree_1",
        name = "Pine Tree",
        size = Vector3.new(4, 12, 4),
        material = Enum.Material.Grass,
        color = Color3.fromRGB(50, 150, 50),
        price = 10,
        previewImage = "rbxassetid://1234567894",
    },
    tree_2 = {
        id = "tree_2",
        name = "Palm Tree",
        size = Vector3.new(6, 16, 6),
        material = Enum.Material.Grass,
        color = Color3.fromRGB(100, 200, 100),
        price = 12,
        previewImage = "rbxassetid://1234567895",
    },
    fountain_1 = {
        id = "fountain_1",
        name = "Decorative Fountain",
        size = Vector3.new(8, 6, 8),
        material = Enum.Material.Marble,
        color = Color3.fromRGB(220, 220, 220),
        price = 15,
        previewImage = "rbxassetid://1234567896",
    },
    lamp_1 = {
        id = "lamp_1",
        name = "Modern Lamp",
        size = Vector3.new(2, 6, 2),
        material = Enum.Material.Metal,
        color = Color3.fromRGB(50, 50, 50),
        price = 8,
        previewImage = "rbxassetid://1234567897",
    },
    bench_1 = {
        id = "bench_1",
        name = "Park Bench",
        size = Vector3.new(6, 2, 2),
        material = Enum.Material.Wood,
        color = Color3.fromRGB(139, 69, 19),
        price = 9,
        previewImage = "rbxassetid://1234567898",
    },
    statue_1 = {
        id = "statue_1",
        name = "Classic Statue",
        size = Vector3.new(4, 12, 4),
        material = Enum.Material.Marble,
        color = Color3.fromRGB(240, 240, 240),
        price = 20,
        previewImage = "rbxassetid://1234567899",
    },
    flower_1 = {
        id = "flower_1",
        name = "Flower Bed",
        size = Vector3.new(4, 1, 4),
        material = Enum.Material.Grass,
        color = Color3.fromRGB(255, 192, 203),
        price = 7,
        previewImage = "rbxassetid://1234567900",
    },    arch_1 = {
        id = "arch_1",
        name = "Stone Arch",
        size = Vector3.new(8, 8, 4),
        material = Enum.Material.Concrete,
        color = Color3.fromRGB(180, 180, 180),
        price = 18,
        previewImage = "rbxassetid://1234567901",
    },
}

-- Create object from type
function ObjectManager.createObject(objectType)
    local config = OBJECT_MODELS[objectType]
    if not config then return nil end
    
    local object = Instance.new("Model")
    object.Name = config.name
    
    -- Create primary part
    local part = Instance.new("Part")
    part.Name = "PrimaryPart"
    part.Size = config.size
    part.Material = config.material
    part.Color = config.color
    part.Anchored = true
    part.CanCollide = true
    part.Parent = object
    
    -- Set primary part
    object.PrimaryPart = part
    
    -- Add object type attribute
    object:SetAttribute("ObjectType", objectType)
    
    return object
end

-- Get object configuration
function ObjectManager.getObjectConfig(objectType)
    return OBJECT_MODELS[objectType]
end

-- Get random object type
function ObjectManager.getRandomObjectType()
    local types = {}
    for type, _ in pairs(OBJECT_MODELS) do
        table.insert(types, type)
    end
    return types[math.random(1, #types)]
end

-- Get marketplace items
function ObjectManager.getMarketplaceItems()
    local items = {}
    for type, config in pairs(OBJECT_MODELS) do
        table.insert(items, {
            id = type,
            name = config.name,
            price = config.price,
            previewImage = config.previewImage,
        })
    end
    return items
end

return ObjectManager 