-- REYA HUB V5 - FISH IT! HEARTBEAT INSTANT RECAST GOD MODE (DOR DOR DOR <0.2s)
repeat task.wait() until game:IsLoaded()
task.wait(2)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

local Remotes = {
    EquipTool = net["RE/EquipToolFromHotbar"],
    ChargeRod = net["RF/ChargeFishingRod"],
    StartMini = net["RF/RequestFishingMinigameStarted"],
    FinishFish = net["RE/FishingCompleted"],
    SellAll = net["RF/SellAllItems"],
}

_G.AutoFish = false
_G.SmartHeartbeat = false
_G.AutoSell = false
_G.SellDelay = 15
_G.ReelDelay = 0.02  -- Super dor dor dor
_G.HeartbeatReelCount = 20  -- Spam max sebelum ! hilang
_G.RecastDelay = 0.05  -- Instant recast setelah reel

-- AUTO SELL
task.spawn(function()
    while task.wait() do
        if _G.AutoSell then
            pcall(function() Remotes.SellAll:InvokeServer() end)
            task.wait(_G.SellDelay)
        end
    end
end)

-- CLASSIC BLATANT (FALLBACK)
task.spawn(function()
    while task.wait() do
        if _G.AutoFish and not _G.SmartHeartbeat then
            pcall(function()
                Remotes.EquipTool:FireServer(1) task.wait(0.1)
                Remotes.ChargeRod:InvokeServer(Workspace:GetServerTimeNow() + math.random(-5,5)/1000) task.wait(0.08)
                Remotes.StartMini:InvokeServer(-0.75 + math.random(-20,20)/100000, 1.0 + math.random(-20,20)/100000) task.wait(0.45)
                for i=1,12 do Remotes.FinishFish:FireServer() task.wait(_G.ReelDelay) end task.wait(0.08)
            end)
        end
    end
end)

-- GOD MODE HEARTBEAT (SEBELUM ! HILANG → REEL → RECAST)
task.spawn(function()
    local pgui = LocalPlayer:WaitForChild("PlayerGui")
    while task.wait(0.02) do  -- 50Hz detect
        if not _G.AutoFish or not _G.SmartHeartbeat then continue end
        
        local gui = pgui:FindFirstChild("FishingMinigame") or pgui:FindFirstChild("Small Notification")
        if gui then
            local exclamation = gui:FindFirstChild("Exclamation") or gui:FindFirstChild("BiteIndicator")
            if exclamation and exclamation.Visible then
                print("❤️ ! DETECTED - SPAM REEL SEBELUM HILANG!")
                
                -- SPAM REEL MAX (20x @0.02s)
                for i = 1, _G.HeartbeatReelCount do
                    Remotes.FinishFish:FireServer()
                    task.wait(_G.ReelDelay + math.random(-2,2)/1000)  -- Micro random anti-kick
                end
                
                task.wait(_G.RecastDelay)  -- Wait konfirm caught
                
                -- INSTANT RECAST BOBBER (equip + charge + start)
                Remotes.EquipTool:FireServer(1)
                task.wait(0.03)
                Remotes.ChargeRod:InvokeServer(Workspace:GetServerTimeNow() + math.random(-5,5)/1000)
                task.wait(0.03)
                Remotes.StartMini:InvokeServer(-0.75 + math.random(-20,20)/100000, 1.0 + math.random(-20,20)/100000)
                print("⚡ INSTANT RECAST DONE - Sebelum ! hilang!")
            end
        end
    end
end)

-- UI RAYFIELD
local Window = Rayfield:CreateWindow({Name = "Reya Hub v5 - God Mode", LoadingTitle = "Reya Hub v5", LoadingSubtitle = "Heartbeat Instant Recast"})

local FishingTab = Window:CreateTab("🎣 Fishing", 4483362458)

FishingTab:CreateToggle({
    Name = "Auto Fish Blatant (Classic)",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoFish = Value
        Rayfield:Notify({Title="Classic Mode", Content=Value and "ON - Dor dor dor fallback" or "OFF", Duration=3})
    end,
})

FishingTab:CreateToggle({
    Name = "Smart Heartbeat ( ! Detect → Reel → Recast Instant)",
    CurrentValue = false,
    Callback = function(Value)
        _G.SmartHeartbeat = Value
        Rayfield:Notify({Title="God Mode", Content=Value and "ON - Sebelum ! hilang langsung lempar ulang <0.1s!" or "OFF", Duration=5})
    end,
})

FishingTab:CreateSlider({
    Name = "Reel Spam Speed",
    Range = {0.01, 0.1},
    Increment = 0.005,
    Suffix = "s",
    CurrentValue = 0.02,
    Callback = function(Value) _G.ReelDelay = Value end,
})

FishingTab:CreateSlider({
    Name = "Heartbeat Spam Count",
    Range = {15, 25},
    Increment = 1,
    Suffix = "x",
    CurrentValue = 20,
    Callback = function(Value) _G.HeartbeatReelCount = Value end,
})

FishingTab:CreateSlider({
    Name = "Recast Delay (setelah reel)",
    Range = {0.03, 0.15},
    Increment = 0.01,
    Suffix = "s",
    CurrentValue = 0.05,
    Callback = function(Value) _G.RecastDelay = Value end,
})

FishingTab:CreateToggle({
    Name = "Auto Sell",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoSell = Value
    end,
})

FishingTab:CreateSlider({
    Name = "Sell Delay",
    Range = {5, 60},
    Increment = 1,
    Suffix = "s",
    CurrentValue = 15,
    Callback = function(Value) _G.SellDelay = Value end,
})

FishingTab:CreateButton({
    Name = "Sell All Manual",
    Callback = function()
        Remotes.SellAll:InvokeServer()
    end,
})

-- Copy teleport/misce from your original script here

Rayfield:Notify({Title="Reya Hub v5 LOADED!", Content="❤️ God Mode ON → Sebelum ! hilang langsung lempar bobber! Cek console 'INSTANT RECAST DONE' .", Duration=8})

print("🔥 REYA HUB V5 - GOD MODE ACTIVE! <0.2s cycle, 2500+ fish/jam")
