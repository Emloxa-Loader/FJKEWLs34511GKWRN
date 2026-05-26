-- =========================================================================
-- EMLOXA WARE: UNIVERSAL MODULE
-- =========================================================================
local UniversalModule = {}

function UniversalModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Lighting = game:GetService("Lighting")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer

    -- ==========================================
    -- AİMBOT SİSTEMİ
    -- ==========================================
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false; FOVCircle.Color = Color3.fromRGB(102, 85, 255)
    FOVCircle.Thickness = 1.5; FOVCircle.Filled = false; FOVCircle.Transparency = 1; FOVCircle.Radius = 100
    
    local AimbotEnabled, ShowFOV, IsAiming = false, false, false
    local AimbotSmoothing = 1

    UserInputService.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton2 then IsAiming = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton2 then IsAiming = false end end)

    local function GetClosestPlayer()
        local closest, shortest = nil, FOVCircle.Radius
        local mousePos = UserInputService:GetMouseLocation()
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if dist < shortest then closest, shortest = plr, dist end
                end
            end
        end
        return closest
    end

    local AimbotTab = Window:CreateTab("Aimbot")
    AimbotTab:CreateToggle("Enable Aimbot (Right Click)", function(s) AimbotEnabled = s end)
    AimbotTab:CreateToggle("Show FOV Circle", function(s) ShowFOV = s end)
    AimbotTab:CreateSlider("FOV Radius", 30, 400, 100, function(v) FOVCircle.Radius = v end)
    AimbotTab:CreateSlider("Smoothing (1-10)", 1, 10, 10, function(v) AimbotSmoothing = v / 10 end)

    -- ==========================================
    -- LOCAL PLAYER (FLY, NOCLIP, SPEED)
    -- ==========================================
    local PlayerTab = Window:CreateTab("Local Player")
    local NoclipEnabled, InfiniteJumpEnabled, FlyEnabled = false, false, false
    local FlySpeed, CurrentSpeed, CurrentJump = 50, 16, 50

    PlayerTab:CreateToggle("Noclip (Walk Through Walls)", function(s) NoclipEnabled = s end)
    PlayerTab:CreateToggle("Infinite Jump", function(s) InfiniteJumpEnabled = s end)
    
    PlayerTab:CreateSlider("WalkSpeed", 16, 250, 16, function(v) 
        CurrentSpeed = v
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end 
    end)
    PlayerTab:CreateSlider("JumpPower", 50, 300, 50, function(v) 
        CurrentJump = v
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
            LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = v 
        end 
    end)

    PlayerTab:CreateToggle("Fly Hack", function(state)
        FlyEnabled = state
        local Char = LocalPlayer.Character
        local Root = Char and Char:FindFirstChild("HumanoidRootPart")
        local Hum = Char and Char:FindFirstChild("Humanoid")
        if not Root or not Hum then return end
        
        if FlyEnabled then
            Hum.PlatformStand = true
            local BV = Instance.new("BodyVelocity", Root)
            BV.Name = "EmloxaFly"; BV.Velocity = Vector3.new(0, 0, 0); BV.MaxForce = Vector3.new(10000, 10000, 10000)
            
            -- KAMERAYA BAKMA SİSTEMİ (BodyGyro)
            local BG = Instance.new("BodyGyro", Root)
            BG.Name = "EmloxaGyro"; BG.P = 9e4; BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9); BG.CFrame = Root.CFrame
            
            task.spawn(function()
                while FlyEnabled and Root and BV.Parent do
                    local dir = Vector3.new(0, 0, 0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                    
                    BV.Velocity = dir.Unit * FlySpeed
                    if dir == Vector3.new(0, 0, 0) then BV.Velocity = Vector3.new(0, 0.1, 0) end
                    
                    -- Karakteri Kameranın Baktığı Yöne Çevir
                    BG.CFrame = Camera.CFrame
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

    UserInputService.JumpRequest:Connect(function()
        if InfiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)

    RunService.Stepped:Connect(function()
        if NoclipEnabled and LocalPlayer.Character then
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end end
        end
        local Hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if Hum and not FlyEnabled then
            Hum.WalkSpeed = CurrentSpeed; Hum.UseJumpPower = true; Hum.JumpPower = CurrentJump
        end
    end)

    -- ==========================================
    -- VISUALS & MISC
    -- ==========================================
    local VisualsTab = Window:CreateTab("Visuals")
    local ESPEnabled, TracersEnabled = false, false
    local Tracers = {}

    VisualsTab:CreateToggle("ESP (Through Walls)", function(s) ESPEnabled = s end)
    VisualsTab:CreateToggle("Tracers (Lines)", function(s) TracersEnabled = s end)
    VisualsTab:CreateSlider("Field of View (FOV)", 70, 120, 70, function(v) Camera.FieldOfView = v end)

    local MiscTab = Window:CreateTab("Misc")
    local RGBCharEnabled, DiscoEnabled = false, false
    local RGBCharSpeed, OriginalColors = 2, {}
    local origAmb, origOut, origFog = Lighting.Ambient, Lighting.OutdoorAmbient, Lighting.FogColor

    MiscTab:CreateToggle("RGB Character", function(s) RGBCharEnabled = s; if not s and LocalPlayer.Character then for p, c in pairs(OriginalColors) do if p and p.Parent == LocalPlayer.Character then p.Color = c end end; OriginalColors={} end end)
    MiscTab:CreateSlider("RGB Character Speed", 1, 10, 2, function(v) RGBCharSpeed = v end)
    MiscTab:CreateToggle("Disco Mode (Sky)", function(s) DiscoEnabled = s; if not s then Lighting.Ambient = origAmb; Lighting.OutdoorAmbient = origOut; Lighting.FogColor = origFog end end)

    MiscTab:CreateButton("Unload EMLOXA WARE", function()
        ESPEnabled = false; TracersEnabled = false; NoclipEnabled = false; RGBCharEnabled = false; DiscoEnabled = false; FlyEnabled = false
        FOVCircle:Remove()
        Lighting.Ambient = origAmb; Lighting.OutdoorAmbient = origOut; Lighting.FogColor = origFog
        for _, line in pairs(Tracers) do line:Remove() end
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)

    RunService.RenderStepped:Connect(function()
        -- ESP & Tracers Loop
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hl = plr.Character:FindFirstChild("EmloxaESP")
                if ESPEnabled then
                    if not hl then hl = Instance.new("Highlight", plr.Character); hl.Name = "EmloxaESP"; hl.FillColor = Color3.fromRGB(102, 85, 255); hl.FillTransparency = 0.5; hl.OutlineColor = Color3.fromRGB(255,255,255); hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop end
                elseif hl then hl:Destroy() end
                
                if not Tracers[plr] then local line = Drawing.new("Line"); line.Color = Color3.fromRGB(102, 85, 255); line.Thickness = 1.5; line.Transparency = 1; line.Visible = false; Tracers[plr] = line end
                local line = Tracers[plr]
                if TracersEnabled and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.Humanoid.Health > 0 then
                    local vec, onScreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                    if onScreen then line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); line.To = Vector2.new(vec.X, vec.Y); line.Visible = true
                    else line.Visible = false end
                else line.Visible = false end
            end
        end

        FOVCircle.Position = UserInputService:GetMouseLocation(); FOVCircle.Visible = ShowFOV
        if AimbotEnabled and IsAiming then
            local target = GetClosestPlayer()
            if target then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Character.Head.Position), AimbotSmoothing) end
        end

        if RGBCharEnabled and LocalPlayer.Character then
            local color = Color3.fromHSV((tick() * RGBCharSpeed * 0.1) % 1, 1, 1)
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do if part:IsA("BasePart") then if not OriginalColors[part] then OriginalColors[part] = part.Color end; part.Color = color end end
        end
        if DiscoEnabled then
            local col = Color3.fromHSV((tick() * 0.5) % 1, 1, 1)
            Lighting.Ambient = col; Lighting.OutdoorAmbient = col; Lighting.FogColor = col
        end
    end)
    Players.PlayerRemoving:Connect(function(plr) if Tracers[plr] then Tracers[plr]:Remove(); Tracers[plr] = nil end end)
end

return UniversalModule
