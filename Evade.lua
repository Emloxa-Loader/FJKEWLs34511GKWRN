-- =========================================================================
-- EMLOXA WARE: EVADE (PLACE ID: 9872472334)
-- OPNSOURCE PORTED, FIXED & ANTICHEAT BYPASSED
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
    -- 1. ANTICHEAT BYPASS SİSTEMİ (ÖN YÜKLEME)
    -- ==========================================
    -- Evade'in hız ve zıplama hilelerini algılamasını engellemek için oyunun hafızasına sızıyoruz.
    local AntiCheatEnabled = false
    local Hooks = {}
    
    local function SetupAntiCheatBypass()
        if not getrawmetatable then return end
        local mt = getrawmetatable(game)
        local oldIndex = mt.__index
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)

        -- Değerleri (WalkSpeed/JumpPower) oyunun hile korumasına orijinalmiş gibi göster
        Hooks.Index = hookmetamethod(game, "__index", function(t, k)
            if AntiCheatEnabled and not checkcaller() and t:IsA("Humanoid") then
                if k == "WalkSpeed" then return 16 end
                if k == "JumpPower" then return 50 end
            end
            return oldIndex(t, k)
        end)

        -- Oyunun sunucuya "Bu adam hile yapıyor (Kick/Ban)" mesajı göndermesini engelle
        Hooks.Namecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            if AntiCheatEnabled and not checkcaller() and method == "FireServer" and self.Name:lower():find("ban") or self.Name:lower():find("kick") or self.Name:lower():find("log") then
                return nil -- Sunucuya giden raporu yok et
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end
    pcall(SetupAntiCheatBypass)

    -- ==========================================
    -- DEĞİŞKENLER VE HAFIZA YÖNETİMİ
    -- ==========================================
    local Connections = {}
    local ActiveESPs = {}
    local ButtonGui = nil

    local Settings = {
        Movement = { WalkSpeed = 16, SpeedMethod = "CFrame", JumpBoost = false, JumpPower = 50, AutoBhop = false, Gravity = 196.2 },
        Auto = { MapNumber = 1, AutoVote = false, AutoRevive = false, LastReviveCheck = 0 },
        ESP = { Players = false, Bots = false, Distance = false },
        Misc = { AntiAFK = true }
    }

    local IsHoldingSpace = false
    local IsHoldingMobileBhop = false

    local OrigLighting = {
        Brightness = Lighting.Brightness, OutdoorAmbient = Lighting.OutdoorAmbient, Ambient = Lighting.Ambient,
        GlobalShadows = Lighting.GlobalShadows, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
        ColorEnabled = Lighting:FindFirstChild("ColorCorrection") and Lighting.ColorCorrection.Enabled or false,
        Saturation = Lighting:FindFirstChild("ColorCorrection") and Lighting.ColorCorrection.Saturation or 0,
        Contrast = Lighting:FindFirstChild("ColorCorrection") and Lighting.ColorCorrection.Contrast or 0
    }

    -- ==========================================
    -- YARDIMCI FONKSİYONLAR
    -- ==========================================
    local function fireVoteServer(mapIndex)
        local events = ReplicatedStorage:FindFirstChild("Events")
        if events and events:FindFirstChild("Player") and events.Player:FindFirstChild("Vote") then
            events.Player.Vote:FireServer(mapIndex)
        end
    end

    local function CreateESP(target, color, text, attachPart, yOffset)
        if not target or not attachPart or target:FindFirstChild("EmloxaHighlight") then return end

        local highlight = Instance.new("Highlight")
        highlight.Name = "EmloxaHighlight"
        highlight.Adornee = target; highlight.FillColor = color; highlight.FillTransparency = 0.5
        highlight.OutlineColor = color; highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; highlight.Parent = target

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "EmloxaBillboard"
        billboard.Size = UDim2.new(0, 200, 0, 50); billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, yOffset, 0); billboard.Adornee = attachPart; billboard.Parent = attachPart

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1
        label.Text = text; label.TextColor3 = color; label.Font = Enum.Font.GothamBold
        label.TextSize = 14; label.TextStrokeTransparency = 0; label.Parent = billboard

        table.insert(ActiveESPs, { Target = target, Part = attachPart, Label = label, BaseText = text, Highlight = highlight, Billboard = billboard })
    end

    local function RemoveESP(target)
        if not target then return end
        if target:FindFirstChild("EmloxaHighlight") then target.EmloxaHighlight:Destroy() end
        for _, v in pairs(target:GetDescendants()) do if v.Name == "EmloxaBillboard" then v:Destroy() end end
        for i = #ActiveESPs, 1, -1 do if ActiveESPs[i].Target == target then table.remove(ActiveESPs, i) end end
    end

    -- ==========================================
    -- SEKME 0: ANTICHEAT (YENİ)
    -- ==========================================
    local ACTab = Window:CreateTab("Anti-Cheat")
    ACTab:CreateToggle("Enable AC Bypass (Spoofer)", function(s) AntiCheatEnabled = s end)
    ACTab:CreateButton("Clear Local Error Logs", function()
        -- Evade içindeki hata gönderici logları temizler (Ban riskini düşürür)
        for _, v in pairs(LocalPlayer:WaitForChild("PlayerScripts"):GetDescendants()) do
            if v:IsA("LocalScript") and (v.Name:lower():match("log") or v.Name:lower():match("error")) then
                v.Disabled = true
            end
        end
    end)

    -- ==========================================
    -- SEKME 1: MOVEMENT (HATA DÜZELTİLDİ)
    -- ==========================================
    local PlayerTab = Window:CreateTab("Movement")
    
    -- C0 Hatasını çözen Velocity/Heartbeat tabanlı hız motoru
    PlayerTab:CreateDropdown("Speed Engine Mode", {"Velocity (Safe)", "CFrame (Risky)", "WalkSpeed"}, "Velocity (Safe)", function(v) Settings.Movement.SpeedMethod = v end)
    PlayerTab:CreateSlider("Speed Value", 16, 100, 16, function(v) Settings.Movement.WalkSpeed = v end)
    
    PlayerTab:CreateToggle("Enable Custom Jump", function(s) Settings.Movement.JumpBoost = s end)
    PlayerTab:CreateSlider("Jump Power", 50, 300, 50, function(v) Settings.Movement.JumpPower = v end)
    
    PlayerTab:CreateSlider("Gravity", 0, 200, 196, function(v) Settings.Movement.Gravity = v; Workspace.Gravity = v end)
    PlayerTab:CreateButton("Reset Gravity", function() Settings.Movement.Gravity = 196.2; Workspace.Gravity = 196.2 end)
    
    PlayerTab:CreateDivider()
    PlayerTab:CreateToggle("Auto Bhop (Hold Space)", function(s) Settings.Movement.AutoBhop = s end)
    
    PlayerTab:CreateButton("Spawn Mobile Bhop Button", function()
        if ButtonGui then ButtonGui:Destroy() end
        ButtonGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
        ButtonGui.Name = "EmloxaBhop"
        local btn = Instance.new("TextButton", ButtonGui)
        btn.Size = UDim2.new(0, 60, 0, 60); btn.Position = UDim2.new(0.85, 0, 0.75, 0)
        btn.BackgroundColor3 = Color3.fromRGB(102, 85, 255); btn.Text = "BHOP"
        btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.GothamBold; btn.TextScaled = true
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        
        btn.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then IsHoldingMobileBhop = true end end)
        btn.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then IsHoldingMobileBhop = false end end)
    end)

    -- ==========================================
    -- SEKME 2: AUTO
    -- ==========================================
    local AutoTab = Window:CreateTab("Auto")
    
    AutoTab:CreateDropdown("Select Map", {"Map 1", "Map 2", "Map 3", "Map 4"}, "Map 1", function(opt) Settings.Auto.MapNumber = tonumber(opt:match("%d+")) end)
    AutoTab:CreateButton("Vote Map Now", function() fireVoteServer(Settings.Auto.MapNumber) end)
    AutoTab:CreateToggle("Auto Vote Loop", function(s) Settings.Auto.AutoVote = s end)
    
    AutoTab:CreateDivider()
    AutoTab:CreateButton("Revive Yourself Instantly", function()
        if LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Downed") then
            ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
        end
    end)
    AutoTab:CreateToggle("Auto Revive Loop", function(s) Settings.Auto.AutoRevive = s end)

    -- ==========================================
    -- SEKME 3: ESP
    -- ==========================================
    local EspTab = Window:CreateTab("ESP")
    
    EspTab:CreateToggle("Players ESP", function(s)
        Settings.ESP.Players = s
        if not s then for _, p in pairs(Players:GetPlayers()) do RemoveESP(p.Character) end end
    end)
    
    EspTab:CreateToggle("NextBots ESP", function(s)
        Settings.ESP.Bots = s
        if not s then
            local f = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players")
            if f then for _, b in pairs(f:GetChildren()) do RemoveESP(b) end end
        end
    end)
    
    EspTab:CreateToggle("Show Distance", function(s) Settings.ESP.Distance = s end)

    -- ==========================================
    -- SEKME 4: VISUALS & MISC
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")
    
    MiscTab:CreateToggle("Anti-AFK", function(s) Settings.Misc.AntiAFK = s end)
    MiscTab:CreateToggle("Full Brightness", function(s)
        Lighting.Brightness = s and 2 or OrigLighting.Brightness
        Lighting.GlobalShadows = not s
    end)
    MiscTab:CreateToggle("Super Brightness", function(s)
        Lighting.Brightness = s and 15 or OrigLighting.Brightness
        Lighting.GlobalShadows = not s
    end)
    MiscTab:CreateToggle("No Fog", function(s)
        Lighting.FogEnd = s and 1000000 or OrigLighting.FogEnd
    end)
    MiscTab:CreateToggle("Vibrant Colors", function(s)
        if Lighting:FindFirstChild("ColorCorrection") then
            Lighting.ColorCorrection.Enabled = s
            Lighting.ColorCorrection.Saturation = s and 0.8 or OrigLighting.Saturation
        end
    end)
    
    MiscTab:CreateButton("FPS Boost (Potato PC)", function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic
            elseif v:IsA("Decal") then v.Transparency = 1 end
        end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)

    MiscTab:CreateButton("Unload EMLOXA WARE", function()
        for _, conn in pairs(Connections) do conn:Disconnect() end
        for _, p in pairs(Players:GetPlayers()) do RemoveESP(p.Character) end
        local f = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players")
        if f then for _, b in pairs(f:GetChildren()) do RemoveESP(b) end end
        if ButtonGui then ButtonGui:Destroy() end
        Workspace.Gravity = 196.2
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)

    -- ==========================================
    -- ANA MOTOR DÖNGÜSÜ (HEARTBEAT - CRASH FIX)
    -- ==========================================
    table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gpe) if not gpe and input.KeyCode == Enum.KeyCode.Space then IsHoldingSpace = true end end))
    table.insert(Connections, UserInputService.InputEnded:Connect(function(input) if input.KeyCode == Enum.KeyCode.Space then IsHoldingSpace = false end end))

    -- Anti-AFK
    task.spawn(function()
        while task.wait(60) do
            if Settings.Misc.AntiAFK and LocalPlayer then
                VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(0.1); VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end
        end
    end)

    table.insert(Connections, RunService.Heartbeat:Connect(function(deltaTime)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        -- 1. HAREKET VE FİZİK (C0 Hatası burada çözüldü)
        if hum and hrp then
            -- Jump
            if Settings.Movement.JumpBoost then 
                hum.UseJumpPower = true
                hum.JumpPower = Settings.Movement.JumpPower 
            end
            
            -- Speed 
            local speed = Settings.Movement.WalkSpeed
            if speed > 16 then
                local moveDir = hum.MoveDirection
                if Settings.Movement.SpeedMethod == "Velocity (Safe)" then
                    -- Güvenli Fizik İvmesi (C0 Animasyonunu bozmaz)
                    if moveDir.Magnitude > 0 then
                        local currentY = hrp.AssemblyLinearVelocity.Y
                        hrp.AssemblyLinearVelocity = Vector3.new(moveDir.X * speed, currentY, moveDir.Z * speed)
                    end
                elseif Settings.Movement.SpeedMethod == "CFrame (Risky)" then
                    -- Eski riskli metot ama RenderStepped'den çıkartıldığı için çökmeyecek
                    if moveDir.Magnitude > 0 then
                        hrp.CFrame = hrp.CFrame + (moveDir * (speed * deltaTime))
                    end
                elseif Settings.Movement.SpeedMethod == "WalkSpeed" then
                    hum.WalkSpeed = speed
                end
            end

            -- Bhop
            if (Settings.Movement.AutoBhop and IsHoldingSpace) or IsHoldingMobileBhop then
                if hum:GetState() ~= Enum.HumanoidStateType.Jumping and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end

        -- 2. OTOMASYON
        if Settings.Auto.AutoRevive and char and char:GetAttribute("Downed") then
            if tick() - Settings.Auto.LastReviveCheck >= 5 then
                Settings.Auto.LastReviveCheck = tick()
                ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
            end
        end
        if Settings.Auto.AutoVote then fireVoteServer(Settings.Auto.MapNumber) end

        -- 3. ESP YARATICISI
        if Settings.ESP.Players then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    CreateESP(p.Character, Color3.new(0.4, 0.8, 0.4), p.Name, p.Character.Head, 1)
                end
            end
        end

        if Settings.ESP.Bots then
            local f = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players")
            if f then
                for _, b in pairs(f:GetChildren()) do
                    if b:IsA("Model") and b:FindFirstChild("Hitbox") then
                        CreateESP(b, Color3.new(0.8, 0.2, 0.2), b.Name, b.Hitbox, -2)
                    end
                end
            end
        end

        -- 4. ESP GÜNCELLEYİCİSİ (Tekil Döngü Optimizasyonu)
        local camPos = workspace.CurrentCamera.CFrame.Position
        for i = #ActiveESPs, 1, -1 do
            local esp = ActiveESPs[i]
            if esp.Target and esp.Target.Parent and esp.Part and esp.Part.Parent then
                if Settings.ESP.Distance then
                    local d = math.floor((camPos - esp.Part.Position).Magnitude)
                    esp.Label.Text = esp.BaseText .. " [" .. d .. "m]"
                else
                    esp.Label.Text = esp.BaseText
                end
            else
                if esp.Highlight then esp.Highlight:Destroy() end
                if esp.Billboard then esp.Billboard:Destroy() end
                table.remove(ActiveESPs, i)
            end
        end
    end))
end

return GameModule
