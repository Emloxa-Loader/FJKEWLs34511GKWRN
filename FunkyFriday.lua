-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY AUTO-PLAYER MODULE v8 (PRIORITY CORE)
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
    
    -- ==========================================
    -- 2. FUNKY FRIDAY: KUSURSUZ ÖNCELİKLİ (PRIORITY) SİSTEM
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

    FunkyTab:CreateToggle("Enable Auto Player (Extreme)", function(s) AutoPlayerEnabled = s end)
    FunkyTab:CreateToggle("Show Visualizer Dots", function(s) ShowVisualizer = s end)
    FunkyTab:CreateSlider("Hit Offset (Ping Adjustment)", -50, 50, 0, function(v) HitOffset = v end)

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

    local TappedNotes = {}
    local ActiveHolds = {}

    RunService.RenderStepped:Connect(function()
        if not AutoPlayerEnabled then return end
        
        local uiWindow = LocalPlayer.PlayerGui:FindFirstChild("Window")
        if not uiWindow then return end
        local gameUI = uiWindow:FindFirstChild("Game")
        if not gameUI then return end
        
        -- Tarafları bulma
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
        local inner = gameUI:FindFirstChild("Fields"):FindFirstChild(mySide):FindFirstChild("Inner")
        if not inner then return end

        for i = 1, 4 do
            local laneName = "Lane" .. i
            local laneFrame = inner:FindFirstChild(laneName)
            if laneFrame then
                ManageVisualizerDot(laneFrame, "EmloxaTargetDot", 20, Color3.fromRGB(0, 0, 0))
                local laneCenterY = laneFrame.AbsolutePosition.Y + (laneFrame.AbsoluteSize.Y / 2) + HitOffset
                local notesFolder = laneFrame:FindFirstChild("Notes")
                
                if notesFolder then
                    -- 1. Sütundaki tüm notaları al
                    local allNotes = notesFolder:GetChildren()
                    
                    -- 2. SIRALAMA (Önceliklendirme): Yüksek Y değerine göre sırala (en yakın olan en başta)
                    table.sort(allNotes, function(a, b)
                        return a.AbsolutePosition.Y > b.AbsolutePosition.Y
                    end)
                    
                    for _, note in ipairs(allNotes) do
                        if note:IsA("GuiObject") then
                            ManageVisualizerDot(note, "EmloxaNoteDot", 14, Color3.fromRGB(50, 50, 50))
                            local noteCenterY = note.AbsolutePosition.Y + (note.AbsoluteSize.Y / 2)
                            local distance = math.abs(noteCenterY - laneCenterY)
                            
                            -- HİTBOX (Tam Kesim)
                            if distance <= 10 then
                                local isHoldNote = #note:GetChildren() > 1
                                local laneKey = LaneKeys[laneName]
                                
                                if isHoldNote then
                                    if not ActiveHolds[note] then
                                        ActiveHolds[note] = laneKey
                                        VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                    end
                                else
                                    if not TappedNotes[note] then
                                        TappedNotes[note] = true
                                        -- Anında Vuruş
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
        end
        
        -- Hold Kontrolü
        for holdNote, key in pairs(ActiveHolds) do
            if not holdNote.Parent or not holdNote:IsDescendantOf(game) then 
                VirtualInputManager:SendKeyEvent(false, key, false, game)
                ActiveHolds[holdNote] = nil
            end
        end
    end)

    -- ==========================================
    -- 3. MISC & CLEANUP
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")
    MiscTab:CreateButton("Unload EMLOXA WARE", function()
        AutoPlayerEnabled = false
        for _, key in pairs(ActiveHolds) do VirtualInputManager:SendKeyEvent(false, key, false, game) end
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
