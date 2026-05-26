-- =========================================================================
-- EMLOXA WARE: BLADE BALL MAXIMUM PERFORMANCE MODULE v5 (ULTIMATE TARGETING)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local Stats = game:GetService("Stats")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer

    -- ==========================================
    -- 0. HEDEF BELİRLEYİCİ ARAYÜZ (TARGET UI)
    -- ==========================================
    local TargetUI = Instance.new("ScreenGui")
    TargetUI.Name = "EmloxaTargetUI"
    local success = pcall(function() TargetUI.Parent = game:GetService("CoreGui") end)
    if not success then TargetUI.Parent = LocalPlayer:WaitForChild("PlayerGui") end

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
    TargetLabel.Parent = TargetUI
    Instance.new("UIStroke", TargetLabel).Color = Color3.fromRGB(0, 0, 0)
    Instance.new("UIStroke", TargetLabel).Thickness = 2

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
    -- 2. BLADE BALL: KUSURSUZ AUTO PARRY & VISUALIZER
    -- ==========================================
    local CombatTab = Window:CreateTab("Combat (Blade Ball)")
    
    local AutoParryEnabled, CamLookAtBall, CharLookAtBall = false, false, false
    local SpinBotEnabled, VisualizeParry = false, false
    local SpinSpeed = 50
    local BaseDistance = 15
    local VelocityMultiplier = 5

    -- Savunma Yarıçapını Gösteren Şeffaf Küre
    local VisualizerSphere = Instance.new("Part")
    VisualizerSphere.Shape = Enum.PartType.Ball
    VisualizerSphere.Material = Enum.Material.ForceField
    VisualizerSphere.Color = Color3.fromRGB(102, 85, 255)
    VisualizerSphere.Transparency = 1
    VisualizerSphere.Anchored = true
    VisualizerSphere.CanCollide = false
    VisualizerSphere.CastShadow = false
    VisualizerSphere.Parent = workspace

    CombatTab:CreateToggle("Auto Parry (Ultimate Target Lock)", function(s) AutoParryEnabled = s end)
    CombatTab:CreateToggle("Visualize Parry Range", function(s) VisualizeParry = s end)
    CombatTab:CreateSlider("Base Hit Distance", 10, 50, 15, function(v) BaseDistance = v end)
    CombatTab:CreateSlider("Velocity Sensitivity", 1, 10, 5, function(v) VelocityMultiplier = v end)

    CombatTab:CreateToggle("Camera Look At Ball", function(s) CamLookAtBall = s end)
    CombatTab:CreateToggle("Character Look At Ball", function(s) CharLookAtBall = s end)
    CombatTab:CreateToggle("Spin Bot", function(s) SpinBotEnabled = s end)
    CombatTab:CreateSlider("Spin Speed", 10, 100, 50, function(v) SpinSpeed = v end)


    -- ==========================================
    -- TOP HEDEFLEME MANTIĞI (SENİN ANALİZİNE GÖRE)
    -- ==========================================
    local LockedBall = nil

    local function GetActiveBall()
        -- 1. Top zaten bulunmuşsa ve haritada var olmaya devam ediyorsa ona odaklanmaya devam et.
        if LockedBall and LockedBall.Parent then
            return LockedBall
        end

        -- 2. Top yok olduysa (patladıysa), yeni topu aramaya başla.
        local ballsFolder = workspace:FindFirstChild("Balls")
        if ballsFolder then
            for _, item in pairs(ballsFolder:GetDescendants()) do
                if item:IsA("BasePart") then
                    local r = math.floor((item.Color.R * 255) + 0.5)
                    local g = math.floor((item.Color.G * 255) + 0.5)
                    local b = math.floor((item.Color.B * 255) + 0.5)
                    
                    -- SENİN FORMÜLÜN: Gerçek topun rengi 128, 128, 128 (Gri)
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
            -- Bazen Highlight partın içinde, bazen direkt klasörde olabilir, hepsini tarıyoruz.
            for _, item in pairs(ballsFolder:GetDescendants()) do
                if item:IsA("Highlight") then
                    local r = math.floor((item.FillColor.R * 255) + 0.5)
                    local g = math.floor((item.FillColor.G * 255) + 0.5)
                    local b = math.floor((item.FillColor.B * 255) + 0.5)
                    
                    -- SENİN FORMÜLÜN: Eğer Highlight kırmızı (255, 30, 30) ise HEDEF BİZİZ!
                    if r == 255 and g == 30 and b == 30 then
                        return true
                    end
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
        local Character = LocalPlayer.Character
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")
        
        if Root then
            local activeBall = GetActiveBall()
            local isTargetingMe = false

            if SpinBotEnabled then
                Root.CFrame = Root.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
            end

            if activeBall then
                isTargetingMe = IsTargetingMe()
                
                -- Hedef Yazısı (Kırmızı Yanıp Sönme Efektli)
                TargetLabel.Visible = isTargetingMe
                
                if CamLookAtBall and not SpinBotEnabled then Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, activeBall.Position) end
                if CharLookAtBall and not SpinBotEnabled then
                    local targetPos = Vector3.new(activeBall.Position.X, Root.Position.Y, activeBall.Position.Z)
                    Root.CFrame = CFrame.new(Root.Position, targetPos)
                end

                -- GÖRSELLEŞTİRİCİ MATEMATİĞİ (Çap Hesaplama)
                local velocity = activeBall.AssemblyLinearVelocity.Magnitude
                
                -- Hız ne kadar yüksekse çap o kadar mantıklı artar
                local dynamicDistance = BaseDistance + (velocity * (VelocityMultiplier / 15))
                dynamicDistance = math.clamp(dynamicDistance, BaseDistance, 150) -- Çapın max sınırını belirle

                if VisualizeParry then
                    VisualizerSphere.Transparency = 0.6
                    -- LERP SİSTEMİ: Küre boyutu bir anda patlamaz, pürüzsüzce büyür ve küçülür
                    local targetSize = Vector3.new(dynamicDistance * 2, dynamicDistance * 2, dynamicDistance * 2)
                    VisualizerSphere.Size = VisualizerSphere.Size:Lerp(targetSize, 0.2)
                    VisualizerSphere.Position = Root.Position
                    VisualizerSphere.Color = isTargetingMe and Color3.fromRGB(255, 30, 30) or Color3.fromRGB(102, 85, 255)
                else
                    VisualizerSphere.Transparency = 1
                end

                -- VURUŞ TETİKLEYİCİSİ
                if AutoParryEnabled and isTargetingMe then
                    local distance = (activeBall.Position - Root.Position).Magnitude
                    
                    -- Top kürenin içine girdiği an ve son basıştan 0.15 sn geçtiyse vur
                    if distance <= dynamicDistance and (tick() - LastParryTime > 0.15) then
                        Parry()
                        LastParryTime = tick()
                        -- Vuruş anında görsel küre parlasın
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

    local MiscTab = Window:CreateTab("Misc")
    MiscTab:CreateButton("Unload EMLOXA WARE", function()
        AutoParryEnabled = false; CamLookAtBall = false; CharLookAtBall = false
        SpinBotEnabled = false; MacroMasterToggle = false; IsMacroActive = false
        VisualizerSphere:Destroy()
        MacroUI:Destroy()
        TargetUI:Destroy()
    end)
end

return GameModule
