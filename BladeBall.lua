-- =========================================================================
-- EMLOXA WARE: BLADE BALL MAXIMUM PERFORMANCE MODULE v8 (OPEN SOURCE CORE)
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
    -- 0. EKRAN ARAYÜZLERİ (TARGET & STATS UI)
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
    Instance.new("UIStroke", TargetLabel).Color = Color3.fromRGB(0, 0, 0)
    Instance.new("UIStroke", TargetLabel).Thickness = 2

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

    local frameCount, lastStatsUpdate = 0, tick()

    -- ==========================================
    -- 1. LOCAL PLAYER SEKME SİSTEMİ
    -- ==========================================
    local PlayerTab = Window:CreateTab("Local Player")
    local NoclipEnabled, FlyEnabled = false, false
    local FlySpeed, CurrentSpeed, CurrentJump = 50, 16, 50

    PlayerTab:CreateToggle("Noclip (Pass Through Walls)", function(s) NoclipEnabled = s end)
    PlayerTab:CreateSlider("WalkSpeed Force", 16, 250, 16, function(v)
        CurrentSpeed = v
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end
    end)
    PlayerTab:CreateSlider("JumpPower Force", 50, 350, 50, function(v)
        CurrentJump = v
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = v end
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
            BodyVelocity.Name = "EmloxaFly"; BodyVelocity.Velocity = Vector3.new(0, 0, 0); BodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
            local BodyGyro = Instance.new("BodyGyro", Root)
            BodyGyro.Name = "EmloxaGyro"; BodyGyro.P = 9e4; BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9); BodyGyro.CFrame = Root.CFrame
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
            if NoclipEnabled then for _, p in pairs(Char:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end end end
            local Hum = Char:FindFirstChild("Humanoid")
            if Hum and not FlyEnabled then Hum.WalkSpeed = CurrentSpeed; Hum.UseJumpPower = true; Hum.JumpPower = CurrentJump end
        end
    end)

    -- ==========================================
    -- 2. BLADE BALL: OS-CORE AUTO PARRY & VISUALIZER
    -- ==========================================
    local CombatTab = Window:CreateTab("Combat (Blade Ball)")
    
    local AutoParryEnabled, CamLookAtBall, CharLookAtBall = false, false, false
    local SpinBotEnabled, VisualizeParry = false, false
    local SpinSpeed = 50
    local PredictionFrames = 10

    -- Visualizer Küresi
    local VisualizerSphere = Instance.new("Part")
    VisualizerSphere.Shape = Enum.PartType.Ball
    VisualizerSphere.Material = Enum.Material.ForceField
    VisualizerSphere.Color = Color3.fromRGB(102, 85, 255)
    VisualizerSphere.Transparency = 1
    VisualizerSphere.Anchored = true
    VisualizerSphere.CanCollide = false
    VisualizerSphere.CastShadow = false
    VisualizerSphere.Parent = workspace

    -- RGB Ball Highlight (daha güvenilir neon efekti)
    local BallHighlight = Instance.new("Highlight")
    BallHighlight.Name = "EmloxaRGB"
    BallHighlight.FillColor = Color3.fromRGB(255, 255, 255)
    BallHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    BallHighlight.FillTransparency = 0.5
    BallHighlight.OutlineTransparency = 0
    BallHighlight.Enabled = false
    BallHighlight.Parent = workspace

    CombatTab:CreateToggle("Auto Parry (OS Core Math)", function(s) AutoParryEnabled = s end)
    CombatTab:CreateToggle("Visualize Parry Range", function(s) VisualizeParry = s end)
    CombatTab:CreateSlider("Prediction Distance (Frames)", 1, 30, 10, function(v) PredictionFrames = v end)

    CombatTab:CreateToggle("Camera Look At Ball", function(s) CamLookAtBall = s end)
    CombatTab:CreateToggle("Character Look At Ball", function(s) CharLookAtBall = s end)
    CombatTab:CreateToggle("Spin Bot", function(s) SpinBotEnabled = s end)
    CombatTab:CreateSlider("Spin Speed", 10, 100, 50, function(v) SpinSpeed = v end)

    -- Aktif topu bulma
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

    -- Hedef biz miyiz?
    local function IsTargetingMe()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Highlight") then
            return true
        end
        return false
    end

    -- Parry işlemi (F + Mouse1)
    local function Parry()
        task.spawn(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            task.wait(0.02)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        end)
    end

    -- Hız hesaplama değişkenleri (daha yumuşak hareket için EMA)
    local OldPosition = Vector3.new()
    local SmoothedVelocity = 0
    local LastParryTime = 0
    local EMA_ALPHA = 0.2 -- Yumuşatma katsayısı

    RunService.RenderStepped:Connect(function(deltaTime)
        -- FPS & PING
        frameCount = frameCount + 1
        local currentTime = tick()
        if currentTime - lastStatsUpdate >= 1 then
            local fps = math.floor(frameCount / (currentTime - lastStatsUpdate))
            local currentPing = 0
            pcall(function() currentPing = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            
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

            if SpinBotEnabled then Root.CFrame = Root.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0) end

            if activeBall then
                if CamLookAtBall and not SpinBotEnabled then Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, activeBall.Position) end
                if CharLookAtBall and not SpinBotEnabled then
                    local targetPos = Vector3.new(activeBall.Position.X, Root.Position.Y, activeBall.Position.Z)
                    Root.CFrame = CFrame.new(Root.Position, targetPos)
                end

                -- Daha hassas hız hesaplama (AssemblyLinearVelocity kullan)
                local rawVelocity = 0
                local success, assemblyVel = pcall(function() return activeBall.AssemblyLinearVelocity.Magnitude end)
                if success and assemblyVel then
                    rawVelocity = assemblyVel
                else
                    if tick() - OldTick >= 1/60 then
                        rawVelocity = (OldPosition - activeBall.Position).Magnitude / (tick() - OldTick)
                        OldPosition = activeBall.Position
                        OldTick = tick()
                    end
                end
                -- Yumuşatılmış hız (EMA)
                SmoothedVelocity = SmoothedVelocity == 0 and rawVelocity or SmoothedVelocity + EMA_ALPHA * (rawVelocity - SmoothedVelocity)

                local Distance = (activeBall.Position - Root.Position).Magnitude

                -- Visualizer boyutu için dinamik mesafe (sabitlenmiş prediction süresi)
                local predictionTime = PredictionFrames / 60 -- saniye cinsinden
                local dynamicDistance = SmoothedVelocity * predictionTime
                dynamicDistance = math.max(12, dynamicDistance) -- minimum yarıçap

                -- Visualizer güncellemesi (yumuşak geçiş + yoksa sıfırla)
                if VisualizeParry then
                    local targetSize = Vector3.new(dynamicDistance * 2, dynamicDistance * 2, dynamicDistance * 2)
                    VisualizerSphere.Transparency = 0.6
                    -- Çok yumuşak hareket için 0.15 katsayı ile lerp
                    VisualizerSphere.Size = VisualizerSphere.Size:Lerp(targetSize, 0.15)
                    VisualizerSphere.Position = Root.Position
                    VisualizerSphere.Color = isTargetingMe and Color3.fromRGB(255, 30, 30) or Color3.fromRGB(102, 85, 255)
                else
                    VisualizerSphere.Transparency = 1
                end

                -- Vuruş kontrolü (daha agresif, %100 isabet)
                if AutoParryEnabled and isTargetingMe then
                    local timeToImpact = Distance / math.max(SmoothedVelocity, 0.1)
                    if timeToImpact <= predictionTime and (tick() - LastParryTime > 0.15) then
                        Parry()
                        LastParryTime = tick()
                        if VisualizeParry then VisualizerSphere.Transparency = 0.1 end
                    end
                    -- Ekstra güvenlik: eğer top çok yakınsa direkt vur
                    if Distance < 5 and (tick() - LastParryTime > 0.15) then
                        Parry()
                        LastParryTime = tick()
                        if VisualizeParry then VisualizerSphere.Transparency = 0.1 end
                    end
                end
            else
                -- Top yoksa visualizer sıfırlanır
                if VisualizeParry then
                    VisualizerSphere.Transparency = 1
                    VisualizerSphere.Size = Vector3.zero
                end
            end
        end
    end)

    -- RGB Ball sistemi (Highlight ile daha güvenilir)
    local RGBBallEnabled = false
    CombatTab:CreateToggle("RGB Ball (Neon)", function(s)
        RGBBallEnabled = s
        if not s then
            BallHighlight.Enabled = false
        end
    end)

    -- RGB Ball rengini sürekli güncelle
    task.spawn(function()
        while true do
            if RGBBallEnabled then
                local ball = GetActiveBall()
                if ball then
                    BallHighlight.Parent = ball
                    BallHighlight.Enabled = true
                    local col = Color3.fromHSV((tick() * 2) % 1, 1, 1)
                    BallHighlight.FillColor = col
                    BallHighlight.OutlineColor = col
                else
                    BallHighlight.Enabled = false
                end
            end
            task.wait()
        end
    end)

    -- ==========================================
    -- 3. MACRO (F SPAMMER) SİSTEMİ
    -- ==========================================
    local MacroTab = Window:CreateTab("Macro (F Spammer)")
    local MacroMasterToggle = false
    local IsMacroActive = false

    local MacroUI = Instance.new("ScreenGui")
    MacroUI.Name = "EmloxaMacroUI"
    local successMacro = pcall(function() MacroUI.Parent = game:GetService("CoreGui") end)
    if not successMacro then MacroUI.Parent = LocalPlayer:WaitForChild("PlayerGui") end

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
    Instance.new("UIStroke", MacroLabel).Color = Color3.fromRGB(0, 0, 0); Instance.new("UIStroke", MacroLabel).Thickness = 2

    MacroTab:CreateToggle("Enable Macro System (Key: E)", function(state)
        MacroMasterToggle = state; MacroLabel.Visible = state
        if not state then IsMacroActive = false; MacroLabel.Text = "MACRO: OFF"; MacroLabel.TextColor3 = Color3.fromRGB(255, 50, 50) end
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
    -- 4. MISC (RGB & FUN) EKLENTİLERİ
    -- ==========================================
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
        AutoParryEnabled = false; CamLookAtBall = false; CharLookAtBall = false
        SpinBotEnabled = false; MacroMasterToggle = false; IsMacroActive = false
        RGBBallEnabled = false; RGBCharEnabled = false; DiscoEnabled = false
        VisualizerSphere:Destroy()
        BallHighlight:Destroy()
        MacroUI:Destroy()
        ScreenUI:Destroy()
        Lighting.Ambient = origAmb; Lighting.OutdoorAmbient = origOut; Lighting.FogColor = origFog
    end)
end

return GameModule
