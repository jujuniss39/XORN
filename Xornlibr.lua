local HttpService = game:GetService("HttpService")

if not isfolder("KRNL_UI") then
    makefolder("KRNL_UI")
end
if not isfolder("KRNL_UI/Config") then
    makefolder("KRNL_UI/Config")
end

local gameName   = tostring(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
gameName         = gameName:gsub("[^%w_ ]", "")
gameName         = gameName:gsub("%s+", "_")

local ConfigFile = "KRNL_UI/Config/Config_" .. gameName .. ".json"

ConfigData       = {}
Elements         = {}
CURRENT_VERSION  = nil

function SaveConfig()
    if writefile then
        ConfigData._version = CURRENT_VERSION
        writefile(ConfigFile, HttpService:JSONEncode(ConfigData))
    end
end

function LoadConfigFromFile()
    if not CURRENT_VERSION then return end
    if isfile and isfile(ConfigFile) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFile))
        end)
        if success and type(result) == "table" then
            if result._version == CURRENT_VERSION then
                ConfigData = result
            else
                ConfigData = { _version = CURRENT_VERSION }
            end
        else
            ConfigData = { _version = CURRENT_VERSION }
        end
    else
        ConfigData = { _version = CURRENT_VERSION }
    end
end

function LoadConfigElements()
    for key, element in pairs(Elements) do
        if ConfigData[key] ~= nil and element.Set then
            element:Set(ConfigData[key], true)
        end
    end
end

local Icons = {
    player    = "rbxassetid://12120698352",
    web       = "rbxassetid://137601480983962",
    bag       = "rbxassetid://8601111810",
    shop      = "rbxassetid://4985385964",
    cart      = "rbxassetid://128874923961846",
    plug      = "rbxassetid://137601480983962",
    settings  = "rbxassetid://70386228443175",
    loop      = "rbxassetid://122032243989747",
    gps       = "rbxassetid://17824309485",
    compas    = "rbxassetid://125300760963399",
    gamepad   = "rbxassetid://84173963561612",
    boss      = "rbxassetid://13132186360",
    scroll    = "rbxassetid://114127804740858",
    menu      = "rbxassetid://6340513838",
    crosshair = "rbxassetid://12614416478",
    user      = "rbxassetid://108483430622128",
    stat      = "rbxassetid://12094445329",
    eyes      = "rbxassetid://14321059114",
    sword     = "rbxassetid://82472368671405",
    discord   = "rbxassetid://94434236999817",
    star      = "rbxassetid://107005941750079",
    skeleton  = "rbxassetid://17313330026",
    payment   = "rbxassetid://18747025078",
    scan      = "rbxassetid://109869955247116",
    alert     = "rbxassetid://73186275216515",
    question  = "rbxassetid://17510196486",
    idea      = "rbxassetid://16833255748",
    storm     = "rbxassetid://13321880293",
    water     = "rbxassetid://100076212630732",
    dcs       = "rbxassetid://15310731934",
    start     = "rbxassetid://108886429866687",
    next      = "rbxassetid://12662718374",
    rod       = "rbxassetid://103247953194129",
    fish      = "rbxassetid://97167558235554",
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CoreGui = game:GetService("CoreGui")
local viewport = workspace.CurrentCamera.ViewportSize

-- KRNL Color Scheme
local KRNL_COLORS = {
    Primary = Color3.fromRGB(0, 162, 255),     -- KRNL Blue
    Secondary = Color3.fromRGB(0, 140, 220),   -- Darker Blue
    Background = Color3.fromRGB(20, 20, 25),   -- Dark Background
    Surface = Color3.fromRGB(30, 30, 35),      -- Slightly lighter
    Text = Color3.fromRGB(240, 240, 240),      -- White text
    TextSecondary = Color3.fromRGB(180, 180, 180), -- Gray text
    Success = Color3.fromRGB(0, 200, 100),     -- Green
    Warning = Color3.fromRGB(255, 165, 0),     -- Orange
    Error = Color3.fromRGB(255, 60, 60),       -- Red
}

local function isMobileDevice()
    return UserInputService.TouchEnabled
        and not UserInputService.KeyboardEnabled
        and not UserInputService.MouseEnabled
end

local isMobile = isMobileDevice()

local function MakeDraggable(topbarobject, object)
    local function CustomPos(topbarobject, object)
        local Dragging, DragInput, DragStart, StartPosition

        local function UpdatePos(input)
            local Delta = input.Position - DragStart
            local pos = UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset + Delta.Y
            )
            local Tween = TweenService:Create(object, TweenInfo.new(0.15), { Position = pos })
            Tween:Play()
        end

        topbarobject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                Dragging = true
                DragStart = input.Position
                StartPosition = object.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                    end
                end)
            end
        end)

        topbarobject.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                DragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == DragInput and Dragging then
                UpdatePos(input)
            end
        end)
    end

    CustomPos(topbarobject, object)
end

function CircleClick(Button, X, Y)
    spawn(function()
        Button.ClipsDescendants = true
        local Circle = Instance.new("ImageLabel")
        Circle.Image = "rbxassetid://266543268"
        Circle.ImageColor3 = KRNL_COLORS.Primary
        Circle.ImageTransparency = 0.7
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Circle.BackgroundTransparency = 1
        Circle.ZIndex = 10
        Circle.Name = "Circle"
        Circle.Parent = Button

        local NewX = X - Circle.AbsolutePosition.X
        local NewY = Y - Circle.AbsolutePosition.Y
        Circle.Position = UDim2.new(0, NewX, 0, NewY)
        
        local Size = 0
        if Button.AbsoluteSize.X > Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.X * 1.5
        elseif Button.AbsoluteSize.X < Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.Y * 1.5
        else
            Size = Button.AbsoluteSize.X * 1.5
        end

        local Time = 0.3
        Circle:TweenSizeAndPosition(
            UDim2.new(0, Size, 0, Size),
            UDim2.new(0.5, -Size/2, 0.5, -Size/2),
            "Out", "Quad", Time, false, nil
        )
        
        for i = 1, 10 do
            Circle.ImageTransparency = Circle.ImageTransparency + 0.03
            wait(Time / 10)
        end
        Circle:Destroy()
    end)
end

-- Notification System
local KRNL_UI = {}
function KRNL_UI:MakeNotify(NotifyConfig)
    local NotifyConfig = NotifyConfig or {}
    NotifyConfig.Title = NotifyConfig.Title or "KRNL UI"
    NotifyConfig.Description = NotifyConfig.Description or "Notification"
    NotifyConfig.Content = NotifyConfig.Content or "Content"
    NotifyConfig.Color = NotifyConfig.Color or KRNL_COLORS.Primary
    NotifyConfig.Time = NotifyConfig.Time or 0.3
    NotifyConfig.Delay = NotifyConfig.Delay or 5
    
    local NotifyFunction = {}
    
    spawn(function()
        if not CoreGui:FindFirstChild("KRNLNotifyGui") then
            local NotifyGui = Instance.new("ScreenGui")
            NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            NotifyGui.Name = "KRNLNotifyGui"
            NotifyGui.Parent = CoreGui
        end
        
        if not CoreGui.KRNLNotifyGui:FindFirstChild("NotifyLayout") then
            local NotifyLayout = Instance.new("Frame")
            NotifyLayout.AnchorPoint = Vector2.new(1, 1)
            NotifyLayout.BackgroundTransparency = 1
            NotifyLayout.Position = UDim2.new(1, -20, 1, -20)
            NotifyLayout.Size = UDim2.new(0, 350, 1, 0)
            NotifyLayout.Name = "NotifyLayout"
            NotifyLayout.Parent = CoreGui.KRNLNotifyGui
        end
        
        local NotifyPosHeight = 0
        for _, v in CoreGui.KRNLNotifyGui.NotifyLayout:GetChildren() do
            if v:IsA("Frame") then
                NotifyPosHeight = NotifyPosHeight + v.Size.Y.Offset + 10
            end
        end
        
        local NotifyFrame = Instance.new("Frame")
        NotifyFrame.Size = UDim2.new(1, 0, 0, 120)
        NotifyFrame.BackgroundTransparency = 1
        NotifyFrame.Position = UDim2.new(0, 0, 1, -(NotifyPosHeight + 10))
        NotifyFrame.Parent = CoreGui.KRNLNotifyGui.NotifyLayout
        
        local MainFrame = Instance.new("Frame")
        MainFrame.Size = UDim2.new(1, 0, 1, 0)
        MainFrame.Position = UDim2.new(0, 400, 0, 0)
        MainFrame.BackgroundColor3 = KRNL_COLORS.Background
        MainFrame.BackgroundTransparency = 0.95
        MainFrame.BorderSizePixel = 0
        MainFrame.Parent = NotifyFrame
        
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = MainFrame
        
        local UIStroke = Instance.new("UIStroke")
        UIStroke.Color = KRNL_COLORS.Primary
        UIStroke.Thickness = 1
        UIStroke.Transparency = 0.7
        UIStroke.Parent = MainFrame
        
        local TopBar = Instance.new("Frame")
        TopBar.Size = UDim2.new(1, 0, 0, 35)
        TopBar.BackgroundColor3 = KRNL_COLORS.Surface
        TopBar.BackgroundTransparency = 0.95
        TopBar.BorderSizePixel = 0
        TopBar.Parent = MainFrame
        
        local Title = Instance.new("TextLabel")
        Title.Font = Enum.Font.GothamBold
        Title.Text = NotifyConfig.Title
        Title.TextColor3 = NotifyConfig.Color
        Title.TextSize = 14
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.BackgroundTransparency = 1
        Title.Size = UDim2.new(1, -40, 1, 0)
        Title.Position = UDim2.new(0, 10, 0, 0)
        Title.Parent = TopBar
        
        local CloseBtn = Instance.new("TextButton")
        CloseBtn.Size = UDim2.new(0, 25, 0, 25)
        CloseBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
        CloseBtn.BackgroundTransparency = 1
        CloseBtn.Text = "×"
        CloseBtn.Font = Enum.Font.GothamBold
        CloseBtn.TextSize = 20
        CloseBtn.TextColor3 = KRNL_COLORS.Text
        CloseBtn.Parent = TopBar
        
        local Content = Instance.new("TextLabel")
        Content.Font = Enum.Font.Gotham
        Content.Text = NotifyConfig.Content
        Content.TextColor3 = KRNL_COLORS.TextSecondary
        Content.TextSize = 13
        Content.TextXAlignment = Enum.TextXAlignment.Left
        Content.TextYAlignment = Enum.TextYAlignment.Top
        Content.BackgroundTransparency = 1
        Content.Position = UDim2.new(0, 10, 0, 40)
        Content.Size = UDim2.new(1, -20, 0, 70)
        Content.TextWrapped = true
        Content.Parent = MainFrame
        
        local Description = Instance.new("TextLabel")
        Description.Font = Enum.Font.Gotham
        Description.Text = NotifyConfig.Description
        Description.TextColor3 = NotifyConfig.Color
        Description.TextSize = 12
        Description.TextXAlignment = Enum.TextXAlignment.Left
        Description.BackgroundTransparency = 1
        Description.Position = UDim2.new(0, Title.TextBounds.X + 15, 0, 0)
        Description.Size = UDim2.new(1, -(Title.TextBounds.X + 40), 1, 0)
        Description.Parent = TopBar
        
        local function close()
            TweenService:Create(
                MainFrame,
                TweenInfo.new(NotifyConfig.Time, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { Position = UDim2.new(0, 400, 0, 0) }
            ):Play()
            wait(NotifyConfig.Time)
            NotifyFrame:Destroy()
        end
        
        CloseBtn.MouseButton1Click:Connect(close)
        
        TweenService:Create(
            MainFrame,
            TweenInfo.new(NotifyConfig.Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { Position = UDim2.new(0, 0, 0, 0) }
        ):Play()
        
        wait(NotifyConfig.Delay)
        close()
    end)
    
    return NotifyFunction
end

function krnl_notify(msg, delay, color, title, desc)
    return KRNL_UI:MakeNotify({
        Title = title or "KRNL UI",
        Description = desc or "Notification",
        Content = msg or "Content",
        Color = color or KRNL_COLORS.Primary,
        Delay = delay or 4
    })
end

-- Main Window Function
function KRNL_UI:Window(GuiConfig)
    GuiConfig = GuiConfig or {}
    GuiConfig.Title = GuiConfig.Title or "KRNL UI"
    GuiConfig.Footer = GuiConfig.Footer or "Powered by KRNL"
    GuiConfig.Color = GuiConfig.Color or KRNL_COLORS.Primary
    GuiConfig.TabWidth = GuiConfig.TabWidth or 150
    GuiConfig.Version = GuiConfig.Version or 1
    
    CURRENT_VERSION = GuiConfig.Version
    LoadConfigFromFile()
    
    local GuiFunc = {}
    
    -- Create Main GUI
    local KrnlGui = Instance.new("ScreenGui")
    KrnlGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    KrnlGui.Name = "KrnlGui"
    KrnlGui.ResetOnSpawn = false
    KrnlGui.Parent = CoreGui
    
    -- Main Container
    local MainContainer = Instance.new("Frame")
    MainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    MainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainContainer.Size = UDim2.new(0, 700, 0, 450)
    MainContainer.BackgroundColor3 = KRNL_COLORS.Background
    MainContainer.BackgroundTransparency = 0.05
    MainContainer.BorderSizePixel = 0
    MainContainer.Parent = KrnlGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainContainer
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = KRNL_COLORS.Primary
    UIStroke.Thickness = 2
    UIStroke.Transparency = 0.3
    UIStroke.Parent = MainContainer
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = KRNL_COLORS.Surface
    TitleBar.BackgroundTransparency = 0.05
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainContainer
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar
    
    local Title = Instance.new("TextLabel")
    Title.Font = Enum.Font.GothamBold
    Title.Text = GuiConfig.Title
    Title.TextColor3 = GuiConfig.Color
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Parent = TitleBar
    
    local Footer = Instance.new("TextLabel")
    Footer.Font = Enum.Font.Gotham
    Footer.Text = GuiConfig.Footer
    Footer.TextColor3 = KRNL_COLORS.TextSecondary
    Footer.TextSize = 12
    Footer.TextXAlignment = Enum.TextXAlignment.Right
    Footer.BackgroundTransparency = 1
    Footer.Size = UDim2.new(0.3, 0, 1, 0)
    Footer.Position = UDim2.new(0.7, -15, 0, 0)
    Footer.Parent = TitleBar
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
    CloseBtn.BackgroundColor3 = KRNL_COLORS.Error
    CloseBtn.BackgroundTransparency = 0.9
    CloseBtn.Text = "×"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 18
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn
    
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.Position = UDim2.new(1, -80, 0.5, -15)
    MinimizeBtn.BackgroundColor3 = KRNL_COLORS.Warning
    MinimizeBtn.BackgroundTransparency = 0.9
    MinimizeBtn.Text = "―"
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 18
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.Parent = TitleBar
    
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 6)
    MinCorner.Parent = MinimizeBtn
    
    -- Sidebar for Tabs
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, GuiConfig.TabWidth, 1, -45)
    Sidebar.Position = UDim2.new(0, 5, 0, 45)
    Sidebar.BackgroundColor3 = KRNL_COLORS.Surface
    Sidebar.BackgroundTransparency = 0.95
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainContainer
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 6)
    SidebarCorner.Parent = Sidebar
    
    local ScrollTab = Instance.new("ScrollingFrame")
    ScrollTab.Size = UDim2.new(1, -10, 1, -10)
    ScrollTab.Position = UDim2.new(0, 5, 0, 5)
    ScrollTab.BackgroundTransparency = 1
    ScrollTab.BorderSizePixel = 0
    ScrollTab.ScrollBarThickness = 3
    ScrollTab.ScrollBarImageColor3 = KRNL_COLORS.Primary
    ScrollTab.Parent = Sidebar
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = ScrollTab
    
    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -(GuiConfig.TabWidth + 15), 1, -45)
    ContentArea.Position = UDim2.new(0, GuiConfig.TabWidth + 10, 0, 45)
    ContentArea.BackgroundColor3 = KRNL_COLORS.Surface
    ContentArea.BackgroundTransparency = 0.95
    ContentArea.BorderSizePixel = 0
    ContentArea.ClipsDescendants = true
    ContentArea.Parent = MainContainer
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 6)
    ContentCorner.Parent = ContentArea
    
    local ContentContainer = Instance.new("ScrollingFrame")
    ContentContainer.Size = UDim2.new(1, -10, 1, -10)
    ContentContainer.Position = UDim2.new(0, 5, 0, 5)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.BorderSizePixel = 0
    ContentContainer.ScrollBarThickness = 3
    ContentContainer.ScrollBarImageColor3 = KRNL_COLORS.Primary
    ContentContainer.Parent = ContentArea
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 10)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = ContentContainer
    
    -- Make draggable
    MakeDraggable(TitleBar, MainContainer)
    
    -- Button click effects
    CloseBtn.MouseButton1Click:Connect(function()
        CircleClick(CloseBtn, Mouse.X, Mouse.Y)
        
        -- Confirmation dialog
        local Overlay = Instance.new("Frame")
        Overlay.Size = UDim2.new(1, 0, 1, 0)
        Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Overlay.BackgroundTransparency = 0.5
        Overlay.ZIndex = 100
        Overlay.Parent = KrnlGui
        
        local Dialog = Instance.new("Frame")
        Dialog.Size = UDim2.new(0, 300, 0, 150)
        Dialog.Position = UDim2.new(0.5, -150, 0.5, -75)
        Dialog.BackgroundColor3 = KRNL_COLORS.Background
        Dialog.BackgroundTransparency = 0.05
        Dialog.ZIndex = 101
        Dialog.Parent = Overlay
        
        local DialogCorner = Instance.new("UICorner")
        DialogCorner.CornerRadius = UDim.new(0, 8)
        DialogCorner.Parent = Dialog
        
        local DialogStroke = Instance.new("UIStroke")
        DialogStroke.Color = KRNL_COLORS.Primary
        DialogStroke.Thickness = 2
        DialogStroke.Parent = Dialog
        
        local DialogTitle = Instance.new("TextLabel")
        DialogTitle.Size = UDim2.new(1, 0, 0, 40)
        DialogTitle.Position = UDim2.new(0, 0, 0, 10)
        DialogTitle.BackgroundTransparency = 1
        DialogTitle.Font = Enum.Font.GothamBold
        DialogTitle.Text = "Close KRNL UI"
        DialogTitle.TextColor3 = KRNL_COLORS.Primary
        DialogTitle.TextSize = 18
        DialogTitle.ZIndex = 102
        DialogTitle.Parent = Dialog
        
        local DialogMessage = Instance.new("TextLabel")
        DialogMessage.Size = UDim2.new(1, -20, 0, 50)
        DialogMessage.Position = UDim2.new(0, 10, 0, 50)
        DialogMessage.BackgroundTransparency = 1
        DialogMessage.Font = Enum.Font.Gotham
        DialogMessage.Text = "Are you sure you want to close?\nYou can reopen with F3."
        DialogMessage.TextSize = 14
        DialogMessage.TextColor3 = KRNL_COLORS.TextSecondary
        DialogMessage.TextWrapped = true
        DialogMessage.ZIndex = 102
        DialogMessage.Parent = Dialog
        
        local YesBtn = Instance.new("TextButton")
        YesBtn.Size = UDim2.new(0.4, -5, 0, 35)
        YesBtn.Position = UDim2.new(0.05, 0, 1, -50)
        YesBtn.BackgroundColor3 = KRNL_COLORS.Error
        YesBtn.BackgroundTransparency = 0.9
        YesBtn.Text = "Yes"
        YesBtn.Font = Enum.Font.GothamBold
        YesBtn.TextSize = 14
        YesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        YesBtn.ZIndex = 102
        YesBtn.Parent = Dialog
        Instance.new("UICorner", YesBtn).CornerRadius = UDim.new(0, 6)
        
        local NoBtn = Instance.new("TextButton")
        NoBtn.Size = UDim2.new(0.4, -5, 0, 35)
        NoBtn.Position = UDim2.new(0.55, 5, 1, -50)
        NoBtn.BackgroundColor3 = KRNL_COLORS.Success
        NoBtn.BackgroundTransparency = 0.9
        NoBtn.Text = "No"
        NoBtn.Font = Enum.Font.GothamBold
        NoBtn.TextSize = 14
        NoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        NoBtn.ZIndex = 102
        NoBtn.Parent = Dialog
        Instance.new("UICorner", NoBtn).CornerRadius = UDim.new(0, 6)
        
        YesBtn.MouseButton1Click:Connect(function()
            KrnlGui:Destroy()
            if CoreGui:FindFirstChild("KRNLToggleUI") then
                CoreGui.KRNLToggleUI:Destroy()
            end
        end)
        
        NoBtn.MouseButton1Click:Connect(function()
            Overlay:Destroy()
        end)
    end)
    
    MinimizeBtn.MouseButton1Click:Connect(function()
        CircleClick(MinimizeBtn, Mouse.X, Mouse.Y)
        MainContainer.Visible = false
    end)
    
    -- Toggle with F3
    local ToggleKey = Enum.KeyCode.F3
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == ToggleKey then
            MainContainer.Visible = not MainContainer.Visible
        end
    end)
    
    -- Toggle Button
    function GuiFunc:CreateToggleButton()
        local ToggleGui = Instance.new("ScreenGui")
        ToggleGui.Name = "KRNLToggleUI"
        ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ToggleGui.Parent = CoreGui
        
        local ToggleButton = Instance.new("ImageButton")
        ToggleButton.Size = UDim2.new(0, 50, 0, 50)
        ToggleButton.Position = UDim2.new(0, 20, 0, 100)
        ToggleButton.BackgroundColor3 = KRNL_COLORS.Primary
        ToggleButton.BackgroundTransparency = 0.9
        ToggleButton.Image = "rbxassetid://101868580779" -- KRNL logo or any icon
        ToggleButton.Parent = ToggleGui
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 8)
        ToggleCorner.Parent = ToggleButton
        
        local ToggleStroke = Instance.new("UIStroke")
        ToggleStroke.Color = KRNL_COLORS.Primary
        ToggleStroke.Thickness = 2
        ToggleStroke.Parent = ToggleButton
        
        -- Draggable
        local dragging = false
        local dragStart, startPos
        
        local function update(input)
            local delta = input.Position - dragStart
            ToggleButton.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
        
        ToggleButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = ToggleButton.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)
        
        ToggleButton.MouseButton1Click:Connect(function()
            MainContainer.Visible = not MainContainer.Visible
        end)
    end
    
    GuiFunc:CreateToggleButton()
    
    -- Update content size
    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentContainer.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
    end)
    
    TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollTab.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Tabs System
    local Tabs = {}
    local TabCount = 0
    local CurrentTab = nil
    
    function Tabs:AddTab(TabConfig)
        TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or ""
        
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 40)
        TabButton.BackgroundColor3 = KRNL_COLORS.Surface
        TabButton.BackgroundTransparency = 0.95
        TabButton.Text = ""
        TabButton.LayoutOrder = TabCount
        TabButton.Parent = ScrollTab
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Font = Enum.Font.GothamBold
        TabLabel.Text = TabConfig.Name
        TabLabel.TextColor3 = KRNL_COLORS.TextSecondary
        TabLabel.TextSize = 13
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.BackgroundTransparency = 1
        TabLabel.Size = UDim2.new(1, -40, 1, 0)
        TabLabel.Position = UDim2.new(0, 35, 0, 0)
        TabLabel.Parent = TabButton
        
        if TabConfig.Icon ~= "" and Icons[TabConfig.Icon] then
            local Icon = Instance.new("ImageLabel")
            Icon.Size = UDim2.new(0, 20, 0, 20)
            Icon.Position = UDim2.new(0, 10, 0.5, -10)
            Icon.BackgroundTransparency = 1
            Icon.Image = Icons[TabConfig.Icon]
            Icon.ImageColor3 = KRNL_COLORS.TextSecondary
            Icon.Parent = TabButton
        end
        
        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 3, 0.7, 0)
        Indicator.Position = UDim2.new(0, 3, 0.15, 0)
        Indicator.BackgroundColor3 = KRNL_COLORS.Primary
        Indicator.BackgroundTransparency = 0.8
        Indicator.Visible = false
        Indicator.Parent = TabButton
        
        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(0, 2)
        IndicatorCorner.Parent = Indicator
        
        -- Create tab content container
        local TabContent = Instance.new("Frame")
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        local TabContentLayout = Instance.new("UIListLayout")
        TabContentLayout.Padding = UDim.new(0, 10)
        TabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabContentLayout.Parent = TabContent
        
        TabContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.Size = UDim2.new(1, 0, 0, TabContentLayout.AbsoluteContentSize.Y)
        end)
        
        -- Select first tab by default
        if TabCount == 0 then
            Indicator.Visible = true
            TabLabel.TextColor3 = KRNL_COLORS.Primary
            TabContent.Visible = true
            CurrentTab = TabContent
        end
        
        TabButton.MouseButton1Click:Connect(function()
            CircleClick(TabButton, Mouse.X, Mouse.Y)
            
            -- Deselect all tabs
            for _, btn in ScrollTab:GetChildren() do
                if btn:IsA("TextButton") and btn ~= TabButton then
                    if btn:FindFirstChild("Indicator") then
                        btn.Indicator.Visible = false
                    end
                    if btn:FindFirstChildOfClass("TextLabel") then
                        btn:FindFirstChildOfClass("TextLabel").TextColor3 = KRNL_COLORS.TextSecondary
                    end
                    if btn:FindFirstChildOfClass("ImageLabel") then
                        btn:FindFirstChildOfClass("ImageLabel").ImageColor3 = KRNL_COLORS.TextSecondary
                    end
                end
            end
            
            -- Hide all tab contents
            for _, content in ContentContainer:GetChildren() do
                if content:IsA("Frame") then
                    content.Visible = false
                end
            end
            
            -- Select this tab
            Indicator.Visible = true
            TabLabel.TextColor3 = KRNL_COLORS.Primary
            if TabButton:FindFirstChildOfClass("ImageLabel") then
                TabButton:FindFirstChildOfClass("ImageLabel").ImageColor3 = KRNL_COLORS.Primary
            end
            
            TabContent.Visible = true
            CurrentTab = TabContent
        end)
        
        -- Section System
        local Sections = {}
        
        function Sections:AddSection(Title, AlwaysOpen)
            Title = Title or "Section"
            AlwaysOpen = AlwaysOpen or false
            
            local Section = Instance.new("Frame")
            Section.Size = UDim2.new(1, 0, 0, 40)
            Section.BackgroundColor3 = KRNL_COLORS.Background
            Section.BackgroundTransparency = 0.95
            Section.LayoutOrder = #TabContent:GetChildren()
            Section.Parent = TabContent
            
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 6)
            SectionCorner.Parent = Section
            
            local SectionStroke = Instance.new("UIStroke")
            SectionStroke.Color = KRNL_COLORS.Primary
            SectionStroke.Thickness = 1
            SectionStroke.Transparency = 0.8
            SectionStroke.Parent = Section
            
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.Text = Title
            SectionTitle.TextColor3 = KRNL_COLORS.Text
            SectionTitle.TextSize = 14
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Size = UDim2.new(1, -40, 1, 0)
            SectionTitle.Position = UDim2.new(0, 10, 0, 0)
            SectionTitle.Parent = Section
            
            local ExpandIcon = Instance.new("ImageLabel")
            ExpandIcon.Size = UDim2.new(0, 20, 0, 20)
            ExpandIcon.Position = UDim2.new(1, -30, 0.5, -10)
            ExpandIcon.BackgroundTransparency = 1
            ExpandIcon.Image = "rbxassetid://6031091004" -- Chevron down
            ExpandIcon.Rotation = 180
            ExpandIcon.ImageColor3 = KRNL_COLORS.TextSecondary
            ExpandIcon.Parent = Section
            
            local SectionContent = Instance.new("Frame")
            SectionContent.Size = UDim2.new(1, -20, 0, 0)
            SectionContent.Position = UDim2.new(0, 10, 0, 45)
            SectionContent.BackgroundTransparency = 1
            SectionContent.Visible = false
            SectionContent.Parent = Section
            
            local ContentLayout = Instance.new("UIListLayout")
            ContentLayout.Padding = UDim.new(0, 8)
            ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContentLayout.Parent = SectionContent
            
            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionContent.Size = UDim2.new(1, -20, 0, ContentLayout.AbsoluteContentSize.Y)
            end)
            
            local SectionButton = Instance.new("TextButton")
            SectionButton.Size = UDim2.new(1, 0, 1, 0)
            SectionButton.BackgroundTransparency = 1
            SectionButton.Text = ""
            SectionButton.Parent = Section
            
            local isOpen = AlwaysOpen
            
            local function updateSection()
                if isOpen then
                    Section.Size = UDim2.new(1, 0, 0, 45 + SectionContent.Size.Y.Offset)
                    SectionContent.Visible = true
                    ExpandIcon.Rotation = 0
                    TweenService:Create(ExpandIcon, TweenInfo.new(0.2), {Rotation = 0}):Play()
                else
                    Section.Size = UDim2.new(1, 0, 0, 40)
                    SectionContent.Visible = false
                    ExpandIcon.Rotation = 180
                    TweenService:Create(ExpandIcon, TweenInfo.new(0.2), {Rotation = 180}):Play()
                end
            end
            
            if AlwaysOpen then
                updateSection()
                SectionButton:Destroy()
            else
                SectionButton.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    updateSection()
                end)
            end
            
            local Items = {}
            
            function Items:AddButton(ButtonConfig)
                ButtonConfig = ButtonConfig or {}
                ButtonConfig.Name = ButtonConfig.Name or "Button"
                ButtonConfig.Callback = ButtonConfig.Callback or function() end
                
                local Button = Instance.new("TextButton")
                Button.Size = UDim2.new(1, 0, 0, 35)
                Button.BackgroundColor3 = KRNL_COLORS.Surface
                Button.BackgroundTransparency = 0.95
                Button.Text = ButtonConfig.Name
                Button.Font = Enum.Font.GothamBold
                Button.TextColor3 = KRNL_COLORS.Text
                Button.TextSize = 13
                Button.LayoutOrder = #SectionContent:GetChildren()
                Button.Parent = SectionContent
                
                local ButtonCorner = Instance.new("UICorner")
                ButtonCorner.CornerRadius = UDim.new(0, 6)
                ButtonCorner.Parent = Button
                
                local ButtonStroke = Instance.new("UIStroke")
                ButtonStroke.Color = KRNL_COLORS.Primary
                ButtonStroke.Thickness = 1
                ButtonStroke.Transparency = 0.8
                ButtonStroke.Parent = Button
                
                Button.MouseButton1Click:Connect(function()
                    CircleClick(Button, Mouse.X, Mouse.Y)
                    ButtonConfig.Callback()
                end)
                
                Button.MouseEnter:Connect(function()
                    TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play()
                end)
                
                Button.MouseLeave:Connect(function()
                    TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundTransparency = 0.95}):Play()
                end)
            end
            
            function Items:AddToggle(ToggleConfig)
                ToggleConfig = ToggleConfig or {}
                ToggleConfig.Name = ToggleConfig.Name or "Toggle"
                ToggleConfig.Default = ToggleConfig.Default or false
                ToggleConfig.Callback = ToggleConfig.Callback or function() end
                
                local configKey = "Toggle_" .. ToggleConfig.Name
                if ConfigData[configKey] ~= nil then
                    ToggleConfig.Default = ConfigData[configKey]
                end
                
                local ToggleFunc = { Value = ToggleConfig.Default }
                
                local Toggle = Instance.new("Frame")
                Toggle.Size = UDim2.new(1, 0, 0, 35)
                Toggle.BackgroundColor3 = KRNL_COLORS.Surface
                Toggle.BackgroundTransparency = 0.95
                Toggle.LayoutOrder = #SectionContent:GetChildren()
                Toggle.Parent = SectionContent
                
                local ToggleCorner = Instance.new("UICorner")
                ToggleCorner.CornerRadius = UDim.new(0, 6)
                ToggleCorner.Parent = Toggle
                
                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Font = Enum.Font.GothamBold
                ToggleLabel.Text = ToggleConfig.Name
                ToggleLabel.TextColor3 = KRNL_COLORS.Text
                ToggleLabel.TextSize = 13
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
                ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
                ToggleLabel.Parent = Toggle
                
                local ToggleSwitch = Instance.new("Frame")
                ToggleSwitch.Size = UDim2.new(0, 50, 0, 25)
                ToggleSwitch.Position = UDim2.new(1, -60, 0.5, -12.5)
                ToggleSwitch.BackgroundColor3 = KRNL_COLORS.Background
                ToggleSwitch.BackgroundTransparency = 0.9
                ToggleSwitch.Parent = Toggle
                
                local SwitchCorner = Instance.new("UICorner")
                SwitchCorner.CornerRadius = UDim.new(0, 12)
                SwitchCorner.Parent = ToggleSwitch
                
                local SwitchDot = Instance.new("Frame")
                SwitchDot.Size = UDim2.new(0, 21, 0, 21)
                SwitchDot.Position = UDim2.new(0, 2, 0.5, -10.5)
                SwitchDot.BackgroundColor3 = KRNL_COLORS.TextSecondary
                SwitchDot.Parent = ToggleSwitch
                
                local DotCorner = Instance.new("UICorner")
                DotCorner.CornerRadius = UDim.new(1, 0)
                DotCorner.Parent = SwitchDot
                
                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Size = UDim2.new(1, 0, 1, 0)
                ToggleButton.BackgroundTransparency = 1
                ToggleButton.Text = ""
                ToggleButton.Parent = Toggle
                
                function ToggleFunc:Set(value)
                    ToggleFunc.Value = value
                    ConfigData[configKey] = value
                    SaveConfig()
                    
                    if value then
                        TweenService:Create(SwitchDot, TweenInfo.new(0.2), {
                            Position = UDim2.new(1, -23, 0.5, -10.5),
                            BackgroundColor3 = KRNL_COLORS.Primary
                        }):Play()
                        TweenService:Create(ToggleSwitch, TweenInfo.new(0.2), {
                            BackgroundColor3 = KRNL_COLORS.Primary
                        }):Play()
                        TweenService:Create(ToggleLabel, TweenInfo.new(0.2), {
                            TextColor3 = KRNL_COLORS.Primary
                        }):Play()
                    else
                        TweenService:Create(SwitchDot, TweenInfo.new(0.2), {
                            Position = UDim2.new(0, 2, 0.5, -10.5),
                            BackgroundColor3 = KRNL_COLORS.TextSecondary
                        }):Play()
                        TweenService:Create(ToggleSwitch, TweenInfo.new(0.2), {
                            BackgroundColor3 = KRNL_COLORS.Background
                        }):Play()
                        TweenService:Create(ToggleLabel, TweenInfo.new(0.2), {
                            TextColor3 = KRNL_COLORS.Text
                        }):Play()
                    end
                    
                    ToggleConfig.Callback(value)
                end
                
                ToggleButton.MouseButton1Click:Connect(function()
                    ToggleFunc:Set(not ToggleFunc.Value)
                end)
                
                ToggleFunc:Set(ToggleFunc.Value)
                Elements[configKey] = ToggleFunc
                
                return ToggleFunc
            end
            
            function Items:AddSlider(SliderConfig)
                SliderConfig = SliderConfig or {}
                SliderConfig.Name = SliderConfig.Name or "Slider"
                SliderConfig.Min = SliderConfig.Min or 0
                SliderConfig.Max = SliderConfig.Max or 100
                SliderConfig.Default = SliderConfig.Default or 50
                SliderConfig.Callback = SliderConfig.Callback or function() end
                
                local configKey = "Slider_" .. SliderConfig.Name
                if ConfigData[configKey] ~= nil then
                    SliderConfig.Default = ConfigData[configKey]
                end
                
                local SliderFunc = { Value = SliderConfig.Default }
                
                local Slider = Instance.new("Frame")
                Slider.Size = UDim2.new(1, 0, 0, 60)
                Slider.BackgroundColor3 = KRNL_COLORS.Surface
                Slider.BackgroundTransparency = 0.95
                Slider.LayoutOrder = #SectionContent:GetChildren()
                Slider.Parent = SectionContent
                
                local SliderCorner = Instance.new("UICorner")
                SliderCorner.CornerRadius = UDim.new(0, 6)
                SliderCorner.Parent = Slider
                
                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Font = Enum.Font.GothamBold
                SliderLabel.Text = SliderConfig.Name
                SliderLabel.TextColor3 = KRNL_COLORS.Text
                SliderLabel.TextSize = 13
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Size = UDim2.new(1, -20, 0, 20)
                SliderLabel.Position = UDim2.new(0, 10, 0, 5)
                SliderLabel.Parent = Slider
                
                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Font = Enum.Font.Gotham
                ValueLabel.Text = tostring(SliderFunc.Value)
                ValueLabel.TextColor3 = KRNL_COLORS.TextSecondary
                ValueLabel.TextSize = 12
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Size = UDim2.new(0.3, 0, 0, 20)
                ValueLabel.Position = UDim2.new(0.7, -10, 0, 5)
                ValueLabel.Parent = Slider
                
                local SliderTrack = Instance.new("Frame")
                SliderTrack.Size = UDim2.new(1, -20, 0, 4)
                SliderTrack.Position = UDim2.new(0, 10, 0, 35)
                SliderTrack.BackgroundColor3 = KRNL_COLORS.Background
                SliderTrack.BackgroundTransparency = 0.9
                SliderTrack.Parent = Slider
                
                local TrackCorner = Instance.new("UICorner")
                TrackCorner.CornerRadius = UDim.new(1, 0)
                TrackCorner.Parent = SliderTrack
                
                local SliderFill = Instance.new("Frame")
                SliderFill.Size = UDim2.new(0, 0, 1, 0)
                SliderFill.BackgroundColor3 = KRNL_COLORS.Primary
                SliderFill.Parent = SliderTrack
                
                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(1, 0)
                FillCorner.Parent = SliderFill
                
                local SliderDot = Instance.new("Frame")
                SliderDot.Size = UDim2.new(0, 12, 0, 12)
                SliderDot.Position = UDim2.new(0, -6, 0.5, -6)
                SliderDot.BackgroundColor3 = KRNL_COLORS.Primary
                SliderDot.Parent = SliderTrack
                
                local DotCorner = Instance.new("UICorner")
                DotCorner.CornerRadius = UDim.new(1, 0)
                DotCorner.Parent = SliderDot
                
                local dragging = false
                
                function SliderFunc:Set(value)
                    value = math.clamp(value, SliderConfig.Min, SliderConfig.Max)
                    SliderFunc.Value = value
                    
                    local percent = (value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min)
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    SliderDot.Position = UDim2.new(percent, -6, 0.5, -6)
                    ValueLabel.Text = tostring(math.floor(value))
                    
                    ConfigData[configKey] = value
                    SaveConfig()
                    SliderConfig.Callback(value)
                end
                
                SliderFunc:Set(SliderFunc.Value)
                
                local function updateSlider(input)
                    local pos = math.clamp(
                        (input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X,
                        0, 1
                    )
                    local value = SliderConfig.Min + (pos * (SliderConfig.Max - SliderConfig.Min))
                    SliderFunc:Set(value)
                end
                
                SliderTrack.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        updateSlider(input)
                    end
                end)
                
                SliderTrack.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input)
                    end
                end)
                
                Elements[configKey] = SliderFunc
                return SliderFunc
            end
            
            function Items:AddLabel(LabelConfig)
                LabelConfig = LabelConfig or {}
                LabelConfig.Text = LabelConfig.Text or "Label"
                LabelConfig.Color = LabelConfig.Color or KRNL_COLORS.Text
                
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 25)
                Label.BackgroundTransparency = 1
                Label.Text = LabelConfig.Text
                Label.Font = Enum.Font.Gotham
                Label.TextColor3 = LabelConfig.Color
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.LayoutOrder = #SectionContent:GetChildren()
                Label.Parent = SectionContent
                
                return Label
            end
            
            function Items:AddDropdown(DropdownConfig)
                DropdownConfig = DropdownConfig or {}
                DropdownConfig.Name = DropdownConfig.Name or "Dropdown"
                DropdownConfig.Options = DropdownConfig.Options or {}
                DropdownConfig.Default = DropdownConfig.Default or DropdownConfig.Options[1]
                DropdownConfig.Callback = DropdownConfig.Callback or function() end
                
                local configKey = "Dropdown_" .. DropdownConfig.Name
                if ConfigData[configKey] ~= nil then
                    DropdownConfig.Default = ConfigData[configKey]
                end
                
                local DropdownFunc = { Value = DropdownConfig.Default }
                
                local Dropdown = Instance.new("Frame")
                Dropdown.Size = UDim2.new(1, 0, 0, 35)
                Dropdown.BackgroundColor3 = KRNL_COLORS.Surface
                Dropdown.BackgroundTransparency = 0.95
                Dropdown.LayoutOrder = #SectionContent:GetChildren()
                Dropdown.Parent = SectionContent
                
                local DropdownCorner = Instance.new("UICorner")
                DropdownCorner.CornerRadius = UDim.new(0, 6)
                DropdownCorner.Parent = Dropdown
                
                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.Font = Enum.Font.GothamBold
                DropdownLabel.Text = DropdownConfig.Name
                DropdownLabel.TextColor3 = KRNL_COLORS.Text
                DropdownLabel.TextSize = 13
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Size = UDim2.new(0.5, 0, 1, 0)
                DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
                DropdownLabel.Parent = Dropdown
                
                local SelectedLabel = Instance.new("TextLabel")
                SelectedLabel.Font = Enum.Font.Gotham
                SelectedLabel.Text = tostring(DropdownFunc.Value) or "Select..."
                SelectedLabel.TextColor3 = KRNL_COLORS.TextSecondary
                SelectedLabel.TextSize = 12
                SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
                SelectedLabel.BackgroundTransparency = 1
                SelectedLabel.Size = UDim2.new(0.4, 0, 1, 0)
                SelectedLabel.Position = UDim2.new(0.55, 0, 0, 0)
                SelectedLabel.Parent = Dropdown
                
                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Size = UDim2.new(1, 0, 1, 0)
                DropdownButton.BackgroundTransparency = 1
                DropdownButton.Text = ""
                DropdownButton.Parent = Dropdown
                
                -- Dropdown menu (simplified version)
                DropdownButton.MouseButton1Click:Connect(function()
                    local Menu = Instance.new("Frame")
                    Menu.Size = UDim2.new(1, 0, 0, #DropdownConfig.Options * 30)
                    Menu.Position = UDim2.new(0, 0, 1, 5)
                    Menu.BackgroundColor3 = KRNL_COLORS.Background
                    Menu.BackgroundTransparency = 0.05
                    Menu.Parent = Dropdown
                    
                    local MenuCorner = Instance.new("UICorner")
                    MenuCorner.CornerRadius = UDim.new(0, 6)
                    MenuCorner.Parent = Menu
                    
                    local MenuStroke = Instance.new("UIStroke")
                    MenuStroke.Color = KRNL_COLORS.Primary
                    MenuStroke.Thickness = 1
                    MenuStroke.Parent = Menu
                    
                    for i, option in ipairs(DropdownConfig.Options) do
                        local OptionButton = Instance.new("TextButton")
                        OptionButton.Size = UDim2.new(1, 0, 0, 30)
                        OptionButton.Position = UDim2.new(0, 0, 0, (i-1)*30)
                        OptionButton.BackgroundColor3 = KRNL_COLORS.Surface
                        OptionButton.BackgroundTransparency = 0.95
                        OptionButton.Text = tostring(option)
                        OptionButton.Font = Enum.Font.Gotham
                        OptionButton.TextColor3 = KRNL_COLORS.Text
                        OptionButton.TextSize = 12
                        OptionButton.Parent = Menu
                        
                        OptionButton.MouseButton1Click:Connect(function()
                            DropdownFunc.Value = option
                            SelectedLabel.Text = tostring(option)
                            ConfigData[configKey] = option
                            SaveConfig()
                            DropdownConfig.Callback(option)
                            Menu:Destroy()
                        end)
                    end
                    
                    -- Close menu when clicking elsewhere
                    local connection
                    connection = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            if Menu and Menu.Parent then
                                Menu:Destroy()
                            end
                            connection:Disconnect()
                        end
                    end)
                end)
                
                Elements[configKey] = DropdownFunc
                return DropdownFunc
            end
            
            function Items:AddTextBox(TextBoxConfig)
                TextBoxConfig = TextBoxConfig or {}
                TextBoxConfig.Name = TextBoxConfig.Name or "Text Box"
                TextBoxConfig.Placeholder = TextBoxConfig.Placeholder or "Enter text..."
                TextBoxConfig.Default = TextBoxConfig.Default or ""
                TextBoxConfig.Callback = TextBoxConfig.Callback or function() end
                
                local configKey = "TextBox_" .. TextBoxConfig.Name
                if ConfigData[configKey] ~= nil then
                    TextBoxConfig.Default = ConfigData[configKey]
                end
                
                local TextBoxFunc = { Value = TextBoxConfig.Default }
                
                local TextBox = Instance.new("Frame")
                TextBox.Size = UDim2.new(1, 0, 0, 50)
                TextBox.BackgroundColor3 = KRNL_COLORS.Surface
                TextBox.BackgroundTransparency = 0.95
                TextBox.LayoutOrder = #SectionContent:GetChildren()
                TextBox.Parent = SectionContent
                
                local TextBoxCorner = Instance.new("UICorner")
                TextBoxCorner.CornerRadius = UDim.new(0, 6)
                TextBoxCorner.Parent = TextBox
                
                local TextBoxLabel = Instance.new("TextLabel")
                TextBoxLabel.Font = Enum.Font.GothamBold
                TextBoxLabel.Text = TextBoxConfig.Name
                TextBoxLabel.TextColor3 = KRNL_COLORS.Text
                TextBoxLabel.TextSize = 13
                TextBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
                TextBoxLabel.BackgroundTransparency = 1
                TextBoxLabel.Size = UDim2.new(1, -20, 0, 20)
                TextBoxLabel.Position = UDim2.new(0, 10, 0, 5)
                TextBoxLabel.Parent = TextBox
                
                local InputBox = Instance.new("TextBox")
                InputBox.Size = UDim2.new(1, -20, 0, 25)
                InputBox.Position = UDim2.new(0, 10, 0, 25)
                InputBox.BackgroundColor3 = KRNL_COLORS.Background
                InputBox.BackgroundTransparency = 0.9
                InputBox.Text = TextBoxFunc.Value
                InputBox.PlaceholderText = TextBoxConfig.Placeholder
                InputBox.Font = Enum.Font.Gotham
                InputBox.TextColor3 = KRNL_COLORS.Text
                InputBox.TextSize = 12
                InputBox.ClearTextOnFocus = false
                InputBox.Parent = TextBox
                
                local InputCorner = Instance.new("UICorner")
                InputCorner.CornerRadius = UDim.new(0, 4)
                InputCorner.Parent = InputBox
                
                function TextBoxFunc:Set(value)
                    TextBoxFunc.Value = value
                    InputBox.Text = value
                    ConfigData[configKey] = value
                    SaveConfig()
                end
                
                InputBox.FocusLost:Connect(function()
                    TextBoxFunc.Value = InputBox.Text
                    ConfigData[configKey] = InputBox.Text
                    SaveConfig()
                    TextBoxConfig.Callback(InputBox.Text)
                end)
                
                TextBoxFunc:Set(TextBoxFunc.Value)
                Elements[configKey] = TextBoxFunc
                
                return TextBoxFunc
            end
            
            updateSection()
            
            return Items
        end
        
        TabCount = TabCount + 1
        return Sections
    end
    
    -- Load saved config
    LoadConfigElements()
    
    return Tabs
end

return KRNL_UI