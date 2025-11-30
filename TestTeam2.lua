repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Remote (anti-obfuscate 2025)
local net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
local Remotes = {
    EquipTool = net:FindFirstChild("RE/EquipToolFromHotbar") or net:FindFirstChild("EquipToolFromHotbar"),
    ChargeRod = net:FindFirstChild("RF/ChargeFishingRod") or net:FindFirstChild("ChargeFishingRod"),
    StartMini = net:FindFirstChild("RF/RequestFishingMinigameStarted") or net:FindFirstChild("RequestFishingMinigameStarted"),
    FinishFish = net:FindFirstChild("RE/FishingCompleted") or net:FindFirstChild("FishingCompleted"),
}

local Fishing = {
    Enabled = false,
    Running = false,
}

-- DETEKSI PALING AKURAT: Minigame aktif + tanda seru muncul
local CanPull = false
RunService.Heartbeat:Connect(function()
    if not Fishing.Enabled then CanPull = false; return end
    
    local pgui = LocalPlayer:WaitForChild("PlayerGui")
    local fishingGui = pgui:FindFirstChild("Fishing")
    local mini = pgui:FindFirstChild("FishingMinigame") or pgui:FindFirstChild("Small Notification")
    
    if fishingGui and fishingGui.Enabled
    and mini and mini:FindFirstChild("Exclamation") and mini.Exclamation.Visible then
        CanPull = true
    else
        CanPull = false
    end
end)

-- MAIN LOOP – INI YANG BIKIN 100% LANGSUNG JALAN
local function StartFishing()
    if Fishing.Running then return end
    Fishing.Running = true
    Fishing.Enabled = true
    
    Rayfield:Notify({Title = "GACOR AKTIF", Content = "Instant pull + no stuck 100% work", Duration = 5})

    -- Equip sekali
    if Remotes.EquipTool then
        pcall(function() Remotes.EquipTool:FireServer(1) end)
        task.wait(0.4)
    end

    while Fishing.Enabled do
        -- CHARGE + LEMPAR DENGAN POSISI MOUSE ASLI (ini kunci utama!)
        if Remotes.ChargeRod then
            pcall(function() Remotes.ChargeRod:InvokeServer(100) end)
        end
        
        task.wait(0.03) -- wajib delay kecil

        -- Kirim posisi mouse REAL-TIME (bukan nilai magic!)
        local mousePos = UserInputService:GetMouseLocation()
        if Remotes.StartMini then
            pcall(function()
                Remotes.StartMini:InvokeServer(mousePos.X, mousePos.Y)
            end)
        end

        -- Tunggu sampai bisa pull (maksimal 1.2 detik)
        local waited = 0
        repeat
            RunService.Heartbeat:Wait()
            waited += RunService.Heartbeat:Wait()
        until CanPull or waited > 1.2 or not Fishing.Enabled

        if not Fishing.Enabled then break end
        if not CanPull then task.wait(0.1) continue end -- jarang banget ke sini

        -- INSTAN PULL
        pcall(function() Remotes.FinishFish:FireServer() end)

        -- INSTAN RECAST (0.035 detik adalah sweet spot 2025)
        task.wait(0.035)
    end

    Fishing.Running = false
end

-- UI
local Window = Rayfield:CreateWindow({Name = "GACOR FIX 30 NOV 2025", ConfigurationSaving = {Enabled = false}})
local Tab = Window:CreateTab("Main")
Tab:CreateButton({Name = "START INSTAN (100% WORK)", Callback = function() task.spawn(StartFishing) end})
Tab:CreateButton({Name = "STOP", Callback = function() Fishing.Enabled = false end})

print("GACOR FIX 30 NOV 2025 – SIAP NGEGAS, NO STUCK LAGI!")
