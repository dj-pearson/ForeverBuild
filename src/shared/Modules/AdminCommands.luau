local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)
local ReportManager = require(ReplicatedStorage.Modules.ReportManager)

local AdminCommands = {}

-- Remote events
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local adminCommandEvent = Instance.new("RemoteEvent")
adminCommandEvent.Name = "AdminCommand"
adminCommandEvent.Parent = remotes

-- Command registry
local commands = {}

-- Register a command
function AdminCommands.registerCommand(name, description, handler)
    commands[name] = {
        description = description,
        handler = handler
    }
end

-- Execute a command
function AdminCommands.executeCommand(player, command, args)
    if not player:GetAttribute("IsAdmin") then
        return false, "You don't have permission to use admin commands"
    end
    
    local cmd = commands[command]
    if not cmd then
        return false, "Unknown command: " .. command
    end
    
    local success, result = pcall(function()
        return cmd.handler(player, args)
    end)
    
    if not success then
        return false, "Error executing command: " .. tostring(result)
    end
    
    return true, result
end

-- Register built-in commands
AdminCommands.registerCommand("help", "Shows list of available commands", function(player, args)
    local helpText = "Available commands:\n"
    for name, cmd in pairs(commands) do
        helpText = helpText .. string.format("/%s - %s\n", name, cmd.description)
    end
    return helpText
end)

AdminCommands.registerCommand("ban", "Bans a player", function(player, args)
    if #args < 1 then
        return false, "Usage: /ban <player> [reason]"
    end
    
    local targetPlayer = Players:FindFirstChild(args[1])
    if not targetPlayer then
        return false, "Player not found"
    end
    
    local reason = table.concat(args, " ", 2) or "No reason provided"
    -- Implement ban logic here
    return true, string.format("Banned %s: %s", targetPlayer.Name, reason)
end)

AdminCommands.registerCommand("kick", "Kicks a player", function(player, args)
    if #args < 1 then
        return false, "Usage: /kick <player> [reason]"
    end
    
    local targetPlayer = Players:FindFirstChild(args[1])
    if not targetPlayer then
        return false, "Player not found"
    end
    
    local reason = table.concat(args, " ", 2) or "No reason provided"
    targetPlayer:Kick(reason)
    return true, string.format("Kicked %s: %s", targetPlayer.Name, reason)
end)

AdminCommands.registerCommand("warn", "Warns a player", function(player, args)
    if #args < 1 then
        return false, "Usage: /warn <player> [reason]"
    end
    
    local targetPlayer = Players:FindFirstChild(args[1])
    if not targetPlayer then
        return false, "Player not found"
    end
    
    local reason = table.concat(args, " ", 2) or "No reason provided"
    -- Implement warning logic here
    return true, string.format("Warned %s: %s", targetPlayer.Name, reason)
end)

AdminCommands.registerCommand("remove", "Removes an object", function(player, args)
    if #args < 1 then
        return false, "Usage: /remove <objectId>"
    end
    
    local objectId = tonumber(args[1])
    if not objectId then
        return false, "Invalid object ID"
    end
    
    local report = ReportManager.getReport(objectId)
    if not report then
        return false, "Report not found"
    end
    
    if report.targetObject and report.targetObject.Parent then
        report.targetObject:Destroy()
        return true, "Object removed successfully"
    else
        return false, "Object not found"
    end
end)

AdminCommands.registerCommand("teleport", "Teleports to a player or position", function(player, args)
    if #args < 1 then
        return false, "Usage: /teleport <player> or /teleport <x> <y> <z>"
    end
    
    if #args == 1 then
        -- Teleport to player
        local targetPlayer = Players:FindFirstChild(args[1])
        if not targetPlayer then
            return false, "Player not found"
        end
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character:MoveTo(targetPlayer.Character.HumanoidRootPart.Position)
            return true, string.format("Teleported to %s", targetPlayer.Name)
        end
    else
        -- Teleport to coordinates
        local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
        if not (x and y and z) then
            return false, "Invalid coordinates"
        end
        
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character:MoveTo(Vector3.new(x, y, z))
            return true, string.format("Teleported to (%d, %d, %d)", x, y, z)
        end
    end
    
    return false, "Failed to teleport"
end)

-- Handle command events
adminCommandEvent.OnServerEvent:Connect(function(player, command, args)
    local success, result = AdminCommands.executeCommand(player, command, args)
    adminCommandEvent:FireClient(player, success, result)
end)

return AdminCommands 