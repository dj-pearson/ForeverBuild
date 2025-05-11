-- DataStore Manager Pro Plugin
local plugin = script:GetProperty("Plugin")
if not plugin then
    error("This script must be run as a plugin")
end

-- Create toolbar and button
local toolbar = plugin:CreateToolbar("DataStore Manager Pro")
local button = toolbar:CreateButton(
    "Open DataStore Manager",
    "Open the DataStore Manager Pro Interface",
    "rbxassetid://7634658388"
)

-- Create widget
local widgetInfo = DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Right,
    false, -- Floating
    false, -- Enabled by default
    800,   -- Width
    600,   -- Height
    800,   -- MinWidth
    600    -- MinHeight
)

local widget = plugin:CreateDockWidgetPluginGui("DataStoreManagerWidget", widgetInfo)
widget.Title = "DataStore Manager Pro"

-- Set up button click handler
button.Click:Connect(function()
    widget.Enabled = not widget.Enabled
end)

return {
    Name = "DataStore Manager Pro",
    Version = "1.0.0"
} 