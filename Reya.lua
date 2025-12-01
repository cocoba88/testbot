-- ============================================
-- REYA HUB - RAYFIELD UI VERSION
-- ============================================

repeat task.wait() until game:IsLoaded()
task.wait(1)

print("🔄 Loading Reya Hub...")

-- ============================================
-- LOAD RAYFIELD UI LIBRARY
-- ============================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ============================================
-- SERVICES & VARIABLES
-- ============================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ============================================
-- GAME MODULES
-- ============================================
local net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================
local function MoveTo(cframe)
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = cframe
        end
    end)
end

local function equipRod()
    pcall(function()
        net:WaitForChild("RE/EquipToolFromHotbar"):FireServer(1)
    end)
end

local function SellAll()
    pcall(function()
        net:WaitForChild("RF/SellAllItems"):InvokeServer()
    end)
end

-- ============================================
-- FISHING FUNCTIONS
-- ============================================
_G.AutoFish = false
_G.ActiveFishing = false
_G.FishingMethod = "Instant"
_G.InstantDelay = 0.1

local function InstantReel()
    pcall(function()
        net:WaitForChild("RE/FishingCompleted"):FireServer()
    end)
end

local function StopFish()
    _G.ActiveFishing = false
    pcall(function()
        net:WaitForChild("RF/CancelFishingInputs"):InvokeServer()
    end)
end

-- Instant Fishing Loop
task.spawn(function()
    while task.wait() do
        if _G.AutoFish and _G.FishingMethod == "Instant" then
            pcall(function()
                _G.ActiveFishing = true
                local timestamp = Workspace:GetServerTimeNow()
                
                equipRod()
                task.wait(0.1)
                
                net:WaitForChild("RF/ChargeFishingRod"):InvokeServer(timestamp)
                
                local x = -0.7499996423721313 + (math.random(-500, 500) / 10000000)
                local y = 1 + (math.random(-500, 500) / 10000000)
                
                net:WaitForChild("RF/RequestFishingMinigameStarted"):InvokeServer(x, y)
                
                task.wait(0.1)
                _G.ActiveFishing = false
            end)
        end
    end
end)

-- Auto reel when fish caught
net["RE/ReplicateTextEffect"].OnClientEvent:Connect(function(data)
    if _G.AutoFish and _G.ActiveFishing and data then
        local myHead = Character and Character:FindFirstChild("Head")
        if myHead and data.Container == myHead then
            task.spawn(function()
                for i = 1, 3 do
                    task.wait(_G.InstantDelay)
                    InstantReel()
                end
            end)
        end
    end
end)

-- ============================================
-- AUTO SELL FUNCTION
-- ============================================
_G.AutoSell = false
_G.SellDelay = 20

task.spawn(function()
    while task.wait() do
        if _G.AutoSell then
            pcall(function()
                SellAll()
                task.wait(_G.SellDelay)
            end)
        end
    end
end)

-- ============================================
-- TELEPORT LOCATIONS
-- ============================================
local TeleportLocations = {
    ["Ancient Jungle"] = CFrame.new(1221.084228515625, 6.624999523162842, -544.1521606445312),
    ["Coral Reefs"] = CFrame.new(-3262.536376953125, 2.499969244003296, 2216.586181640625),
    ["Crater Island"] = CFrame.new(986.1575317382812, 3.1964468955993652, 5146.69970703125),
    ["Esoteric Depths"] = CFrame.new(983311.6767578125, -1302.8548583984375, 1394.7261962890625),
    ["Kohana"] = CFrame.new(-656.1355590820312, 17.250059127807617, 448.951171875),
    ["Kohana Volcano"] = CFrame.new(-554.2496948242188, 18.236753463745117, 117.22779846191406),
    ["Sisyphus Statue"] = CFrame.new(-3731.935546875, -135.0744171142578, -1014.7938232421875),
    ["Treasure Room"] = CFrame.new(-3560.293212890625, -279.07421875, -1605.2633056640625),
    ["Mount Hallow"] = CFrame.new(2144.46728515625, 80.88066864013672, 3269.4921875),
    ["Tropical Grove"] = CFrame.new(-2091.44580078125, 6.268016815185547, 3699.8486328125),
    ["Crystal Cavern"] = CFrame.new(-1723.7686767578125, -450.00048828125, 7205.43701171875),
    ["Crystal Falls"] = CFrame.new(-1955.166748046875, -447.50048828125, 7419.4140625),
}

-- ============================================
-- CREATE WINDOW
-- ============================================
local Window = Rayfield:CreateWindow({
    Name = "Reya Hub",
    LoadingTitle = "Reya Hub",
    LoadingSubtitle = "by Reya",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "ReyaHub"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "Reya Hub",
        Subtitle = "Key System",
        Note = "No Key Needed",
        FileName = "Key",
        SaveKey = false,
        GrabKeyFromSite = false,
        Key = {""}
    }
})

-- ============================================
-- HOME TAB
-- ============================================
local HomeTab = Window:CreateTab("🏠 Home", 4483362458)
local HomeSection = HomeTab:CreateSection("Welcome")

HomeTab:CreateParagraph({
    Title = "Reya Hub v1.0",
    Content = "Fish It automation script with multiple features.\n\nMade by: Reya"
})

local StatsSection = HomeTab:CreateSection("Statistics")

local FPSLabel = HomeTab:CreateLabel("FPS: Loading...")
local PingLabel = HomeTab:CreateLabel("Ping: Loading...")

-- Update stats
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local fps = math.floor(Workspace:GetRealPhysicsFPS())
            FPSLabel:Set("FPS: " .. tostring(fps))
            
            local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
            PingLabel:Set("Ping: " .. ping)
        end)
    end
end)

-- ============================================
-- FISHING TAB
-- ============================================
local FishingTab = Window:CreateTab("🎣 Fishing", 4483362458)
local AutoFishSection = FishingTab:CreateSection("Auto Fishing")

local AutoFishToggle = FishingTab:CreateToggle({
    Name = "Auto Fish",
    CurrentValue = false,
    Flag = "AutoFishToggle",
    Callback = function(Value)
        _G.AutoFish = Value
        if not Value then
            StopFish()
        end
        Rayfield:Notify({
            Title = "Auto Fish",
            Content = Value and "Enabled" or "Disabled",
            Duration = 3,
            Image = 4483362458
        })
    end,
})

local DelaySlider = FishingTab:CreateSlider({
    Name = "Reel Delay",
    Range = {0, 5},
    Increment = 0.1,
    Suffix = "seconds",
    CurrentValue = 0.1,
    Flag = "ReelDelaySlider",
    Callback = function(Value)
        _G.InstantDelay = Value
    end,
})

FishingTab:CreateButton({
    Name = "Equip Fishing Rod",
    Callback = function()
        equipRod()
        Rayfield:Notify({
            Title = "Success",
            Content = "Fishing rod equipped",
            Duration = 2,
            Image = 4483362458
        })
    end,
})

local SellSection = FishingTab:CreateSection("Auto Sell")

local AutoSellToggle = FishingTab:CreateToggle({
    Name = "Auto Sell",
    CurrentValue = false,
    Flag = "AutoSellToggle",
    Callback = function(Value)
        _G.AutoSell = Value
        Rayfield:Notify({
            Title = "Auto Sell",
            Content = Value and "Enabled" or "Disabled",
            Duration = 3,
            Image = 4483362458
        })
    end,
})

local SellDelaySlider = FishingTab:CreateSlider({
    Name = "Sell Delay",
    Range = {1, 60},
    Increment = 1,
    Suffix = "seconds",
    CurrentValue = 20,
    Flag = "SellDelaySlider",
    Callback = function(Value)
        _G.SellDelay = Value
    end,
})

FishingTab:CreateButton({
    Name = "Sell All Now",
    Callback = function()
        SellAll()
        Rayfield:Notify({
            Title = "Success",
            Content = "All fish sold",
            Duration = 2,
            Image = 4483362458
        })
    end,
})

-- ============================================
-- TELEPORT TAB
-- ============================================
local TeleportTab = Window:CreateTab("📍 Teleport", 4483362458)
local LocationSection = TeleportTab:CreateSection("Location Teleport")

local locationNames = {}
for name, _ in pairs(TeleportLocations) do
    table.insert(locationNames, name)
end
table.sort(locationNames)

local selectedLocation = locationNames[1]

local LocationDropdown = TeleportTab:CreateDropdown({
    Name = "Select Location",
    Options = locationNames,
    CurrentOption = locationNames[1],
    Flag = "LocationDropdown",
    Callback = function(Option)
        selectedLocation = Option
    end,
})

TeleportTab:CreateButton({
    Name = "Teleport to Location",
    Callback = function()
        if selectedLocation and TeleportLocations[selectedLocation] then
            MoveTo(TeleportLocations[selectedLocation])
            Rayfield:Notify({
                Title = "Teleported",
                Content = "Moved to " .. selectedLocation,
                Duration = 3,
                Image = 4483362458
            })
        end
    end,
})

local PlayerSection = TeleportTab:CreateSection("Player Teleport")

local function GetPlayerList()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player.Name)
        end
    end
    return #list > 0 and list or {"No Players"}
end

local playerList = GetPlayerList()
local selectedPlayer = playerList[1]

local PlayerDropdown = TeleportTab:CreateDropdown({
    Name = "Select Player",
    Options = playerList,
    CurrentOption = playerList[1],
    Flag = "PlayerDropdown",
    Callback = function(Option)
        selectedPlayer = Option
    end,
})

TeleportTab:CreateButton({
    Name = "Teleport to Player",
    Callback = function()
        if selectedPlayer and selectedPlayer ~= "No Players" then
            local targetPlayer = Players:FindFirstChild(selectedPlayer)
            if targetPlayer and targetPlayer.Character then
                local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    MoveTo(targetHRP.CFrame + Vector3.new(0, 3, 0))
                    Rayfield:Notify({
                        Title = "Teleported",
                        Content = "Moved to " .. selectedPlayer,
                        Duration = 3,
                        Image = 4483362458
                    })
                end
            end
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        playerList = GetPlayerList()
        PlayerDropdown:Refresh(playerList, true)
        Rayfield:Notify({
            Title = "Refreshed",
            Content = "Player list updated",
            Duration = 2,
            Image = 4483362458
        })
    end,
})

-- ============================================
-- MISC TAB
-- ============================================
local MiscTab = Window:CreateTab("⚙️ Misc", 4483362458)
local OxygenSection = MiscTab:CreateSection("Oxygen")

MiscTab:CreateButton({
    Name = "Bypass Oxygen",
    Callback = function()
        pcall(function()
            net["URE/UpdateOxygen"]:Destroy()
        end)
        Rayfield:Notify({
            Title = "Success",
            Content = "Oxygen bypass activated!",
            Duration = 3,
            Image = 4483362458
        })
    end,
})

-- ============================================
-- SERVER TAB
-- ============================================
local ServerTab = Window:CreateTab("🖥️ Server", 4483362458)
local ServerSection = ServerTab:CreateSection("Server Controls")

ServerTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end,
})

ServerTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        local success = pcall(function()
            local module = loadstring(game:HttpGet("https://raw.githubusercontent.com/raw-scriptpastebin/FE/main/Server_Hop_Settings"))()
            module:Teleport(game.PlaceId)
        end)
        
        if not success then
            Rayfield:Notify({
                Title = "Error",
                Content = "Server hop failed",
                Duration = 3,
                Image = 4483362458
            })
        end
    end,
})

local InfoSection = ServerTab:CreateSection("Server Information")

ServerTab:CreateParagraph({
    Title = "Job ID",
    Content = game.JobId
})

ServerTab:CreateButton({
    Name = "Copy Job ID",
    Callback = function()
        if setclipboard then
            setclipboard(game.JobId)
            Rayfield:Notify({
                Title = "Copied",
                Content = "Job ID copied to clipboard",
                Duration = 3,
                Image = 4483362458
            })
        end
    end,
})

-- ============================================
-- AUTO REJOIN ON DISCONNECT
-- ============================================
task.spawn(function()
    while task.wait(5) do
        if not LocalPlayer or not LocalPlayer:IsDescendantOf(game) then
            TeleportService:Teleport(game.PlaceId)
        end
    end
end)

TeleportService.TeleportInitFailed:Connect(function(player, teleportResult)
    if teleportResult == Enum.TeleportResult.Failure then
        TeleportService:Teleport(game.PlaceId)
    end
end)

-- ============================================
-- SUCCESS NOTIFICATION
-- ============================================
Rayfield:Notify({
    Title = "Reya Hub",
    Content = "Successfully loaded! Happy fishing! 🎣",
    Duration = 5,
    Image = 4483362458
})

print("╔═══════════════════════════════════════╗")
print("✅ REYA HUB LOADED!")
print("╠═══════════════════════════════════════╣")
print("Player:", LocalPlayer.Name)
print("PlaceID:", game.PlaceId)
print("╠═══════════════════════════════════════╣")
print("Features:")
print("  • Auto Fishing (Instant)")
print("  • Auto Sell")
print("  • 12+ Teleport Locations")
print("  • Player Teleport")
print("  • Oxygen Bypass")
print("  • Server Hop & Rejoin")
print("╚═══════════════════════════════════════╝")
