-- =========================================================================
-- EMLOXA WARE: EVADE (PLACE ID: 9872472334)
-- BUILT FROM SCRATCH | VECTOR & CFRAME ENGINE | MAXIMUM FEATURES
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local Workspace = game:GetService("Workspace")
    local Lighting = game:GetService("Lighting")
    local LocalPlayer = Players.LocalPlayer

    -- ==========================================
    -- GLOBAL HAFIZA VE AYARLAR
    -- ==========================================
    local Connections = {}
    local ActiveESPs = {}
    local Settings = {
        Movement = { 
            SpeedEnabled = false, SpeedValue = 25, 
            JumpEnabled = false, JumpPower = 50, 
            InfJump = false, AutoBhop = false, EmoteDash = false
        },
        Exploits = { 
            AutoReviveSelf = false, AutoReviveAura = false, 
            AutoVote = false, MapNumber = 1 
        },
        Visuals = { 
            PlayerESP = false, BotESP = false, TicketESP = false, DownedColor = true 
        },
        World = { 
            FullBright = false, NoFog = false, FOV = 70, ThirdPerson = false 
        }
    }

    local IsHoldingSpace = false
    local Camera = Workspace.CurrentCamera

    -- ==========================================
    -- YARDIMCI FONKSİYONLAR (KUSURSUZ ESP)
    -- ==========================================
    local function CreateESP(target, nameText, color, attachPart, yOffset)
        if not target or not attachPart or target:FindFirstChild("EmloxaESP") then return end

        local highlight = Instance.new("Highlight")
        highlight.Name = "EmloxaESP"
        highlight.Adornee = target; highlight.FillColor = color
        highlight.FillTransparency = 0.5; highlight.OutlineColor = color
        highlight.OutlineTransparency = 0; highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = target

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "EmloxaTextESP"
        billboard.Size = UDim2.new(0, 200, 0, 50); billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, yOffset, 0); billboard.Adornee = attachPart
        billboard.Parent = attachPart

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1
        label.Text = nameText; label.TextColor3 = color
        label.Font = Enum.Font.GothamBold; label.TextSize = 14
        label.TextStrokeTransparency = 0; label.Parent = billboard

        table.insert(ActiveESPs, { Target = target, Part = attachPart, Label = label, BaseText = nameText, Highlight = highlight, Billboard = billboard, DefaultColor = color })
    end

    local function RemoveESP(target)
        if not target then return end
        if target:FindFirstChild("EmloxaESP") then target.EmloxaESP:Destroy() end
        for _, v in pairs(target:GetDescendants()) do if v.Name == "EmloxaTextESP" then v:Destroy() end end
        for i = #ActiveESPs, 1, -1 do if ActiveESPs[i].Target == target then table.remove(ActiveESPs, i) end end
    end

    -- ==========================================
    -- SEKME 1: MOVEMENT (EVADE FİZİKLERİNİ EZEN MOTOR)
    -- ==========================================
    local MoveTab = Window:CreateTab("Movement")
    
    MoveTab:CreateToggle("True Speed (Bypasses Evade)", function(s) Settings.Movement.SpeedEnabled = s end)
    MoveTab:CreateSlider("Speed Multiplier", 1, 100, 25, function(v) Settings.Movement.SpeedValue = v end)
    
    MoveTab:CreateDivider()
    MoveTab:CreateToggle("True Jump (Vector Push)", function(s) Settings.Movement.JumpEnabled = s end)
    MoveTab:CreateSlider("Jump Power", 50, 300, 50, function(v) Settings.Movement.JumpPower = v end)
    MoveTab:CreateToggle("Infinite Jump (Fly basically)", function(s) Settings.Movement.InfJump = s end)
    
    MoveTab:CreateDivider()
    MoveTab:CreateToggle("Auto Bhop (PC/Mobile Hold Jump)", function(s) Settings.Movement.AutoBhop = s end)
    MoveTab:CreateToggle("Emote Dash Spam (OP Speed)", function(s) Settings.Movement.EmoteDash = s end)
    
    -- ==========================================
    -- SEKME 2: EXPLOITS & AUTOMATION
    -- ==========================================
    local ExploitTab = Window:CreateTab("Exploits")
    
    ExploitTab:CreateButton("Instant Revive (Self)", function()
        if LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Downed") then
            ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
        end
    end)
    ExploitTab:CreateToggle("Auto Revive Loop (Self)", function(s) Settings.Exploits.AutoReviveSelf = s end)
    
    ExploitTab:CreateDivider()
    ExploitTab:CreateToggle("Revive Aura (Heals players near you)", function(s) Settings.Exploits.AutoReviveAura = s end)
    
    ExploitTab:CreateDivider()
    ExploitTab:CreateDropdown("Select Map to Vote", {"Map 1", "Map 2", "Map 3", "Map 4"}, "Map 1", function(opt) 
        Settings.Exploits.MapNumber = tonumber(opt:match("%d+")) 
    end)
    ExploitTab:CreateToggle("Auto Vote Map Loop", function(s) Settings.Exploits.AutoVote = s end)

    -- ==========================================
    -- SEKME 3: VISUALS (ESP)
    -- ==========================================
    local EspTab = Window:CreateTab("Visuals")
    
    EspTab:CreateToggle("Players ESP", function(s) Settings.Visuals.PlayerESP = s
        if not s then for _, p in pairs(Players:GetPlayers()) do RemoveESP(p.Character) end end
    end)
    EspTab:CreateToggle("Highlight Downed Players (Red)", function(s) Settings.Visuals.DownedColor = s end)
    
    EspTab:CreateDivider()
    EspTab:CreateToggle("NextBots ESP (Wallhack)", function(s) Settings.Visuals.BotESP = s
        if not s then
            local f = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players")
            if f then for _, b in pairs(f:GetChildren()) do RemoveESP(b) end end
        end
    end)
    
    EspTab:CreateDivider()
    EspTab:CreateToggle("Ticket / Objective ESP", function(s) Settings.Visuals.TicketESP = s
        if not s then
            local tf = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Tickets")
            if tf then for _, t in pairs(tf:GetChildren()) do RemoveESP(t) end end
        end
    end)

    -- ==========================================
    -- SEKME 4: WORLD & LIGHTING
    -- ==========================================
    local WorldTab = Window:CreateTab("World")
    
    WorldTab:CreateToggle("FullBright (See in Dark)", function(s) Settings.World.FullBright = s
        Lighting.Brightness = s and 5 or 1
        Lighting.GlobalShadows = not s
        if s then Lighting.Ambient = Color3.fromRGB(255,255,255) else Lighting.Ambient = Color3.fromRGB(0,0,0) end
    end)
    
    WorldTab:CreateToggle("No Fog", function(s) Settings.World.NoFog = s
        Lighting.FogEnd = s and 999999 or 250
    end)
    
    WorldTab:CreateSlider("Field of View (FOV)", 70, 120, 70, function(v) 
        Settings.World.FOV = v
        if Camera then Camera.FieldOfView = v end
    end)

    WorldTab:CreateToggle("Force Third Person", function(s) Settings.World.ThirdPerson = s
        if s then LocalPlayer.CameraMaxZoomDistance = 15; LocalPlayer.CameraMinZoomDistance = 10
        else LocalPlayer.CameraMaxZoomDistance = 128; LocalPlayer.CameraMinZoomDistance = 0.5 end
    end)

    -- ==========================================
    -- SEKME 5: MISC & UNLOAD
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")
    
    MiscTab:CreateButton("Bypass Anti-Cheat (Spoofer)", function()
        -- Evade WalkSpeed taramalarını bozar
        local mt = getrawmetatable(game)
        setreadonly(mt, false)
        local oldIndex = mt.__index
        hookmetamethod(game, "__index", function(t, k)
            if not checkcaller() and t:IsA("Humanoid") and (k == "WalkSpeed" or k == "JumpPower") then
                return k == "WalkSpeed" and 16 or 50
            end
            return oldIndex(t, k)
        end)
        setreadonly(mt, true)
        print("Emloxa: Evade Anti-Cheat Bypassed!")
    end)

    MiscTab:CreateButton("Unload EMLOXA WARE", function()
        for _, conn in pairs(Connections) do conn:Disconnect() end
        for _, p in pairs(Players:GetPlayers()) do RemoveESP(p.Character) end
        local f = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players")
        if f then for _, b in pairs(f:GetChildren()) do RemoveESP(b) end end
        if Camera then Camera.FieldOfView = 70 end
        LocalPlayer.CameraMaxZoomDistance = 128
        LocalPlayer.CameraMinZoomDistance = 0.5
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)

    -- ==========================================
    -- EMLOXA KUSURSUZ MOTOR (HEARTBEAT & INPUT)
    -- ==========================================

    -- Input Taraması (Bhop & Inf Jump için)
    table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gpe) 
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.Space then 
            IsHoldingSpace = true 
            -- Infinite Jump
            if Settings.Movement.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(
                    LocalPlayer.Character.HumanoidRootPart.Velocity.X, 
                    Settings.Movement.JumpPower, 
                    LocalPlayer.Character.HumanoidRootPart.Velocity.Z
                )
            end
        end
    end))
    
    table.insert(Connections, UserInputService.InputEnded:Connect(function(input) 
        if input.KeyCode == Enum.KeyCode.Space then IsHoldingSpace = false end 
    end))

    table.insert(Connections, RunService.Heartbeat:Connect(function(deltaTime)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        -- 1. HAREKET FİZİKLERİ (C0 Hatalarını ve AC'yi Atlatır)
        if hum and hrp then
            -- True Speed (CFrame Delta ile Evade fiziklerini ezer, asla yürüme animasyonunu bozmaz)
            if Settings.Movement.SpeedEnabled and hum.MoveDirection.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (Settings.Movement.SpeedValue * deltaTime))
            end

            -- True Jump (Oyunun JumpPower sınırını Vektörel Güçle ezer)
            if Settings.Movement.JumpEnabled and IsHoldingSpace and hum.FloorMaterial ~= Enum.Material.Air then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, Settings.Movement.JumpPower, hrp.Velocity.Z)
            end

            -- Auto Bhop
            if Settings.Movement.AutoBhop and IsHoldingSpace and hum.FloorMaterial ~= Enum.Material.Air then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end

            -- Emote Dash Spam (G ve F tuşlarını sanal olarak spamlar)
            if Settings.Movement.EmoteDash and hum.MoveDirection.Magnitude > 0 then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.G, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.G, false, game)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end
        end

        -- 2. OTOMASYON VE EXPLOITS
        if Settings.Exploits.AutoReviveSelf and char and char:GetAttribute("Downed") then
            if tick() - Settings.Exploits.LastReviveCheck >= 3 then
                Settings.Exploits.LastReviveCheck = tick()
                ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
            end
        end

        if Settings.Exploits.AutoReviveAura and hrp then
            -- Çevrendeki tüm Revive (Kaldırma) ProximityPrompt'larını otomatik tetikler
            for _, prompt in pairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.ActionText:lower():match("revive") then
                    if prompt.Parent and prompt.Parent:IsA("BasePart") then
                        if (prompt.Parent.Position - hrp.Position).Magnitude < 15 then
                            fireproximityprompt(prompt)
                        end
                    end
                end
            end
        end

        if Settings.Exploits.AutoVote then
            local events = ReplicatedStorage:FindFirstChild("Events")
            if events and events:FindFirstChild("Player") and events.Player:FindFirstChild("Vote") then
                events.Player.Vote:FireServer(Settings.Exploits.MapNumber)
            end
        end

        -- 3. ESP VE GÖRSELLER (Tek Döngü Optimizasyonu)
        if Settings.Visuals.PlayerESP then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local color = Color3.new(0.4, 0.8, 0.4)
                    local text = p.Name
                    
                    -- Yere Düşen Oyuncuları Kırmızı Göster
                    if Settings.Visuals.DownedColor and p.Character:GetAttribute("Downed") then
                        color = Color3.new(0.9, 0.1, 0.1)
                        text = p.Name .. " [DOWNED]"
                    end
                    
                    CreateESP(p.Character, text, color, p.Character.HumanoidRootPart, 2)
                end
            end
        end

        if Settings.Visuals.BotESP then
            local f = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players")
            if f then
                for _, b in pairs(f:GetChildren()) do
                    if b:IsA("Model") and b:FindFirstChild("Hitbox") then
                        CreateESP(b, b.Name, Color3.new(0.8, 0.2, 0.2), b.Hitbox, 3)
                    end
                end
            end
        end

        if Settings.Visuals.TicketESP then
            local tf = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Tickets")
            if tf then
                for _, t in pairs(tf:GetChildren()) do
                    if t:IsA("BasePart") then
                        CreateESP(t, "Ticket", Color3.fromRGB(255, 215, 0), t, 1)
                    end
                end
            end
        end

        -- ESP Etiketlerini ve Mesafelerini Güncelle
        local camPos = Camera and Camera.CFrame.Position or Vector3.new(0,0,0)
        for i = #ActiveESPs, 1, -1 do
            local esp = ActiveESPs[i]
            if esp.Target and esp.Target.Parent and esp.Part and esp.Part.Parent then
                local dist = math.floor((camPos - esp.Part.Position).Magnitude)
                esp.Label.Text = esp.BaseText .. " [" .. dist .. "m]"
                
                -- Downed renk güncellemesi
                if Settings.Visuals.DownedColor and esp.Target:GetAttribute("Downed") then
                    esp.Highlight.FillColor = Color3.new(0.9, 0.1, 0.1)
                    esp.Label.TextColor3 = Color3.new(0.9, 0.1, 0.1)
                else
                    esp.Highlight.FillColor = esp.DefaultColor
                    esp.Label.TextColor3 = esp.DefaultColor
                end
            else
                if esp.Highlight then esp.Highlight:Destroy() end
                if esp.Billboard then esp.Billboard:Destroy() end
                table.remove(ActiveESPs, i)
            end
        end

        -- FOV Koruması (Evade koşarken FOV'u zorla değiştirir, bunu kilitleriz)
        if Settings.World.FOV ~= 70 and Camera then
            Camera.FieldOfView = Settings.World.FOV
        end
    end))
end

return GameModule
