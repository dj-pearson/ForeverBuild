local Constants = {
    -- Game Settings
    MAX_PLAYERS = 50,
    GAME_VERSION = "1.0.0",
    
    -- Admin Settings
    ADMIN_RANKS = {
        "Owner",
        "Admin",
        "Moderator"
    },
    
    -- Command Settings
    COMMAND_PREFIX = "/",
    COMMAND_COOLDOWN = 1, -- seconds
    
    -- Report Settings
    MAX_REPORTS_PER_PLAYER = 5,
    REPORT_COOLDOWN = 300, -- seconds
    
    -- UI Settings
    UI_FADE_TIME = 0.3,
    UI_RESPONSE_DURATION = 3
}

-- Game Settings
Constants.GAME_NAME = "Roblox Infinite Canvas"
Constants.MAX_INVENTORY_SLOTS = 50
Constants.GRID_SIZE = 4 -- Size of the grid for object placement
Constants.STARTING_COINS = 1000
Constants.FREE_OBJECT_SPAWN_INTERVAL = 300 -- 5 minutes
Constants.MAX_PLACED_OBJECTS = 1000
Constants.OBJECT_SPAWN_RADIUS = 100
Constants.OBJECT_SPAWN_HEIGHT = 10

-- Random Drop Settings
Constants.RANDOM_DROP = {
    SPAWN_INTERVAL = 600, -- 10 minutes
    MAX_ACTIVE_DROPS = 5,
    PICKUP_RADIUS = 10,
    GLOW = {
        COLOR = Color3.fromRGB(255, 215, 0), -- Gold color
        TRANSPARENCY = 0.5,
        SIZE = Vector3.new(2, 2, 2),
        PULSE_SPEED = 1,
        PULSE_MIN = 0.3,
        PULSE_MAX = 0.7
    }
}

-- Object Types
Constants.OBJECT_TYPES = {
    BASIC_BLOCK = "BasicBlock",
    BRICK = "Brick",
    DECORATIVE = "Decorative",
    MYSTERY = "Mystery"
}

-- Pricing
Constants.PRICES = {
    PURCHASE = {
        MIN = 5,
        MAX = 10
    },
    ACTIONS = {
        MOVE = 3,
        CLONE = 4,
        REMOVE = 5
    }
}

-- Tool prices
Constants.TOOL_PRICES = {
    SPRING_JUMP = 500,
    MAGIC_CARPET = 1000,
    CAR = 2000,
}

-- Object prices
Constants.OBJECT_PRICES = {
    BASIC_BLOCK = 100,
    CLASSIC_BRICK = 150,
    MODERN_LAMP = 200,
    LARGE_BLOCK = 250,
    STONE_BRICK = 300,
    PINE_TREE = 400,
    DECORATIVE_FOUNTAIN = 500,
}

-- Object spawn chances
Constants.OBJECT_SPAWN_CHANCES = {
    BASIC_BLOCK = 0.3,
    CLASSIC_BRICK = 0.2,
    MODERN_LAMP = 0.15,
    LARGE_BLOCK = 0.1,
    STONE_BRICK = 0.1,
    PINE_TREE = 0.1,
    DECORATIVE_FOUNTAIN = 0.05,
}

-- Spawn area boundaries
Constants.SPAWN_BOUNDS = {
    MIN_X = -1000,
    MAX_X = 1000,
    MIN_Z = -1000,
    MAX_Z = 1000,
    Y = 10,
}

-- UI Settings
Constants.UI = {
    INVENTORY_SLOT_SIZE = UDim2.new(0, 80, 0, 80),
    MARKETPLACE_GRID_SIZE = UDim2.new(0, 100, 0, 100)
}

-- DataStore Keys
Constants.DATASTORE_KEYS = {
    PLAYER_INVENTORY = "PlayerInventory_",
    PLACED_OBJECTS = "PlacedObjects"
}

-- Tutorial
Constants.TUTORIAL_REWARD = 100 -- Coins given for completing the tutorial

return Constants 