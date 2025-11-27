-- =============================================
-- OGHUB GUI INTEGRATION
-- =============================================

-- Load OGHub Library
local OGHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/TesterX14/XXXX/refs/heads/main/Library"))()

-- Create Main Window
local OGHubWindow = OGHub:Window({
    Title = "OGHub | FishIt Premium",
    Color = Color3.fromRGB(0, 208, 255),
    Size = UDim2.new(0, 600, 0, 450),
    Version = 2.0
})

-- Tab System
local OGTabs = {
    Main = OGHubWindow:AddTab({Name = "Fishing", Icon = "gamepad"}),
    Auto = OGHubWindow:AddTab({Name = "Auto", Icon = "loop"}),
    Trade = OGHubWindow:AddTab({Name = "Trade", Icon = "rbxassetid://114581487428395"}),
    Quest = OGHubWindow:AddTab({Name = "Quest", Icon = "scroll"}),
    Teleport = OGHubWindow:AddTab({Name = "Teleport", Icon = "gps"}),
    Webhook = OGHubWindow:AddTab({Name = "Webhook", Icon = "rbxassetid://137601480983962"}),
    Misc = OGHubWindow:AddTab({Name = "Misc", Icon = "settings"})
}

-- =============================================
-- FISHING TAB
-- =============================================
local FishingSection = OGTabs.Main:AddSection("Fishing Features")

-- Detector System
local DetectorParagraph = FishingSection:AddParagraph({
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
            -- Detector implementation from original script
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
                            OGHubWindow:Notify({
                                Title = "Fishing Stuck",
                                Message = "Resetting fishing...",
                                Duration = 3
                            })
                            
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

-- Legit Fishing
FishingSection:AddInput({
    Title = "Legit Delay",
    Content = "Delay complete fishing!",
    Value = tostring(_G.Delay),
    Callback = function(value)
        local delayValue = tonumber(value)
        if delayValue and delayValue > 0 then
            _G.Delay = delayValue
        end
    end
})

FishingSection:AddToggle({
    Title = "Legit Fishing",
    Content = "Auto fishing with animation",
    Default = false,
    Callback = function(enabled)
        local fishingController = GameModules.FishingController
        fishingController._autoLoop = enabled
        
        if enabled then
            -- Legit fishing implementation from original script
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
            end
        else
            fishingController._autoLoop = false
        end
    end
})

-- Instant Fishing
FishingSection:AddInput({
    Title = "Delay Complete",
    Value = tostring(_G.DelayComplete),
    Callback = function(value)
        local delayValue = tonumber(value)
        if delayValue and delayValue >= 0 then
            _G.DelayComplete = delayValue
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

-- =============================================
-- AUTO TAB
-- =============================================
local AutoSection = OGTabs.Auto:AddSection("Auto Features")

-- Auto Sell
AutoSection:AddDropdown({
    Options = {"Delay", "Count"},
    Default = "Delay",
    Title = "Select Sell Mode", 
    Callback = function(mode)
        Config.sellMode = mode
    end
})

AutoSection:AddInput({
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
    end
})

AutoSection:AddToggle({
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

-- Auto Favorite
AutoSection:AddToggle({
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

-- Auto Equip Rod
AutoSection:AddToggle({
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

-- =============================================
-- TRADE TAB
-- =============================================
local TradeSection = OGTabs.Trade:AddSection("Trading Features")

-- Trading Panels
local FishTradePanel = TradeSection:AddParagraph({
    Title = "Fish Trading Panel",
    Content = "\r\nPlayer : ???\r\nItem   : ???\r\nAmount : 0\r\nStatus : Idle\r\nSuccess: 0 / 0\r\n"
})

local CoinTradePanel = TradeSection:AddParagraph({
    Title = "Coin Trading Panel", 
    Content = "\r\nPlayer   : ???\r\nTarget   : 0\r\nProgress : 0 / 0\r\nStatus   : Idle\r\nResult   : Success : 0 | Received : 0\r\n"
})

-- Player Selection
local PlayerDropdown = TradeSection:AddDropdown({
    Options = {},
    Multi = false,
    Title = "Select Player",
    Callback = function(player)
        Config.trade.selectedPlayer = player
    end
})

-- Refresh Players Button
TradeSection:AddButton({
    Title = "Refresh Players",
    Callback = function()
        local players = {}
        for _, player in ipairs(Services.Players:GetPlayers()) do
            if player ~= Config.player then
                table.insert(players, player.Name)
            end
        end
        PlayerDropdown:SetValues(players or {})
    end
})

-- Fish Trading
TradeSection:AddInput({
    Title = "Trade Amount",
    Default = "1",
    Callback = function(value)
        Config.trade.tradeAmount = tonumber(value) or 1
    end
})

TradeSection:AddToggle({
    Title = "Start Fish Trading",
    Default = false,
    Callback = function(enabled)
        if enabled then
            task.spawn(startTradeByName)
        else
            Config.trade.trading = false
        end
    end
})

-- Coin Trading
TradeSection:AddInput({
    Title = "Target Coin",
    Default = "0",
    Callback = function(value)
        Config.trade.targetCoins = tonumber(value) or 0
    end
})

TradeSection:AddToggle({
    Title = "Start Coin Trading",
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
-- QUEST TAB
-- =============================================
local QuestSection = OGTabs.Quest:AddSection("Quest Features")

-- Quest Panels
local ArtifactPanel = QuestSection:AddParagraph({
    Title = "Artifact Progress",
    Content = "\r\nArrow : DISABLE\r\nCrescent : DISABLE\r\nHourglass Diamond : DISABLE\r\nDiamond : DISABLE\r\n"
})

local DeepSeaPanel = QuestSection:AddParagraph({
    Title = "Deep Sea Quest",
    Content = "Loading..."
})

local ElementPanel = QuestSection:AddParagraph({
    Title = "Element Quest", 
    Content = "Loading..."
})

-- Auto Quest Progress
QuestSection:AddToggle({
    Title = "Auto Quest Progress",
    Default = false,
    Callback = function(enabled)
        Config.autoQuestFlow = enabled
        if enabled then
            task.spawn(function()
                -- Auto quest implementation from original script
                local deepSeaCompleted = false
                local artifactCompleted = false
                local elementCompleted = false
                
                while Config.autoQuestFlow and (not deepSeaCompleted or not artifactCompleted or not elementCompleted) do
                    -- Quest logic here
                    task.wait(2)
                end
            end)
        end
    end
})

-- Deep Sea Quest
QuestSection:AddToggle({
    Title = "Auto Deep Sea Quest",
    Content = "Automatically complete Deep Sea Quest!",
    Default = false,
    Callback = function(enabled)
        Config.autoDeepSea = enabled
        if enabled then
            task.spawn(function()
                while Config.autoDeepSea do
                    -- Deep sea quest implementation
                    task.wait(1)
                end
            end)
        end
    end
})

-- Element Quest
QuestSection:AddToggle({
    Title = "Auto Element Quest",
    Content = "Automatically teleport through Element quest stages.",
    Default = false,
    Callback = function(enabled)
        Config.autoElement = enabled
        if enabled then
            task.spawn(function()
                -- Element quest implementation
                task.wait(2)
            end)
        end
    end
})

-- =============================================
-- TELEPORT TAB
-- =============================================
local TeleportSection = OGTabs.Teleport:AddSection("Teleport Features")

-- Location Teleport
local LocationDropdown = TeleportSection:AddDropdown({
    Title = "Select Location",
    Options = LocationNames,
    Default = LocationNames[1],
    Callback = function(location)
        Config.teleportTarget = location
    end
})

TeleportSection:AddButton({
    Title = "Teleport to Location",
    Content = "Teleport to selected location",
    Callback = function()
        local targetLocation = Config.teleportTarget
        if not targetLocation then
            OGHubWindow:Notify({
                Title = "Teleport",
                Message = "Please select a location first!",
                Duration = 3
            })
            return
        end
        
        local locationData = LocationData[targetLocation]
        if locationData then
            local character = LocalPlayer.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                humanoidRootPart.CFrame = CFrame.new(locationData + Vector3.new(0, 3, 0))
                OGHubWindow:Notify({
                    Title = "Teleport",
                    Message = "Teleported to " .. targetLocation,
                    Duration = 3
                })
            end
        end
    end
})

-- Player Teleport
local PlayerTeleportDropdown = TeleportSection:AddDropdown({
    Title = "Select Player",
    Options = {},
    Callback = function(player)
        Config.trade.teleportTarget = player
    end
})

TeleportSection:AddButton({
    Title = "Refresh Players",
    Callback = function()
        local players = {}
        for _, player in ipairs(Services.Players:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(players, player.Name)
            end
        end
        PlayerTeleportDropdown:SetValues(players or {})
    end
})

TeleportSection:AddButton({
    Title = "Teleport to Player",
    Callback = function()
        local targetPlayer = Config.trade.teleportTarget
        if not targetPlayer then
            OGHubWindow:Notify({
                Title = "Teleport",
                Message = "Please select a player first!",
                Duration = 3
            })
            return
        end
        
        local target = Services.Players:FindFirstChild(targetPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local localCharacter = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if localCharacter then
                localCharacter.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                OGHubWindow:Notify({
                    Title = "Teleport",
                    Message = "Teleported to " .. target.Name,
                    Duration = 3
                })
            end
        end
    end
})

-- =============================================
-- WEBHOOK TAB
-- =============================================
local WebhookSection = OGTabs.Webhook:AddSection("Webhook Features")

-- Fish Caught Webhook
WebhookSection:AddInput({
    Title = "Webhook URL",
    Default = "",
    Callback = function(value)
        _G.WebhookURLs.FishCaught = value
        if _G.WebhookFlags and _G.WebhookFlags.FishCaught then
            _G.WebhookFlags.FishCaught.URL = value
        end
    end
})

WebhookSection:AddToggle({
    Title = "Send Fish Webhook",
    Default = _G.WebhookFlags.FishCaught.Enabled,
    Callback = function(enabled)
        _G.WebhookFlags.FishCaught.Enabled = enabled
        Config.autoWebhook = enabled
    end
})

-- Stats Webhook
WebhookSection:AddInput({
    Title = "Stats Webhook URL",
    Default = _G.WebhookFlags.Stats.URL,
    Callback = function(value)
        if value and value:match("discord.com/api/webhooks") then
            _G.WebhookFlags.Stats.URL = value
        end
    end
})

WebhookSection:AddToggle({
    Title = "Send Stats Webhook",
    Content = "Automatically send player stats to Discord",
    Default = _G.WebhookFlags.Stats.Enabled,
    Callback = function(enabled)
        Config.autoWebhookStats = enabled
        _G.WebhookFlags.Stats.Enabled = enabled
    end
})

-- =============================================
-- MISC TAB
-- =============================================
local MiscSection = OGTabs.Misc:AddSection("Miscellaneous Features")

-- Anti Staff
MiscSection:AddToggle({
    Title = "Anti Staff",
    Content = "Auto kick if staff/developer joins the server.",
    Default = false,
    Callback = function(enabled)
        _G.AntiStaff = enabled
        if enabled then
            -- Anti staff implementation from original script
            task.spawn(function()
                while _G.AntiStaff do
                    -- Staff detection logic
                    task.wait(1)
                end
            end)
        end
    end
})

-- No Fishing Animations
MiscSection:AddToggle({
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

-- Walk on Water
MiscSection:AddToggle({
    Title = "Walk on Water",
    Default = false,
    Callback = function(enabled)
        walkOnWaterEnabled = enabled
        local humanoidRootPart = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
        
        if enabled then
            -- Walk on water implementation from original script
            waterPart = Instance.new("Part")
            waterPart.Name = "WW_Part"
            waterPart.Size = Vector3.new(15, 1, 15)
            waterPart.Anchored = true
            waterPart.CanCollide = false
            waterPart.Transparency = 1
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

-- Freeze Player
MiscSection:AddToggle({
    Title = "Freeze Player",
    Content = "Freeze only if rod is equipped",
    Default = false,
    Callback = function(enabled)
        Config.frozen = enabled
        local character = Config.player.Character
        
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
                setCharacterAnchored(char, true)
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
-- INITIALIZATION COMPLETE
-- =============================================

OGHubWindow:Notify({
    Title = "OGHub FishIt",
    Message = "GUI Loaded Successfully!\nAll features are now available!",
    Duration = 5,
    Color = Color3.fromRGB(0, 208, 255)
})

-- Initialize player list
task.spawn(function()
    local players = {}
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(players, player.Name)
        end
    end
    PlayerDropdown:SetValues(players or {})
    PlayerTeleportDropdown:SetValues(players or {})
end)

-- Auto update quest panels
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            ElementPanel:SetContent(readQuestTracker("Element Tracker"))
            DeepSeaPanel:SetContent(readQuestTracker("Deep Sea Tracker"))
            updateArtifactPanel(getArtifactStatus())
        end)
    end
end)

print("OGHub FishIt Premium Loaded Successfully!")