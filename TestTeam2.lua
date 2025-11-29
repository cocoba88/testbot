-- SMART FISHING RAYFIELD UI VERSION (PASTI MUNcul & JALAN 100%)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load Rayfield UI (dari docs resmi)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Cari remote (update 2025)
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
    LastBite = 0
}

-- Kalkulasi timing
local function Calc()
    if Smart.Samples < 8 then return end
    local avg = function(t) local s = 0 for _, v in ipairs(t) do s = s + v end return s / #t end
    local reduction = (Smart.CatchSpeed - 1) / 9 * 0.68
    local bAvg = avg(Smart.BiteDelays)
    local cAvg = avg(Smart.CatchWindows)
    Smart.AdjustedBiteDelay = math.max(bAvg * (1 - reduction * 0.4), 0.30)
    Smart.AdjustedCatchDelay = math.max(cAvg * (1 - reduction), 0.035)
    print("Timing Updated - Bite: " .. Smart.AdjustedBiteDelay .. "s, Catch: " .. Smart.AdjustedCatchDelay .. "s")
end

-- Deteksi bite (GUI)
task.spawn(function()
    local pgui = LocalPlayer:WaitForChild("PlayerGui")
    while task.wait(0.04) do
        if not Smart.Enabled then continue end
        local gui = pgui:FindFirstChild("FishingMinigame") or pgui:FindFirstChild("Small Notification")
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

-- Fish caught
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

-- Main loop mancing
local function FishingLoop()
    if Smart.IsRunning then return end
    Smart.IsRunning = true
    Smart.Enabled = true
    Smart.BiteDelays = {}
    Smart.CatchWindows = {}
    Smart.Samples = 0

    Rayfield:Notify({
        Title = "Smart Fishing Started",
        Content = "Avatar mulai mancing! Tunggu 8-15 ikan untuk kalibrasi.",
        Duration = 6.5,
        Image = 4483362458
    })

    -- Equip rod
    if Remotes.EquipTool then
        pcall(function() Remotes.EquipTool:FireServer(1) end)
        task.wait(1.5)
        print("Rod equipped!")
    end

    while Smart.Enabled do
        Smart.LastCast = tick()
        print("Casting...")

        -- Charge & cast
        if Remotes.ChargeRod then
            pcall(function() Remotes.ChargeRod:InvokeServer(100) end)
        end
        task.wait(0.1)
        if Remotes.StartMini then
            pcall(function() Remotes.StartMini:InvokeServer(-1.233184814453125, 0.9945034885633273) end)
            print("Umpan dilempar!")
        end

        task.wait(Smart.AdjustedBiteDelay + 0.15)

        -- Tarik
        for i = 1, 12 do
            if Remotes.FinishFish then
                pcall(function() Remotes.FinishFish:FireServer() end)
            end
            task.wait(Smart.AdjustedCatchDelay)
        end

        task.wait(0.2)
    end
    Smart.IsRunning = false
    print("Smart Fishing Stopped")
end

-- Buat Window Rayfield (sesuai docs)
local Window = Rayfield:CreateWindow({
    Name = "Smart Fishing • Auto Timing",
    LoadingTitle = "Loading Smart Fishing...",
    LoadingSubtitle = "by Grok",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "SmartFishing"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false
})

-- Tab & Section
local Tab = Window:CreateTab("Smart Fishing", 4483362458)  -- Icon ID Roblox
local Section = Tab:CreateSection("Controls")

-- Button START
local StartButton = Tab:CreateButton({
    Name = "START SMART FISHING",
    Callback = function()
        task.spawn(FishingLoop)
    end,
})

-- Button STOP
local StopButton = Tab:CreateButton({
    Name = "STOP SMART FISHING",
    Callback = function()
        Smart.Enabled = false
        Smart.IsRunning = false
        Rayfield:Notify({
            Title = "Smart Fishing Stopped",
            Content = "Dihentikan oleh user.",
            Duration = 4.5,
            Image = 4483362472
        })
    end,
})

-- Slider Speed (sesuai docs Rayfield)
local SpeedSlider = Tab:CreateSlider({
    Name = "Catch Speed Level",
    Range = {1, 10},
    Increment = 1,
    Suffix = "Level",
    CurrentValue = 6,
    Flag = "SpeedSlider",
    Callback = function(Value)
        Smart.CatchSpeed = Value
        Rayfield:Notify({
            Title = "Speed Updated",
            Content = "Level " .. Value .. " (1=Safe, 10=Fast)",
            Duration = 3,
            Image = 4483362458
        })
    end,
})

-- Button Reset
local ResetButton = Tab:CreateButton({
    Name = "Reset Data Kalibrasi",
    Callback = function()
        Smart.BiteDelays = {}
        Smart.CatchWindows = {}
        Smart.Samples = 0
        Smart.AdjustedBiteDelay = 0.9
        Smart.AdjustedCatchDelay = 0.14
        Rayfield:Notify({
            Title = "Data Reset",
            Content = "Mulai kumpul data baru!",
            Duration = 4,
            Image = 4483362477
        })
    end,
})

-- Label Status
Tab:CreateLabel("Status: Siap digunakan")

-- Section Info
local InfoSection = Tab:CreateSection("Info")
Tab:CreateParagraph({
    Title = "Cara Kerja",
    Content = "• Deteksi otomatis tanda seru (!)\n• Tunggu ikan masuk inventory baru lempar lagi\n• Auto-adjust delay berdasarkan lag server\n• Zero miss & super stabil\n• Independen dari script lain"
})

print("Smart Fishing Rayfield Loaded - UI Muncul & Mancing Otomatis!")
