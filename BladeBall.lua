-- =========================================================================
-- EMLOXA WARE: BLADE BALL MAXIMUM PERFORMANCE MODULE v8 (REVISED)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local Stats = game:GetService("Stats")
    local Lighting = game:GetService("Lighting")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer

    local ScreenUI = Instance.new("ScreenGui")
    ScreenUI.Name = "EmloxaScreenUI"
    local success = pcall(function() ScreenUI.Parent = game:GetService("CoreGui") end)
    if not success then ScreenUI.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- HEDEF ETİKETİ
    local TargetLabel = Instance.new("TextLabel")
    TargetLabel.Size = UDim2.new(0, 200, 0, 50)
    TargetLabel.Position = UDim2.new(0, 20, 0.5, -25)
    TargetLabel.BackgroundTransparency = 1
    TargetLabel.Font = Enum.Font.GothamBold
    TargetLabel.TextSize = 28
    TargetLabel.Text = "TARGET: YOU!"
    TargetLabel.TextColor3 = Color3.fromRGB(255, 30, 30)
    TargetLabel.TextXAlignment = Enum.TextXAlignment.Left
    TargetLabel.Visible = false
    TargetLabel.Parent = ScreenUI
    Instance.new("UIStroke", TargetLabel).Color = Color3.fromRGB(0, 0, 0)
    Instance.new("UIStroke", TargetLabel).Thickness = 2

    -- FPS / PING
    local StatsLabel = Instance.new("TextLabel")
    StatsLabel.Size = UDim2.new(0, 150, 0, 20)
    StatsLabel.Position = UDim2.new(0, 10, 1, -30)
    StatsLabel.BackgroundTransparency = 1
    StatsLabel.Font = Enum.Font.GothamSemibold
    StatsLabel.TextSize = 12
    StatsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatsLabel.Text = "FPS: ... | PING: ..."
    StatsLabel.Parent = ScreenUI
    Instance.new("UIStroke", StatsLabel).Color = Color3.fromRGB(0, 0, 0)
    Instance.new("UIStroke", StatsLabel).Thickness = 1

    -- MAKRO ETİKETİ (Artık ScreenUI içinde)
    local MacroLabel = Instance.new("TextLabel")
    MacroLabel.Size = UDim2.new(0, 200, 0, 40)
    MacroLabel.Position = UDim2.new(0.5, -100, 1, -150)
    MacroLabel.BackgroundTransparency = 1
    MacroLabel.Font = Enum.Font.GothamBold
    MacroLabel.TextSize = 20
    MacroLabel.Text = "MACRO: OFF"
    MacroLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    MacroLabel.Visible = false
    MacroLabel.Parent = ScreenUI
    Instance.new("UIStroke", MacroLabel).Color = Color3.fromRGB(0, 0, 0)
    Instance.new("UIStroke", MacroLabel).Thickness = 2

    local frameCount, lastStatsUpdate = 0, tick()

    local PlayerTab = Window:CreateTab("Local Player")
    local NoclipEnabled, FlyEnabled = false, false
    local FlySpeed, CurrentSpeed, CurrentJump = 50, 16, 50

    PlayerTab:CreateToggle("Noclip (Pass Through Walls)", function(s) NoclipEnabled = s end)
    PlayerTab:CreateSlider("WalkSpeed Force", 16, 250, 16, function(v)
        CurrentSpeed = v
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    end)
    PlayerTab:CreateSlider("JumpPower Force", 50, 350, 50, function(v)
        CurrentJump = v
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.UseJumpPower = true
            LocalPlayer.Character.Humanoid.JumpPower = v
        end
    end)
    PlayerTab:CreateToggle("Fly Hack (Camera Based)", function(state)
        FlyEnabled = state
        local Char = LocalPlayer.Character
        local Root = Char and Char:FindFirstChild("HumanoidRootPart")
        local Hum = Char and Char:FindFirstChild("Humanoid")
        if not Root or not Hum then return end
        if FlyEnabled then
            Hum.PlatformStand = true
            local BodyVelocity = Instance.new("BodyVelocity", Root)
            BodyVelocity.Name = "EmloxaFly"
            BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            BodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
            local BodyGyro = Instance.new("BodyGyro", Root)
            BodyGyro.Name = "EmloxaGyro"
            BodyGyro.P = 9e4
            BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            BodyGyro.CFrame = Root.CFrame
            task.spawn(function()
                while FlyEnabled and Root and BodyVelocity.Parent do
                    local dir = Vector3.new(0, 0, 0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                    BodyVelocity.Velocity = dir.Unit * FlySpeed
                    if dir == Vector3.new(0, 0, 0) then BodyVelocity.Velocity = Vector3.new(0, 0.1, 0) end
                    BodyGyro.CFrame = Camera.CFrame
                    task.wait()
                end
            end)
        else
            Hum.PlatformStand = false
            if Root:FindFirstChild("EmloxaFly") then Root.EmloxaFly:Destroy() end
            if Root:FindFirstChild("EmloxaGyro") then Root.EmloxaGyro:Destroy() end
        end
    end)
    PlayerTab:CreateSlider("Fly Speed", 20, 200, 50, function(v) FlySpeed = v end)

    RunService.Stepped:Connect(function()
        local Char = LocalPlayer.Character
        if Char then
            if NoclipEnabled then
                for _, p in pairs(Char:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
                end
            end
            local Hum = Char:FindFirstChild("Humanoid")
            if Hum and not FlyEnabled then
                Hum.WalkSpeed = CurrentSpeed
                Hum.UseJumpPower = true
                Hum.JumpPower = CurrentJump
            end
        end
    end)

    local CombatTab = Window:CreateTab("Combat (Blade Ball)")

    local AutoParryEnabled, CamLookAtBall, CharLookAtBall = false, false, false
    local SpinBotEnabled, VisualizeParry = false, false
    local SpinSpeed = 50
    local PredictionFrames = 10

    -- Görsel küre
    local VisualizerSphere = Instance.new("Part")
    VisualizerSphere.Shape = Enum.PartType.Ball
    VisualizerSphere.Material = Enum.Material.ForceField
    VisualizerSphere.Color = Color3.fromRGB(102, 85, 255)
    VisualizerSphere.Transparency = 1
    VisualizerSphere.Anchored = true
    VisualizerSphere.CanCollide = false
    VisualizerSphere.CastShadow = false
    VisualizerSphere.Parent = workspace

    CombatTab:CreateToggle("Auto Parry (OS Core Math)", function(s) AutoParryEnabled = s end)
    CombatTab:CreateToggle("Visualize Parry Range", function(s) VisualizeParry = s end)
    CombatTab:CreateSlider("Prediction Distance (Frames)", 1, 30, 10, function(v) PredictionFrames = v end)

    CombatTab:CreateToggle("Camera Look At Ball", function(s) CamLookAtBall = s end)
    CombatTab:CreateToggle("Character Look At Ball", function(s) CharLookAtBall = s end)
    CombatTab:CreateToggle("Spin Bot", function(s) SpinBotEnabled = s end)
    CombatTab:CreateSlider("Spin Speed", 10, 100, 50, function(v) SpinSpeed = v end)

    -- PARRY REMOTE BULUCU
    local function FindParryRemote()
        local net = game:GetService("ReplicatedStorage"):FindFirstChild("Packages")
        if net then
            net = net:FindFirstChild("_Index")
            if net then
                net = net:FindFirstChild("sleitnick_net@0.1.0")
                if net then
                    net = net:FindFirstChild("net")
                    if net then
                        -- spy'daki isimle eşleşen ilk remote'u bul
                        for _, v in pairs(net:GetChildren()) do
                            if v:IsA("RemoteEvent") and v.Name:find("^RE/") then
                                return v
                            end
                        end
                    end
                end
            end
        end
        return nil
    end

    -- TEST BUTONU İLE STATİK REMOTE ÇAĞRISI
    CombatTab:CreateButton("Test Parry (Remote)", function()
        local remote = FindParryRemote()
        if not remote then
            warn("Parry remote bulunamadı!")
            return
        end
        -- Spy verisindeki statik değerler (sadece test amaçlı)
        remote:FireServer(
            "5455ef47-de02-4074-808c-8d82c2cd12ec",
            "D9ZAlO",
            "h|Pq\x1Ead\x04)\bga",
            0.5,
            CFrame.new(-290.70254516602, 131.43264770508, 233.85081481934, -0.96353876590729, 0.13010221719742, -0.23380860686302, 0, 0.87382620573044, 0.48623844981194, 0.26756876707077, 0.4685095846653, -0.84196537733078),
            {
                ["Target<9c654e92-9c3b-41f3-bced-993af6a8c359>"] = Vector3.new(506.64151000977, 80.015319824219, 64.09147644043),
                ["Target<3bacac28-eac7-4081-ab46-37ea6ee81f21>"] = Vector3.new(1041.1909179688, 57.053558349609, 90.963714599609),
                ["Target<d7d8df1f-74ad-4482-a3ed-2b0b5bd57010>"] = Vector3.new(1254.5333251953, -143.73718261719, 108.68649291992),
                ["Target<107bdd32-f849-4ddc-a285-478e5d3ad390>"] = Vector3.new(350.78713989258, 94.86701965332, 47.255836486816),
                ["Target<cf302aa1-7ba1-4be7-851a-5667f1cd78f4>"] = Vector3.new(586.974609375, -131.7314453125, 133.52391052246),
                ["Target<1adc9cb2-448c-41f1-81a2-617d768ebec0>"] = Vector3.new(1480.4177246094, -26.817138671875, 37.819808959961),
                ["Target<df9892ac-f607-42cf-9141-d0f99203ad6a>"] = Vector3.new(758.11730957031, 6.6055297851562, 74.833724975586),
                ["Target<e00d571f-94d3-4c31-b8b8-4976340d0a36>"] = Vector3.new(828.31805419922, -13.851531982422, 119.21705627441),
                ["Target<5256d3c9-e778-420f-8458-bc855fa73133>"] = Vector3.new(730.36199951172, 28.089294433594, 158.5841217041),
                ["Target<e6cb1875-ba56-4137-9d8b-3cc07c8b357b>"] = Vector3.new(921.15661621094, -16.237854003906, 114.08932495117),
                ["Target<13d0a6f7-cef4-4980-8d4e-27d8b1d8803f>"] = Vector3.new(1273.8316650391, -264.52813720703, 101.51066589355),
                ["Target<b2eb292f-fe4f-4396-a694-bcc9ebe6e1d3>"] = Vector3.new(1156.3142089844, -219.603515625, 111.06378173828),
                ["Target<51f95360-471b-4495-b430-072f4a783d81>"] = Vector3.new(1146.3669433594, -112.22647094727, 118.1311340332),
                ["Target<628485b4-3ca4-415d-b1dc-e9a82381d485>"] = Vector3.new(607.56848144531, 31.71337890625, 150.66381835938),
                ["Target<6f3da9f3-eec7-426b-a0cd-fda6015273cc>"] = Vector3.new(661.63842773438, 14.149780273438, 98.951385498047),
                deadnegzel61 = Vector3.new(768.00091552734, 391.78372192383, 13.229377746582),
                ["Target<70506537-7d4a-48f4-aaed-687b3edc8f36>"] = Vector3.new(1182.3653564453, 72.087432861328, 79.093780517578)
            },
            {661, 414},
            false
        )
    end)

    -- YENİ PARRY FONKSİYONU: Remote varsa onu kullan, yoksa sol tık simüle et
    local function Parry()
        local remote = FindParryRemote()
        if remote then
            -- Dinamik veri oluştur (topun ve oyuncunun bilgileri)
            local ball = GetActiveBall()
            if ball and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local root = LocalPlayer.Character.HumanoidRootPart
                local targets = {["deadnegzel61"] = Vector3.new(768, 391, 13)} -- örnek, gerçekte diğer hedefleri eklemek gerek
                -- Basit bir çağrı: oyunun beklediği tüm argümanları kopyalamak zor, bu yüzden simülasyona düş
            end
        end
        -- Fallback: sol fare tuşu gönder
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.02)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end

    -- TOP TESPİTİ
    local function GetActiveBall()
        local ballsFolder = workspace:FindFirstChild("Balls")
        if ballsFolder then
            for _, item in pairs(ballsFolder:GetChildren()) do
                if item:IsA("BasePart") and item:GetAttribute("realBall") == true then
                    return item
                end
            end
        end
        return nil
    end

    local function IsTargetingMe()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Highlight") then
            return true
        end
        return false
    end

    local OldPosition = Vector3.new()
    local SmoothedVelocity = 0
    local LastParryTime = 0
    local EMA_ALPHA = 0.2
    local OldTick = tick()

    RunService.RenderStepped:Connect(function(deltaTime)
        frameCount = frameCount + 1
        local currentTime = tick()
        if currentTime - lastStatsUpdate >= 1 then
            local fps = math.floor(frameCount / (currentTime - lastStatsUpdate))
            local currentPing = 0
            pcall(function()
                currentPing = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            end)

            local pingColor = "<font color='#55FF55'>" .. currentPing .. "ms</font>"
            if currentPing > 100 then pingColor = "<font color='#FFFF55'>" .. currentPing .. "ms</font>" end
            if currentPing > 200 then pingColor = "<font color='#FF5555'>" .. currentPing .. "ms</font>" end

            StatsLabel.RichText = true
            StatsLabel.Text = string.format("FPS: %d | PING: %s", fps, pingColor)
            frameCount, lastStatsUpdate = 0, currentTime
        end

        local Character = LocalPlayer.Character
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")

        if Root then
            local activeBall = GetActiveBall()
            local isTargetingMe = IsTargetingMe()

            TargetLabel.Visible = isTargetingMe

            if SpinBotEnabled then
                Root.CFrame = Root.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
            end

            if activeBall then
                if CamLookAtBall and not SpinBotEnabled then
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, activeBall.Position)
                end
                if CharLookAtBall and not SpinBotEnabled then
                    local targetPos = Vector3.new(activeBall.Position.X, Root.Position.Y, activeBall.Position.Z)
                    Root.CFrame = CFrame.new(Root.Position, targetPos)
                end

                local rawVelocity = 0
                local success, assemblyVel = pcall(function()
                    return activeBall.AssemblyLinearVelocity.Magnitude
                end)
                if success and assemblyVel then
                    rawVelocity = assemblyVel
                else
                    if tick() - OldTick >= 1/60 then
                        rawVelocity = (OldPosition - activeBall.Position).Magnitude / (tick() - OldTick)
                        OldPosition = activeBall.Position
                        OldTick = tick()
                    end
                end
                SmoothedVelocity = SmoothedVelocity == 0 and rawVelocity or SmoothedVelocity + EMA_ALPHA * (rawVelocity - SmoothedVelocity)

                local Distance = (activeBall.Position - Root.Position).Magnitude
                local predictionTime = PredictionFrames / 60
                local dynamicDistance = SmoothedVelocity * predictionTime
                dynamicDistance = math.max(12, dynamicDistance)

                if VisualizeParry then
                    local targetSize = Vector3.new(dynamicDistance * 2, dynamicDistance * 2, dynamicDistance * 2)
                    VisualizerSphere.Transparency = 0.6
                    VisualizerSphere.Size = VisualizerSphere.Size:Lerp(targetSize, 0.15)
                    VisualizerSphere.Position = Root.Position
                    VisualizerSphere.Color = isTargetingMe and Color3.fromRGB(255, 30, 30) or Color3.fromRGB(102, 85, 255)
                else
                    VisualizerSphere.Transparency = 1
                end

                if AutoParryEnabled and isTargetingMe then
                    local timeToImpact = Distance / math.max(SmoothedVelocity, 0.1)
                    if timeToImpact <= predictionTime and (tick() - LastParryTime > 0.15) then
                        Parry()
                        LastParryTime = tick()
                        if VisualizeParry then VisualizerSphere.Transparency = 0.1 end
                    end
                    if Distance < 5 and (tick() - LastParryTime > 0.15) then
                        Parry()
                        LastParryTime = tick()
                        if VisualizeParry then VisualizerSphere.Transparency = 0.1 end
                    end
                end
            else
                if VisualizeParry then
                    VisualizerSphere.Transparency = 1
                    VisualizerSphere.Size = Vector3.zero
                end
            end
        end
    end)

    -- MACRO
    local MacroTab = Window:CreateTab("Macro (F Spammer)")
    local MacroMasterToggle = false
    local IsMacroActive = false

    MacroTab:CreateToggle("Enable Macro System (Key: E)", function(state)
        MacroMasterToggle = state
        MacroLabel.Visible = state
        if not state then
            IsMacroActive = false
            MacroLabel.Text = "MACRO: OFF"
            MacroLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.E and MacroMasterToggle then
            IsMacroActive = not IsMacroActive
            if IsMacroActive then
                MacroLabel.Text = "MACRO: ON (Spamming)"
                MacroLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
            else
                MacroLabel.Text = "MACRO: OFF"
                MacroLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            end
        end
    end)

    task.spawn(function()
        while true do
            if MacroMasterToggle and IsMacroActive then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
            task.wait()
        end
    end)

    -- MISC
    local MiscTab = Window:CreateTab("Misc")

    local RGBCharEnabled, DiscoEnabled = false, false
    local RGBCharSpeed, OriginalColors = 2, {}
    local origAmb, origOut, origFog = Lighting.Ambient, Lighting.OutdoorAmbient, Lighting.FogColor

    MiscTab:CreateToggle("RGB Character", function(s)
        RGBCharEnabled = s
        if not s and LocalPlayer.Character then
            for p, c in pairs(OriginalColors) do
                if p and p.Parent == LocalPlayer.Character then p.Color = c end
            end
            OriginalColors = {}
        end
    end)
    MiscTab:CreateSlider("RGB Character Speed", 1, 10, 2, function(v) RGBCharSpeed = v end)

    MiscTab:CreateToggle("Disco Mode (Sky)", function(s)
        DiscoEnabled = s
        if not s then
            Lighting.Ambient = origAmb
            Lighting.OutdoorAmbient = origOut
            Lighting.FogColor = origFog
        end
    end)

    RunService.RenderStepped:Connect(function()
        if RGBCharEnabled and LocalPlayer.Character then
            local color = Color3.fromHSV((tick() * RGBCharSpeed * 0.1) % 1, 1, 1)
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    if not OriginalColors[part] then OriginalColors[part] = part.Color end
                    part.Color = color
                end
            end
        end
        if DiscoEnabled then
            local col = Color3.fromHSV((tick() * 0.5) % 1, 1, 1)
            Lighting.Ambient = col
            Lighting.OutdoorAmbient = col
            Lighting.FogColor = col
        end
    end)

    MiscTab:CreateButton("Unload EMLOXA WARE", function()
        AutoParryEnabled = false
        CamLookAtBall = false
        CharLookAtBall = false
        SpinBotEnabled = false
        MacroMasterToggle = false
        IsMacroActive = false
        RGBCharEnabled = false
        DiscoEnabled = false
        VisualizerSphere:Destroy()
        ScreenUI:Destroy()
        Lighting.Ambient = origAmb
        Lighting.OutdoorAmbient = origOut
        Lighting.FogColor = origFog
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaScreenUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaScreenUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
