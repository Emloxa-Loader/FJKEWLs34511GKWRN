-- =========================================================================
-- EMLOXA WARE: BLADE BALL MAXIMUM PERFORMANCE MODULE v7 (LIMITLESS PARRY & STATS)
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

    -- Hedef Yazısı (Sol Orta)
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

    -- FPS ve PING Göstergesi (Sol Alt)
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

    -- FPS Hesaplama Değişkenleri
    local frameCount = 0
    local lastStatsUpdate = tick()

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
    -- 2. BLADE BALL: LİMİTSİZ AUTO PARRY & VISUALIZER
    -- ==========================================
    local CombatTab = Window:CreateTab("Combat (Blade Ball)")
    
    local AutoParryEnabled, CamLookAtBall, CharLookAtBall = false, false, false
    local SpinBotEnabled, VisualizeParry = false, false
    local SpinSpeed = 50
    local BaseDistance = 15
    local PredictionMultiplier = 5 

    local VisualizerSphere = Instance.new("Part")
    VisualizerSphere.Shape = Enum.PartType.Ball
    VisualizerSphere.Material = Enum.Material.ForceField
    VisualizerSphere.Color = Color3.fromRGB(102, 85, 255)
    VisualizerSphere.Transparency = 1
    VisualizerSphere.Anchored = true
    VisualizerSphere.CanCollide = false
    VisualizerSphere.CastShadow = false
    VisualizerSphere.Parent = workspace

    CombatTab:CreateToggle("Auto Parry (Limitless Prediction)", function(s) AutoParryEnabled = s end)
    CombatTab:CreateToggle("Visualize Parry Range", function(s) VisualizeParry = s end)
    CombatTab:CreateSlider("Base Hit Distance", 10, 50, 15, function(v) BaseDistance = v end)
    CombatTab:CreateSlider("Prediction Offset (Reaction Time)", 1, 10, 5, function(v) PredictionMultiplier = v end)

    CombatTab:CreateToggle("Camera Look At Ball", function(s) CamLookAtBall = s end)
    CombatTab:CreateToggle("Character Look At Ball", function(s) CharLookAtBall = s end)
    CombatTab:CreateToggle("Spin Bot", function(s) SpinBotEnabled = s end)
    CombatTab:CreateSlider("Spin Speed", 10, 100, 50, function(v) SpinSpeed = v end)

    local LockedBall = nil

    local function GetActiveBall()
        if LockedBall and LockedBall.Parent then return LockedBall end
        local ballsFolder = workspace:FindFirstChild("Balls")
        if ballsFolder then
            for _, item in pairs(ballsFolder:GetDescendants()) do
                if item:IsA("BasePart") then
                    local r, g, b = math.floor((item.Color.R * 255)+0.5), math.floor((item.Color.G * 255)+0.5), math.floor((item.Color.B * 255)+0.5)
                    if r == 128 and g == 128 and b == 128 then
                        LockedBall = item
                        return LockedBall
                    end
                end
            end
        end
        return nil
    end

    local function IsTargetingMe()
        local ballsFolder = workspace:FindFirstChild("Balls")
        if ballsFolder then
            for _, item in pairs(ballsFolder:GetDescendants()) do
                if item:IsA("Highlight") then
                    local r, g, b = math.floor((item.FillColor.R * 255)+0.5), math.floor((item.FillColor.G * 255)+0.5), math.floor((item.FillColor.B * 255)+0.5)
                    if r == 255 and g == 30 and b == 30 then return true end
                end
            end
        end
        return false
    end

    local function Parry()
        task.spawn(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1) 
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1) 
        end)
    end

    local LastParryTime = 0

    RunService.RenderStepped:Connect(function()
        -- FPS HESAPLAYICI DÖNGÜSÜ
        frameCount = frameCount + 1
        local currentTime = tick()
        if currentTime - lastStatsUpdate >= 1 then
            local fps = math.floor(frameCount / (currentTime - lastStatsUpdate))
            local currentPing = 0
            pcall(function() currentPing = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
            
            -- Ping rengi ayarlama (100 üstü sarı, 200 üstü kırmızı)
            local pingColor = "<font color='#55FF55'>" .. currentPing .. "ms</font>"
            if currentPing > 100 then pingColor = "<font color='#FFFF55'>" .. currentPing .. "ms</font>" end
            if currentPing > 200 then pingColor = "<font color='#FF5555'>" .. currentPing .. "ms</font>" end
            
            StatsLabel.RichText = true
            StatsLabel.Text = string.format("FPS: %d | PING: %s", fps, pingColor)
            
            frameCount = 0
            lastStatsUpdate = currentTime
        end

        local Character = LocalPlayer.Character
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")
        
        if Root then
            local activeBall = GetActiveBall()
            local isTargetingMe = false

            if SpinBotEnabled then Root.CFrame = Root.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0) end

            if activeBall then
                isTargetingMe = IsTargetingMe()
                TargetLabel.Visible = isTargetingMe
                
                if CamLookAtBall and not SpinBotEnabled then Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, activeBall.Position) end
                if CharLookAtBall and not SpinBotEnabled then
                    local targetPos = Vector3.new(activeBall.Position.X, Root.Position.Y, activeBall.Position.Z)
                    Root.CFrame = CFrame.new(Root.Position, targetPos)
                end

                -- ==========================================
                -- ZEKİ HESAPLAMA (PING VE FİZİK UYARLAMASI)
                -- ==========================================
                local velocity = activeBall.AssemblyLinearVelocity.Magnitude
                
                -- Anlık pingi saniye cinsinden alıyoruz. (örn: 50ms = 0.05 sn)
                local pingSec = 0.1
                pcall(function() pingSec = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000 end)
                
                -- GERÇEK FİZİK: Mesafe = Hız * Zaman. Zaman = Ping + Gecikme Çarpanı.
                -- Topun sana ping yüzünden geç yansımasını engeller.
                local totalReactionTime = pingSec + (PredictionMultiplier / 20)
                local calculatedDistance = BaseDistance + (velocity * totalReactionTime)
                
                -- LİMİT KALDIRILDI! Sadece alt sınır var (BaseDistance'dan küçük olamaz).
                -- Top 1000 hızla gelirse küre devasa olacak ve daha top sana yaklaşamadan vuracak.
                local dynamicDistance = math.max(BaseDistance, calculatedDistance)

                if VisualizeParry then
                    VisualizerSphere.Transparency = 0.6
                    local targetSize = Vector3.new(dynamicDistance * 2, dynamicDistance * 2, dynamicDistance * 2)
                    VisualizerSphere.Size = VisualizerSphere.Size:Lerp(targetSize, 0.3)
                    VisualizerSphere.Position = Root.Position
                    VisualizerSphere.Color = isTargetingMe and Color3.fromRGB(255, 30, 30) or Color3.fromRGB(102, 85, 255)
                else
                    VisualizerSphere.Transparency = 1
                end

                if AutoParryEnabled and isTargetingMe then
                    local distance = (activeBall.Position - Root.Position).Magnitude
                    
                    -- Sınırsız çapa göre vur!
                    if distance <= dynamicDistance and (tick() - LastParryTime > 0.15) then
                        Parry()
                        LastParryTime = tick()
                        if VisualizeParry then VisualizerSphere.Transparency = 0.1 end
                    end
                end
            else
                TargetLabel.Visible = false
                if VisualizeParry then VisualizerSphere.Transparency = 1 end
            end
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
    local success = pcall(function() MacroUI.Parent = game:GetService("CoreGui") end)
    if not success then MacroUI.Parent = LocalPlayer:WaitForChild("PlayerGui") end

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
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                task.wait()
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end
            task.wait()
        end
    end)

    -- ==========================================
    -- 4. MISC (RGB & FUN) EKLENTİLERİ
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")
    
    local RGBBallEnabled = false
    local RGBCharEnabled, DiscoEnabled = false, false
    local RGBCharSpeed, OriginalColors = 2, {}
    local origAmb, origOut, origFog = Lighting.Ambient, Lighting.OutdoorAmbient, Lighting.FogColor

    MiscTab:CreateToggle("RGB Ball (Neon)", function(s) RGBBallEnabled = s end)
    
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
        if RGBBallEnabled and LockedBall and LockedBall.Parent then
            LockedBall.Material = Enum.Material.Neon
            LockedBall.Color = Color3.fromHSV((tick() * 2) % 1, 1, 1)
        end
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
        MacroUI:Destroy()
        TargetUI:Destroy()
        ScreenUI:Destroy()
        Lighting.Ambient = origAmb; Lighting.OutdoorAmbient = origOut; Lighting.FogColor = origFog
    end)
end

return GameModule
