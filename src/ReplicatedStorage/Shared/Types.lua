local Types = {}

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