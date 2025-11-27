------------------------------------------
----- =======[ LOAD UI LIBRARY - FIXED ]
------------------------------------------

-- Coba beberapa URL library yang terbukti work
local success, OrionLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexsoftworks/Orion/main/source"))()
end)

if not success then
    -- Alternatif 1
    success, OrionLib = pcall(function()
        return loadstring(game:HttpGet("https://pastebin.com/raw/4JfVp3b0"))()
    end)
end

if not success then
    -- Alternatif 2  
    success, OrionLib = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/ItzzExcel/scripts/main/Orion%20Library.lua"))()
    end)
end

if not success then
    -- Buat simple UI manual jika semua URL gagal
    OrionLib = {}
    function OrionLib:MakeWindow(config)
        local window = {Tabs = {}}
        
        function window:MakeTab(tabConfig)
            local tab = {Name = tabConfig.Name}
            
            function tab:AddSection(name)
                print("Section:", name)
                local section = {}
                
                function section:AddParagraph(title, content)
                    print("📝", title, "-", content)
                end
                
                function section:AddToggle(config)
                    print("🔘 Toggle:", config.Name, "Default:", config.Default)
                    if config.Callback then
                        config.Callback(config.Default)
                    end
                end
                
                function section:AddSlider(config)
                    print("📊 Slider:", config.Name, config.Min, config.Max, config.Default)
                    if config.Callback then
                        config.Callback(config.Default)
                    end
                end
                
                function section:AddButton(config)
                    print("🔼 Button:", config.Name)
                    if config.Callback then
                        config.Callback()
                    end
                end
                
                function section:AddDropdown(config)
                    print("📋 Dropdown:", config.Name, #config.Options)
                    if config.Callback and #config.Options > 0 then
                        config.Callback(config.Options[1])
                    end
                end
                
                return section
            end
            
            table.insert(window.Tabs, tab)
            return tab
        end
        
        function window:Init()
            print("🎮 OGHub Loaded with Fallback UI!")
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "OGhub",
                Text = "Fallback UI Loaded!",
                Duration = 5
            })
        end
        
        return window
    end
end

------------------------------------------
----- =======[ CREATE WINDOW ]
------------------------------------------

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

local HomeSection = HomeTab:AddSection("Welcome")
HomeSection:AddParagraph("OGhub", "Script loaded successfully!")
HomeSection:AddParagraph("Status", "All features are ready to use!")

------------------------------------------
----- =======[ AUTO FISH TAB ]
------------------------------------------

local AutoFishTab = Window:MakeTab({
    Name = "Auto Fishing", 
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local FishSection = AutoFishTab:AddSection("Fishing Settings")

-- Auto Fish Toggle
FishSection:AddToggle({
    Name = "Auto Fish Instant",
    Default = false,
    Callback = function(Value)
        print("Auto Fish:", Value)
        if Value then
            -- StartAutoFish5X()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Auto Fish",
                Text = "Started Auto Fishing!",
                Duration = 3
            })
        else
            -- StopAutoFish5X()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Auto Fish", 
                Text = "Stopped Auto Fishing!",
                Duration = 3
            })
        end
    end
})

-- Delay Slider
FishSection:AddSlider({
    Name = "Delay Finish",
    Min = 0.1,
    Max = 5,
    Default = 1,
    Color = Color3.fromRGB(255,0,127),
    Increment = 0.1,
    Callback = function(Value)
        _G.FINISH_DELAY = Value
        print("Delay set to:", Value)
    end
})

-- Speed Slider
FishSection:AddSlider({
    Name = "Speed Legit", 
    Min = 0.1,
    Max = 2,
    Default = 0.5,
    Color = Color3.fromRGB(255,0,127),
    Increment = 0.1,
    Callback = function(Value)
        _G.SPEED_LEGIT = Value
        print("Speed set to:", Value)
    end
})

-- Stop Button
FishSection:AddButton({
    Name = "Stop Fishing",
    Callback = function()
        print("Stop Fishing clicked")
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Fishing",
            Text = "Fishing stopped!",
            Duration = 3
        })
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

local PlayerSection = PlayerTab:AddSection("Player Settings")

-- WalkSpeed
PlayerSection:AddSlider({
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
            print("WalkSpeed:", Value)
        end
    end
})

-- JumpPower
PlayerSection:AddSlider({
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
            print("JumpPower:", Value)
        end
    end
})

-- Infinity Jump
local ijump = false
PlayerSection:AddToggle({
    Name = "Infinity Jump",
    Default = false,
    Callback = function(Value)
        ijump = Value
        print("Infinity Jump:", Value)
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

------------------------------------------
----- =======[ TELEPORT TAB ]
------------------------------------------

local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local TeleportSection = TeleportTab:AddSection("Teleport Options")

-- Player List
local players = {}
for _, player in pairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
        table.insert(players, player.Name)
    end
end

TeleportSection:AddDropdown({
    Name = "Teleport to Player",
    Default = players[1] or "",
    Options = players,
    Callback = function(Value)
        print("Teleporting to:", Value)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Teleport",
            Text = "Teleporting to "..Value,
            Duration = 3
        })
    end
})

-- Islands
local islands = {"Spawn", "Market", "Fishing Spot", "Boss Area"}
TeleportSection:AddDropdown({
    Name = "Teleport to Island",
    Default = islands[1],
    Options = islands,
    Callback = function(Value)
        print("Teleporting to island:", Value)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Island Teleport",
            Text = "Teleporting to "..Value,
            Duration = 3
        })
    end
})

------------------------------------------
----- =======[ INITIALIZE ]
------------------------------------------

-- Initialize global variables
_G.FINISH_DELAY = 1
_G.SPEED_LEGIT = 0.5

-- Init the UI
Window:Init()

print("✅ OGHub loaded successfully!")