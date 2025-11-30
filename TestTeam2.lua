repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Load UI (opsional)
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

-- Cari fishing controller (lebih aman)
local FishingController = ReplicatedStorage:FindFirstChild("Controllers") and ReplicatedStorage.Controllers:FindFirstChild("FishingController")
local FishingModule = FishingController and require(FishingController)

-- State
local State = {
    Enabled = false,
    Casting = false,
    LastCast = 0,
    MinigameActive = false
}

-- Fungsi klik asli (mirip pemain)
local function SimulateFishingClick()
    if not State.MinigameActive then return end

    -- Cara 1: Gunakan Mobile Button (paling reliable di semua device)
    local MobileBtn = LocalPlayer:FindFirstChild("PlayerGui")?.HUD?.MobileFishingButton
    if MobileBtn and MobileBtn.Visible then
        MobileBtn:Click()
        return
    end

    -- Cara 2: Trigger input langsung via FishingController
    if FishingModule and typeof(FishingModule.RequestFishingMinigameClick) == "function" then
        pcall(FishingModule.RequestFishingMinigameClick, FishingModule)
        return
    end

    -- Cara 3: Jika gagal, coba invoke Click event
    local FishingGui = LocalPlayer.PlayerGui:FindFirstChild("Fishing")
    if FishingGui and FishingGui.Enabled then
        local ClickEvent = FishingGui:FindFirstChild("ClickEvent") -- jika ada
        if ClickEvent and ClickEvent:IsA("BindableEvent") then
            ClickEvent:Fire()
        end
    end
end

-- Deteksi tanda seru (!)
task.spawn(function()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    while task.wait(0.008) do
        if not State.Enabled or not State.Casting then continue end
        local FishingGui = PlayerGui:FindFirstChild("Fishing")
        if not (FishingGui and FishingGui.Enabled) then continue end

        local Exclamation = FishingGui:FindFirstChild("Exclamation") or
                            FishingGui.Main:FindFirstChild("Exclamation") or
                            FishingGui.Display:FindFirstChild("Exclamation")

        if Exclamation and Exclamation.Visible then
            print("[AUTO] ! detected → pulling NOW")
            SimulateFishingClick()
            State.MinigameActive = false -- reset setelah pull
            task.wait(0.05) -- jeda minimal sebelum recast
        end
    end
end)

-- Deteksi saat minigame mulai & berhenti
if FishingModule then
    -- Hook ke event internal (jika bisa)
    local Signal = FishingModule._new_result1_upvr_2 or FishingModule["any_new_result1_upvr_2"]
    if Signal and typeof(Signal.Connect) == "function" then
        Signal:Connect(function(data)
            if data and data.Progress then
                State.MinigameActive = true
            end
        end)
    end
end

-- Jika tidak bisa, fallback ke GUI visibility
task.spawn(function()
    while task.wait(0.1) do
        local FishingGui = LocalPlayer.PlayerGui:FindFirstChild("Fishing")
        if FishingGui then
            State.MinigameActive = FishingGui.Enabled
        end
    end
end)

-- Loop utama: instant cast + instant recast
local function AutoFishLoop()
    if State.Enabled then return end
    State.Enabled = true

    if Rayfield then
        Rayfield:Notify({Title = "✅ AUTO FISHING", Content = "Instant pull + instant recast!", Duration = 4})
    end

    -- Equip rod (opsional)
    local Net = ReplicatedStorage:FindFirstChild("Packages")?.Net
    if Net then
        local Equip = Net:FindFirstChild("RE/EquipToolFromHotbar") or Net:FindFirstChild("EquipToolFromHotbar")
        if Equip then
            pcall(function() Equip:FireServer(1) end)
            task.wait(0.6)
        end
    end

    while State.Enabled do
        State.Casting = true
        State.LastCast = tick()

        -- LEmpar umpan (power max)
        if FishingModule and typeof(FishingModule.RequestChargeFishingRod) == "function" then
            pcall(FishingModule.RequestChargeFishingRod, FishingModule, Vector2.new(9999, 9999))
        else
            -- Fallback: klik manual
            local MobileBtn = LocalPlayer.PlayerGui.HUD.MobileFishingButton
            if MobileBtn then MobileBtn:Click() end
        end

        task.wait(0.06) -- tunggu lempar selesai

        -- Tunggu max 1.5 detik untuk ! muncul
        local timeout = tick() + 1.5
        while State.Casting and tick() < timeout do
            task.wait(0.01)
        end

        -- Jika belum selesai, anggap gagal → recast
        State.Casting = false
        task.wait(0.02) -- delay minimal sebelum recast
    end
end

-- UI Simpel (opsional)
if Rayfield then
    local Win = Rayfield:CreateWindow({Name = "Instant Fishing", LoadingTitle = "Loading..."})
    local Tab = Win:CreateTab("Auto Fisher", 4483362458)
    Tab:CreateButton({Name = "START", Callback = AutoFishLoop})
    Tab:CreateButton({Name = "STOP", Callback = function() State.Enabled = false end})
    Tab:CreateParagraph({Title = "Fitur", Content = "• Instant pull saat ! muncul\n• Instant recast setelah catch/gagal\n• Tidak ada stuck\n• Kompatibel semua zone"})
else
    print("Auto Fishing Loaded! Run AutoFishLoop() to start.")
end
