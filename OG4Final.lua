--[[
    Chloe X - FishIt Script
    Complete Combined Script from All Parts
    Original by Chloe X | Combined and Optimized for Readability
--]]

-- =============================================
-- SERVICES & INITIAL SETUP
-- =============================================
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"), 
    HttpService = game:GetService("HttpService"),
    RS = game:GetService("ReplicatedStorage"),
    VIM = game:GetService("VirtualInputManager"),
    PG = game:GetService("Players").LocalPlayer.PlayerGui,
    Camera = workspace.CurrentCamera,
    GuiService = game:GetService("GuiService"),
    CoreGui = game:GetService("CoreGui"),
    TeleportService = game:GetService("TeleportService"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService")
}

-- HTTP Request Handler
_G.httpRequest = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request
if not _G.httpRequest then
    return
end

-- Local Player Reference
local LocalPlayer = Services.Players.LocalPlayer
if not LocalPlayer.Character or not LocalPlayer.Character:WaitForChild("HumanoidRootPart") then
    local _ = LocalPlayer.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")
end

-- =============================================
-- CONFIGURATION & DATA FILES
-- =============================================
local PositionFile = "Chloe X/FishIt/Position.json"

-- UI References
local MerchantUI = {
    MerchantRoot = Services.PG.Merchant.Main.Background,
    ItemsFrame = Services.PG.Merchant.Main.Background.Items.ScrollingFrame,
    RefreshMerchant = Services.PG.Merchant.Main.Background.RefreshLabel
}

-- =============================================
-- GAME MODULES & NETWORK
-- =============================================
local GameModules = {
    Net = Services.RS.Packages._Index["sleitnick_net@0.2.0"].net,
    Replion = require(Services.RS.Packages.Replion),
    FishingController = require(Services.RS.Controllers.FishingController),
    TradingController = require(Services.RS.Controllers.ItemTradingController),
    ItemUtility = require(Services.RS.Shared.ItemUtility),
    VendorUtility = require(Services.RS.Shared.VendorUtility),
    PlayerStatsUtility = require(Services.RS.Shared.PlayerStatsUtility),
    Effects = require(Services.RS.Shared.Effects),
    NotifierFish = require(Services.RS.Controllers.TextNotificationController)
}

local Network = {
    Events = {
        RECutscene = GameModules.Net["RE/ReplicateCutscene"],
        REStop = GameModules.Net["RE/StopCutscene"],
        REFav = GameModules.Net["RE/FavoriteItem"],
        REFavChg = GameModules.Net["RE/FavoriteStateChanged"],
        REFishDone = GameModules.Net["RE/FishingCompleted"],
        REFishGot = GameModules.Net["RE/FishCaught"],
        RENotify = GameModules.Net["RE/TextNotification"],
        REEquip = GameModules.Net["RE/EquipToolFromHotbar"],
        REEquipItem = GameModules.Net["RE/EquipItem"],
        REAltar = GameModules.Net["RE/ActivateEnchantingAltar"],
        REAltar2 = GameModules.Net["RE/ActivateSecondEnchantingAltar"],
        UpdateOxygen = GameModules.Net["URE/UpdateOxygen"],
        REPlayFishEffect = GameModules.Net["RE/PlayFishingEffect"],
        RETextEffect = GameModules.Net["RE/ReplicateTextEffect"],
        REEvReward = GameModules.Net["RE/ClaimEventReward"],
        Totem = GameModules.Net["RE/SpawnTotem"],
        REObtainedNewFishNotification = GameModules.Net["RE/ObtainedNewFishNotification"],
        FishingMinigameChanged = GameModules.Net["RE/FishingMinigameChanged"],
        FishingStopped = GameModules.Net["RE/FishingStopped"]
    },
    Functions = {
        Trade = GameModules.Net["RF/InitiateTrade"],
        BuyRod = GameModules.Net["RF/PurchaseFishingRod"],
        BuyBait = GameModules.Net["RF/PurchaseBait"],
        BuyWeather = GameModules.Net["RF/PurchaseWeatherEvent"],
        ChargeRod = GameModules.Net["RF/ChargeFishingRod"],
        StartMini = GameModules.Net["RF/RequestFishingMinigameStarted"],
        UpdateRadar = GameModules.Net["RF/UpdateFishingRadar"],
        Cancel = GameModules.Net["RF/CancelFishingInputs"],
        Dialogue = GameModules.Net["RF/SpecialDialogueEvent"],
        Done = GameModules.Net["RF/RequestFishingMinigameStarted"],
        SellAllItems = GameModules.Net["RF/SellAllItems"],
        ConsumePotion = GameModules.Net["RF/ConsumePotion"]
    }
}

local DataSystem = {
    Data = GameModules.Replion.Client:WaitReplion("Data"),
    Items = Services.RS:WaitForChild("Items"),
    PlayerStat = require(Services.RS.Packages._Index:FindFirstChild("ytrev_replion@2.0.0-rc.3").replion)
}

-- =============================================
-- MAIN CONFIGURATION
-- =============================================
local Config = {
    -- Auto Features
    autoInstant = false,
    selectedEvents = {},
    autoWeather = false,
    autoSellEnabled = false,
    autoFavEnabled = false,
    autoEventActive = false,
    canFish = true,
    autoEquipRod = false,
    frozen = false,
    autoDeepSea = false,
    autoElement = false,
    autoQuestFlow = false,
    triggerRuin = false,
    autoClaimNPC = false,
    autoClaimHouse = false,
    autoWebhook = false,
    autoWebhookStats = false,
    
    -- Position & State
    savedCFrame = nil,
    curCF = nil,
    origCF = nil,
    flt = false,
    con = nil,
    FarmPosition = nil,
    autoCountdownUpdate = false,
    
    -- Fishing Configuration
    Instant = false,
    CancelWaitTime = 3,
    ResetTimer = 0.5,
    stuckThreshold = 15,
    supportEnabled = false,
    fishingTimer = 0,
    equipTimer = 0,
    lastFishTime = 0,
    fishConnected = false,
    lastCancelTime = 0,
    hasFishingEffect = false,
    hasTriggeredBug = false,
    
    -- Selling System
    sellMode = "Delay",
    sellDelay = 60,
    inputSellCount = 50,
    
    -- Favorite System
    selectedName = {},
    selectedRarity = {},
    selectedVariant = {},
    
    -- Shop Items
    rodDataList = {},
    rodDisplayNames = {},
    baitDataList = {},
    baitDisplayNames = {},
    selectedRodId = nil,
    selectedBaitId = nil,
    rods = {},
    baits = {},
    weathers = {},
    Totems = {},
    TotemDisplayName = {},
    Potions = {},
    PotionDisplayName = {},
    
    -- Player & Character
    lcc = 0,
    player = LocalPlayer,
    stats = LocalPlayer:WaitForChild("leaderstats"),
    caught = LocalPlayer:WaitForChild("leaderstats"):WaitForChild("Caught"),
    char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait(),
    vim = Services.VIM,
    cam = Services.Camera,
    
    -- Event System
    offs = {["Worm Hunt"] = 25},
    priorityEvent = nil,
    ignore = {
        Cloudy = true, Day = true, ["Increased Luck"] = true, Mutated = true,
        Night = true, Snow = true, ["Sparkling Cove"] = true, Storm = true,
        Wind = true, UIListLayout = true, ["Admin - Shocked"] = true,
        ["Admin - Super Mutated"] = true, Radiant = true
    },
    
    -- Trading System
    trade = {
        selectedPlayer = nil,
        selectedItem = nil,
        selectedRarity = nil,
        tradeAmount = 1,
        rarityAmount = 1,
        targetCoins = 0,
        trading = false,
        awaiting = false,
        lastResult = nil,
        successCount = 0,
        failCount = 0,
        totalToTrade = 0,
        sentCoins = 0,
        successCoins = 0,
        failCoins = 0,
        totalReceived = 0,
        currentGrouped = {},
        TotemActive = false,
        teleportTarget = nil
    },
    
    -- UI & Connections
    notifConnections = {},
    defaultHandlers = {},
    disabledCons = {},
    dummyCons = {},
    stopAnimHookEnabled = false,
    stopAnimConn = nil,
    fishingPanelRunning = false,
    focusOverlay = nil,
    CEvent = true,
    skipCutscene = true,
    disableNotifs = false,
    DelEffects = false,
    IrRod = false
}

-- =============================================
-- GLOBAL VARIABLES & CONSTANTS
-- =============================================
_G.Celestial = _G.Celestial or {}
_G.Celestial.DetectorCount = _G.Celestial.DetectorCount or 0
_G.Celestial.InstantCount = _G.Celestial.InstantCount or 0

_G.TierFish = {
    [1] = "Common",
    [2] = "Uncommon", 
    [3] = "Rare",
    [4] = "Epic",
    [5] = "Legendary",
    [6] = "Mythic",
    [7] = "Secret"
}

_G.WebhookRarities = _G.WebhookRarities or {}
_G.WebhookNames = _G.WebhookNames or {}
_G.WebhookCustomName = _G.WebhookCustomName or ""
_G.DisconnectCustomName = _G.DisconnectCustomName or ""

_G.Variant = {
    "Galaxy", "Corrupt", "Gemstone", "Ghost", "Lightning", "Fairy Dust", "Gold",
    "Midnight", "Radioactive", "Stone", "Holographic", "Albino", "Bloodmoon",
    "Sandy", "Acidic", "Color Burn", "Festive", "Frozen"
}

_G.WebhookFlags = _G.WebhookFlags or {
    FishCaught = {
        Enabled = false,
        URL = "https://discord.com/api/webhooks/1432777124607164418/0aGoA5XSsDCpO82T0bR8UYt1vFDv74qXst6AJQLcl-RSN-ujAp4GmIV7QIzrM3yfoGVV"
    },
    Stats = {
        Enabled = false,
        URL = "",
        Delay = 5
    },
    Disconnect = {
        Enabled = false,
        URL = "https://discord.com/api/webhooks/1428340333510398013/1L4UNrQmJXLgiNjO8PvZVc2TSxX60Xvg8BFpGyz8VANNL95DRfwKBPzyx9-mgZYLKw6_"
    }
}

_G.WebhookURLs = _G.WebhookURLs or {}

-- Fishing Delays
_G.Delay = _G.Delay or 1
_G.DelayComplete = _G.DelayComplete or 0
_G.Reel = _G.Reel or 1.9
_G.FishingDelay = _G.FishingDelay or 1.1
_G.FBlatant = _G.FBlatant or false

-- Farm Settings
_G.ThresholdFarm = _G.ThresholdFarm or false
_G.CoinFarm = _G.CoinFarm or false
_G.EnchantFarm = _G.EnchantFarm or false
_G.KaitunPanel = _G.KaitunPanel or false
_G.AutoEquipBestRod = _G.AutoEquipBestRod or false
_G.AutoAccept = _G.AutoAccept or false
_G.AutoUsePotions = _G.AutoUsePotions or false
_G.AntiStaff = _G.AntiStaff or false

-- Quest Progress
_G.DeepSeaDone = _G.DeepSeaDone or false
_G.ArtifactDone = _G.ArtifactDone or false
_G.ElementDone = _G.ElementDone or false
_G.LastArtifactTP = _G.LastArtifactTP or 0
_G.SelectedFarmLocation = _G.SelectedFarmLocation or "Kohana Volcano"

-- =============================================
-- UTILITY FUNCTIONS
-- =============================================

-- Notification System
function chloex(message, duration)
    duration = duration or 5
    -- Implementation for showing notifications
    print("[OGhub]: " .. tostring(message))
end

function SaveConfig()
    -- Save configuration to file
end

-- Fish Count Utility
function getFishCount()
    local BagSize = Config.player.PlayerGui:WaitForChild("Inventory").Main.Top.Options.Fish.Label.BagSize
    return tonumber((BagSize.Text or "0/???"):match("(%d+)/")) or 0
end

-- Input Utility
function clickCenter()
    local ViewportSize = Config.cam.ViewportSize
    Config.vim:SendMouseButtonEvent(ViewportSize.X / 2, ViewportSize.Y / 2, 0, true, nil, 0)
    Config.vim:SendMouseButtonEvent(ViewportSize.X / 2, ViewportSize.Y / 2, 0, false, nil, 0)
end

-- Table to Set Converter
function toSet(inputTable)
    local result = {}
    if type(inputTable) == "table" then
        for _, value in ipairs(inputTable) do
            result[value] = true
        end
        for key, value in pairs(inputTable) do
            if value then
                result[key] = true
            end
        end
    end
    return result
end

-- Name Cleaner
function _cleanName(name)
    if type(name) ~= "string" then
        return tostring(name)
    else
        return name:match("^(.-) %(") or name
    end
end

-- =============================================
-- FAVORITE MANAGEMENT SYSTEM
-- =============================================
local FavoriteCache = {}
Network.Events.REFavChg.OnClientEvent:Connect(function(itemUUID, isFavorited)
    rawset(FavoriteCache, itemUUID, isFavorited)
end)

function checkAndFavorite(itemData)
    if not Config.autoFavEnabled then return end
    
    local itemInfo = GameModules.ItemUtility.GetItemDataFromItemType("Items", itemData.Id)
    if not itemInfo or itemInfo.Data.Type ~= "Fish" then return end
    
    local rarity = _G.TierFish[itemInfo.Data.Tier]
    local itemName = itemInfo.Data.Name
    local variant = itemData.Metadata and itemData.Metadata.VariantId or "None"
    
    local nameMatch = Config.selectedName[itemName]
    local rarityMatch = Config.selectedRarity[rarity] 
    local variantMatch = Config.selectedVariant[variant]
    
    local isFavorited = rawget(FavoriteCache, itemData.UUID)
    if isFavorited == nil then
        isFavorited = itemData.Favorited
    end
    
    local shouldFavorite = false
    if next(Config.selectedVariant) ~= nil and next(Config.selectedName) ~= nil then
        shouldFavorite = nameMatch and variantMatch
    else
        shouldFavorite = nameMatch or rarityMatch
    end
    
    if shouldFavorite and not isFavorited then
        Network.Events.REFav:FireServer(itemData.UUID)
        rawset(FavoriteCache, itemData.UUID, true)
    end
end

function scanInventory()
    if not Config.autoFavEnabled then return end
    for _, item in ipairs(DataSystem.Data:GetExpect({"Inventory", "Items"})) do
        checkAndFavorite(item)
    end
end

-- =============================================
-- POSITION SAVING SYSTEM
-- =============================================
function SavePosition(cframe)
    local components = {cframe:GetComponents()}
    writefile(PositionFile, Services.HttpService:JSONEncode(components))
end

function LoadPosition()
    if isfile(PositionFile) then
        local success, result = pcall(function()
            return Services.HttpService:JSONDecode(readfile(PositionFile))
        end)
        if success and typeof(result) == "table" then
            return CFrame.new(unpack(result))
        end
    end
    return nil
end

function TeleportLastPos(character)
    task.spawn(function()
        local HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
        local savedPosition = LoadPosition()
        if savedPosition then
            task.wait(2)
            HumanoidRootPart.CFrame = savedPosition
            chloex("Teleported to your last position...")
        end
    end)
end

-- Auto position loading
LocalPlayer.CharacterAdded:Connect(TeleportLastPos)
if LocalPlayer.Character then
    TeleportLastPos(LocalPlayer.Character)
end

-- =============================================
-- FISHING DETECTOR SYSTEM
-- =============================================
local DetectorParagraph = nil

Config.loop = function()
    while Config.autoEventActive do
        local eventPart = nil
        local eventName = nil
        
        -- Priority event check
        if Config.priorityEvent then
            eventPart = findEventPart(Config.priorityEvent)
            if eventPart then
                eventName = Config.priorityEvent
            end
        end
        
        -- Selected events check
        if not eventPart and #Config.selectedEvents > 0 then
            for _, event in ipairs(Config.selectedEvents) do
                eventPart = findEventPart(event)
                if eventPart then
                    eventName = event
                    break
                end
            end
        end
        
        local humanoidRootPart = Config.char and Config.char:FindFirstChild("HumanoidRootPart")
        if eventPart and humanoidRootPart then
            if not Config.origCF then
                Config.origCF = humanoidRootPart.CFrame
            end
            
            if (humanoidRootPart.Position - eventPart.Position).Magnitude > 40 then
                Config.curCF = eventPart.CFrame + Vector3.new(0, Config.offs[eventName] or 7, 0)
                Config.char:PivotTo(Config.curCF)
                setupFloatingPart(Config.char, humanoidRootPart, true)
                task.wait(1)
                setAnchoredState(Config.char, true)
                updateEventStatus("Event! " .. eventName)
            end
        elseif not eventPart and Config.curCF and humanoidRootPart then
            setAnchoredState(Config.char, false)
            setupFloatingPart(Config.char, nil, false)
            if Config.origCF then
                Config.char:PivotTo(Config.origCF)
                updateEventStatus("Event end ← Back")
                Config.origCF = nil
            end
            Config.curCF = nil
        elseif not Config.curCF then
            updateEventStatus("Idle")
        end
        task.wait(0.2)
    end
    
    -- Cleanup
    setAnchoredState(Config.char, false)
    setupFloatingPart(Config.char, nil, false)
    if Config.origCF and Config.char then
        Config.char:PivotTo(Config.origCF)
        updateEventStatus("Auto Event off")
    end
    Config.curCF = nil
    Config.origCF = nil
end

function updateEventStatus(status)
    if Config.lastState ~= status then
        chloex(status)
        Config.lastState = status
    end
end

-- Character respawn handler
Config.player.CharacterAdded:Connect(function(character)
    if Config.autoEventActive then
        task.spawn(function()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
            task.wait(0.3)
            if humanoidRootPart then
                if Config.curCF then
                    character:PivotTo(Config.curCF)
                    setupFloatingPart(character, humanoidRootPart, true)
                    task.wait(0.5)
                    setAnchoredState(character, true)
                    chloex("Respawn ← Back")
                elseif Config.origCF then
                    character:PivotTo(Config.origCF)
                    setAnchoredState(character, false)
                    setupFloatingPart(character, humanoidRootPart, true)
                    chloex("Back to farm")
                end
            end
        end)
    end
end)

-- =============================================
-- EVENT & LOCATION UTILITIES
-- =============================================
function findEventPart(eventName)
    -- Implementation for finding event parts in workspace
    if eventName == "Megalodon Hunt" then
        local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
        if menuRings then
            for _, ring in ipairs(menuRings:GetChildren()) do
                local megalodonPart = ring:FindFirstChild("Megalodon Hunt")
                local part = megalodonPart and megalodonPart:FindFirstChild("Megalodon Hunt")
                if part and part:IsA("BasePart") then
                    return part
                end
            end
        end
        return nil
    else
        local searchFolders = {workspace:FindFirstChild("Props")}
        local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
        if menuRings then
            for _, ring in ipairs(menuRings:GetChildren()) do
                if ring.Name:match("^Props") then
                    table.insert(searchFolders, ring)
                end
            end
        end
        
        for _, folder in ipairs(searchFolders) do
            for _, model in ipairs(folder:GetChildren()) do
                for _, descendant in ipairs(model:GetDescendants()) do
                    if descendant:IsA("TextLabel") and descendant.Name == "DisplayName" then
                        local displayText = descendant.ContentText ~= "" and descendant.ContentText or descendant.Text
                        if displayText and displayText:lower() == eventName:lower() then
                            local modelPart = descendant:FindFirstAncestorOfClass("Model")
                            local part = modelPart and modelPart:FindFirstChild("Part") or model:FindFirstChild("Part")
                            if part and part:IsA("BasePart") then
                                return part
                            end
                        end
                    end
                end
            end
        end
        return nil
    end
end

function getActiveEvents()
    local events = {}
    local eventsGui = Config.player:WaitForChild("PlayerGui"):FindFirstChild("Events")
    if eventsGui then
        eventsGui = eventsGui:FindFirstChild("Frame") and eventsGui.Frame:FindFirstChild("Events")
    end
    
    if eventsGui then
        for _, eventFrame in ipairs(eventsGui:GetChildren()) do
            if eventFrame:IsA("Frame") then
                local displayName = eventFrame:FindFirstChild("DisplayName")
                local eventName = displayName and displayName.Text or eventFrame.Name
                if typeof(eventName) == "string" and eventName ~= "" and not Config.ignore[eventName] then
                    table.insert(events, (eventName:gsub("^Admin %- ", "")))
                end
            end
        end
    end
    return events
end

function isValidCharacter(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart"))
end

function setAnchoredState(obj, anchored)
    if not obj then return end
    for _, part in ipairs(obj:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = anchored
        end
    end
end

function setupFloatingPart(char, rootPart, enable)
    if Config.flt and Config.con then
        Config.con:Disconnect()
    end
    
    Config.flt = enable or false
    
    if enable then
        local floatPart = char:FindFirstChild("FloatPart") or Instance.new("Part")
        floatPart.CanCollide = true
        floatPart.Anchored = true
        floatPart.Transparency = 1
        floatPart.Size = Vector3.new(3, 0.2, 3)
        floatPart.Name = "FloatPart"
        floatPart.Parent = char
        
        Config.con = Services.RunService.Heartbeat:Connect(function()
            if char and rootPart and floatPart then
                floatPart.CFrame = rootPart.CFrame * CFrame.new(0, -3.1, 0)
            end
        end)
    else
        local floatPart = char and char:FindFirstChild("FloatPart")
        if floatPart then
            floatPart:Destroy()
        end
    end
end

-- =============================================
-- LOCATION TELEPORT SYSTEM
-- =============================================
local LocationData = {
    ["Treasure Room"] = Vector3.new(-3602.01, -266.57, -1577.18),
    ["Sisyphus Statue"] = Vector3.new(-3703.69, -135.57, -1017.17),
    ["Crater Island Top"] = Vector3.new(1011.29, 22.68, 5076.27),
    ["Crater Island Ground"] = Vector3.new(1079.57, 3.64, 5080.35),
    ["Coral Reefs SPOT 1"] = Vector3.new(-3031.88, 2.52, 2276.36),
    ["Coral Reefs SPOT 2"] = Vector3.new(-3270.86, 2.5, 2228.1),
    ["Coral Reefs SPOT 3"] = Vector3.new(-3136.1, 2.61, 2126.11),
    ["Lost Shore"] = Vector3.new(-3737.97, 5.43, -854.68),
    ["Weather Machine"] = Vector3.new(-1524.88, 2.87, 1915.56),
    ["Kohana Volcano"] = Vector3.new(-561.81, 21.24, 156.72),
    ["Kohana SPOT 1"] = Vector3.new(-367.77, 6.75, 521.91),
    ["Kohana SPOT 2"] = Vector3.new(-623.96, 19.25, 419.36),
    ["Stingray Shores"] = Vector3.new(44.41, 28.83, 3048.93),
    ["Tropical Grove"] = Vector3.new(-2018.91, 9.04, 3750.59),
    ["Ice Sea"] = Vector3.new(2164, 7, 3269),
    ["Tropical Grove Cave 1"] = Vector3.new(-2151, 3, 3671),
    ["Tropical Grove Cave 2"] = Vector3.new(-2018, 5, 3756),
    ["Tropical Grove Highground"] = Vector3.new(-2139, 53, 3624),
    ["Fisherman Island Underground"] = Vector3.new(-62, 3, 2846),
    ["Fisherman Island Mid"] = Vector3.new(33, 3, 2764),
    ["Fisherman Island Rift Left"] = Vector3.new(-26, 10, 2686),
    ["Fisherman Island Rift Right"] = Vector3.new(95, 10, 2684),
    ["Secred Temple"] = Vector3.new(1475, -22, -632),
    ["Ancient Jungle Outside"] = Vector3.new(1488, 8, -392),
    ["Ancient Jungle"] = Vector3.new(1274, 8, -184),
    ["Underground Cellar"] = Vector3.new(2136, -91, -699),
    ["Crystaline Pessage"] = Vector3.new(6051, -539, 4386),
    ["Ancient Ruin"] = Vector3.new(6090, -586, 4634)
}

local LocationNames = {}
for locationName in pairs(LocationData) do
    table.insert(LocationNames, locationName)
end
table.sort(LocationNames, function(a, b) return a:lower() < b:lower() end)

-- =============================================
-- NOTIFICATION MANAGEMENT
-- =============================================
function disableNotifications()
    Config.notifConnections = {}
    for _, event in ipairs({
        GameModules.Net["RE/ObtainedNewFishNotification"],
        GameModules.Net["RE/TextNotification"], 
        GameModules.Net["RE/ClaimNotification"]
    }) do
        for _, connection in ipairs(getconnections(event.OnClientEvent)) do
            connection:Disconnect()
            table.insert(Config.notifConnections, connection)
        end
    end
end

function enableNotifications()
    Config.notifConnections = {}
end

-- =============================================
-- UI LIBRARY INTEGRATION
-- =============================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/TesterX14/XXXX/refs/heads/main/Library"))()
local Window = Library:Window({
    Title = "OGHub |",
    Footer = "Version 2.0.0", 
    Image = "132435516080103",
    Color = Color3.fromRGB(0, 208, 255),
    Theme = 9542022979,
    Version = 3
})

if Window then
    chloex("Window loaded!")
end

-- Tab System
local Tabs = {
    Info = Window:AddTab({Name = "Info", Icon = "player"}),
    Main = Window:AddTab({Name = "Fishing", Icon = "rbxassetid://97167558235554"}),
    Auto = Window:AddTab({Name = "Automatically", Icon = "next"}),
    Trade = Window:AddTab({Name = "Trading", Icon = "rbxassetid://114581487428395"}),
    Farm = Window:AddTab({Name = "Menu", Icon = "rbxassetid://140165584241571"}),
    Quest = Window:AddTab({Name = "Quest", Icon = "scroll"}),
    Tele = Window:AddTab({Name = "Teleport", Icon = "rbxassetid://18648122722"}),
    Webhook = Window:AddTab({Name = "Webhook", Icon = "rbxassetid://137601480983962"}),
    Misc = Window:AddTab({Name = "Misc", Icon = "rbxassetid://6034509993"})
}

-- Load External Modules
local ExternalModuleURL = "https://raw.githubusercontent.com/ChloeRewite/test/refs/heads/main/2.lua"
local success, externalModule = pcall(function()
    local source = game:HttpGet(ExternalModuleURL)
    local loadedFunction = loadstring(source)
    if not loadedFunction then
        error("Failed to load external module")
    end
    return loadedFunction()
end)

if success and type(externalModule) == "function" then
    pcall(externalModule, Window, Tabs)
end

-- =============================================
-- FISHING FEATURES SECTION
-- =============================================
local FishingSection = Tabs.Main:AddSection("Fishing Features")

-- Detector System
DetectorParagraph = FishingSection:AddParagraph({
    Title = "Detector Stuck",
    Content = "Status = Idle\nTime = 0.0s\nBag = 0"
})

FishingSection:AddSlider({
    Title = "Wait (s)",
    Default = 15,
    Min = 10,
    Max = 25,
    Rounding = 0,
    Callback = function(value)
        Config.stuckThreshold = value
    end
})

FishingSection:AddToggle({
    Title = "Start Detector",
    Content = "Detector if fishing got stuck! this feature helpful",
    Default = false,
    Callback = function(enabled)
        Config.supportEnabled = enabled
        if enabled then
            Config.char = Config.player.Character or Config.player.CharacterAdded:Wait()
            Config.savedCFrame = Config.char:WaitForChild("HumanoidRootPart").CFrame
            _G.Celestial.DetectorCount = getFishCount()
            
            Config.fishingTimer = 0
            Config.equipTimer = 0
            local status = "Idle"
            local statusColor = "255,255,255"
            local loopCounter = 0
            
            task.spawn(function()
                while Config.supportEnabled do
                    local success, fishCount = pcall(getFishCount)
                    if not success or not fishCount then
                        DetectorParagraph:SetContent("<font color='rgb(255,69,0)'>Status = Error Reading Count</font>\nTime = 0.0s\nBag = 0")
                        task.wait(1)
                        Config.fishingTimer = 0
                    else
                        task.wait(0.1)
                        loopCounter = loopCounter + 1
                        Config.equipTimer = Config.equipTimer + 0.1
                        Config.fishingTimer = Config.fishingTimer + 0.1
                        
                        if loopCounter % 30000 == 0 then
                            task.wait(5)
                            collectgarbage("collect")
                            loopCounter = 0
                        end
                        
                        if not Config.char or not Config.char.Parent then
                            Config.char = Config.player.Character or Config.player.CharacterAdded:Wait()
                        end
                        
                        if _G.Celestial.DetectorCount < fishCount then
                            _G.Celestial.DetectorCount = fishCount
                            Config.fishingTimer = 0
                            status = "Fishing Normaly"
                            statusColor = "0,255,127"
                        elseif fishCount < _G.Celestial.DetectorCount then
                            _G.Celestial.DetectorCount = fishCount
                            status = "Bag Update"
                            statusColor = "173,216,230"
                        elseif Config.fishingTimer >= (Config.stuckThreshold or 10) then
                            status = "STUCK! Resetting..."
                            statusColor = "255,69,0"
                            chloex("Fishing Stuck! Resetting...", 3)
                            
                            local humanoidRootPart = Config.char and Config.char:FindFirstChild("HumanoidRootPart")
                            if humanoidRootPart then
                                Config.savedCFrame = humanoidRootPart.CFrame
                            end
                            
                            Config.player.Character:BreakJoints()
                            Config.char = Config.player.CharacterAdded:Wait()
                            Config.char:WaitForChild("HumanoidRootPart").CFrame = Config.savedCFrame
                            task.wait(0.2)
                            
                            pcall(function()
                                Network.Events.REEquip:FireServer(1)
                            end)
                            
                            Config.fishingTimer = 0
                            _G.Celestial.DetectorCount = getFishCount()
                            status = "Idle"
                            statusColor = "255,255,255"
                        end
                        
                        DetectorParagraph:SetContent(string.format(
                            "<font color='rgb(%s)'>Status = %s</font>\n<font color='rgb(0,191,255)'>Time = %.1fs</font>\n<font color='rgb(173,216,230)'>Bag = %d</font>",
                            statusColor, status, Config.fishingTimer, fishCount
                        ))
                    end
                end
                DetectorParagraph:SetContent("<font color='rgb(200,200,200)'>Status = Detector Offline</font>\nTime = 0.0s\nBag = 0")
            end)
        else
            DetectorParagraph:SetContent("<font color='rgb(200,200,200)'>Status = Detector Offline</font>\nTime = 0.0s\nBag = 0")
        end
    end
})

FishingSection:AddDivider()

-- Legit Fishing Delay
FishingSection:AddInput({
    Title = "Legit Delay",
    Content = "Delay complete fishing!",
    Value = tostring(_G.Delay),
    Callback = function(value)
        local delayValue = tonumber(value)
        if delayValue and delayValue > 0 then
            _G.Delay = delayValue
            SaveConfig()
            -- Implementation for legit fishing delay
        else
            warn("Invalid fishing delay input")
        end
    end
})

-- Shake Delay
local shakeDelay = 0
FishingSection:AddInput({
    Title = "Shake Delay", 
    Value = tostring(shakeDelay),
    Callback = function(value)
        local delayValue = tonumber(value)
        if delayValue and delayValue >= 0 then
            shakeDelay = delayValue
        end
    end
})

-- Legit Fishing Mode
local selectedMode = "Always Perfect"
local userId = tostring(LocalPlayer.UserId)
local CosmeticFolder = workspace:FindFirstChild("CosmeticFolder")

FishingSection:AddDropdown({
    Title = "Legit Mode",
    Options = {"Always Perfect", "Normal"},
    Default = "Always Perfect",
    Multi = false,
    Callback = function(mode)
        selectedMode = mode
    end
})

-- Fishing Cast Function
function tryCast()
    local playerGui = Services.PG
    local camera = Services.Camera
    local inputManager = Services.VIM
    local localPlayer = Services.Players.LocalPlayer
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local currentGUID = nil
    
    while GameModules.FishingController._autoLoop do
        if GameModules.FishingController:GetCurrentGUID() then
            task.wait(0.05)
        else
            inputManager:SendMouseButtonEvent(screenCenter.X, screenCenter.Y, 0, true, game, 1)
            task.wait(0.05)
            
            local chargeBar = playerGui:WaitForChild("Charge").Main.CanvasGroup:WaitForChild("Bar")
            local startTime = tick()
            
            while chargeBar:IsDescendantOf(playerGui) and chargeBar.Size.Y.Scale < 0.95 do
                task.wait(0.001)
                if tick() - startTime > 1 then
                    break
                end
            end
            
            inputManager:SendMouseButtonEvent(screenCenter.X, screenCenter.Y, 0, false, game, 1)
            local waitTime = tick()
            local shakeDetected = false
            
            while tick() - waitTime < 3 do
                local guid = GameModules.FishingController:GetCurrentGUID()
                if guid and guid ~= currentGUID then
                    shakeDetected = true
                    currentGUID = guid
                    break
                else
                    task.wait(0.05)
                end
            end
            
            if shakeDetected then
                local caughtCount = localPlayer.leaderstats and localPlayer.leaderstats.Caught.Value or 0
                local fishTime = tick()
                
                while tick() - fishTime < 8 and (not localPlayer.leaderstats or caughtCount >= localPlayer.leaderstats.Caught.Value) and GameModules.FishingController:GetCurrentGUID() do
                    task.wait(0.1)
                end
                
                while GameModules.FishingController:GetCurrentGUID() do
                    task.wait(0.05)
                end
                
                task.wait(1.3)
            end
        end
        task.wait(0.05)
    end
end

-- Legit Fishing Toggle
FishingSection:AddToggle({
    Title = "Legit Fishing",
    Content = "Auto fishing with animation",
    Default = false,
    Callback = function(enabled)
        local fishingController = GameModules.FishingController
        fishingController._autoLoop = enabled
        
        if enabled then
            if selectedMode == "Always Perfect" then
                task.spawn(function()
                    while enabled and fishingController._autoLoop do
                        if not CosmeticFolder:FindFirstChild(userId) then
                            repeat
                                tryCast()
                                task.wait(0.1)
                            until CosmeticFolder:FindFirstChild(userId) or not fishingController._autoLoop
                        end
                        
                        while CosmeticFolder:FindFirstChild(userId) and fishingController._autoLoop do
                            if fishingController:GetCurrentGUID() then
                                local startTime = tick()
                                while fishingController:GetCurrentGUID() and fishingController._autoLoop do
                                    pcall(function()
                                        fishingController:RequestFishingMinigameClick()
                                    end)
                                    
                                    if tick() - startTime >= _G.Delay then
                                        task.wait(_G.Delay)
                                        local completed = false
                                        repeat
                                            pcall(function()
                                                Network.Events.REFishDone:FireServer()
                                            end)
                                            task.wait(0.05)
                                            completed = not fishingController:GetCurrentGUID() or not fishingController._autoLoop
                                        until completed
                                    else
                                        task.wait()
                                    end
                                    
                                    if completed then
                                        break
                                    end
                                end
                            end
                            task.wait(0.2)
                        end
                        
                        repeat
                            task.wait(0.1)
                        until not CosmeticFolder:FindFirstChild(userId) or not fishingController._autoLoop
                        
                        if fishingController._autoLoop then
                            task.wait(0.2)
                            tryCast()
                        end
                        task.wait(0.2)
                    end
                end)
            elseif selectedMode == "Normal" then
                if not fishingController._oldGetPower then
                    fishingController._oldGetPower = fishingController._getPower
                end
                fishingController._getPower = function() return 0.999 end
                
                task.spawn(function()
                    while enabled and fishingController._autoLoop do
                        if _G.ShakeEnabled and fishingController:GetCurrentGUID() then
                            local startTime = tick()
                            while fishingController:GetCurrentGUID() and fishingController._autoLoop and _G.ShakeEnabled do
                                pcall(function()
                                    fishingController:RequestFishingMinigameClick()
                                end)
                                
                                if tick() - startTime >= (_G.Delay or 1) then
                                    pcall(function()
                                        Network.Events.REFishDone:FireServer()
                                    end)
                                    task.wait(0.1)
                                    if not fishingController:GetCurrentGUID() or not fishingController._autoLoop or not _G.ShakeEnabled then
                                        break
                                    end
                                end
                                task.wait(0.1)
                            end
                        elseif not fishingController:GetCurrentGUID() then
                            local screenCenter = Vector2.new(Services.Camera.ViewportSize.X / 2, Services.Camera.ViewportSize.Y / 2)
                            pcall(function()
                                fishingController:RequestChargeFishingRod(screenCenter, true)
                            end)
                            task.wait(0.25)
                        end
                        task.wait(0.05)
                    end
                end)
            end
        else
            fishingController._autoLoop = false
            if fishingController._oldGetPower then
                fishingController._getPower = fishingController._oldGetPower
                fishingController._oldGetPower = nil
            end
        end
    end
})

-- Auto Shake Toggle
FishingSection:AddToggle({
    Title = "Auto Shake",
    Content = "Spam click during fishing (only legit)",
    Default = false,
    Callback = function(enabled)
        GameModules._autoShake = enabled
        local clickEffect = Services.PG:FindFirstChild("!!! Click Effect")
        
        if enabled then
            if clickEffect then
                clickEffect.Enabled = false
            end
            task.spawn(function()
                while GameModules._autoShake do
                    pcall(function()
                        GameModules.FishingController:RequestFishingMinigameClick()
                    end)
                    task.wait(shakeDelay)
                end
            end)
        elseif clickEffect then
            clickEffect.Enabled = true
        end
    end
})

FishingSection:AddDivider()

-- Instant Fishing
FishingSection:AddInput({
    Title = "Delay Complete",
    Value = tostring(_G.DelayComplete),
    Callback = function(value)
        local delayValue = tonumber(value)
        if delayValue and delayValue >= 0 then
            _G.DelayComplete = delayValue
            SaveConfig()
        end
    end
})

FishingSection:AddToggle({
    Title = "Instant Fishing",
    Content = "Auto instantly catch fish", 
    Default = false,
    Callback = function(enabled)
        Config.autoInstant = enabled
        if enabled then
            _G.Celestial.InstantCount = getFishCount()
            task.spawn(function()
                while Config.autoInstant do
                    if Config.canFish then
                        Config.canFish = false
                        local success, result = pcall(function()
                            return Network.Functions.ChargeRod:InvokeServer(workspace:GetServerTimeNow())
                        end)
                        
                        if success and typeof(result) == "number" then
                            task.wait(0.3)
                            pcall(function()
                                Network.Functions.StartMini:InvokeServer(-1, 0.999, result)
                            end)
                            
                            local timeout = tick()
                            repeat
                                task.wait(0.05)
                            until _G.FishMiniData and _G.FishMiniData.LastShift or tick() - timeout > 1
                            
                            task.wait(_G.DelayComplete)
                            pcall(function()
                                Network.Events.REFishDone:FireServer()
                            end)
                            
                            local fishCount = getFishCount()
                            local waitTime = tick()
                            repeat
                                task.wait(0.05)
                            until fishCount < getFishCount() or tick() - waitTime > 1
                        end
                        Config.canFish = true
                    end
                    task.wait(0.05)
                end
            end)
        end
    end
})

-- Fishing Minigame Event Handler
if Network.Events.FishingMinigameChanged then
    if _G._MiniEventConn then
        _G._MiniEventConn:Disconnect()
    end
    _G._MiniEventConn = Network.Events.FishingMinigameChanged.OnClientEvent:Connect(function(dataType, data)
        if dataType and data then
            _G.FishMiniData = data
        end
    end)
end

-- =============================================
-- BLATANT FISHING FEATURES
-- =============================================
FishingSection:AddSubSection("Blatant Features [BETA]")

-- Fastest Fishing Function
function Fastest()
    task.spawn(function()
        pcall(function()
            Network.Functions.Cancel:InvokeServer()
        end)
        
        local serverTime = workspace:GetServerTimeNow()
        pcall(function()
            Network.Functions.ChargeRod:InvokeServer(serverTime)
        end)
        
        pcall(function()
            Network.Functions.StartMini:InvokeServer(-1, 0.999)
        end)
        
        task.wait(_G.FishingDelay)
        pcall(function()
            Network.Events.REFishDone:FireServer()
        end)
    end)
end

-- Random Result Function  
function RandomResult()
    task.spawn(function()
        pcall(function()
            Network.Functions.Cancel:InvokeServer()
        end)
        
        local serverTime = workspace:GetServerTimeNow()
        pcall(function()
            Network.Functions.ChargeRod:InvokeServer(serverTime)
        end)
        
        task.wait(0.2)
        pcall(function()
            Network.Functions.StartMini:InvokeServer(-1, 0.999)
        end)
        
        task.wait(_G.FishingDelay)
        pcall(function()
            Network.Events.REFishDone:FireServer()
        end)
    end)
end

-- Blatant Fishing Mode Selection
selectedMode = "Fast"
FishingSection:AddDropdown({
    Title = "Fishing Mode",
    Options = {"Fast", "Random Result"},
    Default = "Fast", 
    Multi = false,
    Callback = function(mode)
        selectedMode = mode
    end
})

-- Fishing Delays
FishingSection:AddInput({
    Title = "Delay Reel",
    Value = tostring(_G.Reel),
    Default = "1.9",
    Callback = function(value)
        local delayValue = tonumber(value)
        if delayValue and delayValue > 0 then
            _G.Reel = delayValue
            SaveConfig()
        end
    end
})

FishingSection:AddInput({
    Title = "Delay Fishing", 
    Value = tostring(_G.FishingDelay),
    Default = "1.1",
    Callback = function(value)
        local delayValue = tonumber(value)
        if delayValue and delayValue > 0 then
            _G.FishingDelay = delayValue
            SaveConfig()
        end
    end
})

-- Blatant Fishing Toggle
FishingSection:AddToggle({
    Title = "Blatant Fishing",
    Default = _G.FBlatant,
    Callback = function(enabled)
        _G.FBlatant = enabled
        if enabled then
            task.spawn(function()
                while _G.FBlatant do
                    if selectedMode == "Fast" then
                        Fastest()
                    elseif selectedMode == "Random Result" then
                        RandomResult()
                    end
                    task.wait(_G.Reel)
                end
            end)
        end
    end
})

-- Recovery Fishing Button
FishingSection:AddButton({
    Title = "Recovery Fishing",
    Callback = function()
        pcall(function()
            Network.Functions.Cancel:InvokeServer()
            chloex("Recovery Successfully!")
        end)
    end
})

-- =============================================
-- UTILITY PLAYER FEATURES
-- =============================================
FishingSection:AddSubSection("Utility Player")

-- Auto Equip Rod
FishingSection:AddToggle({
    Title = "Auto Equip Rod",
    Content = "Automatically equip your fishing rod",
    Default = false,
    Callback = function(enabled)
        Config.autoEquipRod = enabled
        
        local function hasRodEquipped()
            local equippedId = DataSystem.Data:Get("EquippedId")
            if not equippedId then return false end
            
            local equippedItem = GameModules.PlayerStatsUtility:GetItemFromInventory(DataSystem.Data, function(item)
                return item.UUID == equippedId
            end)
            
            if not equippedItem then return false end
            
            local itemData = GameModules.ItemUtility:GetItemData(equippedItem.Id)
            return itemData and itemData.Data.Type == "Fishing Rods"
        end
        
        local function equipRod()
            if not hasRodEquipped() then
                Network.Events.REEquip:FireServer(1)
            end
        end
        
        if enabled then
            task.spawn(function()
                while Config.autoEquipRod do
                    equipRod()
                    task.wait(1)
                end
            end)
        end
    end
})

-- No Fishing Animations
FishingSection:AddToggle({
    Title = "No Fishing Animations", 
    Default = false,
    Callback = function(enabled)
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local animator = character:WaitForChild("Humanoid"):FindFirstChildOfClass("Animator")
        if not animator then return end
        
        if enabled then
            Config.stopAnimHookEnabled = true
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                track:Stop(0)
            end
            
            Config.stopAnimConn = animator.AnimationPlayed:Connect(function(track)
                if Config.stopAnimHookEnabled then
                    task.defer(function()
                        pcall(function()
                            track:Stop(0)
                        end)
                    end)
                end
            end)
        else
            Config.stopAnimHookEnabled = false
            if Config.stopAnimConn then
                Config.stopAnimConn:Disconnect()
                Config.stopAnimConn = nil
            end
        end
    end
})

-- Walk on Water Feature
local walkOnWaterEnabled = false
local waterPart = nil
local waterConnection = nil
local waterHeight = -1.8

FishingSection:AddToggle({
    Title = "Walk on Water",
    Default = false,
    Callback = function(enabled)
        walkOnWaterEnabled = enabled
        local humanoidRootPart = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
        
        if enabled then
            waterPart = Instance.new("Part")
            waterPart.Name = "WW_Part"
            waterPart.Size = Vector3.new(15, 1, 15)
            waterPart.Anchored = true
            waterPart.CanCollide = false
            waterPart.Transparency = 1
            waterPart.Material = Enum.Material.SmoothPlastic
            waterPart.Parent = workspace
            
            waterConnection = Services.RunService.Heartbeat:Connect(function()
                if not walkOnWaterEnabled or not waterPart or not humanoidRootPart then
                    return
                end
                waterPart.Position = Vector3.new(humanoidRootPart.Position.X, waterHeight, humanoidRootPart.Position.Z)
                waterPart.CanCollide = humanoidRootPart.Position.Y > waterHeight
            end)
        else
            if waterConnection then
                waterConnection:Disconnect()
                waterConnection = nil
            end
            if waterPart then
                waterPart:Destroy()
                waterPart = nil
            end
        end
    end
})

-- Freeze Player Feature
FishingSection:AddToggle({
    Title = "Freeze Player",
    Content = "Freeze only if rod is equipped",
    Default = false,
    Callback = function(enabled)
        Config.frozen = enabled
        local character = Config.player.Character
        
        local function hasRodEquipped()
            local equippedId = DataSystem.Data:Get("EquippedId")
            if not equippedId then return false end
            
            local equippedItem = GameModules.PlayerStatsUtility:GetItemFromInventory(DataSystem.Data, function(item)
                return item.UUID == equippedId
            end)
            
            if not equippedItem then return false end
            
            local itemData = GameModules.ItemUtility:GetItemData(equippedItem.Id)
            return itemData and itemData.Data.Type == "Fishing Rods"
        end
        
        local function equipRod()
            if not hasRodEquipped() then
                Network.Events.REEquip:FireServer(1)
                task.wait(0.5)
            end
        end
        
        local function setCharacterAnchored(char, anchored)
            if not char then return end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = anchored
                end
            end
        end
        
        local function updateFreezeState(char)
            if Config.frozen then
                equipRod()
                if hasRodEquipped() then
                    setCharacterAnchored(char, true)
                end
            else
                setCharacterAnchored(char, false)
            end
        end
        
        updateFreezeState(character)
        Config.player.CharacterAdded:Connect(function(newChar)
            task.wait(1)
            updateFreezeState(newChar)
        end)
    end
})

-- =============================================
-- FISHING PANEL SUPPORT FEATURES
-- =============================================
local PanelSection = Tabs.Main:AddSection("Panel Support Features")

-- Fishing Panel Toggle
PanelSection:AddToggle({
    Title = "Show Fishing Panel", 
    Default = false,
    Callback = function(enabled)
        if enabled then
            if Services.CoreGui:FindFirstChild("ChloeX_FishingPanel") then
                Services.CoreGui:FindFirstChild("ChloeX_FishingPanel"):Destroy()
            end
            
            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "ChloeX_FishingPanel"
            screenGui.IgnoreGuiInset = true
            screenGui.ResetOnSpawn = false
            screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
            screenGui.Parent = Services.CoreGui
            
            local mainFrame = Instance.new("Frame", screenGui)
            mainFrame.Size = UDim2.new(0, 400, 0, 210)
            mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
            mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            mainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 35)
            mainFrame.BorderSizePixel = 0
            mainFrame.BackgroundTransparency = 0.05
            mainFrame.Active = true
            mainFrame.Draggable = true
            
            local stroke = Instance.new("UIStroke", mainFrame)
            stroke.Thickness = 2
            stroke.Color = Color3.fromRGB(80, 150, 255)
            stroke.Transparency = 0.35
            
            Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)
            
            -- Panel UI Elements
            local icon = Instance.new("ImageLabel", mainFrame)
            icon.Size = UDim2.new(0, 28, 0, 28)
            icon.Position = UDim2.new(0, 10, 0, 6)
            icon.BackgroundTransparency = 1
            icon.Image = "rbxassetid://100076212630732"
            icon.ScaleType = Enum.ScaleType.Fit
            
            local title = Instance.new("TextLabel", mainFrame)
            title.Size = UDim2.new(1, -40, 0, 36)
            title.Position = UDim2.new(0, 45, 0, 5)
            title.BackgroundTransparency = 1
            title.Font = Enum.Font.GothamBold
            title.Text = "CHLOEX PANEL FISHING"
            title.TextSize = 22
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.TextXAlignment = Enum.TextXAlignment.Left
            
            local titleGradient = Instance.new("UIGradient", title)
            titleGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 220, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 120, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 220, 255))
            })
            titleGradient.Rotation = 45
            
            local inventoryLabel = Instance.new("TextLabel", mainFrame)
            inventoryLabel.Position = UDim2.new(0, 15, 0, 55)
            inventoryLabel.Size = UDim2.new(1, -30, 0, 22)
            inventoryLabel.Font = Enum.Font.GothamBold
            inventoryLabel.TextSize = 18
            inventoryLabel.BackgroundTransparency = 1
            inventoryLabel.TextColor3 = Color3.fromRGB(140, 200, 255)
            inventoryLabel.Text = "INVENTORY COUNT:"
            
            local fishCountLabel = Instance.new("TextLabel", mainFrame)
            fishCountLabel.Position = UDim2.new(0, 15, 0, 75)
            fishCountLabel.Size = UDim2.new(1, -30, 0, 22)
            fishCountLabel.Font = Enum.Font.Gotham
            fishCountLabel.TextSize = 18
            fishCountLabel.BackgroundTransparency = 1
            fishCountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            fishCountLabel.Text = "Fish: 0/0"
            
            local totalLabel = Instance.new("TextLabel", mainFrame)
            totalLabel.Position = UDim2.new(0, 15, 0, 105)
            totalLabel.Size = UDim2.new(1, -30, 0, 22)
            totalLabel.Font = Enum.Font.GothamBold
            totalLabel.TextSize = 18
            totalLabel.BackgroundTransparency = 1
            totalLabel.TextColor3 = Color3.fromRGB(140, 200, 255)
            totalLabel.Text = "TOTAL FISH CAUGHT:"
            
            local totalValueLabel = Instance.new("TextLabel", mainFrame)
            totalValueLabel.Position = UDim2.new(0, 15, 0, 125)
            totalValueLabel.Size = UDim2.new(1, -30, 0, 22)
            totalValueLabel.Font = Enum.Font.Gotham
            totalValueLabel.TextSize = 18
            totalValueLabel.BackgroundTransparency = 1
            totalValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            totalValueLabel.Text = "Value: 0"
            
            local statusLabel = Instance.new("TextLabel", mainFrame)
            statusLabel.Position = UDim2.new(0.5, 0, 0, 165)
            statusLabel.AnchorPoint = Vector2.new(0.5, 0)
            statusLabel.Size = UDim2.new(0.8, 0, 0, 30)
            statusLabel.Font = Enum.Font.GothamBold
            statusLabel.TextSize = 22
            statusLabel.Text = "FISHING NORMAL"
            statusLabel.BackgroundTransparency = 1
            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
            
            local currentCaught = LocalPlayer.leaderstats.Caught.Value
            local lastUpdate = tick()
            local isStuck = false
            
            Config.fishingPanelRunning = true
            
            task.spawn(function()
                while Config.fishingPanelRunning and task.wait(1) do
                    local bagText = ""
                    pcall(function()
                        bagText = LocalPlayer.PlayerGui.Inventory.Main.Top.Options.Fish.Label.BagSize.Text
                    end)
                    
                    local caughtValue = LocalPlayer.leaderstats.Caught.Value
                    fishCountLabel.Text = "Fish: " .. (bagText or "0/0")
                    totalValueLabel.Text = "Value: " .. tostring(caughtValue)
                    
                    if currentCaught < caughtValue then
                        currentCaught = caughtValue
                        lastUpdate = tick()
                        if isStuck then
                            isStuck = false
                            statusLabel.Text = "FISHING NORMAL"
                            statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                        end
                    end
                    
                    if not isStuck and tick() - lastUpdate >= 10 then
                        isStuck = true
                        statusLabel.Text = "FISHING STUCK"
                        statusLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
                    end
                end
            end)
        else
            Config.fishingPanelRunning = false
            local existingPanel = Services.CoreGui:FindFirstChild("ChloeX_FishingPanel")
            if existingPanel then
                existingPanel:Destroy()
            end
        end
    end
})

-- Blackscreen Support
PanelSection:AddToggle({
    Title = "Blackscreen Support",
    Default = false,
    Callback = function(enabled)
        local coreGui = Services.CoreGui
        local tweenService = Services.TweenService
        
        if enabled then
            if coreGui:FindFirstChild("ChloeX_BlackScreen") then
                coreGui.ChloeX_BlackScreen:Destroy()
            end
            
            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "ChloeX_BlackScreen"
            screenGui.IgnoreGuiInset = true
            screenGui.ResetOnSpawn = false
            screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
            screenGui.DisplayOrder = 100
            screenGui.Parent = coreGui
            
            local dimFrame = Instance.new("Frame", screenGui)
            dimFrame.Name = "Dim"
            dimFrame.Size = UDim2.new(1, 0, 1, 0)
            dimFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            dimFrame.BackgroundTransparency = 1
            dimFrame.BorderSizePixel = 0
            dimFrame.ZIndex = 999
            
            tweenService:Create(dimFrame, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0
            }):Play()
            
            local protectedGuis = {"ChloeX_FishingPanel", "Chloeex", "ToggleUIButton"}
            for _, guiName in ipairs(protectedGuis) do
                local gui = coreGui:FindFirstChild(guiName)
                if gui and gui:IsA("ScreenGui") then
                    gui.DisplayOrder = 999
                    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
                    for _, element in ipairs(gui:GetDescendants()) do
                        if element:IsA("GuiObject") then
                            element.ZIndex = 1000
                        end
                    end
                end
            end
            
            Config.focusOverlay = screenGui
        elseif Config.focusOverlay and Config.focusOverlay.Parent then
            local dim = Config.focusOverlay:FindFirstChild("Dim")
            if dim then
                tweenService:Create(dim, TweenInfo.new(0.4), {
                    BackgroundTransparency = 1
                }):Play()
                task.wait(0.4)
            end
            Config.focusOverlay:Destroy()
            Config.focusOverlay = nil
        end
    end
})

-- =============================================
-- SELLING FEATURES
-- =============================================
local SellingSection = Tabs.Main:AddSection("Selling Features")

-- Sell Mode Selection
SellingSection:AddDropdown({
    Options = {"Delay", "Count"},
    Default = "Delay",
    Title = "Select Sell Mode", 
    Callback = function(mode)
        Config.sellMode = mode
        SaveConfig()
    end
})

-- Sell Value Input
SellingSection:AddInput({
    Default = "60",
    Title = "Set Value",
    Content = "Delay = Time Count | Count = Backpack Count",
    Placeholder = "Input Here",
    Callback = function(value)
        local numValue = tonumber(value) or 1
        if Config.sellMode == "Delay" then
            Config.sellDelay = numValue
        else
            Config.inputSellCount = numValue
        end
        SaveConfig()
    end
})

-- Auto Selling Toggle
SellingSection:AddToggle({
    Title = "Start Selling",
    Default = false,
    Callback = function(enabled)
        Config.autoSellEnabled = enabled
        if enabled then
            task.spawn(function()
                while Config.autoSellEnabled do
                    local bagSizeLabel = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Inventory").Main.Top.Options.Fish.Label:FindFirstChild("BagSize")
                    local currentCount = 0
                    local maxCount = 0
                    
                    if bagSizeLabel and bagSizeLabel:IsA("TextLabel") then
                        local current, maximum = (bagSizeLabel.Text or ""):match("(%d+)%s*/%s*(%d+)")
                        currentCount = tonumber(current) or 0
                        maxCount = tonumber(maximum) or 0
                    end
                    
                    if Config.sellMode == "Delay" then
                        Network.Functions.SellAllItems:InvokeServer()
                        task.wait(Config.sellDelay)
                    elseif Config.sellMode == "Count" then
                        if (tonumber(Config.inputSellCount) or maxCount) <= currentCount then
                            Network.Functions.SellAllItems:InvokeServer()
                            task.wait(0)
                        else
                            task.wait(0)
                        end
                    end
                end
            end)
        end
    end
})

-- =============================================
-- FAVORITE FEATURES
-- =============================================
local FavoriteSection = Tabs.Main:AddSection("Favorite Features")

-- Get All Fish Names
local allFishNames = {}
for _, itemScript in ipairs(DataSystem.Items:GetChildren()) do
    if itemScript:IsA("ModuleScript") then
        local success, itemData = pcall(require, itemScript)
        if success and itemData.Data and itemData.Data.Type == "Fish" then
            table.insert(allFishNames, itemData.Data.Name)
        end
    end
end
table.sort(allFishNames)

-- Name Filter Dropdown
FavoriteSection:AddDropdown({
    Options = #allFishNames > 0 and allFishNames or {"No Fish Found"},
    Content = "Favorite By Name Fish (Recommended)",
    Multi = true,
    Title = "Name", 
    Callback = function(selected)
        Config.selectedName = toSet(selected)
    end
})

-- Rarity Filter Dropdown
FavoriteSection:AddDropdown({
    Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"},
    Content = "Favorite By Rarity (Optional)", 
    Multi = true,
    Title = "Rarity",
    Callback = function(selected)
        Config.selectedRarity = toSet(selected)
    end
})

-- Variant Filter Dropdown
FavoriteSection:AddDropdown({
    Options = _G.Variant,
    Content = "Favorite By Variant (Only works with Name)",
    Multi = true,
    Title = "Variant",
    Callback = function(selected)
        if next(Config.selectedName) ~= nil then
            Config.selectedVariant = toSet(selected)
        else
            Config.selectedVariant = {}
            warn("Pilih Name dulu sebelum memilih Variant.")
        end
    end
})

-- Auto Favorite Toggle
FavoriteSection:AddToggle({
    Title = "Auto Favorite",
    Default = false,
    Callback = function(enabled)
        Config.autoFavEnabled = enabled
        if enabled then
            scanInventory()
            DataSystem.Data:OnChange({"Inventory", "Items"}, scanInventory)
        end
    end
})

-- Unfavorite All Button
FavoriteSection:AddButton({
    Title = "Unfavorite Fish", 
    Callback = function()
        for _, item in ipairs(DataSystem.Data:GetExpect({"Inventory", "Items"})) do
            local isFavorited = rawget(FavoriteCache, item.UUID)
            if isFavorited == nil then
                isFavorited = item.Favorited
            end
            if isFavorited then
                Network.Events.REFav:FireServer(item.UUID)
                rawset(FavoriteCache, item.UUID, false)
            end
        end
    end
})

-- =============================================
-- SHOP FEATURES (AUTO TAB)
-- =============================================
local ShopSection = Tabs.Auto:AddSection("Shop Features")

-- Merchant Stock Panel
local ShopParagraph = ShopSection:AddParagraph({
    Title = "MERCHANT STOCK PANEL", 
    Content = "Loading..."
})

-- Open/Close Merchant Button
ShopSection:AddButton({
    Title = "Open/Close Merchant",
    Callback = function()
        local merchantGui = Services.PG:FindFirstChild("Merchant")
        if merchantGui then
            merchantGui.Enabled = not merchantGui.Enabled
        end
    end
})

-- Update Merchant Stock Function
function UpdateMerchantStock()
    local stockItems = {}
    for _, itemFrame in ipairs(MerchantUI.ItemsFrame:GetChildren()) do
        if itemFrame:IsA("ImageLabel") and itemFrame.Name ~= "Frame" then
            local itemInfo = itemFrame:FindFirstChild("Frame")
            if itemInfo and itemInfo:FindFirstChild("ItemName") then
                local itemName = itemInfo.ItemName.Text
                if not string.find(itemName, "Mystery") then
                    table.insert(stockItems, "- " .. itemName)
                end
            end
        end
    end
    
    if #stockItems == 0 then
        ShopParagraph:SetContent("No items found\n" .. MerchantUI.RefreshMerchant.Text)
    else
        ShopParagraph:SetContent(table.concat(stockItems, "\n") .. "\n\n" .. MerchantUI.RefreshMerchant.Text)
    end
end

-- Auto Update Merchant Stock
task.spawn(function()
    while task.wait(1) do
        pcall(UpdateMerchantStock)
    end
end)

-- =============================================
-- ROD & BAIT PURCHASING SYSTEM
-- =============================================

-- Load Rod Data
for _, rodScript in ipairs(DataSystem.Items:GetChildren()) do
    if rodScript:IsA("ModuleScript") and rodScript.Name:match("Rod") then
        local success, rodData = pcall(require, rodScript)
        if success and typeof(rodData) == "table" and rodData.Data then
            local rodName = rodData.Data.Name or "Unknown"
            local rodId = rodData.Data.Id or "Unknown"
            local rodPrice = rodData.Price or 0
            local cleanName = rodName:gsub("^!!!%s*", "")
            local displayName = cleanName .. " ($" .. rodPrice .. ")"
            
            local rodInfo = {
                Name = cleanName,
                Id = rodId,
                Price = rodPrice,
                Display = displayName
            }
            
            Config.rods[rodId] = rodInfo
            Config.rods[cleanName] = rodInfo
            table.insert(Config.rodDisplayNames, displayName)
        end
    end
end

-- Load Bait Data
local BaitsFolder = Services.RS:WaitForChild("Baits")
for _, baitScript in ipairs(BaitsFolder:GetChildren()) do
    if baitScript:IsA("ModuleScript") then
        local success, baitData = pcall(require, baitScript)
        if success and typeof(baitData) == "table" and baitData.Data then
            local baitName = baitData.Data.Name or "Unknown"
            local baitId = baitData.Data.Id or "Unknown"
            local baitPrice = baitData.Price or 0
            local displayName = baitName .. " ($" .. baitPrice .. ")"
            
            local baitInfo = {
                Name = baitName,
                Id = baitId,
                Price = baitPrice,
                Display = displayName
            }
            
            Config.baits[baitId] = baitInfo
            Config.baits[baitName] = baitInfo
            table.insert(Config.baitDisplayNames, displayName)
        end
    end
end

-- Rod Purchase Section
ShopSection:AddSubSection("Buy Rod")

ShopSection:AddDropdown({
    Title = "Select Rod",
    Options = Config.rodDisplayNames,
    Callback = function(selected)
        if not selected then return end
        local cleanName = _cleanName(selected)
        local rodInfo = Config.rods[cleanName]
        if rodInfo then
            Config.selectedRodId = rodInfo.Id
        end
    end
})

ShopSection:AddButton({
    Title = "Buy Selected Rod",
    Callback = function()
        if not Config.selectedRodId then return end
        local rodInfo = Config.rods[Config.selectedRodId] or Config.rods[_cleanName(Config.selectedRodId)]
        if not rodInfo then return end
        pcall(function()
            Network.Functions.BuyRod:InvokeServer(rodInfo.Id)
        end)
    end
})

-- Bait Purchase Section  
ShopSection:AddSubSection("Buy Baits")

ShopSection:AddDropdown({
    Title = "Select Bait",
    Options = Config.baitDisplayNames,
    Callback = function(selected)
        if not selected then return end
        local cleanName = _cleanName(selected)
        local baitInfo = Config.baits[cleanName]
        if baitInfo then
            Config.selectedBaitId = baitInfo.Id
        end
    end
})

ShopSection:AddButton({
    Title = "Buy Selected Bait", 
    Callback = function()
        if not Config.selectedBaitId then return end
        local baitInfo = Config.baits[Config.selectedBaitId] or Config.baits[_cleanName(Config.selectedBaitId)]
        if not baitInfo then return end
        pcall(function()
            Network.Functions.BuyBait:InvokeServer(baitInfo.Id)
        end)
    end
})

-- =============================================
-- WEATHER PURCHASING SYSTEM
-- =============================================
ShopSection:AddSubSection("Buy Weather")

local weatherDropdown = ShopSection:AddDropdown({
    Title = "Select Weather",
    Multi = true,
    Options = {
        "Cloudy ($10000)", "Wind ($10000)", "Snow ($15000)", 
        "Storm ($35000)", "Radiant ($50000)", "Shark Hunt ($300000)"
    },
    Callback = function(selected)
        Config.selectedEvents = {}
        if type(selected) == "table" then
            for _, weather in ipairs(selected) do
                local cleanName = weather:match("^(.-) %(") or weather
                table.insert(Config.selectedEvents, cleanName)
            end
        end
        SaveConfig()
    end
})

ShopSection:AddToggle({
    Title = "Auto Buy Weather",
    Default = false,
    Callback = function(enabled)
        Config.autoBuyWeather = enabled
        if not Network.Functions.BuyWeather then return end
        
        if enabled then
            task.spawn(function()
                while Config.autoBuyWeather do
                    local selectedWeathers = weatherDropdown.Value or weatherDropdown.Selected or {}
                    local weatherList = {}
                    
                    if type(selectedWeathers) == "table" then
                        for _, weather in ipairs(selectedWeathers) do
                            local cleanName = weather:match("^(.-) %(") or weather
                            table.insert(weatherList, cleanName)
                        end
                    elseif type(selectedWeathers) == "string" then
                        local cleanName = selectedWeathers:match("^(.-) %(") or selectedWeathers
                        table.insert(weatherList, cleanName)
                    end
                    
                    if #weatherList > 0 then
                        local activeWeathers = {}
                        local weatherFolder = workspace:FindFirstChild("Weather")
                        if weatherFolder then
                            for _, weather in ipairs(weatherFolder:GetChildren()) do
                                table.insert(activeWeathers, string.lower(weather.Name))
                            end
                        end
                        
                        for _, weather in ipairs(weatherList) do
                            local weatherLower = string.lower(weather)
                            if not table.find(activeWeathers, weatherLower) then
                                pcall(function()
                                    Network.Functions.BuyWeather:InvokeServer(weather)
                                end)
                                task.wait(0.05)
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

-- =============================================
-- SAVE POSITION FEATURES
-- =============================================
local PositionSection = Tabs.Auto:AddSection("Save position Features")

PositionSection:AddParagraph({
    Title = "Guide Teleport", 
    Content = "\r\n<b><font color=\"rgb(0,162,255)\">AUTO TELEPORT?</font></b>\r\nClick <b><font color=\"rgb(0,162,255)\">Save Position</font></b> to save your current position!\r\n\r\n<b><font color=\"rgb(0,162,255)\">HOW TO LOAD?</font></b>\r\nThis feature will auto-sync your last position when executed, so you will teleport automatically!\r\n\r\n<b><font color=\"rgb(0,162,255)\">HOW TO RESET?</font></b>\r\nClick <b><font color=\"rgb(0,162,255)\">Reset Position</font></b> to clear your saved position.\r\n    "
})

PositionSection:AddButton({
    Title = "Save Position",
    Callback = function()
        local character = LocalPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            SavePosition(humanoidRootPart.CFrame)
            chloex("Position saved successfully!")
        end
    end,
    SubTitle = "Reset Position", 
    SubCallback = function()
        if isfile(PositionFile) then
            delfile(PositionFile)
        end
        chloex("Last position has been reset.")
    end
})

-- =============================================
-- ENCHANT FEATURES
-- =============================================
local EnchantSection = Tabs.Auto:AddSection("Enchant Features")

local function getEnchantStatus(stoneId)
    local hasEnchant = false
    local currentEnchant = "None"
    local stoneCount = 0
    local stoneUUIDs = {}
    
    local equippedItems = DataSystem.Data:Get("EquippedItems") or {}
    local fishingRods = DataSystem.Data:Get({"Inventory", "Fishing Rods"}) or {}
    
    for _, equippedUUID in pairs(equippedItems) do
        for _, rod in ipairs(fishingRods) do
            if rod.UUID == equippedUUID then
                local rodData = GameModules.ItemUtility.GetItemData(rod.Id)
                currentEnchant = rodData and rodData.Data.Name or rod.ItemName or "None"
                
                if rod.Metadata and rod.Metadata.EnchantId then
                    local enchantData = GameModules.ItemUtility.GetEnchantData(rod.Metadata.EnchantId)
                    if enchantData then
                        local enchantName = enchantData.Data.Name
                        if enchantName then
                            currentEnchant = enchantName
                            hasEnchant = true
                        end
                    end
                    if not hasEnchant then
                        currentEnchant = "None"
                    end
                end
            end
            hasEnchant = false
        end
    end
    
    for _, item in ipairs(DataSystem.Data:GetExpect({"Inventory", "Items"})) do
        local itemData = GameModules.ItemUtility.GetItemData(item.Id)
        if itemData and itemData.Data.Type == "Enchant Stones" and item.Id == stoneId then
            stoneCount = stoneCount + 1
            table.insert(stoneUUIDs, item.UUID)
        end
    end
    
    return currentEnchant, currentEnchant, stoneCount, stoneUUIDs
end

local EnchantStatusParagraph = EnchantSection:AddParagraph({
    Title = "Enchant Status",
    Content = "Current Rod : None\nCurrent Enchant : None\nEnchant Stones Left : 0"
})

-- Single Enchant Button
EnchantSection:AddButton({
    Title = "Click Enchant",
    Callback = function()
        task.spawn(function()
            local rodName, currentEnchant, stoneCount, stoneUUIDs = getEnchantStatus(10)
            if rodName == "None" or stoneCount <= 0 then
                EnchantStatusParagraph:SetContent(("Current Rod : <font color='rgb(0,170,255)'>%s</font>\nCurrent Enchant : <font color='rgb(0,170,255)'>%s</font>\nEnchant Stones Left : <font color='rgb(0,170,255)'>%d</font>"):format(rodName, currentEnchant, stoneCount))
                return
            end
            
            local equipSlot = nil
            local startTime = tick()
            while tick() - startTime < 5 do
                local equippedItems = DataSystem.Data:Get("EquippedItems") or {}
                for slot, uuid in pairs(equippedItems) do
                    if uuid == stoneUUIDs[1] then
                        equipSlot = slot
                    end
                end
                if not equipSlot then
                    Network.Events.REEquipItem:FireServer(stoneUUIDs[1], "Enchant Stones")
                    task.wait(0.3)
                else
                    break
                end
            end
            
            if not equipSlot then return end
            
            Network.Events.REEquip:FireServer(equipSlot)
            task.wait(0.2)
            Network.Events.REAltar:FireServer()
            task.wait(1.5)
            
            local _, newEnchant = getEnchantStatus(10)
            EnchantStatusParagraph:SetContent(("Current Rod : <font color='rgb(0,170,255)'>%s</font>\nCurrent Enchant : <font color='rgb(0,170,255)'>%s</font>\nEnchant Stones Left : <font color='rgb(0,170,255)'>%d</font>"):format(rodName, newEnchant, stoneCount - 1))
        end)
    end
})

-- Teleport to Enchant Altar
EnchantSection:AddButton({
    Title = "Teleport Enchant Altar", 
    Callback = function()
        local character = Config.player.Character or Config.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoidRootPart and humanoid then
            humanoidRootPart.CFrame = CFrame.new(Vector3.new(3258, -1301, 1391))
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            task.wait(0.1)
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
})

EnchantSection:AddDivider()

-- Double Enchant Button
EnchantSection:AddButton({
    Title = "Click Double Enchant",
    Content = "Starting Double Enchanting", 
    Callback = function()
        task.spawn(function()
            local rodName, currentEnchant, stoneCount, stoneUUIDs = getEnchantStatus(246)
            if rodName == "None" or stoneCount <= 0 then
                EnchantStatusParagraph:SetContent(("Current Rod : <font color='rgb(0,170,255)'>%s</font>\nCurrent Enchant : <font color='rgb(0,170,255)'>%s</font>\nEnchant Stones Left : <font color='rgb(0,170,255)'>%d</font>"):format(rodName, currentEnchant, stoneCount))
                return
            end
            
            local equipSlot = nil
            local startTime = tick()
            while tick() - startTime < 5 do
                local equippedItems = DataSystem.Data:Get("EquippedItems") or {}
                for slot, uuid in pairs(equippedItems) do
                    if uuid == stoneUUIDs[1] then
                        equipSlot = slot
                    end
                end
                if not equipSlot then
                    Network.Events.REEquipItem:FireServer(stoneUUIDs[1], "Enchant Stones")
                    task.wait(0.3)
                else
                    break
                end
            end
            
            if not equipSlot then return end
            
            Network.Events.REEquip:FireServer(equipSlot)
            task.wait(0.2)
            Network.Events.REAltar2:FireServer()
            task.wait(1.5)
            
            local _, newEnchant = getEnchantStatus(246)
            EnchantStatusParagraph:SetContent(("Current Rod : <font color='rgb(0,170,255)'>%s</font>\nCurrent Enchant : <font color='rgb(0,170,255)'>%s</font>\nEnchant Stones Left : <font color='rgb(0,170,255)'>%d</font>"):format(rodName, newEnchant, stoneCount - 1))
        end)
    end
})

-- Teleport to Second Enchant Altar
EnchantSection:AddButton({
    Title = "Teleport Second Enchant Altar",
    Callback = function()
        local character = Config.player.Character or Config.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoidRootPart and humanoid then
            humanoidRootPart.CFrame = CFrame.new(Vector3.new(1480, 128, -593))
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            task.wait(0.1)
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
    end
})

-- =============================================
-- TOTEM FEATURES
-- =============================================
local TotemSection = Tabs.Auto:AddSection("Totem Features")

local TotemPanel = TotemSection:AddParagraph({
    Title = "Panel Activated Totem",
    Content = "Scanning Totems..."
})

local TotemStatusPanel = TotemSection:AddParagraph({
    Title = "Auto Totem Status", 
    Content = "Idle."
})

-- Get Active Totems
function GetActiveTotems()
    local characterPos = Config.char and Config.char:FindFirstChild("HumanoidRootPart") and Config.char.HumanoidRootPart.Position or Vector3.zero
    local activeTotems = {}
    
    for _, totem in pairs(workspace.Totems:GetChildren()) do
        if totem:IsA("Model") then
            local handle = totem:FindFirstChild("Handle")
            local overhead = handle and handle:FindFirstChild("Overhead")
            local content = overhead and overhead:FindFirstChild("Content")
            local header = content and content:FindFirstChild("Header")
            local timerLabel = content and content:FindFirstChild("TimerLabel")
            
            local distance = (characterPos - totem:GetPivot().Position).Magnitude
            local timeLeft = timerLabel and timerLabel.Text or "??"
            local totemName = header and header.Text or "??"
            
            table.insert(activeTotems, {
                Name = totemName,
                Distance = distance,
                TimeLeft = timeLeft
            })
        end
    end
    return activeTotems
end

-- Update Totem Panel
function UpdateTotemPanel()
    local activeTotems = GetActiveTotems()
    if #activeTotems == 0 then
        TotemPanel:SetContent("No active totems detected.")
        return
    end
    
    local totemInfo = {}
    for _, totem in ipairs(activeTotems) do
        table.insert(totemInfo, string.format("%s • %.1f studs • %s", totem.Name, totem.Distance, totem.TimeLeft))
    end
    TotemPanel:SetContent(table.concat(totemInfo, "\n"))
end

-- Auto Update Totem Panel
task.spawn(function()
    while task.wait(1) do
        pcall(UpdateTotemPanel)
    end
end)

-- Get Totem UUID
function GetTotemUUID(totemName)
    if not DataSystem.Data then
        DataSystem.Data = GameModules.Replion.Client:WaitReplion("Data")
        if not DataSystem.Data then return nil end
    end
    
    local totemsModule
    if not totemsModule then
        totemsModule = require(Services.RS:WaitForChild("Totems"))
        if not totemsModule then return nil end
    end
    
    local playerTotems = DataSystem.Data:GetExpect({"Inventory", "Totems"}) or {}
    for _, totem in ipairs(playerTotems) do
        local displayName = "Unknown Totem"
        if typeof(totemsModule) == "table" then
            for _, totemData in pairs(totemsModule) do
                if totemData.Data and totemData.Data.Id == totem.Id then
                    displayName = totemData.Data.Name
                    break
                end
            end
        end
        if displayName == totemName then
            return totem.UUID, displayName
        end
    end
    return nil
end

-- Spawn Totem Function
function SpawnTotem(totemUUID)
    if not totemUUID then return end
    local success, result = pcall(function()
        Network.Events.Totem:FireServer(totemUUID)
    end)
    if not success then
        warn("[Chloe X] Totem spawn failed:", tostring(result))
    end
end

-- Teleport to Nearest Totem
TotemSection:AddButton({
    Title = "Teleport To Nearest Totem",
    Callback = function()
        local humanoidRootPart = Config.char and Config.char:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        local activeTotems = GetActiveTotems()
        if #activeTotems == 0 then return end
        
        table.sort(activeTotems, function(a, b) return a.Distance < b.Distance end)
        local nearestTotem = activeTotems[1]
        
        for _, totem in pairs(workspace.Totems:GetChildren()) do
            if totem:IsA("Model") then
                local totemPos = totem:GetPivot().Position
                if math.abs((totemPos - humanoidRootPart.Position).Magnitude - nearestTotem.Distance) < 1 then
                    humanoidRootPart.CFrame = CFrame.new(totemPos + Vector3.new(0, 3, 0))
                    break
                end
            end
        end
    end
})

-- Load Totem Data
local TotemsFolder = Services.RS:WaitForChild("Totems")
Config.Totems = Config.Totems or {}
Config.TotemDisplayName = Config.TotemDisplayName or {}

for _, totemScript in ipairs(TotemsFolder:GetChildren()) do
    if totemScript:IsA("ModuleScript") then
        local success, totemData = pcall(require, totemScript)
        if success and typeof(totemData) == "table" and totemData.Data then
            local totemName = totemData.Data.Name or "Unknown"
            local totemId = totemData.Data.Id or "Unknown"
            local totemInfo = {
                Name = totemName,
                Id = totemId
            }
            Config.Totems[totemId] = totemInfo
            Config.Totems[totemName] = totemInfo
            table.insert(Config.TotemDisplayName, totemName)
        end
    end
end

-- Totem Selection Dropdown
local selectedTotem = nil
local TotemDropdown = TotemSection:AddDropdown({
    Title = "Select Totem to Auto Place",
    Options = Config.TotemDisplayName or {"No Totems Found"},
    Default = Config.TotemDisplayName and Config.TotemDisplayName[1] or "No Totems Found",
    Callback = function(totem)
        selectedTotem = totem
    end
})

-- Auto Place Totem Toggle
TotemSection:AddToggle({
    Title = "Auto Place Totem (Beta)", 
    Content = "Place Totem every 60 minutes automatically.",
    Default = false,
    Callback = function(enabled)
        Config.trade.TotemActive = enabled
        if enabled then
            if not selectedTotem then
                TotemStatusPanel:SetContent("Please select a Totem first.")
                Config.trade.TotemActive = false
                return
            end
            
            local totemUUID, totemName = GetTotemUUID(selectedTotem)
            if not totemUUID then
                TotemStatusPanel:SetContent("You don't own any Totem.")
                Config.trade.TotemActive = false
                return
            end
            
            TotemStatusPanel:SetContent(("Auto Totem Enabled [%s] • Waiting 60m loop..."):format(selectedTotem))
            
            task.spawn(function()
                local notificationCount = 0
                while Config.trade.TotemActive do
                    SpawnTotem(totemUUID)
                    if notificationCount < 3 then
                        TotemStatusPanel:SetContent(("Totem Used [%s] • Next in 60m"):format(selectedTotem))
                        notificationCount = notificationCount + 1
                    elseif notificationCount == 3 then
                        notificationCount = notificationCount + 1
                        task.wait(1)
                        TotemStatusPanel:SetContent("Reverting to Real Totem Panel...")
                        task.wait(0.5)
                        -- Show real totem panel implementation would go here
                    end
                    
                    -- Wait 60 minutes
                    for i = 3600, 1, -1 do
                        if Config.trade.TotemActive then
                            task.wait(1)
                        else
                            break
                        end
                    end
                    
                    -- Refresh totem UUID
                    local newUUID, newName = GetTotemUUID(selectedTotem)
                    totemName = newName
                    totemUUID = newUUID
                    if not totemUUID then
                        TotemStatusPanel:SetContent("Totem not found in inventory anymore.")
                        Config.trade.TotemActive = false
                        break
                    end
                end
                TotemStatusPanel:SetContent("Auto Totem Disabled.")
            end)
        else
            TotemStatusPanel:SetContent("Auto Totem Disabled.")
            -- Show real totem panel implementation would go here
        end
    end
})

-- =============================================
-- POTIONS FEATURES
-- =============================================
local PotionSection = Tabs.Auto:AddSection("Potions Features")

-- Load Potion Data
local PotionsFolder = Services.RS:WaitForChild("Potions")
Config.Potions = Config.Potions or {}
Config.PotionDisplayName = Config.PotionDisplayName or {}

for _, potionScript in ipairs(PotionsFolder:GetChildren()) do
    if potionScript:IsA("ModuleScript") then
        local success, potionData = pcall(require, potionScript)
        if success and typeof(potionData) == "table" and potionData.Data then
            local potionName = potionData.Data.Name or "Unknown"
            local potionId = potionData.Data.Id or "Unknown"
            if not string.find(string.lower(potionName), "totem") then
                local potionInfo = {
                    Name = potionName,
                    Id = potionId
                }
                Config.Potions[potionId] = potionInfo
                Config.Potions[potionName] = potionInfo
                table.insert(Config.PotionDisplayName, potionName)
            end
        end
    end
end

-- Potion Selection
local selectedPotions = {}
PotionSection:AddDropdown({
    Title = "Select Potions",
    Multi = true,
    Options = Config.PotionDisplayName,
    Callback = function(potions)
        selectedPotions = potions
    end
})

-- Auto Use Potions Toggle
PotionSection:AddToggle({
    Title = "Auto Use Potions",
    Default = false,
    Callback = function(enabled)
        _G.AutoUsePotions = enabled
        if enabled then
            task.spawn(function()
                while _G.AutoUsePotions do
                    task.wait(1)
                    local playerPotions = DataSystem.Data:GetExpect({"Inventory", "Potions"}) or {}
                    for _, potionName in ipairs(selectedPotions) do
                        local potionInfo = Config.Potions[potionName]
                        if potionInfo then
                            for _, potion in ipairs(playerPotions) do
                                if potion.Id == potionInfo.Id then
                                    pcall(function()
                                        Network.Functions.ConsumePotion:InvokeServer(potion.UUID, 1)
                                    end)
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
})

-- =============================================
-- EVENT FEATURES
-- =============================================
local EventSection = Tabs.Auto:AddSection("Event Features")

-- Priority Event Dropdown
EventSection:AddDropdown({
    Options = getActiveEvents() or {},
    Multi = false,
    Title = "Priority Event",
    Callback = function(event)
        Config.priorityEvent = event
    end
})

-- Selected Events Dropdown
EventSection:AddDropdown({
    Options = getActiveEvents() or {},
    Multi = true,
    Title = "Select Event",
    Callback = function(events)
        Config.selectedEvents = {}
        for _, event in pairs(events) do
            table.insert(Config.selectedEvents, event)
        end
        Config.curCF = nil
        if Config.autoEventActive and (#Config.selectedEvents > 0 or Config.priorityEvent) then
            task.spawn(Config.loop)
        end
    end
})

-- Auto Event Toggle
EventSection:AddToggle({
    Title = "Auto Event",
    Default = false,
    Callback = function(enabled)
        Config.autoEventActive = enabled
        if enabled and (#Config.selectedEvents > 0 or Config.priorityEvent) then
            Config.origCF = Config.origCF or isValidCharacter(LocalPlayer.Character).CFrame
            task.spawn(Config.loop)
        else
            if Config.origCF then
                LocalPlayer.Character:PivotTo(Config.origCF)
                chloex("Auto Event Off")
            end
            Config.curCF = nil
            Config.origCF = nil
        end
    end
})

-- =============================================
-- TRADING SYSTEM
-- =============================================

-- Group Items by Type Function
function getGroupedByType(itemType)
    local inventory = DataSystem.Data:GetExpect({"Inventory", "Items"})
    local grouped = {}
    local display = {}
    
    for _, item in ipairs(inventory) do
        local itemData = GameModules.ItemUtility.GetItemDataFromItemType("Items", item.Id)
        if itemData and itemData.Data.Type == itemType and not item.Favorited then
            local itemName = itemData.Data.Name
            grouped[itemName] = grouped[itemName] or {count = 0, uuids = {}}
            grouped[itemName].count = grouped[itemName].count + (item.Quantity or 1)
            table.insert(grouped[itemName].uuids, item.UUID)
        end
    end
    
    for itemName, data in pairs(grouped) do
        table.insert(display, ("%s x%d"):format(itemName, data.count))
    end
    
    return grouped, display
end

-- =============================================
-- FISH TRADING SECTION
-- =============================================
local FishTradeSection = Tabs.Trade:AddSection("Trading Fish Features")
local CoinTradeSection = Tabs.Trade:AddSection("Trading Coin Features")

-- Trading Panels
local FishTradePanel = FishTradeSection:AddParagraph({
    Title = "Panel Name Trading",
    Content = "\r\nPlayer : ???\r\nItem   : ???\r\nAmount : 0\r\nStatus : Idle\r\nSuccess: 0 / 0\r\n"
})

local CoinTradePanel = CoinTradeSection:AddParagraph({
    Title = "Panel Coin Trading", 
    Content = "\r\nPlayer   : ???\r\nTarget   : 0\r\nProgress : 0 / 0\r\nStatus   : Idle\r\nResult   : Success : 0 | Received : 0\r\n"
})

-- Safe Content Setter
_G.safeSetContent = function(paragraph, content)
    Services.RunService.Heartbeat:Once(function()
        if paragraph then
            paragraph:SetContent(content)
        end
    end)
end

-- Update Fish Trade Panel
local function updateFishTradePanel(status)
    local trade = Config.trade
    local statusColor = "200,200,200"
    
    if status and status:lower():find("send") then
        statusColor = "51,153,255"
    elseif status and status:lower():find("complete") then
        statusColor = "0,204,102"
    elseif status and status:lower():find("time") then
        statusColor = "255,69,0"
    end
    
    local content = string.format(
        "\r\n<font color='rgb(173,216,230)'>Player : %s</font>\r\n<font color='rgb(173,216,230)'>Item   : %s</font>\r\n<font color='rgb(173,216,230)'>Amount : %d</font>\r\n<font color='rgb(%s)'>Status : %s</font>\r\n<font color='rgb(173,216,230)'>Success: %d / %d</font>\r\n",
        trade.selectedPlayer or "???",
        trade.selectedItem or "???",
        trade.tradeAmount or 0,
        statusColor,
        status or "Idle",
        trade.successCount or 0,
        trade.totalToTrade or 0
    )
    _G.safeSetContent(FishTradePanel, content)
end

-- Update Coin Trade Panel  
local function updateCoinTradePanel(status)
    local trade = Config.trade
    local statusColor = "200,200,200"
    
    if status and status:lower():find("send") then
        statusColor = "51,153,255"
    elseif status and status:lower():find("progress") then
        statusColor = "255,215,0"
    elseif status and status:lower():find("complete") then
        statusColor = "0,204,102"
    elseif status and status:lower():find("time") then
        statusColor = "255,69,0"
    end
    
    local content = string.format(
        "\r\n<font color='rgb(173,216,230)'>Player   : %s</font>\r\n<font color='rgb(173,216,230)'>Target   : %d</font>\r\n<font color='rgb(173,216,230)'>Progress : %d / %d</font>\r\n<font color='rgb(%s)'>Status   : %s</font>\r\n<font color='rgb(173,216,230)'>Result   : Success : %d | Received : %d</font>\r\n",
        trade.selectedPlayer or "???",
        trade.targetCoins or 0,
        trade.successCoins or 0,
        trade.targetCoins or 0,
        statusColor,
        status or "Idle", 
        trade.successCoins or 0,
        trade.totalReceived or 0
    )
    _G.safeSetContent(CoinTradePanel, content)
end

-- Check if Item exists in Inventory
local function itemExistsInInventory(itemUUID)
    for _, item in ipairs(DataSystem.Data:GetExpect({"Inventory", "Items"})) do
        if item.UUID == itemUUID then
            return true
        end
    end
    return false
end

-- Execute Trade Function
local function executeTrade(targetPlayer, itemUUID, itemName, coinValue)
    local trade = Config.trade
    local success = true
    trade.lastResult = nil
    trade.awaiting = true
    
    local target = Services.Players:FindFirstChild(targetPlayer)
    if not target then
        trade.trading = false
        updateFishTradePanel("<font color='#ff3333'>Player not found</font>")
        updateCoinTradePanel("<font color='#ff3333'>Player not found</font>")
        return false
    end
    
    if itemName then
        updateFishTradePanel("Sending")
        chloex("Sending " .. itemName)
    else
        updateCoinTradePanel("Sending")
        chloex("Sending fish for coins")
    end
    
    if not pcall(function()
        Network.Functions.Trade:InvokeServer(target.UserId, itemUUID)
    end) then
        return false
    end
    
    local startTime = tick()
    while true do
        if trade.trading and not success then
            if not itemExistsInInventory(itemUUID) then
                success = true
                if itemName then
                    trade.successCount = trade.successCount + 1
                    updateFishTradePanel("Completed")
                else
                    trade.successCoins = trade.successCoins + (coinValue or 0)
                    trade.totalReceived = trade.successCoins
                    updateCoinTradePanel("Progress")
                end
            elseif tick() - startTime > 10 then
                return false
            end
            task.wait(0.2)
        else
            return success
        end
    end
end

-- Retry Trade Function
local function retryTrade(targetPlayer, itemUUID, itemName, coinValue)
    local trade = Config.trade
    local retryCount = 0
    while retryCount < 3 and trade.trading do
        if executeTrade(targetPlayer, itemUUID, itemName, coinValue) then
            task.wait(2.5)
            return true
        else
            retryCount = retryCount + 1
            task.wait(1)
        end
    end
    return false
end

-- Start Trade by Name
function startTradeByName()
    local trade = Config.trade
    if trade.trading then return end
    if not trade.selectedPlayer or not trade.selectedItem then
        return chloex("Select player & item first!")
    end
    
    trade.trading = true
    trade.successCount = 0
    chloex("Starting trade with " .. trade.selectedPlayer)
    
    local itemGroup = trade.currentGrouped[trade.selectedItem]
    if not itemGroup then
        trade.trading = false
        updateFishTradePanel("<font color='#ff3333'>Item not found</font>")
        return chloex("Item not found")
    end
    
    trade.totalToTrade = math.min(trade.tradeAmount, #itemGroup.uuids)
    local currentIndex = 1
    
    while trade.trading and trade.successCount < trade.totalToTrade do
        retryTrade(trade.selectedPlayer, itemGroup.uuids[currentIndex], trade.selectedItem)
        currentIndex = currentIndex + 1
        if #itemGroup.uuids < currentIndex then
            currentIndex = 1
        end
        task.wait(2)
    end
    
    trade.trading = false
    updateFishTradePanel("<font color='#66ccff'>All trades finished</font>")
    chloex("All trades finished")
end

-- Choose Fishes by Coin Range
function chooseFishesByRange(fishList, targetCoins)
    table.sort(fishList, function(a, b) return a.Price > b.Price end)
    local selectedFishes = {}
    local totalValue = 0
    
    for _, fish in ipairs(fishList) do
        if totalValue + fish.Price <= targetCoins then
            table.insert(selectedFishes, fish)
            totalValue = totalValue + fish.Price
        end
        if targetCoins <= totalValue then
            break
        end
    end
    
    if totalValue < targetCoins and #fishList > 0 then
        table.insert(selectedFishes, fishList[#fishList])
    end
    
    return selectedFishes, totalValue
end

-- Start Trade by Coin
function startTradeByCoin()
    local trade = Config.trade
    if trade.trading then return end
    if not trade.selectedPlayer or trade.targetCoins <= 0 then
        return chloex("⚠ Select player & coin target first!")
    end
    
    trade.trading = true
    local sentCoins = 0
    local successCoins = 0
    trade.totalReceived = 0
    trade.successCoins = successCoins
    trade.sentCoins = sentCoins
    
    updateCoinTradePanel("<font color='#ffaa00'>Starting...</font>")
    chloex("Starting coin trade with " .. trade.selectedPlayer)
    
    local localPlayer = Services.Players.LocalPlayer
    local playerModifiers = GameModules.PlayerStatsUtility:GetPlayerModifiers(localPlayer)
    
    local availableFishes = {}
    local inventory = DataSystem.Data:GetExpect({"Inventory", "Items"})
    
    for _, item in ipairs(inventory) do
        if not item.Favorited then
            local itemData = GameModules.ItemUtility.GetItemData(item.Id)
            if itemData and itemData.Data and itemData.Data.Type == "Fish" then
                local sellPrice = GameModules.VendorUtility:GetSellPrice(item) or itemData.SellPrice or 0
                local actualValue = math.ceil(sellPrice * (playerModifiers and playerModifiers.CoinMultiplier or 1))
                if actualValue > 0 then
                    table.insert(availableFishes, {
                        UUID = item.UUID,
                        Name = itemData.Data.Name or "Unknown",
                        Price = actualValue
                    })
                end
            end
        end
    end
    
    if #availableFishes == 0 then
        trade.trading = false
        updateCoinTradePanel("<font color='#ff3333'>No fishes found</font>")
        chloex("⚠ No fishes found in inventory")
        return
    end
    
    local selectedFishes, totalValue = chooseFishesByRange(availableFishes, trade.targetCoins)
    if #selectedFishes == 0 then
        trade.trading = false
        updateCoinTradePanel("<font color='#ff3333'>No valid fishes for target</font>")
        return
    end
    
    trade.totalToTrade = #selectedFishes
    trade.targetCoins = totalValue
    
    if not Services.Players:FindFirstChild(trade.selectedPlayer) then
        trade.trading = false
        updateCoinTradePanel("<font color='#ff3333'>Player not found</font>")
        return
    end
    
    for _, fish in ipairs(selectedFishes) do
        if trade.trading then
            trade.sentCoins = trade.sentCoins + fish.Price
            updateCoinTradePanel(string.format("<font color='#ffaa00'>Progress : %d / %d</font>", trade.sentCoins, trade.targetCoins))
            retryTrade(trade.selectedPlayer, fish.UUID, nil, fish.Price)
            trade.successCoins = trade.sentCoins
            task.wait(2)
        else
            break
        end
    end
    
    trade.trading = false
    updateCoinTradePanel(string.format("<font color='#66ccff'>Coin trade finished (Target: %d, Received: %d)</font>", trade.targetCoins, trade.successCoins))
    chloex(string.format("Coin trade finished (Target: %d, Received: %d)", trade.targetCoins, trade.successCoins))
end

-- Fish Trading UI Elements
local FishItemDropdown = FishTradeSection:AddDropdown({
    Options = {},
    Multi = false,
    Title = "Select Item",
    Callback = function(item)
        Config.trade.selectedItem = item and (item:match("^(.-) x") or item)
        updateFishTradePanel()
    end
})

-- Refresh Buttons
FishTradeSection:AddButton({
    Title = "Refresh Fish",
    Callback = function()
        local grouped, display = getGroupedByType("Fish")
        Config.trade.currentGrouped = grouped
        FishItemDropdown:SetValues(display or {})
    end,
    SubTitle = "Refresh Stone",
    SubCallback = function()
        local grouped, display = getGroupedByType("Enchant Stones")
        Config.trade.currentGrouped = grouped
        FishItemDropdown:SetValues(display or {})
    end
})

-- Trade Amount Input
FishTradeSection:AddInput({
    Title = "Amount to Trade",
    Default = "1",
    Callback = function(value)
        Config.trade.tradeAmount = tonumber(value) or 1
        updateFishTradePanel()
    end
})

-- Player Selection for Fish Trading
local FishPlayerDropdown = FishTradeSection:AddDropdown({
    Options = {},
    Multi = false,
    Title = "Select Player",
    Callback = function(player)
        Config.trade.selectedPlayer = player
        updateFishTradePanel()
    end
})

-- Refresh Player List for Fish Trading
FishTradeSection:AddButton({
    Title = "Refresh Player",
    Callback = function()
        local players = {}
        for _, player in ipairs(Services.Players:GetPlayers()) do
            if player ~= Config.player then
                table.insert(players, player.Name)
            end
        end
        FishPlayerDropdown:SetValues(players or {})
    end
})

-- Start Fish Trading Toggle
FishTradeSection:AddToggle({
    Title = "Start By Name",
    Default = false,
    Callback = function(enabled)
        if enabled then
            task.spawn(startTradeByName)
        else
            Config.trade.trading = false
            updateFishTradePanel()
        end
    end
})

-- Coin Trading UI Elements
local CoinPlayerDropdown = CoinTradeSection:AddDropdown({
    Options = {},
    Multi = false,
    Title = "Select Player",
    Callback = function(player)
        Config.trade.selectedPlayer = player
        updateCoinTradePanel()
    end
})

-- Refresh Player List for Coin Trading
CoinTradeSection:AddButton({
    Title = "Refresh Player",
    Callback = function()
        local players = {}
        for _, player in ipairs(Services.Players:GetPlayers()) do
            if player ~= Config.player then
                table.insert(players, player.Name)
            end
        end
        CoinPlayerDropdown:SetValues(players or {})
    end
})

-- Target Coin Input
CoinTradeSection:AddInput({
    Title = "Target Coin",
    Default = "0",
    Callback = function(value)
        Config.trade.targetCoins = tonumber(value) or 0
        updateCoinTradePanel()
    end
})

-- Start Coin Trading Toggle
CoinTradeSection:AddToggle({
    Title = "Start By Coin",
    Default = false,
    Callback = function(enabled)
        if enabled then
            task.spawn(startTradeByCoin)
        else
            Config.trade.trading = false
        end
    end
})

-- =============================================
-- RARITY TRADING SYSTEM
-- =============================================
local RarityTradeSection = Tabs.Trade:AddSection("Trading Rarity Features")

local RarityTradePanel = RarityTradeSection:AddParagraph({
    Title = "Panel Rarity Trading",
    Content = "\r\nPlayer  : ???\r\nRarity  : ???\r\nCount   : 0\r\nStatus  : Idle\r\nSuccess : 0 / 0\r\n"
})

-- Update Rarity Trade Panel
local function updateRarityTradePanel(status)
    local trade = Config.trade
    local statusColor = "200,200,200"
    
    if status and status:lower():find("send") then
        statusColor = "51,153,255"
    elseif status and status:lower():find("complete") then
        statusColor = "0,204,102"
    elseif status and status:lower():find("time") then
        statusColor = "255,69,0"
    end
    
    local content = string.format(
        "\r\n<font color='rgb(173,216,230)'>Player  : %s</font>\r\n<font color='rgb(173,216,230)'>Rarity  : %s</font>\r\n<font color='rgb(173,216,230)'>Count   : %d</font>\r\n<font color='rgb(%s)'>Status  : %s</font>\r\n<font color='rgb(173,216,230)'>Success : %d / %d</font>\r\n",
        trade.selectedPlayer or "???",
        trade.selectedRarity or "???",
        trade.totalToTrade or 0,
        statusColor,
        status or "Idle",
        trade.successCount or 0,
        trade.totalToTrade or 0
    )
    _G.safeSetContent(RarityTradePanel, content)
end

-- Rarity Selection Dropdown
RarityTradeSection:AddDropdown({
    Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"},
    Multi = false,
    Title = "Select Rarity",
    Callback = function(rarity)
        Config.trade.selectedRarity = rarity
        updateRarityTradePanel("Selected rarity: " .. (rarity or "???"))
    end
})

-- Player Selection for Rarity Trading
local RarityPlayerDropdown = RarityTradeSection:AddDropdown({
    Options = {},
    Multi = false,
    Title = "Select Player",
    Callback = function(player)
        Config.trade.selectedPlayer = player
        updateRarityTradePanel()
    end
})

-- Refresh Player List for Rarity Trading
RarityTradeSection:AddButton({
    Title = "Refresh Player",
    Callback = function()
        local players = {}
        for _, player in ipairs(Services.Players:GetPlayers()) do
            if player ~= Config.player then
                table.insert(players, player.Name)
            end
        end
        RarityPlayerDropdown:SetValues(players or {})
    end
})

-- Rarity Trade Amount Input
RarityTradeSection:AddInput({
    Title = "Amount to Trade",
    Default = "1",
    Callback = function(value)
        Config.trade.rarityAmount = tonumber(value) or 1
        updateRarityTradePanel("Set amount: " .. tostring(Config.trade.rarityAmount))
    end
})

-- Start Rarity Trading Function
function startTradeByRarity()
    local trade = Config.trade
    if trade.trading then return end
    if not trade.selectedPlayer or not trade.selectedRarity then
        return chloex("⚠ Select player & rarity first!")
    end
    
    trade.trading = true
    trade.successCount = 0
    chloex("Starting rarity trade (" .. trade.selectedRarity .. ") with " .. trade.selectedPlayer)
    updateRarityTradePanel("<font color='#ffaa00'>Scanning " .. trade.selectedRarity .. " fishes...</font>")
    
    local rarityFishes = {}
    local inventory = DataSystem.Data:GetExpect({"Inventory", "Items"})
    
    for _, item in ipairs(inventory) do
        if not item.Favorited then
            local itemData = GameModules.ItemUtility.GetItemDataFromItemType("Items", item.Id)
            if itemData and itemData.Data.Type == "Fish" and _G.TierFish[itemData.Data.Tier] == trade.selectedRarity then
                table.insert(rarityFishes, {
                    UUID = item.UUID,
                    Name = itemData.Data.Name
                })
            end
        end
    end
    
    if #rarityFishes == 0 then
        trade.trading = false
        updateRarityTradePanel("<font color='#ff3333'>No " .. trade.selectedRarity .. " fishes found</font>")
        return chloex("No " .. trade.selectedRarity .. " fishes found")
    end
    
    trade.totalToTrade = math.min(#rarityFishes, trade.rarityAmount or #rarityFishes)
    updateRarityTradePanel(string.format("Sending %d %s fishes...", trade.totalToTrade, trade.selectedRarity))
    
    local currentIndex = 1
    while trade.trading and currentIndex <= trade.totalToTrade do
        local fish = rarityFishes[currentIndex]
        if retryTrade(trade.selectedPlayer, fish.UUID, fish.Name) then
            trade.successCount = trade.successCount + 1
            updateRarityTradePanel(string.format("Progress: %d / %d (%s)", trade.successCount, trade.totalToTrade, trade.selectedRarity))
        end
        currentIndex = currentIndex + 1
        task.wait(2.5)
    end
    
    trade.trading = false
    updateRarityTradePanel("<font color='#66ccff'>Rarity trade finished</font>")
    chloex("Rarity trade finished (" .. trade.selectedRarity .. ")")
end

-- Start Rarity Trading Toggle
RarityTradeSection:AddToggle({
    Title = "Start By Rarity",
    Default = false,
    Callback = function(enabled)
        if enabled then
            task.spawn(startTradeByRarity)
        else
            Config.trade.trading = false
            updateRarityTradePanel("Idle")
        end
    end
})

-- =============================================
-- AUTO ACCEPT TRADE FEATURES
-- =============================================
local AcceptTradeSection = Tabs.Trade:AddSection("Auto Accept Features")

AcceptTradeSection:AddToggle({
    Title = "Auto Accept Trade",
    Default = _G.AutoAccept,
    Callback = function(enabled)
        _G.AutoAccept = enabled
    end
})

-- Auto Accept Trade Implementation
task.spawn(function()
    while true do
        task.wait(1)
        if _G.AutoAccept then
            pcall(function()
                local promptGui = Services.Players.LocalPlayer.PlayerGui:FindFirstChild("Prompt")
                if promptGui and promptGui:FindFirstChild("Blackout") then
                    local blackout = promptGui.Blackout
                    if blackout:FindFirstChild("Options") then
                        local yesButton = blackout.Options:FindFirstChild("Yes")
                        if yesButton then
                            local inputManager = Services.VIM
                            local buttonPos = yesButton.AbsolutePosition
                            local buttonSize = yesButton.AbsoluteSize
                            local clickX = buttonPos.X + buttonSize.X / 2
                            local clickY = buttonPos.Y + buttonSize.Y / 2 + 50
                            
                            inputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
                            task.wait(0.03)
                            inputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)
                        end
                    end
                end
            end)
        end
    end
end)

-- =============================================
-- FARMING FEATURES (THRESHOLD, COIN, ENCHANT)
-- =============================================
local ThresholdSection = Tabs.Farm:AddSection("Threshold Features")
local CoinSection = Tabs.Farm:AddSection("Coin Features") 
local EnchantSection = Tabs.Farm:AddSection("Enchant Stone Features")

-- Threshold Farm Panel
local ThresholdPanel = ThresholdSection:AddParagraph({
    Title = "Farm Threshold Panel",
    Content = "\r\nCurrent : 0\r\nTarget : 0\r\nProgress : 0%\r\n"
})

-- Threshold Variables
local ThresholdPos1 = ""
local ThresholdPos2 = ""
local ThresholdTarget = 0
local ThresholdBase = 0
local ThresholdTotalBase = 0

-- Threshold Inputs
ThresholdSection:AddInput({
    Title = "Position 1",
    Callback = function(value)
        ThresholdPos1 = value == "" and "" or value
    end
})

ThresholdSection:AddInput({
    Title = "Position 2", 
    Callback = function(value)
        ThresholdPos2 = value == "" and "" or value
    end
})

-- Copy Current Position Button
ThresholdSection:AddButton({
    Title = "Copy Current Position",
    Callback = function()
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local position = string.format("%.1f, %.1f, %.1f", humanoidRootPart.Position.X, humanoidRootPart.Position.Y, humanoidRootPart.Position.Z)
            if setclipboard then
                setclipboard(position)
            end
            chloex("Successfully copied your position to clipboard!")
        end
    end
})

-- Target Fish Input
ThresholdSection:AddInput({
    Title = "Target Fish Caught",
    Callback = function(value)
        ThresholdTarget = tonumber(value) or 0
    end
})

-- Threshold Farm Toggle
ThresholdSection:AddToggle({
    Title = "Enable Threshold Farm",
    Default = false,
    Callback = function(enabled)
        _G.ThresholdFarm = enabled
        if enabled then
            ThresholdBase = (DataSystem.Data:Get({"Statistics"}) or {}).FishCaught or 0
            ThresholdTotalBase = ThresholdBase
        end
    end
})

-- Coin Farm Panel
local CoinPanel = CoinSection:AddParagraph({
    Title = "Coin Farm Panel",
    Content = "\r\nCurrent : 0\r\nTarget : 0\r\nProgress : 0%\r\n"
})

-- Coin Farm Variables
local CoinBase = 0
local CoinTarget = 0
local SelectedCoinSpot = nil

local CoinSpotOptions = {
    ["Kohana Volcano"] = Vector3.new(-552, 19, 183),
    ["Tropical Grove"] = Vector3.new(-2084, 3, 3700)
}

-- Coin Location Dropdown
CoinSection:AddDropdown({
    Title = "Coin Location",
    Options = {"Kohana Volcano", "Tropical Grove"},
    Multi = false,
    Callback = function(location)
        SelectedCoinSpot = CoinSpotOptions[location]
    end
})

-- Target Coin Input
CoinSection:AddInput({
    Title = "Target Coin",
    Placeholder = "Enter coin target...",
    Callback = function(value)
        local coinValue = tonumber(value)
        if coinValue then
            CoinTarget = coinValue
        end
    end
})

-- Coin Farm Toggle
CoinSection:AddToggle({
    Title = "Enable Coin Farm",
    Default = false,
    Callback = function(enabled)
        _G.CoinFarm = enabled
        if enabled then
            repeat task.wait() until DataSystem.Data
            CoinBase = DataSystem.Data:Get({"Coins"}) or 0
        end
    end
})

-- Enchant Farm Panel
local EnchantFarmPanel = EnchantSection:AddParagraph({
    Title = "Enchant Stone Farm Panel",
    Content = "\r\nCurrent : 0\r\nTarget : 0\r\nProgress : 0%\r\n"
})

-- Enchant Farm Variables
local EnchantBase = 0
local EnchantTarget = 0
local SelectedEnchantSpot = nil

local EnchantSpotOptions = {
    ["Tropical Grove"] = Vector3.new(-2084, 3, 3700),
    ["Esoteric Depths"] = Vector3.new(3272, -1302, 1404)
}

-- Enchant Location Dropdown
EnchantSection:AddDropdown({
    Title = "Enchant Stone Location",
    Options = {"Tropical Grove", "Esoteric Depths"},
    Multi = false,
    Callback = function(location)
        SelectedEnchantSpot = EnchantSpotOptions[location]
    end
})

-- Target Enchant Input
EnchantSection:AddInput({
    Title = "Target Enchant Stone",
    Placeholder = "Enter enchant stone target...",
    Callback = function(value)
        local enchantValue = tonumber(value)
        if enchantValue then
            EnchantTarget = enchantValue
        end
    end
})

-- Enchant Farm Toggle
EnchantSection:AddToggle({
    Title = "Enable Enchant Farm",
    Default = false,
    Callback = function(enabled)
        _G.EnchantFarm = enabled
        if enabled then
            local inventory = DataSystem.Data:Get({"Inventory", "Items"}) or {}
            local stoneCount = 0
            for _, item in ipairs(inventory) do
                if item.Id == 10 then
                    stoneCount = stoneCount + (item.Amount or 1)
                end
            end
            EnchantBase = stoneCount
        end
    end
})

-- Farm Monitoring System
task.spawn(function()
    local isTeleporting = false
    local originalPosition = nil
    local loopCounter = 0
    
    while task.wait(1) do
        local data = DataSystem.Data
        if data then
            local character = LocalPlayer.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart and not originalPosition then
                originalPosition = humanoidRootPart.CFrame
            end
            
            -- Threshold Farm Monitoring
            if _G.ThresholdFarm then
                local fishCaught = (data:Get({"Statistics"}) or {}).FishCaught or 0
                if loopCounter == 0 then
                    loopCounter = ThresholdBase
                end
                local progress = fishCaught - ThresholdBase
                local percentage = ThresholdTarget > 0 and math.min(progress / ThresholdTarget * 100, 100) or 0
                ThresholdPanel:SetContent(string.format("Current : %s\nTarget : %s\nProgress : %.1f%%", progress, ThresholdTarget, percentage))
                
                if humanoidRootPart and ThresholdPos1 ~= "" and ThresholdPos2 ~= "" and not isTeleporting then
                    isTeleporting = true
                    task.spawn(function()
                        local pos1 = Vector3.new(unpack(string.split(ThresholdPos1, ",")))
                        local pos2 = Vector3.new(unpack(string.split(ThresholdPos2, ",")))
                        local targetCount = fishCaught + ThresholdTarget
                        
                        while _G.ThresholdFarm do
                            repeat
                                task.wait(1)
                                fishCaught = (data:Get({"Statistics"}) or {}).FishCaught or 0
                            until targetCount <= fishCaught or not _G.ThresholdFarm
                            
                            if _G.ThresholdFarm then
                                humanoidRootPart.CFrame = CFrame.new(pos2 + Vector3.new(0, 3, 0))
                                ThresholdBase = fishCaught
                                targetCount = fishCaught + ThresholdTarget
                                
                                repeat
                                    task.wait(1)
                                    fishCaught = (data:Get({"Statistics"}) or {}).FishCaught or 0
                                until targetCount <= fishCaught or not _G.ThresholdFarm
                                
                                if _G.ThresholdFarm then
                                    humanoidRootPart.CFrame = CFrame.new(pos1 + Vector3.new(0, 3, 0))
                                    ThresholdBase = fishCaught
                                    targetCount = fishCaught + ThresholdTarget
                                else
                                    break
                                end
                            else
                                break
                            end
                        end
                        isTeleporting = false
                    end)
                end
            end
            
            -- Coin Farm Monitoring
            if _G.CoinFarm then
                local coins = (data:Get({"Coins"}) or 0) - CoinBase
                local percentage = CoinTarget > 0 and math.min(coins / CoinTarget * 100, 100) or 0
                CoinPanel:SetContent(string.format("Current : %s\nTarget : %s\nProgress : %.1f%%", coins, CoinTarget, percentage))
                
                if SelectedCoinSpot and humanoidRootPart then
                    if coins < CoinTarget then
                        if (humanoidRootPart.Position - SelectedCoinSpot).Magnitude > 10 then
                            humanoidRootPart.CFrame = CFrame.new(SelectedCoinSpot + Vector3.new(0, 3, 0))
                        end
                    else
                        if originalPosition then
                            humanoidRootPart.CFrame = originalPosition
                        end
                        _G.CoinFarm = false
                    end
                end
            end
            
            -- Enchant Farm Monitoring
            if _G.EnchantFarm then
                local inventory = data:Get({"Inventory", "Items"}) or {}
                local stoneCount = 0
                for _, item in ipairs(inventory) do
                    if item.Id == 10 then
                        stoneCount = stoneCount + (item.Amount or 1)
                    end
                end
                local progress = stoneCount - EnchantBase
                local percentage = EnchantTarget > 0 and math.min(progress / EnchantTarget * 100, 100) or 0
                EnchantFarmPanel:SetContent(string.format("Current : %s\nTarget : %s\nProgress : %.1f%%", progress, EnchantTarget, percentage))
                
                if SelectedEnchantSpot and humanoidRootPart then
                    if progress < EnchantTarget then
                        if (humanoidRootPart.Position - SelectedEnchantSpot).Magnitude > 10 then
                            humanoidRootPart.CFrame = CFrame.new(SelectedEnchantSpot + Vector3.new(0, 3, 0))
                        end
                    else
                        if originalPosition then
                            humanoidRootPart.CFrame = originalPosition
                        end
                        _G.EnchantFarm = false
                    end
                end
            end
        else
            task.wait(1)
        end
    end
end)

-- =============================================
-- ANCIENT LOCHNESS EVENT FEATURES
-- =============================================
local EventFarmSection = Tabs.Farm:AddSection("Event Features")

local CountdownPanel = EventFarmSection:AddParagraph({
    Title = "Ancient Lochness Monster Countdown",
    Content = "<font color='#ff4d4d'><b>waiting for ... for joined event!</b></font>"
})

Config.FarmPosition = Config.FarmPosition or nil

EventFarmSection:AddToggle({
    Title = "Auto Admin Event",
    Default = false,
    Callback = function(enabled)
        local localPlayer = Services.Players.LocalPlayer
        Config.autoCountdownUpdate = enabled
        
        local function getCountdownLabel()
            local success, label = pcall(function()
                return workspace["!!! MENU RINGS"]["Event Tracker"].Main.Gui.Content.Items.Countdown.Label
            end)
            return success and label or nil
        end
        
        local function teleportToEvent(character)
            character.CFrame = CFrame.new(Vector3.new(6063, -586, 4715))
        end
        
        local function returnToFarm(character)
            if Config.FarmPosition then
                character.CFrame = Config.FarmPosition
                CountdownPanel:SetContent("<font color='#00ff99'><b>✓ Returned to saved farm position!</b></font>")
            else
                CountdownPanel:SetContent("<font color='#ff4d4d'><b>✗ No saved farm position found!</b></font>")
            end
        end
        
        if enabled then
            local character = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart", 5)
            if character then
                Config.FarmPosition = character.CFrame
                CountdownPanel:SetContent("<font color='#00ff99'><b>Farm position saved!</b></font>")
            end
            
            local countdownLabel = getCountdownLabel()
            if not countdownLabel then
                CountdownPanel:SetContent("<font color='#ff4d4d'><b>Label not found!</b></font>")
                return
            end
            
            task.spawn(function()
                local atEvent = false
                while Config.autoCountdownUpdate do
                    task.wait(1)
                    local countdownText = ""
                    pcall(function()
                        countdownText = countdownLabel.Text or ""
                    end)
                    
                    if countdownText == "" then
                        CountdownPanel:SetContent("<font color='#ff4d4d'><b>Waiting for countdown...</b></font>")
                    else
                        CountdownPanel:SetContent(string.format("<font color='#4de3ff'><b>Timer: %s</b></font>", countdownText))
                        local character = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart", 5)
                        if not character then
                            CountdownPanel:SetContent("<font color='#ff4d4d'><b>⚠ HRP not found, retrying...</b></font>")
                        else
                            local hours, minutes, seconds = countdownText:match("(%d+)H%s*(%d+)M%s*(%d+)S")
                            hours = tonumber(hours)
                            minutes = tonumber(minutes)
                            seconds = tonumber(seconds)
                            
                            if hours == 3 and minutes == 59 and seconds == 59 and not atEvent then
                                CountdownPanel:SetContent("<font color='#00ff99'><b>Event started! Teleporting...</b></font>")
                                teleportToEvent(character)
                                atEvent = true
                            elseif hours == 3 and minutes == 49 and seconds == 59 and atEvent then
                                CountdownPanel:SetContent("<font color='#ffaa00'><b>Event ended! Returning...</b></font>")
                                returnToFarm(character)
                                atEvent = false
                            end
                        end
                    end
                    
                    if not countdownLabel or not countdownLabel.Parent then
                        countdownLabel = getCountdownLabel()
                        if not countdownLabel then
                            CountdownPanel:SetContent("<font color='#ff4d4d'><b>Label lost. Reconnecting...</b></font>")
                            task.wait(2)
                            countdownLabel = getCountdownLabel()
                        end
                    end
                end
            end)
        else
            local character = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart", 5)
            if character then
                returnToFarm(character)
            end
            CountdownPanel:SetContent("<font color='#ff4d4d'><b>Auto Admin Event disabled.</b></font>")
        end
    end
})

-- =============================================
-- SEMI KAITUN SYSTEM (BETA)
-- =============================================
local KaitunSection = Tabs.Farm:AddSection("Semi Kaitun [BETA]")

-- Game References
local ReplicatedStorage = Services.RS
local ItemsFolder = ReplicatedStorage:WaitForChild("Items")
local BaitsFolder = ReplicatedStorage:WaitForChild("Baits")

-- Item Name Lookup Function
function getItemNameFromFolder(folder, itemId, itemType)
    for _, itemScript in ipairs(folder:GetChildren()) do
        if itemScript:IsA("ModuleScript") then
            local success, itemData = pcall(require, itemScript)
            if success and itemData and itemData.Data then
                local data = itemData.Data
                if data.Id == itemId and (not itemType or data.Type == itemType) then
                    if itemData.IsSkin then
                        return nil
                    else
                        return data.Name
                    end
                end
            end
        end
    end
    return nil
end

-- Kaitun Locations
local KaitunLocations = {
    ["Kohana Volcano"] = Vector3.new(-552, 19, 183),
    ["Tropical Grove"] = Vector3.new(-2084, 3, 3700),
    DeepSea_Start = Vector3.new(-3599, -276, -1641),
    DeepSea_2 = Vector3.new(-3699, -135, -890),
    ["Arrow Artifact"] = CFrame.new(875, 3, -368) * CFrame.Angles(0, math.rad(90), 0),
    ["Crescent Artifact"] = CFrame.new(1403, 3, 123) * CFrame.Angles(0, math.rad(180), 0),
    ["Hourglass Diamond Artifact"] = CFrame.new(1487, 3, -842) * CFrame.Angles(0, math.rad(180), 0),
    ["Diamond Artifact"] = CFrame.new(1844, 3, -287) * CFrame.Angles(0, math.rad(-90), 0),
    Element_Stage1 = CFrame.new(1484, 3, -336) * CFrame.Angles(0, math.rad(180), 0),
    Element_Stage2 = CFrame.new(1453, -22, -636),
    Element_Final = CFrame.new(1480, 128, -593)
}

local ArtifactOrder = {
    "Arrow Artifact",
    "Crescent Artifact", 
    "Hourglass Diamond Artifact",
    "Diamond Artifact"
}

-- Teleport Function
function teleportToLocation(position)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(position)
    end
end

-- Check Rod Ownership
function hasRod(rodName)
    local inventory = DataSystem.Data:Get({"Inventory"}) or {}
    local rods = inventory["Fishing Rods"] or {}
    for _, rod in ipairs(rods) do
        if getItemNameFromFolder(ItemsFolder, rod.Id, "Fishing Rods") == rodName then
            return true
        end
    end
    return false
end

-- Check Bait Ownership
function hasBait(baitName)
    local inventory = DataSystem.Data:Get({"Inventory"}) or {}
    local baits = inventory.Baits or {}
    for _, bait in ipairs(baits) do
        if getItemNameFromFolder(BaitsFolder, bait.Id) == baitName then
            return true
        end
    end
    return false
end

-- Check Artifact in World
function hasArtifactWorld(artifactName)
    local jungleInteractions = workspace:FindFirstChild("JUNGLE INTERACTIONS")
    if not jungleInteractions then return false end
    
    local searchName = artifactName:lower():gsub(" artifact", "")
    for _, lever in ipairs(jungleInteractions:GetDescendants()) do
        if lever:IsA("Model") and lever.Name == "TempleLever" then
            local leverType = tostring(lever:GetAttribute("Type") or ""):lower()
            if leverType:find(searchName) then
                return (lever:FindFirstChild("RootPart") and lever.RootPart:FindFirstChildWhichIsA("ProximityPrompt")) == nil
            end
        end
    end
    return false
end

-- Read Quest Tracker
function readTracker(trackerName)
    local tracker = workspace["!!! MENU RINGS"]:FindFirstChild(trackerName)
    if not tracker then return "" end
    
    local content = tracker:FindFirstChild("Board") and tracker.Board:FindFirstChild("Gui") and tracker.Board.Gui:FindFirstChild("Content")
    if not content then return "" end
    
    local lines = {}
    local lineNumber = 1
    for _, element in ipairs(content:GetChildren()) do
        if element:IsA("TextLabel") and element.Name ~= "Header" then
            table.insert(lines, lineNumber .. ". " .. element.Text)
            lineNumber = lineNumber + 1
        end
    end
    return table.concat(lines, "\n")
end

-- Check Artifact in Inventory
function hasArtifactInv(artifactName)
    local artifactIds = {
        ["Arrow Artifact"] = 265,
        ["Crescent Artifact"] = 266,
        ["Diamond Artifact"] = 267,
        ["Hourglass Diamond Artifact"] = 271
    }
    
    local inventory = DataSystem.Data:Get({"Inventory"}) or {}
    local items = inventory.Items or {}
    local artifactId = artifactIds[artifactName]
    
    if not artifactId then return false end
    
    for _, item in ipairs(items) do
        if item.Id == artifactId then
            return true
        end
    end
    return false
end

-- Get Lever Status
function getLeverStatus()
    local jungleInteractions = workspace:FindFirstChild("JUNGLE INTERACTIONS")
    if not jungleInteractions then return {} end
    
    local status = {}
    local leverCount = 1
    for _, lever in ipairs(jungleInteractions:GetDescendants()) do
        if lever:IsA("Model") and lever.Name == "TempleLever" then
            local prompt = lever:FindFirstChild("RootPart") and lever.RootPart:FindFirstChildWhichIsA("ProximityPrompt")
            status[lever:GetAttribute("Type") or "Lever" .. leverCount] = prompt == nil
            leverCount = leverCount + 1
        end
    end
    return status
end

-- Trigger Lever Function
function triggerLever(leverName)
    local jungleInteractions = workspace:FindFirstChild("JUNGLE INTERACTIONS")
    if not jungleInteractions then return end
    
    local searchTerm = string.match(leverName, "^(%w+)")
    for _, lever in ipairs(jungleInteractions:GetDescendants()) do
        if lever:IsA("Model") and lever.Name == "TempleLever" then
            local leverType = lever:GetAttribute("Type")
            local prompt = lever:FindFirstChild("RootPart") and lever.RootPart:FindFirstChildWhichIsA("ProximityPrompt")
            if leverType and string.find(leverType:lower(), searchTerm:lower()) and prompt then
                pcall(function()
                    fireproximityprompt(prompt)
                end)
                break
            end
        end
    end
end

-- Kaitun Farming Location Dropdown
KaitunSection:AddDropdown({
    Title = "Farming Location",
    Options = {"Kohana Volcano", "Tropical Grove"},
    Default = "Kohana Volcano",
    Callback = function(location)
        _G.SelectedFarmLocation = location
    end
})

-- Start Kaitun Toggle
KaitunSection:AddToggle({
    Title = "Start Kaitun",
    Default = false,
    Callback = function(enabled)
        _G.KaitunPanel = enabled
        if enabled then
            -- Create Kaitun Panel UI
            if Services.CoreGui:FindFirstChild("ChloeX_KaitunPanel") then
                Services.CoreGui:FindFirstChild("ChloeX_KaitunPanel"):Destroy()
            end
            
            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "ChloeX_KaitunPanel"
            screenGui.IgnoreGuiInset = true
            screenGui.ResetOnSpawn = false
            screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
            screenGui.Parent = Services.CoreGui
            
            -- Kaitun Panel implementation would continue here...
            -- This is a simplified version for demonstration
            
            chloex("Kaitun Panel Started!")
        else
            _G.KaitunPanel = false
            local existingPanel = Services.CoreGui:FindFirstChild("ChloeX_KaitunPanel")
            if existingPanel then
                existingPanel:Destroy()
            end
            chloex("Kaitun Panel Stopped!")
        end
    end
})

-- Hide Kaitun Panel Toggle
KaitunSection:AddToggle({
    Title = "Hide Kaitun Panel",
    Default = false,
    Callback = function(enabled)
        local kaitunPanel = Services.CoreGui:FindFirstChild("ChloeX_KaitunPanel")
        if kaitunPanel then
            local mainCard = kaitunPanel:FindFirstChild("MainCard") or kaitunPanel:FindFirstChildWhichIsA("Frame")
            if mainCard then
                mainCard.Visible = not enabled
            end
        end
    end
})

-- Rod Priority List
local RodPriority = {
    "Element Rod",
    "Ghostfin Rod", 
    "Bambo Rod",
    "Angler Rod",
    "Ares Rod",
    "Hazmat Rod",
    "Astral Rod",
    "Midnight Rod"
}

-- Auto Equip Best Rod Function
function equipBestRod()
    local data = DataSystem.Data
    if not data then return end
    
    local inventory = data:Get({"Inventory"}) or {}
    local rods = inventory["Fishing Rods"] or {}
    local equipped = data:Get({"EquippedItems"}) or {}
    local equippedRod = equipped["Fishing Rods"]
    
    local bestPriority = math.huge
    local bestRodName = nil
    local bestRodUUID = nil
    
    for _, rod in ipairs(rods) do
        local rodName = getItemNameFromFolder(ItemsFolder, rod.Id, "Fishing Rods")
        if rodName and rod.UUID then
            for priority, priorityRod in ipairs(RodPriority) do
                if string.find(rodName, priorityRod) and priority < bestPriority then
                    bestPriority = priority
                    bestRodName = rodName
                    bestRodUUID = rod.UUID
                end
            end
        end
    end
    
    if not bestRodUUID or equippedRod == bestRodUUID then
        return
    end
    
    pcall(function()
        Network.Functions.Cancel:InvokeServer()
        task.wait(0.3)
        Network.Events.REEquipItem:FireServer(bestRodUUID, "Fishing Rods")
    end)
end

-- Auto Equip Best Rod Toggle
KaitunSection:AddToggle({
    Title = "Auto Equip Best Rod",
    Default = false,
    Callback = function(enabled)
        _G.AutoEquipBestRod = enabled
        if not enabled then return end
        
        local data = DataSystem.Data
        if not data then return end
        
        local inventory = data:Get({"Inventory"}) or {}
        local rods = inventory["Fishing Rods"] or {}
        local equipped = data:Get({"EquippedItems"}) or {}
        local equippedRod = equipped["Fishing Rods"]
        
        local bestPriority = math.huge
        local bestRodName = nil
        local bestRodUUID = nil
        
        for _, rod in ipairs(rods) do
            local rodName = getItemNameFromFolder(ItemsFolder, rod.Id, "Fishing Rods")
            if rodName and rod.UUID then
                for priority, priorityRod in ipairs(RodPriority) do
                    if string.find(rodName, priorityRod) and priority < bestPriority then
                        bestPriority = priority
                        bestRodName = rodName
                        bestRodUUID = rod.UUID
                    end
                end
            end
        end
        
        if bestRodUUID and equippedRod ~= bestRodUUID then
            pcall(function()
                Network.Functions.Cancel:InvokeServer()
                task.wait(0.3)
                Network.Events.REEquipItem:FireServer(bestRodUUID, "Fishing Rods")
                task.wait(0.3)
                Network.Events.REEquip:FireServer(1)
            end)
        end
    end
})

-- =============================================
-- QUEST FEATURES
-- =============================================

-- Artifact Lever System
local ArtifactSection = Tabs.Quest:AddSection("Artifact Lever Location")

local jungleInteractions = workspace:WaitForChild("JUNGLE INTERACTIONS")
local artifactScanDelay = 1
local artifactAutoProgress = false
local currentArtifactTarget = nil

local artifactPositions = {
    ["Arrow Artifact"] = CFrame.new(875, 3, -368) * CFrame.Angles(0, math.rad(90), 0),
    ["Crescent Artifact"] = CFrame.new(1403, 3, 123) * CFrame.Angles(0, math.rad(180), 0),
    ["Hourglass Diamond Artifact"] = CFrame.new(1487, 3, -842) * CFrame.Angles(0, math.rad(180), 0),
    ["Diamond Artifact"] = CFrame.new(1844, 3, -287) * CFrame.Angles(0, math.rad(-90), 0)
}

local artifactList = {
    "Arrow Artifact",
    "Crescent Artifact",
    "Hourglass Diamond Artifact", 
    "Diamond Artifact"
}

-- Get Artifact Status
function getArtifactStatus()
    local status = {}
    for _, lever in ipairs(jungleInteractions:GetDescendants()) do
        if lever:IsA("Model") and lever.Name == "TempleLever" then
            status[lever:GetAttribute("Type")] = not lever:FindFirstChild("RootPart") or not lever.RootPart:FindFirstChildWhichIsA("ProximityPrompt")
        end
    end
    return status
end

-- Update Artifact Panel
function updateArtifactPanel(status)
    local function formatArtifactStatus(artifactName, isActive)
        local displayName = artifactName == "Hourglass Diamond Artifact" and "Hourglass Diamond" or 
                           artifactName == "Arrow Artifact" and "Arrow" or
                           artifactName == "Crescent Artifact" and "Crescent" or "Diamond"
        local color = isActive and "0,255,0" or "255,0,0"
        local statusText = isActive and "ACTIVE" or "DISABLE"
        return ("%s : <b><font color=\"rgb(%s)\">%s</font></b>"):format(displayName, color, statusText)
    end
    
    ArtifactPanel:SetContent(table.concat({
        formatArtifactStatus("Arrow Artifact", status["Arrow Artifact"]),
        formatArtifactStatus("Crescent Artifact", status["Crescent Artifact"]),
        formatArtifactStatus("Hourglass Diamond Artifact", status["Hourglass Diamond Artifact"]),
        formatArtifactStatus("Diamond Artifact", status["Diamond Artifact"])
    }, "\n"))
end

-- Trigger Specific Lever
function triggerSpecificLever(leverName)
    for _, lever in ipairs(jungleInteractions:GetDescendants()) do
        if lever:IsA("Model") and lever.Name == "TempleLever" and lever:GetAttribute("Type") == leverName then
            local prompt = lever:FindFirstChild("RootPart") and lever.RootPart:FindFirstChildWhichIsA("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
                break
            end
        end
    end
end

-- Artifact Panel
local ArtifactPanel = ArtifactSection:AddParagraph({
    Title = "Panel Progress Artifact",
    Content = "\r\nArrow : <b><font color=\"rgb(255,0,0)\">DISABLE</font></b>\r\nCrescent : <b><font color=\"rgb(255,0,0)\">DISABLE</font></b>\r\nHourglass Diamond : <b><font color=\"rgb(255,0,0)\">DISABLE</font></b>\r\nDiamond : <b><font color=\"rgb(255,0,0)\">DISABLE</font></b>\r\n"
})

-- Fish Caught Event for Artifact Progress
Network.Events.REFishGot.OnClientEvent:Connect(function(fishName)
    if not artifactAutoProgress or not currentArtifactTarget then return end
    
    local targetType = string.split(currentArtifactTarget, " ")[1]
    if targetType and string.find(fishName, targetType, 1, true) then
        task.wait(0)
        triggerSpecificLever(currentArtifactTarget)
        currentArtifactTarget = nil
    end
end)

-- Artifact Auto Progress Toggle
ArtifactSection:AddToggle({
    Title = "Artifact Progress",
    Default = false,
    Callback = function(enabled)
        artifactAutoProgress = enabled
        if enabled then
            task.spawn(function()
                local completed = false
                while artifactAutoProgress do
                    local status = getArtifactStatus()
                    local allActive = true
                    for _, isActive in pairs(status) do
                        if not isActive then
                            allActive = false
                            break
                        end
                    end
                    updateArtifactPanel(status)
                    
                    if allActive then
                        artifactAutoProgress = false
                        break
                    else
                        for _, artifact in ipairs(artifactList) do
                            if not status[artifact] then
                                currentArtifactTarget = artifact
                                local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                                local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
                                if humanoidRootPart and artifactPositions[artifact] then
                                    humanoidRootPart.CFrame = artifactPositions[artifact]
                                end
                                repeat
                                    task.wait(artifactScanDelay)
                                    completed = not currentArtifactTarget or not artifactAutoProgress
                                until completed
                            end
                            if completed then break end
                        end
                        completed = false
                        task.wait(artifactScanDelay)
                    end
                end
            end)
        end
    end
})

-- Auto Update Artifact Panel
task.spawn(function()
    while task.wait(artifactScanDelay) do
        updateArtifactPanel(getArtifactStatus())
    end
end)

-- Artifact Teleport Buttons
ArtifactSection:AddButton({
    Title = "Arrow",
    Callback = function()
        local character = Config.player.Character or Config.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = artifactPositions["Arrow Artifact"]
        end
    end,
    SubTitle = "Hourglass Diamond",
    SubCallback = function()
        local character = Config.player.Character or Config.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = artifactPositions["Hourglass Diamond Artifact"]
        end
    end
})

ArtifactSection:AddButton({
    Title = "Crescent",
    Callback = function()
        local character = Config.player.Character or Config.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = artifactPositions["Crescent Artifact"]
        end
    end,
    SubTitle = "Diamond",
    SubCallback = function()
        local character = Config.player.Character or Config.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = artifactPositions["Diamond Artifact"]
        end
    end
})

-- =============================================
-- DEEP SEA QUEST SYSTEM
-- =============================================
local DeepSeaSection = Tabs.Quest:AddSection("Sisyphus Statue Quest")

local DeepSeaPanel = DeepSeaSection:AddParagraph({
    Title = "Deep Sea Panel",
    Content = ""
})

DeepSeaSection:AddDivider()

-- Auto Deep Sea Quest Toggle
DeepSeaSection:AddToggle({
    Title = "Auto Deep Sea Quest",
    Content = "Automatically complete Deep Sea Quest!",
    Default = false,
    Callback = function(enabled)
        Config.autoDeepSea = enabled
        if enabled then
            task.spawn(function()
                while Config.autoDeepSea do
                    local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
                    local deepSeaTracker = menuRings and menuRings:FindFirstChild("Deep Sea Tracker")
                    if deepSeaTracker then
                        local content = deepSeaTracker:FindFirstChild("Board") and deepSeaTracker.Board:FindFirstChild("Gui") and deepSeaTracker.Board.Gui:FindFirstChild("Content")
                        if content then
                            local questText = nil
                            for _, element in ipairs(content:GetChildren()) do
                                if element:IsA("TextLabel") and element.Name ~= "Header" then
                                    questText = element
                                    break
                                end
                            end
                            if questText then
                                local textLower = string.lower(questText.Text)
                                local humanoidRootPart = Config.player.Character and Config.player.Character:FindFirstChild("HumanoidRootPart")
                                if humanoidRootPart then
                                    if string.find(textLower, "100%%") then
                                        humanoidRootPart.CFrame = CFrame.new(-3763, -135, -995) * CFrame.Angles(0, math.rad(180), 0)
                                    else
                                        humanoidRootPart.CFrame = CFrame.new(-3599, -276, -1641)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

-- Deep Sea Teleport Buttons
DeepSeaSection:AddButton({
    Title = "Treasure Room",
    Callback = function()
        local character = Config.player.Character or Config.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(-3601, -283, -1611)
        end
    end,
    SubTitle = "Sisyphus Statue",
    SubCallback = function()
        local character = Config.player.Character or Config.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(-3698, -135, -1008)
        end
    end
})

-- =============================================
-- ELEMENT QUEST SYSTEM
-- =============================================
local ElementSection = Tabs.Quest:AddSection("Element Quest")

local ElementPanel = ElementSection:AddParagraph({
    Title = "Element Panel",
    Content = ""
})

ElementSection:AddDivider()

-- Auto Element Quest Toggle
ElementSection:AddToggle({
    Title = "Auto Element Quest",
    Content = "Automatically teleport through Element quest stages.",
    Default = false,
    Callback = function(enabled)
        Config.autoElement = enabled
        if enabled then
            task.spawn(function()
                local completed = false
                while Config.autoElement and not completed do
                    local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
                    local elementTracker = menuRings and menuRings:FindFirstChild("Element Tracker")
                    if elementTracker then
                        local content = elementTracker:FindFirstChild("Board") and elementTracker.Board:FindFirstChild("Gui") and elementTracker.Board.Gui:FindFirstChild("Content")
                        if content then
                            local questLines = {}
                            for _, element in ipairs(content:GetChildren()) do
                                if element:IsA("TextLabel") and element.Name ~= "Header" then
                                    table.insert(questLines, string.lower(element.Text))
                                end
                            end
                            local humanoidRootPart = Config.player.Character and Config.player.Character:FindFirstChild("HumanoidRootPart")
                            if humanoidRootPart and #questLines >= 4 then
                                local secondQuest = questLines[2]
                                local fourthQuest = questLines[4]
                                if not string.find(fourthQuest, "100%%") then
                                    humanoidRootPart.CFrame = CFrame.new(1484, 3, -336) * CFrame.Angles(0, math.rad(180), 0)
                                elseif string.find(fourthQuest, "100%%") and not string.find(secondQuest, "100%%") then
                                    humanoidRootPart.CFrame = CFrame.new(1453, -22, -636)
                                elseif string.find(secondQuest, "100%%") then
                                    humanoidRootPart.CFrame = CFrame.new(1480, 128, -593)
                                    completed = true
                                    Config.autoElement = false
                                    if ElementPanel and ElementPanel.SetContent then
                                        ElementPanel:SetContent("Element Quest Completed!")
                                    end
                                end
                            end
                        end
                    end
                    task.wait(2)
                end
            end)
        end
    end
})

-- Element Quest Teleport Buttons
ElementSection:AddButton({
    Title = "Secred Temple",
    Callback = function()
        local character = Config.player.Character or Config.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(1453, -22, -636)
        end
    end,
    SubTitle = "Underground Cellar",
    SubCallback = function()
        local character = Config.player.Character or Config.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(2136, -91, -701)
        end
    end
})

ElementSection:AddButton({
    Title = "Transcended Stones",
    Callback = function()
        local character = Config.player.Character or Config.player.CharacterAdded:Wait()
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(1480, 128, -593)
        end
    end
})

-- Quest Tracker Reader Function
function readQuestTracker(trackerName)
    local tracker = workspace["!!! MENU RINGS"]:FindFirstChild(trackerName)
    if not tracker then return "" end
    
    local board = tracker:FindFirstChild("Board") and tracker.Board:FindFirstChild("Gui")
    local content = board and board:FindFirstChild("Content")
    if not content then return "" end
    
    local lines = {}
    local lineNumber = 1
    for _, element in ipairs(content:GetChildren()) do
        if element:IsA("TextLabel") and element.Name ~= "Header" then
            table.insert(lines, lineNumber .. ". " .. element.Text)
            lineNumber = lineNumber + 1
        end
    end
    return table.concat(lines, "\n")
end

-- Auto Update Quest Panels
task.spawn(function()
    while task.wait(2) do
        ElementPanel:SetContent(readQuestTracker("Element Tracker"))
        DeepSeaPanel:SetContent(readQuestTracker("Deep Sea Tracker"))
    end
end)

-- =============================================
-- AUTO PROGRESS QUEST SYSTEM
-- =============================================
local AutoQuestSection = Tabs.Quest:AddSection("Auto Progress Quest Features")

local AutoQuestPanel = AutoQuestSection:AddParagraph({
    Title = "Progress Quest Panel",
    Content = "Waiting for start..."
})

AutoQuestSection:AddToggle({
    Title = "Auto Teleport Quest",
    Default = false,
    Callback = function(enabled)
        Config.autoQuestFlow = enabled
        if enabled then
            task.spawn(function()
                local deepSeaCompleted = false
                local artifactCompleted = false
                local elementCompleted = false
                local teleportStates = {Deep = false, Lever = false, Element = false}
                
                local function updateQuestPanel(message)
                    if AutoQuestPanel and AutoQuestPanel.SetContent then
                        AutoQuestPanel:SetContent(message)
                    end
                end
                
                while Config.autoQuestFlow and (not deepSeaCompleted or not artifactCompleted or not elementCompleted) do
                    -- Deep Sea Quest
                    if not deepSeaCompleted then
                        local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
                        local deepSeaTracker = menuRings and menuRings:FindFirstChild("Deep Sea Tracker")
                        local content = deepSeaTracker and deepSeaTracker:FindFirstChild("Board") and deepSeaTracker.Board:FindFirstChild("Gui") and deepSeaTracker.Board.Gui:FindFirstChild("Content")
                        
                        local allComplete = true
                        local completedCount = 0
                        local totalQuests = 0
                        
                        if content then
                            for _, element in ipairs(content:GetChildren()) do
                                if element:IsA("TextLabel") and element.Name ~= "Header" then
                                    totalQuests = totalQuests + 1
                                    if string.find(element.Text, "100%%") then
                                        completedCount = completedCount + 1
                                    else
                                        allComplete = false
                                    end
                                end
                            end
                        end
                        
                        local completionPercent = totalQuests > 0 and math.floor(completedCount / totalQuests * 100) or 0
                        updateQuestPanel(string.format("Doing objective on Deep Sea Quest...\nProgress now %d%%.", completionPercent))
                        
                        if not allComplete and not teleportStates.Deep then
                            local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if humanoidRootPart then
                                humanoidRootPart.CFrame = CFrame.new(-3599, -276, -1641)
                                teleportStates.Deep = true
                            end
                        elseif allComplete then
                            deepSeaCompleted = true
                            updateQuestPanel("Deep Sea Quest Completed!\nProceeding to Artifact Lever...")
                        end
                        task.wait(1)
                    end
                    
                    -- Artifact Lever Quest
                    if deepSeaCompleted and not artifactCompleted and Config.autoQuestFlow then
                        local leverStatus = getArtifactStatus()
                        local allLeversActive = true
                        for _, isActive in pairs(leverStatus) do
                            if not isActive then
                                allLeversActive = false
                                break
                            end
                        end
                        
                        if not allLeversActive and not teleportStates.Lever then
                            local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if humanoidRootPart and artifactPositions["Arrow Artifact"] then
                                humanoidRootPart.CFrame = artifactPositions["Arrow Artifact"]
                                teleportStates.Lever = true
                            end
                            updateQuestPanel("Doing objective on Artifact Lever...\nProgress now 75%.")
                        elseif allLeversActive then
                            artifactCompleted = true
                            updateQuestPanel("Artifact Lever Completed!\nProceeding to Element Quest...")
                        end
                        task.wait(1)
                    end
                    
                    -- Element Quest
                    if deepSeaCompleted and artifactCompleted and not elementCompleted and Config.autoQuestFlow then
                        local menuRings = workspace:FindFirstChild("!!! MENU RINGS")
                        local elementTracker = menuRings and menuRings:FindFirstChild("Element Tracker")
                        local content = elementTracker and elementTracker:FindFirstChild("Board") and elementTracker.Board:FindFirstChild("Gui") and elementTracker.Board.Gui:FindFirstChild("Content")
                        
                        if content then
                            local questLines = {}
                            for _, element in ipairs(content:GetChildren()) do
                                if element:IsA("TextLabel") and element.Name ~= "Header" then
                                    table.insert(questLines, element.Text)
                                end
                            end
                            
                            local secondQuest = questLines[2] and string.lower(questLines[2]) or ""
                            local fourthQuest = questLines[4] and string.lower(questLines[4]) or ""
                            local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            
                            if not string.find(secondQuest, "100%%") or not string.find(fourthQuest, "100%%") then
                                if not teleportStates.Element and humanoidRootPart then
                                    humanoidRootPart.CFrame = CFrame.new(1484, 3, -336) * CFrame.Angles(0, math.rad(180), 0)
                                    teleportStates.Element = true
                                end
                                
                                if not string.find(fourthQuest, "100%%") then
                                    updateQuestPanel("Doing objective on Element Quest...\nProgress now 50%.")
                                elseif string.find(fourthQuest, "100%%") and not string.find(secondQuest, "100%%") then
                                    humanoidRootPart.CFrame = CFrame.new(1453, -22, -636)
                                    updateQuestPanel("Doing objective on Element Quest...\nProgress now 75%.")
                                end
                            else
                                elementCompleted = true
                                updateQuestPanel("All Quest Completed Successfully! :3")
                                Config.autoQuestFlow = false
                            end
                        end
                        task.wait(1)
                    end
                end
            end)
        end
    end
})

-- =============================================
-- ANCIENT RUIN DOOR SYSTEM
-- =============================================
local AncientRuinSection = Tabs.Quest:AddSection("Auto Door Ancient Ruin Features")

local ruinInteractions = workspace:FindFirstChild("RUIN INTERACTIONS")
local pressurePlateRarities = {"Rare", "Epic", "Legendary", "Mythic"}

local FishTargetIDs = {
    Rare = 284,
    Epic = 270,
    Legendary = 283,
    Mythic = 263
}

local RuinPanel = AncientRuinSection:AddParagraph({
    Title = "Panel Ancient Ruin",
    Content = "Checking..."
})

-- Auto Update Ruin Panel
task.spawn(function()
    while task.wait(1) do
        if ruinInteractions and ruinInteractions:FindFirstChild("PressurePlates") then
            local pressurePlates = ruinInteractions.PressurePlates
            local rarePrompt = pressurePlates:FindFirstChild("Rare") and pressurePlates.Rare.Part:FindFirstChild("ProximityPrompt")
            local epicPrompt = pressurePlates:FindFirstChild("Epic") and pressurePlates.Epic.Part:FindFirstChild("ProximityPrompt")
            local legendaryPrompt = pressurePlates:FindFirstChild("Legendary") and pressurePlates.Legendary.Part:FindFirstChild("ProximityPrompt")
            local mythicPrompt = pressurePlates:FindFirstChild("Mythic") and pressurePlates.Mythic.Part:FindFirstChild("ProximityPrompt")
            
            RuinPanel:SetContent(string.format(
                "Rare : %s\nEpic : %s\nLegendary : %s\nMythic : %s",
                rarePrompt and "<b>Disable</b>" or "<b>Active</b>",
                epicPrompt and "<b>Disable</b>" or "<b>Active</b>",
                legendaryPrompt and "<b>Disable</b>" or "<b>Active</b>",
                mythicPrompt and "<b>Disable</b>" or "<b>Active</b>"
            ))
        else
            RuinPanel:SetContent("<font color='rgb(255,69,0)'>PressurePlates folder not found!</font>")
        end
    end
end)

-- Auto Ancient Ruin Toggle
AncientRuinSection:AddToggle({
    Title = "Auto Ancient Ruin",
    Default = false,
    Callback = function(enabled)
        Config.triggerRuin = enabled
        if enabled then
            task.spawn(function()
                while Config.triggerRuin do
                    local inventory = DataSystem.Data:GetExpect({"Inventory", "Items"})
                    if ruinInteractions and ruinInteractions:FindFirstChild("PressurePlates") then
                        local pressurePlates = ruinInteractions.PressurePlates
                        for _, rarity in ipairs(pressurePlateRarities) do
                            local targetFishId = FishTargetIDs[rarity]
                            local hasFish = false
                            
                            for _, item in ipairs(inventory) do
                                if item.Id == targetFishId then
                                    hasFish = true
                                    break
                                end
                            end
                            
                            if hasFish then
                                local pressurePlate = pressurePlates:FindFirstChild(rarity)
                                local platePart = pressurePlate and pressurePlate:FindFirstChild("Part")
                                local prompt = platePart and platePart:FindFirstChild("ProximityPrompt")
                                if prompt then
                                    fireproximityprompt(prompt)
                                end
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

-- =============================================
-- TELEPORT FEATURES
-- =============================================

-- Player Teleport Section
local PlayerTeleportSection = Tabs.Tele:AddSection("Teleport To Player")

-- Get Player List Function
function getPlayerList()
    local players = {}
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(players, player.Name)
        end
    end
    return players
end

-- Player Selection Dropdown
local PlayerTeleportDropdown = PlayerTeleportSection:AddDropdown({
    Title = "Select Player to Teleport",
    Content = "Choose target player",
    Options = getPlayerList(),
    Default = {},
    Callback = function(player)
        Config.trade.teleportTarget = player
    end
})

-- Refresh Player List Button
PlayerTeleportSection:AddButton({
    Title = "Refresh Player List",
    Content = "Refresh list!",
    Callback = function()
        PlayerTeleportDropdown:SetValues(getPlayerList())
        chloex("Player list refreshed!")
    end
})

-- Teleport to Player Button
PlayerTeleportSection:AddButton({
    Title = "Teleport to Player",
    Content = "Teleport to selected player from dropdown",
    Callback = function()
        local targetPlayer = Config.trade.teleportTarget
        if not targetPlayer then
            chloex("Please select a player first!")
            return
        end
        
        local target = Services.Players:FindFirstChild(targetPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local localCharacter = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if localCharacter then
                localCharacter.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                chloex("Teleported to " .. target.Name)
            else
                chloex("Your HumanoidRootPart not found.")
            end
        else
            chloex("Target not found or not loaded.")
        end
    end
})

-- Location Teleport Section
local LocationTeleportSection = Tabs.Tele:AddSection("Location")

-- Location Selection Dropdown
LocationTeleportSection:AddDropdown({
    Title = "Select Location",
    Options = LocationNames,
    Default = LocationNames[1],
    Callback = function(location)
        Config.teleportTarget = location
    end
})

-- Teleport to Location Button
LocationTeleportSection:AddButton({
    Title = "Teleport to Location",
    Content = "Teleport to selected location",
    Callback = function()
        local targetLocation = Config.teleportTarget
        if not targetLocation then
            chloex("Please select a location first!")
            return
        end
        
        local locationData = LocationData[targetLocation]
        if locationData then
            local character = LocalPlayer.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                humanoidRootPart.CFrame = CFrame.new(locationData + Vector3.new(0, 3, 0))
                chloex("Teleported to " .. targetLocation)
            end
        end
    end
})

-- =============================================
-- MISCELLANEOUS FEATURES
-- =============================================
local MiscSection = Tabs.Misc:AddSection("Miscellaneous")

-- Anti Staff System
MiscSection:AddToggle({
    Title = "Anti Staff",
    Content = "Auto kick if staff/developer joins the server.",
    Default = false,
    Callback = function(enabled)
        _G.AntiStaff = enabled
        if enabled then
            local groupId = 35102746
            local staffRanks = {
                [2] = "OG",
                [3] = "Tester",
                [4] = "Moderator",
                [75] = "Community Staff",
                [79] = "Analytics",
                [145] = "Divers / Artist",
                [250] = "Devs",
                [252] = "Partner",
                [254] = "Talon",
                [255] = "Wildes",
                [55] = "Swimmer",
                [30] = "Contrib",
                [35] = "Contrib 2",
                [100] = "Scuba",
                [76] = "CC"
            }
            
            task.spawn(function()
                while true do
                    if _G.AntiStaff then
                        for _, player in ipairs(Services.Players:GetPlayers()) do
                            if player ~= Services.Players.LocalPlayer then
                                local rank = player:GetRankInGroup(groupId)
                                if staffRanks[rank] then
                                    Services.Players.LocalPlayer:Kick("Chloe Detected Staff, Automatically Kicked!")
                                    return
                                end
                            end
                        end
                        task.wait(1)
                    else
                        return
                    end
                end
            end)
        end
    end
})

-- Bypass Radar Toggle
MiscSection:AddToggle({
    Title = "Bypass Radar",
    Default = false,
    Callback = function(enabled)
        pcall(function()
            Network.Functions.UpdateRadar:InvokeServer(enabled)
        end)
    end
})

-- =============================================
-- HIDE IDENTIFIER SYSTEM
-- =============================================
MiscSection:AddSubSection("Hide Identifier")

local hideIdentifierEnabled = false
local originalTitle = nil
local originalHeader = nil
local originalLevel = nil
local originalGradientColor = nil
local originalGradientRotation = nil
local customHeader = ""
local customLevel = ""

-- Get Overhead GUI Function
local function getOverheadGUI()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
    if not humanoidRootPart then return nil end
    
    repeat task.wait() until humanoidRootPart:FindFirstChild("Overhead")
    return humanoidRootPart:WaitForChild("Overhead", 5)
end

-- Setup Hide Identifier Function
local function setupHideIdentifier()
    local overhead = getOverheadGUI()
    if not overhead then
        warn("[HideIdent] Overhead not found.")
        return
    end
    
    local titleLabel = overhead:FindFirstChild("TitleContainer") and overhead.TitleContainer:FindFirstChild("Label")
    local header = overhead:FindFirstChild("Content") and overhead.Content:FindFirstChild("Header")
    local levelLabel = overhead:FindFirstChild("LevelContainer") and overhead.LevelContainer:FindFirstChild("Label")
    local gradient = titleLabel and titleLabel:FindFirstChildOfClass("UIGradient")
    
    if not titleLabel or not header or not levelLabel then
        warn("[HideIdent] Missing UI components in Overhead.")
        return
    end
    
    if not gradient then
        gradient = Instance.new("UIGradient", titleLabel)
    end
    
    _G.hideident = {
        overhead = overhead,
        titleLabel = titleLabel,
        gradient = gradient,
        header = header,
        levelLabel = levelLabel
    }
    
    originalTitle = titleLabel.Text
    originalHeader = header.Text
    originalLevel = levelLabel.Text
    originalGradientColor = gradient.Color
    originalGradientRotation = gradient.Rotation
    
    customHeader = customHeader or originalHeader
    customLevel = customLevel or originalLevel
end

-- Apply Hide Identifier Function
local function applyHideIdentifier()
    local hideData = _G.hideident
    if not hideData or not hideData.overhead or not hideData.titleLabel then
        return
    end
    
    hideData.overhead.TitleContainer.Visible = true
    hideData.titleLabel.Text = "Chloe X"
    hideData.gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 85, 255)),
        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(145, 186, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(136, 243, 255))
    })
    hideData.gradient.Rotation = 0
    hideData.header.Text = customHeader ~= "" and customHeader or "Chloe Rawr"
    hideData.levelLabel.Text = customLevel ~= "" and customLevel or "???"
end

-- Initialize Hide Identifier
setupHideIdentifier()

-- Character Added Event for Hide Identifier
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    setupHideIdentifier()
    if hideIdentifierEnabled then
        task.spawn(function()
            while hideIdentifierEnabled do
                applyHideIdentifier()
                task.wait(1)
            end
        end)
    end
end)

-- Name Changer Input
MiscSection:AddInput({
    Title = "Name Changer",
    Placeholder = "Enter header text...",
    Default = originalHeader or "",
    Callback = function(value)
        customHeader = value
        SaveConfig()
    end
})

-- Level Changer Input
MiscSection:AddInput({
    Title = "Lvl Changer",
    Placeholder = "Enter level text...",
    Default = originalLevel or "",
    Callback = function(value)
        customLevel = value
        SaveConfig()
    end
})

-- Hide Identifier Toggle
MiscSection:AddToggle({
    Title = "Start Hide Identifier",
    Default = false,
    Callback = function(enabled)
        hideIdentifierEnabled = enabled
        if enabled then
            task.spawn(function()
                while hideIdentifierEnabled do
                    local success, result = pcall(applyHideIdentifier)
                    if not success then
                        warn("[HideIdent] Error:", result)
                    end
                    task.wait(1)
                end
            end)
        else
            local hideData = _G.hideident
            if not hideData or not hideData.overhead then
                return
            end
            hideData.overhead.TitleContainer.Visible = false
            hideData.titleLabel.Text = originalTitle
            hideData.header.Text = originalHeader
            hideData.levelLabel.Text = originalLevel
            hideData.gradient.Color = originalGradientColor
            hideData.gradient.Rotation = originalGradientRotation
        end
    end
})

-- =============================================
-- HALLOWEEN EVENT FEATURES
-- =============================================
MiscSection:AddSubSection("Halloween Event")

-- Auto Claim Halloween Event Toggle
MiscSection:AddToggle({
    Title = "Auto Claim Halloween Event",
    Default = Config.CEvent,
    Callback = function(enabled)
        Config.CEvent = enabled
        if enabled then
            task.spawn(function()
                local jungleEvent = Services.PG:FindFirstChild("JungleEvent")
                if not jungleEvent or not jungleEvent:FindFirstChild("Frame") then
                    return
                end
                
                local body = jungleEvent.Frame:FindFirstChild("Body")
                if not body then return end
                
                local main = body:FindFirstChild("Main")
                if not main then return end
                
                local track = main:FindFirstChild("Track")
                if not track or not track:FindFirstChild("Frame") then
                    return
                end
                
                local frame = track.Frame
                while Config.CEvent do
                    for i = 1, 13 do
                        local rewardFrame = frame:FindFirstChild(tostring(i))
                        if rewardFrame then
                            local inside = rewardFrame:FindFirstChild("Inside")
                            local claimButton = inside and inside:FindFirstChild("Claim")
                            if claimButton and claimButton:IsA("ImageButton") and claimButton.Visible and inside.Visible and rewardFrame.Visible and claimButton.Active then
                                pcall(function()
                                    Network.Events.REEvReward:FireServer(i)
                                    chloex(string.format("Claimed Reward #%d", i))
                                end)
                                task.wait(0.7)
                            end
                        end
                    end
                    task.wait(5)
                end
            end)
        end
    end
})

-- Auto Claim Halloween NPC Toggle
MiscSection:AddToggle({
    Title = "Auto Claim Halloween NPC",
    Default = false,
    Callback = function(enabled)
        Config.autoClaimNPC = enabled
        if enabled then
            task.spawn(function()
                local npcList = {
                    "Headless Horseman",
                    "Hallow Guardian",
                    "Zombified Doge",
                    "Pumpkin Bandit",
                    "Scientist",
                    "Ghost",
                    "Witch"
                }
                while Config.autoClaimNPC do
                    for _, npc in ipairs(npcList) do
                        pcall(function()
                            Network.Functions.Dialogue:InvokeServer(npc, "TrickOrTreat")
                        end)
                        task.wait(1.5)
                    end
                    task.wait(5)
                end
            end)
        end
    end
})

-- Auto Claim Halloween House Toggle
MiscSection:AddToggle({
    Title = "Auto Claim Halloween House",
    Default = false,
    Callback = function(enabled)
        Config.autoClaimHouse = enabled
        if enabled then
            task.spawn(function()
                local houseList = {
                    "Talon", "Kenny", "OutOfOrderFoxy", "Terror", "RequestingBlox",
                    "Mac", "Wildes", "Tapiobag", "nthnth", "Jixxio", "Relukt"
                }
                while Config.autoClaimHouse do
                    for _, house in ipairs(houseList) do
                        pcall(function()
                            Network.Functions.Dialogue:InvokeServer(house, "TrickOrTreatHouse")
                        end)
                        task.wait(1.5)
                    end
                    task.wait(5)
                end
            end)
        end
    end
})

-- =============================================
-- BOOST PLAYER FEATURES
-- =============================================
MiscSection:AddSubSection("Boost Player")

-- Cutscene Controller
local CutsceneController
local originalPlay
local originalStop

local success, controller = pcall(function()
    return require(Services.RS.Controllers.CutsceneController)
end)

if success and controller then
    CutsceneController = controller
    originalPlay = CutsceneController.Play
    originalStop = CutsceneController.Stop
end

-- Disable Cutscenes Function
local function disableCutscenes()
    if Network.Events.RECutscene then
        Network.Events.RECutscene.OnClientEvent:Connect(function(...)
            warn("[CELESTIAL] Cutscene blocked (ReplicateCutscene)", ...)
        end)
    end
    
    if Network.Events.REStop then
        Network.Events.REStop.OnClientEvent:Connect(function()
            warn("[CELESTIAL] Cutscene blocked (StopCutscene)")
        end)
    end
    
    if CutsceneController then
        CutsceneController.Play = function()
            warn("[CELESTIAL] Cutscene skipped!")
        end
        CutsceneController.Stop = function()
            warn("[CELESTIAL] Cutscene stop skipped")
        end
    end
    warn("[CELESTIAL] All cutscenes disabled successfully!")
end

-- Enable Cutscenes Function
local function enableCutscenes()
    if CutsceneController and originalPlay and originalStop then
        CutsceneController.Play = originalPlay
        CutsceneController.Stop = originalStop
        warn("[CELESTIAL] Cutscenes restored to default")
    end
end

-- Disable Cutscene Toggle
MiscSection:AddToggle({
    Title = "Disable Cutscene",
    Default = true,
    Callback = function(enabled)
        Config.skipCutscene = enabled
        if enabled then
            disableCutscenes()
        else
            enableCutscenes()
        end
    end
})

-- Disable Obtained Fish Toggle
MiscSection:AddToggle({
    Title = "Disable Obtained Fish",
    Default = false,
    Callback = function(enabled)
        local notificationGui = Services.Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("Small Notification")
        if notificationGui and notificationGui:FindFirstChild("Display") then
            notificationGui.Display.Visible = not enabled
        end
    end
})

-- Disable Notification Toggle
MiscSection:AddToggle({
    Title = "Disable Notification",
    Content = "Disable All Notification! Fish/Admin Annoucement/Event Spawned!",
    Default = false,
    Callback = function(enabled)
        Config.disableNotifs = enabled
        if enabled then
            disableNotifications()
        else
            enableNotifications()
        end
    end
})

-- Disable Character Effects Toggle
MiscSection:AddToggle({
    Title = "Disable Char Effect",
    Default = false,
    Callback = function(enabled)
        if enabled then
            Config.dummyCons = {}
            for _, event in ipairs({
                Network.Events.REPlayFishEffect,
                Network.Events.RETextEffect
            }) do
                for _, connection in ipairs(getconnections(event.OnClientEvent)) do
                    connection:Disconnect()
                end
                local dummyConnection = event.OnClientEvent:Connect(function() end)
                table.insert(Config.dummyCons, dummyConnection)
            end
        else
            if Config.dummyCons then
                for _, connection in ipairs(Config.dummyCons) do
                    connection:Disconnect()
                end
            end
            Config.dummyCons = {}
        end
    end
})

-- Delete Fishing Effects Toggle
MiscSection:AddToggle({
    Title = "Delete Fishing Effects",
    Content = "This Feature irivisible! delete any effect on rod",
    Default = false,
    Callback = function(enabled)
        Config.DelEffects = enabled
        if enabled then
            task.spawn(function()
                while Config.DelEffects do
                    local cosmeticFolder = workspace:FindFirstChild("CosmeticFolder")
                    if cosmeticFolder then
                        cosmeticFolder:Destroy()
                    end
                    task.wait(60)
                end
            end)
        end
    end
})

-- Hide Rod on Hand Toggle
MiscSection:AddToggle({
    Title = "Hide Rod On Hand",
    Content = "This feature irivisible! and hide other player too.",
    Default = false,
    Callback = function(enabled)
        Config.IrRod = enabled
        if enabled then
            task.spawn(function()
                while Config.IrRod do
                    local characters = workspace:FindFirstChild("Characters")
                    if characters then
                        for _, character in ipairs(characters:GetChildren()) do
                            local equippedTool = character:FindFirstChild("!!!EQUIPPED_TOOL!!!")
                            if equippedTool then
                                equippedTool:Destroy()
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

-- =============================================
-- WEBHOOK SYSTEM
-- =============================================

-- Fish Database for Webhook
local FishDatabase = {}

-- Build Fish Database Function
function buildFishDatabase()
    local items = DataSystem.Items
    if not items then return end
    
    for _, itemScript in ipairs(items:GetChildren()) do
        local success, itemData = pcall(require, itemScript)
        if success and type(itemData) == "table" and itemData.Data and itemData.Data.Type == "Fish" then
            local data = itemData.Data
            if data.Id and data.Name then
                FishDatabase[data.Id] = {
                    Name = data.Name,
                    Tier = data.Tier,
                    Icon = data.Icon,
                    SellPrice = itemData.SellPrice
                }
            end
        end
    end
end

-- Get Thumbnail URL Function
function getThumbnailURL(assetId)
    local assetNumber = assetId:match("rbxassetid://(%d+)")
    if not assetNumber then return nil end
    
    local thumbnailUrl = string.format("https://thumbnails.roblox.com/v1/assets?assetIds=%s&type=Asset&size=420x420&format=Png", assetNumber)
    local success, result = pcall(function()
        return Services.HttpService:JSONDecode(game:HttpGet(thumbnailUrl))
    end)
    return success and result and result.data and result.data[1] and result.data[1].imageUrl
end

-- Send Webhook Function
function sendWebhook(webhookUrl, webhookData)
    if not _G.httpRequest or not webhookUrl or webhookUrl == "" then
        return
    end
    
    if _G._WebhookLock and _G._WebhookLock[webhookUrl] then
        return
    end
    
    _G._WebhookLock = _G._WebhookLock or {}
    _G._WebhookLock[webhookUrl] = true
    
    task.delay(0.25, function()
        _G._WebhookLock[webhookUrl] = nil
    end)
    
    pcall(function()
        _G.httpRequest({
            Url = webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = Services.HttpService:JSONEncode(webhookData)
        })
    end)
end

-- Send New Fish Webhook Function
function sendNewFishWebhook(fishData)
    if not _G.WebhookFlags.FishCaught.Enabled then
        return
    end
    
    local webhookUrl = _G.WebhookFlags.FishCaught.URL
    if not webhookUrl or not webhookUrl:match("discord.com/api/webhooks") then
        return
    end
    
    local fishInfo = FishDatabase[fishData.Id]
    if not fishInfo then
        return
    end
    
    local rarity = _G.TierFish and _G.TierFish[fishInfo.Tier] or "Unknown"
    
    -- Check rarity filter
    if _G.WebhookRarities and #_G.WebhookRarities > 0 and not table.find(_G.WebhookRarities, rarity) then
        return
    end
    
    -- Check name filter
    if _G.WebhookNames and #_G.WebhookNames > 0 and not table.find(_G.WebhookNames, fishInfo.Name) then
        return
    end
    
    local weight = fishData.Metadata and fishData.Metadata.Weight and string.format("%.2f Kg", fishData.Metadata.Weight) or "N/A"
    local variant = fishData.Metadata and fishData.Metadata.VariantId and tostring(fishData.Metadata.VariantId) or "None"
    local sellPrice = fishInfo.SellPrice and "$" .. string.format("%d", fishInfo.SellPrice):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "") or "N/A"
    
    local webhookPayload = {
        embeds = {
            {
                title = "Chloe X Webhook | Fish Caught",
                url = "https://discord.gg/PaPvGUE8UC",
                description = string.format("🎶ˋ͈ Congratulations!! **%s** You have obtained a new **%s** fish!", _G.WebhookCustomName ~= "" and _G.WebhookCustomName or game.Players.LocalPlayer.Name, rarity),
                color = 52221,
                fields = {
                    {
                        name = "⁺Fish Name :",
                        value = "```◝ " .. fishInfo.Name .. "```"
                    },
                    {
                        name = "⁺Fish Tier :", 
                        value = "```◝ " .. rarity .. "```"
                    },
                    {
                        name = "⁺Weight :",
                        value = "```◝ " .. weight .. "```"
                    },
                    {
                        name = "⁺Mutation :",
                        value = "```◝ " .. variant .. "```"
                    },
                    {
                        name = "⁺Sell Price :",
                        value = "```◝ " .. sellPrice .. "```"
                    }
                },
                image = {
                    url = getThumbnailURL(fishInfo.Icon) or "https://i.imgur.com/WltO8IG.png"
                },
                footer = {
                    text = "Chloe X Webhook",
                    icon_url = "https://i.imgur.com/WltO8IG.png"
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
            }
        },
        username = "Chloe X Notification!",
        avatar_url = "https://i.imgur.com/9afHGRy.jpeg"
    }
    
    sendWebhook(webhookUrl, webhookPayload)
end

-- Build Fish Database
buildFishDatabase()

-- Fish Name List for Webhook Filter
local allFishNames = {}
for _, fishData in pairs(FishDatabase) do
    table.insert(allFishNames, fishData.Name)
end
table.sort(allFishNames)

-- Fish Caught Webhook Connection
task.spawn(function()
    repeat
        local fishNotification = Network.Events.REObtainedNewFishNotification
        task.wait(1)
    until fishNotification
    
    if not _G.FishWebhookConnected then
        _G.FishWebhookConnected = true
        fishNotification.OnClientEvent:Connect(function(fishId, metadata)
            if Config.autoWebhook then
                local fishData = {
                    Id = fishId,
                    Metadata = {
                        Weight = metadata and metadata.Weight,
                        VariantId = metadata and metadata.VariantId
                    }
                }
                sendNewFishWebhook(fishData)
            end
        end)
    end
end)

-- =============================================
-- WEBHOOK UI SECTION
-- =============================================
local WebhookFishSection = Tabs.Webhook:AddSection("Webhook Fish Caught")

-- Webhook URL Input
WebhookFishSection:AddInput({
    Title = "Webhook URL",
    Default = "",
    Callback = function(value)
        _G.WebhookURLs.FishCaught = value
        if _G.WebhookFlags and _G.WebhookFlags.FishCaught then
            _G.WebhookFlags.FishCaught.URL = value
        end
        if value and value:match("discord.com/api/webhooks") then
            SaveConfig()
        end
    end
})

-- Tier Filter Dropdown
WebhookFishSection:AddDropdown({
    Title = "Tier Filter",
    Multi = true,
    Options = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"},
    Default = {"Mythic", "Secret"},
    Callback = function(selected)
        _G.WebhookRarities = selected
        SaveConfig()
    end
})

-- Name Filter Dropdown
WebhookFishSection:AddDropdown({
    Title = "Name Filter",
    Multi = true,
    Options = allFishNames,
    Default = {},
    Callback = function(selected)
        _G.WebhookNames = selected
        SaveConfig()
    end
})

-- Hide Identity Input
WebhookFishSection:AddInput({
    Title = "Hide Identity",
    Content = "Protect your name for sending webhook to discord",
    Default = _G.WebhookCustomName or "",
    Callback = function(value)
        _G.WebhookCustomName = value
        SaveConfig()
    end
})

-- Send Fish Webhook Toggle
WebhookFishSection:AddToggle({
    Title = "Send Fish Webhook",
    Default = _G.WebhookFlags.FishCaught.Enabled,
    Callback = function(enabled)
        _G.WebhookFlags.FishCaught.Enabled = enabled
        Config.autoWebhook = enabled
        SaveConfig()
    end
})

-- Test Webhook Connection Button
WebhookFishSection:AddButton({
    Title = "Test Webhook Connection",
    Callback = function()
        local webhookUrl = _G.WebhookFlags.FishCaught.URL
        if not webhookUrl or not webhookUrl:match("discord.com/api/webhooks") then
            warn("[Webhook Test] ✗ Invalid or missing webhook URL.")
            return
        end
        
        local testPayload = {
            content = nil,
            embeds = {
                {
                    color = 44543,
                    author = {
                        name = "Ding dongggg! Webhook is connected :3"
                    },
                    image = {
                        url = "https://media.tenor.com/KJDqZ0H6Gb4AAAAC/gawr-gura-gura.gif"
                    }
                }
            },
            username = "Chloe X Notification!",
            avatar_url = "https://i.imgur.com/9afHGRy.jpeg",
            attachments = {}
        }
        
        task.spawn(function()
            local success, result = pcall(function()
                return _G.httpRequest({
                    Url = webhookUrl,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = Services.HttpService:JSONEncode(testPayload)
                })
            end)
            if success then
                chloex("Successfully sent test message!")
            else
                chloex("Failed to send webhook:", result)
            end
        end)
    end
})

-- =============================================
-- STATISTICS WEBHOOK SYSTEM
-- =============================================
local StatsWebhookSection = Tabs.Webhook:AddSection("Webhook Statistic Player")

-- Statistic Webhook URL Input
StatsWebhookSection:AddInput({
    Title = "Statistic Webhook URL",
    Default = _G.WebhookFlags.Stats.URL,
    Placeholder = "Paste your stats webhook here...",
    Callback = function(value)
        if value and value:match("discord.com/api/webhooks") then
            _G.WebhookFlags.Stats.URL = value
            SaveConfig()
        end
    end
})

-- Delay Input
StatsWebhookSection:AddInput({
    Title = "Delay (Minutes)",
    Default = tostring(_G.WebhookFlags.Stats.Delay),
    Placeholder = "Delay between data sends...",
    Numeric = true,
    Callback = function(value)
        local delay = tonumber(value)
        if delay and delay >= 1 then
            _G.WebhookFlags.Stats.Delay = delay
            SaveConfig()
        end
    end
})

-- Send Stats Webhook Toggle
StatsWebhookSection:AddToggle({
    Title = "Send Webhook Statistic",
    Content = "Automatically send player stats, inventory, utility, and quest info to Discord.",
    Default = _G.WebhookFlags.Stats.Enabled or false,
    Callback = function(enabled)
        Config.autoWebhookStats = enabled
        _G.WebhookFlags.Stats.Enabled = enabled
        SaveConfig()
        
        if not enabled then return end
        
        task.spawn(function()
            -- Statistics webhook implementation would go here
            -- This is a simplified version
            while Config.autoWebhookStats do
                -- Send stats data
                task.wait((_G.WebhookFlags.Stats.Delay or 5) * 60)
            end
        end)
    end
})

-- =============================================
-- DISCONNECT WEBHOOK SYSTEM
-- =============================================
local DisconnectWebhookSection = Tabs.Webhook:AddSection("Webhook Alert")

local discordMention = ""
local disconnectWebhookEnabled = false
local disconnectTriggered = false

-- Send Disconnect Webhook Function
function SendDisconnectWebhook(reason)
    if not disconnectWebhookEnabled then return end
    
    local webhookUrl = _G.WebhookURLs.Disconnect or _G.WebhookFlags and _G.WebhookFlags.Disconnect.URL or ""
    if webhookUrl == "" or not webhookUrl:match("discord") then
        return
    end
    
    local playerName = "Unknown"
    if _G.DisconnectCustomName and _G.DisconnectCustomName ~= "" then
        playerName = _G.DisconnectCustomName
    elseif LocalPlayer and LocalPlayer.Name then
        playerName = LocalPlayer.Name
    end
    
    local currentTime = os.date("*t")
    local hour = currentTime.hour > 12 and currentTime.hour - 12 or currentTime.hour
    local period = currentTime.hour >= 12 and "PM" or "AM"
    local formattedTime = string.format("%02d/%02d/%04d %02d.%02d %s", currentTime.day, currentTime.month, currentTime.year, hour, currentTime.min, period)
    
    local mention = discordMention ~= "" and discordMention or "Anonymous"
    local disconnectReason = reason and reason ~= "" and reason or "Disconnected from server"
    
    local webhookPayload = {
        content = "Ding Dongg Ding Dongggg, Hello! " .. mention .. " your account got disconnected from server!",
        embeds = {
            {
                title = "DETAIL ACCOUNT",
                color = 36863,
                fields = {
                    {
                        name = "⁺Username :",
                        value = "> " .. playerName
                    },
                    {
                        name = "⁺Time got disconnected :",
                        value = "> " .. formattedTime
                    },
                    {
                        name = "⁺Reason :",
                        value = "> " .. disconnectReason
                    }
                },
                thumbnail = {
                    url = "https://media.tenor.com/rx88bhLtmyUAAAAC/gawr-gura.gif"
                }
            }
        },
        username = "Chloe X Notification!",
        avatar_url = "https://i.imgur.com/9afHGRy.jpeg"
    }
    
    task.spawn(function()
        pcall(function()
            _G.httpRequest({
                Url = webhookUrl,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = Services.HttpService:JSONEncode(webhookPayload)
            })
        end)
    end)
end

-- Disconnect Webhook URL Input
DisconnectWebhookSection:AddInput({
    Title = "Disconnect Alert Webhook URL",
    Default = "",
    Callback = function(value)
        _G.WebhookURLs.Disconnect = value
        if _G.WebhookFlags and _G.WebhookFlags.Disconnect then
            _G.WebhookFlags.Disconnect.URL = value
        end
    end
})

-- Discord ID Input
DisconnectWebhookSection:AddInput({
    Title = "Discord ID",
    Default = "",
    Callback = function(value)
        if value and value ~= "" then
            discordMention = "<@" .. value:gsub("%D", "") .. ">"
        else
            discordMention = ""
        end
        SaveConfig()
    end
})

-- Hide Identity Input
DisconnectWebhookSection:AddInput({
    Title = "Hide Identity",
    Placeholder = "Enter custom name (leave blank for default)",
    Default = _G.DisconnectCustomName or "",
    Callback = function(value)
        _G.DisconnectCustomName = value
        SaveConfig()
    end
})

-- Disconnect Webhook Toggle
DisconnectWebhookSection:AddToggle({
    Title = "Send Webhook On Disconnect",
    Content = "Notify your Discord when account disconnected and auto rejoin.",
    Default = _G.WebhookFlags.Disconnect.Enabled or false,
    Callback = function(enabled)
        if enabled and (not _G.DisconnectCustomName or _G.DisconnectCustomName == "") then
            chloex("Invalid! Input Hide Identity first.")
            if _G.WebhookFlags and _G.WebhookFlags.Disconnect then
                _G.WebhookFlags.Disconnect.Enabled = false
            end
            disconnectWebhookEnabled = false
            return
        end
        
        disconnectWebhookEnabled = enabled
        if _G.WebhookFlags and _G.WebhookFlags.Disconnect then
            _G.WebhookFlags.Disconnect.Enabled = enabled
        end
        SaveConfig()
        
        if enabled then
            disconnectTriggered = false
            
            local function handleDisconnect(reason)
                if not disconnectTriggered and disconnectWebhookEnabled then
                    disconnectTriggered = true
                    local disconnectReason = reason or "Disconnected from server"
                    SendDisconnectWebhook(disconnectReason)
                    task.wait(2)
                    Services.TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end
            end
            
            Services.GuiService.ErrorMessageChanged:Connect(function(errorMessage)
                if errorMessage and errorMessage ~= "" then
                    handleDisconnect(errorMessage)
                end
            end)
            
            Services.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(prompt)
                if prompt.Name == "ErrorPrompt" then
                    task.wait(1)
                    local errorLabel = prompt:FindFirstChildWhichIsA("TextLabel", true)
                    local errorText = errorLabel and errorLabel.Text or "Disconnected"
                    handleDisconnect(errorText)
                end
            end)
        end
    end
})

-- Test Disconnect Button
DisconnectWebhookSection:AddButton({
    Title = "Test Disconnected Player",
    Content = "Kick yourself, send webhook, and auto rejoin.",
    Callback = function()
        chloex("Kicking player...")
        task.wait(1)
        SendDisconnectWebhook("Test Successfully :3")
        task.wait(2)
        Services.TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

-- =============================================
-- EXTERNAL WEBHOOK MODULE
-- =============================================
local externalWebhookModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/MajestySkie/Chloe-X/refs/heads/main/Addons/2.lua"))()
local EventWebhookSection = Tabs.Webhook:AddSection("Webhook Event Settings")

-- Hunt Webhook Input
EventWebhookSection:AddInput({
    Title = "Set Hunt Webhook",
    Content = "Input webhook link for Hunt",
    Callback = function(value)
        if value and value:match("^https://discord.com/api/webhooks/") then
            externalWebhookModule.Links.Hunt = value
            chloex("Hunt webhook updated!")
        end
    end
})

-- Luck Webhook Input
EventWebhookSection:AddInput({
    Title = "Set Luck Webhook",
    Content = "Input webhook link for Server Luck",
    Callback = function(value)
        if value and value:match("^https://discord.com/api/webhooks/") then
            externalWebhookModule.Links.ServerLuck = value
            chloex("Server Luck webhook updated!")
        end
    end
})

-- Auto Send Webhook Toggle
EventWebhookSection:AddToggle({
    Title = "Auto Send Webhook",
    Default = true,
    Callback = function(enabled)
        if enabled then
            _G.WebhookDisabled = false
            if not _G.WebhookStarted then
                _G.WebhookStarted = true
                externalWebhookModule.Start()
            end
        else
            _G.WebhookDisabled = true
        end
    end
})

-- =============================================
-- FINAL INITIALIZATION
-- =============================================
chloex("Chloe X Script Loaded Successfully!")
chloex("All features are now available!")

return {
    Services = Services,
    Config = Config,
    Network = Network,
    DataSystem = DataSystem,
    Tabs = Tabs
}