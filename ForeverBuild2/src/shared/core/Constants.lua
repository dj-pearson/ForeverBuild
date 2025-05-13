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
        MAX_PLACEMENTS_PER_PLAYER = 1000
    },
    
    -- Item Actions
    ITEM_ACTIONS = {
        BUY = "buy",
        MOVE = "move",
        ROTATE = "rotate",
        COLOR = "color",
        DESTROY = "destroy"
    }
}

return Constants