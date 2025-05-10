local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Types = require(ReplicatedStorage.Shared.Types)

local SocialMediaUI = {}

-- UI Elements
local screenGui
local shareDialog
local shareButton

-- Remote events
local generateShareLinkEvent = ReplicatedStorage.Remotes.GenerateShareLink
local verifyShareEvent = ReplicatedStorage.Remotes.VerifyShare

-- Create UI
function SocialMediaUI.create()
    -- Create ScreenGui
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SocialMediaUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create share button
    shareButton = Instance.new("TextButton")
    shareButton.Name = "ShareButton"
    shareButton.Size = UDim2.new(0, 100, 0, 40)
    shareButton.Position = UDim2.new(1, -110, 0, 10)
    shareButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    shareButton.BorderSizePixel = 0
    shareButton.Text = "Share"
    shareButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    shareButton.TextSize = 16
    shareButton.Font = Enum.Font.Gotham
    shareButton.Visible = false
    shareButton.Parent = screenGui
    
    -- Set up button events
    shareButton.MouseButton1Click:Connect(function()
        SocialMediaUI.showShareDialog()
    end)
end

-- Show share dialog
function SocialMediaUI.showShareDialog(shareData)
    -- Create dialog
    shareDialog = Instance.new("Frame")
    shareDialog.Name = "ShareDialog"
    shareDialog.Size = UDim2.new(0, 400, 0, 500)
    shareDialog.Position = UDim2.new(0.5, -200, 0.5, -250)
    shareDialog.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    shareDialog.BorderSizePixel = 0
    shareDialog.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    title.BorderSizePixel = 0
    title.Text = "Share to Social Media"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = shareDialog
    
    -- Share type selection
    local typeLabel = Instance.new("TextLabel")
    typeLabel.Name = "TypeLabel"
    typeLabel.Size = UDim2.new(1, -20, 0, 30)
    typeLabel.Position = UDim2.new(0, 10, 0, 60)
    typeLabel.BackgroundTransparency = 1
    typeLabel.Text = "What would you like to share?"
    typeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    typeLabel.TextSize = 18
    typeLabel.Font = Enum.Font.Gotham
    typeLabel.TextXAlignment = Enum.TextXAlignment.Left
    typeLabel.Parent = shareDialog
    
    -- Share type buttons
    local types = {
        { name = "Showcase", type = "showcase" },
        { name = "Achievement", type = "achievement" },
        { name = "Creation", type = "creation" }
    }
    
    local y = 100
    for _, typeData in ipairs(types) do
        local button = Instance.new("TextButton")
        button.Name = typeData.type
        button.Size = UDim2.new(1, -20, 0, 40)
        button.Position = UDim2.new(0, 10, 0, y)
        button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        button.BorderSizePixel = 0
        button.Text = typeData.name
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 16
        button.Font = Enum.Font.Gotham
        button.Parent = shareDialog
        
        button.MouseButton1Click:Connect(function()
            SocialMediaUI.generateShareLink(typeData.type, shareData)
        end)
        
        y = y + 50
    end
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = shareDialog
    
    closeButton.MouseButton1Click:Connect(function()
        shareDialog:Destroy()
    end)
end

-- Generate share link
function SocialMediaUI.generateShareLink(shareType, shareData)
    local success, result = generateShareLinkEvent:InvokeServer({
        type = shareType,
        data = shareData
    })
    
    if success then
        SocialMediaUI.showShareResult(result)
    else
        SocialMediaUI.showError(result)
    end
end

-- Show share result
function SocialMediaUI.showShareResult(shareUrl)
    -- Clear existing dialog
    if shareDialog then
        shareDialog:Destroy()
    end
    
    -- Create result dialog
    local resultDialog = Instance.new("Frame")
    resultDialog.Name = "ShareResultDialog"
    resultDialog.Size = UDim2.new(0, 400, 0, 300)
    resultDialog.Position = UDim2.new(0.5, -200, 0.5, -150)
    resultDialog.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    resultDialog.BorderSizePixel = 0
    resultDialog.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    title.BorderSizePixel = 0
    title.Text = "Share Link Generated"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = resultDialog
    
    -- Share URL
    local urlLabel = Instance.new("TextLabel")
    urlLabel.Name = "UrlLabel"
    urlLabel.Size = UDim2.new(1, -20, 0, 30)
    urlLabel.Position = UDim2.new(0, 10, 0, 60)
    urlLabel.BackgroundTransparency = 1
    urlLabel.Text = "Share this link:"
    urlLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    urlLabel.TextSize = 18
    urlLabel.Font = Enum.Font.Gotham
    urlLabel.TextXAlignment = Enum.TextXAlignment.Left
    urlLabel.Parent = resultDialog
    
    local urlBox = Instance.new("TextBox")
    urlBox.Name = "UrlBox"
    urlBox.Size = UDim2.new(1, -20, 0, 40)
    urlBox.Position = UDim2.new(0, 10, 0, 100)
    urlBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    urlBox.BorderSizePixel = 0
    urlBox.Text = shareUrl
    urlBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    urlBox.TextSize = 16
    urlBox.Font = Enum.Font.Gotham
    urlBox.Parent = resultDialog
    
    -- Copy button
    local copyButton = Instance.new("TextButton")
    copyButton.Name = "CopyButton"
    copyButton.Size = UDim2.new(0, 150, 0, 40)
    copyButton.Position = UDim2.new(0.5, -75, 0, 150)
    copyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    copyButton.BorderSizePixel = 0
    copyButton.Text = "Copy Link"
    copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyButton.TextSize = 18
    copyButton.Font = Enum.Font.Gotham
    copyButton.Parent = resultDialog
    
    copyButton.MouseButton1Click:Connect(function()
        urlBox:CaptureFocus()
        urlBox.Text = shareUrl
        urlBox:ReleaseFocus()
    end)
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = resultDialog
    
    closeButton.MouseButton1Click:Connect(function()
        resultDialog:Destroy()
    end)
end

-- Show error
function SocialMediaUI.showError(message)
    -- Clear existing dialog
    if shareDialog then
        shareDialog:Destroy()
    end
    
    -- Create error dialog
    local errorDialog = Instance.new("Frame")
    errorDialog.Name = "ErrorDialog"
    errorDialog.Size = UDim2.new(0, 400, 0, 200)
    errorDialog.Position = UDim2.new(0.5, -200, 0.5, -100)
    errorDialog.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    errorDialog.BorderSizePixel = 0
    errorDialog.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    title.BorderSizePixel = 0
    title.Text = "Error"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = errorDialog
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -20, 0, 60)
    messageLabel.Position = UDim2.new(0, 10, 0, 60)
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
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = errorDialog
    
    closeButton.MouseButton1Click:Connect(function()
        errorDialog:Destroy()
    end)
end

-- Show share button
function SocialMediaUI.showShareButton()
    shareButton.Visible = true
end

-- Hide share button
function SocialMediaUI.hideShareButton()
    shareButton.Visible = false
end

-- Initialize
function SocialMediaUI.init()
    SocialMediaUI.create()
end

return SocialMediaUI 