-- =========================================================================
-- EMLOXA WARE: ONE TAP ULTIMATE MODULE (RAGE & LEGIT CORE)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer
    local Mouse = LocalPlayer:GetMouse()

    -- ==========================================
    -- 1. GELİŞMİŞ AYARLAR (STATE)
    -- ==========================================
    local Settings = {
        Combat = {
            LegitAimbot = false,
            RageBot = false,
            TriggerBot = false,
            TargetPart = "Head",
            Smoothness = 5,
            Prediction = 0.13,
            WallCheck = true,
            TeamCheck = true,
            ShowFOV = true,
            FOVRadius = 150
        },
        Visuals = {
            ESP_Highlight = false,
            ESP_Tracers = false,
            TracerColor = Color3.fromRGB(255, 50, 50)
        },
        Misc = {
            NoRecoil = false,
            SpinBot = false,
            SpinSpeed = 50
        }
    }

    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1.5
    FOVCircle.NumSides = 60
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1
    FOVCircle.Color = Color3.fromRGB(102, 85, 255)

    local Tracers = {}
    local Connections = {}
    local IsAiming = false

    -- Mouse Kontrolleri
    table.insert(Connections, UserInputService.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton2 then IsAiming = true end 
    end))
    table.insert(Connections, UserInputService.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton2 then IsAiming = false end 
    end))

    -- ==========================================
    -- 2. UI SEKMELERİ
    -- ==========================================
    local CombatTab = Window:CreateTab("Legit Combat")
    CombatTab:CreateToggle("Enable Legit Aimbot (Right Click)", function(s) Settings.Combat.LegitAimbot = s end)
    CombatTab:CreateDropdown("Target Part", {"Head", "HumanoidRootPart", "UpperTorso"}, "Head", function(v) Settings.Combat.TargetPart = v end)
    CombatTab:CreateSlider("Smoothness", 1, 20, 5, function(v) Settings.Combat.Smoothness = v end)
    CombatTab:CreateSlider("Prediction (Ping Ayarı)", 0, 50, 13, function(v) Settings.Combat.Prediction = v / 100 end)
    CombatTab:CreateToggle("Wall Check (Duvar Arkası Vurma)", function(s) Settings.Combat.WallCheck = s end)
    
    local RageTab = Window:CreateTab("RageBot")
    RageTab:CreateToggle("Enable RageBot (Auto Aim & Shoot)", function(s) Settings.Combat.RageBot = s end)
    RageTab:CreateToggle("TriggerBot (Oto Sıkma)", function(s) Settings.Combat.TriggerBot = s end)
    RageTab:CreateToggle("SpinBot (Mevlana)", function(s) Settings.Misc.SpinBot = s end)
    
    local FOVTab = Window:CreateTab("FOV Settings")
    FOVTab:CreateToggle("Show FOV Circle", function(s) Settings.Combat.ShowFOV = s end)
    FOVTab:CreateSlider("FOV Radius", 50, 600, 150, function(v) Settings.Combat.FOVRadius = v end)

    local VisualsTab = Window:CreateTab("Visuals")
    VisualsTab:CreateToggle("Player Highlight ESP", function(s) Settings.Visuals.ESP_Highlight = s end)
    VisualsTab:CreateToggle("Tracer Lines ESP", function(s) Settings.Visuals.ESP_Tracers = s end)

    -- ==========================================
    -- 3. HEDEF BULMA VE MATEMATİK
    -- ==========================================
    local function IsVisible(targetPart)
        if not Settings.Combat.WallCheck then return true end
        local origin = Camera.CFrame.Position
        local direction = (targetPart.Position - origin)
        
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.IgnoreWater = true
        
        local result = workspace:Raycast(origin, direction, params)
        return not result or result.Instance:IsDescendantOf(targetPart.Parent)
    end

    local function GetBestTarget()
        local bestTarget = nil
        local shortestDistance = Settings.Combat.RageBot and math.huge or Settings.Combat.FOVRadius
        local mousePos = Vector2.new(Mouse.X, Mouse.Y)

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Settings.Combat.TargetPart) then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    if Settings.Combat.TeamCheck and player.Team == LocalPlayer.Team then continue end
                    
                    local targetPart = player.Character[Settings.Combat.TargetPart]
                    local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    
                    if onScreen or Settings.Combat.RageBot then
                        local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        
                        if Settings.Combat.RageBot then
                            -- Ragebot ekrandan bağımsız en yakına kilitlenir
                            local realDist = (LocalPlayer.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude
                            if realDist < shortestDistance and IsVisible(targetPart) then
                                shortestDistance = realDist
                                bestTarget = targetPart
                            end
                        else
                            -- Legit Aimbot FOV içinde arar
                            if dist < shortestDistance and IsVisible(targetPart) then
                                shortestDistance = dist
                                bestTarget = targetPart
                            end
                        end
                    end
                end
            end
        end
        return bestTarget
    end

    -- ==========================================
    -- 4. ANA DÖNGÜ (RENDER & HEARTBEAT)
    -- ==========================================
    table.insert(Connections, RunService.RenderStepped:Connect(function()
        -- FOV Güncellemesi
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36) -- Roblox üst bar offseti
        FOVCircle.Radius = Settings.Combat.FOVRadius
        FOVCircle.Visible = Settings.Combat.ShowFOV

        -- ESP Sistemi (Highlight & Tracers)
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                -- Highlight ESP
                local highlight = player.Character:FindFirstChild("EmloxaESP")
                if Settings.Visuals.ESP_Highlight then
                    if not highlight then
                        highlight = Instance.new("Highlight", player.Character)
                        highlight.Name = "EmloxaESP"
                        highlight.FillColor = Color3.fromRGB(102, 85, 255)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.5
                    end
                elseif highlight then
                    highlight:Destroy()
                end

                -- Tracers
                if not Tracers[player] then
                    Tracers[player] = Drawing.new("Line")
                    Tracers[player].Thickness = 1.5
                    Tracers[player].Color = Settings.Visuals.TracerColor
                end
                
                local tracer = Tracers[player]
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = player.Character:FindFirstChild("Humanoid")

                if Settings.Visuals.ESP_Tracers and rootPart and humanoid and humanoid.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    if onScreen then
                        tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) -- Ekran alt ortası
                        tracer.To = Vector2.new(pos.X, pos.Y)
                        tracer.Visible = true
                    else
                        tracer.Visible = false
                    end
                else
                    tracer.Visible = false
                end
            end
        end

        -- Aimbot & RageBot Çalıştırma
        if (Settings.Combat.LegitAimbot and IsAiming) or Settings.Combat.RageBot then
            local target = GetBestTarget()
            
            if target then
                -- Kusursuz Gelecek Tahmini (Velocity * Prediction)
                local targetVelocity = target.AssemblyLinearVelocity
                local predictedPosition = target.Position + (targetVelocity * Settings.Combat.Prediction)
                
                local lookAtCFrame = CFrame.new(Camera.CFrame.Position, predictedPosition)
                
                if Settings.Combat.RageBot then
                    -- RageBot anında kilitlenir
                    Camera.CFrame = lookAtCFrame
                    if Settings.Combat.TriggerBot then
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.01)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end
                else
                    -- Legit Aimbot pürüzsüz kayar
                    Camera.CFrame = Camera.CFrame:Lerp(lookAtCFrame, 1 / Settings.Combat.Smoothness)
                end
            end
        end

        -- TriggerBot Bağımsız (Aimbot kapalıyken bile Mouse hedefin üstündeyse sıkar)
        if Settings.Combat.TriggerBot and not Settings.Combat.RageBot then
            local mt = Mouse.Target
            if mt and mt.Parent:FindFirstChild("Humanoid") and mt.Parent.Humanoid.Health > 0 then
                local p = Players:GetPlayerFromCharacter(mt.Parent)
                if p and (not Settings.Combat.TeamCheck or p.Team ~= LocalPlayer.Team) then
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.01)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end
        end
    end))

    table.insert(Connections, RunService.Heartbeat:Connect(function()
        -- SpinBot (Fizik motorunda dönmeli ki başkaları görsün)
        if Settings.Misc.SpinBot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(Settings.Misc.SpinSpeed), 0)
        end
    end))

    -- Oyuncu çıkınca Tracer'ı sil (Memory Leak Koruması)
    table.insert(Connections, Players.PlayerRemoving:Connect(function(player)
        if Tracers[player] then
            Tracers[player]:Remove()
            Tracers[player] = nil
        end
    end))

    -- ==========================================
    -- 5. UNLOAD VE TEMİZLİK
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc / Unload")
    MiscTab:CreateButton("Unload EMLOXA WARE", function()
        -- Tüm döngüleri kapat
        for _, conn in pairs(Connections) do conn:Disconnect() end
        
        -- Çizimleri sil
        FOVCircle:Remove()
        for _, tracer in pairs(Tracers) do tracer:Remove() end
        
        -- ESP'leri temizle
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("EmloxaESP") then
                player.Character.EmloxaESP:Destroy()
            end
        end
        
        -- Arayüzü sil
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
