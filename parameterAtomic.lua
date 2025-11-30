------------------------------------------
----- =======[ Load WindUI ]
-------------------------------------------

local Version = "1.6.53"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" ..
Version .. "/main.lua"))()

-------------------------------------------
----- =======[ MERGED GLOBAL FUNCTION ]
-------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
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

-- Animation Setup (TETAP SAMA dengan script pertama)
local ijump = false
local RodIdle = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("ReelingIdle")
local RodShake = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Animations"):WaitForChild("RodThrow")
local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
-- PENTING: Nama variable TETAP seperti aslinya
local RodShake = animator:LoadAnimation(RodShake)
local RodIdle = animator:LoadAnimation(RodIdle)

-- Folder References
local Shared = ReplicatedStorage:WaitForChild("Shared", 5)
local Modules = ReplicatedStorage:WaitForChild("Modules", 5)

-- Custom Require Function
local function customRequire(module)
    if not module then return nil end
    local success, result = pcall(require, module)
    if success then
        return result
    else
        local clone = module:Clone()
        clone.Parent = nil
        local cloneSuccess, cloneResult = pcall(require, clone)
        if cloneSuccess then
            return cloneResult
        else
            warn("Failed to load module: " .. module:GetFullName())
            return nil
        end
    end
end

-- Load Global Utilities
if Shared then
    if not _G.ItemUtility then
        local success, utility = pcall(require, Shared:WaitForChild("ItemUtility", 5))
        if success and utility then
            _G.ItemUtility = utility
        else
            warn("ItemUtility module not found or failed to load.")
        end
    end
    
    if not _G.ItemStringUtility and Modules then
        local success, stringUtility = pcall(require, Modules:WaitForChild("ItemStringUtility", 5))
        if success and stringUtility then
            _G.ItemStringUtility = stringUtility
        else
            warn("ItemStringUtility module not found or failed to load.")
        end
    end
    
    -- Load Trade Modules
    if not _G.Replion then 
        pcall(function() 
            _G.Replion = require(ReplicatedStorage.Packages.Replion) 
        end) 
    end
    
    if not _G.Promise then 
        pcall(function() 
            _G.Promise = require(ReplicatedStorage.Packages.Promise) 
        end) 
    end
    
    if not _G.PromptController then 
        pcall(function() 
            _G.PromptController = require(ReplicatedStorage.Controllers.PromptController) 
        end) 
    end
end

-- Advanced Module Loading System
local ModulesTable = {}
local success, errorMessage = pcall(function()
    local Controllers = ReplicatedStorage:WaitForChild("Controllers", 20)
    local NetFolder = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild(
        "sleitnick_net@0.2.0"):WaitForChild("net", 20)
    
    if not (Controllers and NetFolder and Shared) then 
        error("Core game folders not found.") 
    end

    -- Load using customRequire
    ModulesTable.Replion = customRequire(ReplicatedStorage.Packages.Replion)
    ModulesTable.ItemUtility = customRequire(Shared.ItemUtility)
    ModulesTable.FishingController = customRequire(Controllers.FishingController)
    
    -- Net Events
    ModulesTable.EquipToolEvent = NetFolder["RE/EquipToolFromHotbar"]
    ModulesTable.ChargeRodFunc = NetFolder["RF/ChargeFishingRod"]
    ModulesTable.StartMinigameFunc = NetFolder["RF/RequestFishingMinigameStarted"]
    ModulesTable.CompleteFishingEvent = NetFolder["RE/FishingCompleted"]
end)

if not success then
    warn("FATAL ERROR DURING MODULE LOADING: " .. tostring(errorMessage))
    return
end

-- Export untuk akses global (opsional)
_G.FishingModules = ModulesTable
_G.RodAnimations = {
    Idle = RodIdleAnim,
    Shake = RodShakeAnim
}

print(" Global Function Merged Successfully!")
print(" Modules Loaded:", ModulesTable)

-------------------------------------------
----- =======[ OPTIMIZED X5 SPEED SYSTEM ]
-------------------------------------------

local Modules = {}
local fishingTrove = {}
local autoFishThread = nil
local isWaitingForCorrectTier = false
local fishCaughtBindable = Instance.new("BindableEvent")
local hasEquippedRod = false

-- Enhanced Feature State dengan adaptive defaults
local featureState = {
    AutoFish = false,
    Instant_ChargeDelay = 0.05,    -- Lebih cepat
    Instant_SpamCount = 10,        -- Optimal spam
    Instant_WorkerCount = 2,
    Instant_StartDelay = 1.00,     -- Lebih cepat
    Instant_CatchTimeout = 0.01,
    Instant_CycleDelay = 0.05,     -- Lebih cepat antara cycle
    Instant_ResetCount = 999,      -- Very high untuk continuous
    Instant_ResetPause = 0.05      -- Sangat cepat
}

-- Performance Monitoring System
local performanceStats = {
    cyclesCompleted = 0,
    fishCaught = 0,
    averageCycleTime = 0,
    failures = 0,
    startTime = os.time(),
    lastOptimization = os.time()
}

-- Adaptive Timing System
local adaptiveTiming = {
    lastResponseTime = 0,
    averageLatency = 0.1,
    optimalDelays = {},
    successHistory = {}
}

-- Circuit Breaker Pattern
local circuitBreaker = {
    failureCount = 0,
    lastFailure = 0,
    state = "CLOSED",
    failureThreshold = 3,
    resetTimeout = 30
}

-- Resource Management
local resourceManager = {
    maxMemoryUsage = 100 * 1024 * 1024,
    maxThreads = 50,
    currentUsage = 0,
    lastCleanup = os.time()
}

-- Atomic counters
local atomicCounters = {
    chargeCount = {value = 0},
    workItems = {value = 0},
    fishCount = {value = 0}
}

-- ========== MODULE ASSIGNMENT ==========
Modules.Replion = ModulesTable.Replion
Modules.ItemUtility = ModulesTable.ItemUtility
Modules.FishingController = ModulesTable.FishingController
Modules.EquipToolEvent = ModulesTable.EquipToolEvent
Modules.ChargeRodFunc = ModulesTable.ChargeRodFunc
Modules.StartMinigameFunc = ModulesTable.StartMinigameFunc
Modules.CompleteFishingEvent = ModulesTable.CompleteFishingEvent

-- ========== ATOMIC OPERATIONS ==========
local function atomicIncrement(counter)
    if not counter or not counter.value then
        counter = {value = 0}
    end
    local result
    pcall(function()
        result = counter.value + 1
        counter.value = result
    end)
    return result or 0
end

-- ========== OPTIMIZED FISHING ROD MANAGEMENT ==========
local function equipFishingRod()
    if not hasEquippedRod and Modules.EquipToolEvent then
        local success = pcall(function()
            Modules.EquipToolEvent:FireServer(1)
        end)
        if success then
            hasEquippedRod = true
            print(" Fishing rod equipped successfully")
        else
            warn(" Failed to equip fishing rod")
        end
    end
end

-- ========== ADVANCED FISH DETECTION SYSTEM ==========
local function setupAdvancedFishDetection()
    local detectionMethods = {}
    
    print(" Initializing fish detection system...")

    -- Method 1: Direct Fish Caught Event (MOST RELIABLE)
    local function setupDirectFishCaught()
        local success, fishCaughtEvent = pcall(function()
            return ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net:WaitForChild("RE/FishCaught", 5)
        end)
        
        if success and fishCaughtEvent then
            local connection = fishCaughtEvent.OnClientEvent:Connect(function(fishName, data)
                print(" DIRECT FISH CAUGHT:", fishName or "Unknown Fish")
                atomicIncrement(atomicCounters.fishCount)
                performanceStats.fishCaught = performanceStats.fishCaught + 1
                fishCaughtBindable:Fire()
                
                if WindUI then
                    WindUI:Notify({
                        Title = "Fish Caught!",
                        Content = "OG Mode: " .. (fishName or "Unknown Fish"),
                        Duration = 2,
                        Icon = "fish"
                    })
                end
            end)
            table.insert(detectionMethods, connection)
            print(" Direct fish caught event initialized - MOST RELIABLE")
            return true
        else
            print(" FishCaught event not found, trying alternative methods...")
            return false
        end
    end

    -- Method 2: GUI Notification Detection (Fallback 1)
    local function setupGUINotificationDetection()
        local fallbackThread = task.spawn(function()
            local lastFishName = ""
            while featureState.AutoFish do
                task.wait(0.2) -- Check every 200ms
                
                pcall(function()
                    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                    if not playerGui then return end
                    
                    local notificationGui = playerGui:FindFirstChild("Small Notification")
                    if notificationGui and notificationGui.Enabled then
                        local container = notificationGui:FindFirstChild("Display")
                        if container then
                            local itemNameLabel = container:FindFirstChild("ItemName")
                            if itemNameLabel and itemNameLabel.Text ~= "" and itemNameLabel.Text ~= lastFishName then
                                lastFishName = itemNameLabel.Text
                                print(" Fish caught! (GUI detection): " .. lastFishName)
                                atomicIncrement(atomicCounters.fishCount)
                                performanceStats.fishCaught = performanceStats.fishCaught + 1
                                fishCaughtBindable:Fire()
                                
                                if WindUI then
                                    WindUI:Notify({
                                        Title = "Fish Caught!",
                                        Content = "GUI Detection: " .. lastFishName,
                                        Duration = 2,
                                        Icon = "fish"
                                    })
                                end
                            end
                        end
                    end
                end)
            end
        end)
        table.insert(detectionMethods, fallbackThread)
        print(" GUI notification detection initialized")
    end

    -- Method 3: Obtained New Fish Notification (Fallback 2)
    local function setupObtainedFishNotification()
        local success, obtainedEvent = pcall(function()
            return ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net:WaitForChild("RE/ObtainedNewFishNotification", 3)
        end)
        
        if success and obtainedEvent then
            local connection = obtainedEvent.OnClientEvent:Connect(function(itemId, player, data)
                if player == LocalPlayer then
                    print(" New fish obtained notification")
                    task.delay(0.5, function()
                        atomicIncrement(atomicCounters.fishCount)
                        performanceStats.fishCaught = performanceStats.fishCaught + 1
                        fishCaughtBindable:Fire()
                    end)
                end
            end)
            table.insert(detectionMethods, connection)
            print(" Obtained fish notification initialized")
        end
    end

    -- Initialize methods in order of reliability
    local directSuccess = setupDirectFishCaught()
    
    if not directSuccess then
        setupGUINotificationDetection()
        setupObtainedFishNotification()
        print(" Using fallback detection methods")
    end
    
    print(" Fish detection system initialized successfully")
    return detectionMethods
end

-- ========== ADAPTIVE TIMING SYSTEM ==========
local function calculateOptimalDelay(baseDelay)
    if not baseDelay or baseDelay <= 0 then
        return 0.01
    end
    
    local currentTime = os.clock()
    adaptiveTiming.lastResponseTime = currentTime
    
    -- Calculate adaptive delay berdasarkan success rate
    local successRate = 0
    if #adaptiveTiming.successHistory > 0 then
        local successes = 0
        for _, success in ipairs(adaptiveTiming.successHistory) do
            if success then successes = successes + 1 end
        end
        successRate = successes / #adaptiveTiming.successHistory
    end
    
    -- Adjust delay berdasarkan success rate
    local adaptiveFactor = 1.0
    if successRate > 0.9 then
        adaptiveFactor = 0.8  -- Lebih agresif jika success rate tinggi
    elseif successRate < 0.7 then
        adaptiveFactor = 1.2  -- Lebih konservatif jika success rate rendah
    end
    
    -- Add small random jitter untuk avoid detection
    local jitter = (math.random() * 0.04) - 0.02
    
    local optimalDelay = math.max(0.01, baseDelay * adaptiveFactor + jitter)
    
    -- Maintain history untuk adaptive learning
    table.insert(adaptiveTiming.successHistory, successRate > 0.8)
    if #adaptiveTiming.successHistory > 50 then
        table.remove(adaptiveTiming.successHistory, 1)
    end
    
    return optimalDelay
end

local function adaptiveWait(delay)
    if not delay or delay <= 0 then
        task.wait(0.01)
        return
    end
    local optimalDelay = calculateOptimalDelay(delay)
    task.wait(optimalDelay)
end

-- ========== CIRCUIT BREAKER SYSTEM ==========
local function executeWithCircuitBreaker(func, operationName)
    if not func then
        return nil, "No function provided"
    end
    
    if circuitBreaker.state == "OPEN" then
        if os.time() - circuitBreaker.lastFailure > circuitBreaker.resetTimeout then
            circuitBreaker.state = "HALF_OPEN"
            circuitBreaker.failureCount = 0
        else
            return nil, "Circuit breaker OPEN for " .. (operationName or "unknown")
        end
    end
    
    local success, result = pcall(func)
    
    if success then
        if circuitBreaker.state == "HALF_OPEN" then
            circuitBreaker.state = "CLOSED"
        end
        circuitBreaker.failureCount = 0
        
        -- Record success untuk adaptive timing
        table.insert(adaptiveTiming.successHistory, true)
        if #adaptiveTiming.successHistory > 50 then
            table.remove(adaptiveTiming.successHistory, 1)
        end
        
        return result
    else
        circuitBreaker.failureCount = circuitBreaker.failureCount + 1
        circuitBreaker.lastFailure = os.time()
        performanceStats.failures = performanceStats.failures + 1
        
        -- Record failure untuk adaptive timing
        table.insert(adaptiveTiming.successHistory, false)
        if #adaptiveTiming.successHistory > 50 then
            table.remove(adaptiveTiming.successHistory, 1)
        end
        
        if circuitBreaker.failureCount >= circuitBreaker.failureThreshold then
            circuitBreaker.state = "OPEN"
            warn("Circuit breaker TRIPPED for " .. (operationName or "unknown"))
        end
        
        return nil, result
    end
end

-- ========== RESOURCE MANAGEMENT ==========
local function manageResources()
    local currentTime = os.time()
    
    -- Periodic garbage collection dengan error handling
    if currentTime - resourceManager.lastCleanup > 30 then
        local success, result = pcall(function()
            return collectgarbage("collect")
        end)
        if success then
            resourceManager.lastCleanup = currentTime
        else
            print(" Garbage collection failed:", result)
        end
    end
    
    -- Memory usage monitoring dengan error handling
    local memoryUsage = 0
    local success, result = pcall(function()
        return collectgarbage("count")
    end)
    if success then
        memoryUsage = result * 1024
    end
    
    if memoryUsage > resourceManager.maxMemoryUsage * 0.8 then
        featureState.Instant_WorkerCount = math.max(1, featureState.Instant_WorkerCount - 1)
        
        -- Cleanup dengan pcall
        pcall(function()
            collectgarbage("collect")
        end)
        print(" Resource management: Reduced workers due to high memory usage")
    end
end

-- ========== OPTIMIZED FISHING SEQUENCE ==========
local function optimizedFishingSequence(sequenceId)
    return executeWithCircuitBreaker(function()
        local cycleStartTime = os.clock()
        
        -- Validasi module availability
        if not Modules.ChargeRodFunc or not Modules.StartMinigameFunc or not Modules.CompleteFishingEvent then
            return false, "Required modules not available"
        end
        
        -- 1. CHARGE ROD (FASTER)
        pcall(function()
            Modules.ChargeRodFunc:InvokeServer(nil, nil, nil, workspace:GetServerTimeNow())
        end)
        task.wait(0.05)  -- Reduced from featureState.Instant_ChargeDelay
        
        -- 2. START MINIGAME (FASTER)  
        pcall(function()
            Modules.StartMinigameFunc:InvokeServer(-139, 1, workspace:GetServerTimeNow())
        end)
        task.wait(0.8)   -- Reduced from featureState.Instant_StartDelay
        
        -- 3. SPAM COMPLETE FISHING (OPTIMIZED)
        for i = 1, featureState.Instant_SpamCount do
            if not featureState.AutoFish then break end
            
            pcall(function()
                Modules.CompleteFishingEvent:FireServer()
            end)
            
            -- Ultra fast spam - no delay between spams
        end
        
        -- 4. WAIT FOR FISH DETECTION (SHORTER TIMEOUT)
        local fishDetected = false
        local detectionStart = os.clock()

        local connection
        connection = fishCaughtBindable.Event:Connect(function()
            fishDetected = true
            if connection then connection:Disconnect() end
        end)

        -- SHORTER WAIT: 2.5 seconds instead of 4.0
        local maxWaitTime = 2.5
        
        while featureState.AutoFish and not fishDetected and (os.clock() - detectionStart) < maxWaitTime do
            task.wait(0.05)  -- Faster checking
        end

        if connection and connection.Connected then 
            connection:Disconnect() 
        end
        
        -- 5. STOP FISHING CLIENT (FASTER)
        pcall(function()
            if Modules.FishingController and Modules.FishingController.RequestClientStopFishing then
                Modules.FishingController:RequestClientStopFishing(true)
            end
        end)
        
        -- 6. UPDATE PERFORMANCE METRICS
        local cycleTime = os.clock() - cycleStartTime
        performanceStats.averageCycleTime = (performanceStats.averageCycleTime * performanceStats.cyclesCompleted + cycleTime) / (performanceStats.cyclesCompleted + 1)
        performanceStats.cyclesCompleted = performanceStats.cyclesCompleted + 1
        
        return true, fishDetected and "Fish caught" or "Timeout"
        
    end, "FishingSequence_" .. (sequenceId or "unknown"))
end

-- ========== DYNAMIC WORKER SYSTEM ==========
local function dynamicWorker(workerId)
    print(" Starting worker", workerId)
    
    while featureState.AutoFish do
        manageResources()
        
        local currentCount = atomicIncrement(atomicCounters.chargeCount)
        
        -- Reset counter jika mencapai target
        if currentCount >= featureState.Instant_ResetCount then
            atomicCounters.chargeCount.value = 0
            currentCount = 1
            print(" Worker", workerId, "reset counter for new cycle")
        end
        
        local success, result = optimizedFishingSequence(workerId .. "_" .. currentCount)
        
        if not success then
            print(" Worker", workerId, "failed:", result)
            adaptiveWait(0.5)  -- Backoff pada failure
        else
            print(" Worker", workerId, "completed cycle", currentCount, "-", result)
        end
        
        if not featureState.AutoFish then break end
        adaptiveWait(featureState.Instant_CycleDelay)
    end
    
    print(" Worker", workerId, "stopped")
end

-- ========== PERFORMANCE AUTO-TUNING ==========
local function updatePerformanceTuning()
    local currentTime = os.time()
    
    if currentTime - performanceStats.lastOptimization < 30 then
        return
    end
    
    performanceStats.lastOptimization = currentTime
    
    local efficiency = 0
    if performanceStats.cyclesCompleted > 0 then
        efficiency = (performanceStats.fishCaught / performanceStats.cyclesCompleted) * 100
    end
    
    -- Adaptive parameter tuning
    if efficiency < 70 then
        featureState.Instant_StartDelay = math.min(featureState.Instant_StartDelay * 1.1, 2.0)
        featureState.Instant_ChargeDelay = math.min(featureState.Instant_ChargeDelay * 1.05, 0.15)
        print(" Auto-tuning: Increased delays due to low efficiency", efficiency)
    elseif efficiency > 90 then
        featureState.Instant_StartDelay = math.max(featureState.Instant_StartDelay * 0.95, 0.5)
        featureState.Instant_ChargeDelay = math.max(featureState.Instant_ChargeDelay * 0.95, 0.03)
        print(" Auto-tuning: Decreased delays due to high efficiency", efficiency)
    end
    
    -- Adaptive worker count
    if performanceStats.averageCycleTime > 5.0 then
        featureState.Instant_WorkerCount = math.max(1, featureState.Instant_WorkerCount - 1)
        print(" Auto-tuning: Reduced workers due to slow cycle time", performanceStats.averageCycleTime)
    elseif performanceStats.averageCycleTime < 2.0 and featureState.Instant_WorkerCount < 5 then
        featureState.Instant_WorkerCount = featureState.Instant_WorkerCount + 1
        print(" Auto-tuning: Increased workers due to fast cycle time", performanceStats.averageCycleTime)
    end
    
    -- Reset stats untuk next cycle
    performanceStats.cyclesCompleted = 0
    performanceStats.fishCaught = 0
    performanceStats.failures = 0
    
    print(" Performance tuning completed - Efficiency:", string.format("%.1f%%", efficiency))
end

-- ========== OPTIMIZED WORKER MANAGEMENT ==========
local function startOptimizedAutoFish()
    print(" Starting optimized auto fish system...")
    
    -- Validasi module availability
    if not Modules.ChargeRodFunc then
        warn(" ChargeRodFunc module not available")
        return false
    end
    if not Modules.StartMinigameFunc then
        warn(" StartMinigameFunc module not available")  
        return false
    end
    if not Modules.CompleteFishingEvent then
        warn(" CompleteFishingEvent module not available")
        return false
    end
    
    print(" All modules validated successfully")

    featureState.AutoFish = true
    atomicCounters.chargeCount.value = 0
    atomicCounters.workItems.value = 0
    
    -- Reset performance stats
    performanceStats.cyclesCompleted = 0
    performanceStats.fishCaught = 0
    performanceStats.failures = 0
    performanceStats.startTime = os.time()
    
    -- Setup advanced detection
    local detectionConnections = setupAdvancedFishDetection()
    
    -- Main control thread
autoFishThread = task.spawn(function()
    print(" Main control thread started")
    
    while featureState.AutoFish do
        -- Reset counter setiap cycle baru
        atomicCounters.chargeCount.value = 0
        
        -- Dynamic worker scaling
        local targetWorkers = featureState.Instant_WorkerCount
        
        print(" Starting", targetWorkers, "workers for continuous fishing")
        
        -- Start workers
        local workerThreads = {}
        for i = 1, targetWorkers do
            if not featureState.AutoFish then break end
            local workerThread = task.spawn(dynamicWorker, i)
            table.insert(workerThreads, workerThread)
            table.insert(fishingTrove, workerThread)
        end
        
        -- Continuous operation - tidak ada wait for completion
        while featureState.AutoFish do
            task.wait(1)  -- Check setiap 1 detik jika masih aktif
            
            -- Auto resource management
            manageResources()
        end
        
        -- Stop semua workers ketika AutoFish false
        for _, thread in ipairs(workerThreads) do
            if thread and coroutine.status(thread) ~= "dead" then
                task.cancel(thread)
            end
        end
    end
    
    print(" Main control thread stopped")
    
    -- Cleanup detection connections
    for _, conn in ipairs(detectionConnections) do
        if typeof(conn) == "RBXScriptConnection" then
            pcall(conn.Disconnect, conn)
        elseif typeof(conn) == "thread" then
            pcall(task.cancel, conn)
        end
    end
end)
    
    table.insert(fishingTrove, autoFishThread)
    print(" Optimized auto fish system started successfully")
    return true
end

-- ========== OPTIMIZED STOP FUNCTION ==========
local function stopAutoFishProcesses()
    print(" Stopping all auto fish processes...")
    
    featureState.AutoFish = false
    hasEquippedRod = false
    
    circuitBreaker.state = "CLOSED"
    circuitBreaker.failureCount = 0
    
    -- Cancel semua threads
    for i, item in ipairs(fishingTrove) do
        if typeof(item) == "RBXScriptConnection" then
            pcall(item.Disconnect, item)
        elseif typeof(item) == "thread" then
            pcall(task.cancel, item)
        end
    end
    
    fishingTrove = {}
    
    -- Reset atomic counters
    atomicCounters.chargeCount.value = 0
    atomicCounters.workItems.value = 0
    atomicCounters.fishCount.value = 0
    
    -- Request stop fishing
    pcall(function()
        if Modules.FishingController and Modules.FishingController.RequestClientStopFishing then
            Modules.FishingController:RequestClientStopFishing(true)
        end
    end)
    
    print(" All auto fish processes stopped")
end

-- ========== MAIN CONTROL FUNCTION ==========
local function startOrStopAutoFish(shouldStart)
    if shouldStart then
        print(" Starting auto fish...")
        stopAutoFishProcesses()
        featureState.AutoFish = true
        
        -- Equip rod
        equipFishingRod()
        adaptiveWait(0.1)
        
        -- Start optimized system
        local success = startOptimizedAutoFish()
        
        if success then
            if WindUI then
                WindUI:Notify({
                    Title = "AutoFish Started",
                    Content = "Optimized OG Mode activated with adaptive timing",
                    Duration = 5,
                    Icon = "circle-check"
                })
            end
        else
            if WindUI then
                WindUI:Notify({
                    Title = "AutoFish Error",
                    Content = "Failed to start optimized fishing system",
                    Duration = 5,
                    Icon = "alert-circle"
                })
            end
        end
    else
        print(" Stopping auto fish...")
        stopAutoFishProcesses()
        if WindUI then
            WindUI:Notify({
                Title = "AutoFish Stopped", 
                Content = "OG Mode deactivated",
                Duration = 3,
                Icon = "pause-circle"
            })
        end
    end
end

-- ========== OPTIMIZED ANIMATION DISABLER ==========
local stopAnimConnections = {}
local function setGameAnimationsEnabled(state)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then 
        warn(" Humanoid not found for animation disabler")
        return 
    end

    -- Cleanup previous connections
    for _, conn in pairs(stopAnimConnections) do
        if conn and typeof(conn) == "RBXScriptConnection" then
            pcall(conn.Disconnect, conn)
        end
    end
    stopAnimConnections = {}

    if state then
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            -- Stop current animations
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                pcall(track.Stop, track, 0)
            end

            -- Prevent new animations
            local conn = animator.AnimationPlayed:Connect(function(track)
                task.defer(function()
                    pcall(track.Stop, track, 0)
                end)
            end)
            table.insert(stopAnimConnections, conn)
        end

        if WindUI then
            WindUI:Notify({
                Title = "Animation Disabled",
                Content = "All animations have been disabled for optimal performance",
                Duration = 3,
                Icon = "pause-circle"
            })
        end
    else
        if WindUI then
            WindUI:Notify({
                Title = "Animation Enabled", 
                Content = "Game animations have been reactivated",
                Duration = 3,
                Icon = "play-circle"
            })
        end
    end
end

print(" OPTIMIZED X5 Speed System Initialized Successfully!")

-------------------------------------------
----- =======[ NOTIFY FUNCTION ]
-------------------------------------------

local function NotifySuccess(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "circle-check"
    })
end

local function NotifyError(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "ban"
    })
end

local function NotifyInfo(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "info"
    })
end

local function NotifyWarning(title, message, duration)
    WindUI:Notify({
        Title = title,
        Content = message,
        Duration = duration,
        Icon = "triangle-alert"
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


-------------------------------------------
----- =======[ LOAD WINDOW ]
-------------------------------------------


WindUI:AddTheme({
    Name = "Royal Void",
    Accent = WindUI:Gradient({
        ["0"]   = { Color = Color3.fromHex("#FF3366"), Transparency = 0 },  -- Merah Cerah
        ["50"]  = { Color = Color3.fromHex("#1E90FF"), Transparency = 0 },  -- biru Cerah
        ["100"] = { Color = Color3.fromHex("#9B30FF"), Transparency = 0 },  -- Ungu Terang
    }, {
        Rotation = 45,
    }),

    Dialog = Color3.fromHex("#0A0011"),         -- Latar hitam ke ungu gelap
    Outline = Color3.fromHex("#1E90FF"),        -- Pinggir biru Cerah
    Text = Color3.fromHex("#FFE6FF"),           -- Putih ke ungu muda
    Placeholder = Color3.fromHex("#B34A7F"),    -- Ungu-merah pudar
    Background = Color3.fromHex("#050008"),     -- Hitam pekat dengan nuansa ungu
    Button = Color3.fromHex("#FF00AA"),         -- Merah ke ungu neon
    Icon = Color3.fromHex("#0066CC")            -- Aksen biru
})
WindUI.TransparencyValue = 0.2

local Window = WindUI:CreateWindow({
    Title = "OGhub",
    Icon = "moon",
    Author = "Free To Use",
    Folder = "OGhub",
    Size = UDim2.fromOffset(400, 200),
    Transparent = true,
    Theme = "Royal Void",
    KeySystem = false,
    ScrollBarEnabled = true,
    HideSearchBar = true,
    NewElements = true,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function() end,
    }
})

Window:EditOpenButton({
    Title = "OGhub",
   Icon = "moon",
    CornerRadius = UDim.new(0,30),
    StrokeThickness = 2,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("#FF3366")), -- Merah
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("#1E90FF")), -- biru
        ColorSequenceKeypoint.new(1, Color3.fromHex("#9B30FF")) -- Ungu
    }),
    Draggable = true,
})

local ConfigManager = Window.ConfigManager
local myConfig = ConfigManager:CreateConfig("SansXConfig")

WindUI:SetNotificationLower(true)

WindUI:Notify({
    Title = "OGhub",
    Content = "All Features Loaded!",
    Duration = 5,
    Image = "square-check-big"
})

-------------------------------------------
----- =======[ ALL TAB ]
-------------------------------------------

local Home = Window:Tab({
    Title = "About Me",
    Icon = "hard-drive"
})

local AutoFish = Window:Tab({
    Title = "Auto Fishing",
    Icon = "fish"
})

local X5SpeedTab = Window:Tab({
    Title = "OG Mode",
    Icon = "zap"
})

local AutoFarmArt = Window:Tab({
    Title = "Auto Farm Artifact",
    Icon = "flask-round"
})

local Player = Window:Tab({
    Title = "Player",
    Icon = "users-round"
})

local Teleport = Window:Tab({
    Title = "Teleport",
    Icon = "search"
})

local Trade = Window:Tab({
    Title = "Trade",
    Icon = "handshake"
})

local AutoFav = Window:Tab({
    Title = "Auto Favorite",
    Icon = "heart"
})

local Shop = Window:Tab({
    Title = "Shop",
    Icon = "plus"
})

local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "cog"
})

_G.ServerPage = Window:Tab({
    Title = "Server List",
    Icon = "server"
})

-------------------------------------------
----- =======[ HOME TAB ]
-------------------------------------------

Home:Section({
	Title = "Attention!",
	TextSize = 22,
	TextXAlignment = "Center",
})

Home:Paragraph({
	Title = "⚠️OGhub⚠️",
	Color = "Blue",
	Desc = [[
Thanks For Using This Script.
No More Premium Script.
Everyone Can Used !!.
Keep OG Fams..
]]
})

Home:Space()

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

-------------------------------------------
----- =======[ SERVER PAGE TAB ]
-------------------------------------------

_G.ServerList = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" ..
game.PlaceId .. "/servers/Private?sortOrder=Asc&limit=100"))

_G.ButtonList = {}

_G.ServerListAll = _G.ServerPage:Section({
    Title = "All Server List",
    TextSize = 22,
    TextXAlignment = "Center"
})

_G.ShowServersButton = _G.ServerListAll:Button({
    Title = "Show Server List",
    Desc = "Klik untuk menampilkan daftar server yang tersedia.",
    Locked = false,
    Icon = "",
    Callback = function()
        if _G.ServersShown then return end
        _G.ServersShown = true

        for _, server in ipairs(_G.ServerList.data) do
            _G.playerCount = string.format("%d/%d", server.playing, server.maxPlayers)
            _G.ping = server.ping
            _G.id = server.id

            local buttonServer = _G.ServerListAll:Button({
                Title = "Server",
                Desc = "Player: " .. tostring(_G.playerCount) .. "\nPing: " .. tostring(_G.ping),
                Locked = false,
                Icon = "",
                Callback = function()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, _G.id,
                        game.Players.LocalPlayer)
                end
            })

            buttonServer:SetTitle("Server")
            buttonServer:SetDesc("Player: " .. tostring(_G.playerCount) .. "\nPing: " .. tostring(_G.ping))

            table.insert(_G.ButtonList, buttonServer)
        end

        if #_G.ButtonList == 0 then
            _G.ServerListAll:Button({
                Title = "No Servers Found",
                Desc = "Tidak ada server yang ditemukan.",
                Locked = true,
                Callback = function() end
            })
        end
    end
})

-------------------------------------------
----- =======[ AUTO FISH TAB ]
-------------------------------------------

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
_G.REObtainedNewFishNotification = ReplicatedStorage
    .Packages._Index["sleitnick_net@0.2.0"]
    .net["RE/ObtainedNewFishNotification"]


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

function _G.RecastSpam()
    if _G.rSpamming then return end
    _G.rSpamming = true
    _G.rspamThread = task.spawn(function()
        while _G.rSpamming do
            local ok, err = pcall(StartCast5X)
            if not ok then
                warn("StartCast5X error:", err)
                break
            end
        end
    end)
end

function _G.StopRecastSpam()
    _G.rSpamming = false
end
    

function _G.startSpam()
    if _G.isSpamming then return end
    _G.isSpamming = true
    _G.spamThread = task.spawn(function()
    while _G.isSpamming do
        task.wait(tonumber(_G.FINISH_DELAY))
        finishRemote:FireServer()
        end
    end)
end
    
function _G.stopSpam()
   _G.isSpamming = false
end

_G.REPlayFishingEffect.OnClientEvent:Connect(function(player, head, data)
    if player == Players.LocalPlayer and FuncAutoFish.autofish5x then
        _G.StopRecastSpam()
    end
end)


_G.REObtainedNewFishNotification.OnClientEvent:Connect(function(...)
    _G.lastFishTime = tick()
end)

task.spawn(function()
	while task.wait(1) do
		if _G.AntiStuckEnabled then
			if tick() - _G.lastFishTime > tonumber(_G.STUCK_TIMEOUT) then
				StopAutoFish5X()
				task.wait(0.5)
				StartAutoFish5X()
				_G.lastFishTime = tick()
			end
		end
	end
end)

FuncAutoFish.REReplicateTextEffect.OnClientEvent:Connect(function(data)
    if FuncAutoFish.autofish5x 
    and data and data.TextData 
    and data.TextData.EffectType == "Exclaim" then
    	local myHead = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("Head")
    	if myHead and data.Container == myHead then
    		_G.startSpam()
    	end
    end
end)

_G.REFishCaught.OnClientEvent:Connect(function(fishName, info)
    if FuncAutoFish.autofish5x then
        _G.stopSpam()
        _G.StopFishing()
        _G.RecastSpam()
    end
end)

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

function StopCast()
    _G.StopFishing()
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

--[[

INI AUTO FISH LEGIT 

]]


_G.RunService = game:GetService("RunService")
_G.ReplicatedStorage = game:GetService("ReplicatedStorage")
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

_G.originalAutoFishingStateChanged = _G.AutoFishingController.AutoFishingStateChanged
function _G.forceActiveVisual(arg1)
    _G.originalAutoFishingStateChanged(true)
end

_G.AutoFishingController.AutoFishingStateChanged = _G.forceActiveVisual

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

        if success then
        else
        end
    else
    end
end

-- ===================================================================
-- BAGIAN 2: AUTO CLICK MINIGAME
-- ===================================================================

_G.originalRodStarted = _G.FishingController.FishingRodStarted
_G.originalFishingStopped = _G.FishingController.FishingStopped
_G.clickThread = nil

-- Hook FishingRodStarted (Minigame Aktif)
_G.FishingController.FishingRodStarted = function(self, arg1, arg2)
    _G.originalRodStarted(self, arg1, arg2)

    if _G.AutoFishState.IsActive and not _G.AutoFishState.MinigameActive then
        _G.AutoFishState.MinigameActive = true

        if _G.clickThread then
            task.cancel(_G.clickThread)
        end

        _G.clickThread = task.spawn(function()
            while _G.AutoFishState.IsActive and _G.AutoFishState.MinigameActive do
                _G.performClick()
            end
        end)
    end
end

_G.FishingController.FishingStopped = function(self, arg1)
    _G.originalFishingStopped(self, arg1)

    if _G.AutoFishState.MinigameActive then
        _G.AutoFishState.MinigameActive = false
        task.wait(1)
        _G.ensureServerAutoFishingOn()
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

_G.FishSec = AutoFish:Section({
    Title = "Auto Fishing",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = true
})

_G.FishSec:Slider({
    Title = "Delay Finish",
    Desc = [[
Delay Settings
]],
    Step = 0.01,
    Value = {
        Min = 0.01,
        Max = 5,
        Default = _G.FINISH_DELAY,
    },
    Callback = function(value)
        _G.FINISH_DELAY = value
    end
})

_G.AutoFishes = _G.FishSec:Toggle({
    Title = "Auto Fish Instant",
    Callback = function(value)
        if value then
            StartAutoFish5X()
        else
            StopAutoFish5X()
        end
    end
})

_G.FishSec:Space()

_G.RecastCD = _G.FishSec:Slider({
    Title = "Speed Legit",
    Step = 0.01,
    Value = {
        Min = 0.01,
        Max = 5,
        Default = _G.SPEED_LEGIT,
    },
    Callback = function(value)
        _G.SPEED_LEGIT = value
    end
})

_G.FishSec:Toggle({
    Title = "Auto Fish Legit",
    Value = false,
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

_G.FishSec:Space()

_G.FishSec:Slider({
    Title = "Sell Threshold",
    Step = 1,
    Value = {
        Min = 1,
        Max = 6000,
        Default = 30,
    },
    Callback = function(value)
        _G.obtainedLimit = value
    end
})

_G.FishSec:Slider({
    Title = "Anti Stuck Delay",
    Step = 1,
    Value = {
        Min = 1,
        Max = 6000,
        Default = _G.STUCK_TIMEOUT,
    },
    Callback = function(value)
        _G.STUCK_TIMEOUT = value
    end
})

_G.FishSec:Toggle({
    Title = "Auto Sell",
    Value = false,
    Callback = function(state)
        _G.sellActive = state
        if state then
            NotifySuccess("Auto Sell", "Limit: " .. _G.obtainedLimit)
        else
            NotifySuccess("Auto Sell", "Disabled")
        end
    end
})

_G.FishSec:Toggle({
	Title = "Anti Stuck",
	Value = false,
	Callback = function(state)
		_G.AntiStuckEnabled = state
	end
})


_G.FishSec:Space()


_G.FishSec:Button({
    Title = "Stop Fishing",
    Locked = false,
    Justify = "Center",
    Icon = "",
    Callback = function()
        _G.StopFishing()
        RodIdle:Stop()
        RodIdle:Stop()
        _G.stopSpam()
        _G.StopRecastSpam()
    end
})

-------------------------------------------
----- =======[ X5 SPEED TAB ]
-------------------------------------------

X5SpeedTab:Section({ Title = "OG MODE Settings", Opened = true })

local startDelaySlider = X5SpeedTab:Slider({
    Title = "Delay Recast",
    Desc = "(Default: 1.20)",
    Value = { Min = 0.00, Max = 5.0, Default = featureState.Instant_StartDelay },
    Precise = 2,
    Step = 0.01,
    Callback = function(v)
        featureState.Instant_StartDelay = tonumber(v)
    end
})
myConfig:Register("Instant_StartDelay", startDelaySlider)

local resetCountSlider = X5SpeedTab:Slider({
    Title = "Spam Finish",
    Desc = "(Default: 5)",
    Value = { Min = 5, Max = 50, Default = featureState.Instant_ResetCount },
    Precise = 0,
    Step = 1,
    Callback = function(v)
        local num = math.floor(tonumber(v) or 10)
        featureState.Instant_ResetCount = num
    end
})
myConfig:Register("Instant_ResetCount", resetCountSlider)

local resetPauseSlider = X5SpeedTab:Slider({
    Title = "Cooldown Recast",
    Desc = "(Default: 0.10)",
    Value = { Min = 0.01, Max = 5, Default = featureState.Instant_ResetPause },
    Precise = 2,
    Step = 0.01,
    Callback = function(v)
        local num = tonumber(v) or 2.0
        featureState.Instant_ResetPause = num
    end
})
myConfig:Register("Instant_ResetPause", resetPauseSlider)

X5SpeedTab:Section({ Title = "AutoFish OG Mode Speed", Opened = true })

local autoFishToggle = X5SpeedTab:Toggle({
    Title = "AutoFish OG Mode [OPTIMIZED]",
    Desc = "Enhanced with adaptive timing & performance monitoring",
    Value = false,
    Callback = startOrStopAutoFish
})
myConfig:Register("AutoFish", autoFishToggle)

X5SpeedTab:Space()

local gameAnimToggle = X5SpeedTab:Toggle({
    Title = "No Animation",
    Desc = "Stop all animations from the game.",
    Value = false,
    Callback = function(v)
        setGameAnimationsEnabled(v)
    end
})
myConfig:Register("DisableGameAnimations", gameAnimToggle)

print(" X5 Speed Tab Loaded!")

X5SpeedTab:Section({ Title = "Performance Stats", Opened = false })

local performanceDisplay = X5SpeedTab:Paragraph({
    Title = "Real-time Stats",
    Desc = "Waiting for data...",
    Color = "Blue"
})

-- Auto-update performance display
task.spawn(function()
    while task.wait(2) do
        if featureState.AutoFish then
            local efficiency = performanceStats.cyclesCompleted > 0 and 
                (performanceStats.fishCaught / performanceStats.cyclesCompleted) * 100 or 0
            
            performanceDisplay:SetDesc(string.format(
                "Cycles: %d | Fish: %d | Efficiency: %.1f%%\nAvg Time: %.2fs | Failures: %d\nWorkers: %d | Adaptive Delay: %.3fs",
                performanceStats.cyclesCompleted,
                performanceStats.fishCaught,
                efficiency,
                performanceStats.averageCycleTime,
                performanceStats.failures,
                featureState.Instant_WorkerCount,
                calculateOptimalDelay(featureState.Instant_StartDelay)
            ))
        end
    end
end)

-------------------------------------------
----- =======[ PLAYER TAB ]
-------------------------------------------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

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

Player:Space()

Player:Toggle({
    Title = "Hide Name",
    Desc = "Hide name above character",
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

Player:Toggle({
    Title = "Unlimited Zoom",
    Desc = "Unlimited Camera Zoom for take a Picture",
    Value = false,
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

Player:Space()

Player:Button({
    Title = "Access All Boats",
    Justify = "Center",
    Icon = "",
    Callback = accessAllBoats
})

Player:Space()

Player:Toggle({
    Title = "Infinity Jump",
    Callback = function(val)
        ijump = val
    end,
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if ijump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

local EnableFloat = Player:Toggle({
    Title = "Enable Float",
    Value = false,
    Callback = function(enabled)
        floatingPlat(enabled)
    end,
})

myConfig:Register("ActiveFloat", EnableFloat)

local universalNoclip = false
local originalCollisionState = {}

local NoClip = Player:Toggle({
    Title = "Universal No Clip",
    Value = false,
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

game:GetService("RunService").Stepped:Connect(function()
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

    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChildWhichIsA("VehicleSeat", true) then
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide == true then
                    originalCollisionState[part] = true
                    part.CanCollide = false
                end
            end
        end
    end
end)

myConfig:Register("NoClip", NoClip)

local AntiDrown_Enabled = false
local rawmt = getrawmetatable(game)
setreadonly(rawmt, false)
local oldNamecall = rawmt.__namecall

rawmt.__namecall = newcclosure(function(self, ...)
    local args = { ... }
    local method = getnamecallmethod()

    if tostring(self) == "URE/UpdateOxygen" and method == "FireServer" and AntiDrown_Enabled then
        return nil
    end

    return oldNamecall(self, ...)
end)

local DrownBN = true

local ADrown = Player:Toggle({
    Title = "Anti Drown (Oxygen Bypass)",
    Callback = function(state)
        AntiDrown_Enabled = state
        if DrownBN then
            DrownBN = false
            return
        end
        if state then
            NotifySuccess("Anti Drown Active", "Oxygen loss has been blocked.", 3)
        else
            NotifyWarning("Anti Drown Disabled", "You're vulnerable to drowning again.", 3)
        end
    end,
})

myConfig:Register("AntiDrown", ADrown)

local Speed = Player:Slider({
    Title = "WalkSpeed",
    Value = {
        Min = 16,
        Max = 200,
        Default = 20
    },
    Step = 1,
    Callback = function(val)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = val end
    end,
})

myConfig:Register("PlayerSpeed", Speed)

local Jp = Player:Slider({
    Title = "Jump Power",
    Value = {
        Min = 50,
        Max = 500,
        Default = 35
    },
    Step = 10,
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

myConfig:Register("JumpPower", Jp)


-------------------------------------------
----- =======[ TELEPORT TAB ]
-------------------------------------------

local PLAYERS = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local currentDropdown = nil

local function getPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.DisplayName)
        end
    end
    return list
end


local function teleportToPlayerExact(target)
    local characters = workspace:FindFirstChild("Characters")
    if not characters then return end

    local targetChar = characters:FindFirstChild(target)
    local myChar = characters:FindFirstChild(LocalPlayer.Name)

    if targetChar and myChar then
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        local myHRP = myChar:FindFirstChild("HumanoidRootPart")
        if targetHRP and myHRP then
            myHRP.CFrame = targetHRP.CFrame + Vector3.new(2, 0, 0)
        end
    end
end

local function refreshDropdown()
    if currentDropdown then
        currentDropdown:Refresh(getPlayerList())
    end
end

currentDropdown = Teleport:Dropdown({
    Title = "Teleport to Player",
    Desc = "Select player to teleport",
    Values = getPlayerList(),
    SearchBarEnabled = true,
    Callback = function(selectedDisplayName)
        for _, p in pairs(Players:GetPlayers()) do
            if p.DisplayName == selectedDisplayName then
                teleportToPlayerExact(p.Name)
                NotifySuccess("Teleport Successfully", "Successfully Teleported to " .. p.DisplayName .. "!", 3)
                break
            end
        end
    end
})

Players.PlayerAdded:Connect(function()
    task.delay(0.1, refreshDropdown)
end)

Players.PlayerRemoving:Connect(function()
    task.delay(0.1, refreshDropdown)
end)

refreshDropdown()

Teleport:Space()

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

Teleport:Dropdown({
    Title = "Island Selector",
    Desc = "Select island to teleport",
    Values = islandNames,
    Value = islandNames[1],
    SearchBarEnabled = true,
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

Teleport:Dropdown({
    Title = "Teleport Event",
    Values = eventsList,
    Value = "Shark Hunt",
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
                    WindUI:Notify({
                        Title = "Event Available!",
                        Content = "Teleported To " .. option,
                        Icon = "circle-check",
                        Duration = 3
                    })
                end
            else
                WindUI:Notify({
                    Title = "Event Not Found",
                    Content = option .. " Not Found!",
                    Icon = "ban",
                    Duration = 3
                })
            end
        else
            WindUI:Notify({
                Title = "Event Not Found",
                Content = option .. " Not Found!",
                Icon = "ban",
                Duration = 3
            })
        end
    end
})

local TweenService = game:GetService("TweenService")

local HRP = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

local Items = ReplicatedStorage:WaitForChild("Items")
local Baits = ReplicatedStorage:WaitForChild("Baits")
local net = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")


local npcCFrame = CFrame.new(
    66.866745, 4.62500143, 2858.98535,
    -0.981261611, 5.77215005e-08, -0.192680314,
    6.94250204e-08, 1, -5.39889484e-08,
    0.192680314, -6.63541186e-08, -0.981261611
)


local function FadeScreen(duration)
    local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame", gui)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 0.1

    local tweenIn = TweenService:Create(frame, TweenInfo.new(0.2), { BackgroundTransparency = 0.1 })
    tweenIn:Play()
    tweenIn.Completed:Wait()

    wait(duration)

    local tweenOut = TweenService:Create(frame, TweenInfo.new(0.3), { BackgroundTransparency = 0.1 })
    tweenOut:Play()
    tweenOut.Completed:Wait()
    gui:Destroy()
end

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


Teleport:Dropdown({
    Title = "NPC",
    Desc = "Select NPC to Teleport",
    Values = npcList,
    Value = nil,
    SearchBarEnabled = true,
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
-------------------------------------------
----- =======[ MASS TRADE TAB ]
-------------------------------------------

-- [Trade State Baru]
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

-- [Cache & Utility untuk Mode V2]
local inventoryCache = {}
local fullInventoryDropdownList = {}

-- Asumsi Modul game inti sudah tersedia (seperti Replion)
local ItemUtility = _G.ItemUtility or require(ReplicatedStorage.Shared.ItemUtility) 
local ItemStringUtility = _G.ItemStringUtility or require(ReplicatedStorage.Modules.ItemStringUtility)
local InitiateTrade = net:WaitForChild("RF/InitiateTrade") 
local RFAwaitTradeResponse = net:WaitForChild("RF/AwaitTradeResponse") 

-- Fungsi utilitas untuk mendapatkan daftar pemain
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

-- =======================================================
-- LOGIKA PEMBARUAN INVENTARIS 
-- =======================================================

local function refreshInventory()
    local DataReplion = _G.Replion.Client:WaitReplion("Data")
    if not DataReplion or not ItemUtility or not ItemStringUtility then 
        warn("Cannot refresh inventory: Missing modules.")
        return 
    end
    
    local inventoryItems = DataReplion:Get({ "Inventory", "Items" })
    local groupedItems = {}
    inventoryCache = {}
    fullInventoryDropdownList = {}

    if not inventoryItems then return end

    for _, itemData in ipairs(inventoryItems) do
        local baseItemData = ItemUtility:GetItemData(itemData.Id)
        
        if baseItemData and baseItemData.Data and (baseItemData.Data.Type == "Fish" or baseItemData.Data.Type == "Enchant Stones") then
            -- Filter Unfavorited (Mode V2)
            if not (tradeState.filterUnfavorited and itemData.Favorited) then
                local dynamicName = ItemStringUtility.GetItemName(itemData, baseItemData)
                if not groupedItems[dynamicName] then
                    groupedItems[dynamicName] = 0
                    inventoryCache[dynamicName] = {}
                end
                groupedItems[dynamicName] = (groupedItems[dynamicName] or 0) + 1
                table.insert(inventoryCache[dynamicName], itemData.UUID)
            end
        end
    end

    for name, count in pairs(groupedItems) do
        table.insert(fullInventoryDropdownList, string.format("%s (%dx)", name, count))
    end
    table.sort(fullInventoryDropdownList)

    -- Perbarui Dropdown Item dan Pemain
    if _G.InventoryDropdown then _G.InventoryDropdown:Refresh(fullInventoryDropdownList) end
    if _G.PlayerDropdownTrade then _G.PlayerDropdownTrade:Refresh(getPlayerListV2()) end
end

-- =======================================================
-- LOGIKA HOOKING
-- =======================================================

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)
_G.REEquipItem = game:GetService("ReplicatedStorage").Packages._Index["sleitnick_net@0.2.0"].net["RE/EquipItem"]


mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    -- Logika Save/Send Trade Original (Mode Quiet)
    if method == "FireServer" and self == _G.REEquipItem then
        local uuid, categoryName = args[1], args[2]

        if tradeState.mode == "V1" and tradeState.saveTempMode then
            if uuid and categoryName then
                table.insert(tradeState.TempTradeList, {
                    UUID = uuid,
                    Category = categoryName
                })
                NotifySuccess("Save Mode", "Added item: " .. uuid .. " (" .. categoryName .. ")")
            else
                NotifyError("Save Mode", "Invalid data received.")
            end
            return nil
        end

        if tradeState.mode == "V1" and tradeState.onTrade then
            if uuid and tradeState.selectedPlayerId then
                InitiateTrade:InvokeServer(tradeState.selectedPlayerId, uuid)
                NotifySuccess("Trade Sent", "Trade sent to " .. tradeState.selectedPlayerName or tradeState.selectedPlayerId)
            else
                NotifyError("Trade Error", "Invalid target or item.")
            end
            return nil
        end
    end

	if _G.autoSellMythic 
		and method == "FireServer"
		and self == _G.REEquipItem 
		and typeof(args[1]) == "string"
		and args[2] == "Fishes" then

		local uuid = args[1]

		task.delay(1, function()
			pcall(function()
				local result = RFSellItem:InvokeServer(uuid)
				if result then
					NotifySuccess("AutoSellMythic", "Items Sold!!")
				else
					NotifyError("AutoSellMythic", "Failed to sell item!!")
				end
			end)
		end)
	end
    
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- Implementasi Auto Accept Trade
pcall(function()
    local PromptController = _G.PromptController or ReplicatedStorage:WaitForChild("Controllers").PromptController 
    local Promise = _G.Promise or require(ReplicatedStorage.Packages.Promise) 
    
    if PromptController and PromptController.FirePrompt then
        local oldFirePrompt = PromptController.FirePrompt
        PromptController.FirePrompt = function(self, promptText, ...)
            -- Cek apakah Auto Accept aktif dan prompt adalah Trade
            if _G.AutoAcceptTradeEnabled and type(promptText) == "string" and promptText:find("Accept") and promptText:find("from:") then
                -- Mengembalikan Promise yang otomatis me-resolve (menerima) setelah jeda.
                return Promise.new(function(resolve)
                    task.wait(2) -- Tunggu 2 detik
                    resolve(true)
                end)
            end
            return oldFirePrompt(self, promptText, ...)
        end
    end
end)


-- =======================================================
-- DEFINISI UI
-- =======================================================

Trade:Section({Title = "Trade Mode Selection"})

local modeDropdown = Trade:Dropdown({
    Title = "Select Trade Mode",
    Values = {"V1", "V2"},
    Value = "V1",
    Callback = function(v)
        tradeState.mode = v
        NotifySuccess("Mode Changed", "Trade mode set to: " .. v, 3)
        local isQuiet = v == "Quiet"
        if _G.TradeV2Elements then
            for _, element in ipairs(_G.TradeV2Elements) do
                if element.Element then element.Element.Visible = not isQuiet end
            end
        end
        if _G.TradeQuietElements then
            for _, element in ipairs(_G.TradeQuietElements) do
                if element.Element then element.Element.Visible = isQuiet end
            end
        end
    end
})

local playerDropdown = Trade:Dropdown({
    Title = "Select Trade Target",
    Values = getPlayerListV2(),
    Value = getPlayerListV2()[1] or nil,
    SearchBarEnabled = true,
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
_G.PlayerDropdownTrade = playerDropdown -- Simpan referensi untuk refresh

Trade:Section({Title = "Auto Accept Trade"})

Trade:Toggle({
    Title = "Enable Auto Accept Trade",
    Desc = "Automatically accepts incoming trade requests.",
    Value = false,
    Callback = function(value)
        _G.AutoAcceptTradeEnabled = value
        if value then
            NotifySuccess("Auto Accept", "Auto accept trade enabled.", 3)
        else
            NotifyWarning("Auto Accept", "Auto accept trade disabled.", 3)
        end
    end
})

Trade:Section({Title = "Mode V1"})
_G.TradeQuietElements = {}

-- Toggle Mode Save Items (Mode V1)
local saveModeToggle = Trade:Toggle({
    Title = "Mode Save Items",
    Desc = "Click inventory item to add for Mass Trade",
    Value = false,
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
table.insert(_G.TradeQuietElements, {Element = saveModeToggle})

-- Toggle Trade (Original Send) (V1)
local originalTradeToggle = Trade:Toggle({
    Title = "Trade (Original Send)",
    Desc = "Click inventory items to Send Trade",
    Value = false,
    Callback = function(state)
        tradeState.onTrade = state
        if state then
            NotifySuccess("Trade", "Trade Mode Enabled. Click an item to send trade.")
        else
            NotifyWarning("Trade", "Trade Mode Disabled.")
        end
    end
})
table.insert(_G.TradeQuietElements, {Element = originalTradeToggle})

-- Fungsi Trade All (Mode V1)
local function TradeAllQuiet()       
    if not tradeState.selectedPlayerId then    
        NotifyError("Mass Trade", "Set trade target first!")       
        return         
    end          
    if #tradeState.TempTradeList == 0 then       
        NotifyWarning("Mass Trade", "No items saved!")          
        return         
    end          
    
    NotifyInfo("Mass Trade", "Starting V1 trade of "..#tradeState.TempTradeList.." items...")      
    
    task.spawn(function()          
        for i, item in ipairs(tradeState.TempTradeList) do          
            if not tradeState.autoTradeV2 then
                NotifyWarning("Mass Trade", "V1 Trade stopped!")         
                break          
            end          
        
            local uuid = item.UUID          
            local category = item.Category          
        
            NotifyInfo("Mass Trade", "Trade item "..i.." of "..#tradeState.TempTradeList)          
            InitiateTrade:InvokeServer(tradeState.selectedPlayerId, uuid, category)          
        
            -- Trade response logic (asli, tidak sempurna)
            task.wait(6.5) -- Delay antar trade         
        end          
    
        NotifySuccess("Mass Trade", "Finished V1 trading!")        
        tradeState.autoTradeV2 = false          
        tradeState.TempTradeList = {}          
    end)          
end

-- Toggle Auto Trade (Mode V1)
local autoTradeQuietToggle = Trade:Toggle({
    Title = "Start Mass Trade V1",
    Desc = "Trade all saved items automatically.",
    Value = false,
    Callback = function(state)
        tradeState.autoTradeV2 = state
        if tradeState.mode == "V1" and state then
            if #tradeState.TempTradeList == 0 then
                NotifyError("Mass Trade", "No items saved to trade!")
                tradeState.autoTradeV2 = false
                return
            end
            TradeAllQuiet()
            NotifySuccess("Mass Trade", "V1 Auto Trade Enabled")
        else
            NotifyWarning("Mass Trade", "V1 Auto Trade Disabled")
        end
    end
})
table.insert(_G.TradeQuietElements, {Element = autoTradeQuietToggle})

Trade:Section({Title = "V2"})
_G.TradeV2Elements = {}

local filterToggleV2 = Trade:Toggle({
    Title = "Filter Unfavorited Items Only",
    Value = false,
    Callback = function(val)
        tradeState.filterUnfavorited = val
        refreshInventory()
        NotifyInfo("Filter Updated", "Inventory list refreshed.", 3)
    end
})
table.insert(_G.TradeV2Elements, {Element = filterToggleV2})

_G.InventoryDropdown = Trade:Dropdown({
    Title = "Select Item from Inventory",
    Values = {"- Refresh to load -"},
    AllowNone = true,
    SearchBarEnabled = true,
    Callback = function(val)
        tradeState.selectedItemName = val
    end
})
table.insert(_G.TradeV2Elements, {Element = _G.InventoryDropdown})

Trade:Button({ Title = "Refresh Inventory & Players", Icon = "refresh-cw", Callback = refreshInventory })

local amountInputV2 = Trade:Input({
    Title = "Amount to Trade",
    Placeholder = "Enter amount...",
    Type = "Input",
    Callback = function(val)
        tradeState.tradeAmount = tonumber(val) or 0
    end
})
table.insert(_G.TradeV2Elements, {Element = amountInputV2})

local statusParagraphV2 = Trade:Paragraph({ Title = "Status V2", Desc = "Waiting to start..." })
table.insert(_G.TradeV2Elements, {Element = statusParagraphV2})

-- Toggle Start Mass Trade (V2)
Trade:Toggle({
    Title = "Start Mass Trade V2",
    Value = false,
    Callback = function(value)
        tradeState.autoTradeV2 = value
        if tradeState.mode == "V2" and value then
            task.spawn(function()
                if not tradeState.selectedItemName or not tradeState.selectedPlayerId or tradeState.tradeAmount <= 0 then
                    statusParagraphV2:SetDesc("Error: Select item, amount, and player.")
                    tradeState.autoTradeV2 = false
                    return
                end

                local cleanItemName = tradeState.selectedItemName:match("^(.*) %((%d+)x%)$")
                if cleanItemName then cleanItemName = cleanItemName:match("^(.*)") end 
                if not cleanItemName then cleanItemName = tradeState.selectedItemName end

                local uuidsToSend = inventoryCache[cleanItemName]

                if not uuidsToSend or #uuidsToSend < tradeState.tradeAmount then
                    statusParagraphV2:SetDesc("Error: Not enough items. Refresh inventory.")
                    tradeState.autoTradeV2 = false
                    return
                end

                local successCount, failCount = 0, 0
                local targetName = tradeState.selectedPlayerName

                for i = 1, tradeState.tradeAmount do 
                    if not tradeState.autoTradeV2 then
                        statusParagraphV2:SetDesc("Process stopped by user.")
                        break
                    end

                    local uuid = uuidsToSend[i]
                    statusParagraphV2:SetDesc(string.format(
                        "Progress: %d/%d | Sending to: %s | Status: <font color='#eab308'>Waiting...</font>",
                        i, tradeState.tradeAmount, targetName))

                    local success, result = pcall(InitiateTrade.InvokeServer, InitiateTrade, tradeState.selectedPlayerId, uuid)

                    if success and result then
                        successCount = successCount + 1
                    else
                        failCount = failCount + 1
                    end

                    statusParagraphV2:SetDesc(string.format(
                        "Progress: %d/%d | Sent: %s | Success: %d | Failed: %d",
                        i, tradeState.tradeAmount, success and "✅" or "❌", successCount, failCount))
                    
                    task.wait(5) 
                end

                statusParagraphV2:SetDesc(string.format(
                    "Trade V2 Process Complete.\nSuccessful: %d | Failed: %d",
                    successCount, failCount))

                tradeState.autoTradeV2 = false
                refreshInventory()
            end)
        end
    end
})

-- Sembunyikan elemen GLua secara default, kecuali tombol refresh dan dropdown mode
for _, element in ipairs(_G.TradeV2Elements) do
    if element.Element then element.Element.Visible = false end
end

-- Pastikan elemen Quiet terlihat
for _, element in ipairs(_G.TradeQuietElements) do
    if element.Element then element.Element.Visible = true end
end

-------------------------------------------
----- =======[ ARTIFACT TAB ]
-------------------------------------------

AutoFarmArt:Section({
    Title = "Farming Artifact Menu",
    TextSize = 22,
    TextXAlignment = "Center",
})

local REPlaceLeverItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/PlaceLeverItem"]

_G.UnlockTemple = function()
    task.spawn(function()
        local Artifacts = {
            "Hourglass Diamond Artifact",
            "Crescent Artifact",
            "Arrow Artifact",
            "Diamond Artifact"
        }

        for _, artifact in ipairs(Artifacts) do
            REPlaceLeverItem:FireServer(artifact)
            NotifyInfo("Temple Unlock", "Placing: " .. artifact)
            task.wait(2.1)
        end

        NotifySuccess("Temple Unlock", "All Artifacts placed successfully!")
    end)
end


_G.ArtifactSpots = {
    ["Spot 1"] = CFrame.new(1404.16931, 6.38866091, 118.118126, -0.964853525, 8.69606822e-08, 0.262788326, 9.85441346e-08,
        1, 3.08992689e-08, -0.262788326, 5.5709517e-08, -0.964853525),
    ["Spot 2"] = CFrame.new(883.969788, 6.62499952, -338.560059, -0.325799465, 2.72482961e-08, 0.945438921,
        3.40634649e-08, 1, -1.70824759e-08, -0.945438921, 2.6639464e-08, -0.325799465),
    ["Spot 3"] = CFrame.new(1834.76819, 6.62499952, -296.731476, 0.413336992, -7.92166972e-08, -0.910578132,
        3.06007166e-08, 1, -7.31055181e-08, 0.910578132, 2.35287234e-09, 0.413336992),
    ["Spot 4"] = CFrame.new(1483.25586, 6.62499952, -848.38031, -0.986296117, 2.72397838e-08, 0.164984599, 3.60663037e-08,
        1, 5.05033348e-08, -0.164984599, 5.57616318e-08, -0.986296117)
}

local REFishCaught = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FishCaught"]

local saveFile = "ArtifactProgress.json"

if isfile(saveFile) then
    local success, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile(saveFile))
    end)
    if success and type(data) == "table" then
        _G.ArtifactCollected = data.ArtifactCollected or 0
        _G.CurrentSpot = data.CurrentSpot or 1
    else
        _G.ArtifactCollected = 0
        _G.CurrentSpot = 1
    end
else
    _G.ArtifactCollected = 0
    _G.CurrentSpot = 1
end

_G.ArtifactFarmEnabled = false

local function saveProgress()
    local data = {
        ArtifactCollected = _G.ArtifactCollected,
        CurrentSpot = _G.CurrentSpot
    }
    writefile(saveFile, game:GetService("HttpService"):JSONEncode(data))
end

_G.StartArtifactFarm = function()
    if _G.ArtifactFarmEnabled then return end
    _G.ArtifactFarmEnabled = true

    updateParagraph("Auto Farm Artifact", ("Resuming from Spot %d..."):format(_G.CurrentSpot))

    local Player = game.Players.LocalPlayer
    task.wait(1)
    Player.Character:PivotTo(_G.ArtifactSpots["Spot " .. tostring(_G.CurrentSpot)])
    task.wait(1)

    StartAutoFish5X()
    _G.AutoFishStarted = true

    _G.ArtifactConnection = REFishCaught.OnClientEvent:Connect(function(fishName, data)
        if string.find(fishName, "Artifact") then
            _G.ArtifactCollected += 1
            saveProgress()

            updateParagraph(
                "Auto Farm Artifact",
                ("Artifact Found : %s\nTotal: %d/4"):format(fishName, _G.ArtifactCollected)
            )

            if _G.ArtifactCollected < 4 then
                _G.CurrentSpot += 1
                saveProgress()
                local spotName = "Spot " .. tostring(_G.CurrentSpot)
                if _G.ArtifactSpots[spotName] then
                    task.wait(2)
                    Player.Character:PivotTo(_G.ArtifactSpots[spotName])
                    updateParagraph("Auto Farm Artifact",
                        ("Artifact Found : %s\nTotal : %d/4\n\nTeleporting to %s..."):format(
                            fishName,
                            _G.ArtifactCollected,
                            spotName
                        )
                    )
                    task.wait(1)
                end
            else
                updateParagraph("Auto Farm Artifact", "All Artifacts collected! Unlocking Temple...")
                StopAutoFish5X()
                task.wait(1.5)
                if typeof(_G.UnlockTemple) == "function" then
                    _G.UnlockTemple()
                end
                _G.StopArtifactFarm()
                delfile(saveFile)
            end
        end
    end)
end

_G.StopArtifactFarm = function()
    StopAutoFish()
    _G.ArtifactFarmEnabled = false
    _G.AutoFishStarted = false
    if _G.ArtifactConnection then
        _G.ArtifactConnection:Disconnect()
        _G.ArtifactConnection = nil
    end
    saveProgress()
    updateParagraph("Auto Farm Artifact", "Auto Farm Artifact stopped. Progress saved.")
end

function updateParagraph(title, desc)
    if _G.ArtifactParagraph then
        _G.ArtifactParagraph:SetDesc(desc)
    end
end

_G.ArtifactParagraph = AutoFarmArt:Paragraph({
    Title = "Auto Farm Artifact",
    Desc = "Waiting for activation...",
    Color = "Blue",
})

AutoFarmArt:Space()

AutoFarmArt:Toggle({
    Title = "Auto Farm Artifact",
    Desc = "Automatically collects 4 Artifacts and unlocks The Temple.",
    Default = false,
    Callback = function(state)
        if state then
            _G.StartArtifactFarm()
        else
            _G.StopArtifactFarm()
        end
    end
})

local spotNames = {}
for name in pairs(_G.ArtifactSpots) do
    table.insert(spotNames, name)
end

AutoFarmArt:Dropdown({
    Title = "Teleport to Lever Temple",
    Values = spotNames,
    Value = spotNames[1],
    Callback = function(selected)
        local spotCFrame = _G.ArtifactSpots[selected]
        if spotCFrame then
            local player = game.Players.LocalPlayer
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart")

            if hrp then
                hrp.CFrame = spotCFrame
                NotifySuccess("Lever Temple", "Teleported to " .. selected)
            else
                warn("HumanoidRootPart not found!")
            end
        else
            warn("Invalid teleport spot: " .. tostring(selected))
        end
    end
})

AutoFarmArt:Button({
    Title = "Unlock The Temple",
    Desc = "Still need Artifacts!",
    Justify = "Center",
    Icon = "",
    Callback = function()
        _G.UnlockTemple()
    end
})

-------------------------------------------
----- =======[ SETTINGS TAB ]
-------------------------------------------


_G.AntiAFKEnabled = true
_G.AFKConnection = nil

SettingsTab:Toggle({
    Title = "Anti-AFK",
    Value = true,
    Callback = function(Value)
        _G.AntiAFKEnabled = Value
        if AntiAFKEnabled then
            if AFKConnection then
                AFKConnection:Disconnect()
            end


            local VirtualUser = game:GetService("VirtualUser")

            _G.AFKConnection = LocalPlayer.Idled:Connect(function()
                pcall(function()
                    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                end)
            end)

            if NotifySuccess then
                NotifySuccess("Anti-AFK Activated", "You will now avoid being kicked.")
            end
        else
            if _G.AFKConnection then
                _G.AFKConnection:Disconnect()
                _G.AFKConnection = nil
            end

            if NotifySuccess then
                NotifySuccess("Anti-AFK Deactivated", "You can now go idle again.")
            end
        end
    end,
})

SettingsTab:Space()

SettingsTab:Button({
    Title = "Boost FPS (Ultra Low Graphics)",
    Callback = function()
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
                v.CastShadow = false
                v.Transparency = v.Transparency > 0.5 and 1 or v.Transparency
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Explosion") then
                v.Enabled = false
            elseif v:IsA("Beam") or v:IsA("SpotLight") or v:IsA("PointLight") or v:IsA("SurfaceLight") then
                v.Enabled = false
            elseif v:IsA("ShirtGraphic") or v:IsA("Shirt") or v:IsA("Pants") then
                v:Destroy()
            end
        end

        local Lighting = game:GetService("Lighting")
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then
                effect.Enabled = false
            end
        end
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.ClockTime = 12
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)

        local Terrain = workspace:FindFirstChildOfClass("Terrain")
        if Terrain then
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 1
            Terrain.Decoration = false
        end

        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
        settings().Rendering.TextureQuality = Enum.TextureQuality.Low

        game:GetService("UserSettings").GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
        game:GetService("UserSettings").GameSettings.Fullscreen = true

        for _, s in pairs(workspace:GetDescendants()) do
            if s:IsA("Sound") and s.Playing and s.Volume > 0.5 then
                s.Volume = 0.1
            end
        end

        if collectgarbage then
            collectgarbage("collect")
        end

        local fullWhite = Instance.new("ScreenGui")
        fullWhite.Name = "FullWhiteScreen"
        fullWhite.ResetOnSpawn = false
        fullWhite.IgnoreGuiInset = true
        fullWhite.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        fullWhite.Parent = game:GetService("CoreGui")

        local whiteFrame = Instance.new("Frame")
        whiteFrame.Size = UDim2.new(1, 0, 1, 0)
        whiteFrame.BackgroundColor3 = Color3.new(1, 1, 1)
        whiteFrame.BorderSizePixel = 0
        whiteFrame.Parent = fullWhite

        NotifySuccess("Boost FPS", "Boost FPS mode applied successfully with Full White Screen!")
    end
})

SettingsTab:Space()

function _G.SembunyikanNotifikasiIkan()
    task.spawn(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local notifPath = ReplicatedStorage:FindFirstChild("Packages")
        if not notifPath then
            warn(" Struktur Packages tidak ditemukan.")
            return
        end

        local NetFolder = notifPath:FindFirstChild("_Index")
        if not NetFolder then
            warn(" Folder _Index tidak ditemukan di Packages.")
            return
        end

        local sleitnickNet = NetFolder:FindFirstChild("sleitnick_net@0.2.0")
        if not sleitnickNet then
            warn(" sleitnick_net@0.2.0 tidak ditemukan.")
            return
        end

        local net = sleitnickNet:FindFirstChild("net")
        if not net then
            warn(" Folder net tidak ditemukan.")
            return
        end

        local REObtainedNewFishNotification = net:FindFirstChild("RE/ObtainedNewFishNotification")
        if not REObtainedNewFishNotification then
            warn(" RemoteEvent notifikasi ikan tidak ditemukan.")
            return
        end

        --  Nonaktifkan semua koneksi notifikasi
        for _, connection in pairs(getconnections(REObtainedNewFishNotification.OnClientEvent)) do
            connection:Disable()
        end

        print(" Notifikasi ikan berhasil disembunyikan.")
    end)
end

function _G.TampilkanNotifikasiIkan()
    task.spawn(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local REObtainedNewFishNotification = ReplicatedStorage
            .Packages._Index["sleitnick_net@0.2.0"].net["RE/ObtainedNewFishNotification"]

        if REObtainedNewFishNotification then
            for _, connection in pairs(getconnections(REObtainedNewFishNotification.OnClientEvent)) do
                connection:Enable()
            end
            print(" Notifikasi ikan diaktifkan kembali.")
        else
            warn(" Tidak dapat menemukan event notifikasi ikan.")
        end
    end)
end

--  Tambahkan ke tab UI
SettingsTab:Space()

SettingsTab:Toggle({
    Title = "Hide Notif Fish",
    Desc = "Turn off new fish pop-up",
    Default = false,
    Callback = function(state)
        if state then
            _G.SembunyikanNotifikasiIkan()
        else
            _G.TampilkanNotifikasiIkan()
        end
    end
})

SettingsTab:Space()

local TeleportService = game:GetService("TeleportService")

local function Rejoin()
    local player = Players.LocalPlayer
    if player then
        TeleportService:Teleport(game.PlaceId, player)
    end
end

local function ServerHop()
    local placeId = game.PlaceId
    local servers = {}
    local cursor = ""
    local found = false

    repeat
        local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        if cursor ~= "" then
            url = url .. "&cursor=" .. cursor
        end

        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet(url))
        end)

        if success and result and result.data then
            for _, server in pairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    table.insert(servers, server.id)
                end
            end
            cursor = result.nextPageCursor or ""
        else
            break
        end
    until not cursor or #servers > 0

    if #servers > 0 then
        local targetServer = servers[math.random(1, #servers)]
        TeleportService:TeleportToPlaceInstance(placeId, targetServer, LocalPlayer)
    else
        NotifyError("Server Hop Failed", "No servers available or all are full!")
    end
end

SettingsTab:Space()

SettingsTab:Button({
    Title = "Rejoin Server",
    Justify = "Center",
    Icon = "",
    Callback = function()
        Rejoin()
    end,
})

SettingsTab:Space()

SettingsTab:Button({
    Title = "Server Hop (New Server)",
    Justify = "Center",
    Icon = "",
    Callback = function()
        ServerHop()
    end,
})

SettingsTab:Space()

SettingsTab:Section({
    Title = "Configuration",
    TextSize = 22,
    TextXAlignment = "Center",
    Opened = true
})

SettingsTab:Button({
    Title = "Save",
    Justify = "Center",
    Icon = "",
    Callback = function()
        myConfig:Save()
        NotifySuccess("Config Saved", "Config has been saved!")
    end
})

SettingsTab:Space()

SettingsTab:Button({
    Title = "Load",
    Justify = "Center",
    Icon = "",
    Callback = function()
        myConfig:Load()
        NotifySuccess("Config Loaded", "Config has beed loaded!")
    end
})



-------------------------------------------
----- =======[ SHOP TAB ]
-------------------------------------------


local RFPurchaseMarketItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseMarketItem"]

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

Shop:Dropdown({
    Title = "Traveling Merchant",
    Desc = "Select an item to purchase from Traveling Merchant",
    Values = getKeys(merchantItems),
    Callback = function(selected)
        local itemID = merchantItems[selected]
        if itemID then
            local success, err = pcall(function()
                RFPurchaseMarketItem:InvokeServer(itemID)
            end)
            if success then
                NotifyInfo("Purchase Success", "Successfully bought: " .. selected)
            else
                NotifyInfo("Purchase Failed", "Error: " .. tostring(err))
            end
        end
    end
})

local weatherActive = {}
local weatherData = {
    ["Storm"] = { duration = 900 },
    ["Cloudy"] = { duration = 900 },
    ["Snow"] = { duration = 900 },
    ["Wind"] = { duration = 900 },
    ["Radiant"] = { duration = 900 }
}

local function randomDelay(min, max)
    return math.random(min * 100, max * 100) / 100
end

local function autoBuyWeather(weatherType)
    local purchaseRemote = ReplicatedStorage:WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_net@0.2.0")
        :WaitForChild("net")
        :WaitForChild("RF/PurchaseWeatherEvent")

    task.spawn(function()
        while weatherActive[weatherType] do
            pcall(function()
                purchaseRemote:InvokeServer(weatherType)
                NotifySuccess("Weather Purchased", "Successfully activated " .. weatherType)

                task.wait(weatherData[weatherType].duration)

                local randomWait = randomDelay(1, 5)
                NotifyInfo("Waiting...", "Delay before next purchase: " .. tostring(randomWait) .. "s")
                task.wait(randomWait)
            end)
        end
    end)
end

local WeatherDropdown = Shop:Dropdown({
    Title = "Auto Buy Weather",
    Values = { "Storm", "Cloudy", "Snow", "Wind", "Radiant" },
    Value = {},
    Multi = true,
    AllowNone = true,
    Callback = function(selected)
        for weatherType, active in pairs(weatherActive) do
            if active and not table.find(selected, weatherType) then
                weatherActive[weatherType] = false
                NotifyWarning("Auto Weather", "Auto buying " .. weatherType .. " has been stopped.")
            end
        end
        for _, weatherType in pairs(selected) do
            if not weatherActive[weatherType] then
                weatherActive[weatherType] = true
                NotifyInfo("Auto Weather", "Auto buying " .. weatherType .. " has started!")
                autoBuyWeather(weatherType)
            end
        end
    end
})

myConfig:Register("WeatherDropdown", WeatherDropdown)


local RodItemsPath = game:GetService("ReplicatedStorage"):WaitForChild("Items")

local BaitsPath = ReplicatedStorage:WaitForChild("Baits")

Shop:Space()

local function SafePurchase(callback)
    local originalCFrame = HRP.CFrame
    HRP.CFrame = npcCFrame
    FadeScreen(0.2)
    pcall(callback)
    wait(0.1)
    HRP.CFrame = originalCFrame
end

local rodOptions = {}
local rodData = {}

for _, rod in ipairs(Items:GetChildren()) do
    if rod:IsA("ModuleScript") and rod.Name:find("!!!") then
        local success, module = pcall(require, rod)
        if success and module and module.Data then
            local id = module.Data.Id
            local name = module.Data.Name or rod.Name
            local price = module.Price or module.Data.Price

            if price then
                table.insert(rodOptions, name .. " | Price: " .. tostring(price))
                rodData[name] = id
            end
        end
    end
end

Shop:Dropdown({
    Title = "Rod Shop",
    Desc = "Select Rod to Buy",
    Values = rodOptions,
    Value = nil,
    SearchBarEnabled = true,
    Callback = function(option)
        local selectedName = option:split(" |")[1]
        local id = rodData[selectedName]

        SafePurchase(function()
            net:WaitForChild("RF/PurchaseFishingRod"):InvokeServer(id)
            NotifySuccess("Rod Purchased", selectedName .. " has been successfully purchased!")
        end)
    end,
})


local baitOptions = {}
local baitData = {}

for _, bait in ipairs(Baits:GetChildren()) do
    if bait:IsA("ModuleScript") then
        local success, module = pcall(require, bait)
        if success and module and module.Data then
            local id = module.Data.Id
            local name = module.Data.Name or bait.Name
            local price = module.Price or module.Data.Price

            if price then
                table.insert(baitOptions, name .. " | Price: " .. tostring(price))
                baitData[name] = id
            end
        end
    end
end

Shop:Dropdown({
    Title = "Baits Shop",
    Desc = "Select Baits to Buy",
    Values = baitOptions,
    Value = nil,
    SearchBarEnabled = true,
    Callback = function(option)
        local selectedName = option:split(" |")[1]
        local id = baitData[selectedName]

        SafePurchase(function()
            net:WaitForChild("RF/PurchaseBait"):InvokeServer(id)
            NotifySuccess("Bait Purchased", selectedName .. " has been successfully purchased!")
        end)
    end,
})

-------------------------------------------
----- =======[ AUTO FAV TAB ]
-------------------------------------------


local GlobalFav = {
    REObtainedNewFishNotification = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
    ["RE/ObtainedNewFishNotification"],
    REFavoriteItem = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RE/FavoriteItem"],

    FishIdToName = {},
    FishNameToId = {},
    FishNames = {},
    Variants = {},
    SelectedFishIds = {},
    SelectedVariants = {},
    AutoFavoriteEnabled = false
}

for _, item in pairs(ReplicatedStorage.Items:GetChildren()) do
    local ok, data = pcall(require, item)
    if ok and data.Data and data.Data.Type == "Fish" then
        local id = data.Data.Id
        local name = data.Data.Name
        GlobalFav.FishIdToName[id] = name
        GlobalFav.FishNameToId[name] = id
        table.insert(GlobalFav.FishNames, name)
    end
end

-- Load Variants
for _, variantModule in pairs(ReplicatedStorage.Variants:GetChildren()) do
    local ok, variantData = pcall(require, variantModule)
    if ok and variantData.Data.Name then
        local name = variantData.Data.Name
        GlobalFav.Variants[name] = name
    end
end

AutoFav:Section({
    Title = "Auto Favorite Menu",
    TextSize = 22,
    TextXAlignment = "Center",
})

AutoFav:Toggle({
    Title = "Enable Auto Favorite",
    Value = false,
    Callback = function(state)
        GlobalFav.AutoFavoriteEnabled = state
        if state then
            NotifySuccess("Auto Favorite", "Auto Favorite feature enabled")
        else
            NotifyWarning("Auto Favorite", "Auto Favorite feature disabled")
        end
    end
})

local AllFishNames = GlobalFav.FishNames

_G.FishList = AutoFav:Dropdown({
    Title = "Auto Favorite Fishes",
    Values = AllFishNames,
    Multi = true,
    AllowNone = true,
    SearchBarEnabled = true,
    Callback = function(selectedNames)
        GlobalFav.SelectedFishIds = {}

        for _, name in ipairs(selectedNames) do
            local id = GlobalFav.FishNameToId[name]
            if id then
                GlobalFav.SelectedFishIds[id] = true
            end
        end

        NotifyInfo("Auto Favorite", "Favoriting active for fish: " .. HttpService:JSONEncode(selectedNames))
    end
})


AutoFav:Dropdown({
    Title = "Auto Favorite Variants",
    Values = GlobalFav.Variants,
    Multi = true,
    AllowNone = true,
    SearchBarEnabled = true,
    Callback = function(selectedVariants)
        GlobalFav.SelectedVariants = {}
        for _, vName in ipairs(selectedVariants) do
            for vId, name in pairs(GlobalFav.Variants) do
                if name == vName then
                    GlobalFav.SelectedVariants[vId] = true
                end
            end
        end
        NotifyInfo("Auto Favorite", "Favoriting active for variants: " .. HttpService:JSONEncode(selectedVariants))
    end
})


GlobalFav.REObtainedNewFishNotification.OnClientEvent:Connect(function(itemId, _, data)
    if not GlobalFav.AutoFavoriteEnabled then return end

    local uuid = data.InventoryItem and data.InventoryItem.UUID
    local fishName = GlobalFav.FishIdToName[itemId] or "Unknown"
    local variantId = data.InventoryItem.Metadata and data.InventoryItem.Metadata.VariantId

    if not uuid then return end

    local isFishSelected = GlobalFav.SelectedFishIds[itemId]
    local isVariantSelected = variantId and GlobalFav.SelectedVariants[variantId]

    local shouldFavorite = false

    if isFishSelected and (not next(GlobalFav.SelectedVariants)) then
        shouldFavorite = true
    elseif (not next(GlobalFav.SelectedFishIds)) and isVariantSelected then
        shouldFavorite = true
    elseif isFishSelected and isVariantSelected then
        shouldFavorite = true
    end

    if shouldFavorite then
        GlobalFav.REFavoriteItem:FireServer(uuid)
        local msg = "Favorited " .. fishName
        if isVariantSelected then
            msg = msg .. " (" .. (GlobalFav.Variants[variantId] or variantId) .. " Variant)"
        end
        NotifySuccess("Auto Favorite", msg .. "!")
    end
end)
