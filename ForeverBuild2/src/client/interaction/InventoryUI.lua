local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Constants = require(ReplicatedStorage.shared.core.Constants)

local InventoryUI = {}
InventoryUI.__index = InventoryUI

function InventoryUI.new(inventory, onUse)
    local self = setmetatable({}, InventoryUI)
    self.inventory = inventory or {}
    self.onUse = onUse
    self:CreateUI()
    return self
end

function InventoryUI:CreateUI()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "InventoryUI"
    self.screenGui.Parent = playerGui
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local frame = Instance.new("Frame")
    frame.Name = "InventoryFrame"
    frame.Size = UDim2.new(0, 400, 0, 300)
    frame.Position = UDim2.new(0.5, -200, 0.5, -150)
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
    title.Text = "Inventory"
    title.Parent = frame
    title.ZIndex = 21

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

    -- List items
    local listFrame = Instance.new("Frame")
    listFrame.Name = "ListFrame"
    listFrame.Size = UDim2.new(1, -40, 1, -80)
    listFrame.Position = UDim2.new(0, 20, 0, 60)
    listFrame.BackgroundTransparency = 1
    listFrame.Parent = frame
    listFrame.ZIndex = 21

    local layout = Instance.new("UIListLayout")
    layout.Parent = listFrame
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)

    for _, item in ipairs(self.inventory) do
        local itemButton = Instance.new("TextButton")
        itemButton.Name = item.id
        itemButton.Size = UDim2.new(1, 0, 0, 36)
        itemButton.BackgroundColor3 = Constants.UI_COLORS.PRIMARY
        itemButton.TextColor3 = Constants.UI_COLORS.TEXT
        itemButton.TextSize = 18
        itemButton.Font = Enum.Font.Gotham
        itemButton.Text = string.format("%s x%d", item.id, item.quantity or 1)
        itemButton.Parent = listFrame
        itemButton.ZIndex = 22

        itemButton.MouseButton1Click:Connect(function()
            if self.onUse then
                self.onUse(item)
            end
            self:Destroy()
        end)
    end
end

function InventoryUI:Destroy()
    if self.screenGui then
        self.screenGui:Destroy()
        self.screenGui = nil
    end
end

return InventoryUI 