-- =========================================================================
-- EMLOXA WARE: EVADE (PLACE ID: 9872472334) – v5 FINAL
-- CFrame Speed, Fixed Highlight, Visual Boombox, Better Nextbot ESP
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

    -- HUI parent
    local HUIParent = (gethui and gethui()) or game:GetService("CoreGui")

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
        Vote = {
            AutoVote = false,
            MapNumber = 1
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
        Radio = {
            Enabled = false,
            CurrentID = "",
            Loop = false,
            Volume = 0.5,
            Favorites = {}
        }
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
    -- HUD (HUI)
    -- ==========================================
    local StatusGui = Instance.new("ScreenGui")
    StatusGui.Name = "EmloxaStatusUI"
    StatusGui.Parent = HUIParent

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
    ManualKeyLabel.Text = "[H] -> Teleport & Pick\n[J] -> Lift to Sky\n[K] -> Drop & Revive"
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
    -- DOWNED CHECK
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
    -- ESP (FIXED HIGHLIGHT)
    -- ==========================================
    local function CreateESP(target, nameText, color, attachPart, yOffset, useHighlight)
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

    local VoteTab = Window:CreateTab("Vote")
    VoteTab:CreateDropdown("Select Map to Vote", {"Map 1", "Map 2", "Map 3", "Map 4"}, "Map 1", function(opt)
        Settings.Vote.MapNumber = tonumber(opt:match("%d+"))
    end)
    VoteTab:CreateToggle("Auto Vote Map Loop", function(s) Settings.Vote.AutoVote = s end)

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
        local ui = HUIParent:FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
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
            -- carry pick
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
    -- NEXTBOT SCAN (Humanoid kontrolü)
    -- ==========================================
    local npcNames = {}
    local function updateNpcNames()
        local npcsFolder = ReplicatedStorage:FindFirstChild("NPCs")
        if npcsFolder then
            npcNames = {}
            for _, mod in ipairs(npcsFolder:GetChildren()) do
                if mod:IsA("ModuleScript") then
                    npcNames[mod.Name] = true
                end
            end
        end
    end
    updateNpcNames()
    ReplicatedStorage.ChildAdded:Connect(function(child)
        if child.Name == "NPCs" then updateNpcNames() end
    end)
    if ReplicatedStorage:FindFirstChild("NPCs") then
        ReplicatedStorage.NPCs.ChildAdded:Connect(updateNpcNames)
        ReplicatedStorage.NPCs.ChildRemoved:Connect(updateNpcNames)
    end

    local lastNextbotScan = 0
    local cachedNextbots = {}
    local function scanNextbots()
        local now = tick()
        if now - lastNextbotScan < 2 then return cachedNextbots end
        lastNextbotScan = now
        local npcs = {}
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and npcNames[v.Name] then
                -- Humanoid kontrolü
                if v:FindFirstChildOfClass("Humanoid") then
                    table.insert(npcs, v)
                end
            end
        end
        cachedNextbots = npcs
        return npcs
    end

    -- ==========================================
    -- ANA MOTOR
    -- ==========================================
    table.insert(Connections, RunService.Heartbeat:Connect(function(delta)
        -- FullBright/NoFog
        if Settings.World.FullBright then
            Lighting.Brightness = 5
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(255,255,255)
        end
        if Settings.World.NoFog then
            Lighting.FogEnd = 999999
        else
            Lighting.FogEnd = OrigLighting.FogEnd
        end

        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if hum and hrp then
            -- Fly (BodyVelocity)
            if Settings.Movement.FlyEnabled then
                if hrp:FindFirstChild("EmloxaSpeed") then hrp.EmloxaSpeed:Destroy() end
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

                -- CFrame Speed (Y eksenine dokunma)
                if Settings.Movement.SpeedEnabled and hum.MoveDirection.Magnitude > 0 then
                    local moveDir = hum.MoveDirection * Vector3.new(1, 0, 1)
                    if moveDir.Magnitude > 0 then
                        moveDir = moveDir.Unit
                        local offset = moveDir * Settings.Movement.SpeedValue * delta
                        hrp.CFrame = hrp.CFrame + offset
                    end
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

        -- Downed tracking
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                if IsPlayerDowned(p) then
                    if not DownedTimers[p] then DownedTimers[p] = tick() end
                else
                    DownedTimers[p] = nil
                end
            end
        end

        -- Carry
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

        -- Vote
        if Settings.Vote.AutoVote then
            local ev = ReplicatedStorage:FindFirstChild("Events")
            if ev and ev:FindFirstChild("Player") and ev.Player:FindFirstChild("Vote") then
                ev.Player.Vote:FireServer(Settings.Vote.MapNumber)
            end
        end

        -- ESP
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

        -- ESP Update
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

    -- ==========================================
    -- VISUAL RADIO (BOOMBOX)
    -- ==========================================
    local function hasBoomboxAccessory()
        local char = LocalPlayer.Character
        if char then
            for _, child in ipairs(char:GetChildren()) do
                if child:IsA("Accessory") and child.Name == "Evade Boombox IDOLAccessory" then
                    return true
                end
            end
        end
        return false
    end

    local RadioGui = nil
    local RadioOpen = false
    local CurrentSound = nil

    local function loadFavorites()
        local file = "Emloxa_Favorites.json"
        if isfile then
            local success, data = pcall(function() return readfile(file) end)
            if success then
                local decoded = HttpService:JSONDecode(data)
                if decoded then Settings.Radio.Favorites = decoded end
            end
        end
    end
    local function saveFavorites()
        local file = "Emloxa_Favorites.json"
        if writefile then
            writefile(file, HttpService:JSONEncode(Settings.Radio.Favorites))
        end
    end

    local function createRadio()
        if RadioGui then return end
        RadioGui = Instance.new("ScreenGui")
        RadioGui.Name = "EmloxaRadio"
        RadioGui.Parent = HUIParent
        RadioGui.Enabled = false

        local Main = Instance.new("Frame")
        Main.Size = UDim2.new(0, 400, 0, 300)
        Main.Position = UDim2.new(0.5, -200, 0.5, -150)
        Main.BackgroundColor3 = Color3.fromRGB(25,25,35)
        Main.BorderSizePixel = 0
        Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
        Main.Parent = RadioGui

        -- Title
        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1,0,0,40)
        Title.BackgroundColor3 = Color3.fromRGB(102,85,255)
        Title.Text = "Emloxa Ware Player"
        Title.Font = Enum.Font.GothamBlack
        Title.TextSize = 18
        Title.TextColor3 = Color3.new(1,1,1)
        Title.Parent = Main

        -- Sekme çerçevesi
        local TabFrame = Instance.new("Frame")
        TabFrame.Size = UDim2.new(1,0,0,30)
        TabFrame.Position = UDim2.new(0,0,0,40)
        TabFrame.BackgroundColor3 = Color3.fromRGB(20,20,30)
        TabFrame.Parent = Main

        local PlayTab = Instance.new("TextButton")
        PlayTab.Size = UDim2.new(0.5,0,1,0)
        PlayTab.Text = "Play"
        PlayTab.Font = Enum.Font.GothamBold
        PlayTab.TextSize = 14
        PlayTab.BackgroundColor3 = Color3.fromRGB(102,85,255)
        PlayTab.TextColor3 = Color3.new(1,1,1)
        PlayTab.Parent = TabFrame

        local FavTab = Instance.new("TextButton")
        FavTab.Size = UDim2.new(0.5,0,1,0)
        FavTab.Position = UDim2.new(0.5,0,0,0)
        FavTab.Text = "Favorites"
        FavTab.Font = Enum.Font.GothamBold
        FavTab.TextSize = 14
        FavTab.BackgroundColor3 = Color3.fromRGB(40,40,50)
        FavTab.TextColor3 = Color3.new(0.8,0.8,0.8)
        FavTab.Parent = TabFrame

        -- Play sayfası
        local PlayPage = Instance.new("Frame")
        PlayPage.Size = UDim2.new(1,0,1,-70)
        PlayPage.Position = UDim2.new(0,0,0,70)
        PlayPage.BackgroundTransparency = 1
        PlayPage.Visible = true
        PlayPage.Parent = Main

        local SongID = Instance.new("TextBox")
        SongID.Size = UDim2.new(1,-20,0,30)
        SongID.Position = UDim2.new(0,10,0,10)
        SongID.PlaceholderText = "Enter Music ID..."
        SongID.Text = Settings.Radio.CurrentID
        SongID.Font = Enum.Font.Gotham
        SongID.TextSize = 14
        SongID.BackgroundColor3 = Color3.fromRGB(40,40,50)
        SongID.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", SongID).CornerRadius = UDim.new(0, 6)
        SongID.Parent = PlayPage

        local LoopToggle = Instance.new("TextButton")
        LoopToggle.Size = UDim2.new(0, 30, 0, 30)
        LoopToggle.Position = UDim2.new(0, 10, 0, 50)
        LoopToggle.Text = "🔁"
        LoopToggle.Font = Enum.Font.Gotham
        LoopToggle.TextSize = 18
        LoopToggle.BackgroundColor3 = Settings.Radio.Loop and Color3.fromRGB(102,85,255) or Color3.fromRGB(40,40,50)
        LoopToggle.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", LoopToggle).CornerRadius = UDim.new(0, 6)
        LoopToggle.Parent = PlayPage

        local NowPlaying = Instance.new("TextLabel")
        NowPlaying.Size = UDim2.new(1,-60,0,30)
        NowPlaying.Position = UDim2.new(0,45,0,50)
        NowPlaying.Text = "No music playing"
        NowPlaying.Font = Enum.Font.Gotham
        NowPlaying.TextSize = 12
        NowPlaying.TextColor3 = Color3.new(0.8,0.8,0.8)
        NowPlaying.BackgroundTransparency = 1
        NowPlaying.TextXAlignment = Enum.TextXAlignment.Left
        NowPlaying.Parent = PlayPage

        local ControlsFrame = Instance.new("Frame")
        ControlsFrame.Size = UDim2.new(1,-20,0,40)
        ControlsFrame.Position = UDim2.new(0,10,1,-50)
        ControlsFrame.BackgroundTransparency = 1
        ControlsFrame.Parent = PlayPage

        local function createButton(text, posX, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 40, 0, 40)
            btn.Position = UDim2.new(0, posX, 0, 0)
            btn.Text = text
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 16
            btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
            btn.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            btn.Parent = ControlsFrame
            btn.MouseButton1Click:Connect(callback)
            return btn
        end

        local PrevBtn = createButton("⏮", 0, function()
            -- önceki parça (basit liste çevrimi)
        end)
        local PlayBtn = createButton("▶", 50, function()
            local id = SongID.Text
            if id == "" then return end
            if CurrentSound then CurrentSound:Destroy() end
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://" .. id
            sound.Volume = Settings.Radio.Volume
            sound.Looped = Settings.Radio.Loop
            sound.Parent = Workspace
            sound:Play()
            CurrentSound = sound
            NowPlaying.Text = "Playing: " .. id
            PlayBtn.Text = "⏸"
        end)
        local NextBtn = createButton("⏭", 100, function()
            -- sonraki parça
        end)

        -- Favorites sayfası
        local FavPage = Instance.new("Frame")
        FavPage.Size = UDim2.new(1,0,1,-70)
        FavPage.Position = UDim2.new(0,0,0,70)
        FavPage.BackgroundTransparency = 1
        FavPage.Visible = false
        FavPage.Parent = Main

        local SearchBox = Instance.new("TextBox")
        SearchBox.Size = UDim2.new(1,-50,0,30)
        SearchBox.Position = UDim2.new(0,10,0,10)
        SearchBox.PlaceholderText = "Search ID..."
        SearchBox.Font = Enum.Font.Gotham
        SearchBox.TextSize = 14
        SearchBox.BackgroundColor3 = Color3.fromRGB(40,40,50)
        SearchBox.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)
        SearchBox.Parent = FavPage

        local AddFavBtn = Instance.new("TextButton")
        AddFavBtn.Size = UDim2.new(0, 30, 0, 30)
        AddFavBtn.Position = UDim2.new(1, -40, 0, 10)
        AddFavBtn.Text = "♡"
        AddFavBtn.Font = Enum.Font.Gotham
        AddFavBtn.TextSize = 18
        AddFavBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
        AddFavBtn.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", AddFavBtn).CornerRadius = UDim.new(0, 6)
        AddFavBtn.Parent = FavPage

        local FavList = Instance.new("ScrollingFrame")
        FavList.Size = UDim2.new(1,-20,1,-60)
        FavList.Position = UDim2.new(0,10,0,50)
        FavList.BackgroundTransparency = 1
        FavList.ScrollBarThickness = 3
        FavList.CanvasSize = UDim2.new(0,0,0,0)
        FavList.Parent = FavPage

        local FavLayout = Instance.new("UIListLayout")
        FavLayout.Padding = UDim.new(0, 4)
        FavLayout.Parent = FavList

        local function refreshFavList()
            for _, child in ipairs(FavList:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            for _, favID in ipairs(Settings.Radio.Favorites) do
                local entry = Instance.new("TextButton")
                entry.Size = UDim2.new(1,0,0,30)
                entry.Text = favID
                entry.Font = Enum.Font.Gotham
                entry.TextSize = 12
                entry.BackgroundColor3 = Color3.fromRGB(40,40,50)
                entry.TextColor3 = Color3.new(1,1,1)
                Instance.new("UICorner", entry).CornerRadius = UDim.new(0, 4)
                entry.Parent = FavList
                entry.MouseButton1Click:Connect(function()
                    SongID.Text = favID
                    PlayTab.BackgroundColor3 = Color3.fromRGB(102,85,255)
                    FavTab.BackgroundColor3 = Color3.fromRGB(40,40,50)
                    PlayPage.Visible = true
                    FavPage.Visible = false
                end)
            end
            FavList.CanvasSize = UDim2.new(0,0,0,FavLayout.AbsoluteContentSize.Y + 10)
        end

        AddFavBtn.MouseButton1Click:Connect(function()
            local id = SearchBox.Text
            if id == "" then return end
            local found = false
            for _, fav in ipairs(Settings.Radio.Favorites) do
                if fav == id then found = true break end
            end
            if not found then
                table.insert(Settings.Radio.Favorites, id)
                saveFavorites()
                refreshFavList()
                AddFavBtn.Text = "❤️"
            end
        end)

        PlayTab.MouseButton1Click:Connect(function()
            PlayPage.Visible = true
            FavPage.Visible = false
            PlayTab.BackgroundColor3 = Color3.fromRGB(102,85,255)
            FavTab.BackgroundColor3 = Color3.fromRGB(40,40,50)
        end)
        FavTab.MouseButton1Click:Connect(function()
            PlayPage.Visible = false
            FavPage.Visible = true
            FavTab.BackgroundColor3 = Color3.fromRGB(102,85,255)
            PlayTab.BackgroundColor3 = Color3.fromRGB(40,40,50)
            refreshFavList()
        end)

        loadFavorites()
    end

    local function toggleRadio()
        if hasBoomboxAccessory() then return end -- varsa hiç açma
        if not RadioGui then createRadio() end
        RadioOpen = not RadioOpen
        RadioGui.Enabled = RadioOpen
        if RadioOpen then
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        else
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        end
    end

    table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.V then
            toggleRadio()
        end
    end))

    -- ==========================================
    -- INIT
    -- ==========================================
    if not hasBoomboxAccessory() then
        -- hemen radio oluştur ama kapalı
        createRadio()
    end
end

return GameModule
