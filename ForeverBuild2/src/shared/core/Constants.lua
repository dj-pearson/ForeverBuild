local Color3 = Color3

local Constants = {
    -- Currency
    CURRENCY = {
        STARTING_COINS = 100,
        MAX_COINS = 999999,
        REWARD_INTERVAL = 60, -- seconds
        REWARD_RATE = 1, -- coins per minute
        MIN_REWARD_AMOUNT = 1,
        MAX_REWARD_AMOUNT = 10,
        DAILY_BONUS = 50,
        WEEKLY_BONUS = 500,
        MONTHLY_BONUS = 2000,
        PRODUCTS = {
            {
                id = 1,
                coins = 100,
                robux = 10
            },
            {
                id = 2,
                coins = 500,
                robux = 40
            },
            {
                id = 3,
                coins = 1000,
                robux = 75
            },
            {
                id = 4,
                coins = 5000,
                robux = 350
            }
        }
    },
    
    -- UI
    UI_COLORS = {
        PRIMARY = Color3.fromRGB(0, 170, 255),
        SECONDARY = Color3.fromRGB(40, 40, 40),
        TEXT = Color3.fromRGB(255, 255, 255),
        ERROR = Color3.fromRGB(255, 50, 50)
    },
    
    -- Game Settings
    GAME = {
        MAX_INVENTORY_SLOTS = 50,
        PLACEMENT_COOLDOWN = 0.5,
        MAX_PLACEMENTS_PER_PLAYER = 1000,
        STARTING_CURRENCY = 1000,
        MAX_PLACED_ITEMS = 100
    },
    
    -- Item Actions
    ITEM_ACTIONS = {
        BUY = "buy",
        MOVE = "move",
        ROTATE = "rotate",
        COLOR = "color",
        DESTROY = "destroy",
        clone = {
            cost = 50,
            description = "Create a copy of this item"
        },
        move = {
            cost = 25,
            description = "Move this item to a new location"
        },
        rotate = {
            cost = 10,
            description = "Rotate this item"
        },
        destroy = {
            cost = 0,
            description = "Remove this item"
        }
    },

    ITEM_PRICING = {
        basic = 5,        -- 5 Robux
        secondary = 20,   -- 20 Robux
        rare = 100,       -- 100 Robux
        exclusive = 500,  -- 500 Robux
        clone = 10,       -- Fee for cloning
        move = 2,         -- Fee for moving
        destroy = 1,      -- Fee for destroying
        rotate = 1        -- Fee for rotating
    },

    -- Item definitions
    ITEMS = {
        basic_cube = {
            name = "Basic Cube",
            description = "A simple cube for building",
            price = 100,
            icon = "rbxassetid://0", -- Replace with actual icon
            category = "basic"
        },
        premium_cube = {
            name = "Premium Cube",
            description = "A fancy cube with special effects",
            price = 500,
            icon = "rbxassetid://0", -- Replace with actual icon
            category = "premium"
        },
        rare_cube = {
            name = "Rare Cube",
            description = "An extremely rare cube with unique properties",
            price = 1000,
            icon = "rbxassetid://0", -- Replace with actual icon
            category = "rare"
        }
    },
    
    -- UI Constants
    UI = {
        DIALOG_ANIMATION_DURATION = 0.3,
        BUTTON_HOVER_DURATION = 0.2,
        ERROR_DISPLAY_DURATION = 2
    }
}

return Constants