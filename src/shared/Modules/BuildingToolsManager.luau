local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local BuildingToolsManager = {}

-- Local state
local selectedObjects = {} -- Currently selected objects
local clipboard = {} -- Objects in clipboard for copy/paste
local gridSnapEnabled = true -- Grid snapping state
local gridSize = 4 -- Grid size in studs
local rotationSnapEnabled = true -- Rotation snapping state
local rotationSnapAngle = 45 -- Rotation snap angle in degrees

-- Initialize building tools system
function BuildingToolsManager.init()
    -- Create remote events
    local remotes = ReplicatedStorage:WaitForChild("Remotes")
    
    local selectObjectEvent = Instance.new("RemoteEvent")
    selectObjectEvent.Name = "SelectObject"
    selectObjectEvent.Parent = remotes
    
    local deselectObjectEvent = Instance.new("RemoteEvent")
    deselectObjectEvent.Name = "DeselectObject"
    deselectObjectEvent.Parent = remotes
    
    local copyObjectsEvent = Instance.new("RemoteEvent")
    copyObjectsEvent.Name = "CopyObjects"
    copyObjectsEvent.Parent = remotes
    
    local pasteObjectsEvent = Instance.new("RemoteEvent")
    pasteObjectsEvent.Name = "PasteObjects"
    pasteObjectsEvent.Parent = remotes
    
    local groupObjectsEvent = Instance.new("RemoteEvent")
    groupObjectsEvent.Name = "GroupObjects"
    groupObjectsEvent.Parent = remotes
    
    local ungroupObjectsEvent = Instance.new("RemoteEvent")
    ungroupObjectsEvent.Name = "UngroupObjects"
    ungroupObjectsEvent.Parent = remotes
    
    local setGridSnapEvent = Instance.new("RemoteEvent")
    setGridSnapEvent.Name = "SetGridSnap"
    setGridSnapEvent.Parent = remotes
    
    local setRotationSnapEvent = Instance.new("RemoteEvent")
    setRotationSnapEvent.Name = "SetRotationSnap"
    setRotationSnapEvent.Parent = remotes
    
    -- Set up event handlers
    selectObjectEvent.OnServerEvent:Connect(function(player, object)
        BuildingToolsManager.selectObject(player, object)
    end)
    
    deselectObjectEvent.OnServerEvent:Connect(function(player, object)
        BuildingToolsManager.deselectObject(player, object)
    end)
    
    copyObjectsEvent.OnServerEvent:Connect(function(player)
        BuildingToolsManager.copyObjects(player)
    end)
    
    pasteObjectsEvent.OnServerEvent:Connect(function(player)
        BuildingToolsManager.pasteObjects(player)
    end)
    
    groupObjectsEvent.OnServerEvent:Connect(function(player)
        BuildingToolsManager.groupObjects(player)
    end)
    
    ungroupObjectsEvent.OnServerEvent:Connect(function(player)
        BuildingToolsManager.ungroupObjects(player)
    end)
    
    setGridSnapEvent.OnServerEvent:Connect(function(player, enabled)
        BuildingToolsManager.setGridSnap(player, enabled)
    end)
    
    setRotationSnapEvent.OnServerEvent:Connect(function(player, enabled)
        BuildingToolsManager.setRotationSnap(player, enabled)
    end)
    
    -- Set up player connection/disconnection handlers
    Players.PlayerAdded:Connect(function(player)
        BuildingToolsManager.handlePlayerJoin(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        BuildingToolsManager.handlePlayerLeave(player)
    end)
end

-- Handle player joining
function BuildingToolsManager.handlePlayerJoin(player)
    -- Initialize player's building tools state
    selectedObjects[player.UserId] = {}
    clipboard[player.UserId] = {}
end

-- Handle player leaving
function BuildingToolsManager.handlePlayerLeave(player)
    -- Clean up player's building tools state
    selectedObjects[player.UserId] = nil
    clipboard[player.UserId] = nil
end

-- Select object
function BuildingToolsManager.selectObject(player, object)
    local userId = player.UserId
    
    -- Validate object
    if not object or not object:IsA("BasePart") then
        return false, "Invalid object"
    end
    
    -- Check if player owns the object
    if not BuildingToolsManager.canModifyObject(player, object) then
        return false, "You don't have permission to modify this object"
    end
    
    -- Add object to selection
    table.insert(selectedObjects[userId], object)
    
    -- Highlight selected object
    BuildingToolsManager.highlightObject(object)
    
    return true, "Object selected"
end

-- Deselect object
function BuildingToolsManager.deselectObject(player, object)
    local userId = player.UserId
    
    -- Find and remove object from selection
    for i, selectedObject in ipairs(selectedObjects[userId]) do
        if selectedObject == object then
            table.remove(selectedObjects[userId], i)
            
            -- Remove highlight
            BuildingToolsManager.unhighlightObject(object)
            break
        end
    end
    
    return true, "Object deselected"
end

-- Copy objects
function BuildingToolsManager.copyObjects(player)
    local userId = player.UserId
    
    -- Clear clipboard
    clipboard[userId] = {}
    
    -- Copy selected objects
    for _, object in ipairs(selectedObjects[userId]) do
        table.insert(clipboard[userId], {
            type = object.ClassName,
            size = object.Size,
            position = object.Position,
            orientation = object.Orientation,
            properties = BuildingToolsManager.getObjectProperties(object)
        })
    end
    
    return true, "Objects copied to clipboard"
end

-- Paste objects
function BuildingToolsManager.pasteObjects(player)
    local userId = player.UserId
    
    -- Check if clipboard is empty
    if #clipboard[userId] == 0 then
        return false, "Clipboard is empty"
    end
    
    -- Create new objects from clipboard
    for _, objectData in ipairs(clipboard[userId]) do
        local newObject = BuildingToolsManager.createObjectFromData(objectData)
        if newObject then
            -- Set owner
            BuildingToolsManager.setObjectOwner(newObject, player)
            
            -- Add to selection
            table.insert(selectedObjects[userId], newObject)
            
            -- Highlight
            BuildingToolsManager.highlightObject(newObject)
        end
    end
    
    return true, "Objects pasted"
end

-- Group objects
function BuildingToolsManager.groupObjects(player)
    local userId = player.UserId
    
    -- Check if enough objects are selected
    if #selectedObjects[userId] < 2 then
        return false, "Select at least 2 objects to group"
    end
    
    -- Create group
    local group = Instance.new("Model")
    group.Name = "Group"
    
    -- Move objects into group
    for _, object in ipairs(selectedObjects[userId]) do
        object.Parent = group
    end
    
    -- Set group owner
    BuildingToolsManager.setObjectOwner(group, player)
    
    -- Add group to selection
    table.insert(selectedObjects[userId], group)
    
    -- Highlight group
    BuildingToolsManager.highlightObject(group)
    
    return true, "Objects grouped"
end

-- Ungroup objects
function BuildingToolsManager.ungroupObjects(player)
    local userId = player.UserId
    
    -- Find groups in selection
    for i = #selectedObjects[userId], 1, -1 do
        local object = selectedObjects[userId][i]
        if object:IsA("Model") then
            -- Move objects out of group
            for _, child in ipairs(object:GetChildren()) do
                child.Parent = object.Parent
                table.insert(selectedObjects[userId], child)
            end
            
            -- Remove group from selection
            table.remove(selectedObjects[userId], i)
            
            -- Destroy group
            object:Destroy()
        end
    end
    
    return true, "Objects ungrouped"
end

-- Set grid snap
function BuildingToolsManager.setGridSnap(player, enabled)
    gridSnapEnabled = enabled
    return true, "Grid snap " .. (enabled and "enabled" or "disabled")
end

-- Set rotation snap
function BuildingToolsManager.setRotationSnap(player, enabled)
    rotationSnapEnabled = enabled
    return true, "Rotation snap " .. (enabled and "enabled" or "disabled")
end

-- Get snapped position
function BuildingToolsManager.getSnappedPosition(position)
    if not gridSnapEnabled then
        return position
    end
    
    return Vector3.new(
        math.floor(position.X / gridSize + 0.5) * gridSize,
        math.floor(position.Y / gridSize + 0.5) * gridSize,
        math.floor(position.Z / gridSize + 0.5) * gridSize
    )
end

-- Get snapped rotation
function BuildingToolsManager.getSnappedRotation(rotation)
    if not rotationSnapEnabled then
        return rotation
    end
    
    return Vector3.new(
        math.floor(rotation.X / rotationSnapAngle + 0.5) * rotationSnapAngle,
        math.floor(rotation.Y / rotationSnapAngle + 0.5) * rotationSnapAngle,
        math.floor(rotation.Z / rotationSnapAngle + 0.5) * rotationSnapAngle
    )
end

-- Highlight object
function BuildingToolsManager.highlightObject(object)
    -- TODO: Implement object highlighting
    -- This could include:
    -- - Adding a highlight effect
    -- - Changing object transparency
    -- - Adding a selection box
end

-- Unhighlight object
function BuildingToolsManager.unhighlightObject(object)
    -- TODO: Implement object unhighlighting
    -- This could include:
    -- - Removing highlight effect
    -- - Restoring original transparency
    -- - Removing selection box
end

-- Get object properties
function BuildingToolsManager.getObjectProperties(object)
    -- TODO: Implement getting object properties
    -- This could include:
    -- - Material
    -- - Color
    -- - Transparency
    -- - Other relevant properties
    return {}
end

-- Create object from data
function BuildingToolsManager.createObjectFromData(data)
    -- TODO: Implement creating object from data
    -- This could include:
    -- - Creating the correct type of object
    -- - Setting properties
    -- - Positioning and orienting
    return nil
end

-- Set object owner
function BuildingToolsManager.setObjectOwner(object, player)
    -- TODO: Implement setting object owner
    -- This could include:
    -- - Setting owner attribute
    -- - Updating ownership in database
    -- - Notifying relevant systems
end

-- Check if player can modify object
function BuildingToolsManager.canModifyObject(player, object)
    -- TODO: Implement permission check
    -- This could include:
    -- - Checking ownership
    -- - Checking permissions
    -- - Checking game rules
    return true
end

return BuildingToolsManager 