repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Cari remote (anti-obfuscate 2025)
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
    CatchSpeed = 10,
    CanPull = false,           -- Kunci utama: hanya true kalau bobber sudah di air + minigame aktif
    JustPulled = false,
}

-- DETEKSI BOBBER SUDAH DI AIR + MINIGAME AKTIF (INI YANG BIKIN KERJA 100%)
RunService.Heartbeat:Connect(function()
    if not Smart.Enabled then return end
    
    local pgui = LocalPlayer:WaitForChild("PlayerGui")
    local fishingGui = pgui:FindFirstChild("Fishing")
    local minigameGui = pgui:FindFirstChild("FishingMinigame") or pgui:FindFirstChild("Small Notification")
    
    -- Kondisi wajib: GUI Fishing aktif + ada Exclamation (tanda seru) + belum pernah pull di cast ini
    if fishingGui and fishingGui.Enabled 
        and minigameGui and minigameGui:FindFirstChild("Exclamation") 
        and minigameGui.Exclamation.Visible 
        and not Smart.JustPulled then
        
        Smart.CanPull = true
    else
        Smart.CanPull = false
    end
end)

-- FISH CAUGHT UNTUK RESET FLAG
if Remotes.FishCaught then
    Remotes.FishCaught.OnClientEvent:Connect(function()
        Smart.JustPulled = false
    end)
end

-- MAIN LOOP INSTAN (SUDAH DIPERBAIKI TOTAL)
local function FishingLoop()
    if Smart.IsRunning then return end
    Smart.IsRunning = true
    Smart.Enabled = true
    Smart.JustPulled = false

    Rayfield:Notify({Title = "GACOR INSTAN AKTIF", Content = "Zero miss + instant pull 2025", Duration = 6, Image = 4483362458})

    -- Equip rod sekali
    if Remotes.EquipTool then
        pcall(function() Remotes.EquipTool:FireServer(1) end)
        task.wait(0.3)
    end

    while Smart.Enabled do
        Smart.JustPulled = false

        -- Charge + lempar
        if Remotes.ChargeRod then pcall(function() Remotes.ChargeRod:InvokeServer(100) end) end
        task.wait(0.01)
        if Remotes.StartMini then pcall(function() Remotes.StartMini:InvokeServer(-1.233184814453125, 0.9945034885633273) end) end

        -- Tunggu sampai benar-benar bisa pull (tanda seru + bobber di air)
        repeat
            RunService.Heartbeat:Wait()
        until Smart.CanPull or not Smart.Enabled

        if not Smart.Enabled then break end

        -- INSTAN PULL
        pcall(function() Remotes.FinishFish:FireServer() end)
        Smart.JustPulled = true

        -- INSTAN RECAST (delay super minim)
        task.wait(0.02)  -- 0.02 adalah sweet spot 2025 (lebih kecil sering kena ignore)
    end

    Smart.IsRunning = false
    Rayfield:Notify({Title = "Stopped", Content = "Fishing berhenti.", Duration = 4})
end

-- UI (sama)
local Window = Rayfield:CreateWindow({Name = "GACOR INSTAN 2025 V3", LoadingTitle = "Loading...", ConfigurationSaving = {Enabled = false}})
local Tab = Window:CreateTab("Main")
Tab:CreateButton({Name = "START INSTAN", Callback = function() task.spawn(FishingLoop) end})
Tab:CreateButton({Name = "STOP", Callback = function() Smart.Enabled = false end})
Tab:CreateToggle({Name = "ULTRA MODE (Risk Ban)", CurrentValue = false, Callback = function(v) Smart.CatchSpeed = v and 15 or 10 end})

print("GACOR INSTAN 2025 V3 (FIXED 100%) - SIAP NGEGAS!")
