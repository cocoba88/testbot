-- SMART FISHING STANDALONE PURE GUI (NO LIBRARY - 100% PASTI JALAN)
-- Paste ini ke file baru di GitHub-mu (misal: SmartFishing.lua)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Cari remote otomatis (update 2025)
local net = ReplicatedStorage:WaitForChild("Packages", 10)
    :WaitForChild("_Index", 10)
    :WaitForChild("sleitnick_net@0.2.0", 10)
    :WaitForChild("net", 10)

local Remotes = {
    EquipTool = net:FindFirstChild("RE/EquipToolFromHotbar") or net:FindFirstChild("EquipToolFromHotbar"),
    ChargeRod = net:FindFirstChild("RF/ChargeFishingRod") or net:FindFirstChild("ChargeFishingRod"),
    StartMini = net:FindFirstChild("RF/RequestFishingMinigameStarted") or net:FindFirstChild("RequestFishingMinigameStarted"),
    FinishFish = net:FindFirstChild("RE/FishingCompleted") or net:FindFirstChild("FishingCompleted"),
    FishCaught = net:FindFirstChild("RE/FishCaught") or net:FindFirstChild("FishCaught"),
}

-- Smart State
local Smart = {
    Enabled = false, IsRunning = false,
    CatchSpeed = 6,
    BiteDelays = {}, CatchWindows = {}, Samples = 0,
    AdjustedBiteDelay = 0.9, AdjustedCatchDelay = 0.14,
    LastCast = 0, LastBite = 0,
    GUI = nil, HUD = nil
}

local function Calc()
    if Smart.Samples < 8 then return end
    local avg = function(t) local s=0 for _,v in t do s=s+v end return s/#t end
    local r = (Smart.CatchSpeed-1)/9 * 0.68
    local b = avg(Smart.BiteDelays); local c = avg(Smart.CatchWindows)
    Smart.AdjustedBiteDelay = math.max(b * (1 - r*0.4), 0.30)
    Smart.AdjustedCatchDelay = math.max(c * (1 - r), 0.035)
end

-- Deteksi bite
task.spawn(function()
    local pgui = LocalPlayer:WaitForChild("PlayerGui")
    while task.wait(0.04) do
        if not Smart.Enabled then continue end
        local gui = pgui:FindFirstChild("FishingMinigame") or pgui:FindFirstChild("Small Notification")
        if gui and gui:FindFirstChild("Exclamation") and gui.Exclamation.Visible then
            Smart.LastBite = tick()
            table.insert(Smart.BiteDelays, Smart.LastBite - Smart.LastCast)
            if #Smart.BiteDelays > 30 then table.remove(Smart.BiteDelays,1) end
            Smart.Samples = Smart.Samples + 1
            Calc()
        end
    end
end)

if Remotes.FishCaught then
    Remotes.FishCaught.OnClientEvent:Connect(function()
        if Smart.Enabled and Smart.LastBite > 0 then
            table.insert(Smart.CatchWindows, tick() - Smart.LastBite)
            if #Smart.CatchWindows > 30 then table.remove(Smart.CatchWindows,1) end
            Calc()
        end
    end)
end

local function FishingLoop()
    if Smart.IsRunning then return end
    Smart.IsRunning = true
    Smart.Enabled = true
    Smart.BiteDelays, Smart.CatchWindows, Smart.Samples = {},{},0

    -- Equip rod
    if Remotes.EquipTool then pcall(function() Remotes.EquipTool:FireServer(1) end) task.wait(1.5) end

    while Smart.Enabled do
        Smart.LastCast = tick()
        if Remotes.ChargeRod then pcall(function() Remotes.ChargeRod:InvokeServer(100) end) end
        task.wait(0.1)
        if Remotes.StartMini then pcall(function() Remotes.StartMini:InvokeServer(-1.233184814453125, 0.9945034885633273) end) end
        task.wait(Smart.AdjustedBiteDelay + 0.15)
        for i=1,12 do
            if Remotes.FinishFish then pcall(function() Remotes.FinishFish:FireServer() end) end
            task.wait(Smart.AdjustedCatchDelay)
        end
        task.wait(0.2)
    end
    Smart.IsRunning = false
end

-- === PURE GUI (pasti muncul di semua executor) ===
local sg = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
sg.Name = "SmartFishingPure"
sg.ResetOnSpawn = false

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 320, 0, 420)
frame.Position = UDim2.new(0.5, -160, 0.5, -210)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,50)
title.BackgroundTransparency = 1
title.Text = "Smart Fishing"
title.TextColor3 = Color3.fromRGB(0, 255, 170)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

-- START BUTTON
local start = Instance.new("TextButton", frame)
start.Size = UDim2.new(0.9,0,0,60)
start.Position = UDim2.new(0.05,0,0,60)
start.BackgroundColor3 = Color3.fromRGB(0, 220, 130)
start.Text = "START"
start.TextColor3 = Color3.new(0,0,0)
start.TextScaled = true
start.Font = Enum.Font.GothamBold
Instance.new("UICorner", start).CornerRadius = UDim.new(0,10)
start.MouseButton1Click:Connect(function() task.spawn(FishingLoop) end)

-- STOP BUTTON
local stop = Instance.new("TextButton", frame)
stop.Size = UDim2.new(0.9,0,0,60)
stop.Position = UDim2.new(0.05,0,0,130)
stop.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
stop.Text = "STOP"
stop.TextColor3 = Color3.new(1,1,1)
stop.TextScaled = true
stop.Font = Enum.Font.GothamBold
Instance.new("UICorner", stop).CornerRadius = UDim.new(0,10)
stop.MouseButton1Click:Connect(function() Smart.Enabled = false end)

-- SLIDER (bisa digeser!)
local sliderLabel = Instance.new("TextLabel", frame)
sliderLabel.Size = UDim2.new(0.9,0,0,30)
sliderLabel.Position = UDim2.new(0.05,0,0,210)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "Speed: 6"
sliderLabel.TextColor3 = Color3.new(1,1,1)
sliderLabel.TextScaled = true

local sliderBar = Instance.new("Frame", frame)
sliderBar.Size = UDim2.new(0.9,0,0,20)
sliderBar.Position = UDim2.new(0.05,0,0,240)
sliderBar.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0,10)

local knob = Instance.new("TextButton", sliderBar)
knob.Size = UDim2.new(0,30,1,0)
knob.Position = UDim2.new(0.5,-15,0,0)
knob.BackgroundColor3 = Color3.fromRGB(0,255,170)
knob.Text = ""
Instance.new("UICorner", knob).CornerRadius = UDim.new(0,10)

local dragging = false
knob.MouseButton1Down:Connect(function() dragging = true end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = (UserInputService:GetMouseLocation().X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
        pos = math.clamp(pos, 0, 1)
        knob.Position = UDim2.new(pos, -15, 0, 0)
        Smart.CatchSpeed = math.floor(pos * 9 + 1)
        sliderLabel.Text = "Speed: " .. Smart.CatchSpeed
    end
end)

-- Drag GUI
local draggingFrame = false
frame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingFrame = true end end)
UserInputService.InputChanged:Connect(function(i)
    if draggingFrame and i.UserInputType == Enum.UserInputType.MouseMovement then
        frame.Position = UDim2.new(0, i.Position.X - 160, 0, i.Position.Y - 210)
    end
end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingFrame = false end end)

print("Smart Fishing Pure GUI - Siap dipakai! Execute dengan nama apa saja di GitHub-mu")
