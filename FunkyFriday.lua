-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY AUTO-PLAYER MODULE v2 (VISUALIZER & CENTER MATH)
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
    -- 1. LOCAL PLAYER SEKME SİSTEMİ
    -- ==========================================
    local PlayerTab = Window:CreateTab("Local Player")
    local NoclipEnabled, FlyEnabled = false, false
    local FlySpeed, CurrentSpeed, CurrentJump = 50, 16, 50

    PlayerTab:CreateToggle("Noclip (Pass Through Walls)", function(s) NoclipEnabled = s end)
    PlayerTab:CreateSlider("WalkSpeed Force", 16, 250, 16, function(v)
        CurrentSpeed = v
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end
    end)
    PlayerTab:CreateSlider("JumpPower Force", 50, 350, 50, function(v)
        CurrentJump = v
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = v end
    end)
    PlayerTab:CreateToggle("Fly Hack", function(state)
        FlyEnabled = state
        local Char = LocalPlayer.Character
        local Root = Char and Char:FindFirstChild("HumanoidRootPart")
        local Hum = Char and Char:FindFirstChild("Humanoid")
        if not Root or not Hum then return end
        if FlyEnabled then
            Hum.PlatformStand = true
            local BodyVelocity = Instance.new("BodyVelocity", Root)
            BodyVelocity.Name = "EmloxaFly"; BodyVelocity.Velocity = Vector3.new(0, 0, 0); BodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
            local BodyGyro = Instance.new("BodyGyro", Root)
            BodyGyro.Name = "EmloxaGyro"; BodyGyro.P = 9e4; BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9); BodyGyro.CFrame = Root.CFrame
            task.spawn(function()
                while FlyEnabled and Root and BodyVelocity.Parent do
                    local dir = Vector3.new(0, 0, 0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                    BodyVelocity.Velocity = dir.Unit * FlySpeed
                    if dir == Vector3.new(0, 0, 0) then BodyVelocity.Velocity = Vector3.new(0, 0.1, 0) end
                    BodyGyro.CFrame = Camera.CFrame 
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

    RunService.Stepped:Connect(function()
        local Char = LocalPlayer.Character
        if Char then
            if NoclipEnabled then for _, p in pairs(Char:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end end end
            local Hum = Char:FindFirstChild("Humanoid")
            if Hum and not FlyEnabled then Hum.WalkSpeed = CurrentSpeed; Hum.UseJumpPower = true; Hum.JumpPower = CurrentJump end
        end
    end)

    -- ==========================================
    -- 2. FUNKY FRIDAY: AUTO-PLAYER SİSTEMİ
    -- ==========================================
    local FunkyTab = Window:CreateTab("Auto Player")
    
    local AutoPlayerEnabled = false
    local ShowVisualizer = false
    local HitTolerance = 25 
    
    local LaneKeys = {
        Lane1 = Enum.KeyCode.A,
        Lane2 = Enum.KeyCode.S,
        Lane3 = Enum.KeyCode.W,
        Lane4 = Enum.KeyCode.D
    }

    FunkyTab:CreateToggle("Enable Auto Player (SICK! Mode)", function(s) AutoPlayerEnabled = s end)
    FunkyTab:CreateToggle("Show Visualizer Dots (Debug)", function(s) ShowVisualizer = s end)
    FunkyTab:CreateSlider("Hitbox Tolerance (Pixels)", 5, 100, 25, function(v) HitTolerance = v end)

    local function GetActiveSide()
        local uiWindow = LocalPlayer.PlayerGui:FindFirstChild("Window")
        if uiWindow and uiWindow:FindFirstChild("Game") and uiWindow.Game:FindFirstChild("HUD") then
            local scores = uiWindow.Game.HUD:FindFirstChild("Scores")
            if scores then
                local leftScore = scores:FindFirstChild("Left")
                local rightScore = scores:FindFirstChild("Right")
                
                local function CheckSide(sideFolder)
                    if not sideFolder then return false end
                    for _, obj in pairs(sideFolder:GetDescendants()) do
                        if obj:IsA("TextLabel") and (obj.Text == LocalPlayer.Name or obj.Text == LocalPlayer.DisplayName) then
                            return true
                        end
                    end
                    return false
                end
                
                if CheckSide(leftScore) then return "Left" end
                if CheckSide(rightScore) then return "Right" end
            end
        end
        return nil 
    end

    -- Görselleştirici (Siyah Nokta) Ekleyen Fonksiyon
    local function AddVisualizerDot(parentObj, dotName, size)
        if not ShowVisualizer then
            if parentObj:FindFirstChild(dotName) then parentObj[dotName]:Destroy() end
            return
        end
        
        if not parentObj:FindFirstChild(dotName) then
            local dot = Instance.new("Frame")
            dot.Name = dotName
            dot.Size = UDim2.new(0, size, 0, size)
            dot.Position = UDim2.new(0.5, -size/2, 0.5, -size/2) -- Tam ortalar
            dot.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Siyah
            dot.BorderSizePixel = 0
            dot.ZIndex = 99999
            
            -- Siyah nota siyah arka planda kaybolmasın diye beyaz bir kontur (Stroke) ekliyoruz
            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(255, 255, 255)
            stroke.Thickness = 1.5
            stroke.Parent = dot
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0) -- Yuvarlak
            corner.Parent = dot
            
            dot.Parent = parentObj
        end
    end

    local TappedNotes = {}
    local ActiveHolds = {}

    RunService.RenderStepped:Connect(function()
        if not AutoPlayerEnabled then return end
        
        local mySide = GetActiveSide()
        if not mySide then return end 
        
        local uiWindow = LocalPlayer.PlayerGui:FindFirstChild("Window")
        if not uiWindow then return end
        
        local fields = uiWindow.Game:FindFirstChild("Fields")
        if not fields then return end
        
        local targetField = fields:FindFirstChild(mySide)
        if not targetField or not targetField:FindFirstChild("Inner") then return end

        for i = 1, 4 do
            local laneName = "Lane" .. i
            local laneFrame = targetField.Inner:FindFirstChild(laneName)
            
            if laneFrame then
                -- Lane (Hedef) Merkezine Görsel Nokta Ekle (Büyük Nokta)
                AddVisualizerDot(laneFrame, "EmloxaTargetDot", 16)
                
                -- Lane Merkez Y Koordinatını Hesapla
                local laneCenterY = laneFrame.AbsolutePosition.Y + (laneFrame.AbsoluteSize.Y / 2)

                if laneFrame:FindFirstChild("Notes") then
                    local laneKey = LaneKeys[laneName]
                    
                    for _, note in pairs(laneFrame.Notes:GetChildren()) do
                        if note:IsA("GuiObject") then
                            -- Gelen Nota Merkezine Görsel Nokta Ekle (Küçük Nokta)
                            AddVisualizerDot(note, "EmloxaNoteDot", 12)
                            
                            -- Nota Merkez Y Koordinatını Hesapla
                            local noteCenterY = note.AbsolutePosition.Y + (note.AbsoluteSize.Y / 2)
                            
                            -- Merkezler Arası Gerçek Mesafe (Piksel olarak)
                            local distance = math.abs(noteCenterY - laneCenterY)
                            
                            if distance <= HitTolerance then
                                local isHoldNote = #note:GetChildren() > 1
                                
                                if isHoldNote then
                                    if not ActiveHolds[note] then
                                        ActiveHolds[note] = laneKey
                                        VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                    end
                                else
                                    if not TappedNotes[note] then
                                        TappedNotes[note] = true
                                        task.spawn(function()
                                            -- Ekranda oynamadan önce Roblox'un VIM'i algılaması için çok kısa bir basılı tutma payı
                                            VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                            task.wait(0.02)
                                            VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        -- Basılı tutulan (Hold) notaları bırakma
        for holdNote, key in pairs(ActiveHolds) do
            if not holdNote.Parent then 
                VirtualInputManager:SendKeyEvent(false, key, false, game)
                ActiveHolds[holdNote] = nil
            end
        end
    end)


    -- ==========================================
    -- 3. MISC & CLEANUP
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")
    MiscTab:CreateButton("Clear Note Cache (Fix Lag)", function()
        TappedNotes = {}
        ActiveHolds = {}
    end)
    
    MiscTab:CreateButton("Unload EMLOXA WARE", function()
        AutoPlayerEnabled = false
        ShowVisualizer = false
        FlyEnabled = false
        
        for _, key in pairs(ActiveHolds) do VirtualInputManager:SendKeyEvent(false, key, false, game) end
        ActiveHolds = {}
        TappedNotes = {}
        
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
