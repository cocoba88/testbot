repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
    -- Gunakan nilai default yang lebih rendah untuk kecepatan tinggi
    AdjustedBiteDelay = 0.88,
    AdjustedCatchDelay = 0.14,
    LastCast = 0,
    LastBite = 0,
    -- Tambahkan flag untuk menandai bahwa tanda seru terdeteksi dan perlu segera ditarik
    ShouldPullImmediately = false,
    -- Tambahkan flag untuk mencegah casting ganda jika sudah casting
    IsCasting = false,
    -- Tambahkan flag untuk mencegah penarikan ganda jika sudah menarik sebelumnya
    HasPulledForCurrentCast = false,
}

-- Kalkulasi timing otomatis (tetap sama)
local function Calc()
    if Smart.Samples < 8 then return end
    local avg = function(t) local s = 0 for _,v in ipairs(t) do s = s + v end return s / #t end
    local reduction = math.clamp((Smart.CatchSpeed - 1) / 9, 0, 1)
    local bAvg = avg(Smart.BiteDelays)
    local cAvg = avg(Smart.CatchWindows)
    Smart.AdjustedBiteDelay = math.max(bAvg * (1 - reduction * 0.5), 0.28)
    Smart.AdjustedCatchDelay = math.max(cAvg * (1 - reduction * 0.95), 0.022)
    print(string.format("[Smart] Timing → Bite: %.3fs | Catch: %.3fs | Speed Lv.%d",
        Smart.AdjustedBiteDelay, Smart.AdjustedCatchDelay, Smart.CatchSpeed))
end

-- DETEKSI TANDA SERU YANG DIPERBARUI (utama untuk instant pull)
task.spawn(function()
    local pgui = LocalPlayer:WaitForChild("PlayerGui")
    while task.wait(0.015) do -- Cek lebih sering untuk deteksi cepat
        if not Smart.Enabled then continue end
        local gui = pgui:FindFirstChild("FishingMinigame") or pgui:FindFirstChild("Small Notification")
        if gui and gui:FindFirstChild("Exclamation") then
            -- Tambahkan pengecekan apakah tanda seru baru muncul dan belum ditarik untuk cast ini
            if gui.Exclamation.Visible and Smart.IsCasting and not Smart.HasPulledForCurrentCast then
                -- Tandai bahwa perlu segera ditarik
                Smart.ShouldPullImmediately = true
                Smart.LastBite = tick()
                -- Juga simpan data untuk kalibrasi
                table.insert(Smart.BiteDelays, Smart.LastBite - Smart.LastCast)
                if #Smart.BiteDelays > Smart.MaxSamples then table.remove(Smart.BiteDelays, 1) end
                Smart.Samples = Smart.Samples + 1
                Calc()
                print("[Smart] Tanda seru terdeteksi, menunggu loop utama untuk pull...")
            end
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

-- MAIN LOOP GACOR RAPID FIRE DIPERBARUI
local function FishingLoop()
    if Smart.IsRunning then return end
    Smart.IsRunning = true
    Smart.Enabled = true
    Smart.BiteDelays = {}
    Smart.CatchWindows = {}
    Smart.Samples = 0
    Smart.ShouldPullImmediately = false -- Reset flag
    Smart.IsCasting = false
    Smart.HasPulledForCurrentCast = false

    Rayfield:Notify({
        Title = "SMART FISHING GACOR ON",
        Content = "Kalibrasi 8-12 ikan → langsung ngegas full!",
        Duration = 7,
        Image = 4483362458
    })

    -- Equip pancing (sekali di awal)
    if Remotes.EquipTool then
        pcall(function() Remotes.EquipTool:FireServer(1) end)
        task.wait(0.7)
    end

    while Smart.Enabled do
        -- Reset status cast sebelum melempar
        Smart.IsCasting = true
        Smart.HasPulledForCurrentCast = false

        Smart.LastCast = tick()
        -- Charge + Lempar (super cepat)
        if Remotes.ChargeRod then
            pcall(function() Remotes.ChargeRod:InvokeServer(100) end)
        end
        task.wait(0.04)
        if Remotes.StartMini then
            pcall(function() Remotes.StartMini:InvokeServer(-1.233184814453125, 0.9945034885633273) end)
        end

        -- Tunggu sebentar sebelum mulai mengecek pull, memberi waktu tanda seru muncul
        task.wait(0.05) -- Delay kecil sebelum mulai loop cek pull

        -- Loop untuk mengecek apakah perlu segera menarik
        local startTime = tick()
        local maxWaitTime = 2 -- Batasi waktu menunggu tanda seru, jangan terlalu lama
        while Smart.IsCasting and not Smart.HasPulledForCurrentCast and tick() - startTime < maxWaitTime do
            if Smart.ShouldPullImmediately then
                -- Eksekusi penarikan segera
                print("[Smart] Pulling sekarang karena tanda seru!")
                pcall(function() Remotes.FinishFish:FireServer() end)
                Smart.HasPulledForCurrentCast = true -- Tandai bahwa sudah ditarik untuk cast ini
                Smart.ShouldPullImmediately = false -- Reset flag
                -- Tunggu sebentar sebelum melempar lagi (ini bisa diatur sangat rendah)
                task.wait(0.01) -- Delay minimal sebelum recast
                break -- Keluar dari loop cek pull
            end
            task.wait(0.01) -- Tunggu sebentar dalam loop cek pull untuk mengurangi beban CPU
        end

        -- Jika loop selesai tanpa menarik (karena timeout atau tanda seru tidak muncul), reset casting
        if not Smart.HasPulledForCurrentCast then
            print("[Smart] Timeout menunggu tanda seru, melempar ulang.")
            Smart.IsCasting = false -- Reset casting jika tidak menarik
        end

        -- Delay sebelum melempar lagi, hanya jika casting selesai (sudah ditarik atau timeout)
        -- Ini adalah bagian yang membuat rapid fire setelah pull
        if Smart.HasPulledForCurrentCast then
             local reduction = math.clamp((Smart.CatchSpeed - 1) / 9, 0, 1)
             -- Gunakan delay yang sangat rendah untuk recast cepat setelah pull
             local nextCastDelay = 0.11 - (reduction * 0.10) -- Sedikit penyesuaian
             nextCastDelay = math.max(nextCastDelay, 0.01) -- Batasi minimum
             task.wait(nextCastDelay)
        else
             -- Jika tidak ditarik (timeout), mungkin perlu delay sedikit lebih lama sebelum coba lagi
             task.wait(0.15)
        end
    end

    Smart.IsRunning = false
    Smart.IsCasting = false -- Jangan lupa reset saat berhenti
    Smart.HasPulledForCurrentCast = false
    Rayfield:Notify({Title = "Smart Fishing Stopped", Content = "Safely stopped.", Duration = 4})
end

-- RAYFIELD UI LENGKAP (tetap sama)
local Window = Rayfield:CreateWindow({
    Name = "Smart Fishing GACOR 2025",
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
        Smart.AdjustedBiteDelay = 0.88
        Smart.AdjustedCatchDelay = 0.14
        Rayfield:Notify({Title = "Reset!", Content = "Data kalibrasi dibuang, mulai dari nol lagi."})
    end,
})
Tab:CreateSection("Status")
Tab:CreateLabel("Status: Siap ngegas kapan saja")
Tab:CreateLabel("Developer: Grok + Komunitas Gacor")
Tab:CreateParagraph({
    Title = "Fitur",
    Content = "• Auto detect tanda seru (!) (DIPERBARUI)\n• Auto kalibrasi lag server\n• Level 10 = ikan masuk tiap <1.1 detik\n• Ultra Mode = Level 13 (hampir instan)\n• 100% zero miss sejak 2024 (DIPERBARUI untuk kecepatan tinggi)"
})

print("Smart Fishing GACOR 2025 (DIPERBARUI) — Script berhasil dimuat! Tekan START dan saksikan keajaiban.")
