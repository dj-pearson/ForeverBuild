local Constants = {
    RemoteEvents = {
        ReportObject = "ReportObject",
        AdminCommand = "AdminCommand",
        CompleteTutorial = "CompleteTutorial",
        ReportResponse = "ReportResponse"
    },
    
    RemoteFunctions = {
        GetTutorialStatus = "GetTutorialStatus"
    },
    
    DataStoreNames = {
        PlayerData = "PlayerData",
        WorldObjects = "WorldObjects",
        PlayerDataBackup = "PlayerDataBackup"
    },
    
    DataVersions = {
        PlayerData = 1,
        WorldObjects = 1
    },
    
    RetrySettings = {
        MaxRetries = 3,
        RetryDelay = 1,
        BackupInterval = 300 -- 5 minutes
    }
}

return Constants 