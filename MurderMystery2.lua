-- =========================================================================
-- EMLOXA WARE: MURDER MYSTERY 2
-- ULTIMATE STEALTH & COMBAT ENGINE (AGGRO FLING, DIRECT FARM, TEXT ESP)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    -- ==========================================
    -- 1. DİNAMİK ALTYAPI & YARDIMCI FONKSİYONLAR
    -- ==========================================
    
    local function GetNilByName(Name)
        if getnilinstances then
            for _, Object in pairs(getnilinstances()) do
                if Object.Name == Name then
                    return Object
                end
            end
        end
        return nil
    end

    local function GetMap()
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Model") and v.Name ~= "Lobby" and (v:FindFirstChild("CoinContainer") or v:FindFirstChild("Spawns")) then
                return v
            end
        end
        return nil
    end

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

    -- Yeni Agresif (Çıldıran) Fling Motoru
    local function FlingTarget(TargetPlayer)
        local Char = LocalPlayer.Character
        local TargetChar = TargetPlayer.Character
        if not Char or not Char:FindFirstChild("HumanoidRootPart") or not TargetChar or not TargetChar:FindFirstChild("HumanoidRootPart") then return end
        
        local hrp = Char.HumanoidRootPart
        local targetHrp = TargetChar.HumanoidRootPart
        local originalPos = hrp.CFrame
        
        -- Agresif Fırlatma Kuvveti (Senin verdiğin mantık)
        local thr = Instance.new("BodyThrust")
        thr.Name = "EmloxaFlingThrust"
        thr.Force = Vector3.new(99999, 99999, 99999)
        thr.Location = hrp.Position
        thr.Parent = hrp
        
        local startTime = tick()
        -- Hedef fırlayana kadar (Hızı 50'yi geçene kadar) veya max 3 saniye çıldırarak yapış
        while tick() - startTime < 3 and targetHrp.Velocity.Magnitude < 50 do
            RunService.Heartbeat:Wait()
            if targetHrp.Parent and targetHrp:FindFirstChild("HumanoidRootPart") then
                hrp.CFrame = targetHrp.CFrame
                thr.Location = targetHrp.Position
            else
                break
            end
        end
        
        thr:Destroy()
        
        -- Karakterini sakinleştir ve eski yerine koy
        hrp.Velocity = Vector3.new(0,0,0)
        hrp.RotVelocity = Vector3.new(0,0,0)
        hrp.CFrame = originalPos
    end

    -- ==========================================
    -- 2. TABS & DEĞİŞKENLER
    -- ==========================================
    local FarmTab = Window:CreateTab("Auto Farm")
    local MurdererTab = Window:CreateTab("Murderer Options")
    local SheriffTab = Window:CreateTab("Sheriff Options")
    local FlingTab = Window:CreateTab("Fling Options")
    local ESPTab = Window:CreateTab("Visuals and ESP")
    local TeleportTab = Window:CreateTab("Teleports")
    local LocalTab = Window:CreateTab("Local Player")

    local FarmEnabled = false
    local FarmMode = "Legit" 
    local FarmSpeed = 2

    local ESP_Settings = {
        Murderer = false,
        Sheriff = false,
        Innocent = false,
        ShowNames = false,
        ShowDistance = false
    }
    local NoclipActive = false
    local FakeDeathEnabled = false
    local AutoGetGun = false

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
                    if Map and Map:FindFirstChild("CoinContainer") then
                        for _, coin in pairs(Map.CoinContainer:GetDescendants()) do
                            if not FarmEnabled then break end
                            if coin.Name == "CoinVisual" and coin.Parent.Name == "Coin_Server" then
                                local Char = LocalPlayer.Character
                                if Char and Char:FindFirstChild("HumanoidRootPart") then
                                    -- Doğrudan paranın konumuna ışınlanır
                                    local targetCFrame = coin.CFrame

                                    if FarmMode == "Legit" then
                                        local dist = (Char.HumanoidRootPart.Position - targetCFrame.Position).Magnitude
                                        local tweenTime = math.clamp(dist / (FarmSpeed * 50), 0.5, 3)
                                        local tween = TweenService:Create(Char.HumanoidRootPart, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
                                        tween:Play()
                                        tween.Completed:Wait()
                                    else
                                        Char.HumanoidRootPart.CFrame = targetCFrame
                                        task.wait(0.3) 
                                    end
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
    MurdererTab:CreateButton("Kill All (Require Knife)", function()
        local Char = LocalPlayer.Character
        local Knife = LocalPlayer.Backpack:FindFirstChild("Knife") or Char:FindFirstChild("Knife")
        if not Knife then return end

        Char.Humanoid:EquipTool(Knife)
        task.wait(0.2)

        local originalPos = Char.HumanoidRootPart.CFrame
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                Char.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
                task.wait(0.1)
                
                local Event = GetNilByName("KnifeStabbed")
                if Event then pcall(function() Event:FireServer() end) end
                
                task.wait(0.2)
            end
        end
        Char.HumanoidRootPart.CFrame = originalPos
    end)

    SheriffTab:CreateButton("Kill Murderer (Require Gun)", function()
        local Char = LocalPlayer.Character
        local Gun = LocalPlayer.Backpack:FindFirstChild("Gun") or Char:FindFirstChild("Gun")
        local Murderer = GetMurderer()
        
        if not Gun or not Murderer or not Murderer.Character then return end
        
        Char.Humanoid:EquipTool(Gun)
        
        local originalPos = Char.HumanoidRootPart.CFrame
        Char.HumanoidRootPart.CFrame = Murderer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
        task.wait(0.2)

        pcall(function()
            local Event = game:GetService("ReplicatedStorage").ClientServices.WeaponService.GunFired
            firesignal(Event.OnClientEvent, 
                Gun.Handle,
                Char.HumanoidRootPart.Position,
                Murderer.Character.HumanoidRootPart.Position,
                GetNilByName("Handle")
            )
        end)
        
        pcall(function()
            local Event2 = GetNilByName("Shoot")
            if Event2 then
                Event2:FireServer(
                    Char.HumanoidRootPart.CFrame,
                    Murderer.Character.HumanoidRootPart.CFrame
                )
            end
        end)

        task.wait(0.2)
        Char.HumanoidRootPart.CFrame = originalPos
    end)

    SheriffTab:CreateToggle("Auto Get Dropped Gun", function(state)
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
                            
                            while Map:FindFirstChild("GunDrop") and AutoGetGun do task.wait(0.1) end
                            
                            if Char and Char:FindFirstChild("HumanoidRootPart") then
                                Char.HumanoidRootPart.CFrame = SavedCFrame
                            end
                        end
                    end
                end
            end)
        end
    end)

    -- Fling Options
    FlingTab:CreateButton("Kill All (Fling Mode)", function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                FlingTarget(p)
                task.wait(0.1)
            end
        end
    end)

    FlingTab:CreateButton("Kill Murderer (Fling Mode)", function()
        local Murderer = GetMurderer()
        if Murderer then FlingTarget(Murderer) end
    end)

    -- ==========================================
    -- 5. VISUALS & ESP (AYRILMIŞ ROLLER & TEXT)
    -- ==========================================
    local ESPFolder = Instance.new("Folder", game:GetService("CoreGui"))
    ESPFolder.Name = "EmloxaMM2ESP"

    local function ClearESP()
        ESPFolder:ClearAllChildren()
    end

    local function RefreshESP()
        ClearESP()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local isMurderer = (p == GetMurderer())
                local isSheriff = (p == GetSheriff())
                local isInnocent = not isMurderer and not isSheriff

                local shouldDraw = false
                local drawColor = Color3.new(1,1,1)

                if isMurderer and ESP_Settings.Murderer then
                    shouldDraw = true
                    drawColor = Color3.fromRGB(255, 0, 0)
                elseif isSheriff and ESP_Settings.Sheriff then
                    shouldDraw = true
                    drawColor = Color3.fromRGB(0, 0, 255)
                elseif isInnocent and ESP_Settings.Innocent then
                    shouldDraw = true
                    drawColor = Color3.fromRGB(0, 255, 0)
                end

                if shouldDraw then
                    local hl = Instance.new("Highlight")
                    hl.Name = p.Name .. "_ESP"
                    hl.FillColor = drawColor
                    hl.OutlineColor = Color3.new(1, 1, 1)
                    hl.FillTransparency = 0.5
                    hl.Adornee = p.Character
                    hl.Parent = ESPFolder

                    -- İsim veya Mesafe açıksa metin kutusunu ekle
                    if ESP_Settings.ShowNames or ESP_Settings.ShowDistance then
                        local bgui = Instance.new("BillboardGui")
                        bgui.Name = p.Name .. "_TextESP"
                        bgui.Adornee = p.Character.HumanoidRootPart
                        bgui.Size = UDim2.new(0, 200, 0, 40)
                        bgui.StudsOffset = Vector3.new(0, 3, 0)
                        bgui.AlwaysOnTop = true
                        bgui.Parent = ESPFolder

                        local txt = Instance.new("TextLabel")
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.TextColor3 = drawColor
                        txt.TextStrokeColor3 = Color3.new(0, 0, 0)
                        txt.TextStrokeTransparency = 0
                        txt.Font = Enum.Font.GothamBold
                        txt.TextSize = 13
                        txt.Text = ""
                        txt.Parent = bgui
                    end
                end
            end
        end
    end

    -- Highlightları (Renkleri) 1 Saniyede Bir Güncelle
    task.spawn(function()
        while task.wait(1) do
            if ESP_Settings.Murderer or ESP_Settings.Sheriff or ESP_Settings.Innocent then
                RefreshESP()
            else
                ClearESP()
            end
        end
    end)

    -- Mesafeleri ve İsimleri Çok Hızlı (0.1s) Güncelle
    task.spawn(function()
        while task.wait(0.1) do
            if ESP_Settings.Murderer or ESP_Settings.Sheriff or ESP_Settings.Innocent then
                for _, child in pairs(ESPFolder:GetChildren()) do
                    if child:IsA("BillboardGui") and child.Adornee then
                        local txt = child:FindFirstChildOfClass("TextLabel")
                        if txt then
                            local pName = string.gsub(child.Name, "_TextESP", "")
                            local textStr = ""
                            
                            if ESP_Settings.ShowNames then
                                textStr = pName
                            end
                            
                            if ESP_Settings.ShowDistance and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - child.Adornee.Position).Magnitude)
                                if textStr ~= "" then
                                    textStr = textStr .. "\n[" .. dist .. "m]"
                                else
                                    textStr = "[" .. dist .. "m]"
                                end
                            end
                            
                            txt.Text = textStr
                        end
                    end
                end
            end
        end
    end)

    ESPTab:CreateToggle("ESP Murderer", function(state)
        ESP_Settings.Murderer = state
        RefreshESP()
    end)

    ESPTab:CreateToggle("ESP Sheriff", function(state)
        ESP_Settings.Sheriff = state
        RefreshESP()
    end)

    ESPTab:CreateToggle("ESP Innocent", function(state)
        ESP_Settings.Innocent = state
        RefreshESP()
    end)

    ESPTab:CreateToggle("Show Names", function(state)
        ESP_Settings.ShowNames = state
        RefreshESP()
    end)

    ESPTab:CreateToggle("Show Distance", function(state)
        ESP_Settings.ShowDistance = state
        RefreshESP()
    end)

    -- ==========================================
    -- 6. TELEPORTS
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
    -- 7. LOCAL PLAYER (FAKE DEATH, NOCLIP, SPEED)
    -- ==========================================
    LocalTab:CreateToggle("Fake Death (Press H)", function(state)
        FakeDeathEnabled = state
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
            local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
            if Char and Char:FindFirstChild("Humanoid") and HRP then
                if not Char.Humanoid.PlatformStand then
                    Char.Humanoid.PlatformStand = true
                    HRP.Anchored = true
                    HRP.CFrame = HRP.CFrame * CFrame.Angles(math.rad(90), 0, 0) + Vector3.new(0, -1.5, 0)
                else
                    Char.Humanoid.PlatformStand = false
                    HRP.Anchored = false
                    Char.Humanoid.Jump = true
                end
            end
        end
    end)

    LocalTab:CreateToggle("Noclip", function(state)
        NoclipActive = state
    end)

    RunService.Stepped:Connect(function()
        if NoclipActive or FarmEnabled then
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
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
