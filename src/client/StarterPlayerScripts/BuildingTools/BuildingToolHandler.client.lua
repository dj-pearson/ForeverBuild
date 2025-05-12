local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Get necessary modules and remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PlaceObjectEvent = Remotes:WaitForChild("PlaceObject")
local MoveObjectEvent = Remotes:WaitForChild("MoveObject")
local RemoveObjectEvent = Remotes:WaitForChild("RemoveObject")

-- Set up local variables
local currentTool = nil
local currentObjectPreview = nil
local isPlacingObject = false
local gridSize = 1 -- For grid snapping
local snapToGrid = true
local rotationAmount = math.rad(90) -- 90 degrees
local currentRotation = CFrame.Angles(0, 0, 0)

-- Function to create a preview of the object
local function createObjectPreview(objectType)
    -- Get item models folder
    local ItemModels = ReplicatedStorage:FindFirstChild("ItemModels")
    if not ItemModels then
        warn("BuildingToolHandler: ItemModels folder not found in ReplicatedStorage")
        return nil
    end
    
    -- Find the object model
    local objectModel = ItemModels:FindFirstChild(objectType)
    if not objectModel then
        warn("BuildingToolHandler: Object model not found:", objectType)
        return nil
    end
    
    -- Create a preview by cloning the model
    local preview = objectModel:Clone()
    preview.Name = "ObjectPreview"
    
    -- Make the model transparent
    for _, part in ipairs(preview:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Transparency = 0.5
            
            -- Create a selection box to highlight it
            local selectionBox = Instance.new("SelectionBox")
            selectionBox.Adornee = part
            selectionBox.LineThickness = 0.02
            selectionBox.Color3 = Color3.fromRGB(0, 162, 255)
            selectionBox.Parent = part
        end
    end
    
    preview.Parent = workspace
    return preview
end

-- Function to update the preview position
local function updatePreviewPosition()
    if not currentObjectPreview or not currentObjectPreview.PrimaryPart then
        return
    end
    
    -- Raycast from mouse position
    local mouseRay = Mouse.UnitRay
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {currentObjectPreview}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    
    local raycastResult = workspace:Raycast(mouseRay.Origin, mouseRay.Direction * 1000, raycastParams)
    if not raycastResult then
        return
    end
    
    -- Get position
    local position = raycastResult.Position
    
    -- Snap to grid if enabled
    if snapToGrid then
        position = Vector3.new(
            math.floor(position.X / gridSize + 0.5) * gridSize,
            math.floor(position.Y / gridSize + 0.5) * gridSize,
            math.floor(position.Z / gridSize + 0.5) * gridSize
        )
    end
    
    -- Apply position and rotation
    currentObjectPreview:SetPrimaryPartCFrame(CFrame.new(position) * currentRotation)
end

-- Function to start placing an object
local function startPlacingObject(objectType)
    -- Stop any current placement
    if isPlacingObject then
        stopPlacingObject()
    end
    
    -- Create the preview
    currentObjectPreview = createObjectPreview(objectType)
    if not currentObjectPreview then
        return
    end
    
    currentTool = objectType
    isPlacingObject = true
    
    -- Start updating the preview position
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if isPlacingObject and currentObjectPreview then
            updatePreviewPosition()
        else
            connection:Disconnect()
        end
    end)
end

-- Function to stop placing an object
local function stopPlacingObject()
    if currentObjectPreview then
        currentObjectPreview:Destroy()
        currentObjectPreview = nil
    end
    
    currentTool = nil
    isPlacingObject = false
    currentRotation = CFrame.Angles(0, 0, 0)
end

-- Function to place the current object
local function placeObject()
    if not isPlacingObject or not currentObjectPreview or not currentObjectPreview.PrimaryPart then
        return
    end
    
    -- Get position and rotation
    local position = currentObjectPreview.PrimaryPart.Position
    local rotation = currentRotation:ToEulerAnglesXYZ()
    
    -- Send request to server
    PlaceObjectEvent:FireServer(currentTool, position, Vector3.new(rotation.X, rotation.Y, rotation.Z))
    
    -- Continue placement for multiple objects
    local objectType = currentTool -- Save before stopping
    stopPlacingObject()
    startPlacingObject(objectType)
end

-- Function to rotate the preview
local function rotatePreview(axis)
    if not isPlacingObject or not currentObjectPreview then
        return
    end
    
    if axis == "X" then
        currentRotation = currentRotation * CFrame.Angles(rotationAmount, 0, 0)
    elseif axis == "Y" then
        currentRotation = currentRotation * CFrame.Angles(0, rotationAmount, 0)
    elseif axis == "Z" then
        currentRotation = currentRotation * CFrame.Angles(0, 0, rotationAmount)
    end
    
    updatePreviewPosition()
end

-- Set up input handlers
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if isPlacingObject then
        -- Place object on left click
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            placeObject()
        end
        
        -- Cancel on right click
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            stopPlacingObject()
        end
        
        -- Rotate on keys
        if input.KeyCode == Enum.KeyCode.X then
            rotatePreview("X")
        elseif input.KeyCode == Enum.KeyCode.Y then
            rotatePreview("Y")
        elseif input.KeyCode == Enum.KeyCode.Z then
            rotatePreview("Z")
        end
        
        -- Toggle grid snap
        if input.KeyCode == Enum.KeyCode.G then
            snapToGrid = not snapToGrid
        end
    end
end)

-- Function to start using a building tool
local function useBuilderTool(toolType, objectType)
    if toolType == "place" then
        startPlacingObject(objectType)
    elseif toolType == "move" then
        -- Implementation for moving objects
    elseif toolType == "remove" then
        -- Implementation for removing objects
    end
end

-- Export the module functions
local BuildingToolHandler = {}
BuildingToolHandler.useBuilderTool = useBuilderTool
BuildingToolHandler.stopPlacingObject = stopPlacingObject

-- Make the BuildingToolHandler accessible to other scripts
_G.BuildingToolHandler = BuildingToolHandler

return BuildingToolHandler
