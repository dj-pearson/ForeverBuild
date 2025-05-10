local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local BuildingTemplateManager = {}

-- Local state
local templates = {} -- Player templates
local featuredTemplates = {} -- Featured community templates
local templateLikes = {} -- Template likes
local templateComments = {} -- Template comments

-- Initialize building templates system
function BuildingTemplateManager.init()
    -- Create remote events
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    
    local saveTemplateEvent = Instance.new("RemoteEvent")
    saveTemplateEvent.Name = "SaveTemplate"
    saveTemplateEvent.Parent = remotes
    
    local loadTemplateEvent = Instance.new("RemoteEvent")
    loadTemplateEvent.Name = "LoadTemplate"
    loadTemplateEvent.Parent = remotes
    
    local shareTemplateEvent = Instance.new("RemoteEvent")
    shareTemplateEvent.Name = "ShareTemplate"
    shareTemplateEvent.Parent = remotes
    
    local likeTemplateEvent = Instance.new("RemoteEvent")
    likeTemplateEvent.Name = "LikeTemplate"
    likeTemplateEvent.Parent = remotes
    
    local commentTemplateEvent = Instance.new("RemoteEvent")
    commentTemplateEvent.Name = "CommentTemplate"
    commentTemplateEvent.Parent = remotes
    
    local getTemplatesEvent = Instance.new("RemoteEvent")
    getTemplatesEvent.Name = "GetTemplates"
    getTemplatesEvent.Parent = remotes
    
    local getFeaturedTemplatesEvent = Instance.new("RemoteEvent")
    getFeaturedTemplatesEvent.Name = "GetFeaturedTemplates"
    getFeaturedTemplatesEvent.Parent = remotes
    
    -- Set up event handlers
    saveTemplateEvent.OnServerEvent:Connect(function(player, name, description, objects)
        BuildingTemplateManager.saveTemplate(player, name, description, objects)
    end)
    
    loadTemplateEvent.OnServerEvent:Connect(function(player, templateId)
        BuildingTemplateManager.loadTemplate(player, templateId)
    end)
    
    shareTemplateEvent.OnServerEvent:Connect(function(player, templateId)
        BuildingTemplateManager.shareTemplate(player, templateId)
    end)
    
    likeTemplateEvent.OnServerEvent:Connect(function(player, templateId)
        BuildingTemplateManager.likeTemplate(player, templateId)
    end)
    
    commentTemplateEvent.OnServerEvent:Connect(function(player, templateId, comment)
        BuildingTemplateManager.commentTemplate(player, templateId, comment)
    end)
    
    getTemplatesEvent.OnServerEvent:Connect(function(player)
        BuildingTemplateManager.getTemplates(player)
    end)
    
    getFeaturedTemplatesEvent.OnServerEvent:Connect(function(player)
        BuildingTemplateManager.getFeaturedTemplates(player)
    end)
    
    -- Set up player connection/disconnection handlers
    Players.PlayerAdded:Connect(function(player)
        BuildingTemplateManager.handlePlayerJoin(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        BuildingTemplateManager.handlePlayerLeave(player)
    end)
end

-- Handle player joining
function BuildingTemplateManager.handlePlayerJoin(player)
    -- Initialize player's templates
    templates[player.UserId] = {}
    templateLikes[player.UserId] = {}
    templateComments[player.UserId] = {}
end

-- Handle player leaving
function BuildingTemplateManager.handlePlayerLeave(player)
    -- Clean up player's templates
    templates[player.UserId] = nil
    templateLikes[player.UserId] = nil
    templateComments[player.UserId] = nil
end

-- Save template
function BuildingTemplateManager.saveTemplate(player, name, description, objects)
    local userId = player.UserId
    
    -- Validate input
    if not name or not description or not objects then
        return false, "Invalid input"
    end
    
    -- Create template
    local templateId = HttpService:GenerateGUID()
    local template = {
        id = templateId,
        name = name,
        description = description,
        creator = userId,
        createdAt = os.time(),
        objects = objects,
        likes = 0,
        comments = {}
    }
    
    -- Save template
    templates[userId][templateId] = template
    
    return true, "Template saved"
end

-- Load template
function BuildingTemplateManager.loadTemplate(player, templateId)
    local userId = player.UserId
    
    -- Find template
    local template = nil
    for _, playerTemplates in pairs(templates) do
        if playerTemplates[templateId] then
            template = playerTemplates[templateId]
            break
        end
    end
    
    if not template then
        return false, "Template not found"
    end
    
    -- Create objects from template
    for _, objectData in ipairs(template.objects) do
        local object = BuildingTemplateManager.createObjectFromData(objectData)
        if object then
            -- Set owner
            BuildingTemplateManager.setObjectOwner(object, player)
        end
    end
    
    return true, "Template loaded"
end

-- Share template
function BuildingTemplateManager.shareTemplate(player, templateId)
    local userId = player.UserId
    
    -- Find template
    local template = templates[userId][templateId]
    if not template then
        return false, "Template not found"
    end
    
    -- Generate share link
    local shareLink = BuildingTemplateManager.generateShareLink(template)
    
    return true, shareLink
end

-- Like template
function BuildingTemplateManager.likeTemplate(player, templateId)
    local userId = player.UserId
    
    -- Find template
    local template = nil
    local templateOwner = nil
    for ownerId, playerTemplates in pairs(templates) do
        if playerTemplates[templateId] then
            template = playerTemplates[templateId]
            templateOwner = ownerId
            break
        end
    end
    
    if not template then
        return false, "Template not found"
    end
    
    -- Check if already liked
    if templateLikes[userId][templateId] then
        return false, "Already liked"
    end
    
    -- Add like
    template.likes = template.likes + 1
    templateLikes[userId][templateId] = true
    
    -- Notify owner
    if templateOwner ~= userId then
        local owner = Players:GetPlayerByUserId(templateOwner)
        if owner then
            -- TODO: Send notification to owner
        end
    end
    
    return true, "Template liked"
end

-- Comment on template
function BuildingTemplateManager.commentTemplate(player, templateId, comment)
    local userId = player.UserId
    
    -- Find template
    local template = nil
    local templateOwner = nil
    for ownerId, playerTemplates in pairs(templates) do
        if playerTemplates[templateId] then
            template = playerTemplates[templateId]
            templateOwner = ownerId
            break
        end
    end
    
    if not template then
        return false, "Template not found"
    end
    
    -- Add comment
    table.insert(template.comments, {
        userId = userId,
        username = player.Name,
        comment = comment,
        createdAt = os.time()
    })
    
    -- Notify owner
    if templateOwner ~= userId then
        local owner = Players:GetPlayerByUserId(templateOwner)
        if owner then
            -- TODO: Send notification to owner
        end
    end
    
    return true, "Comment added"
end

-- Get templates
function BuildingTemplateManager.getTemplates(player)
    local userId = player.UserId
    
    -- Get player's templates
    local playerTemplates = templates[userId]
    
    -- Get templates shared with player
    local sharedTemplates = {}
    for ownerId, ownerTemplates in pairs(templates) do
        if ownerId ~= userId then
            for templateId, template in pairs(ownerTemplates) do
                if template.shared then
                    table.insert(sharedTemplates, template)
                end
            end
        end
    end
    
    return true, {
        playerTemplates = playerTemplates,
        sharedTemplates = sharedTemplates
    }
end

-- Get featured templates
function BuildingTemplateManager.getFeaturedTemplates(player)
    return true, featuredTemplates
end

-- Generate share link
function BuildingTemplateManager.generateShareLink(template)
    -- TODO: Implement share link generation
    -- This could include:
    -- - Creating a unique URL
    -- - Adding template data
    -- - Adding security measures
    return "https://example.com/template/" .. template.id
end

-- Create object from data
function BuildingTemplateManager.createObjectFromData(data)
    -- TODO: Implement creating object from data
    -- This could include:
    -- - Creating the correct type of object
    -- - Setting properties
    -- - Positioning and orienting
    return nil
end

-- Set object owner
function BuildingTemplateManager.setObjectOwner(object, player)
    -- TODO: Implement setting object owner
    -- This could include:
    -- - Setting owner attribute
    -- - Updating ownership in database
    -- - Notifying relevant systems
end

return BuildingTemplateManager 