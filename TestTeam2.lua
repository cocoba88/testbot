-- INSTANT FISHING 2025 → UI FIX + 0 DELAY NARIIK & LEMPAR
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- FIX URL RAYFIELD (baru 2025)
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

-- Remote
local net = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
local R = {
    Equip   = net["RE/EquipToolFromHotbar"] or net.EquipToolFromHotbar,
    Charge  = net["RF/ChargeFishingRod"] or net.ChargeFishingRod,
    Cast    = net["RF/RequestFishingMinigameStarted"] or net.RequestFishingMinigameStarted,
    Pull    = net["RE/FishingCompleted"] or net.FishingCompleted,
}

-- State
local S = { On = false, Speed = 8, Ultra = false }

-- Cast Function
local function Cast()
    pcall(function() R.Charge:InvokeServer(100) end)
    task.wait(0.03)
    pcall(function() R.Cast:InvokeServer(-1.233184814453125, 0.9945034885633273) end)
end

-- Main Loop
local function StartFishing()
    if S.On then return end
    S.On = true

    Rayfield:Notify({Title="INSTANT FISHING ON", Content="Tanda seru = langsung narik + lempar lagi!", Duration=6})

    pcall(function() R.Equip:FireServer(1) end)
    task.wait(0.7)
    Cast()

    local conn = RunService.Heartbeat:Connect(function()
        if not S.On then conn:Disconnect() return end

        local pgui = LocalPlayer.PlayerGui
        local gui = pgui.FishingMinigame or pgui["Small Notification"]
        if not gui then return end

        local exc = gui.Exclamation
        if exc and exc.Visible then
            local pullCount = S.Ultra and 4 or (S.Speed >= 9 and 5 or 7)
            for i = 1, pullCount do
                pcall(function() R.Pull:FireServer() end)
                if i < pullCount then task.wait(0.018) end
            end
            task.spawn(Cast)  -- Langsung lempar lagi!
        end
    end)
end

-- Stop
local function StopFishing()
    S.On = false
    Rayfield:Notify({Title="OFF", Content="Stopped", Duration=4})
end

-- UI (muncul pasti!)
local W = Rayfield:CreateWindow({Name = "INSTANT Fishing 2025", ConfigurationSaving = {Enabled = false}})
local T = W:CreateTab("Instant", 4483362458)

T:CreateButton({Name = "START", Callback = StartFishing})
T:CreateButton({Name = "STOP", Callback = StopFishing})

T:CreateSlider({Name = "Speed (1-10)", Range = {1,10}, Increment = 1, CurrentValue = 8, Callback = function(v) S.Speed = v end})

T:CreateToggle({Name = "ULTRA MODE (<0.7 detik/ikan)", CurrentValue = false, Callback = function(v) S.Ultra = v end})

T:CreateLabel("UI Fix 2025 - Gaspol sekarang!")

print("INSTANT FISHING FIXED - UI muncul! Tekan START.")
