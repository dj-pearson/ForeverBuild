local Types = require(script.Parent.Types)
type State<T> = Types.State<T>
type Store = Types.Store

--[[
    StateManager
    A simple state management system for handling global state in the game.
    
    @class StateManager
    @implements Store
]]

local StateManager = {}
StateManager.__index = StateManager

-- Create a new state instance
local function createState<T>(initialValue: T): State<T>
    local state = {
        value = initialValue,
        subscribers = {},
    }
    
    function state:get(): T
        return self.value
    end
    
    function state:set(newValue: T)
        if self.value ~= newValue then
            self.value = newValue
            for _, callback in self.subscribers do
                task.spawn(callback, newValue)
            end
        end
    end
    
    function state:subscribe(callback: (newValue: T) -> ()): () -> ()
        local id = tostring(os.clock())
        self.subscribers[id] = callback
        return function()
            self.subscribers[id] = nil
        end
    end
    
    function state:unsubscribe(callback: (newValue: T) -> ())
        for id, cb in self.subscribers do
            if cb == callback then
                self.subscribers[id] = nil
                break
            end
        end
    end
    
    return state
end

-- Create a new StateManager instance
function StateManager.new(): Store
    local self = setmetatable({
        states = {},
    }, StateManager)
    return self
end

-- Get state value
function StateManager:getState(key: string): any
    local state = self.states[key]
    return state and state:get() or nil
end

-- Set state value
function StateManager:setState(key: string, value: any)
    if not self.states[key] then
        self.states[key] = createState(value)
    else
        self.states[key]:set(value)
    end
end

-- Subscribe to state changes
function StateManager:subscribe(key: string, callback: (newValue: any) -> ()): () -> ()
    if not self.states[key] then
        self.states[key] = createState(nil)
    end
    return self.states[key]:subscribe(callback)
end

-- Unsubscribe from state changes
function StateManager:unsubscribe(key: string, callback: (newValue: any) -> ())
    local state = self.states[key]
    if state then
        state:unsubscribe(callback)
    end
end

return StateManager.new() 