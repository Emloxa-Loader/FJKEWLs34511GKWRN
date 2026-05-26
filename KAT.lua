-- =========================================================================
-- EMLOXA WARE: KNIFE ABILITY TEST (KAT) V13 DISTANCE CORE (HUB FIX)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local VirtualUser = game:GetService("VirtualUser")
    local Lighting = game:GetService("Lighting")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer
    local Mouse = LocalPlayer:GetMouse()

    --// AYARLAR //--
    local Settings = {
        Combat = {
            Aimbot = false,
            RageBot = false,
            TriggerBot = false,
            SilentAim = false,
            FFCheck = true,
            WallCheck = true,
            ShowFOV = true,
            FOV = 120,
            RageRange = 500,
            Smoothness = 5
        },
        Visuals = {
            ESP = false,
            FullBright = false,
            ChamsColor = Color3.fromRGB(255, 0, 0),
            ChamsOutline = Color3.fromRGB(255, 255, 255)
        },
        Movement = {
            WalkSpeed = 16,
            JumpPower = 50,
            InfJump = false,
            NoClip = false
        },
        Misc = {
            SpinBot = false,
            SpinSpeed = 30
        }
    }

    -- FOV Çemberi (Drawing API)
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1.5
    FOVCircle.NumSides = 50
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)

    -- Döngüleri hafızada tutmak için tablo (Unload için)
    local Connections = {}

    -- ==========================================
    -- 1. SEKMELER (EMLOXA HUB FORMATI)
    -- ==========================================
    local CombatTab = Window:CreateTab("Combat")
    local VisualsTab = Window:CreateTab("Visuals")
    local MovementTab = Window:CreateTab("Movement")
    local MiscTab = Window:CreateTab("Misc")

    -- COMBAT TAB
    CombatTab:CreateToggle("RageBot (360°)", function(v) Settings.Combat.RageBot = v end)
    CombatTab:CreateSlider("Mesafe (Range Limit)", 50, 1000, 500, function(v) Settings.Combat.RageRange = v end)
    CombatTab:CreateToggle("Wall Check (Rage & Legit)", function(v) Settings.Combat.WallCheck = v end)
    
    CombatTab:CreateToggle("Legit Aimbot (Sağ Tık)", function(v) Settings.Combat.Aimbot = v end)
    CombatTab:CreateSlider("Aimbot Smoothness", 1, 20, 5, function(v) Settings.Combat.Smoothness = v end)
    CombatTab:CreateToggle("Silent Aim (Micro Flick)", function(v) Settings.Combat.SilentAim = v end)
    
    CombatTab:CreateToggle("TriggerBot", function(v) Settings.Combat.TriggerBot = v end)
    CombatTab:CreateToggle("FF Protection (Spawn Koruma)", function(v) Settings.Combat.FFCheck = v end)
    CombatTab:CreateToggle("Show FOV", function(v) Settings.Combat.ShowFOV = v end)
    CombatTab:CreateSlider("FOV Radius", 50, 600, 120, function(v) Settings.Combat.FOV = v end)

    -- VISUALS TAB
    VisualsTab:CreateToggle("ESP (Force Refresh)", function(v) Settings.Visuals.ESP = v end)
    VisualsTab:CreateToggle("FullBright", function(v) Settings.Visuals.FullBright = v end)

    -- MOVEMENT TAB
    MovementTab:CreateSlider("Walk Speed", 16, 250, 16, function(v) Settings.Movement.WalkSpeed = v end)
    MovementTab:CreateSlider("Jump Power", 50, 300, 50, function(v) Settings.Movement.JumpPower = v end)
    MovementTab:CreateToggle("Infinite Jump", function(v) Settings.Movement.InfJump = v end)
    MovementTab:CreateToggle("NoClip", function(v) Settings.Movement.NoClip = v end)

    -- MISC TAB
    MiscTab:CreateToggle("SpinBot", function(v) Settings.Misc.SpinBot = v end)
    MiscTab:CreateSlider("Spin Speed", 10, 100, 30, function(v) Settings.Misc.SpinSpeed = v end)

    -- ==========================================
    -- 2. HEDEF BULMA FONKSİYONLARI
    -- ==========================================
    local function IsVisible(target)
        if not Settings.Combat.WallCheck then return true end
        local origin = Camera.CFrame.Position
        local dir = target.Position - origin
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {LocalPlayer.Character}
        params.FilterType = Enum.RaycastFilterType.Exclude
        local result = workspace:Raycast(origin, dir.Unit * dir.Magnitude, params)
        return result and result.Instance:IsDescendantOf(target.Parent)
    end

    local function GetRageTarget()
        local target = nil
        local maxDistance = Settings.Combat.RageRange
        
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character.Humanoid.Health > 0 then
                if Settings.Combat.FFCheck and plr.Character:FindFirstChildOfClass("ForceField") then continue end
                
                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                
                if myRoot and targetRoot then
                    local dist = (myRoot.Position - targetRoot.Position).Magnitude
                    if dist <= maxDistance then
                        if Settings.Combat.WallCheck then
                            if IsVisible(plr.Character.Head) then
                                target = plr
                                maxDistance = dist
                            end
                        else
                            target = plr
                            maxDistance = dist
                        end
                    end
                end
            end
        end
        return target
    end

    local function GetLegitTarget()
        local target = nil
        local shortest = Settings.Combat.FOV
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character.Humanoid.Health > 0 then
                if Settings.Combat.FFCheck and plr.Character:FindFirstChildOfClass("ForceField") then continue end
                local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if dist < shortest then
                        if IsVisible(plr.Character.Head) then
                            shortest = dist
                            target = plr
                        end
                    end
                end
            end
        end
        return target
    end

    -- ==========================================
    -- 3. ANA DÖNGÜLER (BACKEND)
    -- ==========================================
    
    -- RenderStepped: Aimbot, Visuals, Spinbot
    table.insert(Connections, RunService.RenderStepped:Connect(function()
        -- FOV GÜNCELLEMESİ
        FOVCircle.Position = UserInputService:GetMouseLocation()
        FOVCircle.Radius = Settings.Combat.FOV
        FOVCircle.Visible = Settings.Combat.ShowFOV and (Settings.Combat.Aimbot or Settings.Combat.SilentAim)
        FOVCircle.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) -- Rainbow FOV

        -- 1. RAGEBOT
        if Settings.Combat.RageBot then
            local target = GetRageTarget()
            if target then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(0,0), Camera.CFrame)
            else
                VirtualUser:Button1Up(Vector2.new(0,0), Camera.CFrame)
            end
        end

        -- 2. LEGIT AIMBOT
        if Settings.Combat.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = GetLegitTarget()
            if target then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character.Head.Position), 1/Settings.Combat.Smoothness)
            end
        end

        -- 3. SILENT AIM (Micro Flick)
        if Settings.Combat.SilentAim and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            local target = GetLegitTarget()
            if target then
                local oldCF = Camera.CFrame
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
                task.delay(0.005, function() Camera.CFrame = oldCF end)
            end
        end
        
        -- 4. TRIGGERBOT
        if Settings.Combat.TriggerBot then
            local mt = Mouse.Target
            if mt and mt.Parent:FindFirstChild("Humanoid") then
                local p = Players:GetPlayerFromCharacter(mt.Parent)
                if p and p ~= LocalPlayer and not (Settings.Combat.FFCheck and p.Character:FindFirstChildOfClass("ForceField")) then
                    VirtualUser:CaptureController()
                    VirtualUser:Button1Down(Vector2.new(0,0), Camera.CFrame)
                    task.wait()
                    VirtualUser:Button1Up(Vector2.new(0,0), Camera.CFrame)
                end
            end
        end

        -- 5. ESP (FORCE REFRESH SYSTEM)
        if Settings.Visuals.ESP then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local hum = plr.Character:FindFirstChild("Humanoid")
                    local head = plr.Character:FindFirstChild("Head")
                    
                    if hum and hum.Health > 0 and head then
                        if not plr.Character:FindFirstChild("EMLOXA_ESP") then
                            local hl = Instance.new("Highlight")
                            hl.Name = "EMLOXA_ESP"
                            hl.FillColor = Settings.Visuals.ChamsColor
                            hl.OutlineColor = Settings.Visuals.ChamsOutline
                            hl.FillTransparency = 0.5
                            hl.Parent = plr.Character
                        end
                    else
                        if plr.Character:FindFirstChild("EMLOXA_ESP") then
                            plr.Character.EMLOXA_ESP:Destroy()
                        end
                    end
                end
            end
        else
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("EMLOXA_ESP") then 
                    plr.Character.EMLOXA_ESP:Destroy() 
                end
            end
        end
        
        -- FullBright & Spinbot
        if Settings.Visuals.FullBright then Lighting.ClockTime = 12; Lighting.GlobalShadows = false end
        if Settings.Misc.SpinBot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(Settings.Misc.SpinSpeed), 0)
        end
    end))

    -- Heartbeat: Movement (Fizik Döngüsü)
    table.insert(Connections, RunService.Heartbeat:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Settings.Movement.WalkSpeed
            LocalPlayer.Character.Humanoid.UseJumpPower = true
            LocalPlayer.Character.Humanoid.JumpPower = Settings.Movement.JumpPower
            if Settings.Movement.NoClip then 
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do 
                    if v:IsA("BasePart") then v.CanCollide = false end 
                end 
            end
        end
    end))

    -- Infinite Jump
    table.insert(Connections, UserInputService.JumpRequest:Connect(function() 
        if Settings.Movement.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) 
        end 
    end))

    -- ==========================================
    -- 4. UNLOAD / CLEANUP
    -- ==========================================
    MiscTab:CreateButton("Unload EMLOXA", function()
        -- Tüm döngüleri kapat
        for _, conn in pairs(Connections) do conn:Disconnect() end
        
        -- FOV Dairesini Sil
        FOVCircle:Remove()
        
        -- ESP'leri Temizle
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("EMLOXA_ESP") then 
                plr.Character.EMLOXA_ESP:Destroy() 
            end
        end
        
        -- Hızı ve Zıplamayı Normale Döndür
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
            LocalPlayer.Character.Humanoid.JumpPower = 50
        end
        
        -- Menüyü Kapat
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
