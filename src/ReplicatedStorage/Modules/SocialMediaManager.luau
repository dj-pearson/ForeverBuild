local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local SocialMediaManager = {}

-- Local state
local shareTokens = {} -- Stores temporary share tokens for verification

-- Initialize social media system
function SocialMediaManager.init()
    -- Create remote events
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    
    local generateShareLinkEvent = Instance.new("RemoteFunction")
    generateShareLinkEvent.Name = "GenerateShareLink"
    generateShareLinkEvent.Parent = remotes
    
    local verifyShareEvent = Instance.new("RemoteFunction")
    verifyShareEvent.Name = "VerifyShare"
    verifyShareEvent.Parent = remotes
    
    -- Set up event handlers
    generateShareLinkEvent.OnServerInvoke = function(player, shareData)
        return SocialMediaManager.generateShareLink(player, shareData)
    end
    
    verifyShareEvent.OnServerInvoke = function(player, token)
        return SocialMediaManager.verifyShare(player, token)
    end
    
    -- Set up player connection/disconnection handlers
    Players.PlayerAdded:Connect(function(player)
        SocialMediaManager.handlePlayerJoin(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        SocialMediaManager.handlePlayerLeave(player)
    end)
end

-- Handle player joining
function SocialMediaManager.handlePlayerJoin(player)
    -- Initialize player's share tokens
    shareTokens[player.UserId] = {}
end

-- Handle player leaving
function SocialMediaManager.handlePlayerLeave(player)
    -- Clean up player's share tokens
    shareTokens[player.UserId] = nil
end

-- Generate share link
function SocialMediaManager.generateShareLink(player, shareData)
    local userId = player.UserId
    
    -- Validate share data
    if not shareData or type(shareData) ~= "table" then
        return false, "Invalid share data"
    end
    
    -- Generate unique token
    local token = HttpService:GenerateGUID(false)
    
    -- Store share data with token
    shareTokens[userId][token] = {
        type = shareData.type,
        data = shareData.data,
        timestamp = os.time(),
        expires = os.time() + 86400 -- 24 hours
    }
    
    -- Generate share URL
    local shareUrl = string.format(
        "https://www.roblox.com/games/%d?shareToken=%s",
        game.PlaceId,
        token
    )
    
    return true, shareUrl
end

-- Verify share
function SocialMediaManager.verifyShare(player, token)
    local userId = player.UserId
    
    -- Check if token exists and is valid
    local shareData = shareTokens[userId][token]
    if not shareData then
        return false, "Invalid share token"
    end
    
    -- Check if token has expired
    if os.time() > shareData.expires then
        shareTokens[userId][token] = nil
        return false, "Share token expired"
    end
    
    -- Process share based on type
    local success = false
    local message = ""
    
    if shareData.type == "showcase" then
        success, message = SocialMediaManager.processShowcaseShare(player, shareData.data)
    elseif shareData.type == "achievement" then
        success, message = SocialMediaManager.processAchievementShare(player, shareData.data)
    elseif shareData.type == "creation" then
        success, message = SocialMediaManager.processCreationShare(player, shareData.data)
    else
        return false, "Invalid share type"
    end
    
    -- Clean up token if successful
    if success then
        shareTokens[userId][token] = nil
    end
    
    return success, message
end

-- Process showcase share
function SocialMediaManager.processShowcaseShare(player, data)
    -- TODO: Implement showcase share processing
    -- This could include:
    -- - Recording the share in player stats
    -- - Awarding experience points
    -- - Triggering notifications
    return true, "Showcase shared successfully"
end

-- Process achievement share
function SocialMediaManager.processAchievementShare(player, data)
    -- TODO: Implement achievement share processing
    -- This could include:
    -- - Recording the share in player stats
    -- - Awarding experience points
    -- - Triggering notifications
    return true, "Achievement shared successfully"
end

-- Process creation share
function SocialMediaManager.processCreationShare(player, data)
    -- TODO: Implement creation share processing
    -- This could include:
    -- - Recording the share in player stats
    -- - Awarding experience points
    -- - Triggering notifications
    return true, "Creation shared successfully"
end

-- Clean up expired tokens
function SocialMediaManager.cleanupTokens()
    local currentTime = os.time()
    
    for userId, tokens in pairs(shareTokens) do
        for token, data in pairs(tokens) do
            if currentTime > data.expires then
                tokens[token] = nil
            end
        end
    end
end

return SocialMediaManager 