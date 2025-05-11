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
        PlayerBackup = "PlayerBackup"
    },
    
    DataVersions = {
        PlayerData = 1
    },
    
    RetrySettings = {
        MaxRetries = 3,
        InitialDelay = 1,
        MaxDelay = 5
    }
}

return Constants 