repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Cari Net dengan cara aman
local Net = require(ReplicatedStorage.Packages.Net)

local Remotes = {
    EquipTool = Net:RemoteEvent("EquipToolFromHotbar"),
    ChargeRod = Net:RemoteFunction("ChargeFishingRod"),
    StartMini = Net:RemoteFunction("RequestFishingMinigameStarted"),
    FinishFish = Net:RemoteEvent("FishingCompleted"),
    MinigameChanged = Net:RemoteEvent("FishingMinigameChanged"),
}

-- State
local State = {
    Enabled = false,
    IsCasting = false,
    MinigameActive = false,
    UUID = nil,
}

-- DETEKSI MINIGAME DIMULAI (saat tanda seru muncul)
Remotes.MinigameChanged.OnClientEvent:Connect(function(player, action, data)
    if player ~= LocalPlayer then return end
    if action == "Activated" and State.Enabled and State.IsCasting then
        State.MinigameActive = true
        State.UUID = data.UUID
        print("[AUTO] Tanda seru terdeteksi → Pull INSTAN!")
        task.wait(0.005) -- Micro delay
        pcall(function() Remotes.FinishFish:FireServer() end)
        State.MinigameActive = false
    end
end)

-- FUNGSI UTAMA
local function StartAutoFishing()
    if State.Enabled then return end
    State.Enabled = true

    -- Notifikasi internal
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🎣 Auto Fishing",
            Text = "Instant Pull + Instant Recast!",
            Duration = 4
        })
    end)

    -- Equip rod
    pcall(function() Remotes.EquipTool:FireServer(1) end)
    task.wait(0.7)

    while State.Enabled do
        State.IsCasting = true

        -- LEMPAR CEPAT
        pcall(function() Remotes.ChargeRod:InvokeServer(100) end)
        task.wait(0.03)
        pcall(function() Remotes.StartMini:InvokeServer(-1.23, 0.995) end)

        -- Tunggu max 1.2 detik
        task.wait(1.2)

        -- INSTANT RECAST
        State.IsCasting = false
        task.wait(0.05)
    end
end

-- UI SEDERHANA (GUI NATIVE)
local function CreateUI()
    local screen = Instance.new("ScreenGui")
    screen.Name = "AutoFishingUI"
    screen.ResetOnSpawn = false
    screen.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, 40)
    btn.Position = UDim2.new(0, 20, 0, 20)
    btn.Text = "AUTO FISH START"
    btn.BackgroundColor3 = Color3.fromRGB(50, 180, 80)
    btn.TextColor3 = Color3.white
    btn.Font = Enum.Font.SourceSansBold
    btn.MouseButton1Click:Connect(StartAutoFishing)
    btn.Parent = screen

    local stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(0, 180, 0, 40)
    stopBtn.Position = UDim2.new(0, 20, 0, 70)
    stopBtn.Text = "STOP"
    stopBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    stopBtn.TextColor3 = Color3.white
    stopBtn.Font = Enum.Font.SourceSansBold
    stopBtn.MouseButton1Click:Connect(function()
        State.Enabled = false
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "⏹️ Stopped",
                Text = "Auto fishing berhenti.",
                Duration = 2
            })
        end)
    end)
    stopBtn.Parent = screen
end

-- Jalankan
pcall(CreateUI)
