-- =========================================================================
-- EMLOXA WARE: LUCKY BLOCKS BATTLEGROUNDS MAXIMUM POWER MODULE
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- =========================================================================
    -- 1. DETAYLI LOCAL PLAYER SEKME SİSTEMİ (Fly, Noclip, Speed, Jump)
    -- =========================================================================
    local PlayerTab = Window:CreateTab("Local Player")
    
    local NoclipEnabled = false
    local FlyEnabled = false
    local FlySpeed = 50
    local CurrentSpeed = 16
    local CurrentJump = 50

    PlayerTab:CreateToggle("Noclip (Pass Through Walls)", function(state)
        NoclipEnabled = state
    end)

    PlayerTab:CreateSlider("WalkSpeed Force", 16, 250, 16, function(value)
        CurrentSpeed = value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end)

    PlayerTab:CreateSlider("JumpPower Force", 50, 350, 50, function(value)
        CurrentJump = value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.UseJumpPower = true
            LocalPlayer.Character.Humanoid.JumpPower = value
        end
    end)

    -- Ultra Smooth Fly Sistemi
    PlayerTab:CreateToggle("Fly Hack", function(state)
        FlyEnabled = state
        local Character = LocalPlayer.Character
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")
        local Humanoid = Character and Character:FindFirstChild("Humanoid")
        
        if not Root or not Humanoid then return end
        
        if FlyEnabled then
            Humanoid.PlatformStand = true
            local BodyVelocity = Instance.new("BodyVelocity")
            BodyVelocity.Name = "EmloxaFly"
            BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            BodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
            BodyVelocity.Parent = Root
            
            task.spawn(function()
                while FlyEnabled and Root and BodyVelocity.Parent do
                    local direction = Vector3.new(0, 0, 0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end
                    
                    BodyVelocity.Velocity = direction.Unit * FlySpeed
                    if direction == Vector3.new(0, 0, 0) then BodyVelocity.Velocity = Vector3.new(0, 0.1, 0) end
                    task.wait()
                end
            end)
        else
            Humanoid.PlatformStand = false
            local bv = Root:FindFirstChild("EmloxaFly")
            if bv then bv:Destroy() end
        end
    end)

    PlayerTab:CreateSlider("Fly Speed", 20, 200, 50, function(value)
        FlySpeed = value
    end)

    -- Karakter Döngü Kontrolleri (Respawndan sonra silinmesin diye)
    RunService.Stepped:Connect(function()
        local Character = LocalPlayer.Character
        if Character then
            -- Noclip Uygulama
            if NoclipEnabled then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                end
            end
            -- Speed & Jump Sabitleyici Koruma
            local Hum = Character:FindFirstChild("Humanoid")
            if Hum and not FlyEnabled then
                Hum.WalkSpeed = CurrentSpeed
                Hum.UseJumpPower = true
                Hum.JumpPower = CurrentJump
            end
        end
    end)


    -- =========================================================================
    -- 2. LUCKY BLOCKS TEKLI / LOOP ALIM SEKME SİSTEMİ
    -- =========================================================================
    local LuckyTab = Window:CreateTab("Lucky Blocks")
    
    local Blocks = {
        {Name = "Lucky Block", Remote = "SpawnLuckyBlock"},
        {Name = "Super Block", Remote = "SpawnSuperBlock"},
        {Name = "Diamond Block", Remote = "SpawnDiamondBlock"},
        {Name = "Rainbow Block", Remote = "SpawnRainbowBlock"},
        {Name = "Galaxy Block", Remote = "SpawnGalaxyBlock"}
    }
    local LoopConnections = {}

    for _, blockData in pairs(Blocks) do
        LuckyTab:CreateButton("Get " .. blockData.Name, function()
            local remote = ReplicatedStorage:FindFirstChild(blockData.Remote)
            if remote then remote:FireServer() end
        end)

        LuckyTab:CreateToggle("Loop " .. blockData.Name, function(state)
            if state then
                LoopConnections[blockData.Name] = RunService.RenderStepped:Connect(function()
                    local remote = ReplicatedStorage:FindFirstChild(blockData.Remote)
                    if remote then remote:FireServer() end
                end)
            else
                if LoopConnections[blockData.Name] then
                    LoopConnections[blockData.Name]:Disconnect()
                    LoopConnections[blockData.Name] = nil
                end
            end
        end)
    end


    -- =========================================================================
    -- 3. %100 FİLTRELİ KUSURSUZ DUPE SİSTEMİ (Eşya Kaybı Engellendi)
    -- =========================================================================
    local DupeTab = Window:CreateTab("Dupe Tool")
    
    local DupeTargetAmount = 10
    local DupeInProgress = false

    DupeTab:CreateSlider("Target Dupe Amount", 1, 100, 10, function(value)
        DupeTargetAmount = value
    end)

    DupeTab:CreateButton("Start Dupe (Held Item)", function()
        if DupeInProgress then return end
        
        local Character = LocalPlayer.Character
        local Humanoid = Character and Character:FindFirstChild("Humanoid")
        local HeldTool = Character and Character:FindFirstChildOfClass("Tool")
        
        if not HeldTool then
            print("[EMLOXA WARE] Dupe Error: You must hold the tool in your hand first!")
            return
        end

        local TargetItemName = HeldTool.Name
        DupeInProgress = true
        print("[EMLOXA WARE] Dupe Triggered for: " .. TargetItemName)

        task.spawn(function()
            local timeoutCounter = 0
            local maxTimeout = 150 -- 15 Saniye limit

            while DupeInProgress and timeoutCounter < maxTimeout do
                -- Toplam sayıyı dinamik hesapla (Çanta + Elimizdeki)
                local totalOwned = 0
                for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if item.Name == TargetItemName then totalOwned = totalOwned + 1 end
                end
                if Character:FindFirstChild(TargetItemName) then totalOwned = totalOwned + 1 end

                -- Hedefe ulaştıysak döngüden çık
                if totalOwned >= DupeTargetAmount then break end

                -- Blok düşür
                local galaxyRemote = ReplicatedStorage:FindFirstChild("SpawnGalaxyBlock")
                if galaxyRemote then galaxyRemote:FireServer() end

                -- AKILLI FİLTRELEME: Çantadaki Alakasız Eşyaları Temizle (Kopyalanacak Eşyaya Asla Dokunmaz)
                for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if item:IsA("Tool") then
                        if item.Name == TargetItemName then
                            Humanoid:EquipTool(item) -- Koruma altına al ve eline zorla ver
                        else
                            item:Destroy() -- Tamamen farklı çöp eşyaları sil
                        end
                    end
                end

                -- Yerdeki Doğru Eşyaları Çekme Akımı
                for _, item in pairs(workspace:GetChildren()) do
                    if item:IsA("Tool") and item:FindFirstChild("Handle") then
                        if item.Name == TargetItemName then
                            item.Handle.CFrame = Character.HumanoidRootPart.CFrame -- Direkt üstümüze çek
                        else
                            -- Bizim atmadığımız veya başkasının olan çöpleri temizle lagı engelle
                            item:Destroy()
                        end
                    end
                end

                timeoutCounter = timeoutCounter + 1
                task.wait(0.1)
            end

            DupeInProgress = false
            print("[EMLOXA WARE] Dupe Cycle Finished Safely.")
        end)
    end)
    
    DupeTab:CreateButton("Stop Dupe Process", function()
        DupeInProgress = false
    end)


    -- =========================================================================
    -- 4. KILLER (PLAYER BRING) SİSTEMİ (Arkadaş Filtreli & Yüzü Dönük)
    -- =========================================================================
    local KillerTab = Window:CreateTab("Killer")
    
    local KillerEnabled = false
    local IgnoreFriends = true
    local KillerConnection = nil

    KillerTab:CreateToggle("Ignore Friends", function(state)
        IgnoreFriends = state
    end)

    KillerTab:CreateToggle("Enable Killer (Bring All)", function(state)
        KillerEnabled = state
        
        if KillerEnabled then
            KillerConnection = RunService.Heartbeat:Connect(function()
                local MyChar = LocalPlayer.Character
                local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
                
                if MyRoot then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                            
                            -- Arkadaşlık Kontrolü
                            if IgnoreFriends and player:IsFriendsWith(LocalPlayer.UserId) then
                                continue 
                            end
                            
                            -- Kusursuz CFrame Kilitlemesi (Karşı karşıya getirme formülü)
                            local EnemyRoot = player.Character.HumanoidRootPart
                            EnemyRoot.CFrame = MyRoot.CFrame * CFrame.new(0, 0, -3.5) * CFrame.Angles(0, math.pi, 0)
                        end
                    end
                end
            end)
        else
            if KillerConnection then
                KillerConnection:Disconnect()
                KillerConnection = nil
            end
        end
    end)
end

return GameModule
