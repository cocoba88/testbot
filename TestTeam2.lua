-- SMART FISHING FINAL FIX 2025 → LEVEL 1-10 + ULTRA 100% CATCH RATE
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Remote detection (2025 update)
local net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
local Remotes = {
    EquipTool = net:FindFirstChild("RE/EquipToolFromHotbar") or net:FindFirstChild("EquipToolFromHotbar"),
    ChargeRod = net:FindFirstChild("RF/ChargeFishingRod") or net:FindFirstChild("ChargeFishingRod"),
    StartMini = net:FindFirstChild("RF/RequestFishingMinigameStarted") or net:FindFirstChild("RequestFishingMinigameStarted"),
    FinishFish = net:FindFirstChild("RE/FishingCompleted") or net:FindFirstChild("FishingCompleted"),
    FishCaught = net:FindFirstChild("RE/FishCaught") or net:FindFirstChild("FishCaught"),
}

local Smart = {
    Enabled = false,
    IsRunning = false,
    CatchSpeed = 6,
    BiteDelays = {},
    CatchWindows = {},
    Samples = 0,
    MaxSamples = 40,
    AdjustedBiteDelay = 0.92,
    AdjustedCatchDelay = 0.15,
    LastCast = 0,
    LastBite = 0,
    BiteDetected = false   -- <--- INI YANG BARU (penting banget!)
}

-- MAIN LOOP DIROMBAK TOTAL AGAR TIDAK KELEWATAN BITE
local function FishingLoop()
    if Smart.IsRunning then return end
    Smart.IsRunning = true
    Smart.Enabled = true
    Smart.BiteDelays = {}
    Smart.CatchWindows = {}
    Smart.Samples = 0
    Smart.BiteDetected = false

    Rayfield:Notify({Title = "SMART FISHING FINAL", Content = "Level 1-10 + Ultra Mode → 100% tangkap!", Duration = 7, Image = 4483362458})

    if Remotes.EquipTool then
        pcall(function() Remotes.EquipTool:FireServer(1) end)
        task.wait(0.7)
    end

    while Smart.Enabled do
        Smart.LastCast = tick()
        Smart.BiteDetected = false   -- reset setiap lemparan baru

        -- Charge + Lempar
        if Remotes.ChargeRod then pcall(function() Remotes.ChargeRod:InvokeServer(100) end) end
        task.wait(0.04)
        if Remotes.StartMini then pcall(function() Remotes.StartMini:InvokeServer(-1.233184814453125, 0.9945034885633273) end) end

        -- === TUNGGU BITE DENGAN LOGIKA BARU (INI YANG BIKIN STABIL DI LEVEL 10) ===
        local reduction = math.clamp((Smart.CatchSpeed - 1) / 9, 0, 1)
        local baseWait = Smart.AdjustedBiteDelay * (1 - reduction * 0.65)  -- tidak terlalu agresif
        baseWait = math.max(baseWait, 0.24)  -- BATAS BAWAH 0.24 detik → ini yang bikin level 7-10 tetap aman

        local waited = 0
        while waited < baseWait + 0.4 do   -- maksimal tunggu +0.4 detik (untuk lag)
            task.wait(0.03)
            waited = waited + 0.03

            -- CEK GUI SETIAP 30ms
            local pgui = LocalPlayer:FindFirstChild("PlayerGui")
            if pgui then
                local gui = pgui:FindFirstChild("FishingMinigame") or pgui:FindFirstChild("Small Notification")
                if gui and gui:FindFirstChild("Exclamation") and gui.Exclamation.Visible then
                    Smart.BiteDetected = true
                    Smart.LastBite = tick()
                    table.insert(Smart.BiteDelays, Smart.LastBite - Smart.LastCast)
                    if #Smart.BiteDelays > Smart.MaxSamples then table.remove(Smart.BiteDelays, 1) end
                    Smart.Samples = Smart.Samples + 1
                    Calc()
                    break
                end
            end
        end

        -- KALAU TIDAK ADA BITE DETECTED → tunggu sedikit lagi (safety)
        if not Smart.BiteDetected then
            task.wait(0.22)
        end

        -- === TARIK IKAN ===
        local pullCount = Smart.CatchSpeed <= 5 and 12 or Smart.CatchSpeed <= 8 and 9 or 6
        if Smart.CatchSpeed >= 12 then pullCount = 4 end

        local pullDelay = Smart.AdjustedCatchDelay * (1 - reduction * 0.92)
        pullDelay = math.max(pullDelay, 0.021)

        for i = 1, pullCount do
            if not Smart.Enabled then break end
            pcall(function() Remotes.FinishFish:FireServer() end)
            if i < pullCount then task.wait(pullDelay) end
        end

        -- Delay sebelum lempar lagi (super kecil tapi aman)
        local finalDelay = Smart.CatchSpeed <= 6 and 0.14 or Smart.CatchSpeed <= 9 and 0.08 or 0.04
        task.wait(finalDelay)
    end

    Smart.IsRunning = false
end

-- UI SAMA PERSIS SEPERTI SEBELUMNYA (tinggal copy bagian ini)
local Window = Rayfield:CreateWindow({Name = "Smart Fishing FINAL FIX", LoadingTitle = "Loading...", ConfigurationSaving = {Enabled = false}, KeySystem = false})
local Tab = Window:CreateTab("Smart Fishing", 4483362458)

Tab:CreateButton({Name = "START FISHING", Callback = function() task.spawn(FishingLoop) end})
Tab:CreateButton({Name = "STOP FISHING", Callback = function() Smart.Enabled = false Rayfield:Notify({Title = "Stopped"}) end})

Tab:CreateSlider({
    Name = "Catch Speed (1-10 | Ultra = Toggle)",
    Range = {1,10},
    Increment = 1,
    CurrentValue = 6,
    Callback = function(v)
        Smart.CatchSpeed = v
        Rayfield:Notify({Title = "Speed Level " .. v, Content = v >= 9 and "EKSTREM!" or "Aman", Duration = 3})
    end,
})

Tab:CreateToggle({
    Name = "ULTRA MODE (Level 14)",
    CurrentValue = false,
    Callback = function(v)
        Smart.CatchSpeed = v and 14 or 10
        Rayfield:Notify({Title = v and "ULTRA ON" or "ULTRA OFF", Content = v and "Ikan takut sama kamu sekarang" or "Kembali normal"})
    end
})

Tab:CreateButton({Name = "Reset Kalibrasi", Callback = function()
    Smart.BiteDelays = {}; Smart.CatchWindows = {}; Smart.Samples = 0
    Smart.AdjustedBiteDelay = 0.92; Smart.AdjustedCatchDelay = 0.15
end})

print("Smart Fishing FINAL FIX 2025 loaded — Level 1-10 + Ultra 100% CATCH RATE")
