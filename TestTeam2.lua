repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

-- Cari Net module dengan cara lebih aman
local Net
local success, _ = pcall(function()
    Net = require(ReplicatedStorage.Packages.Net)
end)

if not success then
    warn("[FISH BOT] Gagal muat Net module!")
    return
end

-- Remote yang dibutuhkan
local Remotes = {
    EquipTool = Net:RemoteEvent("EquipToolFromHotbar"),
    ChargeRod = Net:RemoteFunction("ChargeFishingRod"),
    StartMini = Net:RemoteFunction("RequestFishingMinigameStarted"),
    FinishFish = Net:RemoteEvent("FishingCompleted"),
    FishCaught = Net:RemoteEvent("FishCaught"),
}

-- State auto fishing
local State = {
    Enabled = false,
    IsCasting = false,
    HasPulled = false,
    LastCast = 0,
}

-- Notifikasi internal (tanpa Rayfield)
local function Notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3
        })
    end)
end

-- DETEKSI TANDA SERU (!) → INSTANT PULL
task.spawn(function()
    local gui = LocalPlayer:WaitForChild("PlayerGui")
    while task.wait(0.01) do
        if not State.Enabled or not State.IsCasting then continue end
        local fishingGui = gui:FindFirstChild("Fishing")
        if not fishingGui or not fishingGui.Enabled then continue end

        local exclamation = fishingGui:FindFirstChild("Exclamation") or
                            fishingGui.Main:FindFirstChild("Exclamation") or
                            fishingGui.Display:FindFirstChild("Exclamation")

        if exclamation and exclamation.Visible and not State.HasPulled then
            print("[AUTO] ! terdeteksi → pull INSTAN!")
            pcall(function() Remotes.FinishFish:FireServer() end)
            State.HasPulled = true
            task.wait(0.05) -- Beri waktu sebelum recast
        end
    end
end)

-- MAIN LOOP: Instant Cast + Instant Recast
local function StartAutoFishing()
    if State.Enabled then return end
    State.Enabled = true
    Notify("🎣 AUTO FISHING", "Instant Pull + Instant Recast!", 4)

    -- Equip rod
    if Remotes.EquipTool then
        pcall(function() Remotes.EquipTool:FireServer(1) end)
        task.wait(0.7)
    end

    while State.Enabled do
        State.IsCasting = true
        State.HasPulled = false
        State.LastCast = tick()

        -- LEMPAR CEPAT
        if Remotes.ChargeRod then
            pcall(function() Remotes.ChargeRod:InvokeServer(100) end)
        end
        task.wait(0.03)

        if Remotes.StartMini then
            pcall(function() Remotes.StartMini:InvokeServer(-1.23, 0.995) end)
        end

        task.wait(0.04) -- Biar GUI muncul

        -- Tunggu max 1.5 detik untuk tanda seru
        local timeout = tick() + 1.5
        while State.IsCasting and tick() < timeout do
            task.wait(0.01)
        end

        -- INSTANT RECAST
        State.IsCasting = false
        task.wait(0.06) -- Delay minimal (aman untuk semua area)
    end

    Notify("⏹️ Berhenti", "Auto fishing dihentikan.", 3)
end

-- BUAT GUI SEDERHANA (SELALU TAMPIL)
local function CreateUI()
    local screen = Instance.new("ScreenGui")
    screen.Name = "AutoFishingUI"
    screen.ResetOnSpawn = false
    screen.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 110)
    frame.Position = UDim2.new(0, 20, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    frame.BorderSizePixel = 0
    frame.Parent = screen

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "⚡ Auto Fishing GACOR"
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Color3.fromRGB(255, 255, 100)
    title.TextScaled = true
    title.Parent = frame

    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(0.45, 0, 0, 35)
    startBtn.Position = UDim2.new(0.05, 0, 0, 45)
    startBtn.Text = "START"
    startBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 80)
    startBtn.TextColor3 = Color3.white
    startBtn.Font = Enum.Font.Gotham
    startBtn.Parent = frame
    startBtn.MouseButton1Click:Connect(StartAutoFishing)

    local stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(0.45, 0, 0, 35)
    stopBtn.Position = UDim2.new(0.5, 0, 0, 45)
    stopBtn.Text = "STOP"
    stopBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    stopBtn.TextColor3 = Color3.white
    stopBtn.Font = Enum.Font.Gotham
    stopBtn.Parent = frame
    stopBtn.MouseButton1Click:Connect(function()
        State.Enabled = false
        State.IsCasting = false
        Notify("⏹️ STOP", "Dihentikan.", 2)
    end)

    Notify("✅ UI Siap", "Klik START untuk mulai auto fishing!", 5)
end

-- Jalankan UI
pcall(CreateUI)
