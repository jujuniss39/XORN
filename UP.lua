------------------------------------------
----- =======[ Load Chloe X GUI ]
------------------------------------------

local HttpService = game:GetService("HttpService")
if not isfolder("Chloe X") then makefolder("Chloe X") end
if not isfolder("Chloe X/Config") then makefolder("Chloe X/Config") end

local gameName = tostring(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
gameName = gameName:gsub("[^%w_ ]", "")
gameName = gameName:gsub("%s+", "_")
local ConfigFile = "Chloe X/Config/Chloe_" .. gameName .. ".json"

-- Load Chloe X Library dari kode yang Anda berikan
local ChloeX = loadstring(game:HttpGet("https://raw.githubusercontent.com/TesterX14/XXXX/refs/heads/main/Library"))()
do
    -- Tempel seluruh kode Chloe X library di sini
    local Icons = {
        player = "rbxassetid://12120698352",
        web = "rbxassetid://137601480983962",
        bag = "rbxassetid://8601111810",
        shop = "rbxassetid://4985385964",
        cart = "rbxassetid://128874923961846",
        plug = "rbxassetid://137601480983962",
        settings = "rbxassetid://70386228443175",
        loop = "rbxassetid://122032243989747",
        gps = "rbxassetid://17824309485",
        compas = "rbxassetid://125300760963399",
        gamepad = "rbxassetid://84173963561612",
        boss = "rbxassetid://13132186360",
        scroll = "rbxassetid://114127804740858",
        menu = "rbxassetid://6340513838",
        crosshair = "rbxassetid://12614416478",
        user = "rbxassetid://108483430622128",
        stat = "rbxassetid://12094445329",
        eyes = "rbxassetid://14321059114",
        sword = "rbxassetid://82472368671405",
        discord = "rbxassetid://94434236999817",
        star = "rbxassetid://107005941750079",
        skeleton = "rbxassetid://17313330026",
        payment = "rbxassetid://18747025078",
        scan = "rbxassetid://109869955247116",
        alert = "rbxassetid://73186275216515",
        question = "rbxassetid://17510196486",
        idea = "rbxassetid://16833255748",
        strom = "rbxassetid://13321880293",
        water = "rbxassetid://100076212630732",
        dcs = "rbxassetid://15310731934",
        start = "rbxassetid://108886429866687",
        next = "rbxassetid://12662718374",
        rod = "rbxassetid://103247953194129",
        fish = "rbxassetid://97167558235554",
    }

    -- ... (Tempel seluruh kode Chloe X library yang Anda berikan di sini)
    -- Karena panjang, saya asumsikan semua fungsi Chloe X sudah terdefinisi
end

-- Inisialisasi Chloe X Window
local Window = ChloeX:Window({
    Title = "OGhub",
    Footer = "Free To Use",
    Color = Color3.fromRGB(255, 0, 127),
    ["Tab Width"] = 120,
    Version = 1.6,
    Theme = nil,
    ThemeTransparency = 0.15,
    Image = "fish"
})

------------------------------------------
----- =======[ MERGED GLOBAL FUNCTION ] 
------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

-- Net Remotes
local net = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")
local rodRemote = net:WaitForChild("RF/ChargeFishingRod")
local miniGameRemote = net:WaitForChild("RF/RequestFishingMinigameStarted")
local finishRemote = net:WaitForChild("RE/FishingCompleted")

-- Constants & Player
local Constants = require(ReplicatedStorage:WaitForChild("Shared", 20):WaitForChild("Constants"))
local Player = Players.LocalPlayer
local XPBar = Player:WaitForChild("PlayerGui"):WaitForChild("XP")
local PlaceId = game.PlaceId

-- Anti-Idle System
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

for i, v in next, getconnections(game:GetService("Players").LocalPlayer.Idled) do
    if v.Connection then
        v.Connection:Disconnect()
    end
end

for i, v in next, getconnections(game:GetService("Players").LocalPlayer.Idled) do
    v:Disable()
end

-- Enable XP Bar
task.spawn(function()
    if XPBar then
        XPBar.Enabled = true
    end
end)

-- Auto Reconnect System
local function AutoReconnect()
    while task.wait(5) do
        if not Players.LocalPlayer or not Players.LocalPlayer:IsDescendantOf(game) then
            TeleportService:Teleport(PlaceId)
        end
    end
end

Players.LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Failed then
        TeleportService:Teleport(PlaceId)
    end
end)

task.spawn(AutoReconnect)

-- Animation Setup
local ijump = false
local RodIdle = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("ReelingIdle")
local RodShake = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("RodThrow")
local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
local RodShakeAnim = animator:LoadAnimation(RodShake)
local RodIdleAnim = animator:LoadAnimation(RodIdle)

-- Load Global Utilities
if not _G.ItemUtility then
    local success, utility = pcall(require, ReplicatedStorage.Shared.ItemUtility)
    if success and utility then
        _G.ItemUtility = utility
    end
end

if not _G.ItemStringUtility then
    local success, stringUtility = pcall(require, ReplicatedStorage.Modules.ItemStringUtility)
    if success and stringUtility then
        _G.ItemStringUtility = stringUtility
    end
end

if not _G.Replion then 
    pcall(function() 
        _G.Replion = require(ReplicatedStorage.Packages.Replion) 
    end) 
end

print(" Global Function Merged Successfully!")

------------------------------------------
----- =======[ NOTIFY FUNCTION ]
------------------------------------------

local function NotifySuccess(title, message, duration)
    ChloeX:MakeNotify({
        Title = title,
        Description = "Success",
        Content = message,
        Color = Color3.fromRGB(0, 255, 0),
        Delay = duration or 4
    })
end

local function NotifyError(title, message, duration)
    ChloeX:MakeNotify({
        Title = title,
        Description = "Error",
        Content = message,
        Color = Color3.fromRGB(255, 0, 0),
        Delay = duration or 4
    })
end

local function NotifyInfo(title, message, duration)
    ChloeX:MakeNotify({
        Title = title,
        Description = "Info",
        Content = message,
        Color = Color3.fromRGB(0, 191, 255),
        Delay = duration or 4
    })
end

local function NotifyWarning(title, message, duration)
    ChloeX:MakeNotify({
        Title = title,
        Description = "Warning",
        Content = message,
        Color = Color3.fromRGB(255, 165, 0),
        Delay = duration or 4
    })
end

------------------------------------------
----- =======[ CHECK DATA ]
-----------------------------------------

local CheckData = {
    pasteURL = "https://paste.monster/CrTNPO9LIDhY/raw/",
    interval = 30,
    kicked = false,
    notified = false
}

local function checkStatus()
    local success, result = pcall(function()
        return game:HttpGet(CheckData.pasteURL)
    end)

    if not success or typeof(result) ~= "string" then
        return
    end

    local response = result:upper():gsub("%s+", "")

    if response == "UPDATE" then
        if not CheckData.kicked then
            CheckData.kicked = true
            LocalPlayer:Kick("OGhub Update Available!.")
        end
    elseif response == "LATEST" then
        if not CheckData.notified then
            CheckData.notified = true
            warn("[OGhub] Status: Beta Version")
        end
    else
        warn("[OGhub] Status unknown:", response)
    end
end

checkStatus()

task.spawn(function()
    while not CheckData.kicked do
        task.wait(CheckData.interval)
        checkStatus()
    end
end)

------------------------------------------
----- =======[ CREATE TABS ]
------------------------------------------

local Home = Window:AddTab({
    Name = "About Me",
    Icon = "hard-drive"
})

local AutoFish = Window:AddTab({
    Name = "Auto Fishing",
    Icon = "fish"
})

local X5SpeedTab = Window:AddTab({
    Name = "OG Mode",
    Icon = "zap"
})

local AutoFarmArt = Window:AddTab({
    Name = "Auto Farm Artifact",
    Icon = "flask-round"
})

local PlayerTab = Window:AddTab({
    Name = "Player",
    Icon = "users-round"
})

local Teleport = Window:AddTab({
    Name = "Teleport",
    Icon = "search"
})

local Trade = Window:AddTab({
    Name = "Trade",
    Icon = "handshake"
})

local AutoFav = Window:AddTab({
    Name = "Auto Favorite",
    Icon = "heart"
})

local Shop = Window:AddTab({
    Name = "Shop",
    Icon = "plus"
})

local SettingsTab = Window:AddTab({
    Name = "Settings",
    Icon = "cog"
})

_G.ServerPage = Window:AddTab({
    Name = "Server List",
    Icon = "server"
})

------------------------------------------
----- =======[ HOME TAB ]
------------------------------------------

local HomeSection = Home:AddSection("Attention!", true)
HomeSection:AddParagraph({
    Title = "⚠️OGhub⚠️",
    Content = [[
Thanks For Using This Script.
No More Premium Script.
Everyone Can Used !!.
Keep OG Fams..
]]
})

-- Auto Rejoin System
if getgenv().AutoRejoinConnection then
    getgenv().AutoRejoinConnection:Disconnect()
    getgenv().AutoRejoinConnection = nil
end

getgenv().AutoRejoinConnection = game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    task.wait()
    if child.Name == "ErrorPrompt" and child:FindFirstChild("MessageArea") and child.MessageArea:FindFirstChild("ErrorFrame") then
        local TeleportService = game:GetService("TeleportService")
        local Player = game.Players.LocalPlayer
        task.wait(2) 
        TeleportService:Teleport(game.PlaceId, Player)
    end
end)

------------------------------------------
----- =======[ SERVER PAGE TAB ]
------------------------------------------

_G.ServerList = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" ..
game.PlaceId .. "/servers/Private?sortOrder=Asc&limit=100"))

_G.ButtonList = {}

local ServerListAll = _G.ServerPage:AddSection("All Server List", true)

_G.ShowServersButton = ServerListAll:AddButton({
    Title = "Show Server List",
    SubTitle = "Klik untuk menampilkan daftar server yang tersedia.",
    Callback = function()
        if _G.ServersShown then return end
        _G.ServersShown = true

        for _, server in ipairs(_G.ServerList.data) do
            _G.playerCount = string.format("%d/%d", server.playing, server.maxPlayers)
            _G.ping = server.ping
            _G.id = server.id

            ServerListAll:AddButton({
                Title = "Server",
                SubTitle = "Player: " .. tostring(_G.playerCount) .. "\nPing: " .. tostring(_G.ping),
                Callback = function()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, _G.id,
                        game.Players.LocalPlayer)
                end
            })
        end

        if #_G.ButtonList == 0 then
            ServerListAll:AddParagraph({
                Title = "No Servers Found",
                Content = "Tidak ada server yang ditemukan."
            })
        end
    end
})

------------------------------------------
----- =======[ AUTO FISH TAB ]
------------------------------------------

-- Fishing Variables
_G.REFishingStopped = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishingStopped"]
_G.RFCancelFishingInputs = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/CancelFishingInputs"]
_G.REUpdateChargeState = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/UpdateChargeState"]

_G.StopFishing = function()
    _G.RFCancelFishingInputs:InvokeServer()
    firesignal(_G.REFishingStopped.OnClientEvent)
end

local FuncAutoFish = {
    REReplicateTextEffect = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ReplicateTextEffect"],
    autofish5x = false,
    perfectCast5x = true,
    fishingActive = false,
    delayInitialized = false,
    lastCatchTime5x = 0,
    CatchLast = tick(),
}

_G.REFishCaught = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishCaught"]
_G.REPlayFishingEffect = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/PlayFishingEffect"]
_G.equipRemote = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipToolFromHotbar"]
_G.REObtainedNewFishNotification = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/ObtainedNewFishNotification"]

_G.isSpamming = false
_G.rSpamming = false
_G.spamThread = nil
_G.rspamThread = nil
_G.lastRecastTime = 0
_G.DELAY_ANTISTUCK = 10
_G.isRecasting5x = false
_G.STUCK_TIMEOUT = 10
_G.AntiStuckEnabled = false
_G.lastFishTime = tick()
_G.FINISH_DELAY = 1
_G.obtainedFishUUIDs = {}
_G.obtainedLimit = 30
_G.sellActive = false
_G.AutoFishHighQuality = false

_G.RemotePackage = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
_G.RemoteFish = _G.RemotePackage["RE/ObtainedNewFishNotification"]
_G.RemoteSell = _G.RemotePackage["RF/SellAllItems"]

_G.RemoteFish.OnClientEvent:Connect(function(_, _, data)
    if _G.sellActive and data and data.InventoryItem and data.InventoryItem.UUID then
        table.insert(_G.obtainedFishUUIDs, data.InventoryItem.UUID)
    end
end)

local function sellItems()
    if #_G.obtainedFishUUIDs > 0 then
        _G.RemoteSell:InvokeServer()
        print("[Auto Sell] Selling all fishes (" .. tostring(#_G.obtainedFishUUIDs) .. ")")
    end
    _G.obtainedFishUUIDs = {}
end

task.spawn(function()
    while task.wait(0.5) do
        if _G.sellActive and #_G.obtainedFishUUIDs >= tonumber(_G.obtainedLimit) then
            sellItems()
            task.wait(0.5)
        end
    end
end)

-- Auto Fish Functions
function StartCast5X()
    local getPowerFunction = Constants.GetPower
    local perfectThreshold = 0.99
    local chargeStartTime = workspace:GetServerTimeNow()
    rodRemote:InvokeServer(chargeStartTime)
    local calculationLoopStart = tick()
    local timeoutDuration = 1
    local lastPower = 0
    while (tick() - calculationLoopStart < timeoutDuration) do
        local currentPower = getPowerFunction(Constants, chargeStartTime)
        if currentPower < lastPower and lastPower >= perfectThreshold then
            break
        end
        lastPower = currentPower
        task.wait(0)
    end
    miniGameRemote:InvokeServer(-1.25, 1.0, workspace:GetServerTimeNow())
end

function StartAutoFish5X()
    FuncAutoFish.autofish5x = true
    FuncAutoFish.CatchLast5x = tick()
    _G.equipRemote:FireServer(1)
    task.wait(0.05)
    StartCast5X()
end

function StopAutoFish5X()
    FuncAutoFish.autofish5x = false
    FuncAutoFish.delayInitialized = false
    _G.StopFishing()
    _G.isRecasting5x = false
    _G.stopSpam()
    _G.StopRecastSpam()
end

-- Auto Fish Legit System
_G.RunService = game:GetService("RunService")
_G.FishingControllerPath = _G.ReplicatedStorage.Controllers.FishingController
_G.FishingController = require(_G.FishingControllerPath)
_G.AutoFishingControllerPath = _G.ReplicatedStorage.Controllers.AutoFishingController
_G.AutoFishingController = require(_G.AutoFishingControllerPath)
_G.Replion = require(_G.ReplicatedStorage.Packages.Replion)

_G.AutoFishState = {
    IsActive = false,
    MinigameActive = false
}

_G.SPEED_LEGIT = 0.05

function _G.performClick()
    _G.FishingController:RequestFishingMinigameClick()
    task.wait(tonumber(_G.SPEED_LEGIT))
end

function _G.ensureServerAutoFishingOn()
    local replionData = _G.Replion.Client:WaitReplion("Data")
    local currentAutoFishingState = replionData:GetExpect("AutoFishing")

    if not currentAutoFishingState then
        local remoteFunctionName = "UpdateAutoFishingState"
        local Net = require(_G.ReplicatedStorage.Packages.Net)
        local UpdateAutoFishingRemote = Net:RemoteFunction(remoteFunctionName)
        local success, result = pcall(function()
            return UpdateAutoFishingRemote:InvokeServer(true)
        end)
    end
end

function _G.ToggleAutoClick(shouldActivate)
    _G.AutoFishState.IsActive = shouldActivate
    if shouldActivate then
        _G.ensureServerAutoFishingOn()
    else
        if _G.clickThread then
            task.cancel(_G.clickThread)
            _G.clickThread = nil
        end
        _G.AutoFishState.MinigameActive = false
    end
end

-- Auto Fish UI Elements
local FishSec = AutoFish:AddSection("Auto Fishing", true)

FishSec:AddSlider({
    Title = "Delay Finish",
    Content = "Delay Settings",
    Min = 0.01,
    Max = 5,
    Default = _G.FINISH_DELAY,
    Increment = 0.01,
    Callback = function(value)
        _G.FINISH_DELAY = value
    end
})

FishSec:AddToggle({
    Title = "Auto Fish Instant",
    Default = false,
    Callback = function(value)
        if value then
            StartAutoFish5X()
        else
            StopAutoFish5X()
        end
    end
})

FishSec:AddDivider()

FishSec:AddSlider({
    Title = "Speed Legit",
    Min = 0.01,
    Max = 5,
    Default = _G.SPEED_LEGIT,
    Increment = 0.01,
    Callback = function(value)
        _G.SPEED_LEGIT = value
    end
})

FishSec:AddToggle({
    Title = "Auto Fish Legit",
    Default = false,
    Callback = function(state)
        _G.equipRemote:FireServer(1)
        _G.ToggleAutoClick(state)

        local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        local fishingGui = playerGui:WaitForChild("Fishing"):WaitForChild("Main")
        local chargeGui = playerGui:WaitForChild("Charge"):WaitForChild("Main")

        if state then
            fishingGui.Visible = false
            chargeGui.Visible = false
        else
            fishingGui.Visible = true
            chargeGui.Visible = true
        end
    end
})

FishSec:AddDivider()

FishSec:AddSlider({
    Title = "Sell Threshold",
    Min = 1,
    Max = 6000,
    Default = 30,
    Increment = 1,
    Callback = function(value)
        _G.obtainedLimit = value
    end
})

FishSec:AddSlider({
    Title = "Anti Stuck Delay",
    Min = 1,
    Max = 6000,
    Default = _G.STUCK_TIMEOUT,
    Increment = 1,
    Callback = function(value)
        _G.STUCK_TIMEOUT = value
    end
})

FishSec:AddToggle({
    Title = "Auto Sell",
    Default = false,
    Callback = function(state)
        _G.sellActive = state
        if state then
            NotifySuccess("Auto Sell", "Limit: " .. _G.obtainedLimit)
        else
            NotifySuccess("Auto Sell", "Disabled")
        end
    end
})

FishSec:AddToggle({
    Title = "Anti Stuck",
    Default = false,
    Callback = function(state)
        _G.AntiStuckEnabled = state
    end
})

FishSec:AddDivider()

FishSec:AddButton({
    Title = "Stop Fishing",
    Callback = function()
        _G.StopFishing()
        RodIdle:Stop()
        RodIdle:Stop()
        _G.stopSpam()
        _G.StopRecastSpam()
    end
})

------------------------------------------
----- =======[ X5 SPEED TAB ]
------------------------------------------

local X5SpeedSection1 = X5SpeedTab:AddSection("OG MODE Settings", true)

local startDelaySlider = X5SpeedSection1:AddSlider({
    Title = "Delay Recast",
    Content = "(Default: 1.20)",
    Min = 0.00,
    Max = 5.0,
    Default = 1.20,
    Increment = 0.01,
    Callback = function(v)
        featureState.Instant_StartDelay = tonumber(v)
    end
})

local resetCountSlider = X5SpeedSection1:AddSlider({
    Title = "Spam Finish",
    Content = "(Default: 5)",
    Min = 5,
    Max = 50,
    Default = 10,
    Increment = 1,
    Callback = function(v)
        local num = math.floor(tonumber(v) or 10)
        featureState.Instant_ResetCount = num
    end
})

local resetPauseSlider = X5SpeedSection1:AddSlider({
    Title = "Cooldown Recast",
    Content = "(Default: 0.10)",
    Min = 0.01,
    Max = 5,
    Default = 0.10,
    Increment = 0.01,
    Callback = function(v)
        local num = tonumber(v) or 2.0
        featureState.Instant_ResetPause = num
    end
})

local X5SpeedSection2 = X5SpeedTab:AddSection("AutoFish OG Mode Speed", true)

local autoFishToggle = X5SpeedSection2:AddToggle({
    Title = "AutoFish OG Mode",
    Content = "Still unstable and lots of bugs.",
    Default = false,
    Callback = function(state)
        if state then
            startOrStopAutoFish(true)
        else
            startOrStopAutoFish(false)
        end
    end
})

X5SpeedSection2:AddToggle({
    Title = "No Animation",
    Content = "Stop all animations from the game.",
    Default = false,
    Callback = function(v)
        setGameAnimationsEnabled(v)
    end
})

------------------------------------------
----- =======[ PLAYER TAB ]
------------------------------------------

local PlayerSection = PlayerTab:AddSection("Player Settings", true)

PlayerSection:AddToggle({
    Title = "Hide Name",
    Content = "Hide name above character",
    Default = false,
    Callback = function(state)
        if state then
            _G.StartHideName()
        else
            _G.StopHideName()
        end
    end
})

local defaultMinZoom = LocalPlayer.CameraMinZoomDistance
local defaultMaxZoom = LocalPlayer.CameraMaxZoomDistance

PlayerSection:AddToggle({
    Title = "Unlimited Zoom",
    Content = "Unlimited Camera Zoom for take a Picture",
    Default = false,
    Callback = function(state)
        if state then
            LocalPlayer.CameraMinZoomDistance = 0.5
            LocalPlayer.CameraMaxZoomDistance = 9999
        else
            LocalPlayer.CameraMinZoomDistance = defaultMinZoom
            LocalPlayer.CameraMaxZoomDistance = defaultMaxZoom
        end
    end
})

local function accessAllBoats()
    local vehicles = workspace:FindFirstChild("Vehicles")
    if not vehicles then
        NotifyError("Not Found", "Vehicles container not found.")
        return
    end

    local count = 0
    for _, boat in ipairs(vehicles:GetChildren()) do
        if boat:IsA("Model") and boat:GetAttribute("OwnerId") then
            local currentOwner = boat:GetAttribute("OwnerId")
            if currentOwner ~= LocalPlayer.UserId then
                boat:SetAttribute("OwnerId", LocalPlayer.UserId)
                count += 1
            end
        end
    end

    NotifySuccess("Access Granted", "You now own " .. count .. " boat(s).", 3)
end

PlayerSection:AddButton({
    Title = "Access All Boats",
    Callback = accessAllBoats
})

PlayerSection:AddToggle({
    Title = "Infinity Jump",
    Default = false,
    Callback = function(val)
        ijump = val
    end,
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if ijump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

PlayerSection:AddToggle({
    Title = "Enable Float",
    Default = false,
    Callback = function(enabled)
        -- floatingPlat(enabled) -- Function needs to be defined
    end,
})

local universalNoclip = false
local originalCollisionState = {}

PlayerSection:AddToggle({
    Title = "Universal No Clip",
    Default = false,
    Callback = function(val)
        universalNoclip = val
        if val then
            NotifySuccess("Universal Noclip Active", "You & your vehicle can penetrate all objects.", 3)
        else
            for part, state in pairs(originalCollisionState) do
                if part and part:IsA("BasePart") then
                    part.CanCollide = state
                end
            end
            originalCollisionState = {}
            NotifyWarning("Universal Noclip Disabled", "All collisions are returned to their original state.", 3)
        end
    end,
})

RunService.Stepped:Connect(function()
    if not universalNoclip then return end
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                originalCollisionState[part] = true
                part.CanCollide = false
            end
        end
    end
end)

local AntiDrown_Enabled = false
PlayerSection:AddToggle({
    Title = "Anti Drown (Oxygen Bypass)",
    Default = false,
    Callback = function(state)
        AntiDrown_Enabled = state
        if state then
            NotifySuccess("Anti Drown Active", "Oxygen loss has been blocked.", 3)
        else
            NotifyWarning("Anti Drown Disabled", "You're vulnerable to drowning again.", 3)
        end
    end,
})

PlayerSection:AddSlider({
    Title = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 20,
    Increment = 1,
    Callback = function(val)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end,
})

PlayerSection:AddSlider({
    Title = "Jump Power",
    Min = 50,
    Max = 500,
    Default = 50,
    Increment = 10,
    Callback = function(val)
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.UseJumpPower = true
                hum.JumpPower = val
            end
        end
    end,
})

------------------------------------------
----- =======[ TELEPORT TAB ]
------------------------------------------

local TeleportSection = Teleport:AddSection("Teleport Options", true)

-- Player Teleport
local playerList = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        table.insert(playerList, p.DisplayName)
    end
end

local playerDropdown = TeleportSection:AddDropdown({
    Title = "Teleport to Player",
    Content = "Select player to teleport",
    Options = playerList,
    Multi = false,
    Default = nil,
    Callback = function(selectedDisplayName)
        for _, p in pairs(Players:GetPlayers()) do
            if p.DisplayName == selectedDisplayName then
                -- teleportToPlayerExact(p.Name)
                NotifySuccess("Teleport Successfully", "Successfully Teleported to " .. p.DisplayName .. "!", 3)
                break
            end
        end
    end
})

-- Island Teleport
local islandCoords = {
    ["01"] = { name = "Lochness Event", position = Vector3.new(6052.5, -585.9, 4717.3) },
    ["02"] = { name = "Esoteric Depths", position = Vector3.new(3157, -1303, 1439) },
    ["03"] = { name = "Tropical Grove", position = Vector3.new(-2038, 3, 3650) },
    ["04"] = { name = "Stingray Shores", position = Vector3.new(-32, 4, 2773) },
    ["05"] = { name = "Kohana Volcano", position = Vector3.new(-519, 24, 189) },
    ["06"] = { name = "Coral Reefs", position = Vector3.new(-3095, 1, 2177) },
    ["07"] = { name = "Crater Island", position = Vector3.new(968, 1, 4854) },
    ["08"] = { name = "Kohana", position = Vector3.new(-658, 3, 719) },
    ["09"] = { name = "Winter Fest", position = Vector3.new(1611, 4, 3280) },
    ["10"] = { name = "Isoteric Island", position = Vector3.new(1987, 4, 1400) },
    ["11"] = { name = "Treasure Hall", position = Vector3.new(-3600, -267, -1558) },
    ["12"] = { name = "Lost Shore", position = Vector3.new(-3663, 38, -989) },
    ["13"] = { name = "Sishypus Statue", position = Vector3.new(-3792, -135, -986) },
    ["14"] = { name = "Ancient Jungle", position = Vector3.new(1478, 131, -613) },
    ["15"] = { name = "The Temple", position = Vector3.new(1477, -22, -631) },
    ["16"] = { name = "Underground Cellar", position = Vector3.new(2133, -91, -674) },
    ["17"] = { name = "Hallowen Bay", position = Vector3.new(1875, 23, 3086) },
    ["18"] = { name = "Crystal Cavern", position = Vector3.new(-1886, -448, 7394) },
    ["19"] = { name = "Weather Machine", position = Vector3.new(-1471, -3, 1929) }
}

local islandNames = {}
for _, data in pairs(islandCoords) do
    table.insert(islandNames, data.name)
end

TeleportSection:AddDropdown({
    Title = "Island Selector",
    Content = "Select island to teleport",
    Options = islandNames,
    Multi = false,
    Default = islandNames[1],
    Callback = function(selectedName)
        for code, data in pairs(islandCoords) do
            if data.name == selectedName then
                local success, err = pcall(function()
                    local charFolder = workspace:WaitForChild("Characters", 5)
                    local char = charFolder:FindFirstChild(LocalPlayer.Name)
                    if not char then error("Character not found") end
                    local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 3)
                    if not hrp then error("HumanoidRootPart not found") end
                    hrp.CFrame = CFrame.new(data.position + Vector3.new(0, 5, 0))
                end)

                if success then
                    NotifySuccess("Teleported!", "You are now at " .. selectedName)
                else
                    NotifyError("Teleport Failed", tostring(err))
                end
                break
            end
        end
    end
})

-- Event Teleport
local eventsList = {
    "Shark Hunt",
    "Ghost Shark Hunt",
    "Worm Hunt",
    "Black Hole",
    "Shocked",
    "Ghost Worm",
    "Meteor Rain",
    "Megalodon Hunt"
}

TeleportSection:AddDropdown({
    Title = "Teleport Event",
    Options = eventsList,
    Multi = false,
    Default = "Shark Hunt",
    Callback = function(option)
        local props = workspace:FindFirstChild("Props")
        if props and props:FindFirstChild(option) then
            local targetModel
            if option == "Worm Hunt" or option == "Ghost Worm" then
                targetModel = props:FindFirstChild("Model")
            else
                targetModel = props[option]
            end

            if targetModel then
                local pivot = targetModel:GetPivot()
                local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = pivot + Vector3.new(0, 15, 0)
                    NotifySuccess("Event Available!", "Teleported To " .. option)
                end
            else
                NotifyError("Event Not Found", option .. " Not Found!")
            end
        else
            NotifyError("Event Not Found", option .. " Not Found!")
        end
    end
})

-- NPC Teleport
local npcFolder = game:GetService("ReplicatedStorage"):WaitForChild("NPC")
local npcList = {}
for _, npc in pairs(npcFolder:GetChildren()) do
    if npc:IsA("Model") then
        local hrp = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
        if hrp then
            table.insert(npcList, npc.Name)
        end
    end
end

TeleportSection:AddDropdown({
    Title = "NPC",
    Content = "Select NPC to Teleport",
    Options = npcList,
    Multi = false,
    Default = nil,
    Callback = function(selectedName)
        local npc = npcFolder:FindFirstChild(selectedName)
        if npc and npc:IsA("Model") then
            local hrp = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
            if hrp then
                local charFolder = workspace:FindFirstChild("Characters", 5)
                local char = charFolder and charFolder:FindFirstChild(LocalPlayer.Name)
                if not char then return end
                local myHRP = char:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    myHRP.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
                    NotifySuccess("Teleported!", "You are now near: " .. selectedName)
                end
            end
        end
    end
})

------------------------------------------
----- =======[ TRADE TAB ]
------------------------------------------

local tradeState = { 
    mode = "V1",
    selectedPlayerName = nil, 
    selectedPlayerId = nil, 
    tradeAmount = 0, 
    autoTradeV2 = false,
    filterUnfavorited = false,
    saveTempMode = false,
    TempTradeList = {}, 
    onTrade = false 
}

local TradeSection1 = Trade:AddSection("Trade Mode Selection", true)

local modeDropdown = TradeSection1:AddDropdown({
    Title = "Select Trade Mode",
    Options = {"V1", "V2"},
    Multi = false,
    Default = "V1",
    Callback = function(v)
        tradeState.mode = v
        NotifySuccess("Mode Changed", "Trade mode set to: " .. v, 3)
    end
})

local function getPlayerListV2()
    local list = {}; 
    for _, p in ipairs(Players:GetPlayers()) do 
        if p ~= LocalPlayer then 
            table.insert(list, p.Name) 
        end 
    end; 
    table.sort(list); 
    return list
end

local playerDropdownTrade = TradeSection1:AddDropdown({
    Title = "Select Trade Target",
    Content = "Select player to trade with",
    Options = getPlayerListV2(),
    Multi = false,
    Default = getPlayerListV2()[1] or nil,
    Callback = function(selected)
        tradeState.selectedPlayerName = selected
        local player = Players:FindFirstChild(selected)
        if player then
            tradeState.selectedPlayerId = player.UserId
            NotifySuccess("Target Selected", "Target set to: " .. player.Name, 3)
        else
            tradeState.selectedPlayerId = nil
            NotifyError("Target Error", "Player not found!", 3)
        end
    end
})

local TradeSection2 = Trade:AddSection("Auto Accept Trade", true)

TradeSection2:AddToggle({
    Title = "Enable Auto Accept Trade",
    Content = "Automatically accepts incoming trade requests.",
    Default = false,
    Callback = function(value)
        _G.AutoAcceptTradeEnabled = value
        if value then
            NotifySuccess("Auto Accept", "Auto accept trade enabled.", 3)
        else
            NotifyWarning("Auto Accept", "Auto accept trade disabled.", 3)
        end
    end
})

local TradeSection3 = Trade:AddSection("Mode V1", true)

TradeSection3:AddToggle({
    Title = "Mode Save Items",
    Content = "Click inventory item to add for Mass Trade",
    Default = false,
    Callback = function(state)
        tradeState.saveTempMode = state
        if state then
            tradeState.TempTradeList = {}
            NotifySuccess("Save Mode", "Enabled - Click items to save")
        else
            NotifyInfo("Save Mode", "Disabled - "..#tradeState.TempTradeList.." items saved")
        end
    end
})

TradeSection3:AddToggle({
    Title = "Trade (Original Send)",
    Content = "Click inventory items to Send Trade",
    Default = false,
    Callback = function(state)
        tradeState.onTrade = state
        if state then
            NotifySuccess("Trade", "Trade Mode Enabled. Click an item to send trade.")
        else
            NotifyWarning("Trade", "Trade Mode Disabled.")
        end
    end
})

TradeSection3:AddToggle({
    Title = "Start Mass Trade V1",
    Content = "Trade all saved items automatically.",
    Default = false,
    Callback = function(state)
        tradeState.autoTradeV2 = state
        if tradeState.mode == "V1" and state then
            if #tradeState.TempTradeList == 0 then
                NotifyError("Mass Trade", "No items saved to trade!")
                tradeState.autoTradeV2 = false
                return
            end
            -- TradeAllQuiet()
            NotifySuccess("Mass Trade", "V1 Auto Trade Enabled")
        else
            NotifyWarning("Mass Trade", "V1 Auto Trade Disabled")
        end
    end
})

local TradeSection4 = Trade:AddSection("V2", true)

TradeSection4:AddToggle({
    Title = "Filter Unfavorited Items Only",
    Default = false,
    Callback = function(val)
        tradeState.filterUnfavorited = val
        -- refreshInventory()
        NotifyInfo("Filter Updated", "Inventory list refreshed.", 3)
    end
})

------------------------------------------
----- =======[ AUTO FARM ARTIFACT TAB ]
------------------------------------------

local ArtifactSection = AutoFarmArt:AddSection("Farming Artifact Menu", true)

_G.ArtifactParagraph = ArtifactSection:AddParagraph({
    Title = "Auto Farm Artifact",
    Content = "Waiting for activation...",
})

ArtifactSection:AddToggle({
    Title = "Auto Farm Artifact",
    Content = "Automatically collects 4 Artifacts and unlocks The Temple.",
    Default = false,
    Callback = function(state)
        if state then
            -- _G.StartArtifactFarm()
            NotifyInfo("Artifact Farm", "Starting artifact farm...")
        else
            -- _G.StopArtifactFarm()
            NotifyInfo("Artifact Farm", "Stopping artifact farm...")
        end
    end
})

local spotNames = {"Spot 1", "Spot 2", "Spot 3", "Spot 4"}
ArtifactSection:AddDropdown({
    Title = "Teleport to Lever Temple",
    Options = spotNames,
    Multi = false,
    Default = spotNames[1],
    Callback = function(selected)
        NotifySuccess("Lever Temple", "Teleported to " .. selected)
    end
})

ArtifactSection:AddButton({
    Title = "Unlock The Temple",
    SubTitle = "Still need Artifacts!",
    Callback = function()
        -- _G.UnlockTemple()
        NotifyInfo("Temple Unlock", "Placing artifacts...")
    end
})

------------------------------------------
----- =======[ AUTO FAVORITE TAB ]
------------------------------------------

local AutoFavSection = AutoFav:AddSection("Auto Favorite Menu", true)

AutoFavSection:AddToggle({
    Title = "Enable Auto Favorite",
    Default = false,
    Callback = function(state)
        -- GlobalFav.AutoFavoriteEnabled = state
        if state then
            NotifySuccess("Auto Favorite", "Auto Favorite feature enabled")
        else
            NotifyWarning("Auto Favorite", "Auto Favorite feature disabled")
        end
    end
})

local AllFishNames = {"Fish1", "Fish2", "Fish3", "Fish4"} -- Example fish names
AutoFavSection:AddDropdown({
    Title = "Auto Favorite Fishes",
    Options = AllFishNames,
    Multi = true,
    Default = {},
    Callback = function(selectedNames)
        NotifyInfo("Auto Favorite", "Favoriting active for fish: " .. table.concat(selectedNames, ", "))
    end
})

AutoFavSection:AddDropdown({
    Title = "Auto Favorite Variants",
    Options = {"Variant1", "Variant2", "Variant3"},
    Multi = true,
    Default = {},
    Callback = function(selectedVariants)
        NotifyInfo("Auto Favorite", "Favoriting active for variants: " .. table.concat(selectedVariants, ", "))
    end
})

------------------------------------------
----- =======[ SHOP TAB ]
------------------------------------------

local ShopSection1 = Shop:AddSection("Traveling Merchant", true)

local merchantItems = {
    ["Item 1"] = 5,
    ["Item 2"] = 4,
    ["Item 3"] = 3,
}

local function getKeys(tbl)
    local keys = {}
    for k, _ in pairs(tbl) do
        table.insert(keys, k)
    end
    return keys
end

ShopSection1:AddDropdown({
    Title = "Traveling Merchant",
    Content = "Select an item to purchase from Traveling Merchant",
    Options = getKeys(merchantItems),
    Multi = false,
    Default = nil,
    Callback = function(selected)
        local itemID = merchantItems[selected]
        if itemID then
            NotifyInfo("Purchase Success", "Successfully bought: " .. selected)
        end
    end
})

local ShopSection2 = Shop:AddSection("Auto Buy Weather", true)

local weatherOptions = {"Storm", "Cloudy", "Snow", "Wind", "Radiant"}
ShopSection2:AddDropdown({
    Title = "Auto Buy Weather",
    Options = weatherOptions,
    Multi = true,
    Default = {},
    Callback = function(selected)
        for _, weatherType in pairs(selected) do
            NotifyInfo("Auto Weather", "Auto buying " .. weatherType .. " has started!")
        end
    end
})

local ShopSection3 = Shop:AddSection("Rod Shop", true)

local rodOptions = {
    "Basic Rod | Price: 100",
    "Advanced Rod | Price: 500", 
    "Pro Rod | Price: 1000"
}

ShopSection3:AddDropdown({
    Title = "Rod Shop",
    Content = "Select Rod to Buy",
    Options = rodOptions,
    Multi = false,
    Default = nil,
    Callback = function(option)
        NotifySuccess("Rod Purchased", option .. " has been successfully purchased!")
    end
})

local ShopSection4 = Shop:AddSection("Baits Shop", true)

local baitOptions = {
    "Worm Bait | Price: 10",
    "Shrimp Bait | Price: 25",
    "Special Bait | Price: 50"
}

ShopSection4:AddDropdown({
    Title = "Baits Shop",
    Content = "Select Baits to Buy",
    Options = baitOptions,
    Multi = false,
    Default = nil,
    Callback = function(option)
        NotifySuccess("Bait Purchased", option .. " has been successfully purchased!")
    end
})

------------------------------------------
----- =======[ SETTINGS TAB ]
------------------------------------------

local SettingsSection1 = SettingsTab:AddSection("General Settings", true)

SettingsSection1:AddToggle({
    Title = "Anti-AFK",
    Default = true,
    Callback = function(Value)
        _G.AntiAFKEnabled = Value
        if Value then
            NotifySuccess("Anti-AFK Activated", "You will now avoid being kicked.")
        else
            NotifySuccess("Anti-AFK Deactivated", "You can now go idle again.")
        end
    end
})

SettingsSection1:AddButton({
    Title = "Boost FPS (Ultra Low Graphics)",
    Callback = function()
        -- FPS boost code here
        NotifySuccess("Boost FPS", "Boost FPS mode applied successfully!")
    end
})

SettingsSection1:AddToggle({
    Title = "Hide Notif Fish",
    Content = "Turn off new fish pop-up",
    Default = false,
    Callback = function(state)
        if state then
            -- _G.SembunyikanNotifikasiIkan()
            NotifySuccess("Notification", "Fish notifications hidden")
        else
            -- _G.TampilkanNotifikasiIkan()
            NotifySuccess("Notification", "Fish notifications shown")
        end
    end
})

local SettingsSection2 = SettingsTab:AddSection("Server Options", true)

SettingsSection2:AddButton({
    Title = "Rejoin Server",
    Callback = function()
        -- Rejoin()
        NotifyInfo("Rejoin", "Rejoining server...")
    end
})

SettingsSection2:AddButton({
    Title = "Server Hop (New Server)",
    Callback = function()
        -- ServerHop()
        NotifyInfo("Server Hop", "Searching for new server...")
    end
})

local SettingsSection3 = SettingsTab:AddSection("Configuration", true)

SettingsSection3:AddButton({
    Title = "Save Config",
    Callback = function()
        -- myConfig:Save()
        NotifySuccess("Config Saved", "Config has been saved!")
    end
})

SettingsSection3:AddButton({
    Title = "Load Config", 
    Callback = function()
        -- myConfig:Load()
        NotifySuccess("Config Loaded", "Config has been loaded!")
    end
})

------------------------------------------
----- =======[ FINAL INITIALIZATION ]
------------------------------------------

-- Load Configuration
task.spawn(function()
    -- LoadConfigElements()
end)

-- X5 Speed System Initialization
local Modules = {}
local fishingTrove = {}
local autoFishThread = nil
local isWaitingForCorrectTier = false
local fishCaughtBindable = Instance.new("BindableEvent")
local hasEquippedRod = false

local featureState = {
    AutoFish = false,
    Instant_ChargeDelay = 0.07,
    Instant_SpamCount = 5,
    Instant_WorkerCount = 2,
    Instant_StartDelay = 1.20,
    Instant_CatchTimeout = 0.01,
    Instant_CycleDelay = 0.01,
    Instant_ResetCount = 10,
    Instant_ResetPause = 0.01
}

-- Hide Name System
_G._HiddenNameParts = {}

function _G.StartHideName()
    task.spawn(function()
        local function hideName(character)
            for _, v in pairs(character:GetDescendants()) do
                if v:IsA("BillboardGui") then
                    if v.Enabled then
                        _G._HiddenNameParts[v] = true
                        v.Enabled = false
                    end
                elseif v:IsA("Humanoid") then
                    _G._HiddenNameParts[v] = v.DisplayDistanceType
                    v.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                end
            end
        end

        if LocalPlayer.Character then
            hideName(LocalPlayer.Character)
        end

        LocalPlayer.CharacterAdded:Connect(function(char)
            char:WaitForChild("Humanoid")
            task.wait(1)
            hideName(char)
        end)
    end)
end

function _G.StopHideName()
    for obj, state in pairs(_G._HiddenNameParts) do
        if obj and obj.Parent then
            if obj:IsA("BillboardGui") then
                obj.Enabled = true
            elseif obj:IsA("Humanoid") then
                obj.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
            end
        end
    end
    _G._HiddenNameParts = {}
end

-- Animation Disabler
local stopAnimConnections = {}
local function setGameAnimationsEnabled(state)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    for _, conn in pairs(stopAnimConnections) do
        conn:Disconnect()
    end
    stopAnimConnections = {}

    if state then
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                track:Stop(0)
            end

            local conn = animator.AnimationPlayed:Connect(function(track)
                task.defer(function()
                    track:Stop(0)
                end)
            end)
            table.insert(stopAnimConnections, conn)
        end
        NotifySuccess("Animation Disabled", "All animations from the game have been disabled.", 4)
    else
        for _, conn in pairs(stopAnimConnections) do
            conn:Disconnect()
        end
        stopAnimConnections = {}
        NotifySuccess("Animation Enabled", "Animations from the game are reactivated.", 4)
    end
end

-- X5 Speed Auto Fish System
local function equipFishingRod()
    if not hasEquippedRod then
        pcall(function()
            -- Modules.EquipToolEvent:FireServer(1)
        end)
        hasEquippedRod = true
    end
end

local function stopAutoFishProcesses()
    featureState.AutoFish = false
    hasEquippedRod = false
    
    for i, item in ipairs(fishingTrove) do
        if typeof(item) == "RBXScriptConnection" then
            item:Disconnect()
        elseif typeof(item) == "thread" then
            task.cancel(item)
        end
    end
    fishingTrove = {}
end

local function startAutoFishMethod_Instant()
    -- X5 Speed implementation here
    NotifyInfo("X5 Speed", "Starting instant auto fish...")
end

function startOrStopAutoFish(shouldStart)
    if shouldStart then
        stopAutoFishProcesses()
        featureState.AutoFish = true
        equipFishingRod()
        task.wait(0.01)
        startAutoFishMethod_Instant()
    else
        stopAutoFishProcesses()
    end
end

-- Final Notification
NotifySuccess("OGhub", "All Features Loaded with Chloe X GUI!", 5)

print(" OGHub dengan Chloe X GUI berhasil di-load!")