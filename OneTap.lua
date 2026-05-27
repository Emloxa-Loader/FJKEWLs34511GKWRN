-- =========================================================================
-- EMLOXA WARE: ONE TAP V2 (ULTIMATE NPC & PLAYER HYBRID CORE)
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
    -- 1. GELİŞMİŞ AYARLAR (STATE)
    -- ==========================================
    local Settings = {
        Combat = {
            LegitAimbot = false,
            RageBot = false,
            TriggerBot = false,
            RealPlayersOnly = true, -- YENİ: Sadece gerçek oyuncular
            TargetPart = "Head",
            Smoothness = 5,
            Prediction = 0.13,
            WallCheck = true,
            TeamCheck = false,
            ShowFOV = true,
            FOVRadius = 150
        },
        Local = {
            WalkSpeed = 16,
            JumpPower = 50,
            CameraFOV = 70,
            SpeedEnabled = false,
            JumpEnabled = false
        },
        Visuals = {
            ESP_Highlight = false,
            ESP_Tracers = false,
            TracerColor = Color3.fromRGB(255, 50, 50)
        },
        Misc = {
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

    -- Mouse Kontrolleri (Sağ Tık)
    table.insert(Connections, UserInputService.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton2 then IsAiming = true end 
    end))
    table.insert(Connections, UserInputService.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton2 then IsAiming = false end 
    end))

    -- ==========================================
    -- 2. UI SEKMELERİ
    -- ==========================================
    local CombatTab = Window:CreateTab("Combat (Aim)")
    CombatTab:CreateToggle("Legit Aimbot (Right Click)", function(s) Settings.Combat.LegitAimbot = s end)
    CombatTab:CreateToggle("RageBot (Auto Lock)", function(s) Settings.Combat.RageBot = s end)
    CombatTab:CreateToggle("TriggerBot (Auto Shoot on Crosshair)", function(s) Settings.Combat.TriggerBot = s end)
    
    CombatTab:CreateToggle("Only Lock Real Players", function(s) Settings.Combat.RealPlayersOnly = s end)
    CombatTab:CreateToggle("Wall Check (Duvar Arkası Vurma)", function(s) Settings.Combat.WallCheck = s end)
    
    CombatTab:CreateDropdown("Target Part", {"Head", "HumanoidRootPart", "UpperTorso"}, "Head", function(v) Settings.Combat.TargetPart = v end)
    CombatTab:CreateSlider("Smoothness", 1, 20, 5, function(v) Settings.Combat.Smoothness = v end)
    CombatTab:CreateSlider("Prediction (Gelecek Tahmini)", 0, 50, 13, function(v) Settings.Combat.Prediction = v / 100 end)
    
    local LocalTab = Window:CreateTab("Local Player")
    LocalTab:CreateToggle("Enable Custom WalkSpeed", function(s) Settings.Local.SpeedEnabled = s end)
    LocalTab:CreateSlider("WalkSpeed", 16, 250, 16, function(v) Settings.Local.WalkSpeed = v end)
    LocalTab:CreateToggle("Enable Custom JumpPower", function(s) Settings.Local.JumpEnabled = s end)
    LocalTab:CreateSlider("JumpPower", 50, 300, 50, function(v) Settings.Local.JumpPower = v end)
    LocalTab:CreateSlider("Camera FOV (Görüş Açısı)", 70, 120, 70, function(v) Settings.Local.CameraFOV = v; Camera.FieldOfView = v end)
    LocalTab:CreateToggle("SpinBot (Mevlana)", function(s) Settings.Misc.SpinBot = s end)

    local VisualsTab = Window:CreateTab("Visuals & FOV")
    VisualsTab:CreateToggle("Show FOV Circle", function(s) Settings.Combat.ShowFOV = s end)
    VisualsTab:CreateSlider("FOV Radius", 50, 600, 150, function(v) Settings.Combat.FOVRadius = v end)
    VisualsTab:CreateToggle("Player Highlight ESP", function(s) Settings.Visuals.ESP_Highlight = s end)
    VisualsTab:CreateToggle("Tracer Lines ESP", function(s) Settings.Visuals.ESP_Tracers = s end)

    -- ==========================================
    -- 3. HEDEF BULMA (NPC VE PLAYER DESTEKLİ)
    -- ==========================================
    local function GetValidTargets()
        local targets = {}
        if Settings.Combat.RealPlayersOnly then
            -- SADECE GERÇEK OYUNCULAR
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    if Settings.Combat.TeamCheck and player.Team == LocalPlayer.Team then continue end
                    table.insert(targets, player.Character)
                end
            end
        else
            -- TÜM HUMANOID'LER (NPC, Bot, Zombi, Oyuncu her şey)
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj ~= LocalPlayer.Character and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                    table.insert(targets, obj)
                end
            end
        end
        return targets
    end

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
        -- FPS oyunlarında mouse merkeze kilitlendiği için ekranın tam ortasını baz alıyoruz
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

        local potentialTargets = GetValidTargets()

        for _, character in pairs(potentialTargets) do
            local humanoid = character:FindFirstChild("Humanoid")
            local targetPart = character:FindFirstChild(Settings.Combat.TargetPart) or character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and targetPart then
                local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                
                if onScreen or Settings.Combat.RageBot then
                    local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    
                    if Settings.Combat.RageBot then
                        local realDist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude) or math.huge
                        if realDist < shortestDistance and IsVisible(targetPart) then
                            shortestDistance = realDist
                            bestTarget = targetPart
                        end
                    else
                        if dist < shortestDistance and IsVisible(targetPart) then
                            shortestDistance = dist
                            bestTarget = targetPart
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
        -- FOV Ekranın Tam Ortasına
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = Settings.Combat.FOVRadius
        FOVCircle.Visible = Settings.Combat.ShowFOV

        -- ESP Sistemi
        local targets = GetValidTargets()
        
        -- Önce tüm highlightları temizle (Görünmez olanlar kalmasın diye)
        if not Settings.Visuals.ESP_Highlight then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Highlight") and obj.Name == "EmloxaESP" then obj:Destroy() end
            end
        end

        for _, character in pairs(targets) do
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                -- Highlight
                if Settings.Visuals.ESP_Highlight then
                    local highlight = character:FindFirstChild("EmloxaESP")
                    if not highlight then
                        highlight = Instance.new("Highlight", character)
                        highlight.Name = "EmloxaESP"
                        highlight.FillColor
