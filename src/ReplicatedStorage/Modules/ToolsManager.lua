local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local ToolsManager = {}

-- Tool configurations
local TOOL_CONFIGS = {
    SPRING_JUMP = {
        name = "Spring Jump",
        cooldown = 3,
        jumpPower = 50,
        model = function()
            local tool = Instance.new("Tool")
            tool.Name = "SpringJump"
            
            -- Handle
            local handle = Instance.new("Part")
            handle.Name = "Handle"
            handle.Size = Vector3.new(1, 4, 1)
            handle.Material = Enum.Material.Metal
            handle.Color = Color3.fromRGB(200, 200, 200)
            handle.Parent = tool
            
            -- Spring
            local spring = Instance.new("Part")
            spring.Name = "Spring"
            spring.Size = Vector3.new(0.5, 2, 0.5)
            spring.Material = Enum.Material.Metal
            spring.Color = Color3.fromRGB(150, 150, 150)
            spring.Position = handle.Position + Vector3.new(0, 3, 0)
            spring.Parent = handle
            
            return tool
        end
    },
    
    MAGIC_CARPET = {
        name = "Magic Carpet",
        cooldown = 0,
        speed = 30,
        model = function()
            local tool = Instance.new("Tool")
            tool.Name = "MagicCarpet"
            
            -- Carpet
            local carpet = Instance.new("Part")
            carpet.Name = "Handle"
            carpet.Size = Vector3.new(4, 0.2, 6)
            carpet.Material = Enum.Material.Fabric
            carpet.Color = Color3.fromRGB(255, 215, 0)
            carpet.Parent = tool
            
            -- Tassels
            for i = 1, 4 do
                local tassel = Instance.new("Part")
                tassel.Size = Vector3.new(0.2, 1, 0.2)
                tassel.Material = Enum.Material.Fabric
                tassel.Color = Color3.fromRGB(255, 215, 0)
                tassel.Position = carpet.Position + Vector3.new(
                    (i <= 2 and -1.8 or 1.8),
                    -0.6,
                    (i % 2 == 0 and 2.8 or -2.8)
                )
                tassel.Parent = carpet
            end
            
            return tool
        end
    },
    
    CAR = {
        name = "Sports Car",
        cooldown = 0,
        speed = 40,
        model = function()
            local tool = Instance.new("Tool")
            tool.Name = "Car"
            
            -- Car body
            local body = Instance.new("Part")
            body.Name = "Handle"
            body.Size = Vector3.new(6, 2, 3)
            body.Material = Enum.Material.Metal
            body.Color = Color3.fromRGB(255, 0, 0)
            body.Parent = tool
            
            -- Wheels
            local wheelPositions = {
                Vector3.new(-2, -1, 1.5),
                Vector3.new(2, -1, 1.5),
                Vector3.new(-2, -1, -1.5),
                Vector3.new(2, -1, -1.5)
            }
            
            for _, pos in ipairs(wheelPositions) do
                local wheel = Instance.new("Part")
                wheel.Size = Vector3.new(1, 1, 0.5)
                wheel.Material = Enum.Material.Rubber
                wheel.Color = Color3.fromRGB(20, 20, 20)
                wheel.Position = body.Position + pos
                wheel.Parent = body
            end
            
            -- Windshield
            local windshield = Instance.new("Part")
            windshield.Size = Vector3.new(4, 1.5, 0.1)
            windshield.Material = Enum.Material.Glass
            windshield.Transparency = 0.5
            windshield.Position = body.Position + Vector3.new(0, 1, 1.5)
            windshield.Parent = body
            
            return tool
        end
    }
}

-- Create tool
function ToolsManager.createTool(toolType)
    local config = TOOL_CONFIGS[toolType]
    if not config then
        warn("No configuration found for tool type:", toolType)
        return nil
    end
    
    return config.model()
end

-- Apply tool effects
function ToolsManager.applyToolEffect(player, toolType)
    local config = TOOL_CONFIGS[toolType]
    if not config then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if toolType == "SPRING_JUMP" then
        -- Apply spring jump effect
        humanoid.JumpPower = config.jumpPower
        task.delay(config.cooldown, function()
            humanoid.JumpPower = 50 -- Reset to default
        end)
    elseif toolType == "MAGIC_CARPET" then
        -- Apply magic carpet effect
        local tool = character:FindFirstChild("MagicCarpet")
        if tool then
            local handle = tool:FindFirstChild("Handle")
            if handle then
                -- Make the carpet float
                handle.CanCollide = false
                handle.Anchored = false
                
                -- Apply hover effect
                local bodyForce = Instance.new("BodyForce")
                bodyForce.Force = Vector3.new(0, handle:GetMass() * 196.2, 0) -- Counter gravity
                bodyForce.Parent = handle
                
                -- Apply movement
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                bodyVelocity.P = 1e5
                bodyVelocity.Parent = handle
                
                -- Clean up when tool is unequipped
                tool.Unequipped:Connect(function()
                    bodyForce:Destroy()
                    bodyVelocity:Destroy()
                    handle.CanCollide = true
                end)
            end
        end
    elseif toolType == "CAR" then
        -- Apply car effect
        local tool = character:FindFirstChild("Car")
        if tool then
            local handle = tool:FindFirstChild("Handle")
            if handle then
                -- Make the car drivable
                handle.CanCollide = true
                handle.Anchored = false
                
                -- Apply car physics
                local bodyForce = Instance.new("BodyForce")
                bodyForce.Force = Vector3.new(0, handle:GetMass() * 196.2, 0) -- Counter gravity
                bodyForce.Parent = handle
                
                -- Apply movement
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                bodyVelocity.P = 1e5
                bodyVelocity.Parent = handle
                
                -- Clean up when tool is unequipped
                tool.Unequipped:Connect(function()
                    bodyForce:Destroy()
                    bodyVelocity:Destroy()
                end)
            end
        end
    end
end

-- Get available tools
function ToolsManager.getAvailableTools()
    local tools = {}
    for toolType, config in pairs(TOOL_CONFIGS) do
        table.insert(tools, {
            type = toolType,
            name = config.name,
            cooldown = config.cooldown
        })
    end
    return tools
end

return ToolsManager 