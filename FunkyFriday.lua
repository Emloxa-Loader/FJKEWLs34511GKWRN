-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY AUTO-PLAYER MODULE v4 (FIXED SIDE DETECTION)
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
    -- 2. FUNKY FRIDAY: AUTO-PLAYER & DEBUGGER
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
    FunkyTab:CreateToggle("Show Visualizer Dots & Debug", function(s) ShowVisualizer = s end)
    FunkyTab:CreateSlider("Hitbox Tolerance (Pixels)", 5, 100, 25, function(v) HitTolerance = v end)

    local lastDebugPrint = 0
    local function DebugLog(message)
        if ShowVisualizer and tick() - lastDebugPrint > 1 then
            print("[EMLOXA DEBUG] " .. message)
        end
    end

    local function AddVisualizerDot(parentObj, dotName, size, color)
        if not ShowVisualizer then
            if parentObj:FindFirstChild(dotName) then parentObj[dotName]:Destroy() end
            return
        end
        if not parentObj:FindFirstChild(dotName) then
            local dot = Instance.new("Frame")
            dot.Name = dotName
            dot.Size = UDim2.new(0, size, 0, size)
            dot.Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
            dot.BackgroundColor3 = color or Color3.fromRGB(0, 0, 0)
            dot.BorderSizePixel = 0
            dot.ZIndex = 999999
            
            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(255, 255, 255)
            stroke.Thickness = 2
            stroke.Parent = dot
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = dot
            dot.Parent = parentObj
        end
    end

    local TappedNotes = {}
    local ActiveHolds = {}

    RunService.RenderStepped:Connect(function()
        if not AutoPlayerEnabled then return end
        
        local uiWindow = LocalPlayer.PlayerGui:FindFirstChild("Window")
        if not uiWindow then DebugLog("PlayerGui icinde 'Window' bulunamadi!"); return end
        
        local gameUI = uiWindow:FindFirstChild("Game")
        if not gameUI then DebugLog("Window icinde 'Game' bulunamadi!"); return end
        
        -- YENİLENEN TARAF BULMA MANTIĞI (İSME GÖRE ARAMA)
        local mySide = nil
        local hud = gameUI:FindFirstChild("HUD")
        if hud then
            local scores = hud:FindFirstChild("Scores")
            if scores then
                local leftScore = scores:FindFirstChild("Left")
                local rightScore = scores:FindFirstChild("Right")
                
                local function CheckSide(sideFolder)
                    if not sideFolder then return false end
                    
                    -- 1. Objenin direkt kendi adı senin adınsa (örn: Scores.Left.Oyuncuadı)
                    if sideFolder:FindFirstChild(LocalPlayer.Name) or sideFolder:FindFirstChild(LocalPlayer.DisplayName) then 
                        return true 
                    end
                    
                    -- 2. Alt objelerin isimlerinde veya Text değerlerinde varsa
                    for _, obj in pairs(sideFolder:GetDescendants()) do
                        if obj.Name == LocalPlayer.Name or obj.Name == LocalPlayer.DisplayName then return true end
                        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                            if string.find(string.lower(obj.Text), string.lower(LocalPlayer.Name)) or string.find(string.lower(obj.Text), string.lower(LocalPlayer.DisplayName)) then
                                return true
                            end
                        end
                    end
                    return false
                end
                
                if CheckSide(leftScore) then mySide = "Left" 
                elseif CheckSide(rightScore) then mySide = "Right" end
            else
                DebugLog("HUD icinde 'Scores' bulunamadi!")
            end
        else
            DebugLog("Game icinde 'HUD' bulunamadi!")
        end

        if not mySide then DebugLog("Oyuncu tarafi (Left/Right) bulunamadi. Sarki basladi mi?"); return end
        
        local fields = gameUI:FindFirstChild("Fields")
        if not fields then DebugLog("Game icinde 'Fields' bulunamadi!"); return end
        
        local targetField = fields:FindFirstChild(mySide)
        if not targetField then DebugLog("Fields icinde '" .. mySide .. "' bulunamadi!"); return end
        
        local inner = targetField:FindFirstChild("Inner")
        if not inner then DebugLog(mySide .. " icinde 'Inner' bulunamadi!"); return end

        if ShowVisualizer and tick() - lastDebugPrint > 1 then
            print("[EMLOXA DEBUG] SISTEM KUSURSUZ! Taraf: " .. mySide .. " - Notalar Okunuyor...")
            lastDebugPrint = tick()
        end

        -- NOTALARI TARAMA VE VURMA
        for i = 1, 4 do
            local laneName = "Lane" .. i
            local laneFrame = inner:FindFirstChild(laneName)
            
            if laneFrame then
                AddVisualizerDot(laneFrame, "EmloxaTargetDot", 20, Color3.fromRGB(0, 0, 0))
                local laneCenterY = laneFrame.AbsolutePosition.Y + (laneFrame.AbsoluteSize.Y / 2)

                local notesFolder = laneFrame:FindFirstChild("Notes")
                if notesFolder then
                    local laneKey = LaneKeys[laneName]
                    
                    for _, note in pairs(notesFolder:GetChildren()) do
                        if note:IsA("GuiObject") then
                            AddVisualizerDot(note, "EmloxaNoteDot", 14, Color3.fromRGB(50, 50, 50))
                            
                            local noteCenterY = note.AbsolutePosition.Y + (note.AbsoluteSize.Y / 2)
                            local distance = math.abs(noteCenterY - laneCenterY)
                            
                            if distance <= HitTolerance then
                                local isHoldNote = false
                                local frameCount = 0
                                for _, child in pairs(note:GetChildren()) do
                                    if child:IsA("GuiObject") and child.Name ~= "EmloxaNoteDot" then 
                                        frameCount = frameCount + 1 
                                    end
                                end
                                if frameCount > 1 then isHoldNote = true end
                                
                                if isHoldNote then
                                    if not ActiveHolds[note] then
                                        ActiveHolds[note] = laneKey
                                        VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                    end
                                else
                                    if not TappedNotes[note] then
                                        TappedNotes[note] = true
                                        task.spawn(function()
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
            else
                DebugLog("Inner icinde '" .. laneName .. "' bulunamadi!")
            end
        end
        
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
        print("[EMLOXA DEBUG] Cache Temizlendi.")
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
