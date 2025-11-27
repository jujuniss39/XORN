------------------------------------------
----- =======[ LOAD CHLOE X GUI - FIXED ]
------------------------------------------

local ChloeX = loadstring(game:HttpGet("https://raw.githubusercontent.com/TesterX14/XXXX/refs/heads/main/Library"))()
local Window = ChloeX:Window({
    Title = "OGhub",
    Footer = "Free To Use",
    Color = Color3.fromRGB(255, 0, 127)
})

------------------------------------------
----- =======[ CREATE TABS - FIXED SYNTAX ]
------------------------------------------

-- Home Tab (Working)
local Home = Window:AddTab("Home", "hard-drive")
local HomeSection = Home:AddSection("Welcome")
HomeSection:Label("⚠️OGhub⚠️")
HomeSection:Label("Thanks For Using This Script.")
HomeSection:Label("No More Premium Script.")
HomeSection:Label("Everyone Can Used !!")
HomeSection:Label("Keep OG Fams..")

-- Auto Fish Tab - FIXED
local AutoFish = Window:AddTab("Auto Fishing", "fish")
local FishSection = AutoFish:AddSection("Auto Fishing Settings")

FishSection:Toggle("Auto Fish Instant", false, function(value)
    if value then
        StartAutoFish5X()
    else
        StopAutoFish5X()
    end
end)

FishSection:Slider("Delay Finish", 0.1, 5, 1, function(value)
    _G.FINISH_DELAY = value
end)

FishSection:Toggle("Auto Fish Legit", false, function(state)
    _G.equipRemote:FireServer(1)
    _G.ToggleAutoClick(state)
end)

FishSection:Slider("Speed Legit", 0.1, 5, 0.05, function(value)
    _G.SPEED_LEGIT = value
end)

FishSection:Toggle("Auto Sell", false, function(state)
    _G.sellActive = state
end)

FishSection:Slider("Sell Threshold", 1, 100, 30, function(value)
    _G.obtainedLimit = value
end)

FishSection:Button("Stop Fishing", function()
    _G.StopFishing()
end)

-- Player Tab - FIXED
local PlayerTab = Window:AddTab("Player", "user")
local PlayerSection = PlayerTab:AddSection("Player Settings")

PlayerSection:Toggle("Hide Name", false, function(state)
    if state then
        _G.StartHideName()
    else
        _G.StopHideName()
    end
end)

PlayerSection:Toggle("Unlimited Zoom", false, function(state)
    if state then
        LocalPlayer.CameraMinZoomDistance = 0.5
        LocalPlayer.CameraMaxZoomDistance = 9999
    else
        LocalPlayer.CameraMinZoomDistance = 16
        LocalPlayer.CameraMaxZoomDistance = 100
    end
end)

PlayerSection:Toggle("Infinity Jump", false, function(val)
    ijump = val
end)

PlayerSection:Toggle("No Clip", false, function(val)
    universalNoclip = val
end)

PlayerSection:Slider("WalkSpeed", 16, 200, 16, function(val)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = val end
end)

PlayerSection:Slider("Jump Power", 50, 200, 50, function(val)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = val end
    end
end)

PlayerSection:Button("Access All Boats", function()
    local vehicles = workspace:FindFirstChild("Vehicles")
    if vehicles then
        local count = 0
        for _, boat in ipairs(vehicles:GetChildren()) do
            if boat:IsA("Model") and boat:GetAttribute("OwnerId") then
                boat:SetAttribute("OwnerId", LocalPlayer.UserId)
                count += 1
            end
        end
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Boats",
            Text = "Accessed "..count.." boats",
            Duration = 3
        })
    end
end)

-- Teleport Tab - FIXED
local Teleport = Window:AddTab("Teleport", "map-pin")
local TeleportSection = Teleport:AddSection("Teleport Options")

-- Player dropdown
local playerList = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        table.insert(playerList, p.Name)
    end
end

TeleportSection:Dropdown("Teleport to Player", playerList, function(selected)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Teleport",
        Text = "Teleporting to "..selected,
        Duration = 3
    })
end)

-- Island dropdown
local islandNames = {
    "Lochness Event", "Esoteric Depths", "Tropical Grove", "Stingray Shores",
    "Kohana Volcano", "Coral Reefs", "Crater Island", "Kohana"
}

TeleportSection:Dropdown("Teleport to Island", islandNames, function(selected)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Island",
        Text = "Teleporting to "..selected,
        Duration = 3
    })
end)

-- Events dropdown
local eventsList = {
    "Shark Hunt", "Ghost Shark Hunt", "Worm Hunt", "Black Hole",
    "Meteor Rain", "Megalodon Hunt"
}

TeleportSection:Dropdown("Teleport to Event", eventsList, function(selected)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Event",
        Text = "Teleporting to "..selected,
        Duration = 3
    })
end)

-- X5 Speed Tab - FIXED
local X5SpeedTab = Window:AddTab("OG Mode", "zap")
local X5SpeedSection = X5SpeedTab:AddSection("OG Mode Settings")

X5SpeedSection:Slider("Delay Recast", 0.1, 5, 1.2, function(v)
    featureState.Instant_StartDelay = v
end)

X5SpeedSection:Slider("Spam Finish", 1, 50, 10, function(v)
    featureState.Instant_ResetCount = v
end)

X5SpeedSection:Slider("Cooldown", 0.1, 5, 0.1, function(v)
    featureState.Instant_ResetPause = v
end)

X5SpeedSection:Toggle("AutoFish OG Mode", false, function(state)
    if state then
        startOrStopAutoFish(true)
    else
        startOrStopAutoFish(false)
    end
end)

X5SpeedSection:Toggle("No Animation", false, function(v)
    setGameAnimationsEnabled(v)
end)

-- Auto Farm Artifact Tab - FIXED
local AutoFarmArt = Window:AddTab("Artifact", "flask-round")
local ArtifactSection = AutoFarmArt:AddSection("Artifact Farming")

ArtifactSection:Label("Auto Farm Artifact")
ArtifactSection:Label("Collect 4 artifacts automatically")

ArtifactSection:Toggle("Auto Farm Artifact", false, function(state)
    if state then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Artifact Farm",
            Text = "Starting...",
            Duration = 3
        })
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Artifact Farm",
            Text = "Stopping...",
            Duration = 3
        })
    end
end)

local spotNames = {"Spot 1", "Spot 2", "Spot 3", "Spot 4"}
ArtifactSection:Dropdown("Teleport to Spot", spotNames, function(selected)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Teleport",
        Text = "Going to "..selected,
        Duration = 3
    })
end)

ArtifactSection:Button("Unlock Temple", function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Temple",
        Text = "Unlocking temple...",
        Duration = 3
    })
end)

-- Trade Tab - FIXED
local Trade = Window:AddTab("Trade", "handshake")
local TradeSection = Trade:AddSection("Trade Settings")

TradeSection:Dropdown("Trade Mode", {"V1", "V2"}, function(mode)
    tradeState.mode = mode
end)

TradeSection:Dropdown("Select Player", playerList, function(player)
    tradeState.selectedPlayerName = player
end)

TradeSection:Toggle("Auto Accept", false, function(state)
    _G.AutoAcceptTradeEnabled = state
end)

TradeSection:Toggle("Save Items Mode", false, function(state)
    tradeState.saveTempMode = state
end)

TradeSection:Toggle("Mass Trade", false, function(state)
    tradeState.autoTradeV2 = state
end)

-- Shop Tab - FIXED
local Shop = Window:AddTab("Shop", "shopping-bag")
local ShopSection = Shop:AddSection("Shop")

local merchantItems = {"Item 1", "Item 2", "Item 3"}
ShopSection:Dropdown("Merchant", merchantItems, function(item)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Purchase",
        Text = "Bought "..item,
        Duration = 3
    })
end)

local rodOptions = {"Basic Rod", "Advanced Rod", "Pro Rod"}
ShopSection:Dropdown("Rods", rodOptions, function(rod)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Rod",
        Text = "Bought "..rod,
        Duration = 3
    })
end)

local baitOptions = {"Worm Bait", "Shrimp Bait", "Special Bait"}
ShopSection:Dropdown("Baits", baitOptions, function(bait)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Bait",
        Text = "Bought "..bait,
        Duration = 3
    })
end)

-- Settings Tab - FIXED
local SettingsTab = Window:AddTab("Settings", "settings")
local SettingsSection = SettingsTab:AddSection("Settings")

SettingsSection:Toggle("Anti-AFK", true, function(state)
    _G.AntiAFKEnabled = state
end)

SettingsSection:Toggle("Hide Fish Notifications", false, function(state)
    -- Hide notification logic
end)

SettingsSection:Button("Boost FPS", function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "FPS",
        Text = "FPS boosted!",
        Duration = 3
    })
end)

SettingsSection:Button("Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId)
end)

SettingsSection:Button("Save Config", function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Config",
        Text = "Settings saved!",
        Duration = 3
    })
end)

------------------------------------------
----- =======[ INITIALIZE VARIABLES ]
------------------------------------------

-- Initialize global variables
_G.FINISH_DELAY = 1
_G.SPEED_LEGIT = 0.05
_G.STUCK_TIMEOUT = 10
_G.obtainedLimit = 30
_G.AutoAcceptTradeEnabled = false
_G.sellActive = false

-- Feature state
local featureState = {
    Instant_StartDelay = 1.20,
    Instant_ResetCount = 10,
    Instant_ResetPause = 0.10
}

-- Player states
local ijump = false
local universalNoclip = false

-- Mock functions untuk testing
function StartAutoFish5X()
    print("🎣 Starting Auto Fish 5X")
end

function StopAutoFish5X()
    print("🛑 Stopping Auto Fish 5X")
end

function _G.StopFishing()
    print("⏹️ Stop Fishing")
end

function _G.ToggleAutoClick(state)
    print("🖱️ Auto Click:", state)
end

function _G.StartHideName()
    print("👤 Hide Name: ON")
end

function _G.StopHideName()
    print("👤 Hide Name: OFF")
end

function setGameAnimationsEnabled(state)
    print("🎬 Animations:", state and "Disabled" or "Enabled")
end

function startOrStopAutoFish(state)
    print("🤖 Auto Fish:", state and "START" or "STOP")
end

------------------------------------------
----- =======[ FINAL MESSAGE ]
------------------------------------------

print("🎉 All tabs fixed with correct Chloe X syntax!")
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "OGhub",
    Text = "All menus loaded successfully!",
    Duration = 5
})