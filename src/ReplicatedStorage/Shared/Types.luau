local Types = {
    -- Report Types
    REPORT_TYPES = {
        "Inappropriate Content",
        "Harassment",
        "Exploitation",
        "Other"
    },
    
    -- Command Types
    COMMAND_TYPES = {
        "help",
        "ban",
        "kick",
        "warn",
        "remove",
        "teleport"
    },
    
    -- Admin Action Types
    ADMIN_ACTIONS = {
        "Remove Object",
        "Warn Player",
        "Kick Player",
        "Ban Player"
    }
}

-- Object Types
export type PlacedObject = {
    id: string,
    objectType: string,
    position: Vector3,
    rotation: Vector3,
    owner: number, -- UserId
    purchaseTime: number,
    price: number
}

export type InventoryItem = {
    id: string,
    objectType: string,
    purchaseTime: number,
    price: number
}

export type PlayerData = {
    userId: number,
    inventory: {InventoryItem},
    robux: number,
    lastLogin: number
}

export type MarketplaceItem = {
    id: string,
    name: string,
    description: string,
    price: number,
    objectType: string,
    previewImage: string
}

return Types 