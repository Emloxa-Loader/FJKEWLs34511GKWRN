-- =========================================================================
-- EMLOXA WARE: LUCKY BLOCKS BATTLEGROUNDS MAXIMUM POWER MODULE v4
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

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

    PlayerTab:CreateToggle("Fly Hack", function(state)
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
    -- 2. LUCKY BLOCKS SEKME SİSTEMİ
    -- ==========================================
    local LuckyTab = Window:CreateTab("Lucky Blocks")
    local Blocks = {{"Lucky Block", "SpawnLuckyBlock"}, {"Super Block", "SpawnSuperBlock"}, {"Diamond Block", "SpawnDiamondBlock"}, {"Rainbow Block", "SpawnRainbowBlock"}, {"Galaxy Block", "SpawnGalaxyBlock"}}
    local LoopConnections = {}

    for _, b in pairs(Blocks) do
        LuckyTab:CreateButton("Get " .. b[1], function() local r = ReplicatedStorage:FindFirstChild(b[2]); if r then r:FireServer() end end)
        LuckyTab:CreateToggle("Loop " .. b[1], function(state)
            if state then LoopConnections[b[1]] = RunService.RenderStepped:Connect(function() local r = ReplicatedStorage:FindFirstChild(b[2]); if r then r:FireServer() end end)
            else if LoopConnections[b[1]] then LoopConnections[b[1]]:Disconnect(); LoopConnections[b[1]] = nil end end
        end)
    end

    -- ==========================================
    -- 3. ULTRA HIZLI DUPE SİSTEMİ (YENİLENDİ)
    -- ==========================================
    local DupeTab = Window:CreateTab("Dupe Tool")
    local DupeTargetAmount = 10
    local DupeInProgress = false
    local DupeConnection = nil

    DupeTab:CreateSlider("Target Dupe Amount", 1, 100, 10, function(value) DupeTargetAmount = value end)

    DupeTab:CreateButton("Start Dupe (Held Item)", function()
        if DupeInProgress then return end
        local Character = LocalPlayer.Character
        if not Character then print("[EMLOXA WARE] Character not found"); return end
        local HeldTool = Character:FindFirstChildOfClass("Tool")
        if not HeldTool then print("[EMLOXA WARE] Error: Eline tool almalısın!"); return end
        local TargetItemName = HeldTool.Name
        DupeInProgress = true
        print("[EMLOXA WARE] Ultra Fast Dupe Started for: " .. TargetItemName)

        -- Karakteri sabitle
        local Humanoid = Character:FindFirstChild("Humanoid")
        if Humanoid then Humanoid.PlatformStand = true end

        task.spawn(function()
            local timeout = 0
            local lastOwned = 0
            local allBlockNames = {"SpawnLuckyBlock", "SpawnSuperBlock", "SpawnDiamondBlock", "SpawnRainbowBlock", "SpawnGalaxyBlock"}

            while DupeInProgress do
                -- Mevcut hedef eşya sayısını hesapla
                local totalOwned = 0
                for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if item:IsA("Tool") and item.Name == TargetItemName then totalOwned = totalOwned + 1 end
                end
                for _, item in pairs(Character:GetChildren()) do
                    if item:IsA("Tool") and item.Name == TargetItemName then totalOwned = totalOwned + 1 end
                end
                -- Workspace'teki araçları da kontrol et (düşmüş eşyalar)
                for _, item in pairs(workspace:GetChildren()) do
                    if item:IsA("Tool") and item.Name == TargetItemName then totalOwned = totalOwned + 1 end
                end

                if totalOwned >= DupeTargetAmount then
                    print("[EMLOXA WARE] Dupe completed! Target reached.")
                    break
                end

                -- Eğer sayı artıyorsa timeout'u sıfırla
                if totalOwned > lastOwned then
                    timeout = 0
                    lastOwned = totalOwned
                end

                if timeout > 600 then  -- 600 * ~0.03 saniye = yaklaşık 18 saniye
                    print("[EMLOXA WARE] Dupe stopped due to inactivity (timeout).")
                    break
                end

                -- Tüm blokları spawn et (her çevrimde hepsini gönder)
                for _, blockName in ipairs(allBlockNames) do
                    local remote = ReplicatedStorage:FindFirstChild(blockName)
                    if remote then remote:FireServer() end
                end

                -- Backpack'teki tüm araçları kontrol et: hedef eşyayı karaktere taşı, diğerlerini yok et
                for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if item:IsA("Tool") then
                        if item.Name == TargetItemName then
                            item.Parent = Character
                        else
                            item:Destroy()
                        end
                    end
                end

                -- Workspace'teki araçları topla: hedef eşyayı karaktere yaklaştır, diğerlerini yok et
                for _, item in pairs(workspace:GetChildren()) do
                    if item:IsA("Tool") and item:FindFirstChild("Handle") then
                        if item.Name == TargetItemName then
                            -- Eşyayı karakterin önüne getir (otomatik toplanması için)
                            local root = Character:FindFirstChild("HumanoidRootPart")
                            if root then
                                item.Handle.CFrame = root.CFrame * CFrame.new(0, 0, -3)
                            end
                        else
                            item:Destroy()
                        end
                    end
                end

                timeout = timeout + 1
                task.wait() -- Maksimum hız
            end

            -- Temizlik
            DupeInProgress = false
            if Humanoid then Humanoid.PlatformStand = false end
            print("[EMLOXA WARE] Dupe process finished.")
        end)
    end)

    DupeTab:CreateButton("Stop Dupe Process", function()
        DupeInProgress = false
        local Character = LocalPlayer.Character
        if Character then
            local Humanoid = Character:FindFirstChild("Humanoid")
            if Humanoid then Humanoid.PlatformStand = false end
        end
        print("[EMLOXA WARE] Dupe stopped by user.")
    end)

    -- ==========================================
    -- 4. KILLER SİSTEMİ
    -- ==========================================
    local KillerTab = Window:CreateTab("Killer")
    local KillerEnabled, IgnoreFriends = false, true
    local KillerConnection = nil

    KillerTab:CreateToggle("Ignore Friends", function(s) IgnoreFriends = s end)
    KillerTab:CreateToggle("Enable Killer (Bring All)", function(state)
        KillerEnabled = state
        if KillerEnabled then
            KillerConnection = RunService.Heartbeat:Connect(function()
                local MyChar = LocalPlayer.Character
                local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
                if MyRoot then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                            if IgnoreFriends and player:IsFriendsWith(LocalPlayer.UserId) then continue end
                            player.Character.HumanoidRootPart.CFrame = MyRoot.CFrame * CFrame.new(0, 0, -3.5)
                        end
                    end
                end
            end)
        else
            if KillerConnection then KillerConnection:Disconnect(); KillerConnection = nil end
        end
    end)

    -- ==========================================
    -- 5. CRASH SİSTEMİ (YENİ)
    -- ==========================================
    local CrashTab = Window:CreateTab("Crash")
    local CrashRunning = false
    local CrashConnection = nil

    CrashTab:CreateButton("Crash Server", function()
        if CrashRunning then return end
        CrashRunning = true
        print("[EMLOXA WARE] Starting crash sequence...")

        task.spawn(function()
            -- 1. Aşırı yük: 2000 adet blok spawn isteği gönder
           local lplr = game.Players.LocalPlayer

-- Başlangıç değerleri
local da = #lplr.Character:GetChildren()
local skok = 0
local daskok = 30

-- 1. Sunucuya çok sayıda blok spawn isteği gönder (sunucuyu yavaşlatmak için)
for i = 1, 1000 do
    game.ReplicatedStorage.SpawnRainbowBlock:FireServer()
    game.ReplicatedStorage.SpawnDiamondBlock:FireServer()
    game.ReplicatedStorage.SpawnSuperBlock:FireServer()
    game.ReplicatedStorage.SpawnLuckyBlock:FireServer()
    game.ReplicatedStorage.SpawnGalaxyBlock:FireServer()
end

-- 2. Hedef sayıda IvoryPeriastron toplanana kadar bekle
while wait(0.1) and #lplr.Character:GetChildren() - da < daskok do
    for i, v in pairs(lplr.Backpack:GetChildren()) do
        if v.Name == 'IvoryPeriastron' then
            v.Parent = lplr.Character
            skok = #lplr.Character:GetChildren() - da
            print('Yükleniyor ('..skok..'/'..daskok..')')
        end
    end
end

-- 3. Kısa bekleme
wait(1)
print('Done! bye bye server')

-- 4. Tüm IvoryPeriastron'ları aynı anda patlat
for i, v in pairs(lplr.Character:GetChildren()) do
    if v.Name == 'IvoryPeriastron' then
        v.Remote:FireServer(Enum.KeyCode.Q)
    end
end

            CrashRunning = false
            print("[EMLOXA WARE] Crash sequence finished.")
        end)
    end)

    CrashTab:CreateButton("Stop Crash", function()
        CrashRunning = false
        print("[EMLOXA WARE] Crash stopped.")
    end)

    CrashTab:CreateLabel("Warning: Using this may get your account banned!")
    CrashTab:CreateLabel("Use at your own risk.")

end

return GameModule
