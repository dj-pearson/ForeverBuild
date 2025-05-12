local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)
local ContentFilter = require(ReplicatedStorage.Modules.ContentFilter)

local ReportManager = {}

-- Remote events
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local reportObjectEvent = Instance.new("RemoteEvent")
reportObjectEvent.Name = "ReportObject"
reportObjectEvent.Parent = remotes

local reportResponseEvent = Instance.new("RemoteEvent")
reportResponseEvent.Name = "ReportResponse"
reportResponseEvent.Parent = remotes

-- Report types
local REPORT_TYPES = {
    INAPPROPRIATE_CONTENT = "Inappropriate Content",
    HARASSMENT = "Harassment",
    EXPLOITATION = "Exploitation",
    OTHER = "Other"
}

-- Active reports
local activeReports = {}

-- Create report
function ReportManager.createReport(reporter, targetObject, reportType, description)
    local reportId = #activeReports + 1
    
    local report = {
        id = reportId,
        reporter = reporter,
        targetObject = targetObject,
        reportType = reportType,
        description = ContentFilter.filterText(description),
        timestamp = os.time(),
        status = "pending",
        reviewedBy = nil
    }
    
    table.insert(activeReports, report)
    
    -- Notify admins
    for _, player in ipairs(Players:GetPlayers()) do
        if player:GetAttribute("IsAdmin") then
            reportObjectEvent:FireClient(player, report)
        end
    end
    
    return reportId
end

-- Handle report submission
reportObjectEvent.OnServerEvent:Connect(function(player, targetObject, reportType, description)
    -- Validate report type
    if not REPORT_TYPES[reportType] then
        reportResponseEvent:FireClient(player, false, "Invalid report type")
        return
    end
    
    -- Create report
    local reportId = ReportManager.createReport(player, targetObject, reportType, description)
    
    -- Notify reporter
    reportResponseEvent:FireClient(player, true, "Report submitted successfully")
end)

-- Review report
function ReportManager.reviewReport(reportId, admin, action, notes)
    local report = activeReports[reportId]
    if not report then return false, "Report not found" end
    
    report.status = action
    report.reviewedBy = admin
    report.reviewNotes = notes
    report.reviewTimestamp = os.time()
    
    -- Handle the reported object based on action
    if action == "remove" then
        -- Remove the object
        if report.targetObject and report.targetObject.Parent then
            report.targetObject:Destroy()
        end
    elseif action == "warn" then
        -- Send warning to object owner
        local owner = report.targetObject:GetAttribute("Owner")
        if owner then
            local ownerPlayer = Players:GetPlayerByUserId(owner)
            if ownerPlayer then
                reportResponseEvent:FireClient(ownerPlayer, false, "Warning: Your object has been reported and requires review")
            end
        end
    end
    
    -- Notify reporter
    if report.reporter and report.reporter.Parent then
        reportResponseEvent:FireClient(report.reporter, true, "Your report has been reviewed")
    end
    
    return true, "Report reviewed successfully"
end

-- Get active reports
function ReportManager.getActiveReports()
    return activeReports
end

-- Get report by ID
function ReportManager.getReport(reportId)
    return activeReports[reportId]
end

return ReportManager 