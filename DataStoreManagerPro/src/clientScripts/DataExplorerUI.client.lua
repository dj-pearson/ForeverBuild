-- DataExplorerUI.client.lua
local DataExplorerUI = {}

function DataExplorerUI.initialize()
    print("DataExplorerUI initialized")
end

function DataExplorerUI.createMainGui(parent)
    local frame = Instance.new("Frame")
    frame.Name = "DataExplorerUIFrame"
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.Parent = parent
    return frame
end

return DataExplorerUI 