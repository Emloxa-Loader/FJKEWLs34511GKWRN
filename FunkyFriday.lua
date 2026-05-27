-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY V26 (ABSOLUTE FLAWLESS & GHOST-WIPE CORE)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- ==========================================
    -- 1. LOCAL PLAYER SEKME
    -- ==========================================
    local PlayerTab = Window:CreateTab("Local Player")
    
    PlayerTab:CreateToggle("Noclip (Pass Through)", function(s) 
        RunService.Stepped:Connect(function() 
            if s and LocalPlayer.Character then 
                for _, p in pairs(LocalPlayer.Character:GetDescendants()) do 
                    if p:IsA("BasePart") then p.CanCollide = false end 
                end 
            end 
        end)
    end)
    PlayerTab:CreateSlider("WalkSpeed", 16, 250, 16, function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end 
    end)
    PlayerTab:CreateSlider("JumpPower", 50, 350, 50, function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
            LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = v 
        end 
    end)

    -- ==========================================
    -- 2. AUTO PLAYER (GHOST-WIPE ENGINE)
    -- ==========================================
    local FunkyTab = Window:CreateTab("Auto Player")
    local AdvancedTab = Window:CreateTab("Advanced")
    
    local AutoPlayerEnabled = false
    local AutoplayMethod = "Hybrid"
    
    local LaneKeys = { Lane1 = Enum.KeyCode.A, Lane2 = Enum.KeyCode.S, Lane3 = Enum.KeyCode.W, Lane4 = Enum.KeyCode.D }
    
    local LaneStats = {
        Lane1 = {Seen = 0, Taps = 0}, Lane2 = {Seen = 0, Taps = 0},
        Lane3 = {Seen = 0, Taps = 0}, Lane4 = {Seen = 0, Taps = 0}
    }
    
    local ActiveHolds = {}
    local TappedNotes = {}
    local CountedNotes = {} 
    local LastYPositions = {} 
    local LastNoteSeenTime = tick()

    FunkyTab:CreateToggle("Enable God Mode (No Miss Guarantee)", function(s) AutoPlayerEnabled = s end)
    AdvancedTab:CreateDropdown("Autoplay Method", {"Calculate", "Rapid checks", "Hybrid"}, "Hybrid", function(val) AutoplayMethod = val end)

    local function UpdateLaneStats(laneFrame, laneName)
        local statLabel = laneFrame:FindFirstChild("EmloxaStats")
        if not statLabel then
            statLabel = Instance.new("TextLabel")
            statLabel.Name = "EmloxaStats"
            statLabel.Size = UDim2.new(1, 0, 0, 30)
            statLabel.Position = UDim2.new(0, 0, 0, -35)
            statLabel.BackgroundTransparency = 1
            statLabel.Font = Enum.Font.GothamBold
            statLabel.TextSize = 13
            statLabel.TextColor3 = Color3.fromRGB(102, 85, 255)
            statLabel.TextStrokeTransparency = 0
            statLabel.Parent = laneFrame
        end
        statLabel.Text = "Seen: " .. LaneStats[laneName].Seen .. " | Taps: " .. LaneStats[laneName].Taps
    end

    local function ManageDynamicDot(note, dist)
        local dot = note:FindFirstChild("EmloxaDynamicDot")
        if not dot then
            dot = Instance.new("Frame")
            dot.Name = "EmloxaDynamicDot"
            dot.Size = UDim2.new(0, 8, 0, 8)
            dot.Position = UDim2.new(0.5, -4, 0.5, -4)
            dot.BorderSizePixel = 0
            dot.ZIndex = 999999
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
            dot.Parent = note
        end

        if dist > 200 then
            dot.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        else
            local intensity = math.clamp(1 - (dist / 200), 0, 1)
            dot.BackgroundColor3 = Color3.fromRGB(0, math.floor(255 * intensity), 0)
        end
    end

    -- ==========================================
    -- MİLİSANİYELİK KUSURSUZ TARAMA DÖNGÜSÜ
    -- ==========================================
    RunService.RenderStepped:Connect(function(deltaTime)
        if not AutoPlayerEnabled then return end
        
        local ui = LocalPlayer.PlayerGui:FindFirstChild("Window")
        if not ui or not ui:FindFirstChild("Game") or not ui.Game:FindFirstChild("Fields") then return end
        
        local mySide = nil
        local scores = ui.Game:FindFirstChild("HUD") and ui.Game.HUD:FindFirstChild("Scores")
        if scores then
            for _, side in pairs({scores.Left, scores.Right}) do
                if side:FindFirstChild(LocalPlayer.Name) or side:FindFirstChild(LocalPlayer.DisplayName) then mySide = side.Name break end
            end
        end
        if not mySide then return end
        
        local fields = ui.Game.Fields[mySide].Inner
        local anyNoteSeenThisFrame = false

        for i = 1, 4 do
            local laneName = "Lane" .. i
            local laneFrame = fields:FindFirstChild(laneName)
            local laneKey = LaneKeys[laneName]
            
            if laneFrame then
                UpdateLaneStats(laneFrame, laneName)
                
                local laneCenterY = laneFrame.AbsolutePosition.Y + (laneFrame.AbsoluteSize.Y / 2)
                local notesFolder = laneFrame:FindFirstChild("Notes")
                
                if notesFolder then
                    for _, note in pairs(notesFolder:GetChildren()) do
                        if note:IsA("GuiObject") then
                            local noteTop = note.AbsolutePosition.Y
                            local noteBottom = noteTop + note.AbsoluteSize.Y
                            local noteCenterY = noteTop + (note.AbsoluteSize.Y / 2)
                            local dist = math.abs(noteCenterY - laneCenterY)

                            -- ===============================================
                            -- 1. DEPO (WIPE) KONTROLÜ - HAYALET NOTA ÇÖZÜMÜ
                            -- ===============================================
                            -- Eğer nota merkeze 1000 pikselden daha uzaksa (oyun onu saklıyorsa) hafızasını tamamen sil!
                            if dist > 1000 then
                                if CountedNotes[note] then
                                    CountedNotes[note] = nil
                                    TappedNotes[note] = nil
                                    ActiveHolds[note] = nil
                                    LastYPositions[note] = nil
                                end
                                continue -- Bu notayı çok uzakta olduğu için işlemeye gerek yok
                            end

                            -- Eğer buraya ulaştıysa nota 1000 pikselin içine (ekrana) girmiştir.
                            anyNoteSeenThisFrame = true
                            LastNoteSeenTime = tick()

                            -- ===============================================
                            -- 2. SEEN SAYACI (ANINDA YAKALAMA)
                            -- ===============================================
                            if not CountedNotes[note] then
                                CountedNotes[note] = true
                                LaneStats[laneName].Seen = LaneStats[laneName].Seen + 1
                            end

                            ManageDynamicDot(note, dist)
                            
                            local noteVelocity = 0
                            if LastYPositions[note] then
                                noteVelocity = math.abs(noteCenterY - LastYPositions[note]) / deltaTime
                            end
                            LastYPositions[note] = noteCenterY

                            local childCount = 0
                            for _, c in ipairs(note:GetChildren()) do
                                if c.Name ~= "EmloxaDynamicDot" then childCount = childCount + 1 end
                            end
                            local isHoldNote = (childCount > 1) or (note.AbsoluteSize.Y > note.AbsoluteSize.X * 1.5)

                            -- ===============================================
                            -- 3. VURUŞ MATEMATİĞİ (SICK GARANTİSİ)
                            -- ===============================================
                            local shouldHit = false
                            local frameTravel = noteVelocity * deltaTime
                            
                            if AutoplayMethod == "Rapid checks" then
                                shouldHit = (dist <= 3)
                            elseif AutoplayMethod == "Calculate" then
                                shouldHit = (dist <= math.max(2, frameTravel / 1.2))
                            elseif AutoplayMethod == "Hybrid" then
                                shouldHit = (dist <= math.max(3, frameTravel))
                            end

                            -- ===============================================
                            -- 4. TUŞ ŞOKLAMA (Sıfır Gecikme)
                            -- ===============================================
                            if shouldHit and not TappedNotes[note] then
                                TappedNotes[note] = true
                                LaneStats[laneName].Taps = LaneStats[laneName].Taps + 1
                                
                                if isHoldNote then
                                    ActiveHolds[note] = laneKey
                                    task.spawn(function()
                                        VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                    end)
                                else
                                    task.spawn(function()
                                        VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                                        VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                        
                                        task.wait(0.01)
                                        
                                        local isHolding = false
                                        for hNote, k in pairs(ActiveHolds) do
                                            if k == laneKey and hNote.Parent then isHolding = true break end
                                        end
                                        if not isHolding then
                                            VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                                        end
                                    end)
                                end
                            end
                            
                            -- Hold Notası Kuyruk Bırakma
                            if isHoldNote and TappedNotes[note] then
                                if noteBottom < laneCenterY - 15 then 
                                    if ActiveHolds[note] then
                                        task.spawn(function()
                                            VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                                        end)
                                        ActiveHolds[note] = nil
                                    end
                                end
                            end
                        end
                    end
                end
                
                for holdNote, key in pairs(ActiveHolds) do
                    if key == laneKey and not holdNote.Parent then 
                        task.spawn(function()
                            VirtualInputManager:SendKeyEvent(false, key, false, game)
                        end)
                        ActiveHolds[holdNote] = nil
                    end
                end
            end
        end

        -- ==========================================
        -- OTOMATİK SIFIRLAMA (Şarkı Bitişi)
        -- ==========================================
        if not anyNoteSeenThisFrame and (tick() - LastNoteSeenTime > 2.5) then
            for i=1,4 do LaneStats["Lane"..i] = {Seen=0, Taps=0} end
            TappedNotes = {}
            CountedNotes = {}
            LastYPositions = {}
            
            for holdNote, key in pairs(ActiveHolds) do
                VirtualInputManager:SendKeyEvent(false, key, false, game)
            end
            ActiveHolds = {}
            LastNoteSeenTime = tick()
        end
    end)

    -- ==========================================
    -- 3. MISC & OPTIMIZATION
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")

    MiscTab:CreateButton("Optimize Graphics (MAX FPS)", function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false
            elseif v:IsA("BasePart") and (v.Material == Enum.Material.Glass or v.Material == Enum.Material.Neon) then v.Material = Enum.Material.SmoothPlastic end
        end
        game:GetService("Lighting").GlobalShadows = false
    end)

    MiscTab:CreateButton("Unload EMLOXA", function()
        AutoPlayerEnabled = false
        for _, key in pairs(LaneKeys) do VirtualInputManager:SendKeyEvent(false, key, false, game) end
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
