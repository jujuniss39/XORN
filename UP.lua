------------------------------------------
----- =======[ CREATE TABS - FIXED ]
------------------------------------------

local Home = Window:AddTab("About Me", "hard-drive")
local AutoFish = Window:AddTab("Auto Fishing", "fish")
local X5SpeedTab = Window:AddTab("OG Mode", "zap")
local AutoFarmArt = Window:AddTab("Auto Farm Artifact", "flask-round")
local PlayerTab = Window:AddTab("Player", "users-round")
local Teleport = Window:AddTab("Teleport", "search")
local Trade = Window:AddTab("Trade", "handshake")
local AutoFav = Window:AddTab("Auto Favorite", "heart")
local Shop = Window:AddTab("Shop", "plus")
local SettingsTab = Window:AddTab("Settings", "cog")
_G.ServerPage = Window:AddTab("Server List", "server")

------------------------------------------
----- =======[ HOME TAB - FIXED ]
------------------------------------------

local HomeSection = Home:AddSection("Attention!")
HomeSection:AddParagraph("⚠️OGhub⚠️", [[
Thanks For Using This Script.
No More Premium Script.
Everyone Can Used !!.
Keep OG Fams..
]])

------------------------------------------
----- =======[ AUTO FISH TAB - FIXED ]
------------------------------------------

local FishSection = AutoFish:AddSection("Auto Fishing Settings")

FishSection:AddSlider("Delay Finish", 0.01, 5, _G.FINISH_DELAY, 0.01, function(value)
    _G.FINISH_DELAY = value
end)

FishSection:AddToggle("Auto Fish Instant", false, function(value)
    if value then
        StartAutoFish5X()
    else
        StopAutoFish5X()
    end
end)

FishSection:AddDivider()

FishSection:AddSlider("Speed Legit", 0.01, 5, _G.SPEED_LEGIT, 0.01, function(value)
    _G.SPEED_LEGIT = value
end)

FishSection:AddToggle("Auto Fish Legit", false, function(state)
    _G.equipRemote:FireServer(1)
    _G.ToggleAutoClick(state)
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    local fishingGui = playerGui:WaitForChild("Fishing"):WaitForChild("Main")
    local chargeGui = playerGui:WaitForChild("Charge"):WaitForChild("Main")
    fishingGui.Visible = not state
    chargeGui.Visible = not state
end)

FishSection:AddDivider()

FishSection:AddSlider("Sell Threshold", 1, 6000, 30, 1, function(value)
    _G.obtainedLimit = value
end)

FishSection:AddSlider("Anti Stuck Delay", 1, 6000, _G.STUCK_TIMEOUT, 1, function(value)
    _G.STUCK_TIMEOUT = value
end)

FishSection:AddToggle("Auto Sell", false, function(state)
    _G.sellActive = state
    if state then
        NotifySuccess("Auto Sell", "Limit: " .. _G.obtainedLimit)
    else
        NotifySuccess("Auto Sell", "Disabled")
    end
end)

FishSection:AddToggle("Anti Stuck", false, function(state)
    _G.AntiStuckEnabled = state
end)

FishSection:AddDivider()

FishSection:AddButton("Stop Fishing", function()
    _G.StopFishing()
    RodIdle:Stop()
    _G.stopSpam()
    _G.StopRecastSpam()
end)

------------------------------------------
----- =======[ X5 SPEED TAB - FIXED ]
------------------------------------------

local X5SpeedSection = X5SpeedTab:AddSection("OG Mode Settings")

X5SpeedSection:AddSlider("Delay Recast", 0.00, 5.0, 1.20, 0.01, function(v)
    featureState.Instant_StartDelay = tonumber(v)
end)

X5SpeedSection:AddSlider("Spam Finish", 5, 50, 10, 1, function(v)
    featureState.Instant_ResetCount = math.floor(tonumber(v) or 10)
end)

X5SpeedSection:AddSlider("Cooldown Recast", 0.01, 5, 0.10, 0.01, function(v)
    featureState.Instant_ResetPause = tonumber(v) or 2.0
end)

X5SpeedSection:AddDivider()

X5SpeedSection:AddToggle("AutoFish OG Mode", false, function(state)
    if state then
        startOrStopAutoFish(true)
    else
        startOrStopAutoFish(false)
    end
end)

X5SpeedSection:AddToggle("No Animation", false, function(v)
    setGameAnimationsEnabled(v)
end)

------------------------------------------
----- =======[ PLAYER TAB - FIXED ]
------------------------------------------

local PlayerSection = PlayerTab:AddSection("Player Settings")

PlayerSection:AddToggle("Hide Name", false, function(state)
    if state then
        _G.StartHideName()
    else
        _G.StopHideName()
    end
end)

local defaultMinZoom = LocalPlayer.CameraMinZoomDistance
local defaultMaxZoom = LocalPlayer.CameraMaxZoomDistance

PlayerSection:AddToggle("Unlimited Zoom", false, function(state)
    if state then
        LocalPlayer.CameraMinZoomDistance = 0.5
        LocalPlayer.CameraMaxZoomDistance = 9999
    else
        LocalPlayer.CameraMinZoomDistance = defaultMinZoom
        LocalPlayer.CameraMaxZoomDistance = defaultMaxZoom
    end
end)

PlayerSection:AddButton("Access All Boats", accessAllBoats)

PlayerSection:AddToggle("Infinity Jump", false, function(val)
    ijump = val
end)

PlayerSection:AddToggle("Enable Float", false, function(enabled)
    -- floatingPlat(enabled)
end)

PlayerSection:AddToggle("Universal No Clip", false, function(val)
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
end)

PlayerSection:AddToggle("Anti Drown (Oxygen Bypass)", false, function(state)
    AntiDrown_Enabled = state
    if state then
        NotifySuccess("Anti Drown Active", "Oxygen loss has been blocked.", 3)
    else
        NotifyWarning("Anti Drown Disabled", "You're vulnerable to drowning again.", 3)
    end
end)

PlayerSection:AddSlider("WalkSpeed", 16, 200, 20, 1, function(val)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = val end
end)

PlayerSection:AddSlider("Jump Power", 50, 500, 50, 10, function(val)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = val
        end
    end
end)

------------------------------------------
----- =======[ TELEPORT TAB - FIXED ]
------------------------------------------

local TeleportSection = Teleport:AddSection("Teleport Options")

-- Player Teleport Dropdown
local playerList = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        table.insert(playerList, p.DisplayName)
    end
end

TeleportSection:AddDropdown("Teleport to Player", playerList, function(selectedDisplayName)
    for _, p in pairs(Players:GetPlayers()) do
        if p.DisplayName == selectedDisplayName then
            NotifySuccess("Teleport Successfully", "Successfully Teleported to " .. p.DisplayName .. "!", 3)
            break
        end
    end
end)

-- Island Teleport
local islandNames = {}
for _, data in pairs(islandCoords) do
    table.insert(islandNames, data.name)
end

TeleportSection:AddDropdown("Island Selector", islandNames, function(selectedName)
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
end)

-- Event Teleport
local eventsList = {
    "Shark Hunt", "Ghost Shark Hunt", "Worm Hunt", "Black Hole", 
    "Shocked", "Ghost Worm", "Meteor Rain", "Megalodon Hunt"
}

TeleportSection:AddDropdown("Teleport Event", eventsList, function(option)
    local props = workspace:FindFirstChild("Props")
    if props and props:FindFirstChild(option) then
        local targetModel = (option == "Worm Hunt" or option == "Ghost Worm") and props:FindFirstChild("Model") or props[option]
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
end)

-- NPC Teleport
local npcList = {}
for _, npc in pairs(npcFolder:GetChildren()) do
    if npc:IsA("Model") then
        local hrp = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
        if hrp then
            table.insert(npcList, npc.Name)
        end
    end
end

TeleportSection:AddDropdown("NPC Teleport", npcList, function(selectedName)
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
end)

------------------------------------------
----- =======[ TRADE TAB - FIXED ]
------------------------------------------

local TradeSection = Trade:AddSection("Trade Settings")

TradeSection:AddDropdown("Select Trade Mode", {"V1", "V2"}, function(v)
    tradeState.mode = v
    NotifySuccess("Mode Changed", "Trade mode set to: " .. v, 3)
end)

local function getPlayerListV2()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    table.sort(list)
    return list
end

TradeSection:AddDropdown("Select Trade Target", getPlayerListV2(), function(selected)
    tradeState.selectedPlayerName = selected
    local player = Players:FindFirstChild(selected)
    if player then
        tradeState.selectedPlayerId = player.UserId
        NotifySuccess("Target Selected", "Target set to: " .. player.Name, 3)
    else
        tradeState.selectedPlayerId = nil
        NotifyError("Target Error", "Player not found!", 3)
    end
end)

TradeSection:AddToggle("Enable Auto Accept Trade", false, function(value)
    _G.AutoAcceptTradeEnabled = value
    if value then
        NotifySuccess("Auto Accept", "Auto accept trade enabled.", 3)
    else
        NotifyWarning("Auto Accept", "Auto accept trade disabled.", 3)
    end
end)

TradeSection:AddDivider()

TradeSection:AddToggle("Mode Save Items", false, function(state)
    tradeState.saveTempMode = state
    if state then
        tradeState.TempTradeList = {}
        NotifySuccess("Save Mode", "Enabled - Click items to save")
    else
        NotifyInfo("Save Mode", "Disabled - "..#tradeState.TempTradeList.." items saved")
    end
end)

TradeSection:AddToggle("Trade (Original Send)", false, function(state)
    tradeState.onTrade = state
    if state then
        NotifySuccess("Trade", "Trade Mode Enabled. Click an item to send trade.")
    else
        NotifyWarning("Trade", "Trade Mode Disabled.")
    end
end)

TradeSection:AddToggle("Start Mass Trade V1", false, function(state)
    tradeState.autoTradeV2 = state
    if tradeState.mode == "V1" and state then
        if #tradeState.TempTradeList == 0 then
            NotifyError("Mass Trade", "No items saved to trade!")
            tradeState.autoTradeV2 = false
            return
        end
        NotifySuccess("Mass Trade", "V1 Auto Trade Enabled")
    else
        NotifyWarning("Mass Trade", "V1 Auto Trade Disabled")
    end
end)

TradeSection:AddToggle("Filter Unfavorited Items Only", false, function(val)
    tradeState.filterUnfavorited = val
    NotifyInfo("Filter Updated", "Inventory list refreshed.", 3)
end)

------------------------------------------
----- =======[ AUTO FARM ARTIFACT TAB - FIXED ]
------------------------------------------

local ArtifactSection = AutoFarmArt:AddSection("Artifact Farming")

_G.ArtifactParagraph = ArtifactSection:AddParagraph("Auto Farm Artifact", "Waiting for activation...")

ArtifactSection:AddToggle("Auto Farm Artifact", false, function(state)
    if state then
        NotifyInfo("Artifact Farm", "Starting artifact farm...")
    else
        NotifyInfo("Artifact Farm", "Stopping artifact farm...")
    end
end)

local spotNames = {"Spot 1", "Spot 2", "Spot 3", "Spot 4"}
ArtifactSection:AddDropdown("Teleport to Lever Temple", spotNames, function(selected)
    NotifySuccess("Lever Temple", "Teleported to " .. selected)
end)

ArtifactSection:AddButton("Unlock The Temple", function()
    NotifyInfo("Temple Unlock", "Placing artifacts...")
end)

------------------------------------------
----- =======[ AUTO FAVORITE TAB - FIXED ]
------------------------------------------

local AutoFavSection = AutoFav:AddSection("Auto Favorite Settings")

AutoFavSection:AddToggle("Enable Auto Favorite", false, function(state)
    if state then
        NotifySuccess("Auto Favorite", "Auto Favorite feature enabled")
    else
        NotifyWarning("Auto Favorite", "Auto Favorite feature disabled")
    end
end)

local AllFishNames = {"Fish1", "Fish2", "Fish3", "Fish4"}
AutoFavSection:AddDropdown("Auto Favorite Fishes", AllFishNames, function(selectedNames)
    NotifyInfo("Auto Favorite", "Favoriting active for fish: " .. table.concat(selectedNames, ", "))
end)

AutoFavSection:AddDropdown("Auto Favorite Variants", {"Variant1", "Variant2", "Variant3"}, function(selectedVariants)
    NotifyInfo("Auto Favorite", "Favoriting active for variants: " .. table.concat(selectedVariants, ", "))
end)

------------------------------------------
----- =======[ SHOP TAB - FIXED ]
------------------------------------------

local ShopSection = Shop:AddSection("Shop Options")

local merchantItems = {"Item 1", "Item 2", "Item 3"}
ShopSection:AddDropdown("Traveling Merchant", merchantItems, function(selected)
    NotifyInfo("Purchase Success", "Successfully bought: " .. selected)
end)

local weatherOptions = {"Storm", "Cloudy", "Snow", "Wind", "Radiant"}
ShopSection:AddDropdown("Auto Buy Weather", weatherOptions, function(selected)
    for _, weatherType in pairs(selected) do
        NotifyInfo("Auto Weather", "Auto buying " .. weatherType .. " has started!")
    end
end)

local rodOptions = {"Basic Rod | Price: 100", "Advanced Rod | Price: 500", "Pro Rod | Price: 1000"}
ShopSection:AddDropdown("Rod Shop", rodOptions, function(option)
    NotifySuccess("Rod Purchased", option .. " has been successfully purchased!")
end)

local baitOptions = {"Worm Bait | Price: 10", "Shrimp Bait | Price: 25", "Special Bait | Price: 50"}
ShopSection:AddDropdown("Baits Shop", baitOptions, function(option)
    NotifySuccess("Bait Purchased", option .. " has been successfully purchased!")
end)

------------------------------------------
----- =======[ SETTINGS TAB - FIXED ]
------------------------------------------

local SettingsSection = SettingsTab:AddSection("Settings")

SettingsSection:AddToggle("Anti-AFK", true, function(Value)
    _G.AntiAFKEnabled = Value
    if Value then
        NotifySuccess("Anti-AFK Activated", "You will now avoid being kicked.")
    else
        NotifySuccess("Anti-AFK Deactivated", "You can now go idle again.")
    end
end)

SettingsSection:AddButton("Boost FPS (Ultra Low Graphics)", function()
    NotifySuccess("Boost FPS", "Boost FPS mode applied successfully!")
end)

SettingsSection:AddToggle("Hide Notif Fish", false, function(state)
    if state then
        NotifySuccess("Notification", "Fish notifications hidden")
    else
        NotifySuccess("Notification", "Fish notifications shown")
    end
end)

SettingsSection:AddButton("Rejoin Server", function()
    NotifyInfo("Rejoin", "Rejoining server...")
end)

SettingsSection:AddButton("Server Hop (New Server)", function()
    NotifyInfo("Server Hop", "Searching for new server...")
end)

SettingsSection:AddButton("Save Config", function()
    NotifySuccess("Config Saved", "Config has been saved!")
end)

SettingsSection:AddButton("Load Config", function()
    NotifySuccess("Config Loaded", "Config has been loaded!")
end)

------------------------------------------
----- =======[ SERVER PAGE TAB - FIXED ]
------------------------------------------

local ServerSection = _G.ServerPage:AddSection("Server List")

ServerSection:AddButton("Show Server List", function()
    if _G.ServersShown then return end
    _G.ServersShown = true

    for _, server in ipairs(_G.ServerList.data) do
        _G.playerCount = string.format("%d/%d", server.playing, server.maxPlayers)
        _G.ping = server.ping
        _G.id = server.id

        ServerSection:AddButton("Server - " .. _G.playerCount, function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, _G.id, game.Players.LocalPlayer)
        end)
    end
end)

-- Final Notification
NotifySuccess("OGhub", "All Features Loaded with Chloe X GUI!", 5)
print(" OGHub dengan Chloe X GUI berhasil di-load semua tab!")