-- REYA HUB V6 - AUTO FISH BLATANT + AUTO TIMING CALIBRATOR
repeat task.wait() until game:IsLoaded()
task.wait(2)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local pgui = LocalPlayer:WaitForChild("PlayerGui")

local net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

local Remotes = {
    EquipTool = net["RE/EquipToolFromHotbar"],
    ChargeRod = net["RF/ChargeFishingRod"],
    StartMini = net["RF/RequestFishingMinigameStarted"],
    FinishFish = net["RE/FishingCompleted"],
    SellAll = net["RF/SellAllItems"],
}

_G.AutoFish = false
_G.AutoCalibrate = false
_G.AutoSell = false

-- hasil kalibrasi default
_G.CastDelay = 350
_G.BiteDelay = 2300
_G.ReelSpam = 12
_G.ReelDelay = 0.03


------------------------------------------------------
-- 🔥 AUTO TIMING CALIBRATOR
------------------------------------------------------
local function calibrateCycle()
    print("⚙ [Calibrate] Starting...")

    -- EQUIP
    Remotes.EquipTool:FireServer(1)
    task.wait(0.1)

    -- CAST
    local t_cast = tick()
    Remotes.ChargeRod:InvokeServer(Workspace:GetServerTimeNow())
    task.wait(0.05)
    Remotes.StartMini:InvokeServer(-0.75, 1.0)
    print("⚙ [Calibrate] Cast sent.")

    -- WAIT FOR BITE (!) GUI
    local biteTime = nil
    while task.wait() do
        local gui = pgui:FindFirstChild("FishingMinigame") or pgui:FindFirstChild("Small Notification")
        if gui then
            local ex = gui:FindFirstChild("Exclamation") or gui:FindFirstChild("BiteIndicator")
            if ex and ex.Visible then
                biteTime = tick()
                break
            end
        end
    end

    local castDelay = math.floor((biteTime - t_cast) * 1000)
    print("⚙ [Calibrate] Bite detected → "..castDelay.." ms")

    -- REEL minimal once
    local t_reelStart = tick()
    Remotes.FinishFish:FireServer()
    task.wait(0.05)
    Remotes.FinishFish:FireServer()

    local reelTime = math.floor((tick() - t_reelStart) * 1000)
    print("⚙ [Calibrate] ReelTime = "..reelTime.." ms")

    -- APPLY
    _G.CastDelay = castDelay
    _G.BiteDelay = castDelay   -- sama di game ini
    _G.ReelDelay = math.clamp(reelTime/1000, 0.015, 0.08)

    Rayfield:Notify({
        Title = "Calibration Done",
        Content = "Cast="..castDelay.."ms | Reel="..reelTime.."ms",
        Duration = 5
    })
end


task.spawn(function()
    while task.wait() do
        if _G.AutoCalibrate then
            calibrateCycle()
        end
    end
end)


------------------------------------------------------
-- 🎣 AUTO FISH BLATANT BARU
------------------------------------------------------
task.spawn(function()
    while task.wait() do
        if not _G.AutoFish then continue end

        -- EQUIP
        Remotes.EquipTool:FireServer(1)
        task.wait(0.1)

        -- CAST
        Remotes.ChargeRod:InvokeServer(Workspace:GetServerTimeNow())
        task.wait(0.05)
        Remotes.StartMini:InvokeServer(-0.75, 1.0)
        task.wait(_G.BiteDelay/1000)

        -- REEL
        for i=1,_G.ReelSpam do
            Remotes.FinishFish:FireServer()
            task.wait(_G.ReelDelay)
        end

        task.wait(0.1)
    end
end)


------------------------------------------------------
-- UI
------------------------------------------------------
local Window = Rayfield:CreateWindow({Name="Reya Hub V6 - Auto Timing Blatant"})

local Tab = Window:CreateTab("🎣 Fishing")

Tab:CreateToggle({
    Name = "Auto Fish Blatant (New)",
    Callback = function(v) _G.AutoFish = v end
})

Tab:CreateToggle({
    Name = "Auto Timing Calibrator (1 cycle)",
    Callback = function(v) _G.AutoCalibrate = v end
})

Tab:CreateLabel("Hasil Kalibrasi:")
Tab:CreateLabel(function()
    return "CastDelay: ".._G.CastDelay.."ms | ReelDelay: "..(_G.ReelDelay*1000).."ms"
end)
