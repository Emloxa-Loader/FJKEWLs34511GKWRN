-- =========================================================================
-- EMLOXA WARE: EVADE (PLACE ID: 9872472334)
-- OPNSOURCE PORTED & HIGHLY OPTIMIZED
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local VirtualUser = game:GetService("VirtualUser")
    local Workspace = game:GetService("Workspace")
    local Lighting = game:GetService("Lighting")
    local LocalPlayer = Players.LocalPlayer

    -- ==========================================
    -- DEĞİŞKENLER VE HAFIZA YÖNETİMİ
    -- ==========================================
    local Connections = {}
    local ActiveESPs = {} -- ESP döngülerini tek merkezde toplamak için
    local ButtonGui = nil

    -- Ayar Değişkenleri
    local Settings = {
        Movement = {
            WalkSpeed = 16,
            CFrameSpeed = false,
            JumpBoost = false,
            JumpPower = 50,
            AutoBhop = false,
            Gravity = 196.2
        },
        Auto = {
            MapNumber = 1,
            AutoVote = false,
            AutoRevive = false,
            LastReviveCheck = 0
        },
        ESP = {
            Players = false,
            Bots = false,
            ShowDistance = false
        },
        Misc = {
            AntiAFK = true
        }
    }

    local IsHoldingSpace = false
    local IsHoldingMobileBhop = false

    -- Orijinal Işıklandırma Ayarları
    local OrigLighting = {
        Brightness = Lighting.Brightness,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Ambient = Lighting.Ambient,
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        ColorEnabled = Lighting:FindFirstChild("ColorCorrection") and Lighting.ColorCorrection.Enabled or false,
        Saturation = Lighting:FindFirstChild("ColorCorrection") and Lighting.ColorCorrection.Saturation or 0,
        Contrast = Lighting:FindFirstChild("ColorCorrection") and Lighting.ColorCorrection.Contrast or 0
    }

    -- ==========================================
    -- YARDIMCI FONKSİYONLAR
    -- ==========================================
    local function fireVoteServer(mapIndex)
        local eventsFolder = ReplicatedStorage:WaitForChild("Events", 5)
        if eventsFolder and eventsFolder:FindFirstChild("Player") and eventsFolder.Player:FindFirstChild("Vote") then
            eventsFolder.Player.Vote:FireServer(mapIndex)
        end
    end

    local function CreateESP(target, color, nameText, attachPart, yOffset)
        if not target or not attachPart then return end
        if target:FindFirstChild("EmloxaHighlight") then return end

        local highlight = Instance.new("Highlight")
        highlight.Name = "EmloxaHighlight"
        highlight.Adornee = target
        highlight.FillColor = color
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = color
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = target

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "EmloxaBillboard"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, yOffset, 0)
        billboard.Adornee = attachPart
        billboard.Parent = attachPart

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = nameText
        label.TextColor3 = color
        label.TextScaled = false
        label.TextSize = 14
        label.Font = Enum.Font.GothamBold
        label.TextStrokeTransparency = 0
        label.Parent = billboard

        -- ESP'yi güncelleme listesine ekle
        table.insert(ActiveESPs, {
            Target = target,
            Part = attachPart,
            Label = label,
            BaseText = nameText,
            Highlight = highlight,
            Billboard = billboard
        })
    end

    local function RemoveESP(target)
        if not target then return end
        if target:FindFirstChild("EmloxaHighlight") then target.EmloxaHighlight:Destroy() end
        for _, desc in pairs(target:GetDescendants()) do
            if desc.Name == "EmloxaBillboard" then desc:Destroy() end
        end
        -- Listeden çıkar
        for i = #ActiveESPs, 1, -1 do
            if ActiveESPs[i].Target == target then
                table.remove(ActiveESPs, i)
            end
        end
    end

    local function MobileBhopButton()
        if ButtonGui then ButtonGui:Destroy() end

        ButtonGui = Instance.new("ScreenGui")
        ButtonGui.Name = "EmloxaBhopGui"
        ButtonGui.ResetOnSpawn = false
        ButtonGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(0, 60, 0, 60)
        Button.Position = UDim2.new(0.85, 0, 0.75, 0)
        Button.BackgroundColor3 = Color3.fromRGB(102, 85, 255)
        Button.BackgroundTransparency = 0.3
        Button.Text = "BHOP"
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.Font = Enum.Font.GothamBold
        Button.TextScaled = true
        Instance.new("UICorner", Button).CornerRadius = UDim.new(1, 0)
        Button.Parent = ButtonGui

        local dragging = false
        local dragInput, mousePos, framePos

        Button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                mousePos = input.Position
                framePos = Button.Position
                IsHoldingMobileBhop = true
            end
        end)

        Button.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - mousePos
                Button.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
            end
        end)

        Button.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                IsHoldingMobileBhop = false
            end
        end)
    end

    -- ==========================================
    -- SEKME 1: MOVEMENT (HAREKET)
    -- ==========================================
    local PlayerTab = Window:CreateTab("Movement")
    
    PlayerTab:CreateSlider("WalkSpeed", 16, 50, 16, function(v) Settings.Movement.WalkSpeed = v end)
    PlayerTab:CreateToggle("CFrame Speed Boost", function(s) Settings.Movement.CFrameSpeed = s end)
    PlayerTab:CreateToggle("Enable Jump Power", function(s) Settings.Movement.JumpBoost = s end)
    PlayerTab:CreateSlider("Jump Power", 50, 1000, 50, function(v) Settings.Movement.JumpPower = v end)
    PlayerTab:CreateSlider("Gravity", 0, 1000, 196, function(v) Settings.Movement.Gravity = v; Workspace.Gravity = v end)
    PlayerTab:CreateButton("Reset Gravity", function() Settings.Movement.Gravity = 196.2; Workspace.Gravity = 196.2 end)
    
    PlayerTab:CreateDivider()
    PlayerTab:CreateToggle("Auto Bhop (Hold Space)", function(s) Settings.Movement.AutoBhop = s end)
    PlayerTab:CreateButton("Spawn Mobile Bhop Button", function() MobileBhopButton() end)

    -- ==========================================
    -- SEKME 2: AUTO (OTOMASYON)
    -- ==========================================
    local AutoTab = Window:CreateTab("Auto")
    
    AutoTab:CreateDropdown("Select Map to Vote", {"Map 1", "Map 2", "Map 3", "Map 4"}, "Map 1", function(opt)
        Settings.Auto.MapNumber = tonumber(opt:match("%d+")) or 1
    end)
    AutoTab:CreateButton("Force Vote Selected Map", function() fireVoteServer(Settings.Auto.MapNumber) end)
    AutoTab:CreateToggle("Auto Vote Map Loop", function(s) Settings.Auto.AutoVote = s end)
    
    AutoTab:CreateDivider()
    AutoTab:CreateButton("Revive Yourself Instantly", function()
        if LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Downed") then
            ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
        end
    end)
    AutoTab:CreateToggle("Auto Revive Yourself", function(s) Settings.Auto.AutoRevive = s end)

    -- ==========================================
    -- SEKME 3: ESP & VISUALS
    -- ==========================================
    local EspTab = Window:CreateTab("Visuals & ESP")
    
    EspTab:CreateToggle("Players ESP", function(s)
        Settings.ESP.Players = s
        if not s then for _, p in pairs(Players:GetPlayers()) do RemoveESP(p.Character) end end
    end)
    
    EspTab:CreateToggle("NextBots ESP", function(s)
        Settings.ESP.Bots = s
        if not s then
            local gameFolder = Workspace:FindFirstChild("Game")
            local botsFolder = gameFolder and gameFolder:FindFirstChild("Players")
            if botsFolder then for _, bot in pairs(botsFolder:GetChildren()) do RemoveESP(bot) end end
        end
    end)
    
    EspTab:CreateToggle("Show Distance on ESP", function(s) Settings.ESP.ShowDistance = s end)

    EspTab:CreateDivider()
    EspTab:CreateToggle("Full Brightness", function(s)
        Lighting.Brightness = s and 2 or OrigLighting.Brightness
        Lighting.OutdoorAmbient = s and Color3.fromRGB(255, 255, 255) or OrigLighting.OutdoorAmbient
        Lighting.Ambient = s and Color3.fromRGB(255, 255, 255) or OrigLighting.Ambient
        Lighting.GlobalShadows = not s
    end)
    
    EspTab:CreateToggle("Super Brightness (Flashbang)", function(s)
        Lighting.Brightness = s and 15 or OrigLighting.Brightness
        Lighting.OutdoorAmbient = s and Color3.fromRGB(255, 255, 255) or OrigLighting.OutdoorAmbient
        Lighting.Ambient = s and Color3.fromRGB(255, 255, 255) or OrigLighting.Ambient
        Lighting.GlobalShadows = not s
    end)

    EspTab:CreateToggle("No Fog", function(s)
        Lighting.FogEnd = s and 1000000 or OrigLighting.FogEnd
        Lighting.FogStart = s and 999999 or OrigLighting.FogStart
    end)
    
    EspTab:CreateToggle("Vibrant Colors", function(s)
        if Lighting:FindFirstChild("ColorCorrection") then
            Lighting.ColorCorrection.Enabled = s
            Lighting.ColorCorrection.Saturation = s and 0.8 or OrigLighting.Saturation
            Lighting.ColorCorrection.Contrast = s and 0.4 or OrigLighting.Contrast
        end
    end)

    -- ==========================================
    -- SEKME 4: MISC & UNLOAD
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")
    
    MiscTab:CreateToggle("Anti-AFK", function(s) Settings.Misc.AntiAFK = s end)
    
    MiscTab:CreateButton("FPS Boost (Potato PC Mode)", function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.Reflectance = 0
            elseif v:IsA("Decal") then v.Transparency = 1 end
        end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
    
    MiscTab:CreateButton("Unload EMLOXA WARE", function()
        for _, conn in pairs(Connections) do conn:Disconnect() end
        for _, p in pairs(Players:GetPlayers()) do RemoveESP(p.Character) end
        
        local gameFolder = Workspace:FindFirstChild("Game")
        local botsFolder = gameFolder and gameFolder:FindFirstChild("Players")
        if botsFolder then for _, bot in pairs(botsFolder:GetChildren()) do RemoveESP(bot) end end
        
        if ButtonGui then ButtonGui:Destroy() end
        Workspace.Gravity = OrigLighting.Gravity or 196.2
        Lighting.Brightness = OrigLighting.Brightness
        
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)

    -- ==========================================
    -- ANA MOTOR DÖNGÜLERİ (HIGHLY OPTIMIZED)
    -- ==========================================

    -- Girdi Kontrolleri (Spacebar & Bhop)
    table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.Space then IsHoldingSpace = true end
    end))
    table.insert(Connections, UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Space then IsHoldingSpace = false end
    end))

    -- Anti-AFK Döngüsü
    task.spawn(function()
        while task.wait(60) do
            if Settings.Misc.AntiAFK and LocalPlayer then
                VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(0.1)
                VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end
        end
    end)

    -- Merkez Heartbeat / RenderStepped Döngüsü (Tüm kontroller tek çatı altında)
    table.insert(Connections, RunService.Heartbeat:Connect(function()
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        -- 1. FİZİK VE HAREKET (Movement)
        if humanoid and hrp then
            if Settings.Movement.WalkSpeed ~= 16 then humanoid.WalkSpeed = Settings.Movement.WalkSpeed end
            humanoid.UseJumpPower = Settings.Movement.JumpBoost
            if Settings.Movement.JumpBoost then humanoid.JumpPower = Settings.Movement.JumpPower end
            
            -- CFrame Hızlandırma
            if Settings.Movement.CFrameSpeed then
                local moveDir = humanoid.MoveDirection
                if moveDir.Magnitude > 0 then hrp.CFrame = hrp.CFrame + (moveDir * math.max(Settings.Movement.WalkSpeed, 1) * 0.015) end
            end

            -- Bhop (Yer çekimi kontrolü)
            if (Settings.Movement.AutoBhop and IsHoldingSpace) or IsHoldingMobileBhop then
                if humanoid.FloorMaterial ~= Enum.Material.Air then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end

        -- 2. OTO CANLANMA VE OY KULLANMA
        if Settings.Auto.AutoRevive and character and character:GetAttribute("Downed") then
            if tick() - Settings.Auto.LastReviveCheck >= 5 then
                Settings.Auto.LastReviveCheck = tick()
                ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
            end
        end
        if Settings.Auto.AutoVote then fireVoteServer(Settings.Auto.MapNumber) end

        -- 3. ESP YARATMA KONTROLLERİ (Yeni oyuncu/bot geldi mi?)
        if Settings.ESP.Players then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    CreateESP(p.Character, Color3.new(0.4, 0.8, 0.4), p.Name, p.Character.Head, 1)
                end
            end
        end

        if Settings.ESP.Bots then
            local gameFolder = Workspace:FindFirstChild("Game")
            local botsFolder = gameFolder and gameFolder:FindFirstChild("Players")
            if botsFolder then
                for _, bot in pairs(botsFolder:GetChildren()) do
                    if bot:IsA("Model") and bot:FindFirstChild("Hitbox") then
                        bot.Hitbox.Transparency = 0.5
                        CreateESP(bot, Color3.new(0.8, 0.2, 0.2), bot.Name, bot.Hitbox, -2)
                    end
                end
            end
        end

        -- 4. AKTİF ESP'LERİ GÜNCELLEME SİSTEMİ (Tek Döngü)
        local camPos = workspace.CurrentCamera.CFrame.Position
        for i = #ActiveESPs, 1, -1 do
            local espData = ActiveESPs[i]
            if espData.Target and espData.Target.Parent and espData.Part and espData.Part.Parent then
                if Settings.ESP.ShowDistance then
                    local dist = math.floor((camPos - espData.Part.Position).Magnitude)
                    espData.Label.Text = espData.BaseText .. " [" .. dist .. "m]"
                else
                    espData.Label.Text = espData.BaseText
                end
            else
                -- Obje silindiyse ESP'yi listeden ve ekrandan temizle
                if espData.Highlight then espData.Highlight:Destroy() end
                if espData.Billboard then espData.Billboard:Destroy() end
                table.remove(ActiveESPs, i)
            end
        end
    end))
end

return GameModule
