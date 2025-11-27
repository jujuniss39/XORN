-- OGHub Complete Library
local OGHub = {}

-- Services
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Config System
if not isfolder("OGHub") then makefolder("OGHub") end
if not isfolder("OGHub/Config") then makefolder("OGHub/Config") end

local gameName = tostring(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
gameName = gameName:gsub("[^%w_ ]", "") gameName = gameName:gsub("%s+", "_")
local ConfigFile = "OGHub/Config/OGHub_" .. gameName .. ".json"

OGHub.Config = {} OGHub.Elements = {} OGHub.CurrentVersion = nil

function OGHub:SaveConfig()
    if writefile then 
        OGHub.Config._version = OGHub.CurrentVersion
        writefile(ConfigFile, HttpService:JSONEncode(OGHub.Config)) 
    end
end

function OGHub:LoadConfig()
    if not OGHub.CurrentVersion then return end
    if isfile and isfile(ConfigFile) then
        local success, result = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
        if success and type(result) == "table" then
            if result._version == OGHub.CurrentVersion then OGHub.Config = result
            else OGHub.Config = { _version = OGHub.CurrentVersion } end
        else OGHub.Config = { _version = OGHub.CurrentVersion } end
    else OGHub.Config = { _version = OGHub.CurrentVersion } end
end

function OGHub:LoadConfigElements()
    for key, element in pairs(OGHub.Elements) do
        if OGHub.Config[key] ~= nil and element.Set then element:Set(OGHub.Config[key], true) end
    end
end

-- Icons
OGHub.Icons = {
    player = "rbxassetid://12120698352",
    sword = "rbxassetid://82472368671405", 
    loop = "rbxassetid://122032243989747",
    gps = "rbxassetid://17824309485",
    settings = "rbxassetid://70386228443175",
    gamepad = "rbxassetid://84173963561612",
    star = "rbxassetid://107005941750079"
}

-- Utility Functions
local function MakeDraggable(topbar, object)
    local dragging, dragInput, dragStart, startPos
    
    local function Update(input)
        local delta = input.Position - dragStart
        local pos = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        object.Position = pos
    end
    
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            Update(input)
        end
    end)
end

local function RippleEffect(button)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.8
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, Mouse.X - button.AbsolutePosition.X, 0, Mouse.Y - button.AbsolutePosition.Y)
    ripple.Parent = button
    ripple.ZIndex = 10
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
    TweenService:Create(ripple, TweenInfo.new(0.3), {
        Size = UDim2.new(0, size, 0, size),
        Position = UDim2.new(0.5, -size/2, 0.5, -size/2),
        BackgroundTransparency = 1
    }):Play()
    
    delay(0.3, function() ripple:Destroy() end)
end

-- Notification System
function OGHub:Notify(config)
    config = config or {}
    local title = config.Title or "OGHub"
    local message = config.Message or "Notification"
    local duration = config.Duration or 3
    local color = config.Color or Color3.fromRGB(255, 165, 0)
    
    local NotificationGui = Instance.new("ScreenGui")
    NotificationGui.Name = "OGHubNotification"
    NotificationGui.Parent = CoreGui
    NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 80)
    MainFrame.Position = UDim2.new(1, 10, 1, -90)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = NotificationGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = color
    Stroke.Thickness = 2
    Stroke.Parent = MainFrame
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -20, 0, 20)
    TitleLabel.Position = UDim2.new(0, 10, 0, 10)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = color
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = MainFrame
    
    local MessageLabel = Instance.new("TextLabel")
    MessageLabel.Size = UDim2.new(1, -20, 1, -40)
    MessageLabel.Position = UDim2.new(0, 10, 0, 35)
    MessageLabel.BackgroundTransparency = 1
    MessageLabel.Text = message
    MessageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    MessageLabel.Font = Enum.Font.Gotham
    MessageLabel.TextSize = 12
    MessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    MessageLabel.TextYAlignment = Enum.TextYAlignment.Top
    MessageLabel.TextWrapped = true
    MessageLabel.Parent = MainFrame
    
    -- Animation
    MainFrame.Position = UDim2.new(1, 320, 1, -90)
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {
        Position = UDim2.new(1, 10, 1, -90)
    }):Play()
    
    delay(duration, function()
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Position = UDim2.new(1, 320, 1, -90)
        }):Play()
        delay(0.3, function() NotificationGui:Destroy() end)
    end)
end

-- Main Window Function
function OGHub:Window(config)
    config = config or {}
    local title = config.Title or "OGHub"
    local color = config.Color or Color3.fromRGB(255, 165, 0)
    local size = config.Size or UDim2.new(0, 600, 0, 400)
    
    OGHub.CurrentVersion = config.Version or 1.0
    OGHub:LoadConfig()
    
    -- Create Main GUI
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "OGHubGUI"
    MainGui.Parent = CoreGui
    MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = size
    MainFrame.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = MainGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = color
    Stroke.Thickness = 2
    Stroke.Parent = MainFrame
    
    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 8)
    TopCorner.Parent = TopBar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = color
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Position = UDim2.new(1, -30, 0, 2)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 12
    CloseButton.Parent = TopBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = CloseButton
    
    -- Minimize Button
    local MinButton = Instance.new("TextButton")
    MinButton.Size = UDim2.new(0, 25, 0, 25)
    MinButton.Position = UDim2.new(1, -60, 0, 2)
    MinButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    MinButton.BorderSizePixel = 0
    MinButton.Text = "_"
    MinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinButton.Font = Enum.Font.GothamBold
    MinButton.TextSize = 12
    MinButton.Parent = TopBar
    
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 4)
    MinCorner.Parent = MinButton
    
    -- Circle Button (Minimized)
    local CircleButton = Instance.new("ImageButton")
    CircleButton.Size = UDim2.new(0, 50, 0, 50)
    CircleButton.Position = UDim2.new(0, 20, 0, 100)
    CircleButton.BackgroundColor3 = color
    CircleButton.BackgroundTransparency = 0.2
    CircleButton.Image = OGHub.Icons.star
    CircleButton.Visible = false
    CircleButton.Parent = MainGui
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = CircleButton
    
    local CircleStroke = Instance.new("UIStroke")
    CircleStroke.Color = color
    CircleStroke.Thickness = 2
    CircleStroke.Parent = CircleButton
    
    -- Tab System
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(0, 120, 1, -40)
    TabContainer.Position = UDim2.new(0, 10, 0, 40)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame
    
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -140, 1, -40)
    ContentContainer.Position = UDim2.new(0, 130, 0, 40)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame
    
    -- Make draggable
    MakeDraggable(TopBar, MainFrame)
    MakeDraggable(CircleButton, CircleButton)
    
    -- Minimize System
    local IsMinimized = false
    
    local function MinimizeToCircle()
        IsMinimized = true
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        delay(0.3, function()
            MainFrame.Visible = false
            CircleButton.Visible = true
            CircleButton.Size = UDim2.new(0, 0, 0, 0)
            TweenService:Create(CircleButton, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 50, 0, 50)
            }):Play()
        end)
    end
    
    local function RestoreFromCircle()
        IsMinimized = false
        TweenService:Create(CircleButton, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        delay(0.3, function()
            CircleButton.Visible = false
            MainFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            TweenService:Create(MainFrame, TweenInfo.new(0.3), {
                Size = size
            }):Play()
        end)
    end
    
    -- Button Events
    CloseButton.MouseButton1Click:Connect(function()
        RippleEffect(CloseButton)
        MainGui:Destroy()
    end)
    
    MinButton.MouseButton1Click:Connect(function()
        RippleEffect(MinButton)
        MinimizeToCircle()
    end)
    
    CircleButton.MouseButton1Click:Connect(function()
        RestoreFromCircle()
    end)
    
    -- Hotkey
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.F4 then
            if IsMinimized then RestoreFromCircle() else MinimizeToCircle() end
        end
    end)
    
    local WindowFunctions = {}
    local Tabs = {}
    local CurrentTab = nil
    
    function WindowFunctions:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 35)
        TabButton.Position = UDim2.new(0, 0, 0, #Tabs * 40)
        TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TabButton.BorderSizePixel = 0
        TabButton.Text = ""
        TabButton.Parent = TabContainer
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -30, 1, 0)
        TabLabel.Position = UDim2.new(0, 30, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = tabConfig.Name or "Tab"
        TabLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabLabel.Font = Enum.Font.Gotham
        TabLabel.TextSize = 12
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabButton
        
        local Icon = Instance.new("ImageLabel")
        Icon.Size = UDim2.new(0, 20, 0, 20)
        Icon.Position = UDim2.new(0, 5, 0, 7)
        Icon.BackgroundTransparency = 1
        Icon.Image = OGHub.Icons[tabConfig.Icon] or OGHub.Icons.gamepad
        Icon.Parent = TabButton
        
        -- Tab Content
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.ScrollBarThickness = 3
        TabContent.ScrollBarImageColor3 = color
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        local TabLayout = Instance.new("UIListLayout")
        TabLayout.Padding = UDim.new(0, 5)
        TabLayout.Parent = TabContent
        
        TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y)
        end)
        
        -- Tab Selection
        TabButton.MouseButton1Click:Connect(function()
            RippleEffect(TabButton)
            if CurrentTab then CurrentTab.Visible = false end
            
            for _, btn in pairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                end
            end
            
            TabButton.BackgroundColor3 = color
            TabContent.Visible = true
            CurrentTab = TabContent
        end)
        
        -- Select First Tab
        if #Tabs == 0 then
            TabButton.BackgroundColor3 = color
            TabContent.Visible = true
            CurrentTab = TabContent
        end
        
        table.insert(Tabs, TabContent)
        
        local TabFunctions = {}
        
        function TabFunctions:AddSection(sectionName)
            local Section = Instance.new("Frame")
            Section.Size = UDim2.new(1, 0, 0, 30)
            Section.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Section.BorderSizePixel = 0
            Section.Parent = TabContent
            
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 6)
            SectionCorner.Parent = Section
            
            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Size = UDim2.new(1, -20, 1, 0)
            SectionLabel.Position = UDim2.new(0, 10, 0, 0)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Text = sectionName or "Section"
            SectionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.TextSize = 13
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionLabel.Parent = Section
            
            local SectionContent = Instance.new("Frame")
            SectionContent.Size = UDim2.new(1, -20, 0, 0)
            SectionContent.Position = UDim2.new(0, 10, 0, 35)
            SectionContent.BackgroundTransparency = 1
            SectionContent.Parent = Section
            
            local SectionLayout = Instance.new("UIListLayout")
            SectionLayout.Padding = UDim.new(0, 5)
            SectionLayout.Parent = SectionContent
            
            SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Section.Size = UDim2.new(1, 0, 0, 40 + SectionLayout.AbsoluteContentSize.Y)
            end)
            
            local SectionFunctions = {}
            
            -- Button Element
            function SectionFunctions:AddButton(btnConfig)
                btnConfig = btnConfig or {}
                
                local Button = Instance.new("TextButton")
                Button.Size = UDim2.new(1, 0, 0, 30)
                Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                Button.BorderSizePixel = 0
                Button.Text = btnConfig.Name or "Button"
                Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                Button.Font = Enum.Font.Gotham
                Button.TextSize = 12
                Button.Parent = SectionContent
                
                local ButtonCorner = Instance.new("UICorner")
                ButtonCorner.CornerRadius = UDim.new(0, 4)
                ButtonCorner.Parent = Button
                
                Button.MouseButton1Click:Connect(function()
                    RippleEffect(Button)
                    if btnConfig.Callback then btnConfig.Callback() end
                end)
                
                return Button
            end
            
            -- Toggle Element
            function SectionFunctions:AddToggle(toggleConfig)
                toggleConfig = toggleConfig or {}
                local configKey = "Toggle_" .. (toggleConfig.Name or "Toggle")
                local toggleState = OGHub.Config[configKey] or toggleConfig.Default or false
                
                local Toggle = Instance.new("Frame")
                Toggle.Size = UDim2.new(1, 0, 0, 25)
                Toggle.BackgroundTransparency = 1
                Toggle.Parent = SectionContent
                
                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Size = UDim2.new(1, -40, 1, 0)
                ToggleLabel.Position = UDim2.new(0, 0, 0, 0)
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Text = toggleConfig.Name or "Toggle"
                ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                ToggleLabel.Font = Enum.Font.Gotham
                ToggleLabel.TextSize = 12
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.Parent = Toggle
                
                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Size = UDim2.new(0, 35, 0, 20)
                ToggleButton.Position = UDim2.new(1, -35, 0, 2)
                ToggleButton.BackgroundColor3 = toggleState and color or Color3.fromRGB(60, 60, 60)
                ToggleButton.BorderSizePixel = 0
                ToggleButton.Text = ""
                ToggleButton.Parent = Toggle
                
                local ToggleCorner = Instance.new("UICorner")
                ToggleCorner.CornerRadius = UDim.new(0, 10)
                ToggleCorner.Parent = ToggleButton
                
                local ToggleDot = Instance.new("Frame")
                ToggleDot.Size = UDim2.new(0, 16, 0, 16)
                ToggleDot.Position = UDim2.new(0, toggleState and 17 or 2, 0, 2)
                ToggleDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ToggleDot.BorderSizePixel = 0
                ToggleDot.Parent = ToggleButton
                
                local DotCorner = Instance.new("UICorner")
                DotCorner.CornerRadius = UDim.new(0, 8)
                DotCorner.Parent = ToggleDot
                
                local ToggleFunctions = {}
                
                function ToggleFunctions:Set(state)
                    toggleState = state
                    OGHub.Config[configKey] = state
                    OGHub:SaveConfig()
                    
                    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                        BackgroundColor3 = state and color or Color3.fromRGB(60, 60, 60)
                    }):Play()
                    
                    TweenService:Create(ToggleDot, TweenInfo.new(0.2), {
                        Position = UDim2.new(0, state and 17 or 2, 0, 2)
                    }):Play()
                    
                    if toggleConfig.Callback then toggleConfig.Callback(state) end
                end
                
                ToggleButton.MouseButton1Click:Connect(function()
                    ToggleFunctions:Set(not toggleState)
                end)
                
                OGHub.Elements[configKey] = ToggleFunctions
                return ToggleFunctions
            end
            
            -- Slider Element
            function SectionFunctions:AddSlider(sliderConfig)
                sliderConfig = sliderConfig or {}
                local configKey = "Slider_" .. (sliderConfig.Name or "Slider")
                local sliderValue = OGHub.Config[configKey] or sliderConfig.Default or 50
                local min = sliderConfig.Min or 0
                local max = sliderConfig.Max or 100
                
                local Slider = Instance.new("Frame")
                Slider.Size = UDim2.new(1, 0, 0, 40)
                Slider.BackgroundTransparency = 1
                Slider.Parent = SectionContent
                
                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Size = UDim2.new(1, 0, 0, 15)
                SliderLabel.Position = UDim2.new(0, 0, 0, 0)
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Text = (sliderConfig.Name or "Slider") .. ": " .. sliderValue
                SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                SliderLabel.Font = Enum.Font.Gotham
                SliderLabel.TextSize = 12
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = Slider
                
                local SliderTrack = Instance.new("Frame")
                SliderTrack.Size = UDim2.new(1, 0, 0, 5)
                SliderTrack.Position = UDim2.new(0, 0, 0, 20)
                SliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                SliderTrack.BorderSizePixel = 0
                SliderTrack.Parent = Slider
                
                local TrackCorner = Instance.new("UICorner")
                TrackCorner.CornerRadius = UDim.new(0, 3)
                TrackCorner.Parent = SliderTrack
                
                local SliderFill = Instance.new("Frame")
                SliderFill.Size = UDim2.new((sliderValue - min) / (max - min), 0, 1, 0)
                SliderFill.BackgroundColor3 = color
                SliderFill.BorderSizePixel = 0
                SliderFill.Parent = SliderTrack
                
                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(0, 3)
                FillCorner.Parent = SliderFill
                
                local SliderDot = Instance.new("Frame")
                SliderDot.Size = UDim2.new(0, 15, 0, 15)
                SliderDot.Position = UDim2.new((sliderValue - min) / (max - min), -7, 0, -5)
                SliderDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderDot.BorderSizePixel = 0
                SliderDot.Parent = SliderTrack
                
                local DotCorner = Instance.new("UICorner")
                DotCorner.CornerRadius = UDim.new(0, 7)
                DotCorner.Parent = SliderDot
                
                local dragging = false
                
                local function UpdateSlider(value)
                    value = math.clamp(value, min, max)
                    sliderValue = value
                    SliderLabel.Text = (sliderConfig.Name or "Slider") .. ": " .. value
                    SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    SliderDot.Position = UDim2.new((value - min) / (max - min), -7, 0, -5)
                    
                    OGHub.Config[configKey] = value
                    OGHub:SaveConfig()
                    if sliderConfig.Callback then sliderConfig.Callback(value) end
                end
                
                SliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        local percent = (input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X
                        UpdateSlider(min + (max - min) * percent)
                    end
                end)
                
                SliderTrack.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local percent = (input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X
                        UpdateSlider(min + (max - min) * percent)
                    end
                end)
                
                local SliderFunctions = {}
                
                function SliderFunctions:Set(value) UpdateSlider(value) end
                function SliderFunctions:Get() return sliderValue end
                
                OGHub.Elements[configKey] = SliderFunctions
                return SliderFunctions
            end
            
            return SectionFunctions
        end
        
        return TabFunctions
    end
    
    function WindowFunctions:Destroy() MainGui:Destroy() end
    function WindowFunctions:Notify(config) OGHub:Notify(config) end
    
    -- Load config
    OGHub:LoadConfigElements()
    
    -- Welcome notification
    OGHub:Notify({
        Title = "OGHub",
        Message = "GUI Loaded Successfully!\nPress F4 to toggle",
        Duration = 5,
        Color = color
    })
    
    return WindowFunctions
end

return OGHub

-- ========== TEST SCRIPT ==========
local Window = OGHub:Window({
    Title = "OGHub Premium",
    Color = Color3.fromRGB(255, 165, 0),
    Size = UDim2.new(0, 600, 0, 400),
    Version = 1.0
})

-- Tabs
local MainTab = Window:AddTab({Name = "Main", Icon = "gamepad"})
local PlayerTab = Window:AddTab({Name = "Player", Icon = "player"})
local CombatTab = Window:AddTab({Name = "Combat", Icon = "sword"})

-- Main Tab Sections
local AutoSection = MainTab:AddSection("Auto Farm")

local FarmToggle = AutoSection:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(value)
        Window:Notify({
            Title = "Auto Farm",
            Message = value and "Started farming!" or "Stopped farming!",
            Duration = 2
        })
    end
})

local SpeedSlider = AutoSection:AddSlider({
    Name = "Farm Speed",
    Min = 1,
    Max = 10,
    Default = 5,
    Callback = function(value)
        print("Farm speed:", value)
    end
})

AutoSection:AddButton({
    Name = "Start Farming",
    Callback = function()
        Window:Notify({
            Title = "Farming",
            Message = "Starting farm routine...",
            Duration = 3
        })
    end
})

-- Player Tab Sections
local MoveSection = PlayerTab:AddSection("Movement")

local SpeedToggle = MoveSection:AddToggle({
    Name = "Speed Hack",
    Default = false,
    Callback = function(value)
        if value then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 50
        else
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
})

MoveSection:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

-- Combat Tab Sections
local CombatSection = CombatTab:AddSection("Combat")

local AuraToggle = CombatSection:AddToggle({
    Name = "Kill Aura",
    Default = false,
    Callback = function(value)
        Window:Notify({
            Title = "Kill Aura",
            Message = value and "Activated!" or "Deactivated!",
            Duration = 2
        })
    end
})

CombatSection:AddButton({
    Name = "Teleport to Enemy",
    Callback = function()
        Window:Notify({
            Title = "Combat",
            Message = "Searching for enemies...",
            Duration = 2
        })
    end
})

print("OGHub Premium Loaded Successfully!")