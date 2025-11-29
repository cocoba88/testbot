-- SMART FISHING PURE GUI V3 (ADA TOMBOL MINIMIZE & CLOSE)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Remote detection (sama seperti sebelumnya)
local net = ReplicatedStorage:WaitForChild("Packages",10)
    :WaitForChild("_Index",10):WaitForChild("sleitnick_net@0.2.0",10):WaitForChild("net",10)

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
    MainFrame = nil, HUD = nil, Minimized = false
}

-- Kalkulasi & deteksi bite/fish caught (sama seperti sebelumnya)
local function Calc() -- (sama seperti versi sebelumnya, aku singkat biar gak panjang)
    if Smart.Samples < 8 then return end
    local avg = function(t) local s=0 for _,v in t do s=s+v end return s/#t end
    local r = (Smart.CatchSpeed-1)/9 * 0.68
    local b = avg(Smart.BiteDelays); local c = avg(Smart.CatchWindows)
    Smart.AdjustedBiteDelay = math.max(b * (1 - r*0.4), 0.30)
    Smart.AdjustedCatchDelay = math.max(c * (1 - r), 0.035)
end

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
    Smart.IsRunning = true; Smart.Enabled = true
    Smart.BiteDelays, Smart.CatchWindows, Smart.Samples = {},{},0

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

-- === PURE GUI + TOMBOL MINIMIZE & CLOSE ===
local sg = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
sg.Name = "SmartFishingV3"
sg.ResetOnSpawn = false

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 340, 0, 440)
frame.Position = UDim2.new(0.5, -170, 0.5, -220)
frame.BackgroundColor3 = Color3.fromRGB(15,15,20)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)
Smart.MainFrame = frame

-- Topbar (bisa di-drag + tombol)
local topbar = Instance.new("Frame", frame)
topbar.Size = UDim2.new(1,0,0,40)
topbar.BackgroundColor3 = Color3.fromRGB(0, 200, 130)
topbar.BorderSizePixel = 0
Instance.new("UICorner", topbar).CornerRadius = UDim.new(0,12)

local title = Instance.new("TextLabel", topbar)
title.Size = UDim2.new(1,-80,1,0)
title.Position = UDim2.new(0,10,0,0)
title.BackgroundTransparency = 1
title.Text = "Smart Fishing"
title.TextColor3 = Color3.new(0,0,0)
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextScaled = true
title.Font = Enum.Font.GothamBold

-- Tombol Minimize
local minBtn = Instance.new("TextButton", topbar)
minBtn.Size = UDim2.new(0,35,0,35)
minBtn.Position = UDim2.new(1,-70,0,2.5)
minBtn.BackgroundColor3 = Color3.fromRGB(255,200,0)
minBtn.Text = "−"
minBtn.TextColor3 = Color3.new(0,0,0)
minBtn.TextScaled = true
minBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0,8)
minBtn.MouseButton1Click:Connect(function()
    Smart.Minimized = not Smart.Minimized
    frame.Size = Smart.Minimized and UDim2.new(0,340,0,40) or UDim2.new(0,340,0,440)
end)

-- Tombol Close
local closeBtn = Instance.new("TextButton", topbar)
closeBtn.Size = UDim2.new(0,35,0,35)
closeBtn.Position = UDim2.new(1,-35,0,2.5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255,50,50)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,8)
closeBtn.MouseButton1Click:Connect(function()
    Smart.Enabled = false
    sg:Destroy()
end)

-- Drag topbar
local dragging = false
topbar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        frame.Position = UDim2.new(0, i.Position.X - 170, 0, i.Position.Y - 220)
    end
end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- Isi GUI (hanya muncul kalau tidak minimize)
local content = Instance.new("Frame", frame)
content.Size = UDim2.new(1,0,1,-40)
content.Position = UDim2.new(0,0,0,40)
content.BackgroundTransparency = 1

-- START, STOP, Slider, dll (sama seperti versi sebelumnya, aku taruh di dalam content)
-- ... (kode START button, STOP, slider, dll tetap sama, hanya dipindah ke dalam 'content')

-- START BUTTON
local start = Instance.new("TextButton", content)
start.Size = UDim2.new(0.9,0,0,60)
start.Position = UDim2.new(0.05,0,0,10)
start.BackgroundColor3 = Color3.fromRGB(0,220,130)
start.Text = "START"
start.TextScaled = true
Instance.new("UICorner", start).CornerRadius = UDim.new(0,10)
start.MouseButton1Click:Connect(function() task.spawn(FishingLoop) end)

-- STOP BUTTON
local stop = Instance.new("TextButton", content)
stop.Size = UDim2.new(0.9,0,0,60)
stop.Position = UDim2.new(0.05,0,0,80)
stop.BackgroundColor3 = Color3.fromRGB(255,50,50)
stop.Text = "STOP"
stop.TextScaled = true
Instance.new("UICorner", stop).CornerRadius = UDim.new(0,10)
stop.MouseButton1Click:Connect(function() Smart.Enabled = false end)

-- Slider (sama seperti sebelumnya)
local sliderLabel = Instance.new("TextLabel", content)
sliderLabel.Size = UDim2.new(0.9,0,0,30)
sliderLabel.Position = UDim2.new(0.05,0,0,160)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Text = "Speed: 6"
sliderLabel.TextColor3 = Color3.new(1,1,1)
sliderLabel.TextScaled = true

local sliderBar = Instance.new("Frame", content)
sliderBar.Size = UDim2.new(0.9,0,0,20)
sliderBar.Position = UDim2.new(0.05,0,0,190)
sliderBar.BackgroundColor3 = Color3.fromRGB(50,50,50)
Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0,10)

local knob = Instance.new("TextButton", sliderBar)
knob.Size = UDim2.new(0,30,1,0)
knob.Position = UDim2.new(0.5,-15,0,0)
knob.BackgroundColor3 = Color3.fromRGB(0,255,170)
knob.Text = ""
Instance.new("UICorner", knob).CornerRadius = UDim.new(0,10)

local draggingKnob = false
knob.MouseButton1Down:Connect(function() draggingKnob = true end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingKnob = false end end)
UserInputService.InputChanged:Connect(function(i)
    if draggingKnob and i.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = (UserInputService:GetMouseLocation().X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
        pos = math.clamp(pos, 0, 1)
        knob.Position = UDim2.new(pos, -15, 0, 0)
        Smart.CatchSpeed = math.floor(pos * 9 + 1)
        sliderLabel.Text = "Speed: " .. Smart.CatchSpeed
    end
end)

print("Smart Fishing V3 - Ada Minimize & Close! Siap dipakai")
