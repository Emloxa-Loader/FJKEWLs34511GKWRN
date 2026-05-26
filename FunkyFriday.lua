-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY AUTO-PLAYER MODULE v7 (PURE DOT OVERLAP CORE)
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
    -- 2. FUNKY FRIDAY: SAF MERKEZ (DOT) SİSTEMİ
    -- ==========================================
    local FunkyTab = Window:CreateTab("Auto Player")

local AutoPlayerEnabled = false
local ShowVisualizer = false
local HitOffset = 0

local LaneKeys = {
    Lane1 = Enum.KeyCode.A,
    Lane2 = Enum.KeyCode.S,
    Lane3 = Enum.KeyCode.W,
    Lane4 = Enum.KeyCode.D
}

FunkyTab:CreateToggle("Enable Auto Player (Extreme Speed)", function(s) AutoPlayerEnabled = s end)
FunkyTab:CreateToggle("Show Visualizer Dots (Centers)", function(s) ShowVisualizer = s end)
FunkyTab:CreateSlider("Hit Offset (Ping Adjustment)", -50, 50, 0, function(v) HitOffset = v end)

-- Yardımcı görsel nokta
local function ManageVisualizerDot(parentObj, dotName, size, color)
    local dot = parentObj:FindFirstChild(dotName)
    if not ShowVisualizer then
        if dot then dot:Destroy() end
        return
    end
    if not dot then
        dot = Instance.new("Frame")
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

local NotePrevY = {}       -- [note] = previous hit Y (center for tap, top for hold)
local TappedNotes = {}     -- işlenmiş tap notalar
local ActiveHolds = {}     -- { [note] = { key, startTime } }

RunService.RenderStepped:Connect(function()
    if not AutoPlayerEnabled then return end

    local uiWindow = LocalPlayer.PlayerGui:FindFirstChild("Window")
    if not uiWindow then return end

    local gameUI = uiWindow:FindFirstChild("Game")
    if not gameUI then return end

    -- Oyuncu tarafı bulma
    local mySide = nil
    local hud = gameUI:FindFirstChild("HUD")
    if hud then
        local scores = hud:FindFirstChild("Scores")
        if scores then
            local function CheckSide(sideFolder)
                if not sideFolder then return false end
                if sideFolder:FindFirstChild(LocalPlayer.Name) or sideFolder:FindFirstChild(LocalPlayer.DisplayName) then return true end
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
            if CheckSide(scores:FindFirstChild("Left")) then mySide = "Left"
            elseif CheckSide(scores:FindFirstChild("Right")) then mySide = "Right" end
        end
    end

    if not mySide then return end

    local fields = gameUI:FindFirstChild("Fields")
    if not fields then return end
    local targetField = fields:FindFirstChild(mySide)
    if not targetField then return end
    local inner = targetField:FindFirstChild("Inner")
    if not inner then return end

    -- Lane'leri tara
    for i = 1, 4 do
        local laneName = "Lane" .. i
        local laneFrame = inner:FindFirstChild(laneName)
        if laneFrame then
            -- Vuruş noktası (lane ortası) + offset
            local laneCenterY = laneFrame.AbsolutePosition.Y + (laneFrame.AbsoluteSize.Y / 2) + HitOffset
            ManageVisualizerDot(laneFrame, "EmloxaTargetDot", 20, Color3.fromRGB(0, 0, 0))

            local notesFolder = laneFrame:FindFirstChild("Notes")
            if notesFolder then
                local laneKey = LaneKeys[laneName]

                for _, note in pairs(notesFolder:GetChildren()) do
                    if note:IsA("GuiObject") then
                        -- Nota boyutuna göre hold olup olmadığını belirle (uzun dikdörtgen)
                        local absSize = note.AbsoluteSize
                        local isHold = (absSize.Y > absSize.X * 1.3)  -- boyu eninden belirgin büyükse hold

                        local hitY
                        if isHold then
                            hitY = note.AbsolutePosition.Y  -- üst kenar (başlangıç)
                        else
                            hitY = note.AbsolutePosition.Y + (absSize.Y / 2)  -- merkez
                        end

                        -- Görsel nokta (merkez gösterimi)
                        ManageVisualizerDot(note, "EmloxaNoteDot", 14, Color3.fromRGB(50, 50, 50))

                        local prevY = NotePrevY[note]

                        if not isHold then
                            -- TAP NOTA: merkez çizgiyi geçti mi?
                            if prevY and not TappedNotes[note] then
                                if prevY < laneCenterY and hitY >= laneCenterY then
                                    TappedNotes[note] = true
                                    -- Anında bas-çek
                                    task.spawn(function()
                                        VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                        task.delay(0.01, function()
                                            VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                                        end)
                                    end)
                                end
                            end
                        else
                            -- HOLD NOTA: üst kenar çizgiyi geçince bas, alt kenar geçince bırak
                            local bottomY = note.AbsolutePosition.Y + absSize.Y
                            if prevY and not ActiveHolds[note] then
                                if prevY < laneCenterY and hitY >= laneCenterY then
                                    -- HOLD BAŞLANGICI
                                    ActiveHolds[note] = { key = laneKey }
                                    VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                end
                            end
                            if ActiveHolds[note] then
                                -- HOLD BİTİŞ KONTROLÜ
                                if bottomY >= laneCenterY then
                                    VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                                    ActiveHolds[note] = nil
                                end
                            end
                        end

                        -- Güncel konumu sakla
                        NotePrevY[note] = hitY
                    end
                end
            end
        end
    end

    -- Geçersiz notaları temizle
    for note, _ in pairs(NotePrevY) do
        if not note.Parent or not note:IsDescendantOf(gameUI) then
            NotePrevY[note] = nil
            if TappedNotes[note] then TappedNotes[note] = nil end
            if ActiveHolds[note] then
                VirtualInputManager:SendKeyEvent(false, ActiveHolds[note].key, false, game)
                ActiveHolds[note] = nil
            end
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
