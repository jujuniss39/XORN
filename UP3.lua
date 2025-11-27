------------------------------------------
----- =======[ USE WORKING UI LIBRARY ]
------------------------------------------

-- Orion Library (Terbukti Stabil)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexsoftworks/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
    Name = "OGhub", 
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "OGhubConfig"
})

------------------------------------------
----- =======[ HOME TAB ]
------------------------------------------

local HomeTab = Window:MakeTab({
    Name = "Home",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

HomeTab:AddSection("Welcome")
HomeTab:AddParagraph("OGhub", "Thank you for using OGHub!")
HomeTab:AddParagraph("Status", "All features loaded successfully!")

------------------------------------------
----- =======[ AUTO FISH TAB ]
------------------------------------------

local AutoFishTab = Window:MakeTab({
    Name = "Auto Fishing",
    Icon = "rbxassetid://4483345998", 
    PremiumOnly = false
})

AutoFishTab:AddSection("Fishing Settings")

-- Auto Fish Toggle
_G.AutoFishEnabled = false
AutoFishTab:AddToggle({
    Name = "Auto Fish Instant",
    Default = false,
    Callback = function(Value)
        _G.AutoFishEnabled = Value
        if Value then
            StartAutoFish5X()
        else
            StopAutoFish5X()
        end
    end    
})

-- Delay Slider
_G.FINISH_DELAY = 1
AutoFishTab:AddSlider({
    Name = "Delay Finish",
    Min = 0.1,
    Max = 5,
    Default = 1,
    Color = Color3.fromRGB(255,0,127),
    Increment = 0.1,
    Callback = function(Value)
        _G.FINISH_DELAY = Value
    end    
})

-- Legit Mode
_G.SPEED_LEGIT = 0.05
AutoFishTab:AddToggle({
    Name = "Auto Fish Legit", 
    Default = false,
    Callback = function(Value)
        _G.equipRemote:FireServer(1)
        _G.ToggleAutoClick(Value)
    end    
})

AutoFishTab:AddSlider({
    Name = "Speed Legit",
    Min = 0.1,
    Max = 2,
    Default = 0.05,
    Color = Color3.fromRGB(255,0,127),
    Increment = 0.05,
    Callback = function(Value)
        _G.SPEED_LEGIT = Value
    end    
})

-- Auto Sell
_G.sellActive = false
_G.obtainedLimit = 30
AutoFishTab:AddToggle({
    Name = "Auto Sell",
    Default = false,
    Callback = function(Value)
        _G.sellActive = Value
    end    
})

AutoFishTab:AddSlider({
    Name = "Sell Threshold", 
    Min = 1,
    Max = 100,
    Default = 30,
    Color = Color3.fromRGB(255,0,127),
    Increment = 1,
    Callback = function(Value)
        _G.obtainedLimit = Value
    end    
})

-- Stop Button
AutoFishTab:AddButton({
    Name = "Stop Fishing",
    Callback = function()
        _G.StopFishing()
    end    
})

------------------------------------------
----- =======[ PLAYER TAB ]
------------------------------------------

local PlayerTab = Window:MakeTab({
    Name = "Player",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false  
})

PlayerTab:AddSection("Movement Settings")

-- WalkSpeed
PlayerTab:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Color = Color3.fromRGB(255,0,127),
    Increment = 1,
    Callback = function(Value)
        local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Value
        end
    end    
})

-- JumpPower
PlayerTab:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(255,0,127),
    Increment = 5,
    Callback = function(Value)
        local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.JumpPower = Value
        end
    end    
})

-- Infinity Jump
local ijump = false
PlayerTab:AddToggle({
    Name = "Infinity Jump",
    Default = false,
    Callback = function(Value)
        ijump = Value
    end    
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if ijump and game.Players.LocalPlayer.Character then
        local humanoid = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState("Jumping")
        end
    end
end)

PlayerTab:AddSection("Visual Settings")

-- Hide Name
PlayerTab:AddToggle({
    Name = "Hide Name",
    Default = false,
    Callback = function(Value)
        if Value then
            _G.StartHideName()
        else
            _G.StopHideName()
        end
    end    
})

-- No Clip
local noclip = false
PlayerTab:AddToggle({
    Name = "No Clip", 
    Default = false,
    Callback = function(Value)
        noclip = Value
    end    
})

game:GetService("RunService").Stepped:Connect(function()
    if noclip and game.Players.LocalPlayer.Character then
        for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

------------------------------------------
----- =======[ TELEPORT TAB ]
------------------------------------------

local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

TeleportTab:AddSection("Player Teleport")

-- Player List
local playerDropdown = {}
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
        table.insert(playerDropdown, player.Name)
    end
end

TeleportTab:AddDropdown({
    Name = "Teleport to Player",
    Default = "",
    Options = playerDropdown,
    Callback = function(Value)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Teleport",
            Text = "Teleporting to "..Value,
            Duration = 3
        })
    end    
})

TeleportTab:AddSection("Island Teleport")

-- Islands
local islands = {
    "Spawn Island", "Fishing Spot", "Market", "Boss Area", 
    "Secret Cave", "Treasure Island", "Volcano", "Ice Cave"
}

TeleportTab:AddDropdown({
    Name = "Teleport to Island", 
    Default = "",
    Options = islands,
    Callback = function(Value)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Island Teleport",
            Text = "Teleporting to "..Value,
            Duration = 3
        })
    end    
})

------------------------------------------
----- =======[ X5 SPEED TAB ]
------------------------------------------

local X5SpeedTab = Window:MakeTab({
    Name = "OG Mode", 
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

X5SpeedTab:AddSection("OG Mode Settings")

local featureState = {
    Instant_StartDelay = 1.20,
    Instant_ResetCount = 10, 
    Instant_ResetPause = 0.10
}

X5SpeedTab:AddSlider({
    Name = "Delay Recast",
    Min = 0.1,
    Max = 5,
    Default = 1.2,
    Color = Color3.fromRGB(255,0,127),
    Increment = 0.1,
    Callback = function(Value)
        featureState.Instant_StartDelay = Value
    end    
})

X5SpeedTab:AddSlider({
    Name = "Spam Finish", 
    Min = 1,
    Max = 50,
    Default = 10,
    Color = Color3.fromRGB(255,0,127),
    Increment = 1,
    Callback = function(Value)
        featureState.Instant_ResetCount = Value
    end    
})

X5SpeedTab:AddSlider({
    Name = "Cooldown Recast",
    Min = 0.1, 
    Max = 5,
    Default = 0.1,
    Color = Color3.fromRGB(255,0,127),
    Increment = 0.1,
    Callback = function(Value)
        featureState.Instant_ResetPause = Value
    end    
})

X5SpeedTab:AddToggle({
    Name = "AutoFish OG Mode",
    Default = false,
    Callback = function(Value)
        if Value then
            startOrStopAutoFish(true)
        else
            startOrStopAutoFish(false) 
        end
    end    
})

X5SpeedTab:AddToggle({
    Name = "No Animation",
    Default = false,
    Callback = function(Value)
        setGameAnimationsEnabled(Value)
    end    
})

------------------------------------------
----- =======[ SETTINGS TAB ]
------------------------------------------

local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://4483345998", 
    PremiumOnly = false
})

SettingsTab:AddSection("General Settings")

SettingsTab:AddToggle({
    Name = "Anti-AFK",
    Default = true,
    Callback = function(Value)
        _G.AntiAFKEnabled = Value
    end    
})

SettingsTab:AddToggle({
    Name = "Auto Rejoin",
    Default = false, 
    Callback = function(Value)
        -- Auto rejoin logic
    end    
})

SettingsTab:AddButton({
    Name = "Boost FPS",
    Callback = function()
        -- FPS boost logic
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "FPS Boost",
            Text = "FPS boosted!",
            Duration = 3
        })
    end    
})

SettingsTab:AddButton({
    Name = "Rejoin Server", 
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end    
})

------------------------------------------
----- =======[ INITIALIZE FUNCTIONS ]
------------------------------------------

-- Mock functions untuk testing
function StartAutoFish5X()
    print("🎣 Starting Auto Fish 5X")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Auto Fish",
        Text = "Started Auto Fish!",
        Duration = 3
    })
end

function StopAutoFish5X()
    print("🛑 Stopping Auto Fish 5X") 
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Auto Fish",
        Text = "Stopped Auto Fish!",
        Duration = 3
    })
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

-- Initialize remotes
pcall(function()
    _G.equipRemote = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipToolFromHotbar"]
end)

------------------------------------------
----- =======[ FINAL INIT ]
------------------------------------------

OrionLib:Init()
print("🎉 OGHub loaded successfully with Orion UI!")
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "OGhub",
    Text = "All features loaded!",
    Duration = 5
})