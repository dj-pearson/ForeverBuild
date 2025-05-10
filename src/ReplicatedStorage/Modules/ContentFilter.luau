local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local ContentFilter = {}

-- Filtered words list (this would typically be stored in a secure location)
local FILTERED_WORDS = {
    "badword1",
    "badword2",
    -- Add more filtered words
}

-- Filter text content
function ContentFilter.filterText(text)
    if not text then return "" end
    
    -- Use Roblox's built-in text filtering
    local success, filteredText = pcall(function()
        return TextService:FilterStringAsync(text, 0, "en"):GetChatForUserAsync(0)
    end)
    
    if success then
        return filteredText
    else
        warn("Text filtering failed:", filteredText)
        return text
    end
end

-- Check if text contains filtered words
function ContentFilter.containsFilteredWords(text)
    if not text then return false end
    
    text = string.lower(text)
    for _, word in ipairs(FILTERED_WORDS) do
        if string.find(text, word) then
            return true
        end
    end
    
    return false
end

-- Validate object placement
function ContentFilter.validateObjectPlacement(object)
    -- Check object name
    if ContentFilter.containsFilteredWords(object.Name) then
        return false, "Object name contains inappropriate content"
    end
    
    -- Check object description if it exists
    local description = object:GetAttribute("Description")
    if description and ContentFilter.containsFilteredWords(description) then
        return false, "Object description contains inappropriate content"
    end
    
    -- Check for inappropriate textures
    for _, part in ipairs(object:GetDescendants()) do
        if part:IsA("BasePart") then
            -- Check texture IDs
            if part.TextureID ~= "" then
                -- Here you would implement texture validation
                -- This might involve checking against a list of approved textures
                -- or using a moderation service
            end
            
            -- Check decal IDs
            for _, decal in ipairs(part:GetChildren()) do
                if decal:IsA("Decal") and decal.Texture ~= "" then
                    -- Similar texture validation for decals
                end
            end
        end
    end
    
    return true, nil
end

return ContentFilter 