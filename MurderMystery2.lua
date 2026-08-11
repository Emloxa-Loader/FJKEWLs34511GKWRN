-- =========================================================================
-- EMLOXA WARE: MURDER MYSTERY 2
-- ULTIMATE STEALTH & COMBAT ENGINE (DYNAMIC MAP & ROLE DETECTION)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local VirtualUser = game:GetService("VirtualUser")
    local LocalPlayer = Players.LocalPlayer

    -- ==========================================
    -- 1. DİNAMİK ALTYAPI & YARDIMCI FONKSİYONLAR
    -- ==========================================
    local function GetNil(Name, DebugId)
        if getnilinstances then
            for _, Object in pairs(getnilinstances()) do
                if Object.Name == Name and Object:GetDebugId() == DebugId then
                    return Object
                end
            end
        end
        return nil
    end

    -- Dinamik Harita Bulucu (İsmi ne olursa olsun haritayı bulur)
    local function GetMap()
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Model") and v.Name ~= "Lobby" and (v:FindFirstChild("CoinContainer") or v:FindFirstChild("Spawns")) then
                return v
            end
        end
        return nil
    end

    -- Rol Bulucular
    local function GetMurderer()
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Knife") or p.Backpack and p.Backpack:FindFirstChild("Knife") then
                return p
            end
        end
        return nil
    end

    local function GetSheriff()
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Gun") or p.Backpack and p.Backpack:FindFirstChild("Gun") then
                return p
            end
        end
        return nil
    end

    -- Fling (Fırlatma) Motoru
    local function FlingTarget(TargetPlayer)
        local Char = LocalPlayer.Character
        if not Char or not Char:FindFirstChild("HumanoidRootPart") or not TargetPlayer.Character or not TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        
        local hrp = Char.HumanoidRootPart
        local bg = Instance.new("BodyAngularVelocity", hrp)
        bg.AngularVelocity = Vector3.new(99999, 99999, 99999)
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 9000
        
        local startTime = tick()
        while tick() - startTime < 0.5 do
            RunService.Heartbeat:Wait()
            if TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                hrp.CFrame = TargetPlayer.Character.HumanoidRootPart.CFrame
            end
        end
        bg:Destroy()
    end

    -- ==========================================
    -- 2. TABS & DEĞİŞKENLER
    -- ==========================================
    local FarmTab = Window:CreateTab("Auto Farm")
    local CombatTab = Window:CreateTab("Combat (Roles)")
    local ESPTab = Window:CreateTab("Visuals & ESP")
    local TeleportTab = Window:CreateTab("Teleports")
    local LocalTab = Window:CreateTab("Local Player")

    local FarmEnabled = false
    local FarmMode = "Legit" -- Legit (Tween) veya Rage (Instant)
    local FarmSpeed = 1.5

    local FakeDeathEnabled = false
    local AutoGetGun = false
    
    local NoclipActive = false

    -- ==========================================
    -- 3. AUTO FARM (COINS)
    -- ==========================================
    FarmTab:CreateDropdown("Coin Farm Mode", {"Legit", "Rage"}, "Legit", function(val)
        FarmMode = val
    end)

    FarmTab:CreateSlider("Legit Tween Speed", 1, 5, 2, function(val)
        FarmSpeed = val
    end)

    FarmTab:CreateToggle("Enable Coin Farm", function(state)
        FarmEnabled = state
        if FarmEnabled then
            task.spawn(function()
                while FarmEnabled do
                    task.wait(0.1)
                    local Map = GetMap()
                    if Map and Map:FindFirstChild("CoinContainer") and Map.CoinContainer:FindFirstChild("Coin_Server") then
                        for _, coin in pairs(Map.CoinContainer.Coin_Server:GetChildren()) do
                            if not FarmEnabled then break end
                            if coin.Name == "CoinVisual" and coin.Transparency == 0 then
                                local Char = LocalPlayer.Character
                                if Char and Char:FindFirstChild("HumanoidRootPart") then
                                    -- Haritanın altından (gizli) yaklaşır
                                    local targetCFrame = coin.CFrame * CFrame.new(0, -3.5, 0)
                                    
                                    -- Yere düşmemesi için platform oluştur
                                    local plat = Instance.new("Part", workspace)
                                    plat.Size = Vector3.new(5, 1, 5)
                                    plat.Anchored = true
                                    plat.Transparency = 1
                                    plat.CFrame = targetCFrame * CFrame.new(0, -3, 0)

                                    if FarmMode == "Legit" then
                                        local dist = (Char.HumanoidRootPart.Position - targetCFrame.Position).Magnitude
                                        local tweenTime = math.clamp(dist / (FarmSpeed * 50), 0.5, 3)
                                        local tween = TweenService:Create(Char.HumanoidRootPart, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
                                        tween:Play()
                                        tween.Completed:Wait()
                                    else
                                        -- Rage Modu (Anında TP ama anti-cheat için küçük bekleme)
                                        Char.HumanoidRootPart.CFrame = targetCFrame
                                        task.wait(0.3) 
                                    end
                                    
                                    task.wait(0.1)
                                    plat:Destroy()
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)

    -- ==========================================
    -- 4. COMBAT (MURDERER & SHERIFF)
    -- ==========================================
    local function AttackFallback()
        -- Cobalt kodu çalışmazsa fare ile garanti tıklar
        if mouse1click then mouse1click() end
        VirtualUser:ClickButton1(Vector2.new())
    end

    CombatTab:CreateButton("🔪 Kill All (Murderer - Knife)", function()
        local Char = LocalPlayer.Character
        local Knife = LocalPlayer.Backpack:FindFirstChild("Knife") or Char:FindFirstChild("Knife")
        if not Knife then return end

        Char.Humanoid:EquipTool(Knife)
        task.wait(0.2)

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                Char.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
                task.wait(0.1)
                
                -- Senin sağladığın Cobalt Kodu
                local Event = GetNil("KnifeStabbed", "1_1294408")
                if Event then pcall(function() Event:FireServer() end) end
                AttackFallback()
                task.wait(0.2)
            end
        end
    end)

    CombatTab:CreateButton("🔪 Kill All (Fling Mode)", function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                FlingTarget(p)
                task.wait(0.1)
            end
        end
    end)

    CombatTab:CreateButton("🔫 Kill Murderer (Sheriff - Gun)", function()
        local Char = LocalPlayer.Character
        local Gun = LocalPlayer.Backpack:FindFirstChild("Gun") or Char:FindFirstChild("Gun")
        local Murderer = GetMurderer()
        
        if not Gun or not Murderer or not Murderer.Character then return end
        
        Char.Humanoid:EquipTool(Gun)
        Char.HumanoidRootPart.CFrame = Murderer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
        task.wait(0.2)

        -- Senin sağladığın Cobalt Silah Kodu
        pcall(function()
            local Event = game:GetService("ReplicatedStorage").ClientServices.WeaponService.GunFired
            firesignal(Event.OnClientEvent, 
                Gun.Handle,
                Char.HumanoidRootPart.Position,
                Murderer.Character.HumanoidRootPart.Position,
                GetNil("Handle", "1_1578716")
            )
        end)
        
        pcall(function()
            local Event2 = GetNil("Shoot", "1_1411212")
            if Event2 then
                Event2:FireServer(
                    Char.HumanoidRootPart.CFrame,
                    Murderer.Character.HumanoidRootPart.CFrame
                )
            end
        end)

        AttackFallback()
    end)

    CombatTab:CreateButton("🔫 Kill Murderer (Fling Mode)", function()
        local Murderer = GetMurderer()
        if Murderer then FlingTarget(Murderer) end
    end)

    CombatTab:CreateToggle("Auto Get Gun (When Dropped)", function(state)
        AutoGetGun = state
        if AutoGetGun then
            task.spawn(function()
                while AutoGetGun do
                    task.wait(0.1)
                    local Map = GetMap()
                    if Map and Map:FindFirstChild("GunDrop") then
                        local Char = LocalPlayer.Character
                        if Char and Char:FindFirstChild("HumanoidRootPart") then
                            local SavedCFrame = Char.HumanoidRootPart.CFrame
                            Char.HumanoidRootPart.CFrame = Map.GunDrop.CFrame
                            
                            -- Silah alınana veya harita değişene kadar bekle
                            while Map:FindFirstChild("GunDrop") and AutoGetGun do task.wait(0.1) end
                            
                            -- Eski yerine geri dön
                            if Char and Char:FindFirstChild("HumanoidRootPart") then
                                Char.HumanoidRootPart.CFrame = SavedCFrame
                            end
                        end
                    end
                end
            end)
        end
    end)

    -- ==========================================
    -- 5. TELEPORTS
    -- ==========================================
    TeleportTab:CreateButton("Teleport to Lobby", function()
        if workspace:FindFirstChild("Lobby") and workspace.Lobby:FindFirstChild("Spawns") then
            local spawns = workspace.Lobby.Spawns:GetChildren()
            if #spawns > 0 then
                LocalPlayer.Character.HumanoidRootPart.CFrame = spawns[math.random(1, #spawns)].CFrame * CFrame.new(0,3,0)
            end
        end
    end)

    TeleportTab:CreateButton("Teleport to Map", function()
        local Map = GetMap()
        if Map and Map:FindFirstChild("Spawns") then
            local spawns = Map.Spawns:GetChildren()
            if #spawns > 0 then
                -- 12. spawnı bulmaya çalışır, yoksa rastgele atar
                local targetSpawn = spawns[12] or spawns[math.random(1, #spawns)]
                LocalPlayer.Character.HumanoidRootPart.CFrame = targetSpawn.CFrame * CFrame.new(0,3,0)
            end
        end
    end)

    TeleportTab:CreateButton("Teleport to Murderer", function()
        local Murderer = GetMurderer()
        if Murderer and Murderer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = Murderer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end
    end)

    TeleportTab:CreateButton("Teleport to Sheriff", function()
        local Sheriff = GetSheriff()
        if Sheriff and Sheriff.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = Sheriff.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end
    end)

    -- ==========================================
    -- 6. VISUALS & ESP (KATİL / ŞERİF GÖRME)
    -- ==========================================
    local ESPFolder = Instance.new("Folder", game:GetService("CoreGui"))
    ESPFolder.Name = "EmloxaMM2ESP"

    local function CreateHighlight(player, color)
        if player == LocalPlayer then return end
        local hl = Instance.new("Highlight")
        hl.Name = player.Name .. "_ESP"
        hl.FillColor = color
        hl.OutlineColor = Color3.new(1, 1, 1)
        hl.FillTransparency = 0.5
        hl.Parent = ESPFolder
        
        task.spawn(function()
            while player.Parent and ESPFolder:FindFirstChild(hl.Name) do
                if player.Character then hl.Adornee = player.Character end
                task.wait(1)
            end
            hl:Destroy()
        end)
    end

    ESPTab:CreateButton("🔄 Update ESP Roles", function()
        ESPFolder:ClearAllChildren()
        for _, p in pairs(Players:GetPlayers()) do
            local color = Color3.fromRGB(0, 255, 0) -- Masum (Yeşil)
            if p == GetMurderer() then
                color = Color3.fromRGB(255, 0, 0) -- Katil (Kırmızı)
            elseif p == GetSheriff() then
                color = Color3.fromRGB(0, 0, 255) -- Şerif (Mavi)
            end
            CreateHighlight(p, color)
        end
    end)

    ESPTab:CreateButton("❌ Clear ESP", function()
        ESPFolder:ClearAllChildren()
    end)

    -- ==========================================
    -- 7. LOCAL PLAYER (FAKE DEATH, NOCLIP, SPEED)
    -- ==========================================
    LocalTab:CreateToggle("Fake Death (Press H)", function(state)
        FakeDeathEnabled = state
        -- Ekranda bilgilendirme yazısı gösterilir
        local ui = LocalPlayer.PlayerGui:FindFirstChild("FakeDeathNotif")
        if state and not ui then
            ui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
            ui.Name = "FakeDeathNotif"
            local txt = Instance.new("TextLabel", ui)
            txt.Size = UDim2.new(0, 200, 0, 30)
            txt.Position = UDim2.new(0.5, -100, 0, 10)
            txt.BackgroundTransparency = 1
            txt.Text = "[H] Fake Death: ON"
            txt.Font = Enum.Font.GothamBold
            txt.TextColor3 = Color3.fromRGB(255, 85, 85)
            txt.TextSize = 14
        elseif not state and ui then
            ui:Destroy()
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.H and FakeDeathEnabled then
            local Char = LocalPlayer.Character
            if Char and Char:FindFirstChild("Humanoid") and Char:FindFirstChild("HumanoidRootPart") then
                if not Char.Humanoid.PlatformStand then
                    -- Yere Yüz Üstü Yatma
                    Char.Humanoid.PlatformStand = true
                    Char.HumanoidRootPart.CFrame = Char.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(90), 0, 0)
                else
                    -- Ayağa Kalkma
                    Char.Humanoid.PlatformStand = false
                    Char.Humanoid.Jump = true
                end
            end
        end
    end)

    LocalTab:CreateToggle("Noclip", function(state)
        NoclipActive = state
    end)

    RunService.Stepped:Connect(function()
        -- Farm açıkken harita altında takılmamak için noclip zorunludur
        if (NoclipActive or FarmEnabled) and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)

    LocalTab:CreateSlider("WalkSpeed", 16, 100, 16, function(val)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = val
        end
    end)

    LocalTab:CreateSlider("JumpPower", 50, 200, 50, function(val)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.UseJumpPower = true
            LocalPlayer.Character.Humanoid.JumpPower = val
        end
    end)
end

return GameModule
