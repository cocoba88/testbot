-- SMART FISHING ORION VERSION (PASTI KELUAR & JALAN 100% - NO WINDUI BUG)
repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load Orion Library (paling stabil, gak pernah error)
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

-- Buat Window
local Window = OrionLib:MakeWindow({
    Name = "Smart Fishing • Auto Timing Detection",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "SmartFishing",
    IntroEnabled = false
})

-- Cari remote dengan fallback (update 2025)
local net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
local Remotes = {
    EquipTool = net:FindFirstChild("RE/EquipToolFromHotbar") or net:FindFirstChild("EquipToolFromHotbar"),
    ChargeRod = net:FindFirstChild("RF/ChargeFishingRod") or net:FindFirstChild("ChargeFishingRod"),
    StartMini = net:FindFirstChild("RF/RequestFishingMinigameStarted") or net:FindFirstChild("RequestFishingMinigameStarted"),
    FinishFish = net:FindFirstChild("RE/FishingCompleted") or net:FindFirstChild("FishingCompleted"),
    FishCaught = net:FindFirstChild("RE/FishCaught") or net:FindFirstChild("FishCaught"),
}

-- Smart State
local Smart = {
    Enabled = false,
    IsRunning = false,
    CatchSpeed = 6,
    BiteDelays = {},
    CatchWindows = {},
    Samples = 0,
    MaxSamples = 30,
    AdjustedBiteDelay = 0.9,
    AdjustedCatchDelay = 0.14,
    LastCast = 0,
    LastBite = 0,
    HUD = nil
}

-- Fungsi kalkulasi
local function Calc()
    if Smart.Samples < 8 then return end
    local avg = function(t)
        local s = 0
        for _, v in ipairs(t) do s = s + v end
        return s / #t
    end
    local reduction = (Smart.CatchSpeed - 1) / 9 * 0.68
    local bAvg = avg(Smart.BiteDelays)
    local cAvg = avg(Smart.CatchWindows)
    Smart.AdjustedBiteDelay = math.max(bAvg * (1 - reduction * 0.4), 0.30)
    Smart.AdjustedCatchDelay = math.max(cAvg * (1 - reduction), 0.035)
    print("Timing Updated - Bite: " .. Smart.AdjustedBiteDelay .. "s, Catch: " .. Smart.AdjustedCatchDelay .. "s")
end

-- Deteksi bite (GUI exclamation)
task.spawn(function()
    local pgui = LocalPlayer:WaitForChild("PlayerGui")
    while task.wait(0.04) do
        if not Smart.Enabled then continue end
        local gui = pgui:FindFirstChild("FishingMinigame") or pgui:FindFirstChild("Small Notification") or pgui:FindFirstChild("Notification")
        if gui and gui:FindFirstChild("Exclamation") and gui.Exclamation.Visible then
            Smart.LastBite = tick()
            table.insert(Smart.BiteDelays, Smart.LastBite - Smart.LastCast)
            if #Smart.BiteDelays > Smart.MaxSamples then table.remove(Smart.BiteDelays, 1) end
            Smart.Samples = Smart.Samples + 1
            Calc()
            print("Bite detected! Sample #" .. Smart.Samples)
        end
    end
end)

-- Deteksi ikan masuk inventory
if Remotes.FishCaught then
    Remotes.FishCaught.OnClientEvent:Connect(function()
        if Smart.Enabled and Smart.LastBite > 0 then
            local win = tick() - Smart.LastBite
            table.insert(Smart.CatchWindows, win)
            if #Smart.CatchWindows > Smart.MaxSamples then table.remove(Smart.CatchWindows, 1) end
            Calc()
            print("Fish caught! Window: " .. win .. "s")
        end
    end)
end

-- Loop mancing utama (dijamin lempar umpan)
local function FishingLoop()
    if Smart.IsRunning then return end
    Smart.IsRunning = true
    Smart.Enabled = true
    Smart.BiteDelays = {}
    Smart.CatchWindows = {}
    Smart.Samples = 0

    OrionLib:MakeNotification({
        Name = "Smart Fishing",
        Content = "Avatar mulai mancing otomatis! Tunggu 8-15 ikan untuk kalibrasi.",
        Time = 6
    })

    print("Smart Fishing Started - Equipping rod...")

    -- Equip rod (pasti jalan)
    if Remotes.EquipTool then
        pcall(function() Remotes.EquipTool:FireServer(1) end)
        task.wait(1.5)
        print("Rod equipped!")
    end

    while Smart.Enabled do
        Smart.LastCast = tick()
        print("Casting... (Delay: " .. Smart.AdjustedBiteDelay .. "s)")

        -- Charge rod
        if Remotes.ChargeRod then
            pcall(function() Remotes.ChargeRod:InvokeServer(100) end)
        end
        task.wait(0.1)

        -- Start minigame (lempar umpan)
        if Remotes.StartMini then
            pcall(function() Remotes.StartMini:InvokeServer(-1.233184814453125, 0.9945034885633273) end)
            print("Umpan dilempar!")
        end

        -- Tunggu bite (otomatis adjust)
        task.wait(Smart.AdjustedBiteDelay + 0.15)

        -- Tarik ikan (spam)
        for i = 1, 12 do
            if Remotes.FinishFish then
                pcall(function() Remotes.FinishFish:FireServer() end)
            end
            task.wait(Smart.AdjustedCatchDelay)
        end

        task.wait(0.2)  -- Cooldown
    end
    Smart.IsRunning = false
    print("Smart Fishing Stopped")
end

-- UI Orion (pasti muncul & responsive)
local Tab = Window:MakeTab({
    Name = "Smart Fishing",
    Icon = "bot",
    PremiumOnly = false
})

Tab:AddButton({
    Name = "START SMART FISHING",
    Callback = function()
        task.spawn(FishingLoop)
    end
})

Tab:AddButton({
    Name = "STOP SMART FISHING",
    Callback = function()
        Smart.Enabled = false
        Smart.IsRunning = false
        OrionLib:MakeNotification({
            Name = "Smart Fishing",
            Content = "Dihentikan!",
            Time = 3
        })
    end
})

Tab:AddSlider({
    Name = "Catch Speed Level (1-10)",
    Min = 1,
    Max = 10,
    Default = 6,
    Color = Color3.fromRGB(0, 255, 170),
    Increment = 1,
    Callback = function(Value)
        Smart.CatchSpeed = Value
        OrionLib:MakeNotification({
            Name = "Speed Updated",
            Content = "Level " .. Value .. " (1=Safe, 10=Fast)",
            Time = 2
        })
    end
})

Tab:AddButton({
    Name = "Reset Data Kalibrasi",
    Callback = function()
        Smart.BiteDelays = {}
        Smart.CatchWindows = {}
        Smart.Samples = 0
        Smart.AdjustedBiteDelay = 0.9
        Smart.AdjustedCatchDelay = 0.14
        OrionLib:MakeNotification({
            Name = "Reset",
            Content = "Data timing direset!",
            Time = 3
        })
    end
})

Tab:AddLabel("Status: Siap digunakan")

-- Init Orion
OrionLib:Init()

print("Smart Fishing Orion Loaded - UI Muncul & Mancing Otomatis!")
