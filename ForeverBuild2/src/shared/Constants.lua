local Constants = {}

-- Admin Configuration
Constants.ADMIN_IDS = {
    7768610061 -- Main admin ID
}

-- Item Categories
Constants.ITEM_CATEGORIES = {
    FREEBIES = "Freebies",
    PAID = "Paid",
    ADMIN = "Admin"
}

-- Item Actions
Constants.ITEM_ACTIONS = {
    BUY = "buy",
    MOVE = "move",
    DESTROY = "destroy",
    ROTATE = "rotate",
    COLOR = "color"
}

-- Currency Configuration
Constants.CURRENCY = {
    INGAME = "Coins",
    ROBUX = "Robux",
    REWARD_RATE = 1.67, -- Coins per real minute
    REWARD_INTERVAL = 60, -- Reward interval in seconds
    MIN_REWARD_AMOUNT = 1, -- Minimum reward amount
    MAX_REWARD_AMOUNT = 100, -- Maximum reward amount
    DAILY_BONUS = 100, -- Daily login bonus
    WEEKLY_BONUS = 500, -- Weekly login bonus
    MONTHLY_BONUS = 2000 -- Monthly login bonus
}

-- Item Pricing Configuration
Constants.ITEM_PRICES = {
    BASIC = {
        INGAME = 5, -- 5 coins
        ROBUX = 5 -- 5 Robux
    },
    SECONDARY = {
        INGAME = 15, -- 15 coins
        ROBUX = 15 -- 15 Robux
    },
    RARE = {
        INGAME = 100, -- 100 coins
        ROBUX = 100 -- 100 Robux
    },
    EXCLUSIVE = {
        INGAME = 1000, -- 1000 coins
        ROBUX = 1000 -- 1000 Robux
    }
}

-- Pricing Configuration
Constants.BASE_PRICES = {
    BUY = 10, -- Base price for buying items
    MOVE = 5, -- Base price for moving items
    DESTROY = 3, -- Base price for destroying items
    ROTATE = 2, -- Base price for rotating items
    COLOR = 2 -- Base price for changing color
}

-- Homebase Configuration
Constants.HOMEBASE = {
    RADIUS = 50, -- Radius of homebase area
    CENTER = Vector3.new(0, 0, 0) -- Center point of homebase
}

-- Inventory Configuration
Constants.INVENTORY = {
    MAX_SLOTS = 50,
    MAX_STACK_SIZE = 99
}

-- Item Properties
Constants.ITEM_PROPERTIES = {
    MAX_ROTATION = 360, -- Maximum rotation in degrees
    MIN_ROTATION = 0,
    ROTATION_STEP = 45, -- Rotation step in degrees
    MAX_COLOR_CHANGES = 5 -- Maximum number of color changes allowed
}

return Constants 