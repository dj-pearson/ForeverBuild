local Types = require(script.Parent.Types)
type UIComponent = Types.UIComponent

--[[
    ErrorBoundary
    A component that catches and handles errors in UI components.
    
    @class ErrorBoundary
    @implements UIComponent
]]

local ErrorBoundary = {}
ErrorBoundary.__index = ErrorBoundary

-- Create a new ErrorBoundary instance
function ErrorBoundary.new(component: UIComponent, fallbackUI: UIComponent)
    local self = setmetatable({
        component = component,
        fallbackUI = fallbackUI,
        hasError = false,
        error = nil,
    }, ErrorBoundary)
    return self
end

-- Initialize the error boundary
function ErrorBoundary:init()
    if self.component and self.component.init then
        local success, err = pcall(function()
            self.component:init()
        end)
        
        if not success then
            self.hasError = true
            self.error = err
            if self.fallbackUI and self.fallbackUI.init then
                self.fallbackUI:init()
            end
        end
    end
end

-- Show the component or fallback UI
function ErrorBoundary:show()
    if self.hasError then
        if self.fallbackUI and self.fallbackUI.show then
            self.fallbackUI:show()
        end
    else
        if self.component and self.component.show then
            local success, err = pcall(function()
                self.component:show()
            end)
            
            if not success then
                self.hasError = true
                self.error = err
                if self.fallbackUI and self.fallbackUI.show then
                    self.fallbackUI:show()
                end
            end
        end
    end
end

-- Hide the component or fallback UI
function ErrorBoundary:hide()
    if self.hasError then
        if self.fallbackUI and self.fallbackUI.hide then
            self.fallbackUI:hide()
        end
    else
        if self.component and self.component.hide then
            local success, err = pcall(function()
                self.component:hide()
            end)
            
            if not success then
                self.hasError = true
                self.error = err
                if self.fallbackUI and self.fallbackUI.hide then
                    self.fallbackUI:hide()
                end
            end
        end
    end
end

-- Update the component or fallback UI
function ErrorBoundary:update(data: {[string]: any})
    if self.hasError then
        if self.fallbackUI and self.fallbackUI.update then
            self.fallbackUI:update(data)
        end
    else
        if self.component and self.component.update then
            local success, err = pcall(function()
                self.component:update(data)
            end)
            
            if not success then
                self.hasError = true
                self.error = err
                if self.fallbackUI and self.fallbackUI.update then
                    self.fallbackUI:update(data)
                end
            end
        end
    end
end

-- Destroy the component and fallback UI
function ErrorBoundary:destroy()
    if self.component and self.component.destroy then
        pcall(function()
            self.component:destroy()
        end)
    end
    
    if self.fallbackUI and self.fallbackUI.destroy then
        pcall(function()
            self.fallbackUI:destroy()
        end)
    end
end

-- Get the current error state
function ErrorBoundary:getError(): string?
    return self.error
end

-- Reset the error boundary
function ErrorBoundary:reset()
    self.hasError = false
    self.error = nil
end

return ErrorBoundary 