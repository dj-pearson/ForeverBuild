local Types = {
    PlayerData = {
        tutorialComplete = "boolean",
        lastLogin = "number",
        settings = {
            musicVolume = "number",
            sfxVolume = "number",
            sensitivity = "number"
        }
    },
    
    TutorialState = {
        NOT_STARTED = "not_started",
        IN_PROGRESS = "in_progress",
        COMPLETED = "completed"
    },
    
    UserRole = {
        ADMIN = "ADMIN",
        MODERATOR = "MODERATOR",
        USER = "USER"
    }
}

return Types 