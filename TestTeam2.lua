-- [Auto Fishing GACOR v3 - NO RAYFIELD]
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

-- Cari remote (tetap sama)
local Net
local success, _ = pcall(function()
    Net = require(ReplicatedStorage.Packages.Net)
end)
if not success then
    warn("Net module not found!")
    return
end

local Remotes = {
    EquipTool = Net:RemoteEvent("EquipToolFromHotbar"),
    ChargeRod = Net:RemoteFunction("ChargeFishingRod"),
    StartMini = Net:RemoteFunction("RequestFishingMinigameStarted"),
    FinishFish = Net:RemoteEvent("FishingCompleted"),
}

-- State
local State = {
    Enabled = false,
    IsCasting = false,
    ShouldPull = false,
    HasPulled = false,
}

-- 🔔 NOTIFIKASI INTERNAL (tanpa Rayfield)
local function Notify(title, text, duration)
    duration = duration or 3
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration
    })
end

-- DETEKSI TANDA SERU (!)
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
            State.ShouldPull = true
            State.HasPulled = true
            print("[AUTO] ! detected → pulling NOW")
        end
    end
end)

-- MAIN LOOP
local function StartFishing()
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
        State.ShouldPull = false

        -- LEMPAR UMANG CEPAT
        if Remotes.ChargeRod then
            pcall(function() Remotes.ChargeRod:InvokeServer(100) end)
        end
        task.wait(0.03)

        if Remotes.StartMini then
            pcall(function() Remotes.StartMini:InvokeServer(-1.23, 0.995) end)
        end

        task.wait(0.05) -- biar GUI muncul

        -- Tunggu ! muncul (maks 1.5 detik)
        local timeout = tick() + 1.5
        while State.IsCasting and tick() < timeout do
            if State.ShouldPull then
                pcall(function() Remotes.FinishFish:FireServer() end)
                break
            end
            task.wait(0.01)
        end

        -- INSTANT RECAST
        State.IsCasting = false
        task.wait(0.06) -- delay minimal sebelum lempar ulang
    end

    Notify("⏹️ Auto Fishing", "Stopped.", 3)
end

-- 🎛️ UI SEDERHANA (Native)
local function CreateUI()
    local screen = Instance.new("ScreenGui")
    screen.Name = "AutoFishingUI"
    screen.ResetOnSpawn = false
    screen.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 140)
    frame.Position = UDim2.new(0, 20, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 0
    frame.Parent = screen

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "🎣 Auto Fishing GACOR"
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Color3.white
    title.TextScaled = true
    title.Parent = frame

    local startBtn = Instance.new("TextButton")
    startBtn.Size = UDim2.new(0.9, 0, 0, 35)
    startBtn.Position = UDim2.new(0.05, 0, 0, 40)
    startBtn.Text = "START"
    startBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 100)
    startBtn.TextColor3 = Color3.white
    startBtn.Font = Enum.Font.Gotham
    startBtn.Parent = frame
    startBtn.MouseButton1Click:Connect(StartFishing)

    local stopBtn = Instance.new("TextButton")
    stopBtn.Size = UDim2.new(0.9, 0, 0, 35)
    stopBtn.Position = UDim2.new(0.05, 0, 0, 85)
    stopBtn.Text = "STOP"
    stopBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    stopBtn.TextColor3 = Color3.white
    stopBtn.Font = Enum.Font.Gotham
    stopBtn.Parent = frame
    stopBtn.MouseButton1Click:Connect(function()
        State.Enabled = false
        State.IsCasting = false
        Notify("⏹️ Stopped", "Auto fishing dihentikan.", 2)
    end)

    Notify("✅ UI Loaded", "Click START to begin!", 4)
end

-- Jalankan UI
pcall(CreateUI)
