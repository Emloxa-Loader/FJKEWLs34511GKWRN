-- =========================================================================
-- EMLOXA WARE: EVADE (PLACE ID: 9872472334) – v6 ULTIMATE
-- CFrame Speed, Chams Highlight, FULL VISUAL BOOMBOX (MODERN, MOVABLE)
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
    local HttpService = game:GetService("HttpService")
    local MarketplaceService = game:GetService("MarketplaceService")

    local HUIParent = (gethui and gethui()) or game:GetService("CoreGui")
    local TweenService = game:GetService("TweenService")

    local Connections = {}
    local ActiveESPs = {}
    local DownedTimers = {}
    local CurrentPlatform = nil

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
        Vote = { AutoVote = false, MapNumber = 1 },
        Visuals = {
            PlayerESP = false, BotESP = false, TicketESP = false,
            DownedColor = true, Distance = true,
            PlayerHighlight = false, BotHighlight = false,
            VisualBoombox = false
        },
        World = { FullBright = false, NoFog = false, FOV = 70, ThirdPerson = false },
        Radio = {
            CurrentID = "",
            Loop = false,
            Volume = 0.5,
            Favorites = {},
            Playlist = {},
            NowPlayingIndex = 0
        }
    }

    local IsHoldingSpace = false
    local IsHoldingCtrl = false

    -- ==========================================
    -- HUD (taşınabilir, şık)
    -- ==========================================
    local StatusGui = Instance.new("ScreenGui")
    StatusGui.Name = "EmloxaStatusUI"
    StatusGui.Parent = HUIParent

    local MainHud = Instance.new("Frame")
    MainHud.Size = UDim2.new(0, 240, 0, 180)
    MainHud.Position = UDim2.new(1, -250, 0.3, 0)
    MainHud.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainHud.BackgroundTransparency = 0.15
    MainHud.BorderSizePixel = 0
    MainHud.Active = true
    Instance.new("UICorner", MainHud).CornerRadius = UDim.new(0, 10)
    MainHud.Parent = StatusGui
    Instance.new("UIStroke", MainHud).Color = Color3.fromRGB(102, 85, 255)

    -- (HUD içeriği aynı kalacak, kısaltıldı)
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0, 28)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "EMLOXA CARRY HUD"
    TitleLabel.TextColor3 = Color3.fromRGB(102, 85, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.Parent = MainHud

    local StateLabel = Instance.new("TextLabel")
    StateLabel.Size = UDim2.new(1, -20, 0, 25)
    StateLabel.Position = UDim2.new(0, 10, 0, 32)
    StateLabel.BackgroundTransparency = 1
    StateLabel.Text = "System State: IDLE"
    StateLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StateLabel.Font = Enum.Font.Gotham
    StateLabel.TextSize = 12
    StateLabel.TextXAlignment = Enum.TextXAlignment.Left
    StateLabel.Parent = MainHud

    local TargetLabel = Instance.new("TextLabel")
    TargetLabel.Size = UDim2.new(1, -20, 0, 25)
    TargetLabel.Position = UDim2.new(0, 10, 0, 60)
    TargetLabel.BackgroundTransparency = 1
    TargetLabel.Text = "Target: None"
    TargetLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TargetLabel.Font = Enum.Font.Gotham
    TargetLabel.TextSize = 12
    TargetLabel.TextXAlignment = Enum.TextXAlignment.Left
    TargetLabel.Parent = MainHud

    local ManualKeyLabel = Instance.new("TextLabel")
    ManualKeyLabel.Size = UDim2.new(1, -20, 0, 50)
    ManualKeyLabel.Position = UDim2.new(0, 10, 0, 90)
    ManualKeyLabel.BackgroundTransparency = 1
    ManualKeyLabel.Text = "[H] Teleport & Pick  [J] Lift  [K] Revive"
    ManualKeyLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    ManualKeyLabel.Font = Enum.Font.Gotham
    ManualKeyLabel.TextSize = 11
    ManualKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
    ManualKeyLabel.Parent = MainHud

    local function UpdateHUD()
        StateLabel.Text = "System State: " .. Settings.CarrySystem.State:upper()
        if Settings.CarrySystem.TargetPlayer then
            TargetLabel.Text = "Target: " .. Settings.CarrySystem.TargetPlayer.Name
        else
            TargetLabel.Text = "Target: None"
        end
    end

    -- ==========================================
    -- DOWNED CHECK
    -- ==========================================
    local function IsPlayerDowned(p)
        if not p then return false end
        local char = p.Character
        if char and (char:GetAttribute("Downed") or char:FindFirstChild("ImageLabel")) then return true end
        local wsPlayers = Workspace:FindFirstChild("Players")
        if wsPlayers then
            local pFolder = wsPlayers:FindFirstChild(p.Name)
            if pFolder then
                local pChar = pFolder:FindFirstChild(p.Name)
                if pChar and pChar:FindFirstChild("ImageLabel") then return true end
            end
        end
        return false
    end

    -- ==========================================
    -- CHAMS HIGHLIGHT (Always On Top)
    -- ==========================================
    local function CreateESP(target, nameText, color, attachPart, yOffset, useHighlight)
        if not target or not attachPart or target:FindFirstChild("EmloxaESP_Tag") then return end
        local tag = Instance.new("Folder")
        tag.Name = "EmloxaESP_Tag"
        tag.Parent = target

        if useHighlight then
            local highlight = Instance.new("Highlight")
            highlight.Name = "EmloxaChams"
            highlight.Adornee = target
            highlight.FillColor = color
            highlight.FillTransparency = 0.4
            highlight.OutlineColor = color
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = target
            table.insert(ActiveESPs, {Target = target, Part = attachPart, Highlight = highlight, CurrentColor = color})
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

        table.insert(ActiveESPs, {Target = target, Part = attachPart, Label = label, BaseText = nameText, Billboard = billboard, CurrentColor = color})
    end

    local function RemoveESP(target)
        if not target then return end
        if target:FindFirstChild("EmloxaESP_Tag") then target.EmloxaESP_Tag:Destroy() end
        if target:FindFirstChild("EmloxaChams") then target.EmloxaChams:Destroy() end
        for _, v in pairs(target:GetDescendants()) do if v.Name == "EmloxaTextESP" then v:Destroy() end end
        for i = #ActiveESPs, 1, -1 do
            if ActiveESPs[i].Target == target then table.remove(ActiveESPs, i) end
        end
    end

    -- ==========================================
    -- MENÜ SEKMELERİ
    -- ==========================================
    local MoveTab = Window:CreateTab("Movement")
    MoveTab:CreateToggle("Enable True Speed", function(s) Settings.Movement.SpeedEnabled = s end)
    MoveTab:CreateSlider("Speed Value", 16, 200, 40, function(v) Settings.Movement.SpeedValue = v end)
    MoveTab:CreateToggle("Enable Fly Mode", function(s) Settings.Movement.FlyEnabled = s end)
    MoveTab:CreateSlider("Fly Speed", 20, 200, 50, function(v) Settings.Movement.FlySpeed = v end)
    MoveTab:CreateToggle("Auto Bhop", function(s) Settings.Movement.AutoBhop = s end)
    MoveTab:CreateToggle("Emote Dash Spam", function(s) Settings.Movement.EmoteDash = s end)

    local CarryTab = Window:CreateTab("Carry")
    CarryTab:CreateToggle("Enable Auto Carry", function(s)
        Settings.CarrySystem.AutoMode = s
        if not s then Settings.CarrySystem.State = "Idle"; Settings.CarrySystem.TargetPlayer = nil; UpdateHUD() end
    end)
    CarryTab:CreateButton("Reset Carry", function()
        Settings.CarrySystem.State = "Idle"; Settings.CarrySystem.TargetPlayer = nil
        if CurrentPlatform then CurrentPlatform:Destroy(); CurrentPlatform = nil end
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        UpdateHUD()
    end)

    local VoteTab = Window:CreateTab("Vote")
    VoteTab:CreateDropdown("Map", {"Map 1","Map 2","Map 3","Map 4"}, "Map 1", function(o) Settings.Vote.MapNumber = tonumber(o:match("%d")) end)
    VoteTab:CreateToggle("Auto Vote", function(s) Settings.Vote.AutoVote = s end)

    local EspTab = Window:CreateTab("Visuals")
    EspTab:CreateToggle("Players ESP", function(s) Settings.Visuals.PlayerESP = s
        if not s then for _, p in pairs(Players:GetPlayers()) do RemoveESP(p.Character) end end
    end)
    EspTab:CreateToggle("Player Highlight (Chams)", function(s)
        Settings.Visuals.PlayerHighlight = s
        for _, p in pairs(Players:GetPlayers()) do RemoveESP(p.Character) end
    end)
    EspTab:CreateToggle("Downed Color", function(s) Settings.Visuals.DownedColor = s end)
    EspTab:CreateToggle("Show Distance", function(s) Settings.Visuals.Distance = s end)
    EspTab:CreateToggle("NextBots ESP", function(s) Settings.Visuals.BotESP = s
        if not s then for i=#ActiveESPs,1,-1 do if ActiveESPs[i].Target and not Players:GetPlayerFromCharacter(ActiveESPs[i].Target) then RemoveESP(ActiveESPs[i].Target) end end end
    end)
    EspTab:CreateToggle("NextBots Highlight", function(s)
        Settings.Visuals.BotHighlight = s
        for i=#ActiveESPs,1,-1 do if ActiveESPs[i].Target and not Players:GetPlayerFromCharacter(ActiveESPs[i].Target) then RemoveESP(ActiveESPs[i].Target) end end
    end)
    EspTab:CreateToggle("Ticket ESP", function(s) Settings.Visuals.TicketESP = s
        if not s then local tf=Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Tickets") if tf then for _,t in pairs(tf:GetChildren()) do RemoveESP(t) end end end
    end)

    -- Visual Boombox toggle
    local boomboxToggle = EspTab:CreateToggle("Visual Boombox", function(s)
        Settings.Visuals.VisualBoombox = s
        if s then
            if not hasBoomboxAccessory() then
                giveBoombox()
                if RadioGui then RadioGui.Enabled = true RadioOpen = true end
            else
                EspTab:CreateNotification("Error", "You already have the boombox!", 2)
            end
        else
            if RadioGui then RadioGui.Enabled = false end
            removeBoombox()
        end
    end)

    local WorldTab = Window:CreateTab("World")
    WorldTab:CreateToggle("FullBright", function(s) Settings.World.FullBright = s end)
    WorldTab:CreateToggle("No Fog", function(s) Settings.World.NoFog = s end)
    WorldTab:CreateSlider("FOV", 70, 120, 70, function(v) Settings.World.FOV = v if Camera then Camera.FieldOfView = v end end)
    WorldTab:CreateToggle("Force Third Person", function(s) Settings.World.ThirdPerson = s
        if s then LocalPlayer.CameraMaxZoomDistance = 15; LocalPlayer.CameraMinZoomDistance = 10
        else LocalPlayer.CameraMaxZoomDistance = 128; LocalPlayer.CameraMinZoomDistance = 0.5 end
    end)

    local MiscTab = Window:CreateTab("Misc")
    MiscTab:CreateButton("Unload", function()
        for _,c in ipairs(Connections) do c:Disconnect() end
        for _,p in pairs(Players:GetPlayers()) do RemoveESP(p.Character) end
        StatusGui:Destroy()
        if RadioGui then RadioGui:Destroy() end
        removeBoombox()
        if CurrentPlatform then CurrentPlatform:Destroy() end
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
            if char.HumanoidRootPart:FindFirstChild("EmloxaVelocity") then char.HumanoidRootPart.EmloxaVelocity:Destroy() end
        end
        local ui = HUIParent:FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)

    -- ==========================================
    -- TUŞLAR (Carry manuel)
    -- ==========================================
    table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.Space then IsHoldingSpace = true end
        if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl then IsHoldingCtrl = true end
        if input.KeyCode == Enum.KeyCode.H then CarryPick() end
        if input.KeyCode == Enum.KeyCode.J then CarryLift() end
        if input.KeyCode == Enum.KeyCode.K then CarryRevive() end
    end))
    table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Space then IsHoldingSpace = false end
        if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl then IsHoldingCtrl = false end
    end))

    -- Carry fonksiyonları (öncekiyle aynı)
    local function CarryPick()
        local closest, minDist, myHrp = nil, math.huge, LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHrp then
            for _,p in pairs(Players:GetPlayers()) do
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
    end
    local function CarryLift()
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHrp and Settings.CarrySystem.TargetPlayer then
            Settings.CarrySystem.State = "Lifting"; UpdateHUD()
            if CurrentPlatform then CurrentPlatform:Destroy() end
            CurrentPlatform = Instance.new("Part")
            CurrentPlatform.Size = Vector3.new(30,1,30)
            CurrentPlatform.CFrame = myHrp.CFrame + Vector3.new(0,100,0)
            CurrentPlatform.Anchored = true
            CurrentPlatform.Material = Enum.Material.Glass
            CurrentPlatform.Parent = Workspace
            task.wait(0.1)
            myHrp.CFrame = CurrentPlatform.CFrame + Vector3.new(0,3,0)
        end
    end
    local function CarryRevive()
        Settings.CarrySystem.State = "Reviving"; UpdateHUD()
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
        task.spawn(function()
            local st = tick()
            while tick()-st < 4 do
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                task.wait(0.05)
            end
            Settings.CarrySystem.State = "Idle"; Settings.CarrySystem.TargetPlayer = nil
            if CurrentPlatform then CurrentPlatform:Destroy(); CurrentPlatform = nil end
            UpdateHUD()
        end)
    end

    -- ==========================================
    -- NEXTBOT SCAN (Humanoid kontrolü)
    -- ==========================================
    local npcNames = {}
    local function updateNpcNames()
        local npcsFolder = ReplicatedStorage:FindFirstChild("NPCs")
        if npcsFolder then
            npcNames = {}
            for _, mod in ipairs(npcsFolder:GetChildren()) do
                if mod:IsA("ModuleScript") then npcNames[mod.Name] = true end
            end
        end
    end
    updateNpcNames()
    ReplicatedStorage.ChildAdded:Connect(function(c) if c.Name == "NPCs" then updateNpcNames() end end)
    if ReplicatedStorage:FindFirstChild("NPCs") then
        ReplicatedStorage.NPCs.ChildAdded:Connect(updateNpcNames)
        ReplicatedStorage.NPCs.ChildRemoved:Connect(updateNpcNames)
    end
    local lastNextbotScan = 0; local cachedNextbots = {}
    local function scanNextbots()
        if tick()-lastNextbotScan < 2 then return cachedNextbots end
        lastNextbotScan = tick()
        local npcs = {}
        for _,v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and npcNames[v.Name] and v:FindFirstChildOfClass("Humanoid") then
                table.insert(npcs, v)
            end
        end
        cachedNextbots = npcs
        return npcs
    end

    -- ==========================================
    -- ANA MOTOR
    -- ==========================================
    table.insert(Connections, RunService.Heartbeat:Connect(function(delta)
        if Settings.World.FullBright then
            Lighting.Brightness = 5; Lighting.GlobalShadows = false; Lighting.Ambient = Color3.new(1,1,1)
        end
        if Settings.World.NoFog then Lighting.FogEnd = 999999 else Lighting.FogEnd = 5000 end

        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hum and hrp then
            if Settings.Movement.FlyEnabled then
                if hrp:FindFirstChild("EmloxaVelocity") then hrp.EmloxaVelocity:Destroy() end
                local bv = Instance.new("BodyVelocity"); bv.Name = "EmloxaVelocity"; bv.MaxForce = Vector3.new(1e6,1e6,1e6); bv.Parent = hrp
                hum.PlatformStand = true
                local dir = hum.MoveDirection
                if IsHoldingSpace then dir += Vector3.new(0,1,0) end
                if IsHoldingCtrl then dir += Vector3.new(0,-1,0) end
                bv.Velocity = (dir.Magnitude>0 and dir.Unit or Vector3.new()) * Settings.Movement.FlySpeed
            else
                if hum.PlatformStand then hum.PlatformStand = false end
                if hrp:FindFirstChild("EmloxaVelocity") then hrp.EmloxaVelocity:Destroy() end
                if Settings.Movement.SpeedEnabled and hum.MoveDirection.Magnitude>0 then
                    local moveDir = hum.MoveDirection * Vector3.new(1,0,1)
                    if moveDir.Magnitude>0 then
                        hrp.CFrame += moveDir.Unit * Settings.Movement.SpeedValue * delta
                    end
                end
            end
            if Settings.Movement.AutoBhop and IsHoldingSpace and hum.FloorMaterial~=Enum.Material.Air then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            if Settings.Movement.EmoteDash and hum.MoveDirection.Magnitude>0 then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.G, false, game)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.G, false, game)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end
        end

        -- Downed tracking / Carry / Vote (öncekiyle aynı, kısaltıldı)
        for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer and p.Character then if IsPlayerDowned(p) then if not DownedTimers[p] then DownedTimers[p]=tick() end else DownedTimers[p]=nil end end end
        if Settings.CarrySystem.AutoMode and hrp then
            if Settings.CarrySystem.State == "Idle" then
                for p,st in pairs(DownedTimers) do if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and tick()-st>=5 then Settings.CarrySystem.TargetPlayer=p; Settings.CarrySystem.State="Teleporting"; UpdateHUD() break end end
            elseif Settings.CarrySystem.State == "Teleporting" and Settings.CarrySystem.TargetPlayer then
                local tHrp = Settings.CarrySystem.TargetPlayer.Character and Settings.CarrySystem.TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if tHrp then hrp.CFrame=tHrp.CFrame; VirtualInputManager:SendKeyEvent(true,Enum.KeyCode.Q,false,game); task.wait(0.2); Settings.CarrySystem.State="Lifting"; UpdateHUD() else Settings.CarrySystem.State="Idle"; UpdateHUD() end
            elseif Settings.CarrySystem.State == "Lifting" then
                if CurrentPlatform then CurrentPlatform:Destroy() end
                CurrentPlatform = Instance.new("Part"); CurrentPlatform.Size=Vector3.new(30,1,30); CurrentPlatform.CFrame=hrp.CFrame+Vector3.new(0,100,0); CurrentPlatform.Anchored=true; CurrentPlatform.Material=Enum.Material.Glass; CurrentPlatform.Parent=Workspace
                task.wait(0.1); hrp.CFrame=CurrentPlatform.CFrame+Vector3.new(0,3,0); task.wait(0.2); VirtualInputManager:SendKeyEvent(false,Enum.KeyCode.Q,false,game); Settings.CarrySystem.State="Reviving"; UpdateHUD()
            elseif Settings.CarrySystem.State == "Reviving" and Settings.CarrySystem.TargetPlayer then
                if IsPlayerDowned(Settings.CarrySystem.TargetPlayer) then VirtualInputManager:SendKeyEvent(true,Enum.KeyCode.E,false,game); task.wait(0.05); VirtualInputManager:SendKeyEvent(false,Enum.KeyCode.E,false,game) else if CurrentPlatform then CurrentPlatform:Destroy(); CurrentPlatform=nil end; Settings.CarrySystem.State="Idle"; Settings.CarrySystem.TargetPlayer=nil; UpdateHUD() end
            end
        end
        if Settings.Vote.AutoVote then
            local ev = ReplicatedStorage:FindFirstChild("Events")
            if ev and ev:FindFirstChild("Player") and ev.Player:FindFirstChild("Vote") then ev.Player.Vote:FireServer(Settings.Vote.MapNumber) end
        end

        -- ESP oluşturma/güncelleme (aynı)
        if Settings.Visuals.PlayerESP then
            for _,p in pairs(Players:GetPlayers()) do
                if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and not p.Character:FindFirstChild("EmloxaESP_Tag") then
                    local down = IsPlayerDowned(p)
                    local col = down and Color3.new(0.9,0.1,0.1) or Color3.new(0.4,0.8,0.4)
                    local txt = down and (p.Name.." [DOWNED]") or p.Name
                    CreateESP(p.Character, txt, col, p.Character.HumanoidRootPart, 2, Settings.Visuals.PlayerHighlight)
                end
            end
        end
        if Settings.Visuals.BotESP then
            for _,b in ipairs(scanNextbots()) do
                local part = b:FindFirstChild("Hitbox") or b:FindFirstChild("HumanoidRootPart")
                if part and not b:FindFirstChild("EmloxaESP_Tag") then CreateESP(b, b.Name, Color3.new(0.8,0.2,0.2), part, 3, Settings.Visuals.BotHighlight) end
            end
        end
        if Settings.Visuals.TicketESP then
            local tf = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Tickets")
            if tf then for _,t in pairs(tf:GetChildren()) do if t:IsA("BasePart") and not t:FindFirstChild("EmloxaESP_Tag") then CreateESP(t, "Ticket", Color3.fromRGB(255,215,0), t, 1, false) end end end
        end
        -- ESP mesafe/renk güncelleme
        local camPos = Camera and Camera.CFrame.Position or Vector3.new()
        for i=#ActiveESPs,1,-1 do
            local esp = ActiveESPs[i]
            if esp.Target and esp.Target.Parent and esp.Part and esp.Part.Parent then
                local p = Players:GetPlayerFromCharacter(esp.Target)
                if p then
                    local isDown = IsPlayerDowned(p)
                    esp.CurrentColor = isDown and Color3.new(0.9,0.1,0.1) or Color3.new(0.4,0.8,0.4)
                    if esp.Label then
                        if Settings.Visuals.Distance then
                            esp.Label.Text = (isDown and (p.Name.." [DOWNED]") or p.Name) .. " ["..math.floor((camPos-esp.Part.Position).Magnitude).."m]"
                        else esp.Label.Text = isDown and (p.Name.." [DOWNED]") or p.Name end
                        esp.Label.TextColor3 = esp.CurrentColor
                    end
                end
                if esp.Highlight then esp.Highlight.FillColor = esp.CurrentColor; esp.Highlight.OutlineColor = esp.CurrentColor end
            else
                if esp.Highlight then esp.Highlight:Destroy() end
                if esp.Billboard then esp.Billboard:Destroy() end
                table.remove(ActiveESPs, i)
            end
        end
        if Settings.World.FOV ~= 70 and Camera then Camera.FieldOfView = Settings.World.FOV end
    end))

    -- ==========================================
    -- VISUAL BOOMBOX SİSTEMİ (TAŞINABİLİR, ŞIK)
    -- ==========================================
    local function hasBoomboxAccessory()
        local char = LocalPlayer.Character
        if char then
            for _,acc in ipairs(char:GetChildren()) do
                if acc:IsA("Accessory") and acc.Name == "Evade Boombox IDOLAccessory" then return true end
            end
        end
        return false
    end

    local function giveBoombox()
        if hasBoomboxAccessory() then return end
        local char = LocalPlayer.Character
        if not char then return end
        local accessory = Instance.new("Accessory")
        accessory.Name = "Evade Boombox IDOLAccessory"
        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(1,1,1)
        handle.CFrame = char.PrimaryPart.CFrame
        handle.Parent = accessory
        local mesh = Instance.new("SpecialMesh", handle)
        mesh.MeshId = "rbxassetid://103401629121847"
        mesh.TextureId = "rbxassetid://75341317051938"
        accessory.Parent = char
    end

    local function removeBoombox()
        local char = LocalPlayer.Character
        if char then
            for _,acc in ipairs(char:GetChildren()) do
                if acc:IsA("Accessory") and acc.Name == "Evade Boombox IDOLAccessory" then
                    acc:Destroy()
                end
            end
        end
    end

    -- RADIO GUI
    local RadioGui, RadioOpen, CurrentSound, SongDurationSlider, VolumeSlider, NowPlayingLabel, LoopBtn, PlayBtn
    local function createRadioGUI()
        if RadioGui then return end
        RadioGui = Instance.new("ScreenGui")
        RadioGui.Name = "EmloxaRadio"
        RadioGui.Parent = HUIParent
        RadioGui.Enabled = false

        local Main = Instance.new("Frame")
        Main.Size = UDim2.new(0, 360, 0, 280)
        Main.Position = UDim2.new(0.5, -180, 0.5, -140)
        Main.BackgroundColor3 = Color3.fromRGB(25,25,35)
        Main.BorderSizePixel = 0
        Main.Active = true
        Main.Draggable = true
        Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
        local stroke = Instance.new("UIStroke", Main)
        stroke.Color = Color3.fromRGB(102,85,255)
        stroke.Thickness = 2
        Main.Parent = RadioGui

        -- Başlık çubuğu (draggable)
        local TitleBar = Instance.new("Frame")
        TitleBar.Size = UDim2.new(1,0,0,35)
        TitleBar.BackgroundColor3 = Color3.fromRGB(102,85,255)
        TitleBar.BorderSizePixel = 0
        TitleBar.Parent = Main

        local TitleText = Instance.new("TextLabel")
        TitleText.Size = UDim2.new(1,-40,1,0)
        TitleText.Position = UDim2.new(0,10,0,0)
        TitleText.Text = "Emloxa Ware Player"
        TitleText.Font = Enum.Font.GothamBlack
        TitleText.TextSize = 16
        TitleText.TextColor3 = Color3.new(1,1,1)
        TitleText.BackgroundTransparency = 1
        TitleText.TextXAlignment = Enum.TextXAlignment.Left
        TitleText.Parent = TitleBar

        local CloseBtn = Instance.new("TextButton")
        CloseBtn.Size = UDim2.new(0,28,0,28)
        CloseBtn.Position = UDim2.new(1,-32,0,4)
        CloseBtn.Text = "✕"
        CloseBtn.Font = Enum.Font.GothamBold
        CloseBtn.TextSize = 16
        CloseBtn.BackgroundColor3 = Color3.fromRGB(255,80,80)
        CloseBtn.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,6)
        CloseBtn.Parent = TitleBar
        CloseBtn.MouseButton1Click:Connect(function()
            RadioGui.Enabled = false
            RadioOpen = false
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        end)

        -- Sekme çerçevesi
        local TabFrame = Instance.new("Frame")
        TabFrame.Size = UDim2.new(1,0,0,30)
        TabFrame.Position = UDim2.new(0,0,0,35)
        TabFrame.BackgroundColor3 = Color3.fromRGB(35,35,45)
        TabFrame.Parent = Main

        local PlayTab = Instance.new("TextButton")
        PlayTab.Size = UDim2.new(0.5,0,1,0)
        PlayTab.Text = "🎵 Play"
        PlayTab.Font = Enum.Font.GothamBold
        PlayTab.TextSize = 13
        PlayTab.BackgroundColor3 = Color3.fromRGB(102,85,255)
        PlayTab.TextColor3 = Color3.new(1,1,1)
        PlayTab.Parent = TabFrame

        local FavTab = Instance.new("TextButton")
        FavTab.Size = UDim2.new(0.5,0,1,0)
        FavTab.Position = UDim2.new(0.5,0,0,0)
        FavTab.Text = "❤️ Favorites"
        FavTab.Font = Enum.Font.GothamBold
        FavTab.TextSize = 13
        FavTab.BackgroundColor3 = Color3.fromRGB(45,45,55)
        FavTab.TextColor3 = Color3.new(0.8,0.8,0.8)
        FavTab.Parent = TabFrame

        -- Sayfa konteynerı
        local Pages = Instance.new("Frame")
        Pages.Size = UDim2.new(1,0,1,-65)
        Pages.Position = UDim2.new(0,0,0,65)
        Pages.BackgroundTransparency = 1
        Pages.ClipsDescendants = true
        Pages.Parent = Main

        -- Play sayfası
        local PlayPage = Instance.new("Frame")
        PlayPage.Size = UDim2.new(1,0,1,0)
        PlayPage.BackgroundTransparency = 1
        PlayPage.Visible = true
        PlayPage.Parent = Pages

        local IdFrame = Instance.new("Frame")
        IdFrame.Size = UDim2.new(1,-20,0,35)
        IdFrame.Position = UDim2.new(0,10,0,10)
        IdFrame.BackgroundColor3 = Color3.fromRGB(40,40,50)
        Instance.new("UICorner", IdFrame).CornerRadius = UDim.new(0,8)
        IdFrame.Parent = PlayPage

        local SongIdBox = Instance.new("TextBox")
        SongIdBox.Size = UDim2.new(1,0,1,0)
        SongIdBox.BackgroundTransparency = 1
        SongIdBox.PlaceholderText = "Enter Music ID..."
        SongIdBox.Font = Enum.Font.Gotham
        SongIdBox.TextSize = 14
        SongIdBox.TextColor3 = Color3.new(1,1,1)
        SongIdBox.ClearTextOnFocus = false
        SongIdBox.Parent = IdFrame

        NowPlayingLabel = Instance.new("TextLabel")
        NowPlayingLabel.Size = UDim2.new(1,-20,0,22)
        NowPlayingLabel.Position = UDim2.new(0,10,0,52)
        NowPlayingLabel.Text = "No track selected"
        NowPlayingLabel.Font = Enum.Font.Gotham
        NowPlayingLabel.TextSize = 12
        NowPlayingLabel.TextColor3 = Color3.new(0.8,0.8,0.8)
        NowPlayingLabel.BackgroundTransparency = 1
        NowPlayingLabel.TextXAlignment = Enum.TextXAlignment.Left
        NowPlayingLabel.Parent = PlayPage

        -- Süre slider
        SongDurationSlider = Instance.new("Frame")
        SongDurationSlider.Size = UDim2.new(1,-20,0,6)
        SongDurationSlider.Position = UDim2.new(0,10,0,80)
        SongDurationSlider.BackgroundColor3 = Color3.fromRGB(60,60,70)
        Instance.new("UICorner", SongDurationSlider).CornerRadius = UDim.new(0,3)
        local fill = Instance.new("Frame", SongDurationSlider)
        fill.Size = UDim2.new(0,0,1,0)
        fill.BackgroundColor3 = Color3.fromRGB(102,85,255)
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0,3)
        local knob = Instance.new("Frame", SongDurationSlider)
        knob.Size = UDim2.new(0,10,0,10)
        knob.Position = UDim2.new(0,-5,0.5,-5)
        knob.BackgroundColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", knob).CornerRadius = UDim.new(0,5)
        knob.Parent = SongDurationSlider
        SongDurationSlider.Parent = PlayPage

        -- Kontrol butonları
        local Controls = Instance.new("Frame")
        Controls.Size = UDim2.new(1,-20,0,45)
        Controls.Position = UDim2.new(0,10,0,100)
        Controls.BackgroundTransparency = 1
        Controls.Parent = PlayPage

        local function makeCtrlBtn(icon, x, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0,42,0,42)
            btn.Position = UDim2.new(0,x,0.5,-21)
            btn.Text = icon
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 20
            btn.BackgroundColor3 = Color3.fromRGB(50,50,60)
            btn.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
            btn.Parent = Controls
            btn.MouseButton1Click:Connect(callback)
            return btn
        end

        local PrevBtn = makeCtrlBtn("⏮", 0, function()
            if #Settings.Radio.Playlist > 0 then
                Settings.Radio.NowPlayingIndex = math.max(1, Settings.Radio.NowPlayingIndex - 1)
                playSong(Settings.Radio.Playlist[Settings.Radio.NowPlayingIndex])
            end
        end)
        PlayBtn = makeCtrlBtn("▶", 55, function()
            if CurrentSound then
                if CurrentSound.IsPlaying then CurrentSound:Pause() PlayBtn.Text = "▶" else CurrentSound:Resume() PlayBtn.Text = "⏸" end
            else
                local id = SongIdBox.Text
                if id ~= "" then playSong(id) end
            end
        end)
        local NextBtn = makeCtrlBtn("⏭", 110, function()
            if #Settings.Radio.Playlist > 0 then
                Settings.Radio.NowPlayingIndex = math.min(#Settings.Radio.Playlist, Settings.Radio.NowPlayingIndex + 1)
                playSong(Settings.Radio.Playlist[Settings.Radio.NowPlayingIndex])
            end
        end)
        LoopBtn = makeCtrlBtn("🔁", 170, function()
            Settings.Radio.Loop = not Settings.Radio.Loop
            LoopBtn.BackgroundColor3 = Settings.Radio.Loop and Color3.fromRGB(102,85,255) or Color3.fromRGB(50,50,60)
            if CurrentSound then CurrentSound.Looped = Settings.Radio.Loop end
        end)
        LoopBtn.BackgroundColor3 = Settings.Radio.Loop and Color3.fromRGB(102,85,255) or Color3.fromRGB(50,50,60)

        -- Volume slider (sağda)
        local VolFrame = Instance.new("Frame")
        VolFrame.Size = UDim2.new(0,100,0,6)
        VolFrame.Position = UDim2.new(1,-120,0.5,-3)
        VolFrame.BackgroundColor3 = Color3.fromRGB(60,60,70)
        Instance.new("UICorner", VolFrame).CornerRadius = UDim.new(0,3)
        local volFill = Instance.new("Frame", VolFrame)
        volFill.Size = UDim2.new(0.5,0,1,0)
        volFill.BackgroundColor3 = Color3.fromRGB(102,85,255)
        Instance.new("UICorner", volFill).CornerRadius = UDim.new(0,3)
        local volKnob = Instance.new("Frame", VolFrame)
        volKnob.Size = UDim2.new(0,10,0,10)
        volKnob.Position = UDim2.new(0.5,-5,0.5,-5)
        volKnob.BackgroundColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", volKnob).CornerRadius = UDim.new(0,5)
        VolFrame.Parent = Controls

        local volLabel = Instance.new("TextLabel")
        volLabel.Size = UDim2.new(0,20,0,20)
        volLabel.Position = UDim2.new(1,-115,0.5,-10)
        volLabel.Text = "🔊"
        volLabel.Font = Enum.Font.Gotham
        volLabel.TextSize = 14
        volLabel.BackgroundTransparency = 1
        volLabel.Parent = Controls

        -- Favorites sayfası
        local FavPage = Instance.new("Frame")
        FavPage.Size = UDim2.new(1,0,1,0)
        FavPage.BackgroundTransparency = 1
        FavPage.Visible = false
        FavPage.Parent = Pages

        local SearchFrame = Instance.new("Frame")
        SearchFrame.Size = UDim2.new(1,-20,0,32)
        SearchFrame.Position = UDim2.new(0,10,0,8)
        SearchFrame.BackgroundColor3 = Color3.fromRGB(40,40,50)
        Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0,6)
        SearchFrame.Parent = FavPage

        local SearchBox = Instance.new("TextBox")
        SearchBox.Size = UDim2.new(1,-42,1,0)
        SearchBox.Position = UDim2.new(0,4,0,0)
        SearchBox.BackgroundTransparency = 1
        SearchBox.PlaceholderText = "Search ID..."
        SearchBox.Font = Enum.Font.Gotham
        SearchBox.TextSize = 13
        SearchBox.TextColor3 = Color3.new(1,1,1)
        SearchBox.ClearTextOnFocus = false
        SearchBox.Parent = SearchFrame

        local HeartBtn = Instance.new("TextButton")
        HeartBtn.Size = UDim2.new(0,34,0,34)
        HeartBtn.Position = UDim2.new(1,-38,0,-1)
        HeartBtn.Text = "♡"
        HeartBtn.Font = Enum.Font.Gotham
        HeartBtn.TextSize = 20
        HeartBtn.BackgroundColor3 = Color3.fromRGB(50,50,60)
        HeartBtn.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", HeartBtn).CornerRadius = UDim.new(0,6)
        HeartBtn.Parent = SearchFrame

        local SongPreview = Instance.new("TextLabel")
        SongPreview.Size = UDim2.new(1,-20,0,20)
        SongPreview.Position = UDim2.new(0,10,0,48)
        SongPreview.Text = "Enter ID to search"
        SongPreview.Font = Enum.Font.Gotham
        SongPreview.TextSize = 11
        SongPreview.TextColor3 = Color3.new(0.7,0.7,0.7)
        SongPreview.BackgroundTransparency = 1
        SongPreview.TextXAlignment = Enum.TextXAlignment.Left
        SongPreview.Parent = FavPage

        local FavList = Instance.new("ScrollingFrame")
        FavList.Size = UDim2.new(1,-20,1,-82)
        FavList.Position = UDim2.new(0,10,0,76)
        FavList.BackgroundTransparency = 1
        FavList.ScrollBarThickness = 3
        FavList.CanvasSize = UDim2.new(0,0,0,0)
        FavList.Parent = FavPage
        local FavLayout = Instance.new("UIListLayout", FavList)
        FavLayout.Padding = UDim.new(0,4)

        local function refreshFavList()
            for _,child in ipairs(FavList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
            for _,favID in ipairs(Settings.Radio.Favorites) do
                local entry = Instance.new("TextButton")
                entry.Size = UDim2.new(1,-40,0,28)
                entry.Position = UDim2.new(0,4,0,0)
                entry.Text = favID
                entry.Font = Enum.Font.Gotham
                entry.TextSize = 12
                entry.BackgroundColor3 = Color3.fromRGB(40,40,50)
                entry.TextColor3 = Color3.new(1,1,1)
                Instance.new("UICorner", entry).CornerRadius = UDim.new(0,5)
                entry.Parent = FavList
                entry.MouseButton1Click:Connect(function()
                    SongIdBox.Text = favID
                    playSong(favID)
                    PlayPage.Visible = true; FavPage.Visible = false
                    PlayTab.BackgroundColor3 = Color3.fromRGB(102,85,255); FavTab.BackgroundColor3 = Color3.fromRGB(45,45,55)
                end)
                local removeBtn = Instance.new("TextButton")
                removeBtn.Size = UDim2.new(0,28,0,28)
                removeBtn.Position = UDim2.new(1,-32,0,0)
                removeBtn.Text = "✕"
                removeBtn.Font = Enum.Font.GothamBold
                removeBtn.TextSize = 14
                removeBtn.BackgroundColor3 = Color3.fromRGB(255,70,70)
                removeBtn.TextColor3 = Color3.new(1,1,1)
                Instance.new("UICorner", removeBtn).CornerRadius = UDim.new(0,5)
                removeBtn.Parent = entry
                removeBtn.MouseButton1Click:Connect(function()
                    for i,v in ipairs(Settings.Radio.Favorites) do if v == favID then table.remove(Settings.Radio.Favorites, i) break end end
                    saveFavorites()
                    refreshFavList()
                end)
            end
            FavList.CanvasSize = UDim2.new(0,0,0,FavLayout.AbsoluteContentSize.Y + 10)
        end

        local function searchSong(id)
            local success, info = pcall(function() return MarketplaceService:GetProductInfo(tonumber(id)) end)
            if success and info and info.Name then
                SongPreview.Text = "🎵 "..info.Name
                return info.Name
            else
                SongPreview.Text = "Invalid ID or not a public audio"
                return nil
            end
        end

        HeartBtn.MouseButton1Click:Connect(function()
            local id = SearchBox.Text
            if id == "" then return end
            local found = false
            for _,fav in ipairs(Settings.Radio.Favorites) do if fav == id then found = true break end end
            if not found then
                local name = searchSong(id)
                if name then
                    table.insert(Settings.Radio.Favorites, id)
                    saveFavorites()
                    refreshFavList()
                    HeartBtn.Text = "❤️"
                end
            else
                for i,v in ipairs(Settings.Radio.Favorites) do if v == id then table.remove(Settings.Radio.Favorites, i) break end end
                saveFavorites()
                refreshFavList()
                HeartBtn.Text = "♡"
            end
        end)
        SearchBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                local name = searchSong(SearchBox.Text)
                if name then
                    HeartBtn.Text = "♡"
                    for _,fav in ipairs(Settings.Radio.Favorites) do if fav == SearchBox.Text then HeartBtn.Text = "❤️" break end end
                end
            end
        end)

        PlayTab.MouseButton1Click:Connect(function()
            PlayPage.Visible = true; FavPage.Visible = false
            PlayTab.BackgroundColor3 = Color3.fromRGB(102,85,255); FavTab.BackgroundColor3 = Color3.fromRGB(45,45,55)
        end)
        FavTab.MouseButton1Click:Connect(function()
            PlayPage.Visible = false; FavPage.Visible = true
            FavTab.BackgroundColor3 = Color3.fromRGB(102,85,255); PlayTab.BackgroundColor3 = Color3.fromRGB(45,45,55)
            refreshFavList()
        end)

        -- Başlangıç ayarları
        loadFavorites()
        refreshFavList()
    end

    local function loadFavorites()
        if isfile then
            local ok, data = pcall(function() return readfile("Emloxa_Favorites.json") end)
            if ok then
                local decoded = HttpService:JSONDecode(data)
                if decoded then Settings.Radio.Favorites = decoded end
            end
        end
    end
    local function saveFavorites()
        if writefile then writefile("Emloxa_Favorites.json", HttpService:JSONEncode(Settings.Radio.Favorites)) end
    end

    local function playSong(id)
        if CurrentSound then CurrentSound:Destroy() end
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://"..id
        sound.Volume = Settings.Radio.Volume
        sound.Looped = Settings.Radio.Loop
        sound.Parent = Workspace
        sound:Play()
        CurrentSound = sound
        NowPlayingLabel.Text = "Playing: "..id
        PlayBtn.Text = "⏸"
        if not table.find(Settings.Radio.Playlist, id) then
            table.insert(Settings.Radio.Playlist, id)
            Settings.Radio.NowPlayingIndex = #Settings.Radio.Playlist
        else
            Settings.Radio.NowPlayingIndex = table.find(Settings.Radio.Playlist, id) or 1
        end
    end

    createRadioGUI()

    -- Radio toggle callback (zaten yukarıda Visuals sekmesinde ayarlandı)
    -- Unload'da radio GUI temizle
    local oldUnload = MiscTab.Unload -- yok, doğrudan eventte

    print("Emloxa Evade v6 yüklendi.")
end

return GameModule
