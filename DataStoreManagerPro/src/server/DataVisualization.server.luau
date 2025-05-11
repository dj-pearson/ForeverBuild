--luau
-- DataStore Plugin/DataVisualization.luau

-- Get module resolver from init script or define a local one
local resolver = script.Parent:FindFirstChild("ModuleResolver")
local resolveModule = resolver and require(resolver).resolveModule or function(name)
    local success, result = pcall(function()
        return require(script.Parent:FindFirstChild(name))
    end)
    
    if success and result then
        return result
    end
    
    warn("Failed to resolve module: " .. name)
    return {
        initialize = function() return true end,
        createUI = function() return Instance.new("Frame") end
    }
end

local DataVisualization = {}

-- Function to create a basic bar chart
function DataVisualization.createBarChart(container, data, options)
    options = options or {}
    local title = options.title or "Bar Chart"
    local barColor = options.barColor or Color3.fromRGB(60, 120, 255)
    local labelColor = options.labelColor or Color3.fromRGB(255, 255, 255)
    local backgroundColor = options.backgroundColor or Color3.fromRGB(30, 30, 40)
    local showValues = options.showValues ~= false -- Default to true
    local valueFormat = options.valueFormat or "%d" -- Default format
    
    -- Create chart container
    local chartFrame = Instance.new("Frame")
    chartFrame.Size = UDim2.new(1, 0, 1, 0)
    chartFrame.BackgroundColor3 = backgroundColor
    chartFrame.BorderSizePixel = 0
    chartFrame.Parent = container
    
    -- Chart title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 24)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = labelColor
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 16
    titleLabel.Parent = chartFrame
    
    -- Chart area
    local chartArea = Instance.new("Frame")
    chartArea.Size = UDim2.new(1, -20, 1, -40)
    chartArea.Position = UDim2.new(0, 10, 0, 35)
    chartArea.BackgroundTransparency = 1
    chartArea.ClipsDescendants = true
    chartArea.Parent = chartFrame
    
    -- Find max value for scaling
    local maxValue = 0
    for _, value in pairs(data) do
        if type(value) == "number" then
            maxValue = math.max(maxValue, value)
        end
    end
    
    -- If all values are 0, set a minimum scale
    if maxValue == 0 then
        maxValue = 1
    end
    
    -- Create bars
    local barCount = 0
    for key, value in pairs(data) do
        if type(value) == "number" then
            barCount = barCount + 1
        end
    end
    
    local barWidth = chartArea.Size.X.Scale / barCount
    local padding = barWidth * 0.1
    
    local index = 0
    for key, value in pairs(data) do
        if type(value) == "number" then
            local normalizedValue = value / maxValue
            local barHeight = normalizedValue * chartArea.Size.Y.Scale * 0.9 -- Leave room for labels
            
            -- Bar
            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(barWidth - padding, 0, barHeight, 0)
            bar.Position = UDim2.new(index * barWidth + padding/2, 0, 1 - barHeight, 0)
            bar.BackgroundColor3 = barColor
            bar.BorderSizePixel = 0
            bar.Parent = chartArea
            
            -- Value label (if enabled)
            if showValues then
                local valueLabel = Instance.new("TextLabel")
                valueLabel.Size = UDim2.new(1, 0, 0, 20)
                valueLabel.Position = UDim2.new(0, 0, -20/chartArea.Size.Y.Offset, 0)
                valueLabel.BackgroundTransparency = 1
                valueLabel.Text = string.format(valueFormat, value)
                valueLabel.TextColor3 = labelColor
                valueLabel.Font = Enum.Font.SourceSans
                valueLabel.TextSize = 12
                valueLabel.Parent = bar
            end
            
            -- Key label
            local keyLabel = Instance.new("TextLabel")
            keyLabel.Size = UDim2.new(barWidth - padding, 0, 0, 20)
            keyLabel.Position = UDim2.new(index * barWidth + padding/2, 0, 1, 5)
            keyLabel.BackgroundTransparency = 1
            keyLabel.Text = tostring(key)
            keyLabel.TextColor3 = labelColor
            keyLabel.Font = Enum.Font.SourceSans
            keyLabel.TextSize = 12
            keyLabel.TextWrapped = true
            keyLabel.Parent = chartFrame
            
            index = index + 1
        end
    end
    
    return chartFrame
end

-- Function to create a line chart
function DataVisualization.createLineChart(container, data, options)
    options = options or {}
    local title = options.title or "Line Chart"
    local lineColor = options.lineColor or Color3.fromRGB(60, 200, 60)
    local pointColor = options.pointColor or Color3.fromRGB(255, 255, 255)
    local labelColor = options.labelColor or Color3.fromRGB(255, 255, 255)
    local backgroundColor = options.backgroundColor or Color3.fromRGB(30, 30, 40)
    local showValues = options.showValues ~= false -- Default to true
    local valueFormat = options.valueFormat or "%d" -- Default format
    
    -- Create chart container
    local chartFrame = Instance.new("Frame")
    chartFrame.Size = UDim2.new(1, 0, 1, 0)
    chartFrame.BackgroundColor3 = backgroundColor
    chartFrame.BorderSizePixel = 0
    chartFrame.Parent = container
    
    -- Chart title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 24)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = labelColor
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 16
    titleLabel.Parent = chartFrame
    
    -- Chart area
    local chartArea = Instance.new("Frame")
    chartArea.Size = UDim2.new(1, -20, 1, -40)
    chartArea.Position = UDim2.new(0, 10, 0, 35)
    chartArea.BackgroundTransparency = 1
    chartArea.ClipsDescendants = true
    chartArea.Parent = chartFrame
    
    -- Find min and max values for scaling
    local minValue = math.huge
    local maxValue = -math.huge
    for _, value in pairs(data) do
        if type(value) == "number" then
            minValue = math.min(minValue, value)
            maxValue = math.max(maxValue, value)
        end
    end
    
    -- Ensure min and max are different
    if minValue == maxValue then
        if minValue == 0 then
            maxValue = 1
        else
            minValue = minValue * 0.9
            maxValue = maxValue * 1.1
        end
    end
    
    -- Create data points and lines
    local pointCount = 0
    for key, value in pairs(data) do
        if type(value) == "number" then
            pointCount = pointCount + 1
        end
    end
    
    local pointWidth = chartArea.Size.X.Scale / (pointCount - 1)
    local normalizedValues = {}
    local points = {}
    
    local index = 0
    for key, value in pairs(data) do
        if type(value) == "number" then
            local normalizedValue = (value - minValue) / (maxValue - minValue)
            normalizedValues[key] = normalizedValue
            
            -- Point
            local point = Instance.new("Frame")
            point.Size = UDim2.new(0, 8, 0, 8)
            point.Position = UDim2.new(index * pointWidth, 0, 1 - normalizedValue, 0)
            point.AnchorPoint = Vector2.new(0.5, 0.5)
            point.BackgroundColor3 = pointColor
            point.BorderSizePixel = 0
            point.Name = "Point_" .. tostring(key)
            point.Parent = chartArea
            
            table.insert(points, point)
            
            -- Value label (if enabled)
            if showValues then
                local valueLabel = Instance.new("TextLabel")
                valueLabel.Size = UDim2.new(0, 50, 0, 20)
                valueLabel.Position = UDim2.new(0, 0, -20/chartArea.Size.Y.Offset, 0)
                valueLabel.AnchorPoint = Vector2.new(0.5, 1)
                valueLabel.BackgroundTransparency = 1
                valueLabel.Text = string.format(valueFormat, value)
                valueLabel.TextColor3 = labelColor
                valueLabel.Font = Enum.Font.SourceSans
                valueLabel.TextSize = 12
                valueLabel.Parent = point
            end
            
            -- Key label
            if index % math.max(1, math.floor(pointCount / 10)) == 0 then -- Show labels for 10 points max
                local keyLabel = Instance.new("TextLabel")
                keyLabel.Size = UDim2.new(0, 50, 0, 20)
                keyLabel.Position = UDim2.new(index * pointWidth, 0, 1, 5)
                keyLabel.AnchorPoint = Vector2.new(0.5, 0)
                keyLabel.BackgroundTransparency = 1
                keyLabel.Text = tostring(key)
                keyLabel.TextColor3 = labelColor
                keyLabel.Font = Enum.Font.SourceSans
                keyLabel.TextSize = 12
                keyLabel.TextWrapped = true
                keyLabel.Parent = chartFrame
            end
            
            index = index + 1
        end
    end
    
    -- Draw lines between points
    for i = 1, #points - 1 do
        local p1 = points[i]
        local p2 = points[i + 1]
        
        local dx = p2.Position.X.Scale - p1.Position.X.Scale
        local dy = p2.Position.Y.Scale - p1.Position.Y.Scale
        local distance = math.sqrt(dx*dx + dy*dy)
        local angle = math.atan2(dy, dx)
        
        local line = Instance.new("Frame")
        line.Size = UDim2.new(distance, 0, 0, 2)
        line.Position = UDim2.new(p1.Position.X.Scale, 0, p1.Position.Y.Scale, 0)
        line.AnchorPoint = Vector2.new(0, 0.5)
        line.BackgroundColor3 = lineColor
        line.BorderSizePixel = 0
        line.Rotation = math.deg(angle)
        line.ZIndex = 1 -- Behind points
        line.Parent = chartArea
    end
    
    return chartFrame
end

-- Function to create a pie chart
function DataVisualization.createPieChart(container, data, options)
    options = options or {}
    local title = options.title or "Pie Chart"
    local colors = options.colors or {
        Color3.fromRGB(60, 120, 255),
        Color3.fromRGB(60, 200, 60),
        Color3.fromRGB(255, 100, 100),
        Color3.fromRGB(200, 100, 200),
        Color3.fromRGB(255, 180, 60),
    }
    local labelColor = options.labelColor or Color3.fromRGB(255, 255, 255)
    local backgroundColor = options.backgroundColor or Color3.fromRGB(30, 30, 40)
    local showValues = options.showValues ~= false -- Default to true
    local valueFormat = options.valueFormat or "%.1f%%" -- Default format
    
    -- Create chart container
    local chartFrame = Instance.new("Frame")
    chartFrame.Size = UDim2.new(1, 0, 1, 0)
    chartFrame.BackgroundColor3 = backgroundColor
    chartFrame.BorderSizePixel = 0
    chartFrame.Parent = container
    
    -- Chart title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 24)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = labelColor
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 16
    titleLabel.Parent = chartFrame
    
    -- We can't actually create a pie chart in Roblox UI directly,
    -- so we'll use a legend instead
    local legendFrame = Instance.new("Frame")
    legendFrame.Size = UDim2.new(0.5, 0, 0.8, 0)
    legendFrame.Position = UDim2.new(0.5, 0, 0.2, 0)
    legendFrame.BackgroundTransparency = 1
    legendFrame.Parent = chartFrame
    
    local legendLayout = Instance.new("UIListLayout")
    legendLayout.Padding = UDim.new(0, 5)
    legendLayout.Parent = legendFrame
    
    -- Calculate total
    local total = 0
    for _, value in pairs(data) do
        if type(value) == "number" and value > 0 then
            total = total + value
        end
    end
    
    -- Create legend items
    local index = 0
    for key, value in pairs(data) do
        if type(value) == "number" and value > 0 then
            local percentage = (value / total) * 100
            local colorIndex = (index % #colors) + 1
            
            local itemFrame = Instance.new("Frame")
            itemFrame.Size = UDim2.new(1, 0, 0, 24)
            itemFrame.BackgroundTransparency = 1
            itemFrame.Parent = legendFrame
            
            local colorSwatch = Instance.new("Frame")
            colorSwatch.Size = UDim2.new(0, 16, 0, 16)
            colorSwatch.Position = UDim2.new(0, 0, 0.5, -8)
            colorSwatch.BackgroundColor3 = colors[colorIndex]
            colorSwatch.BorderSizePixel = 0
            colorSwatch.Parent = itemFrame
            
            local keyLabel = Instance.new("TextLabel")
            keyLabel.Size = UDim2.new(0.7, -20, 1, 0)
            keyLabel.Position = UDim2.new(0, 24, 0, 0)
            keyLabel.BackgroundTransparency = 1
            keyLabel.Text = tostring(key)
            keyLabel.TextColor3 = labelColor
            keyLabel.TextXAlignment = Enum.TextXAlignment.Left
            keyLabel.Font = Enum.Font.SourceSans
            keyLabel.TextSize = 14
            keyLabel.TextWrapped = true
            keyLabel.Parent = itemFrame
            
            if showValues then
                local valueLabel = Instance.new("TextLabel")
                valueLabel.Size = UDim2.new(0.3, 0, 1, 0)
                valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
                valueLabel.BackgroundTransparency = 1
                valueLabel.Text = string.format(valueFormat, percentage)
                valueLabel.TextColor3 = labelColor
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                valueLabel.Font = Enum.Font.SourceSans
                valueLabel.TextSize = 14
                valueLabel.Parent = itemFrame
            end
            
            index = index + 1
        end
    end
    
    -- Create a simplified pie visualization using sectors
    local pieFrame = Instance.new("Frame")
    pieFrame.Size = UDim2.new(0.4, 0, 0.7, 0)
    pieFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
    pieFrame.BackgroundTransparency = 1
    pieFrame.Parent = chartFrame
    
    -- Note: In a real implementation, we would create actual pie sectors,
    -- but for simplicity, we're just creating colored blocks proportional to values
    local currentOffset = 0
    index = 0
    for key, value in pairs(data) do
        if type(value) == "number" and value > 0 then
            local percentage = value / total
            local colorIndex = (index % #colors) + 1
            
            local segment = Instance.new("Frame")
            segment.Size = UDim2.new(1, 0, percentage, 0)
            segment.Position = UDim2.new(0, 0, currentOffset, 0)
            segment.BackgroundColor3 = colors[colorIndex]
            segment.BorderSizePixel = 0
            segment.Parent = pieFrame
            
            currentOffset = currentOffset + percentage
            index = index + 1
        end
    end
    
    return chartFrame
end

-- Function to create a generic table view
function DataVisualization.createTableView(container, data, options)
    options = options or {}
    local title = options.title or "Data Table"
    local headerColor = options.headerColor or Color3.fromRGB(60, 100, 180)
    local rowColor1 = options.rowColor1 or Color3.fromRGB(40, 40, 50)
    local rowColor2 = options.rowColor2 or Color3.fromRGB(50, 50, 60)
    local textColor = options.textColor or Color3.fromRGB(255, 255, 255)
    local backgroundColor = options.backgroundColor or Color3.fromRGB(30, 30, 40)
    local columns = options.columns or {"Key", "Value"}
    
    -- Create table container
    local tableFrame = Instance.new("Frame")
    tableFrame.Size = UDim2.new(1, 0, 1, 0)
    tableFrame.BackgroundColor3 = backgroundColor
    tableFrame.BorderSizePixel = 0
    tableFrame.Parent = container
    
    -- Table title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 24)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = textColor
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 16
    titleLabel.Parent = tableFrame
    
    -- Table area
    local tableArea = Instance.new("ScrollingFrame")
    tableArea.Size = UDim2.new(1, -20, 1, -30)
    tableArea.Position = UDim2.new(0, 10, 0, 30)
    tableArea.BackgroundTransparency = 1
    tableArea.ScrollBarThickness = 6
    tableArea.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be set later
    tableArea.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
    tableArea.Parent = tableFrame
    
    local tableLayout = Instance.new("UIListLayout")
    tableLayout.Padding = UDim.new(0, 1)
    tableLayout.Parent = tableArea
    
    -- Create header row
    local headerRow = Instance.new("Frame")
    headerRow.Size = UDim2.new(1, 0, 0, 24)
    headerRow.BackgroundColor3 = headerColor
    headerRow.BorderSizePixel = 0
    headerRow.Parent = tableArea
    
    local columnWidth = 1 / #columns
    for i, columnName in ipairs(columns) do
        local headerCell = Instance.new("TextLabel")
        headerCell.Size = UDim2.new(columnWidth, 0, 1, 0)
        headerCell.Position = UDim2.new((i-1) * columnWidth, 0, 0, 0)
        headerCell.BackgroundTransparency = 1
        headerCell.Text = columnName
        headerCell.TextColor3 = textColor
        headerCell.Font = Enum.Font.SourceSansBold
        headerCell.TextSize = 14
        headerCell.Parent = headerRow
    end
    
    -- Create data rows
    local rowIndex = 0
    for key, value in pairs(data) do
        rowIndex = rowIndex + 1
        local rowColor = rowIndex % 2 == 0 and rowColor1 or rowColor2
        
        local dataRow = Instance.new("Frame")
        dataRow.Size = UDim2.new(1, 0, 0, 24)
        dataRow.BackgroundColor3 = rowColor
        dataRow.BorderSizePixel = 0
        dataRow.Parent = tableArea
        
        -- Create cells
        local keyCell = Instance.new("TextLabel")
        keyCell.Size = UDim2.new(columnWidth, 0, 1, 0)
        keyCell.Position = UDim2.new(0, 0, 0, 0)
        keyCell.BackgroundTransparency = 1
        keyCell.Text = tostring(key)
        keyCell.TextColor3 = textColor
        keyCell.Font = Enum.Font.SourceSans
        keyCell.TextSize = 14
        keyCell.TextXAlignment = Enum.TextXAlignment.Left
        keyCell.TextWrapped = true
        keyCell.Parent = dataRow
        
        local valueCell = Instance.new("TextLabel")
        valueCell.Size = UDim2.new(columnWidth, 0, 1, 0)
        valueCell.Position = UDim2.new(columnWidth, 0, 0, 0)
        valueCell.BackgroundTransparency = 1
        valueCell.Text = tostring(value)
        valueCell.TextColor3 = textColor
        valueCell.Font = Enum.Font.SourceSans
        valueCell.TextSize = 14
        valueCell.TextXAlignment = Enum.TextXAlignment.Left
        valueCell.TextWrapped = true
        valueCell.Parent = dataRow
    end
    
    return tableFrame
end

return DataVisualization
