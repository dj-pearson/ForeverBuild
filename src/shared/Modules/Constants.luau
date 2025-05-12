local Constants = {}

-- UI Constants
Constants.UI = {
    Colors = {
        Primary = Color3.fromRGB(66, 133, 244),
        Secondary = Color3.fromRGB(76, 175, 80),
        Error = Color3.fromRGB(244, 67, 54),
        Warning = Color3.fromRGB(255, 152, 0),
        Success = Color3.fromRGB(76, 175, 80),
        Background = Color3.fromRGB(45, 45, 45),
        BackgroundLight = Color3.fromRGB(60, 60, 60),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(200, 200, 200)
    },
    
    Fonts = {
        Title = Enum.Font.SourceSansBold,
        Body = Enum.Font.SourceSans,
        Button = Enum.Font.SourceSansSemibold
    },
    
    TextSizes = {
        Title = 24,
        Subtitle = 20,
        Body = 16,
        Button = 14,
        Small = 12
    },
    
    Spacing = {
        Small = 5,
        Medium = 10,
        Large = 20
    },
    
    Padding = {
        Small = 5,
        Medium = 10,
        Large = 20
    },
    
    BorderRadius = {
        Small = 4,
        Medium = 8,
        Large = 12
    }
}

-- Game Constants
Constants.Game = {
    MaxPlayers = 50,
    MinPlayers = 2,
    RoundDuration = 300, -- 5 minutes
    RespawnTime = 5,
    MaxTeamSize = 5,
    StartingCurrency = 1000,
    MaxCurrency = 1000000,
    CurrencyEarningRate = 10, -- per minute
    MaxInventorySize = 100,
    MaxFriends = 200,
    MaxGuildSize = 50,
    MaxChatLength = 200,
    MaxUsernameLength = 20,
    MinUsernameLength = 3,
    MaxPasswordLength = 32,
    MinPasswordLength = 8
}

-- Achievement Constants
Constants.Achievements = {
    MaxProgress = 100,
    MaxLevel = 100,
    ExperienceMultiplier = 1.5,
    BaseExperience = 100,
    MaxDailyAchievements = 5,
    AchievementCooldown = 86400 -- 24 hours in seconds
}

-- Building Constants
Constants.Building = {
    MaxHeight = 100,
    MaxWidth = 100,
    MaxDepth = 100,
    MinHeight = 1,
    MinWidth = 1,
    MinDepth = 1,
    MaxParts = 1000,
    MaxTools = 50,
    MaxTemplates = 100,
    MaxChallenges = 50
}

-- Social Constants
Constants.Social = {
    MaxFriends = 200,
    MaxGuildSize = 50,
    MaxChatLength = 200,
    MaxMessageLength = 500,
    MaxGroupSize = 10,
    MaxPartySize = 4,
    MaxClanSize = 100,
    MaxClanOfficers = 10,
    MaxClanNameLength = 30,
    MaxClanDescriptionLength = 500
}

-- Security Constants
Constants.Security = {
    MaxLoginAttempts = 5,
    LoginCooldown = 300, -- 5 minutes
    MaxReportLength = 500,
    MaxReportReasonLength = 200,
    MaxBanDuration = 31536000, -- 1 year in seconds
    MaxWarnCount = 3,
    MaxMuteDuration = 86400, -- 24 hours in seconds
    MaxKickCount = 5
}

-- Performance Constants
Constants.Performance = {
    MaxCacheSize = 1000,
    MaxCacheTime = 3600, -- 1 hour in seconds
    MaxMemoryUsage = 1024, -- 1 GB in MB
    MaxCPUUsage = 80, -- percentage
    MaxNetworkUsage = 1024, -- 1 MB per second
    MaxDiskUsage = 1024, -- 1 GB in MB
    MaxThreadCount = 4,
    MaxRequestRate = 100 -- requests per second
}

-- Game Settings
Constants.GameSettings = {
    MaxPlayers = 50,
    DefaultSpawnLocation = Vector3.new(0, 5, 0),
    MaxBuildingHeight = 100,
    MaxBuildingWidth = 50,
    MaxBuildingDepth = 50
}

-- Module Paths
Constants.ModulePaths = {
    Shared = "ReplicatedStorage.Shared",
    Server = "ServerScriptService.server",
    Client = "StarterPlayer.StarterPlayerScripts.client"
}

-- Remote Event Names
Constants.RemoteEvents = {
    -- Admin Events
    ReportObject = "ReportObject",
    AdminCommand = "AdminCommand",
    AdminReport = "AdminReport",
    
    -- Game Events
    DataSync = "DataSync",
    PlayerUpdate = "PlayerUpdate",
    PurchaseObject = "PurchaseObject",
    PlaceObject = "PlaceObject",
    PurchaseTool = "PurchaseTool",
    ClaimDailyReward = "ClaimDailyReward",
    SpawnObject = "SpawnObject",
    RemoveObject = "RemoveObject",
    UpdateInventory = "UpdateInventory",
    UpdateCurrency = "UpdateCurrency",
    
    -- Social Events
    FriendRequest = "FriendRequest",
    FriendResponse = "FriendResponse",
    ChatMessage = "ChatMessage",
    PartyInvite = "PartyInvite",
    PartyResponse = "PartyResponse",
    GuildInvite = "GuildInvite",
    GuildResponse = "GuildResponse",
    
    -- Building Events
    PlaceBuilding = "PlaceBuilding",
    RemoveBuilding = "RemoveBuilding",
    UpdateBuilding = "UpdateBuilding",
    SaveBuilding = "SaveBuilding",
    LoadBuilding = "LoadBuilding",
    
    -- Achievement Events
    AchievementProgress = "AchievementProgress",
    AchievementUnlocked = "AchievementUnlocked",
    RewardClaimed = "RewardClaimed"
}

-- Remote Function Names
Constants.RemoteFunctions = {
    -- Game Functions
    GetMarketplaceItems = "GetMarketplaceItems",
    GetAvailableTools = "GetAvailableTools",
    GetPlayerData = "GetPlayerData",
    GetInventory = "GetInventory",
    GetCurrency = "GetCurrency",
    
    -- Social Functions
    GetFriends = "GetFriends",
    GetParty = "GetParty",
    GetGuild = "GetGuild",
    GetChatHistory = "GetChatHistory",
    
    -- Building Functions
    GetBuildings = "GetBuildings",
    GetBuildingData = "GetBuildingData",
    ValidateBuilding = "ValidateBuilding",
    
    -- Achievement Functions
    GetAchievements = "GetAchievements",
    GetProgress = "GetProgress",
    GetRewards = "GetRewards"
}

-- Module Status
Constants.ModuleStatus = {
    NOT_LOADED = "NOT_LOADED",
    LOADING = "LOADING",
    LOADED = "LOADED",
    ERROR = "ERROR"
}

-- Error Messages
Constants.ErrorMessages = {
    ModuleNotFound = "Module not found: %s",
    InvalidModulePath = "Invalid module path: %s",
    ModuleLoadError = "Failed to load module: %s - %s",
    RemoteNotFound = "Remote event not found: %s"
}

return Constants 