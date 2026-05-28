-- =========================================================================
-- EMLOXA WARE: EVADE (PLACE ID: 9872472334)
-- EMLOXA UI FIX | SIMPLE & STABLE CORE | NO CRASHES
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local VirtualUser = game:GetService("VirtualUser")
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
            AutoBhop = false, EmoteDash = false
        },
        Exploits = { 
            AutoReviveSelf = false, AutoReviveAura = false, 
            AutoVote = false, MapNumber = 1, LastReviveCheck = 0
        },
        Visuals = { 
            PlayerESP = false, BotESP = false, TicketESP = false, DownedColor = true, Distance = true
        },
        World = { 
            FullBright = false, NoFog = false, FOV = 70, ThirdPerson = false 
        },
        Misc = {
            AntiAFK = true
        }
    }

    local IsHoldingSpace = false
    local Camera = Workspace.CurrentCamera

    local OrigLighting = {
        Brightness = Lighting.Brightness,
        Ambient = Lighting.Ambient,
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd
    }

    -- ==========================================
    -- YARDIMCI FONKSİYONLAR (ESP SİSTEMİ)
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
    -- SEKME 1: MOVEMENT (TAMAMEN EMLOXA UI UYUMLU)
    -- ==========================================
    local MoveTab = Window:CreateTab("Movement")
    
    MoveTab:CreateToggle("Enable WalkSpeed", function(s) Settings.Movement.SpeedEnabled = s end)
    MoveTab:CreateSlider("WalkSpeed Value", 16, 150, 25, function(v) Settings.Movement.SpeedValue = v end)
    MoveTab:CreateToggle("Enable JumpPower", function(s) Settings.Movement.JumpEnabled = s end)
    MoveTab:CreateSlider("JumpPower Value", 50, 300, 50, function(v) Settings.Movement.JumpPower = v end)
    MoveTab:CreateToggle("Auto Bhop (Hold Space)", function(s) Settings.Movement.AutoBhop = s end)
    MoveTab:CreateToggle("Emote Dash Spam (G + F)", function(s) Settings.Movement.EmoteDash = s end)

    -- ==========================================
    -- SEKME 2: EXPLOITS
    -- ==========================================
    local ExploitTab = Window:CreateTab("Exploits")
    
    ExploitTab:CreateButton("Instant Revive (Self)", function()
        if LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Downed") then
            ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
        end
    end)
    ExploitTab:CreateToggle("Auto Revive Loop (Self)", function(s) Settings.Exploits.AutoReviveSelf = s end)
    ExploitTab:CreateToggle("Revive Aura (Heals nearby players)", function(s) Settings.Exploits.AutoReviveAura = s end)
    ExploitTab:CreateDropdown("Select Map to Vote", {"Map 1", "Map 2", "Map 3", "Map 4"}, "Map 1", function(opt) 
        Settings.Exploits.MapNumber = tonumber(opt:match("%d+")) 
    end)
    ExploitTab:CreateToggle("Auto Vote Map Loop", function(s) Settings.Exploits.AutoVote = s end)

    -- ==========================================
    -- SEKME 3: VISUALS
    -- ==========================================
    local EspTab = Window:CreateTab("Visuals")
    
    EspTab:CreateToggle("Players ESP", function(s) Settings.Visuals.PlayerESP = s
        if not s then for _, p in pairs(Players:GetPlayers()) do RemoveESP(p.Character) end end
    end)
    EspTab:CreateToggle("Highlight Downed Players (Red)", function(s) Settings.Visuals.DownedColor = s end)
    EspTab:CreateToggle("Show Distance", function(s) Settings.Visuals.Distance = s end)
    EspTab:CreateToggle("NextBots ESP (Wallhack)", function(s) Settings.Visuals.BotESP = s
        if not s then
            local f = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players")
            if f then for _, b in pairs(f:GetChildren()) do RemoveESP(b) end end
        end
    end)
    EspTab:CreateToggle("Ticket / Objective ESP", function(s) Settings.Visuals.TicketESP = s
        if not s then
            local tf = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Tickets")
            if tf then for _, t in pairs(tf:GetChildren()) do RemoveESP(t) end end
        end
    end)

    -- ==========================================
    -- SEKME 4: WORLD
    -- ==========================================
    local WorldTab = Window:CreateTab("World")
    
    WorldTab:CreateToggle("FullBright (See in Dark)", function(s) Settings.World.FullBright = s
        Lighting.Brightness = s and 5 or OrigLighting.Brightness
        Lighting.GlobalShadows = not s
        if s then Lighting.Ambient = Color3.fromRGB(255,255,255) else Lighting.Ambient = OrigLighting.Ambient end
    end)
    WorldTab:CreateToggle("No Fog", function(s) Settings.World.NoFog = s
        Lighting.FogEnd = s and 999999 or OrigLighting.FogEnd
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
    -- SEKME 5: MISC
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")
    
    MiscTab:CreateToggle("Anti-AFK", function(s) Settings.Misc.AntiAFK = s end)
    MiscTab:CreateButton("Unload EMLOXA WARE", function()
        for _, conn in pairs(Connections) do conn:Disconnect() end
        for _, p in pairs(Players:GetPlayers()) do RemoveESP(p.Character) end
        local f = Workspace:FindFirstChild("Game") and Workspace.Game:FindFirstChild("Players")
        if f then for _, b in pairs(f:GetChildren()) do RemoveESP(b) end end
        
        if Camera then Camera.FieldOfView = 70 end
        LocalPlayer.CameraMaxZoomDistance = 128
        LocalPlayer.CameraMinZoomDistance = 0.5
        Lighting.Brightness = OrigLighting.Brightness
        Lighting.GlobalShadows = OrigLighting.GlobalShadows
        Lighting.Ambient = OrigLighting.Ambient
        Lighting.FogEnd = OrigLighting.FogEnd
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
            LocalPlayer.Character.Humanoid.JumpPower = 50
        end

        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)

    -- ==========================================
    -- GİRDİ KONTROLLERİ (INPUTS)
    -- ==========================================
    table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gpe) 
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.Space then IsHoldingSpace = true end
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

    -- ==========================================
    -- ANA MOTOR DÖNGÜSÜ (STABLE CORE)
    -- ==========================================
    table.insert(Connections, RunService.Heartbeat:Connect(function()
        -- 1. KARAKTER VE FİZİK
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                if Settings.Movement.SpeedEnabled then
                    hum.WalkSpeed = Settings.Movement.SpeedValue
                end
                
                if Settings.Movement.JumpEnabled then
                    hum.UseJumpPower = true
                    hum.JumpPower = Settings.Movement.JumpPower
                end

                if Settings.Movement.AutoBhop and IsHoldingSpace and hum.FloorMaterial ~= Enum.Material.Air then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end

                if Settings.Movement.EmoteDash and hum.MoveDirection.Magnitude > 0 then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.G, false, game)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.G, false, game)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                end
            end
        end

        -- 2. OTOMASYON VE EXPLOITS
        if Settings.Exploits.AutoReviveSelf and char and char:GetAttribute("Downed") then
            if tick() - Settings.Exploits.LastReviveCheck >= 3 then
                Settings.Exploits.LastReviveCheck = tick()
                ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
            end
        end

        if Settings.Exploits.AutoReviveAura and char and char:FindFirstChild("HumanoidRootPart") then
            for _, prompt in pairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.ActionText:lower():match("revive") then
                    if prompt.Parent and prompt.Parent:IsA("BasePart") then
                        if (prompt.Parent.Position - char.HumanoidRootPart.Position).Magnitude < 15 then
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

        -- 3. ESP VE GÖRSELLER
        if Settings.Visuals.PlayerESP then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local color = Color3.new(0.4, 0.8, 0.4)
                    local text = p.Name
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

        -- ESP Güncelleyici
        local camPos = Camera and Camera.CFrame.Position or Vector3.new(0,0,0)
        for i = #ActiveESPs, 1, -1 do
            local esp = ActiveESPs[i]
            if esp.Target and esp.Target.Parent and esp.Part and esp.Part.Parent then
                if Settings.Visuals.Distance then
                    local dist = math.floor((camPos - esp.Part.Position).Magnitude)
                    esp.Label.Text = esp.BaseText .. " [" .. dist .. "m]"
                else
                    esp.Label.Text = esp.BaseText
                end
                
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

        if Settings.World.FOV ~= 70 and Camera then Camera.FieldOfView = Settings.World.FOV end
    end))
end

return GameModule
