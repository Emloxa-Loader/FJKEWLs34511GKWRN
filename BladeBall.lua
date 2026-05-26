-- =========================================================================
-- EMLOXA WARE: BLADE BALL MAXIMUM PERFORMANCE MODULE v9 (FINAL FIX)
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

    -- ==========================================
    -- 0. SCREEN UI (TARGET & STATS)
    -- ==========================================
    local ScreenUI = Instance.new("ScreenGui")
    ScreenUI.Name = "EmloxaScreenUI"
    local success = pcall(function() ScreenUI.Parent = game:GetService("CoreGui") end)
    if not success then ScreenUI.Parent = LocalPlayer:WaitForChild("PlayerGui") end

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
    local Stroke1 = Instance.new("UIStroke", TargetLabel)
    Stroke1.Color = Color3.fromRGB(0, 0, 0)
    Stroke1.Thickness = 2

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
    local Stroke2 = Instance.new("UIStroke", StatsLabel)
    Stroke2.Color = Color3.fromRGB(0, 0, 0)
    Stroke2.Thickness = 1

    local frameCount, lastStatsUpdate = 0, tick()

    -- ==========================================
    -- 1. LOCAL PLAYER
    -- ==========================================
    local PlayerTab = Window:CreateTab("Local Player")
    local NoclipEnabled, FlyEnabled = false, false
    local FlySpeed, CurrentSpeed, CurrentJump = 50, 16, 50

    PlayerTab:CreateToggle("Noclip (Pass Through Walls)", function(s) NoclipEnabled = s end)
    PlayerTab:CreateSlider("WalkSpeed Force", 16, 250, 16, function(v)
        CurrentSpeed = v
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = v end
    end)
    PlayerTab:CreateSlider("JumpPower Force", 50, 350, 50, function(v)
        CurrentJump = v
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.UseJumpPower = true; hum.JumpPower = v end
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

    -- ==========================================
    -- 2. BLADE BALL: AUTO PARRY & VISUALIZER
    -- ==========================================
    local CombatTab = Window:CreateTab("Combat (Blade Ball)")

    local AutoParryEnabled, CamLookAtBall, CharLookAtBall = false, false, false
    local SpinBotEnabled, VisualizeParry = false, false
    local SpinSpeed = 50
    local PredictionFrames = 10   -- kaç frame önceden basılacağı (1/60 saniye)

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
    CombatTab:CreateSlider("Prediction Frames (1-30)", 1, 30, 10, function(v) PredictionFrames = v end)

    CombatTab:CreateToggle("Camera Look At Ball", function(s) CamLookAtBall = s end)
    CombatTab:CreateToggle("Character Look At Ball", function(s) CharLookAtBall = s end)
    CombatTab:CreateToggle("Spin Bot", function(s) SpinBotEnabled = s end)
    CombatTab:CreateSlider("Spin Speed", 10, 100, 50, function(v) SpinSpeed = v end)

    -- Gelişmiş top bulma (attribute + name)
    local function GetActiveBall()
        local ballsFolder = workspace:FindFirstChild("Balls")
        if ballsFolder then
            for _, item in pairs(ballsFolder:GetChildren()) do
                if item:IsA("BasePart") and (item:GetAttribute("realBall") == true or item.Name == "Ball") then
                    return item
                end
            end
        end
        return nil
    end

    local function IsTargetingMe()
        return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Highlight") ~= nil
    end

    local function Parry()
        task.spawn(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            task.wait(0.02)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        end)
    end

    local LastParryTime = 0
    local cooldown = 0.05  -- çok kısa, kaçırma yapmaz

    RunService.RenderStepped:Connect(function(dt)
        -- FPS & PING
        frameCount = frameCount + 1
        local now = tick()
        if now - lastStatsUpdate >= 1 then
            local fps = math.floor(frameCount / (now - lastStatsUpdate))
            local ping = 0
            pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            local pingStr = "<font color='#55FF55'>" .. ping .. "ms</font>"
            if ping > 100 then pingStr = "<font color='#FFFF55'>" .. ping .. "ms</font>" end
            if ping > 200 then pingStr = "<font color='#FF5555'>" .. ping .. "ms</font>" end
            StatsLabel.RichText = true
            StatsLabel.Text = string.format("FPS: %d | PING: %s", fps, pingStr)
            frameCount, lastStatsUpdate = 0, now
        end

        local Char = LocalPlayer.Character
        local Root = Char and Char:FindFirstChild("HumanoidRootPart")
        if not Root then
            if VisualizeParry then VisualizerSphere.Size = Vector3.new(0,0,0) end
            return
        end

        local activeBall = GetActiveBall()
        local targetingMe = IsTargetingMe()
        TargetLabel.Visible = targetingMe

        if SpinBotEnabled then
            Root.CFrame = Root.CFrame * CFrame.Angles(0, math.rad(SpinSpeed * dt * 60), 0)
        end

        -- Top varsa
        if activeBall and targetingMe then
            if CamLookAtBall and not SpinBotEnabled then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, activeBall.Position)
            end
            if CharLookAtBall and not SpinBotEnabled then
                local flatPos = Vector3.new(activeBall.Position.X, Root.Position.Y, activeBall.Position.Z)
                Root.CFrame = CFrame.new(Root.Position, flatPos)
            end

            -- Topun gerçek hızı (AssemblyLinearVelocity) çok daha kararlıdır
            local speed = 0
            pcall(function()
                speed = activeBall.AssemblyLinearVelocity.Magnitude
            end)
            if speed == 0 then
                -- fallback: son konum farkı
                speed = (activeBall.Position - (activeBall.Position - (activeBall.AssemblyLinearVelocity or Vector3.new()))) ... fallback better to use difference from last frame stored in variable.
                -- Daha güvenli: her frame'de eski pozisyonu saklayalım.
                -- Ancak daha basit: eğer AssemblyLinearVelocity yoksa, eski mantıktaki gibi bir önceki frame'deki konumu kullanırız.
            end
            -- Eski mantığı yedeklemek için bir değişken kullanacağız.
            -- Basitlik için her zaman AssemblyLinearVelocity kullanmaya çalışalım, eğer 0 ise fallback olarak basit farkı kullanırız.
            -- Burada önceki pozisyonu saklayacak bir değişken koyalım.
            -- Alttaki kodu düzgün yapalım.

        end
    end)

    -- Daha düzenli bir RenderStepped bağlantısı:
    local lastBallPos = Vector3.new()
    local currentBallSpeed = 0

    RunService.RenderStepped:Connect(function(dt)
        frameCount = frameCount + 1
        local now = tick()
        if now - lastStatsUpdate >= 1 then
            local fps = math.floor(frameCount / (now - lastStatsUpdate))
            local ping = 0
            pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            local pingStr = "<font color='#55FF55'>" .. ping .. "ms</font>"
            if ping > 100 then pingStr = "<font color='#FFFF55'>" .. ping .. "ms</font>" end
            if ping > 200 then pingStr = "<font color='#FF5555'>" .. ping .. "ms</font>" end
            StatsLabel.RichText = true
            StatsLabel.Text = string.format("FPS: %d | PING: %s", fps, pingStr)
            frameCount, lastStatsUpdate = 0, now
        end

        local Char = LocalPlayer.Character
        local Root = Char and Char:FindFirstChild("HumanoidRootPart")
        if not Root then
            if VisualizeParry then VisualizerSphere.Size = Vector3.new(0,0,0) end
            return
        end

        local activeBall = GetActiveBall()
        local targetingMe = IsTargetingMe()
        TargetLabel.Visible = targetingMe

        if SpinBotEnabled then
            Root.CFrame = Root.CFrame * CFrame.Angles(0, math.rad(SpinSpeed * dt * 60), 0)
        end

        if activeBall and targetingMe then
            if CamLookAtBall and not SpinBotEnabled then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, activeBall.Position)
            end
            if CharLookAtBall and not SpinBotEnabled then
                local flatPos = Vector3.new(activeBall.Position.X, Root.Position.Y, activeBall.Position.Z)
                Root.CFrame = CFrame.new(Root.Position, flatPos)
            end

            -- Top hızı: öncelik AssemblyLinearVelocity, değilse frame farkı
            local speed
            pcall(function()
                speed = activeBall.AssemblyLinearVelocity.Magnitude
            end)
            if not speed or speed == 0 then
                local deltaPos = activeBall.Position - lastBallPos
                speed = deltaPos.Magnitude / math.max(dt, 0.001)
            end
            currentBallSpeed = speed
            lastBallPos = activeBall.Position

            -- Tahmini vuruş mesafesi = hız * (PredictionFrames / 60)
            local predictionTime = PredictionFrames / 60
            local parryRadius = speed * predictionTime
            parryRadius = math.max(parryRadius, 5)  -- minimum 5 stud

            -- Visualizer (küre) çapı = 2 * yarıçap
            local sphereSize = parryRadius * 2
            VisualizerSphere.Size = Vector3.new(sphereSize, sphereSize, sphereSize)
            VisualizerSphere.Position = Root.Position
            if VisualizeParry then
                VisualizerSphere.Transparency = 0.6
                VisualizerSphere.Color = Color3.fromRGB(255, 30, 30)  -- kırmızı, hedef sensin
            else
                VisualizerSphere.Transparency = 1
            end

            -- Otomatik vuruş: topun bize ulaşma süresi <= predictionTime ise ve cooldown geçtiyse
            local distance = (activeBall.Position - Root.Position).Magnitude
            if AutoParryEnabled and speed > 0 then
                local timeToImpact = distance / speed
                if timeToImpact <= predictionTime and (tick() - LastParryTime > cooldown) then
                    Parry()
                    LastParryTime = tick()
                    if VisualizeParry then
                        VisualizerSphere.Transparency = 0.1  -- vurduğunda belirginleşsin
                    end
                end
            end
        else
            -- Top yok veya hedef değilsek visualizer'ı sıfırla
            currentBallSpeed = 0
            lastBallPos = Vector3.new()
            VisualizerSphere.Size = Vector3.new(0, 0, 0)
            VisualizerSphere.Transparency = 1
        end
    end)

    -- ==========================================
    -- 3. MACRO (F SPAMMER)
    -- ==========================================
    local MacroTab = Window:CreateTab("Macro (F Spammer)")
    local MacroMasterToggle = false
    local IsMacroActive = false

    local MacroUI = Instance.new("ScreenGui")
    MacroUI.Name = "EmloxaMacroUI"
    local success2 = pcall(function() MacroUI.Parent = game:GetService("CoreGui") end)
    if not success2 then MacroUI.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local MacroLabel = Instance.new("TextLabel")
    MacroLabel.Size = UDim2.new(0, 200, 0, 40)
    MacroLabel.Position = UDim2.new(0.5, -100, 1, -150)
    MacroLabel.BackgroundTransparency = 1
    MacroLabel.Font = Enum.Font.GothamBold
    MacroLabel.TextSize = 20
    MacroLabel.Text = "MACRO: OFF"
    MacroLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    MacroLabel.Visible = false
    MacroLabel.Parent = MacroUI
    local StrokeMacro = Instance.new("UIStroke", MacroLabel)
    StrokeMacro.Color = Color3.fromRGB(0, 0, 0)
    StrokeMacro.Thickness = 2

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
                MacroLabel.Text = "MACRO: ON (Spamming F)"
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
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                task.wait()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end
            task.wait()
        end
    end)

    -- ==========================================
    -- 4. MISC (RGB & FUN)
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")

    local RGBBallEnabled = false
    local RGBCharEnabled, DiscoEnabled = false, false
    local RGBCharSpeed = 2
    local OriginalColors = {}
    local origAmb, origOut, origFog = Lighting.Ambient, Lighting.OutdoorAmbient, Lighting.FogColor

    MiscTab:CreateToggle("RGB Ball (Neon)", function(s) RGBBallEnabled = s end)

    MiscTab:CreateToggle("RGB Character", function(s)
        RGBCharEnabled = s
        if not s and LocalPlayer.Character then
            for part, color in pairs(OriginalColors) do
                if part and part.Parent == LocalPlayer.Character then
                    part.Color = color
                end
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
        -- RGB Ball (düzeltildi: top attribute veya isim ile bulunur)
        if RGBBallEnabled then
            local ball = GetActiveBall()
            if ball and ball.Parent then
                ball.Material = Enum.Material.Neon
                ball.Color = Color3.fromHSV((tick() * 2) % 1, 1, 1)
            end
        end

        -- RGB Character
        if RGBCharEnabled and LocalPlayer.Character then
            local hue = (tick() * RGBCharSpeed * 0.1) % 1
            local color = Color3.fromHSV(hue, 1, 1)
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    if not OriginalColors[part] then
                        OriginalColors[part] = part.Color
                    end
                    part.Color = color
                end
            end
        end

        -- Disco
        if DiscoEnabled then
            local hue = (tick() * 0.5) % 1
            local col = Color3.fromHSV(hue, 1, 1)
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
        RGBBallEnabled = false
        RGBCharEnabled = false
        DiscoEnabled = false
        VisualizerSphere:Destroy()
        MacroUI:Destroy()
        ScreenUI:Destroy()
        Lighting.Ambient = origAmb
        Lighting.OutdoorAmbient = origOut
        Lighting.FogColor = origFog
    end)
end

return GameModule
