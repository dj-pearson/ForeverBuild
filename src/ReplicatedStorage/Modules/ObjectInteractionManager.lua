local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local ObjectInteractionManager = {}

-- Remote events
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local moveObjectEvent = remotes:WaitForChild("MoveObject")
local cloneObjectEvent = remotes:WaitForChild("CloneObject")
local removeObjectEvent = remotes:WaitForChild("RemoveObject")
local rotateObjectEvent = remotes:WaitForChild("RotateObject")

-- Local state
local selectedObject = nil
local isInteracting = false
local interactionMode = nil -- "move", "clone", "remove", or "rotate"
local currentRotation = 0

-- Handle object selection
function ObjectInteractionManager.selectObject(object)
    if selectedObject then
        -- Deselect previous object
        if selectedObject:FindFirstChild("Highlight") then
            selectedObject.Highlight:Destroy()
        end
    end
    
    selectedObject = object
    
    if object then
        -- Create highlight
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Color3.fromRGB(255, 255, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 200, 0)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = object
    end
end

-- Start object interaction
function ObjectInteractionManager.startInteraction(mode)
    if not selectedObject then return end
    
    interactionMode = mode
    isInteracting = true
    currentRotation = 0
    
    -- Show interaction UI
    local interactionUI = Instance.new("ScreenGui")
    interactionUI.Name = "InteractionUI"
    interactionUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 100)
    frame.Position = UDim2.new(0.5, -100, 0.8, -50)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    frame.BorderSizePixel = 0
    frame.Parent = interactionUI
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "Click to " .. mode .. " object\nPress R to rotate\nPress ESC to cancel"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 20
    label.Font = Enum.Font.Gotham
    label.Parent = frame
    
    -- Handle input
    local function onInputBegan(input, gameProcessed)
        if gameProcessed then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Get mouse position in world space
            local mouse = Players.LocalPlayer:GetMouse()
            local ray = workspace.CurrentCamera:ScreenPointToRay(mouse.X, mouse.Y)
            local hit, position = workspace:FindPartOnRay(ray)
            
            if hit then
                if interactionMode == "move" then
                    moveObjectEvent:FireServer(selectedObject:GetFullName(), position, currentRotation)
                elseif interactionMode == "clone" then
                    cloneObjectEvent:FireServer(selectedObject:GetFullName(), position, currentRotation)
                elseif interactionMode == "remove" then
                    removeObjectEvent:FireServer(selectedObject:GetFullName())
                end
                
                -- Clean up
                ObjectInteractionManager.endInteraction()
            end
        elseif input.KeyCode == Enum.KeyCode.R then
            -- Rotate object
            currentRotation = (currentRotation + 90) % 360
            rotateObjectEvent:FireServer(selectedObject:GetFullName(), currentRotation)
        elseif input.KeyCode == Enum.KeyCode.Escape then
            ObjectInteractionManager.endInteraction()
        end
    end
    
    UserInputService.InputBegan:Connect(onInputBegan)
end

-- End object interaction
function ObjectInteractionManager.endInteraction()
    isInteracting = false
    interactionMode = nil
    currentRotation = 0
    
    -- Remove interaction UI
    local interactionUI = Players.LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("InteractionUI")
    if interactionUI then
        interactionUI:Destroy()
    end
    
    -- Deselect object
    ObjectInteractionManager.selectObject(nil)
end

-- Initialize
function ObjectInteractionManager.init()
    -- Set up event handlers
    moveObjectEvent.OnClientEvent:Connect(function(success, message)
        if success then
            print("Object moved successfully")
        else
            print("Failed to move object:", message)
        end
    end)
    
    cloneObjectEvent.OnClientEvent:Connect(function(success, message)
        if success then
            print("Object cloned successfully")
        else
            print("Failed to clone object:", message)
        end
    end)
    
    removeObjectEvent.OnClientEvent:Connect(function(success, message)
        if success then
            print("Object removed successfully")
        else
            print("Failed to remove object:", message)
        end
    end)
    
    rotateObjectEvent.OnClientEvent:Connect(function(success, message)
        if success then
            print("Object rotated successfully")
        else
            print("Failed to rotate object:", message)
        end
    end)
end

return ObjectInteractionManager 