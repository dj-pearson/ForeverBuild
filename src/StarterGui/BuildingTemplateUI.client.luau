local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local BuildingTemplateUI = {}

-- UI Elements
local screenGui
local templatesFrame
local saveTemplateButton
local loadTemplateButton
local shareTemplateButton
local likeTemplateButton
local commentTemplateButton
local templateList
local templateDetails
local commentList
local commentInput

-- Remote events
local saveTemplateEvent = ReplicatedStorage.Remotes.SaveTemplate
local loadTemplateEvent = ReplicatedStorage.Remotes.LoadTemplate
local shareTemplateEvent = ReplicatedStorage.Remotes.ShareTemplate
local likeTemplateEvent = ReplicatedStorage.Remotes.LikeTemplate
local commentTemplateEvent = ReplicatedStorage.Remotes.CommentTemplate
local getTemplatesEvent = ReplicatedStorage.Remotes.GetTemplates
local getFeaturedTemplatesEvent = ReplicatedStorage.Remotes.GetFeaturedTemplates

-- Create UI
function BuildingTemplateUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BuildingTemplateUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create templates frame
    templatesFrame = Instance.new("Frame")
    templatesFrame.Name = "TemplatesFrame"
    templatesFrame.Size = UDim2.new(0, 400, 0, 600)
    templatesFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
    templatesFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    templatesFrame.BorderSizePixel = 0
    templatesFrame.Visible = false
    templatesFrame.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    title.BorderSizePixel = 0
    title.Text = "Building Templates"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = templatesFrame
    
    -- Create buttons
    local buttonHeight = 40
    local buttonSpacing = 10
    local y = 50
    
    -- Save template button
    saveTemplateButton = BuildingTemplateUI.createButton("Save Template", y)
    saveTemplateButton.Parent = templatesFrame
    y = y + buttonHeight + buttonSpacing
    
    -- Load template button
    loadTemplateButton = BuildingTemplateUI.createButton("Load Template", y)
    loadTemplateButton.Parent = templatesFrame
    y = y + buttonHeight + buttonSpacing
    
    -- Share template button
    shareTemplateButton = BuildingTemplateUI.createButton("Share Template", y)
    shareTemplateButton.Parent = templatesFrame
    y = y + buttonHeight + buttonSpacing
    
    -- Like template button
    likeTemplateButton = BuildingTemplateUI.createButton("Like Template", y)
    likeTemplateButton.Parent = templatesFrame
    y = y + buttonHeight + buttonSpacing
    
    -- Comment template button
    commentTemplateButton = BuildingTemplateUI.createButton("Comment", y)
    commentTemplateButton.Parent = templatesFrame
    y = y + buttonHeight + buttonSpacing
    
    -- Template list
    templateList = Instance.new("ScrollingFrame")
    templateList.Name = "TemplateList"
    templateList.Size = UDim2.new(0.5, -20, 0, 400)
    templateList.Position = UDim2.new(0, 10, 0, y)
    templateList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    templateList.BorderSizePixel = 0
    templateList.ScrollBarThickness = 6
    templateList.Parent = templatesFrame
    
    -- Template details
    templateDetails = Instance.new("Frame")
    templateDetails.Name = "TemplateDetails"
    templateDetails.Size = UDim2.new(0.5, -20, 0, 400)
    templateDetails.Position = UDim2.new(0.5, 10, 0, y)
    templateDetails.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    templateDetails.BorderSizePixel = 0
    templateDetails.Parent = templatesFrame
    
    -- Comment list
    commentList = Instance.new("ScrollingFrame")
    commentList.Name = "CommentList"
    commentList.Size = UDim2.new(1, -20, 0, 200)
    commentList.Position = UDim2.new(0, 10, 0, y + 410)
    commentList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    commentList.BorderSizePixel = 0
    commentList.ScrollBarThickness = 6
    commentList.Parent = templatesFrame
    
    -- Comment input
    commentInput = Instance.new("TextBox")
    commentInput.Name = "CommentInput"
    commentInput.Size = UDim2.new(1, -20, 0, 40)
    commentInput.Position = UDim2.new(0, 10, 0, y + 620)
    commentInput.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    commentInput.BorderSizePixel = 0
    commentInput.Text = ""
    commentInput.PlaceholderText = "Add a comment..."
    commentInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    commentInput.TextSize = 16
    commentInput.Font = Enum.Font.Gotham
    commentInput.Parent = templatesFrame
    
    -- Set up button events
    saveTemplateButton.MouseButton1Click:Connect(function()
        BuildingTemplateUI.showSaveTemplateDialog()
    end)
    
    loadTemplateButton.MouseButton1Click:Connect(function()
        BuildingTemplateUI.showLoadTemplateDialog()
    end)
    
    shareTemplateButton.MouseButton1Click:Connect(function()
        BuildingTemplateUI.shareTemplate()
    end)
    
    likeTemplateButton.MouseButton1Click:Connect(function()
        BuildingTemplateUI.likeTemplate()
    end)
    
    commentTemplateButton.MouseButton1Click:Connect(function()
        BuildingTemplateUI.commentTemplate()
    end)
    
    -- Set up keyboard shortcuts
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.S and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            BuildingTemplateUI.showSaveTemplateDialog()
        elseif input.KeyCode == Enum.KeyCode.O and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            BuildingTemplateUI.showLoadTemplateDialog()
        end
    end)
end

-- Create button
function BuildingTemplateUI.createButton(text, y)
    local button = Instance.new("TextButton")
    button.Name = text .. "Button"
    button.Size = UDim2.new(1, -20, 0, 40)
    button.Position = UDim2.new(0, 10, 0, y)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.Font = Enum.Font.Gotham
    
    return button
end

-- Show save template dialog
function BuildingTemplateUI.showSaveTemplateDialog()
    -- Create dialog
    local dialog = Instance.new("Frame")
    dialog.Name = "SaveTemplateDialog"
    dialog.Size = UDim2.new(0, 300, 0, 200)
    dialog.Position = UDim2.new(0.5, -150, 0.5, -100)
    dialog.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    dialog.BorderSizePixel = 0
    dialog.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    title.BorderSizePixel = 0
    title.Text = "Save Template"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = dialog
    
    -- Name input
    local nameInput = Instance.new("TextBox")
    nameInput.Name = "NameInput"
    nameInput.Size = UDim2.new(1, -20, 0, 30)
    nameInput.Position = UDim2.new(0, 10, 0, 50)
    nameInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    nameInput.BorderSizePixel = 0
    nameInput.Text = ""
    nameInput.PlaceholderText = "Template name"
    nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameInput.TextSize = 16
    nameInput.Font = Enum.Font.Gotham
    nameInput.Parent = dialog
    
    -- Description input
    local descriptionInput = Instance.new("TextBox")
    descriptionInput.Name = "DescriptionInput"
    descriptionInput.Size = UDim2.new(1, -20, 0, 60)
    descriptionInput.Position = UDim2.new(0, 10, 0, 90)
    descriptionInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    descriptionInput.BorderSizePixel = 0
    descriptionInput.Text = ""
    descriptionInput.PlaceholderText = "Template description"
    descriptionInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    descriptionInput.TextSize = 16
    descriptionInput.Font = Enum.Font.Gotham
    descriptionInput.MultiLine = true
    descriptionInput.Parent = dialog
    
    -- Save button
    local saveButton = Instance.new("TextButton")
    saveButton.Name = "SaveButton"
    saveButton.Size = UDim2.new(0, 100, 0, 30)
    saveButton.Position = UDim2.new(0.5, -50, 1, -40)
    saveButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    saveButton.BorderSizePixel = 0
    saveButton.Text = "Save"
    saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveButton.TextSize = 16
    saveButton.Font = Enum.Font.Gotham
    saveButton.Parent = dialog
    
    -- Cancel button
    local cancelButton = Instance.new("TextButton")
    cancelButton.Name = "CancelButton"
    cancelButton.Size = UDim2.new(0, 100, 0, 30)
    cancelButton.Position = UDim2.new(0.5, 50, 1, -40)
    cancelButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    cancelButton.BorderSizePixel = 0
    cancelButton.Text = "Cancel"
    cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelButton.TextSize = 16
    cancelButton.Font = Enum.Font.Gotham
    cancelButton.Parent = dialog
    
    -- Set up button events
    saveButton.MouseButton1Click:Connect(function()
        local name = nameInput.Text
        local description = descriptionInput.Text
        
        if name == "" or description == "" then
            BuildingTemplateUI.showError("Please fill in all fields")
            return
        end
        
        local success, message = saveTemplateEvent:InvokeServer(name, description, BuildingTemplateUI.getSelectedObjects())
        if success then
            BuildingTemplateUI.showNotification("Template saved")
            dialog:Destroy()
            BuildingTemplateUI.refreshTemplates()
        else
            BuildingTemplateUI.showError(message)
        end
    end)
    
    cancelButton.MouseButton1Click:Connect(function()
        dialog:Destroy()
    end)
end

-- Show load template dialog
function BuildingTemplateUI.showLoadTemplateDialog()
    -- Create dialog
    local dialog = Instance.new("Frame")
    dialog.Name = "LoadTemplateDialog"
    dialog.Size = UDim2.new(0, 300, 0, 400)
    dialog.Position = UDim2.new(0.5, -150, 0.5, -200)
    dialog.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    dialog.BorderSizePixel = 0
    dialog.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    title.BorderSizePixel = 0
    title.Text = "Load Template"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = dialog
    
    -- Template list
    local templateList = Instance.new("ScrollingFrame")
    templateList.Name = "TemplateList"
    templateList.Size = UDim2.new(1, -20, 0, 300)
    templateList.Position = UDim2.new(0, 10, 0, 50)
    templateList.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    templateList.BorderSizePixel = 0
    templateList.ScrollBarThickness = 6
    templateList.Parent = dialog
    
    -- Load button
    local loadButton = Instance.new("TextButton")
    loadButton.Name = "LoadButton"
    loadButton.Size = UDim2.new(0, 100, 0, 30)
    loadButton.Position = UDim2.new(0.5, -50, 1, -40)
    loadButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    loadButton.BorderSizePixel = 0
    loadButton.Text = "Load"
    loadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadButton.TextSize = 16
    loadButton.Font = Enum.Font.Gotham
    loadButton.Parent = dialog
    
    -- Cancel button
    local cancelButton = Instance.new("TextButton")
    cancelButton.Name = "CancelButton"
    cancelButton.Size = UDim2.new(0, 100, 0, 30)
    cancelButton.Position = UDim2.new(0.5, 50, 1, -40)
    cancelButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    cancelButton.BorderSizePixel = 0
    cancelButton.Text = "Cancel"
    cancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelButton.TextSize = 16
    cancelButton.Font = Enum.Font.Gotham
    cancelButton.Parent = dialog
    
    -- Set up button events
    loadButton.MouseButton1Click:Connect(function()
        local selectedTemplate = BuildingTemplateUI.getSelectedTemplate()
        if not selectedTemplate then
            BuildingTemplateUI.showError("Please select a template")
            return
        end
        
        local success, message = loadTemplateEvent:InvokeServer(selectedTemplate.id)
        if success then
            BuildingTemplateUI.showNotification("Template loaded")
            dialog:Destroy()
        else
            BuildingTemplateUI.showError(message)
        end
    end)
    
    cancelButton.MouseButton1Click:Connect(function()
        dialog:Destroy()
    end)
    
    -- Load templates
    BuildingTemplateUI.loadTemplates(templateList)
end

-- Share template
function BuildingTemplateUI.shareTemplate()
    local selectedTemplate = BuildingTemplateUI.getSelectedTemplate()
    if not selectedTemplate then
        BuildingTemplateUI.showError("Please select a template")
        return
    end
    
    local success, shareLink = shareTemplateEvent:InvokeServer(selectedTemplate.id)
    if success then
        BuildingTemplateUI.showNotification("Share link copied to clipboard")
        -- TODO: Copy to clipboard
    else
        BuildingTemplateUI.showError(shareLink)
    end
end

-- Like template
function BuildingTemplateUI.likeTemplate()
    local selectedTemplate = BuildingTemplateUI.getSelectedTemplate()
    if not selectedTemplate then
        BuildingTemplateUI.showError("Please select a template")
        return
    end
    
    local success, message = likeTemplateEvent:InvokeServer(selectedTemplate.id)
    if success then
        BuildingTemplateUI.showNotification("Template liked")
        BuildingTemplateUI.refreshTemplates()
    else
        BuildingTemplateUI.showError(message)
    end
end

-- Comment template
function BuildingTemplateUI.commentTemplate()
    local selectedTemplate = BuildingTemplateUI.getSelectedTemplate()
    if not selectedTemplate then
        BuildingTemplateUI.showError("Please select a template")
        return
    end
    
    local comment = commentInput.Text
    if comment == "" then
        BuildingTemplateUI.showError("Please enter a comment")
        return
    end
    
    local success, message = commentTemplateEvent:InvokeServer(selectedTemplate.id, comment)
    if success then
        BuildingTemplateUI.showNotification("Comment added")
        commentInput.Text = ""
        BuildingTemplateUI.refreshTemplates()
    else
        BuildingTemplateUI.showError(message)
    end
end

-- Get selected objects
function BuildingTemplateUI.getSelectedObjects()
    -- TODO: Implement getting selected objects
    -- This could include:
    -- - Getting objects from BuildingToolsManager
    -- - Converting objects to data format
    return {}
end

-- Get selected template
function BuildingTemplateUI.getSelectedTemplate()
    -- TODO: Implement getting selected template
    -- This could include:
    -- - Getting selected template from list
    -- - Validating selection
    return nil
end

-- Load templates
function BuildingTemplateUI.loadTemplates(templateList)
    local success, templates = getTemplatesEvent:InvokeServer()
    if success then
        -- Clear list
        for _, child in ipairs(templateList:GetChildren()) do
            child:Destroy()
        end
        
        -- Add templates
        local y = 0
        for _, template in pairs(templates.playerTemplates) do
            local templateButton = BuildingTemplateUI.createTemplateButton(template, y)
            templateButton.Parent = templateList
            y = y + 50
        end
        
        for _, template in pairs(templates.sharedTemplates) do
            local templateButton = BuildingTemplateUI.createTemplateButton(template, y)
            templateButton.Parent = templateList
            y = y + 50
        end
    end
end

-- Create template button
function BuildingTemplateUI.createTemplateButton(template, y)
    local button = Instance.new("TextButton")
    button.Name = template.id
    button.Size = UDim2.new(1, 0, 0, 40)
    button.Position = UDim2.new(0, 0, 0, y)
    button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    button.BorderSizePixel = 0
    button.Text = template.name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.Font = Enum.Font.Gotham
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.TextWrapped = true
    
    -- Add padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.Parent = button
    
    return button
end

-- Refresh templates
function BuildingTemplateUI.refreshTemplates()
    BuildingTemplateUI.loadTemplates(templateList)
end

-- Show notification
function BuildingTemplateUI.showNotification(message)
    -- Create notification
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 200, 0, 40)
    notification.Position = UDim2.new(0.5, -100, 0.1, 0)
    notification.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    notification.BorderSizePixel = 0
    notification.Parent = screenGui
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, 0, 1, 0)
    messageLabel.Position = UDim2.new(0, 0, 0, 0)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextSize = 16
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.Parent = notification
    
    -- Animate notification
    notification.BackgroundTransparency = 1
    messageLabel.TextTransparency = 1
    
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    local showTween = game:GetService("TweenService"):Create(notification, tweenInfo, {
        BackgroundTransparency = 0
    })
    
    local showTextTween = game:GetService("TweenService"):Create(messageLabel, tweenInfo, {
        TextTransparency = 0
    })
    
    showTween:Play()
    showTextTween:Play()
    
    -- Hide notification after delay
    task.delay(2, function()
        local hideTween = game:GetService("TweenService"):Create(notification, tweenInfo, {
            BackgroundTransparency = 1
        })
        
        local hideTextTween = game:GetService("TweenService"):Create(messageLabel, tweenInfo, {
            TextTransparency = 1
        })
        
        hideTween:Play()
        hideTextTween:Play()
        
        hideTween.Completed:Connect(function()
            notification:Destroy()
        end)
    end)
end

-- Show error
function BuildingTemplateUI.showError(message)
    -- Create error dialog
    local errorDialog = Instance.new("Frame")
    errorDialog.Name = "ErrorDialog"
    errorDialog.Size = UDim2.new(0, 300, 0, 150)
    errorDialog.Position = UDim2.new(0.5, -150, 0.5, -75)
    errorDialog.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    errorDialog.BorderSizePixel = 0
    errorDialog.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    title.BorderSizePixel = 0
    title.Text = "Error"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = errorDialog
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -20, 0, 60)
    messageLabel.Position = UDim2.new(0, 10, 0, 50)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    messageLabel.TextSize = 16
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextWrapped = true
    messageLabel.Parent = errorDialog
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 100, 0, 30)
    closeButton.Position = UDim2.new(0.5, -50, 1, -40)
    closeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "Close"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.Gotham
    closeButton.Parent = errorDialog
    
    closeButton.MouseButton1Click:Connect(function()
        errorDialog:Destroy()
    end)
end

-- Show templates
function BuildingTemplateUI.showTemplates()
    templatesFrame.Visible = true
    BuildingTemplateUI.refreshTemplates()
end

-- Hide templates
function BuildingTemplateUI.hideTemplates()
    templatesFrame.Visible = false
end

-- Initialize
function BuildingTemplateUI.init()
    BuildingTemplateUI.create()
end

return BuildingTemplateUI 