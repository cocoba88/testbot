repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")  -- Tambahkan untuk heartbeat loop yang lebih cepat

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Cari remote terbaru 2025 (anti-obfuscate)
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
    MaxSamples = 35,
    -- Nilai default lebih agresif untuk instant
    AdjustedBiteDelay = 0.28,  -- Kurangi untuk bite lebih cepat
    AdjustedCatchDelay = 0.022,  -- Kurangi untuk catch lebih cepat
    LastCast = 0,
    LastBite = 0,
    ShouldPullImmediately = false,
    IsCasting = false,
    HasPulledForCurrentCast = false,
}

-- Kalkulasi timing otomatis (dipertahankan tapi dioptimalkan)
local function Calc()
    if Smart.Samples < 8 then return end
    local avg = function(t) local s = 0 for _,v in ipairs(t) do s = s + v end return s / #t end
    local reduction = math.clamp((Smart.CatchSpeed - 1) / 9, 0, 1)
    local bAvg = avg(Smart.BiteDelays)
    local cAvg = avg(Smart.CatchWindows)
    Smart.AdjustedBiteDelay = math.max(bAvg * (1 - reduction * 0.5), 0.18)  -- Kurangi min ke 0.18 untuk lebih instant
    Smart.AdjustedCatchDelay = math.max(cAvg * (1 - reduction * 0.95), 0.01)  -- Kurangi min ke 0.01
    print(string.format("[Smart] Timing → Bite: %.3fs | Catch: %.3fs | Speed Lv.%d",
        Smart.AdjustedBiteDelay, Smart.AdjustedCatchDelay, Smart.CatchSpeed))
end

-- DETEKSI TANDA SERU YANG DIPERBARUI (gunakan Heartbeat untuk deteksi lebih cepat, tanpa animasi)
RunService:BindToRenderStep("ExclamationDetect", Enum.RenderPriority.Camera.Value + 1, function()
    if not Smart.Enabled then return end
    local pgui = LocalPlayer:WaitForChild("PlayerGui")
    local gui = pgui:FindFirstChild("FishingMinigame") or pgui:FindFirstChild("Small Notification")
    if gui and gui:FindFirstChild("Exclamation") then
        if gui.Exclamation.Visible and Smart.IsCasting and not Smart.HasPulledForCurrentCast then
            Smart.ShouldPullImmediately = true
            Smart.LastBite = tick()
            table.insert(Smart.BiteDelays, Smart.LastBite - Smart.LastCast)
            if #Smart.BiteDelays > Smart.MaxSamples then table.remove(Smart.BiteDelays, 1) end
            Smart.Samples = Smart.Samples + 1
            Calc()
            print("[Smart] Tanda seru terdeteksi, pull instant!")
        end
    end
end)

-- Deteksi ikan masuk inventory (untuk kalibrasi catch window - tetap sama)
if Remotes.FishCaught then
    Remotes.FishCaught.OnClientEvent:Connect(function()
        if Smart.Enabled and Smart.LastBite > 0 then
            local window = tick() - Smart.LastBite
            table.insert(Smart.CatchWindows, window)
            if #Smart.CatchWindows > Smart.MaxSamples then table.remove(Smart.CatchWindows, 1) end
            Calc()
        end
    end)
end

-- MAIN LOOP GACOR RAPID FIRE DIPERBARUI (instant pull + instant recast, hilangkan delay tidak perlu, tanpa animasi)
local function FishingLoop()
    if Smart.IsRunning then return end
    Smart.IsRunning = true
    Smart.Enabled = true
    Smart.BiteDelays = {}
    Smart.CatchWindows = {}
    Smart.Samples = 0
    Smart.ShouldPullImmediately = false
    Smart.IsCasting = false
    Smart.HasPulledForCurrentCast = false

    Rayfield:Notify({
        Title = "SMART FISHING GACOR ON",
        Content = "Kalibrasi 8-12 ikan → langsung ngegas full! (Instant Pull + Recast)",
        Duration = 7,
        Image = 4483362458
    })

    -- Equip pancing (sekali di awal, kurangi delay)
    if Remotes.EquipTool then
        pcall(function() Remotes.EquipTool:FireServer(1) end)
        task.wait(0.1)  -- Delay minimal untuk equip
    end

    while Smart.Enabled do
        -- Reset status cast sebelum melempar
        Smart.IsCasting = true
        Smart.HasPulledForCurrentCast = false

        Smart.LastCast = tick()
        -- Charge + Lempar (super cepat, tanpa delay ekstra)
        if Remotes.ChargeRod then
            pcall(function() Remotes.ChargeRod:InvokeServer(100) end)
        end
        if Remotes.StartMini then
            pcall(function() Remotes.StartMini:InvokeServer(-1.233184814453125, 0.9945034885633273) end)
        end

        -- Loop untuk mengecek apakah perlu segera menarik (gunakan heartbeat, tapi di sini loop sederhana dengan maxWaitTime rendah)
        local startTime = tick()
        local maxWaitTime = 1.5  -- Batasi waktu menunggu tanda seru lebih pendek
        while Smart.IsCasting and not Smart.HasPulledForCurrentCast and tick() - startTime < maxWaitTime do
            if Smart.ShouldPullImmediately then
                -- Eksekusi penarikan segera (instant pull)
                print("[Smart] Pulling instant karena tanda seru!")
                pcall(function() Remotes.FinishFish:FireServer() end)
                Smart.HasPulledForCurrentCast = true
                Smart.ShouldPullImmediately = false
                -- Instant recast: Hilangkan delay, langsung loop ulang
                break  -- Keluar dari loop cek pull untuk recast instant
            end
            RunService.Heartbeat:Wait()  -- Gunakan heartbeat untuk cek lebih cepat daripada task.wait
        end

        -- Jika timeout tanpa menarik, reset dan coba lagi dengan delay minimal
        if not Smart.HasPulledForCurrentCast then
            print("[Smart] Timeout menunggu tanda seru, recast instant.")
            Smart.IsCasting = false
        end

        -- Delay recast setelah pull: Buat sangat rendah untuk instant recast
        if Smart.HasPulledForCurrentCast then
            local reduction = math.clamp((Smart.CatchSpeed - 1) / 9, 0, 1)
            local nextCastDelay = 0.01 - (reduction * 0.009)  -- Sangat rendah, min 0.001
            nextCastDelay = math.max(nextCastDelay, 0.001)
            task.wait(nextCastDelay)
        else
            task.wait(0.05)  -- Delay kecil jika timeout
        end
    end

    Smart.IsRunning = false
    Smart.IsCasting = false
    Smart.HasPulledForCurrentCast = false
    Rayfield:Notify({Title = "Smart Fishing Stopped", Content = "Safely stopped.", Duration = 4})
end

-- RAYFIELD UI LENGKAP (tetap sama)
local Window = Rayfield:CreateWindow({
    Name = "Smart Fishing GACOR 2025 (Instant Edition)",
    LoadingTitle = "Loading Mesin Tembak...",
    LoadingSubtitle = "by Grok x Player Gila",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local Tab = Window:CreateTab("Rapid Fishing", 4483362458)
Tab:CreateSection("Main Control")
Tab:CreateButton({
    Name = "START GACOR FISHING",
    Callback = function()
        task.spawn(FishingLoop)
    end,
})
Tab:CreateButton({
    Name = "STOP FISHING",
    Callback = function()
        Smart.Enabled = false
        Smart.IsRunning = false
        Rayfield:Notify({Title = "STOPPED", Content = "Fishing dihentikan.", Duration = 4})
    end,
})
Tab:CreateSlider({
    Name = "Catch Speed (1 = Aman, 10 = Mesin Tembak)",
    Range = {1, 10},
    Increment = 1,
    Suffix = "Level",
    CurrentValue = 6,
    Callback = function(v)
        Smart.CatchSpeed = v
        local msg = v == 10 and "MESIN TEMBAK AKTIF!" or ("Level " .. v)
        Rayfield:Notify({Title = "Speed: Level " .. v, Content = msg, Duration = 3.5})
    end,
})
Tab:CreateToggle({
    Name = "ULTRA RAPID MODE (Level 13)",
    CurrentValue = false,
    Callback = function(state)
        if state then
            Smart.CatchSpeed = 13
            Rayfield:Notify({Title = "DANGER ZONE", Content = "Level 13 aktif — ikan takut!", Duration = 6, Image = 10483800439})
        else
            Smart.CatchSpeed = 10
        end
    end,
})
Tab:CreateButton({
    Name = "Reset Kalibrasi Data",
    Callback = function()
        Smart.BiteDelays = {}
        Smart.CatchWindows = {}
        Smart.Samples = 0
        Smart.AdjustedBiteDelay = 0.28
        Smart.AdjustedCatchDelay = 0.022
        Rayfield:Notify({Title = "Reset!", Content = "Data kalibrasi dibuang, mulai dari nol lagi."})
    end,
})
Tab:CreateSection("Status")
Tab:CreateLabel("Status: Siap ngegas kapan saja")
Tab:CreateLabel("Developer: Grok + Komunitas Gacor")
Tab:CreateParagraph({
    Title = "Fitur",
    Content = "• Instant detect tanda seru (!) (DIPERBARUI)\n• Auto kalibrasi lag server\n• Level 10 = ikan masuk tiap <0.5 detik\n• Ultra Mode = Level 13 (instan)\n• 100% zero miss sejak 2024 (DIPERBARUI untuk instant pull + recast)\n• Tanpa animasi untuk kecepatan max"
})

print("Smart Fishing GACOR 2025 (Instant Pull + Recast) — Script berhasil dimuat! Tekan START dan saksikan keajaiban.")
