-- =========================================================================
-- EMLOXA WARE: EVADE v8.6 – OPTİMİZE EDİLMİŞ, MÜZİK SEKMESİZ
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

    local HUIParent = (gethui and gethui()) or game:GetService("CoreGui")

    local Connections = {}
    local ActiveESPs = {}
    local CurrentPlatform = nil

    local Settings = {
        Movement = {
            SpeedEnabled = false, SpeedValue = 40,
            FlyEnabled = false, FlySpeed = 50,
            AutoBhop = false, EmoteDash = false
        },
        CarrySystem = {
            State = "Idle",
            TargetPlayer = nil
        },
        Vote = { AutoVote = false, MapNumber = 1 },
        Visuals = {
            PlayerESP = false, BotESP = false, TicketESP = false,
            DownedColor = true, Distance = true,
            PlayerHighlight = false, BotHighlight = false
        },
        World = { FullBright = false, NoFog = false, FOV = 70, ThirdPerson = false },
        AutoFarm = {
            AutoTickets = false,
            AutoWin = false
        }
    }

    local IsHoldingSpace = false
    local IsHoldingCtrl = false

    local currentTicketTarget = nil
    local ticketSafePlatform = nil

    -- ==========================================
    -- HUD (şeffaf, tıklamaları engellemez)
    -- ==========================================
    local StatusGui = Instance.new("ScreenGui")
    StatusGui.Name = "EmloxaStatusUI"
    StatusGui.Parent = HUIParent

    local MainHud = Instance.new("Frame")
    MainHud.Size = UDim2.new(0, 240, 0, 180)
    MainHud.Position = UDim2.new(1, -250, 0.3, 0)
    MainHud.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainHud.BackgroundTransparency = 0.6
    MainHud.BorderSizePixel = 0
    MainHud.Active = false
    Instance.new("UICorner", MainHud).CornerRadius = UDim.new(0, 10)
    MainHud.Parent = StatusGui
    Instance.new("UIStroke", MainHud).Color = Color3.fromRGB(102, 85, 255)

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
    ManualKeyLabel.Text = "[H] Pick  [J] Lift  [K] Revive"
    ManualKeyLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    ManualKeyLabel.Font = Enum.Font.Gotham
    ManualKeyLabel.TextSize = 11
    ManualKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
    ManualKeyLabel.Parent = MainHud

    local AutoFarmLabel = Instance.new("TextLabel")
    AutoFarmLabel.Size = UDim2.new(1, -20, 0, 50)
    AutoFarmLabel.Position = UDim2.new(0, 10, 0, 145)
    AutoFarmLabel.BackgroundTransparency = 1
    AutoFarmLabel.Text = "AutoFarm: IDLE"
    AutoFarmLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    AutoFarmLabel.Font = Enum.Font.Gotham
    AutoFarmLabel.TextSize = 11
    AutoFarmLabel.TextXAlignment = Enum.TextXAlignment.Left
    AutoFarmLabel.Parent = MainHud

    local function UpdateHUD()
        StateLabel.Text = "System State: " .. Settings.CarrySystem.State:upper()
        if Settings.CarrySystem.TargetPlayer then
            TargetLabel.Text = "Target: " .. Settings.CarrySystem.TargetPlayer.Name
        else
            TargetLabel.Text = "Target: None"
        end
        if currentTicketTarget then
            AutoFarmLabel.Text = "AutoFarm: Collecting " .. currentTicketTarget.Name
        elseif Settings.AutoFarm.AutoWin then
            AutoFarmLabel.Text = "AutoFarm: Win Mode"
        else
            AutoFarmLabel.Text = "AutoFarm: IDLE"
        end
    end

    -- ==========================================
    -- DOWNED CHECK (sadece manuel carry için)
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
    -- ESP SİSTEMİ (Highlight / Billboard)
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

    local AutoFarmTab = Window:CreateTab("Autofarm")
    AutoFarmTab:CreateToggle("Auto Collect Tickets", function(s)
        Settings.AutoFarm.AutoTickets = s
        if not s then
            currentTicketTarget = nil
            if ticketSafePlatform then ticketSafePlatform:Destroy(); ticketSafePlatform = nil end
            UpdateHUD()
        end
    end)
    AutoFarmTab:CreateToggle("Auto Win", function(s)
        Settings.AutoFarm.AutoWin = s
        if not s and ticketSafePlatform then
            ticketSafePlatform:Destroy()
            ticketSafePlatform = nil
        end
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
        if CurrentPlatform then CurrentPlatform:Destroy() end
        if ticketSafePlatform then ticketSafePlatform:Destroy() end
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
    -- MANUEL CARRY FONKSİYONLARI
    -- ==========================================
    local function CarryPick()
        local closest, minDist = nil, math.huge
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and IsPlayerDowned(p) then
                local pHrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if pHrp then
                    local d = (pHrp.Position - myHrp.Position).Magnitude
                    if d < minDist then minDist = d; closest = p end
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
        if not myHrp then return end
        if not Settings.CarrySystem.TargetPlayer then
            local closest, minDist = nil, math.huge
            for _,p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and IsPlayerDowned(p) then
                    local pHrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    if pHrp then
                        local d = (pHrp.Position - myHrp.Position).Magnitude
                        if d < minDist then minDist = d; closest = p end
                    end
                end
            end
            if closest then
                Settings.CarrySystem.TargetPlayer = closest
                Settings.CarrySystem.State = "Teleporting"
                UpdateHUD()
                myHrp.CFrame = closest.Character.HumanoidRootPart.CFrame
                task.wait(0.15)
            else
                return
            end
        end
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

    -- ==========================================
    -- NEXTBOT TARAMA (NPC isimlerine göre, optimize)
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
    local lastNextbotScan = 0
    local cachedNextbots = {}
    local function scanNextbots()
        local now = tick()
        if now - lastNextbotScan < 1.2 then return cachedNextbots end  -- saniyede 1 kere
        lastNextbotScan = now
        local npcs = {}
        for _,v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and npcNames[v.Name] and v:FindFirstChildOfClass("Humanoid") then
                local hrp = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Hitbox")
                if hrp then
                    table.insert(npcs, {Model = v, Position = hrp.Position})
                end
            end
        end
        cachedNextbots = npcs
        return npcs
    end

    -- ==========================================
    -- GÜVENLİ PLATFORM (tekrar oluşturmaz, taşır)
    -- ==========================================
    local function createSafePlatform(position)
        if ticketSafePlatform then
            ticketSafePlatform.CFrame = CFrame.new(position.X, position.Y + 1000, position.Z)
        else
            local plat = Instance.new("Part")
            plat.Size = Vector3.new(30, 1, 30)
            plat.CFrame = CFrame.new(position.X, position.Y + 1000, position.Z)
            plat.Anchored = true
            plat.Material = Enum.Material.Glass
            plat.Parent = Workspace
            ticketSafePlatform = plat
        end
        return ticketSafePlatform.CFrame + Vector3.new(0, 3, 0)
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
            -- Hareket sistemi
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
                if Settings.Movement.SpeedEnabled and hum.MoveDirection.Magnitude > 0 and not Settings.AutoFarm.AutoTickets then
                    local moveDir = hum.MoveDirection.Unit
                    hrp.CFrame = hrp.CFrame + moveDir * Settings.Movement.SpeedValue * delta
                end
            end

            if Settings.Movement.AutoBhop and IsHoldingSpace and hum.FloorMaterial ~= Enum.Material.Air then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
            if Settings.Movement.EmoteDash and hum.MoveDirection.Magnitude > 0 then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.G, false, game)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.G, false, game)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end

            -- AUTO WIN
            if Settings.AutoFarm.AutoWin then
                local npcs = scanNextbots()
                local myPos = hrp.Position
                local danger = false
                for _, npc in ipairs(npcs) do
                    local dist = (npc.Position - myPos).Magnitude
                    local yDiff = math.abs(npc.Position.Y - myPos.Y)
                    if dist < 70 and yDiff < 15 then
                        danger = true
                        break
                    end
                end
                if danger then
                    hrp.CFrame = createSafePlatform(myPos)
                end
            end

            -- AUTO COLLECT TICKETS
            if Settings.AutoFarm.AutoTickets then
                local npcs = scanNextbots()
                local myPos = hrp.Position

                local nearestNpcDist = math.huge
                for _, npc in ipairs(npcs) do
                    local d = (npc.Position - myPos).Magnitude
                    if d < nearestNpcDist then nearestNpcDist = d end
                end

                if nearestNpcDist < 70 then
                    hrp.CFrame = createSafePlatform(myPos)
                    currentTicketTarget = nil
                    UpdateHUD()
                else
                    if not currentTicketTarget or not currentTicketTarget.Parent then
                        currentTicketTarget = nil
                        local ticketsFolder = Workspace:FindFirstChild("Effects") and Workspace.Effects:FindFirstChild("Tickets") and Workspace.Effects.Tickets:FindFirstChild("Visual")
                        if ticketsFolder then
                            local bestTicket = nil
                            local bestSafety = -1
                            for _, ticket in ipairs(ticketsFolder:GetChildren()) do
                                if ticket:IsA("BasePart") then
                                    local tPos = ticket.Position
                                    local minNpcToTicket = math.huge
                                    for _, npc in ipairs(npcs) do
                                        local d = (npc.Position - tPos).Magnitude
                                        if d < minNpcToTicket then minNpcToTicket = d end
                                    end
                                    if minNpcToTicket > 70 then
                                        if minNpcToTicket > bestSafety then
                                            bestSafety = minNpcToTicket
                                            bestTicket = ticket
                                        end
                                    end
                                end
                            end
                            if bestTicket then
                                currentTicketTarget = bestTicket
                                UpdateHUD()
                            end
                        end
                    end

                    if currentTicketTarget then
                        local tPos = currentTicketTarget.Position
                        local stillSafe = true
                        for _, npc in ipairs(npcs) do
                            if (npc.Position - tPos).Magnitude < 50 then
                                stillSafe = false
                                break
                            end
                        end
                        if stillSafe then
                            hrp.CFrame = CFrame.new(tPos)
                        else
                            hrp.CFrame = createSafePlatform(myPos)
                            currentTicketTarget = nil
                            UpdateHUD()
                        end
                    end
                end
            else
                if currentTicketTarget then
                    currentTicketTarget = nil
                    UpdateHUD()
                end
            end
        end

        -- Auto Vote
        if Settings.Vote.AutoVote then
            local ev = ReplicatedStorage:FindFirstChild("Events")
            if ev and ev:FindFirstChild("Player") and ev.Player:FindFirstChild("Vote") then
                ev.Player.Vote:FireServer(Settings.Vote.MapNumber)
            end
        end

        -- ESP oluşturma
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
                local part = b.Model:FindFirstChild("Hitbox") or b.Model:FindFirstChild("HumanoidRootPart")
                if part and not b.Model:FindFirstChild("EmloxaESP_Tag") then
                    CreateESP(b.Model, b.Model.Name, Color3.new(0.8,0.2,0.2), part, 3, Settings.Visuals.BotHighlight)
                end
            end
        end
        if Settings.Visuals.TicketESP then
            local tf = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Tickets")
            if tf then for _,t in pairs(tf:GetChildren()) do if t:IsA("BasePart") and not t:FindFirstChild("EmloxaESP_Tag") then CreateESP(t, "Ticket", Color3.fromRGB(255,215,0), t, 1, false) end end end
        end

        -- ESP güncelleme
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

    print("Emloxa Evade v8.6 (Optimized) yüklendi.")
end

return GameModule
