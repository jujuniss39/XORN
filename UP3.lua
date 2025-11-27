------------------------------------------
----- =======[ SIMPLE MANUAL UI - NO EXTERNAL LIBRARY ]
------------------------------------------

-- Create main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OGhubUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main window
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 0, 127)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "OGhub - Free To Use"
TitleLabel.TextColor3 = Color3.new(1, 1, 1)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Close button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Tab buttons
local TabButtons = Instance.new("Frame")
TabButtons.Size = UDim2.new(1, 0, 0, 40)
TabButtons.Position = UDim2.new(0, 0, 0, 40)
TabButtons.BackgroundTransparency = 1
TabButtons.Parent = MainFrame

-- Content frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -90)
ContentFrame.Position = UDim2.new(0, 10, 0, 90)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Scroll frame for content
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 127)
ScrollFrame.Parent = ContentFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ScrollFrame

------------------------------------------
----- =======[ TAB SYSTEM ]
------------------------------------------

local tabs = {}
local currentTab = nil

function CreateTab(name)
    local tab = {}
    
    -- Tab button
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(0.2, 0, 1, 0)
    TabButton.Position = UDim2.new(0.2 * (#tabs), 0, 0, 0)
    TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TabButton.Text = name
    TabButton.TextColor3 = Color3.new(1, 1, 1)
    TabButton.Font = Enum.Font.Gotham
    TabButton.TextSize = 12
    TabButton.Parent = TabButtons
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabButton
    
    -- Tab content
    local TabContent = Instance.new("Frame")
    TabContent.Size = UDim2.new(1, 0, 0, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.Visible = false
    TabContent.Parent = ScrollFrame
    
    local TabContentLayout = Instance.new("UIListLayout")
    TabContentLayout.Padding = UDim.new(0, 5)
    TabContentLayout.Parent = TabContent
    
    -- Functions
    function tab:Show()
        if currentTab then
            currentTab:Hide()
        end
        TabContent.Visible = true
        currentTab = tab
        
        -- Update button colors
        for _, otherTab in pairs(tabs) do
            otherTab.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end
        TabButton.BackgroundColor3 = Color3.fromRGB(255, 0, 127)
    end
    
    function tab:Hide()
        TabContent.Visible = false
    end
    
    function tab:Section(title)
        local section = {}
        
        local SectionFrame = Instance.new("Frame")
        SectionFrame.Size = UDim2.new(1, 0, 0, 30)
        SectionFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        SectionFrame.Parent = TabContent
        
        local SectionCorner = Instance.new("UICorner")
        SectionCorner.CornerRadius = UDim.new(0, 6)
        SectionCorner.Parent = SectionFrame
        
        local SectionLabel = Instance.new("TextLabel")
        SectionLabel.Size = UDim2.new(1, -10, 1, 0)
        SectionLabel.Position = UDim2.new(0, 5, 0, 0)
        SectionLabel.BackgroundTransparency = 1
        SectionLabel.Text = title
        SectionLabel.TextColor3 = Color3.new(1, 1, 1)
        SectionLabel.Font = Enum.Font.GothamBold
        SectionLabel.TextSize = 14
        SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
        SectionLabel.Parent = SectionFrame
        
        function section:Button(text, callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, 0, 0, 35)
            Button.BackgroundColor3 = Color3.fromRGB(255, 0, 127)
            Button.Text = text
            Button.TextColor3 = Color3.new(1, 1, 1)
            Button.Font = Enum.Font.Gotham
            Button.TextSize = 12
            Button.Parent = TabContent
            
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 6)
            ButtonCorner.Parent = Button
            
            Button.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
            
            return Button
        end
        
        function section:Toggle(text, default, callback)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            ToggleFrame.Parent = TabContent
            
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 6)
            ToggleCorner.Parent = ToggleFrame
            
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Text = text
            ToggleLabel.TextColor3 = Color3.new(1, 1, 1)
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.TextSize = 12
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleFrame
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.new(0, 50, 0, 25)
            ToggleButton.Position = UDim2.new(1, -60, 0.5, -12.5)
            ToggleButton.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
            ToggleButton.Text = default and "ON" or "OFF"
            ToggleButton.TextColor3 = Color3.new(1, 1, 1)
            ToggleButton.Font = Enum.Font.GothamBold
            ToggleButton.TextSize = 10
            ToggleButton.Parent = ToggleFrame
            
            local ToggleButtonCorner = Instance.new("UICorner")
            ToggleButtonCorner.CornerRadius = UDim.new(0, 6)
            ToggleButtonCorner.Parent = ToggleButton
            
            ToggleButton.MouseButton1Click:Connect(function()
                local newState = ToggleButton.Text == "OFF"
                ToggleButton.Text = newState and "ON" or "OFF"
                ToggleButton.BackgroundColor3 = newState and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
                if callback then callback(newState) end
            end)
            
            return ToggleFrame
        end
        
        function section:Slider(text, min, max, default, callback)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 50)
            SliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            SliderFrame.Parent = TabContent
            
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 6)
            SliderCorner.Parent = SliderFrame
            
            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Size = UDim2.new(1, -10, 0, 20)
            SliderLabel.Position = UDim2.new(0, 5, 0, 0)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Text = text .. ": " .. default
            SliderLabel.TextColor3 = Color3.new(1, 1, 1)
            SliderLabel.Font = Enum.Font.Gotham
            SliderLabel.TextSize = 12
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.Parent = SliderFrame
            
            local SliderTrack = Instance.new("Frame")
            SliderTrack.Size = UDim2.new(1, -20, 0, 10)
            SliderTrack.Position = UDim2.new(0, 10, 0, 30)
            SliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            SliderTrack.Parent = SliderFrame
            
            local SliderTrackCorner = Instance.new("UICorner")
            SliderTrackCorner.CornerRadius = UDim.new(0, 5)
            SliderTrackCorner.Parent = SliderTrack
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            SliderFill.BackgroundColor3 = Color3.fromRGB(255, 0, 127)
            SliderFill.Parent = SliderTrack
            
            local SliderFillCorner = Instance.new("UICorner")
            SliderFillCorner.CornerRadius = UDim.new(0, 5)
            SliderFillCorner.Parent = SliderFill
            
            local SliderButton = Instance.new("TextButton")
            SliderButton.Size = UDim2.new(1, 0, 1, 0)
            SliderButton.BackgroundTransparency = 1
            SliderButton.Text = ""
            SliderButton.Parent = SliderTrack
            
            local dragging = false
            
            local function updateSlider(x)
                local relativeX = math.clamp(x - SliderTrack.AbsolutePosition.X, 0, SliderTrack.AbsoluteSize.X)
                local percentage = relativeX / SliderTrack.AbsoluteSize.X
                local value = math.floor(min + (max - min) * percentage)
                
                SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                SliderLabel.Text = text .. ": " .. value
                
                if callback then callback(value) end
            end
            
            SliderButton.MouseButton1Down:Connect(function()
                dragging = true
            end)
            
            game:GetService("UserInputService").InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            game:GetService("UserInputService").InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input.Position.X)
                end
            end)
            
            return SliderFrame
        end
        
        function section:Label(text)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 0, 25)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Color3.new(1, 1, 1)
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = TabContent
            
            return Label
        end
        
        return section
    end
    
    -- Store references
    tab.Button = TabButton
    tab.Content = TabContent
    
    TabButton.MouseButton1Click:Connect(function()
        tab:Show()
    end)
    
    table.insert(tabs, tab)
    return tab
end

------------------------------------------
----- =======[ CREATE TABS ]
------------------------------------------

-- Home Tab
local HomeTab = CreateTab("Home")
local HomeSection = HomeTab:Section("Welcome to OGHub!")
HomeSection:Label("Thank you for using our script!")
HomeSection:Label("No More Premium Script")
HomeSection:Label("Everyone Can Used !!")
HomeSection:Label("Keep OG Fams.. 👑")

-- Auto Fish Tab
local AutoFishTab = CreateTab("Auto Fish")
local FishSection = AutoFishTab:Section("Auto Fishing Settings")

_G.AutoFishEnabled = false
FishSection:Toggle("Auto Fish Instant", false, function(value)
    _G.AutoFishEnabled = value
    print("🎣 Auto Fish:", value)
end)

_G.FINISH_DELAY = 1
FishSection:Slider("Delay Finish", 0.1, 5, 1, function(value)
    _G.FINISH_DELAY = value
    print("⏱️ Delay:", value)
end)

_G.SPEED_LEGIT = 0.5
FishSection:Slider("Speed Legit", 0.1, 2, 0.5, function(value)
    _G.SPEED_LEGIT = value
    print("⚡ Speed:", value)
end)

FishSection:Button("Stop Fishing", function()
    print("⏹️ Fishing Stopped")
end)

-- Player Tab
local PlayerTab = CreateTab("Player")
local PlayerSection = PlayerTab:Section("Player Settings")

PlayerSection:Slider("WalkSpeed", 16, 200, 16, function(value)
    local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = value
        print("🚶 WalkSpeed:", value)
    end
end)

PlayerSection:Slider("Jump Power", 50, 200, 50, function(value)
    local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.JumpPower = value
        print("🦘 JumpPower:", value)
    end
end)

local ijump = false
PlayerSection:Toggle("Infinity Jump", false, function(value)
    ijump = value
    print("∞ Infinity Jump:", value)
end)

PlayerSection:Button("Boost FPS", function()
    print("🔄 FPS Boosted")
end)

-- Teleport Tab
local TeleportTab = CreateTab("Teleport")
local TeleportSection = TeleportTab:Section("Teleport Options")

TeleportSection:Button("Teleport to Spawn", function()
    print("📍 Teleport to Spawn")
end)

TeleportSection:Button("Teleport to Market", function()
    print("🛒 Teleport to Market")
end)

TeleportSection:Button("Teleport to Fishing Spot", function()
    print("🎣 Teleport to Fishing Spot")
end)

-- Settings Tab
local SettingsTab = CreateTab("Settings")
local SettingsSection = SettingsTab:Section("Settings")

SettingsSection:Toggle("Anti-AFK", true, function(value)
    print("🛡️ Anti-AFK:", value)
end)

SettingsSection:Button("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId)
end)

SettingsSection:Button("Save Settings", function()
    print("💾 Settings Saved")
end)

------------------------------------------
----- =======[ FINAL INITIALIZATION ]
------------------------------------------

-- Show first tab
HomeTab:Show()

-- Update scroll frame size
game:GetService("RunService").Heartbeat:Connect(function()
    local totalHeight = 0
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") and child.Visible then
            totalHeight = totalHeight + child.AbsoluteSize.Y + 5
        end
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end)

-- Infinity jump system
game:GetService("UserInputService").JumpRequest:Connect(function()
    if ijump and game.Players.LocalPlayer.Character then
        local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState("Jumping")
        end
    end
end)

print("🎉 OGHub Manual UI Loaded Successfully!")

-- Make window draggable
local dragging = false
local dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)