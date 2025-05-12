--[[
    State Type Definition
    Defines the structure and behavior of the state management system.
    
    @class State
    @type {[string]: any}
]]

export type State<T> = {
    -- Core State Properties
    value: T,
    subscribers: {[string]: (newValue: T) -> ()},
    
    -- State Methods
    get: (self: State<T>) -> T,
    set: (self: State<T>, newValue: T) -> (),
    subscribe: (self: State<T>, callback: (newValue: T) -> ()) -> () -> (),
    unsubscribe: (self: State<T>, callback: (newValue: T) -> ()) -> (),
}

--[[
    Store Type Definition
    Defines the structure and behavior of the global state store.
    
    @class Store
    @type {[string]: State<any>}
]]

export type Store = {
    -- Store Methods
    getState: (self: Store, key: string) -> any,
    setState: (self: Store, key: string, value: any) -> (),
    subscribe: (self: Store, key: string, callback: (newValue: any) -> ()) -> () -> (),
    unsubscribe: (self: Store, key: string, callback: (newValue: any) -> ()) -> (),
}

return nil 