--[[
    UIComponent Type Definition
    Defines the structure and behavior of UI components in the game.
    
    @class UIComponent
    @type {[string]: any}
]]

export type UIComponent = {
    -- Core UI Component Properties
    Name: string,
    Visible: boolean,
    Enabled: boolean,
    
    -- UI Component Methods
    init: (self: UIComponent) -> (),
    show: (self: UIComponent) -> (),
    hide: (self: UIComponent) -> (),
    enable: (self: UIComponent) -> (),
    disable: (self: UIComponent) -> (),
    update: (self: UIComponent, data: {[string]: any}) -> (),
    destroy: (self: UIComponent) -> (),
    
    -- Event Handlers
    onShow: (self: UIComponent) -> (),
    onHide: (self: UIComponent) -> (),
    onEnable: (self: UIComponent) -> (),
    onDisable: (self: UIComponent) -> (),
    onUpdate: (self: UIComponent, data: {[string]: any}) -> (),
    onDestroy: (self: UIComponent) -> (),
}

return nil 