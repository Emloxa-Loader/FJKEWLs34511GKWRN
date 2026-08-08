-- =========================================================================
-- EMLOXA WARE: EVADE (PLACE ID: 9872472334) – FPS OPTİMİZASYONLU v3
-- SMART NEXTBOT SCAN, ANTI-LAG ESP (NO DUPLICATES), TRUE SPEED (X/Z ONLY)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local Workspace = game:GetService("Workspace")
    local Lighting = game:GetService("Lighting")
    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera

    -- ==========================================
    -- GLOBAL AYARLAR & DEĞİŞKENLER
    -- ==========================================
    local Connections = {}
    local ActiveESPs = {}
    local DownedTimers = {}
    local CurrentPlatform = nil
    local PreReviveCFrame = nil
    local AwaitingReviveTeleport = false
    local TargetedNextbot = nil

    local Settings = {
        Movement = {
            SpeedEnabled = false, SpeedValue = 40,
            FlyEnabled = false, FlySpeed = 50,
            AutoBhop = false, EmoteDash = false
        },
        CarrySystem = {
            AutoMode = false,
            State = "Idle",
            TargetPlayer = nil
        },
        Exploits = {
            AutoReviveSelf = false, AutoReviveAura = false,
            TeleportBackOnRevive = false, ReviveTPDelay = 0,
            AutoVote = false, MapNumber = 1, LastReviveCheck = 0,
            LoopTPNextbot = false
        },
        Visuals = {
            PlayerESP = false, BotESP = false, TicketESP = false,
            DownedColor = true, Distance = true,
            PlayerHighlight = false, BotHighlight = false
        },
        World = {
            FullBright = false, NoFog = false,
            FOV = 70, ThirdPerson = false
        },
        Misc = { AntiAFK = true }
    }

    local IsHoldingSpace = false
    local IsHoldingCtrl = false

    local OrigLighting = {
        Brightness = Lighting.Brightness,
        Ambient = Lighting.Ambient,
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd
    }

    -- ==========================================
    -- HUD
    -- ==========================================
    local StatusGui = Instance.new("ScreenGui")
    StatusGui.Name = "EmloxaStatusUI"
    StatusGui.Parent = game:GetService("CoreGui") or LocalPlayer.PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 240, 0, 180)
    MainFrame.Position = UDim2.new(1, -250, 0.3, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BackgroundTransparency = 0.2
    MainFrame.BorderSizePixel = 0
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
    MainFrame.Parent = StatusGui

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(102, 85, 255)
    Stroke.Thickness = 2
    Stroke.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0, 30)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "EMLOXA CARRY HUD"
    TitleLabel.TextColor3 = Color3.fromRGB(102, 85, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.Parent = MainFrame

    local StateLabel = Instance.new("TextLabel")
    StateLabel.Size = UDim2.new(1, -20, 0, 25)
    StateLabel.Position = UDim2.new(0, 10, 0, 35)
    StateLabel.BackgroundTransparency = 1
    StateLabel.Text = "System State: IDLE"
    StateLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StateLabel.Font = Enum.Font.Gotham
    StateLabel.TextSize = 12
    StateLabel.TextXAlignment = Enum.TextXAlignment.Left
    StateLabel.Parent = MainFrame

    local TargetLabel = Instance.new("TextLabel")
    TargetLabel.Size = UDim2.new(1, -20, 0, 25)
    TargetLabel.Position = UDim2.new(0, 10, 0, 60)
    TargetLabel.BackgroundTransparency = 1
    TargetLabel.Text = "Target: None"
    TargetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TargetLabel.Font = Enum.Font.Gotham
    TargetLabel.TextSize = 12
    TargetLabel.TextXAlignment = Enum.TextXAlignment.Left
    TargetLabel.Parent = MainFrame

    local ManualKeyLabel = Instance.new("TextLabel")
    ManualKeyLabel.Size = UDim2.new(1, -20, 0, 50)
    ManualKeyLabel.Position = UDim2.new(0, 10, 0, 90)
    ManualKeyLabel.BackgroundTransparency = 1
    ManualKeyLabel.Text = "[H] -> Manual Step 1: Teleport & Pick\n[J] -> Manual Step 2: Lift to Sky\n[K] -> Manual Step 3: Drop & Revive"
    ManualKeyLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    ManualKeyLabel.Font = Enum.Font.Gotham
    ManualKeyLabel.TextSize = 11
    ManualKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
    ManualKeyLabel.Parent = MainFrame

    local function UpdateHUD()
        StateLabel.Text = "System State: " .. Settings.CarrySystem.State:upper()
        if Settings.CarrySystem.TargetPlayer then
            TargetLabel.Text = "Target: " .. Settings.CarrySystem.TargetPlayer.Name
        else
            TargetLabel.Text = "Target: None"
        end
    end

    -- ==========================================
    -- GELİŞMİŞ OYUNCU (DOWNED) BULUCU
    -- ==========================================
    local function IsPlayerDowned(p)
        if not p then return false end
        local char = p.Character
        if char and (char:GetAttribute("Downed") or char:FindFirstChild("ImageLabel")) then 
            return true 
        end
        local wsPlayers = Workspace:FindFirstChild("Players")
        if wsPlayers then
            local pFolder = wsPlayers:FindFirstChild(p.Name)
            if pFolder then
                local pChar = pFolder:FindFirstChild(p.Name)
                if pChar and pChar:FindFirstChild("ImageLabel") then
                    return true
                end
            end
        end
        return false
    end

    -- ==========================================
    -- LAG-FREE ESP SİSTEMİ (DUPLICATE KORUMALI)
    -- ==========================================
    local function CreateESP(target, nameText, color, attachPart, yOffset, useHighlight)
        -- Eğer hedefin üstünde halihazırda ESP Tag'i varsa asla ikinciyi oluşturma (LAG FIX)
        if not target or not attachPart or target:FindFirstChild("EmloxaESP_Tag") then return end
        
        local tag = Instance.new("Folder")
        tag.Name = "EmloxaESP_Tag"
        tag.Parent = target

        if useHighlight then
            local highlight = Instance.new("Highlight")
            highlight.Name = "EmloxaHighlightESP"
            highlight.Adornee = target
            highlight.FillColor = color
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = color
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = target
            table.insert(ActiveESPs, {
                Target = target,
                Part = attachPart,
                Label = nil,
                BaseText = nameText,
                Highlight = highlight,
                Billboard = nil,
                CurrentColor = color
            })
            return
        end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "EmloxaTextESP"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, yOffset, 0)
        billboard.Adornee = attachPart
        billboard.Parent = attachPart

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = nameText
        label.TextColor3 = color
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextStrokeTransparency = 0
        label.Parent = billboard

        table.insert(ActiveESPs, {
            Target = target,
            Part = attachPart,
            Label = label,
            BaseText = nameText,
            Highlight = nil,
            Billboard = billboard,
            CurrentColor = color
        })
    end

    local function RemoveESP(target)
        if not target then return end
        if target:FindFirstChild("EmloxaESP_Tag") then target.EmloxaESP_Tag:Destroy() end
        if target:FindFirstChild("EmloxaHighlightESP") then target.EmloxaHighlightESP:Destroy() end
        for _, v in pairs(target:GetDescendants()) do
            if v.Name == "EmloxaTextESP" then v:Destroy() end
        end
        for i = #ActiveESPs, 1, -1 do
            if ActiveESPs[i].Target == target then table.remove(ActiveESPs, i) end
        end
    end

    -- ==========================================
    -- MENÜ SEKMELERİ
    -- ==========================================
    local MoveTab = Window:CreateTab("Movement")
    MoveTab:CreateToggle("Enable True Speed", function(s) Settings.Movement.SpeedEnabled = s end)
    MoveTab:CreateSlider("Speed Velocity Value", 16, 200, 40, function(v) Settings.Movement.SpeedValue = v end)
    MoveTab:CreateToggle("Enable Fly Mode", function(s) Settings.Movement.FlyEnabled = s end)
    MoveTab:CreateSlider("Fly Velocity Value", 20, 200, 50, function(v) Settings.Movement.FlySpeed = v end)
    MoveTab:CreateToggle("Auto Bhop (Hold Space)", function(s) Settings.Movement.AutoBhop = s end)
    MoveTab:CreateToggle("Emote Dash Spam (G + F)", function(s) Settings.Movement.EmoteDash = s end)

    local CarryTab = Window:CreateTab("Carry")
    CarryTab:CreateToggle("Enable Auto Carry Loop", function(s)
        Settings.CarrySystem.AutoMode = s
        if not s then Settings.CarrySystem.State = "Idle"; Settings.CarrySystem.TargetPlayer = nil UpdateHUD() end
    end)
    CarryTab:CreateButton("Reset Carry State", function()
        Settings.CarrySystem.State = "Idle"
        Settings.CarrySystem.TargetPlayer = nil
        if CurrentPlatform then CurrentPlatform:Destroy(); CurrentPlatform = nil end
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        UpdateHUD()
    end)

    local ExploitTab = Window:CreateTab("Exploits")
    ExploitTab:CreateToggle("Auto Revive Aura (Lag-Free)", function(s) Settings.Exploits.AutoReviveAura = s end)
    ExploitTab:CreateToggle("Auto Revive Loop (Self)", function(s) Settings.Exploits.AutoReviveSelf = s end)
    ExploitTab:CreateToggle("TP Back After Revive", function(s) Settings.Exploits.TeleportBackOnRevive = s end)
    ExploitTab:CreateSlider("Revive TP Delay (Sec)", 0, 10, 0, function(v) Settings.Exploits.ReviveTPDelay = v end)
    ExploitTab:CreateToggle("Loop TP to Nextbot", function(s)
        Settings.Exploits.LoopTPNextbot = s
        if not s then TargetedNextbot = nil end
    end)
    ExploitTab:CreateDropdown("Select Map to Vote", {"Map 1", "Map 2", "Map 3", "Map 4"}, "Map 1", function(opt)
        Settings.Exploits.MapNumber = tonumber(opt:match("%d+"))
    end)
    ExploitTab:CreateToggle("Auto Vote Map Loop", function(s) Settings.Exploits.AutoVote = s end)

    local EspTab = Window:CreateTab("Visuals")
    EspTab:CreateToggle("Players ESP", function(s) Settings.Visuals.PlayerESP = s
        if not s then for _, p in pairs(Players:GetPlayers()) do RemoveESP(p.Character) end end
    end)
    EspTab:CreateToggle("Players Highlight Mode", function(s) 
        Settings.Visuals.PlayerHighlight = s 
        for _, p in pairs(Players:GetPlayers()) do RemoveESP(p.Character) end 
    end)
    EspTab:CreateToggle("Highlight Downed Players", function(s) Settings.Visuals.DownedColor = s end)
    EspTab:CreateToggle("Show Distance", function(s) Settings.Visuals.Distance = s end)
    
    EspTab:CreateToggle("NextBots ESP", function(s) Settings.Visuals.BotESP = s
        if not s then
            for i = #ActiveESPs, 1, -1 do
                if ActiveESPs[i].Target and ActiveESPs[i].Target:IsDescendantOf(Workspace) and not Players:GetPlayerFromCharacter(ActiveESPs[i].Target) then
                    RemoveESP(ActiveESPs[i].Target)
                end
            end
        end
    end)
    EspTab:CreateToggle("NextBots Highlight Mode", function(s) 
        Settings.Visuals.BotHighlight = s 
        for i = #ActiveESPs, 1, -1 do
            if ActiveESPs[i].Target and not Players:GetPlayerFromCharacter(ActiveESPs[i].Target) then
                RemoveESP(ActiveESPs[i].Target)
            end
        end
    end)
    
    EspTab:CreateToggle("Ticket ESP", function(s) Settings.Visuals.TicketESP = s
        if not s then
            local tf = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Tickets")
            if tf then for _, t in pairs(tf:GetChildren()) do RemoveESP(t) end end
        end
    end)

    local WorldTab = Window:CreateTab("World")
    WorldTab:CreateToggle("FullBright", function(s) Settings.World.FullBright = s end)
    WorldTab:CreateToggle("No Fog", function(s) Settings.World.NoFog = s end)
    WorldTab:CreateSlider("Field of View", 70, 120, 70, function(v)
        Settings.World.FOV = v
        if Camera then Camera.FieldOfView = v end
    end)
    WorldTab:CreateToggle("Force Third Person", function(s) Settings.World.ThirdPerson = s
        if s then LocalPlayer.CameraMaxZoomDistance = 15; LocalPlayer.CameraMinZoomDistance = 10
        else LocalPlayer.CameraMaxZoomDistance = 128; LocalPlayer.CameraMinZoomDistance = 0.5 end
    end)

    local MiscTab = Window:CreateTab("Misc")
    MiscTab:CreateButton("Unload EMLOXA WARE", function()
        for _, conn in pairs(Connections) do conn:Disconnect() end
        for _, p in pairs(Players:GetPlayers()) do RemoveESP(p.Character) end
        StatusGui:Destroy()
        if CurrentPlatform then CurrentPlatform:Destroy() end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
            if char.HumanoidRootPart:FindFirstChild("EmloxaVelocity") then char.HumanoidRootPart.EmloxaVelocity:Destroy() end
            if char.HumanoidRootPart:FindFirstChild("EmloxaSpeed") then char.HumanoidRootPart.EmloxaSpeed:Destroy() end
        end
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)

    -- ==========================================
    -- TUŞ KONTROLLERİ
    -- ==========================================
    table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.Space then IsHoldingSpace = true end
        if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl then IsHoldingCtrl = true end

        if input.KeyCode == Enum.KeyCode.H then
            local closest = nil
            local minDist = math.huge
            local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myHrp then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and IsPlayerDowned(p) then
                        local pHrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if pHrp then
                            local d = (pHrp.Position - myHrp.Position).Magnitude
                            if d < minDist then minDist = d; closest = p end
                        end
                    end
                end
            end
            if closest then
                Settings.CarrySystem.TargetPlayer = closest
                Settings.CarrySystem.State = "Teleporting"
                UpdateHUD()
                myHrp.CFrame = closest.Character.HumanoidRootPart.CFrame
                task.spawn(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                    task.wait(0.1)
                    Settings.CarrySystem.State = "Carrying"
                    UpdateHUD()
                end)
            end
        elseif input.KeyCode == Enum.KeyCode.J then
            local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myHrp and Settings.CarrySystem.TargetPlayer then
                Settings.CarrySystem.State = "Lifting"
                UpdateHUD()
                if CurrentPlatform then CurrentPlatform:Destroy() end
                CurrentPlatform = Instance.new("Part")
                CurrentPlatform.Size = Vector3.new(30, 1, 30)
                CurrentPlatform.CFrame = myHrp.CFrame + Vector3.new(0, 100, 0)
                CurrentPlatform.Anchored = true
                CurrentPlatform.Material = Enum.Material.Glass
                CurrentPlatform.Parent = Workspace
                task.wait(0.1)
                myHrp.CFrame = CurrentPlatform.CFrame + Vector3.new(0, 3, 0)
            end
        elseif input.KeyCode == Enum.KeyCode.K then
            Settings.CarrySystem.State = "Reviving"
            UpdateHUD()
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
            task.spawn(function()
                local startTime = tick()
                while tick() - startTime < 4 do
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    task.wait(0.05)
                end
                Settings.CarrySystem.State = "Idle"
                Settings.CarrySystem.TargetPlayer = nil
                if CurrentPlatform then CurrentPlatform:Destroy(); CurrentPlatform = nil end
                UpdateHUD()
            end)
        end
    end))

    table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Space then IsHoldingSpace = false end
        if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl then IsHoldingCtrl = false end
    end))

    -- ==========================================
    -- AKILLI NEXTBOT TARAMASI (SMART SCAN - LAG FIX)
    -- ==========================================
    local lastNextbotScan = 0
    local cachedNextbots = {}

    local function scanNextbots()
        local now = tick()
        if now - lastNextbotScan < 2 then return cachedNextbots end -- 2 saniyede bir tarar (Asla lag yapmaz)
        lastNextbotScan = now
        
        local npcs = {}
        local npcsFolder = ReplicatedStorage:FindFirstChild("NPCs")
        if npcsFolder then
            -- Sadece ana klasörlerin yüzeyine bakar, GetDescendants kullanmaz
            local function checkList(list)
                for _, v in pairs(list) do
                    if v:IsA("Model") and npcsFolder:FindFirstChild(v.Name) then
                        table.insert(npcs, v)
                    end
                end
            end
            checkList(Workspace:GetChildren())
            if Workspace:FindFirstChild("Game") then
                checkList(Workspace.Game:GetChildren())
            end
        end
        cachedNextbots = npcs
        return npcs
    end

    -- ==========================================
    -- ANA MOTOR (HEARTBEAT LOOP)
    -- ==========================================
    table.insert(Connections, RunService.Heartbeat:Connect(function(delta)
        if Settings.World.FullBright then
            Lighting.Brightness = 5
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(255,255,255)
        end

        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if hum and hrp then
            if Settings.Movement.FlyEnabled then
                if hrp:FindFirstChild("EmloxaSpeed") then hrp.EmloxaSpeed:Destroy() end -- Çakışmayı önle
                
                local bVel = hrp:FindFirstChild("EmloxaVelocity")
                if not bVel then
                    bVel = Instance.new("BodyVelocity")
                    bVel.Name = "EmloxaVelocity"
                    bVel.Parent = hrp
                end
                hum.PlatformStand = true
                bVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                local flyDir = hum.MoveDirection
                if IsHoldingSpace then flyDir += Vector3.new(0, 1, 0) end
                if IsHoldingCtrl then flyDir += Vector3.new(0, -1, 0) end
                if flyDir.Magnitude > 0 then flyDir = flyDir.Unit end
                bVel.Velocity = flyDir * Settings.Movement.FlySpeed
            else
                if hum.PlatformStand then hum.PlatformStand = false end
                if hrp:FindFirstChild("EmloxaVelocity") then hrp.EmloxaVelocity:Destroy() end

                -- KUSURSUZ TRUE SPEED (Sadece X/Z, Y Serbest Bırakıldı)
                if Settings.Movement.SpeedEnabled and hum.MoveDirection.Magnitude > 0 then
                    local bv = hrp:FindFirstChild("EmloxaSpeed")
                    if not bv then
                        bv = Instance.new("BodyVelocity")
                        bv.Name = "EmloxaSpeed"
                        bv.MaxForce = Vector3.new(100000, 0, 100000) -- Y'de HİÇBİR GÜÇ YOK (Yerçekimi çalışır)
                        bv.Parent = hrp
                    end
                    local moveDir = hum.MoveDirection.Unit
                    bv.Velocity = Vector3.new(moveDir.X * Settings.Movement.SpeedValue, 0, moveDir.Z * Settings.Movement.SpeedValue)
                else
                    if hrp:FindFirstChild("EmloxaSpeed") then hrp.EmloxaSpeed:Destroy() end
                end
            end

            if Settings.Movement.AutoBhop and IsHoldingSpace and hum.FloorMaterial ~= Enum.Material.Air then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end

            if Settings.Movement.EmoteDash and hum.MoveDirection.Magnitude > 0 then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.G, false, game)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.G, false, game)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end
        end

        if Settings.Exploits.LoopTPNextbot and hrp then
            if not TargetedNextbot or not TargetedNextbot.Parent or not TargetedNextbot:FindFirstChild("Hitbox") then
                local npcs = scanNextbots()
                for _, b in ipairs(npcs) do
                    if b:FindFirstChild("Hitbox") then
                        TargetedNextbot = b
                        break
                    end
                end
            end
            if TargetedNextbot and TargetedNextbot:FindFirstChild("Hitbox") then
                hrp.CFrame = TargetedNextbot.Hitbox.CFrame + Vector3.new(0, 3, 0)
            end
        end

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                if IsPlayerDowned(p) then
                    if not DownedTimers[p] then DownedTimers[p] = tick() end
                else
                    DownedTimers[p] = nil
                end
            end
        end

        if Settings.CarrySystem.AutoMode and hrp then
            if Settings.CarrySystem.State == "Idle" then
                for p, startTime in pairs(DownedTimers) do
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and (tick() - startTime >= 5) then
                        Settings.CarrySystem.TargetPlayer = p
                        Settings.CarrySystem.State = "Teleporting"
                        UpdateHUD()
                        break
                    end
                end
            elseif Settings.CarrySystem.State == "Teleporting" and Settings.CarrySystem.TargetPlayer then
                local targetHrp = Settings.CarrySystem.TargetPlayer.Character and Settings.CarrySystem.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetHrp then
                    hrp.CFrame = targetHrp.CFrame
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                    task.wait(0.2)
                    Settings.CarrySystem.State = "Lifting"
                    UpdateHUD()
                else
                    Settings.CarrySystem.State = "Idle"
                    UpdateHUD()
                end
            elseif Settings.CarrySystem.State == "Lifting" then
                if CurrentPlatform then CurrentPlatform:Destroy() end
                CurrentPlatform = Instance.new("Part")
                CurrentPlatform.Size = Vector3.new(30, 1, 30)
                CurrentPlatform.CFrame = hrp.CFrame + Vector3.new(0, 100, 0)
                CurrentPlatform.Anchored = true
                CurrentPlatform.Material = Enum.Material.Glass
                CurrentPlatform.Parent = Workspace
                task.wait(0.1)
                hrp.CFrame = CurrentPlatform.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.2)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
                Settings.CarrySystem.State = "Reviving"
                UpdateHUD()
            elseif Settings.CarrySystem.State == "Reviving" and Settings.CarrySystem.TargetPlayer then
                if IsPlayerDowned(Settings.CarrySystem.TargetPlayer) then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                else
                    if CurrentPlatform then CurrentPlatform:Destroy(); CurrentPlatform = nil end
                    Settings.CarrySystem.State = "Idle"
                    Settings.CarrySystem.TargetPlayer = nil
                    UpdateHUD()
                end
            end
        end

        if Settings.Exploits.AutoReviveAura and char and hrp then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and IsPlayerDowned(p) then
                    local pRoot = p.Character:FindFirstChild("HumanoidRootPart")
                    if pRoot and (pRoot.Position - hrp.Position).Magnitude < 15 then
                        local prompt = p.Character:FindFirstChildOfClass("ProximityPrompt") or p.Character:GetComponentOfClass("ProximityPrompt")
                        if prompt then fireproximityprompt(prompt) end
                    end
                end
            end
        end

        if Settings.Exploits.AutoReviveSelf and char then
            if IsPlayerDowned(LocalPlayer) then
                if Settings.Exploits.TeleportBackOnRevive and hrp and not AwaitingReviveTeleport then
                    PreReviveCFrame = hrp.CFrame
                    AwaitingReviveTeleport = true
                end
                if tick() - Settings.Exploits.LastReviveCheck >= 3 then
                    Settings.Exploits.LastReviveCheck = tick()
                    ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
                end
            elseif not IsPlayerDowned(LocalPlayer) and AwaitingReviveTeleport then
                AwaitingReviveTeleport = false
                if PreReviveCFrame and Settings.Exploits.TeleportBackOnRevive then
                    local targetCFrame = PreReviveCFrame
                    PreReviveCFrame = nil
                    task.spawn(function()
                        if Settings.Exploits.ReviveTPDelay > 0 then task.wait(Settings.Exploits.ReviveTPDelay) else task.wait() end
                        local curChar = LocalPlayer.Character
                        local curHrp = curChar and curChar:FindFirstChild("HumanoidRootPart")
                        if curHrp then curHrp.CFrame = targetCFrame end
                    end)
                end
            end
        end

        if Settings.Exploits.AutoVote then
            local ev = ReplicatedStorage:FindFirstChild("Events")
            if ev and ev:FindFirstChild("Player") and ev.Player:FindFirstChild("Vote") then
                ev.Player.Vote:FireServer(Settings.Exploits.MapNumber)
            end
        end

        -- ESP OLUŞTURMA (Artık sil-yükle yapmıyor, sadece olmayanlara ekliyor)
        if Settings.Visuals.PlayerESP then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if not p.Character:FindFirstChild("EmloxaESP_Tag") then
                        local color = IsPlayerDowned(p) and Color3.new(0.9, 0.1, 0.1) or Color3.new(0.4, 0.8, 0.4)
                        local text = IsPlayerDowned(p) and (p.Name .. " [DOWNED]") or p.Name
                        CreateESP(p.Character, text, color, p.Character.HumanoidRootPart, 2, Settings.Visuals.PlayerHighlight)
                    end
                end
            end
        end

        if Settings.Visuals.BotESP then
            local npcs = scanNextbots()
            for _, b in ipairs(npcs) do
                local part = b:FindFirstChild("Hitbox") or b:FindFirstChild("HumanoidRootPart")
                if part and not b:FindFirstChild("EmloxaESP_Tag") then
                    CreateESP(b, b.Name, Color3.new(0.8, 0.2, 0.2), part, 3, Settings.Visuals.BotHighlight)
                end
            end
        end

        if Settings.Visuals.TicketESP then
            local tf = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Tickets")
            if tf then
                for _, t in pairs(tf:GetChildren()) do
                    if t:IsA("BasePart") and not t:FindFirstChild("EmloxaESP_Tag") then 
                        CreateESP(t, "Ticket", Color3.fromRGB(255, 215, 0), t, 1, false) 
                    end
                end
            end
        end

        -- ESP MESAFE VE DİNAMİK RENK GÜNCELLEMESİ (Lag olmadan renkleri anlık değiştirir)
        local camPos = Camera and Camera.CFrame.Position or Vector3.new(0,0,0)
        for i = #ActiveESPs, 1, -1 do
            local esp = ActiveESPs[i]
            if esp.Target and esp.Target.Parent and esp.Part and esp.Part.Parent then
                local p = Players:GetPlayerFromCharacter(esp.Target)
                if p then
                    local isDown = IsPlayerDowned(p)
                    esp.CurrentColor = isDown and Color3.new(0.9, 0.1, 0.1) or Color3.new(0.4, 0.8, 0.4)
                    esp.BaseText = isDown and (p.Name .. " [DOWNED]") or p.Name
                end

                if esp.Label then
                    esp.Label.TextColor3 = esp.CurrentColor
                    if Settings.Visuals.Distance then
                        local dist = math.floor((camPos - esp.Part.Position).Magnitude)
                        esp.Label.Text = esp.BaseText .. " [" .. dist .. "m]"
                    else
                        esp.Label.Text = esp.BaseText
                    end
                end
                
                if esp.Highlight then
                    esp.Highlight.FillColor = esp.CurrentColor
                    esp.Highlight.OutlineColor = esp.CurrentColor
                end
            else
                if esp.Highlight then esp.Highlight:Destroy() end
                if esp.Billboard then esp.Billboard:Destroy() end
                table.remove(ActiveESPs, i)
            end
        end

        if Settings.World.FOV ~= 70 and Camera then Camera.FieldOfView = Settings.World.FOV end
    end))
end

return GameModule
