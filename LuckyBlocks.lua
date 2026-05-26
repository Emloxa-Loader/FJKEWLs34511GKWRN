-- ==========================================
-- EMLOXA WARE: LUCKY BLOCKS BATTLEGROUNDS MODULE
-- ==========================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    -- 1. LUCKY BLOCKS SEKME SİSTEMİ
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
        -- Tekli Alım Butonu
        LuckyTab:CreateButton("Get " .. blockData.Name, function()
            local remote = ReplicatedStorage:FindFirstChild(blockData.Remote)
            if remote then remote:FireServer() end
        end)

        -- Otomatik (Loop) Alım
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

    -- 2. GELİŞMİŞ DUPE (KOPYALAMA) SİSTEMİ
    local DupeTab = Window:CreateTab("Dupe Tool")
    
    local DupeTargetAmount = 10
    local DupeInProgress = false

    DupeTab:CreateSlider("Target Dupe Amount", 1, 100, 10, function(value)
        DupeTargetAmount = value
    end)

    DupeTab:CreateButton("Start Dupe (Held Item)", function()
        if DupeInProgress then return end -- Zaten çalışıyorsa engelle
        
        local Character = LocalPlayer.Character
        local Humanoid = Character and Character:FindFirstChild("Humanoid")
        local HeldTool = Character and Character:FindFirstChildOfClass("Tool")
        
        if not HeldTool then
            print("[EMLOXA WARE] Dupe Error: Eline kopyalamak istediğin eşyayı almalısın!")
            return
        end

        local TargetItemName = HeldTool.Name
        DupeInProgress = true
        print("[EMLOXA WARE] Dupe Başladı. Hedef Eşya: " .. TargetItemName)

        -- Dupe Döngüsü
        task.spawn(function()
            local currentDupeCount = 1 -- Zaten elimizde 1 tane var
            local timeoutCounter = 0
            local maxTimeout = 200 -- Yaklaşık 20 saniye (task.wait(0.1) * 200)

            while DupeInProgress and currentDupeCount < DupeTargetAmount and timeoutCounter < maxTimeout do
                -- Galaxy Block Spawnla (En iyi eşyalar için)
                local galaxyRemote = ReplicatedStorage:FindFirstChild("SpawnGalaxyBlock")
                if galaxyRemote then galaxyRemote:FireServer() end

                -- Envanteri ve Yerdeki (Workspace) Eşyaları Kontrol Et
                -- 1. Backpack (Çanta) Kontrolü
                for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if item:IsA("Tool") then
                        if item.Name == TargetItemName then
                            currentDupeCount = currentDupeCount + 1
                            Humanoid:EquipTool(item) -- Zorla Eline Ver
                        else
                            item:Destroy() -- İstenmeyen eşyayı sil
                        end
                    end
                end

                -- 2. Yerdeki (Workspace) Düşen Eşyaları Kontrol Et
                for _, item in pairs(workspace:GetChildren()) do
                    if item:IsA("Tool") and item:FindFirstChild("Handle") then
                        if item.Name == TargetItemName then
                            -- Karakterin üstüne ışınla ki hemen alsın
                            item.Handle.CFrame = Character.HumanoidRootPart.CFrame
                        else
                            item:Destroy() -- Yerdeki gereksiz çöpü sil
                        end
                    end
                end

                timeoutCounter = timeoutCounter + 1
                task.wait(0.1)
            end

            DupeInProgress = false
            if timeoutCounter >= maxTimeout then
                print("[EMLOXA WARE] Dupe Durduruldu: Timeout (Zaman Aşımı)!")
            else
                print("[EMLOXA WARE] Dupe Başarılı: " .. currentDupeCount .. " adet toplandı!")
            end
        end)
    end)
    
    DupeTab:CreateButton("Stop Dupe", function()
        DupeInProgress = false
    end)

    -- 3. KILLER (BRING PLAYERS) SİSTEMİ
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
            -- Döngüyü Heartbeat ile yapıyoruz ki oyuncular pürüzsüz gelsin, titremesin.
            KillerConnection = RunService.Heartbeat:Connect(function()
                local MyChar = LocalPlayer.Character
                local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
                
                if MyRoot then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                            
                            -- Arkadaş Kontrolü
                            if IgnoreFriends and player:IsFriendsWith(LocalPlayer.UserId) then
                                continue -- Arkadaşsa atla, bir sonraki oyuncuya geç
                            end
                            
                            -- Karakteri tam olarak bizim karakterimizin "Önüne" (-3 Z ekseni) getir.
                            local EnemyRoot = player.Character.HumanoidRootPart
                            EnemyRoot.CFrame = MyRoot.CFrame * CFrame.new(0, 0, -3)
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
