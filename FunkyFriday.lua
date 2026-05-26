-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY AUTO-PLAYER v9 (ULTRA SPEED & FLAWLESS)
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
    -- 1. LOCAL PLAYER SEKME (GERİ EKLENDİ)
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
    PlayerTab:CreateToggle("Fly Hack (Camera Based)", function(state)
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
    -- 2. FUNKY FRIDAY: KUSURSUZ (EXTREME) AUTO-PLAYER
    -- ==========================================
    local FunkyTab = Window:CreateTab("Auto Player")
    
    local AutoPlayerEnabled = false
    local ShowVisualizer = true -- Görsel noktalar hep açık kalsın istedin
    local HitTolerance = 35 -- Aşırı hızlı tepki için genişletildi
    
    local LaneKeys = {
        Lane1 = Enum.KeyCode.A,
        Lane2 = Enum.KeyCode.S,
        Lane3 = Enum.KeyCode.W,
        Lane4 = Enum.KeyCode.D
    }

    FunkyTab:CreateToggle("Enable Auto Player (Extreme Speed)", function(s) AutoPlayerEnabled = s end)
    FunkyTab:CreateToggle("Show Visualizer Dots", function(s) ShowVisualizer = s end)
    FunkyTab:CreateSlider("Hitbox Sensitivity", 10, 60, 35, function(v) HitTolerance = v end)

    local function AddVisualizerDot(parentObj, dotName, size, color)
        local dot = parentObj:FindFirstChild(dotName)
        if not ShowVisualizer then if dot then dot:Destroy() end return end
        if not dot then
            dot = Instance.new("Frame")
            dot.Name = dotName
            dot.Size = UDim2.new(0, size, 0, size)
            dot.Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
            dot.BackgroundColor3 = color or Color3.fromRGB(0, 0, 0)
            dot.BorderSizePixel = 0
            dot.ZIndex = 999999
            Instance.new("UIStroke", dot).Thickness = 2
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
            dot.Parent = parentObj
        end
    end

    local TappedNotes = {}
    local ActiveHolds = {}

    RunService.RenderStepped:Connect(function()
        if not AutoPlayerEnabled then return end
        
        local ui = LocalPlayer.PlayerGui:FindFirstChild("Window")
        if not ui or not ui:FindFirstChild("Game") or not ui.Game:FindFirstChild("Fields") then return end
        
        local mySide = nil
        local scores = ui.Game:FindFirstChild("HUD") and ui.Game.HUD:FindFirstChild("Scores")
        if scores then
            for _, side in pairs({scores.Left, scores.Right}) do
                if side:FindFirstChild(LocalPlayer.Name) or side:FindFirstChild(LocalPlayer.DisplayName) then mySide = side.Name break end
                for _, obj in pairs(side:GetDescendants()) do
                    if (obj.Name == LocalPlayer.Name or obj.Name == LocalPlayer.DisplayName) then mySide = side.Name break end
                end
            end
        end
        if not mySide then return end
        
        local inner = ui.Game.Fields[mySide].Inner

        -- SÜPER HIZLI TARAMA (TÜM LANELER AYNI ANDA)
        for i = 1, 4 do
            local laneFrame = inner:FindFirstChild("Lane" .. i)
            if laneFrame then
                ManageVisualizerDot(laneFrame, "EmloxaTargetDot", 20, Color3.fromRGB(0, 0, 0))
                local laneCenterY = laneFrame.AbsolutePosition.Y + (laneFrame.AbsoluteSize.Y / 2)
                local notesFolder = laneFrame:FindFirstChild("Notes")
                
                if notesFolder then
                    local laneKey = LaneKeys["Lane" .. i]
                    
                    for _, note in pairs(notesFolder:GetChildren()) do
                        if note:IsA("GuiObject") then
                            ManageVisualizerDot(note, "EmloxaNoteDot", 14, Color3.fromRGB(50, 50, 50))
                            
                            local noteCenterY = note.AbsolutePosition.Y + (note.AbsoluteSize.Y / 2)
                            local dist = math.abs(noteCenterY - laneCenterY)
                            
                            -- HİTBOX: Çok yakınsa VUR
                            if dist <= HitTolerance then
                                local isHoldNote = #note:GetChildren() > 1
                                
                                if isHoldNote then
                                    if not ActiveHolds[note] then
                                        ActiveHolds[note] = laneKey
                                        VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                    end
                                elseif not TappedNotes[note] then
                                    TappedNotes[note] = true
                                    -- SIFIR GECİKME İLE BASIP BIRAKMA
                                    VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                    task.delay(0.01, function()
                                        VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
        
        for holdNote, key in pairs(ActiveHolds) do
            if not holdNote.Parent or not holdNote:IsDescendantOf(game) then 
                VirtualInputManager:SendKeyEvent(false, key, false, game)
                ActiveHolds[holdNote] = nil
            end
        end
    end)

    -- CLEANUP
    local MiscTab = Window:CreateTab("Misc")
    MiscTab:CreateButton("Unload EMLOXA WARE", function()
        for _, key in pairs(ActiveHolds) do VirtualInputManager:SendKeyEvent(false, key, false, game) end
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
