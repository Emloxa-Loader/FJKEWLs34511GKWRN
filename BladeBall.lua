-- =========================================================================
-- EMLOXA WARE: BLADE BALL MAXIMUM PERFORMANCE MODULE
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer

    -- ==========================================
    -- 1. LOCAL PLAYER SEKME SİSTEMİ
    -- ==========================================
    local PlayerTab = Window:CreateTab("Local Player")
    local NoclipEnabled, FlyEnabled = false, false
    local FlySpeed, CurrentSpeed, CurrentJump = 50, 16, 50

    PlayerTab:CreateToggle("Noclip (Pass Through Walls)", function(state) NoclipEnabled = state end)
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
        local Character = LocalPlayer.Character
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")
        local Humanoid = Character and Character:FindFirstChild("Humanoid")
        if not Root or not Humanoid then return end
        
        if FlyEnabled then
            Humanoid.PlatformStand = true
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
            Humanoid.PlatformStand = false
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
    -- 2. BLADE BALL: COMBAT & AUTO PARRY
    -- ==========================================
    local CombatTab = Window:CreateTab("Combat (Blade Ball)")
    
    local AutoParryEnabled = false
    local LookAtBallEnabled = false
    local SpinBotEnabled = false
    local SpinSpeed = 50
    local DistanceThreshold = 25 -- Varsayılan vuruş mesafesi
    local TimingOffset = 0.5 -- Topun hızına göre erken basma payı

    CombatTab:CreateToggle("Auto Parry (Smart Block)", function(state) AutoParryEnabled = state end)
    CombatTab:CreateSlider("Parry Distance Tolerance", 10, 100, 25, function(v) DistanceThreshold = v end)
    CombatTab:CreateSlider("Ping/Timing Offset (ms)", 1, 10, 5, function(v) TimingOffset = v / 10 end)

    CombatTab:CreateToggle("Look At Active Ball", function(state) LookAtBallEnabled = state end)
    
    CombatTab:CreateToggle("Spin Bot", function(state) SpinBotEnabled = state end)
    CombatTab:CreateSlider("Spin Speed", 10, 100, 50, function(v) SpinSpeed = v end)

    -- Topu Bulma Fonksiyonu
    local function GetActiveBall()
        local ballsFolder = workspace:FindFirstChild("Balls")
        if ballsFolder then
            for _, item in pairs(ballsFolder:GetChildren()) do
                if item:IsA("BasePart") and item:FindFirstChildOfClass("Highlight") then
                    return item
                end
            end
        end
        return nil
    end

    -- Topun Rengini (Bize Gelip Gelmediğini) Kontrol Etme
    local function IsBallTargetingUs(ball)
        local highlight = ball:FindFirstChildOfClass("Highlight")
        if highlight then
            -- Rengi 255,255,255 (Beyaz) değilse top bize veya başkasına odaklanmış demektir.
            -- Blade Ball'da top bize dönünce kırmızı olur.
            local r, g, b = highlight.FillColor.R, highlight.FillColor.G, highlight.FillColor.B
            if r ~= 1 or g ~= 1 or b ~= 1 then -- 1,1,1 beyaz demektir
                return true
            end
        end
        return false
    end

    -- F Tuşuna Basma Simülatörü
    local function Parry()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end

    -- Combat Ana Döngüsü
    RunService.RenderStepped:Connect(function()
        local Character = LocalPlayer.Character
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")
        
        if Root then
            local activeBall = GetActiveBall()
            
            -- Spin Bot
            if SpinBotEnabled then
                Root.CFrame = Root.CFrame * CFrame.Angles(0, math.rad(SpinSpeed), 0)
            end

            if activeBall then
                -- Look At Ball
                if LookAtBallEnabled and not SpinBotEnabled then
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, activeBall.Position)
                end

                -- Dinamik Auto Parry Mantığı
                if AutoParryEnabled and IsBallTargetingUs(activeBall) then
                    local distance = (activeBall.Position - Root.Position).Magnitude
                    local velocity = activeBall.AssemblyLinearVelocity.Magnitude
                    
                    -- Zaman ve Mesafe Formülü: Top ne kadar hızlıysa, o kadar uzaktan basmalıdır!
                    local dynamicDistance = DistanceThreshold + (velocity * TimingOffset)
                    
                    if distance <= dynamicDistance then
                        Parry()
                    end
                end
            end
        end
    end)


    -- ==========================================
    -- 3. MACRO SİSTEMİ (Ekranda UI Göstergeli)
    -- ==========================================
    local MacroTab = Window:CreateTab("Macro (F Spammer)")
    
    local MacroMasterToggle = false
    local IsMacroActive = false

    -- Ekranda Gözükecek Macro UI'ı (Sadece bu oyuna özel)
    local MacroUI = Instance.new("ScreenGui")
    MacroUI.Name = "EmloxaMacroUI"
    local success = pcall(function() MacroUI.Parent = game:GetService("CoreGui") end)
    if not success then MacroUI.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local MacroLabel = Instance.new("TextLabel")
    MacroLabel.Size = UDim2.new(0, 200, 0, 40)
    MacroLabel.Position = UDim2.new(0.5, -100, 1, -150) -- Alt Orta
    MacroLabel.BackgroundTransparency = 1
    MacroLabel.Font = Enum.Font.GothamBold
    MacroLabel.TextSize = 20
    MacroLabel.Text = "MACRO: OFF"
    MacroLabel.TextColor3 = Color3.fromRGB(255, 50, 50) -- Kırmızı
    MacroLabel.Visible = false
    MacroLabel.Parent = MacroUI
    Instance.new("UIStroke", MacroLabel).Color = Color3.fromRGB(0, 0, 0)

    MacroTab:CreateToggle("Enable Macro System (Key: E)", function(state)
        MacroMasterToggle = state
        MacroLabel.Visible = state
        if not state then
            IsMacroActive = false
            MacroLabel.Text = "MACRO: OFF"
            MacroLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    end)

    -- E Tuşu Algılayıcı (Macro Aç/Kapat)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.E and MacroMasterToggle then
            IsMacroActive = not IsMacroActive
            
            if IsMacroActive then
                MacroLabel.Text = "MACRO: ON (Spamming F)"
                MacroLabel.TextColor3 = Color3.fromRGB(50, 255, 50) -- Yeşil
            else
                MacroLabel.Text = "MACRO: OFF"
                MacroLabel.TextColor3 = Color3.fromRGB(255, 50, 50) -- Kırmızı
            end
        end
    end)

    -- Macro F Spammer Döngüsü (Oyun motorunun max hızında çalışır)
    task.spawn(function()
        while true do
            if MacroMasterToggle and IsMacroActive then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                task.wait() -- Hız sınırı yok, oyunu çökertecek kadar değil ama en hızlı
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end
            task.wait()
        end
    end)

    -- Menü kapanınca Macro UI'ını da temizlemek için
    local MiscTab = Window:CreateTab("Misc")
    MiscTab:CreateButton("Unload EMLOXA WARE", function()
        AutoParryEnabled = false
        LookAtBallEnabled = false
        SpinBotEnabled = false
        MacroMasterToggle = false
        IsMacroActive = false
        MacroUI:Destroy()
        -- Universal unload işlemlerine dahil olması için buraya eklendi.
    end)
end

return GameModule
