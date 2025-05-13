-- PlacedItemDialog.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Constants = require(script.Parent.Parent.Constants)

local PlacedItemDialog = {}

-- UI Constants
local DIALOG_SIZE = UDim2.new(0, 300, 0, 400)
local DIALOG_POSITION = UDim2.new(0.5, -150, 0.5, -200)
local ANIMATION_DURATION = 0.3
local BUTTON_HEIGHT = 50
local BUTTON_PADDING = 10

-- Create the dialog UI
local function createDialog(parent)
    local dialog = Instance.new("Frame")
    dialog.Name = "PlacedItemDialog"
    dialog.Size = DIALOG_SIZE
    dialog.Position = DIALOG_POSITION
    dialog.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    dialog.BorderSizePixel = 0
    dialog.Visible = false
    dialog.Parent = parent
    
    -- Add corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = dialog
    
    -- Add shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.ZIndex = -1
    shadow.Parent = dialog
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    title.BorderSizePixel = 0
    title.Font = Enum.Font.GothamBold
    title.Text = "Item Actions"
    title.TextSize = 24
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Parent = dialog
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = title
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Text = "X"
    closeButton.TextSize = 18
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Parent = title
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton
    
    -- Actions container
    local actionsContainer = Instance.new("Frame")
    actionsContainer.Name = "ActionsContainer"
    actionsContainer.Size = UDim2.new(1, -40, 1, -70)
    actionsContainer.Position = UDim2.new(0, 20, 0, 60)
    actionsContainer.BackgroundTransparency = 1
    actionsContainer.Parent = dialog
    
    -- Create action buttons
    local actions = {
        { name = "Clone", color = Color3.fromRGB(0, 120, 0), cost = Constants.ITEM_ACTIONS.clone.cost },
        { name = "Move", color = Color3.fromRGB(0, 120, 200), cost = Constants.ITEM_ACTIONS.move.cost },
        { name = "Rotate", color = Color3.fromRGB(200, 120, 0), cost = Constants.ITEM_ACTIONS.rotate.cost },
        { name = "Destroy", color = Color3.fromRGB(200, 0, 0), cost = Constants.ITEM_ACTIONS.destroy.cost }
    }
    
    for i, action in ipairs(actions) do
        local button = Instance.new("TextButton")
        button.Name = action.name
        button.Size = UDim2.new(1, 0, 0, BUTTON_HEIGHT)
        button.Position = UDim2.new(0, 0, 0, (i-1) * (BUTTON_HEIGHT + BUTTON_PADDING))
        button.BackgroundColor3 = action.color
        button.Font = Enum.Font.GothamBold
        button.Text = string.format("%s (%d)", action.name, action.cost)
        button.TextSize = 18
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Parent = actionsContainer
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 4)
        buttonCorner.Parent = button
        
        -- Hover effect
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = action.color:Lerp(Color3.new(1, 1, 1), 0.2)
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = action.color
            }):Play()
        end)
    end
    
    return dialog
end

-- Initialize the dialog
function PlacedItemDialog.Initialize(parent)
    local dialog = createDialog(parent)
    local currentItemId = nil
    
    -- Set up close button
    dialog.Title.CloseButton.MouseButton1Click:Connect(function()
        PlacedItemDialog.Hide()
    end)
    
    -- Set up action buttons
    for _, button in ipairs(dialog.ActionsContainer:GetChildren()) do
        if button:IsA("TextButton") then
            button.MouseButton1Click:Connect(function()
                if PlacedItemDialog.OnActionSelected and currentItemId then
                    PlacedItemDialog.OnActionSelected(currentItemId, button.Name:lower())
                end
                PlacedItemDialog.Hide()
            end)
        end
    end
    
    -- Store dialog reference
    PlacedItemDialog._dialog = dialog
end

-- Show the dialog
function PlacedItemDialog.Show(itemId, itemName)
    local dialog = PlacedItemDialog._dialog
    if not dialog then return end
    
    currentItemId = itemId
    dialog.Title.Text = itemName or "Item Actions"
    
    -- Show dialog with animation
    dialog.Visible = true
    dialog.BackgroundTransparency = 1
    
    local showTween = TweenService:Create(dialog, TweenInfo.new(ANIMATION_DURATION), {
        BackgroundTransparency = 0
    })
    showTween:Play()
end

-- Hide the dialog
function PlacedItemDialog.Hide()
    local dialog = PlacedItemDialog._dialog
    if not dialog then return end
    
    local hideTween = TweenService:Create(dialog, TweenInfo.new(ANIMATION_DURATION), {
        BackgroundTransparency = 1
    })
    
    hideTween.Completed:Connect(function()
        dialog.Visible = false
    end)
    
    hideTween:Play()
end

return PlacedItemDialog 