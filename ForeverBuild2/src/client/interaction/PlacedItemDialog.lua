local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Constants = require(ReplicatedStorage.shared.core.Constants)

local PlacedItemDialog = {}
PlacedItemDialog.__index = PlacedItemDialog

function PlacedItemDialog.new(itemId, tier, onAction)
    local self = setmetatable({}, PlacedItemDialog)
    self.itemId = itemId
    self.tier = tier
    self.onAction = onAction
    self:CreateUI()
    return self
end

function PlacedItemDialog:CreateUI()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "PlacedItemDialog"
    self.screenGui.Parent = playerGui
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local frame = Instance.new("Frame")
    frame.Name = "DialogFrame"
    frame.Size = UDim2.new(0, 320, 0, 260)
    frame.Position = UDim2.new(0.5, -160, 0.5, -130)
    frame.BackgroundColor3 = Constants.UI_COLORS.SECONDARY
    frame.BorderSizePixel = 0
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.Parent = self.screenGui
    frame.ZIndex = 20

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Constants.UI_COLORS.TEXT
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.Text = string.format("%s (%s)", self.itemId, self.tier:gsub("^%l", string.upper))
    title.Parent = frame
    title.ZIndex = 21

    local actions = {
        {name = "Clone", fee = Constants.ITEM_PRICING.clone or 0},
        {name = "Move", fee = Constants.ITEM_PRICING.move or 0},
        {name = "Destroy", fee = Constants.ITEM_PRICING.destroy or 0},
        {name = "Rotate", fee = Constants.ITEM_PRICING.rotate or 0}
    }

    for i, action in ipairs(actions) do
        local button = Instance.new("TextButton")
        button.Name = action.name .. "Button"
        button.Size = UDim2.new(0.8, 0, 0, 40)
        button.Position = UDim2.new(0.1, 0, 0, 40 + (i-1)*50)
        button.BackgroundColor3 = Constants.UI_COLORS.PRIMARY
        button.Text = string.format("%s (%d Robux)", action.name, action.fee)
        button.TextColor3 = Constants.UI_COLORS.TEXT
        button.TextSize = 18
        button.Font = Enum.Font.GothamBold
        button.Parent = frame
        button.ZIndex = 21
        button.MouseButton1Click:Connect(function()
            if self.onAction then
                self.onAction(action.name:lower())
            end
            self:Destroy()
        end)
    end

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundColor3 = Constants.UI_COLORS.ERROR
    closeButton.Text = "X"
    closeButton.TextColor3 = Constants.UI_COLORS.TEXT
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = frame
    closeButton.ZIndex = 21
    closeButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
end

function PlacedItemDialog:Destroy()
    if self.screenGui then
        self.screenGui:Destroy()
        self.screenGui = nil
    end
end

return PlacedItemDialog 