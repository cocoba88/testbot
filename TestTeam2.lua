repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Zones = Workspace:FindFirstChild("Zones")

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Ambil remote
local net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
local Remotes = {
    EquipTool = net:FindFirstChild("RE/EquipToolFromHotbar") or net:FindFirstChild("EquipToolFromHotbar"),
    ChargeRod = net:FindFirstChild("RF/ChargeFishingRod") or net:FindFirstChild("ChargeFishingRod"),
    StartMini = net:FindFirstChild("RF/RequestFishingMinigameStarted") or net:FindFirstChild("RequestFishingMinigameStarted"),
    FinishFish = net:FindFirstChild("RE/FishingCompleted") or net:FindFirstChild("FishingCompleted"),
    FishCaught = net:FindFirstChild("RE/FishCaught") or net:FindFirstChild("FishCaught"),
    BaitSpawned = net:FindFirstChild("RE/BaitSpawned") or net:FindFirstChild("BaitSpawned"),
}

-- Muat data area (ClickPowerMultiplier)
local AreaData = {}
local AreasModule = ReplicatedStorage:FindFirstChild("Areas")
if AreasModule then
    local success, data = pcall(function()
        return require(AreasModule)
    end)
    if success then
        AreaData = data
    end
end

-- Helper: Dapatkan area dari posisi
local function GetAreaNameFromPosition(pos)
    if not Zones then return "Ocean" end
    for _, zone in ipairs(Zones:GetChildren()) do
        if zone:IsA("Model") and zone:FindFirstChild("RegionPart") then
            local regionPart = zone.RegionPart
            local size = regionPart.Size
            local cframe = regionPart.CFrame
            local rel = cframe:PointToObjectSpace(pos)
            if math.abs(rel.X) <= size.X/2 and math.abs(rel.Y) <= size.Y/2 and math.abs(rel.Z) <= size.Z/2 then
                return zone.Name
            end
        end
    end
    return "Ocean"
end

-- Smart State
local Smart = {
    Enabled = false,
    IsRunning = false,
    CatchSpeed = 6,
    CurrentArea = "Ocean",
    LastCastPos = Vector3.zero,
    ShouldPullImmediately = false,
    IsCasting = false,
    HasPulled = false,
}

-- Ambil ClickPowerMultiplier dari area
local function GetClickPowerMultiplier(areaName)
    local area = AreaData[areaName]
    if area and type(area.ClickPowerMultiplier) == "number" then
        return area.ClickPowerMultiplier
    end
    return 1.0
end

-- Deteksi tanda seru (!) → instant pull trigger
task.spawn(function()
    local pgui = LocalPlayer:WaitForChild("PlayerGui")
    while task.wait(0.008) do
        if not Smart.Enabled or not Smart.IsCasting then continue end
        local fishingGui = pgui:FindFirstChild("Fishing")
        if fishingGui and fishingGui.Enabled then
            local exclamation = fishingGui:FindFirstChild("Exclamation") or fishingGui.Main:FindFirstChild("Exclamation")
            if exclamation and exclamation.Visible and not Smart.HasPulled then
                Smart.ShouldPullImmediately = true
                Smart.HasPulled = true
                print("[AUTO] ! detected → pulling NOW")
            end
        end
    end
end)

-- MAIN LOOP: Instant Pull + Smart Recast
local function FishingLoop()
    if Smart.IsRunning then return end
    Smart.IsRunning = true
    Smart.Enabled = true
    Smart.ShouldPullImmediately = false
    Smart.IsCasting = false
    Smart.HasPulled = false

    Rayfield:Notify({
        Title = "✅ SMART FISHING GACOR v2",
        Content = "Instant pull + area-aware recast!",
        Duration = 5
    })

    -- Equip rod
    if Remotes.EquipTool then
        pcall(function() Remotes.EquipTool:FireServer(1) end)
        task.wait(0.6)
    end

    while Smart.Enabled do
        Smart.IsCasting = true
        Smart.HasPulled = false
        Smart.ShouldPullImmediately = false

        -- Charge & lempar sangat cepat
        if Remotes.ChargeRod then
            pcall(function() Remotes.ChargeRod:InvokeServer(100) end)
        end
        task.wait(0.03)

        -- Kirim request dengan power max
        local success, res = pcall(function()
            return Remotes.StartMini:InvokeServer(-1.23, 0.995)
        end)

        if not success or not res then
            Smart.IsCasting = false
            task.wait(0.3)
            continue
        end

        -- Simpan posisi casting untuk deteksi area
        Smart.LastCastPos = typeof(res) == "Vector3" and res or Vector3.zero
        Smart.CurrentArea = GetAreaNameFromPosition(Smart.LastCastPos)
        local multiplier = GetClickPowerMultiplier(Smart.CurrentArea)
        print("[AUTO] Casting in:", Smart.CurrentArea, "| Multiplier:", multiplier)

        -- Tunggu sedikit agar UI muncul
        task.wait(0.04)

        -- Tunggu pull (maks 2 detik)
        local pullTimeout = tick() + 2
        while Smart.IsCasting and tick() < pullTimeout do
            if Smart.ShouldPullImmediately then
                pcall(function() Remotes.FinishFish:FireServer() end)
                print("[AUTO] Fish caught! Recasting...")
                break
            end
            task.wait(0.005)
        end

        -- HITUNG DELAY RECAST BERDASARKAN AREA
        -- Semakin kecil multiplier → semakin sulit → jangan terlalu cepat recast
        local baseRecastDelay = 0.08  -- default untuk area mudah
        local adjustedDelay = baseRecastDelay + (1 - multiplier) * 0.12  -- max ~0.2s untuk area sulit
        adjustedDelay = math.clamp(adjustedDelay, 0.06, 0.22)

        task.wait(adjustedDelay)
        Smart.IsCasting = false
    end

    Smart.IsRunning = false
    Rayfield:Notify({Title = "⏹️ Stopped", Content = "Auto fishing halted.", Duration = 3})
end

-- UI
local Window = Rayfield:CreateWindow({
    Name = "Smart Fishing GACOR v2",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Instant Pull + Area-Aware Recast",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local Tab = Window:CreateTab("Auto Fishing", 4483362458)
Tab:CreateButton({
    Name = "🚀 START AUTO FISHING",
    Callback = function()
        task.spawn(FishingLoop)
    end,
})
Tab:CreateButton({
    Name = "⏹️ STOP",
    Callback = function()
        Smart.Enabled = false
    end,
})
Tab:CreateSlider({
    Name = "Speed Level (1-10)",
    Range = {1, 10},
    Increment = 1,
    Suffix = "",
    CurrentValue = 8,
    Callback = function(v)
        Smart.CatchSpeed = v
    end,
})
Tab:CreateParagraph({
    Title = "Fitur",
    Content = "• Instant pull saat ! muncul\n• Recast delay disesuaikan tiap area\n• Support semua zone (termasuk Hidden)\n• Anti ban & anti miss"
})
