-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY V29 (V27 FULL PERFECT CORE + AUTO-KEY SYSTEM)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local LocalPlayer = Players.LocalPlayer

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
    -- 2. AUTO PLAYER (PERFECT ENGINE + AUTO-KEY)
    -- ==========================================
    local FunkyTab = Window:CreateTab("Auto Player")
    local AdvancedTab = Window:CreateTab("Advanced")
    
    local AutoPlayerEnabled = false
    local AutoplayMethod = "Hybrid"
    
    -- DİNAMİK KEYMAP SİSTEMİ (Sol Ok Tuşu = Enum.KeyCode.Left olarak düzeltildi)
    local KeyMaps = {
        [4] = {Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Up, Enum.KeyCode.Right},
        [5] = {Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.Space, Enum.KeyCode.J, Enum.KeyCode.K},
        [6] = {Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L},
        [7] = {Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.Space, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L},
        [8] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L, Enum.KeyCode.Semicolon},
        [9] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.Space, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L, Enum.KeyCode.Semicolon}
    }
    
    -- Dinamik İstatistik Tablosu (1'den 9'a kadar sorunsuz çalışması için hazırlandı)
    local LaneStats = {}
    for i = 1, 9 do LaneStats["Lane"..i] = {Seen = 0, Taps = 0} end
    
    local ActiveHolds = {}
    local TappedNotes = {}
    local CountedNotes = {} 
    local LastYPositions = {} 
    local LastNoteSeenTime = tick()

    FunkyTab:CreateToggle("Enable God Mode (Flawless V29 Auto-Key)", function(s) AutoPlayerEnabled = s end)
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
        if LaneStats[laneName] then
            statLabel.Text = "Seen: " .. LaneStats[laneName].Seen .. " | Taps: " .. LaneStats[laneName].Taps
        end
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

        if dist > 150 then
            dot.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        else
            local intensity = math.clamp(1 - (dist / 150), 0, 1)
            dot.BackgroundColor3 = Color3.fromRGB(0, math.floor(255 * intensity), 0)
        end
    end

    -- ==========================================
    -- MİLİSANİYELİK KUSURSUZ DÖNGÜ
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

        -- Ekranda kaç tane Lane olduğunu dinamik olarak bul
        local laneCount = 0
        for _, obj in pairs(fields:GetChildren()) do 
            if obj.Name:find("Lane") then laneCount = laneCount + 1 end 
        end
        
        -- Eğer desteklenmeyen bir modsa veya lane yoksa işlemi durdur
        if laneCount == 0 or not KeyMaps[laneCount] then return end

        for i = 1, laneCount do
            local laneName = "Lane" .. i
            local laneFrame = fields:FindFirstChild(laneName)
            local laneKey = KeyMaps[laneCount][i]
            
            if laneFrame and laneKey then
                UpdateLaneStats(laneFrame, laneName)
                
                local laneCenterY = laneFrame.AbsolutePosition.Y + (laneFrame.AbsoluteSize.Y / 2)
                local notesFolder = laneFrame:FindFirstChild("Notes")
                
                if notesFolder then
                    for _, note in pairs(notesFolder:GetChildren()) do
                        if note:IsA("GuiObject") then
                            anyNoteSeenThisFrame = true
                            LastNoteSeenTime = tick()

                            local noteTop = note.AbsolutePosition.Y
                            local noteBottom = noteTop + note.AbsoluteSize.Y
                            local noteCenterY = noteTop + (note.AbsoluteSize.Y / 2)
                            local dist = math.abs(noteCenterY - laneCenterY)
                            
                            -- ===============================================
                            -- KUSURSUZ HAFIZA SİLİCİ (TELEPORT ALGILAYICI)
                            -- ===============================================
                            -- Eğer nota bir önceki kareye göre 50 pikselden fazla sıçradıysa ışınlanmıştır!
                            if LastYPositions[note] and math.abs(noteCenterY - LastYPositions[note]) > 50 then
                                CountedNotes[note] = nil
                                TappedNotes[note] = nil
                                ActiveHolds[note] = nil
                            end
                            
                            -- Hız Hesaplama
                            local noteVelocity = 0
                            if LastYPositions[note] then
                                noteVelocity = math.abs(noteCenterY - LastYPositions[note]) / deltaTime
                            end
                            LastYPositions[note] = noteCenterY

                            -- SEEN SAYACI (Doğduğu an tık diye sayar)
                            if not CountedNotes[note] then
                                CountedNotes[note] = true
                                LaneStats[laneName].Seen = LaneStats[laneName].Seen + 1
                            end

                            ManageDynamicDot(note, dist)

                            -- Hold Notası Tespiti
                            local childCount = 0
                            for _, c in ipairs(note:GetChildren()) do
                                if c.Name ~= "EmloxaDynamicDot" then childCount = childCount + 1 end
                            end
                            local isHoldNote = (childCount > 1) or (note.AbsoluteSize.Y > note.AbsoluteSize.X * 1.5)

                            -- V25'in Kusursuz Merkez (Sick) Matematiği
                            local shouldHit = false
                            local frameTravel = noteVelocity * deltaTime
                            
                            if AutoplayMethod == "Rapid checks" then
                                shouldHit = (dist <= 3) 
                            elseif AutoplayMethod == "Calculate" then
                                shouldHit = (dist <= math.max(2, frameTravel / 1.5))
                            elseif AutoplayMethod == "Hybrid" then
                                shouldHit = (dist <= math.max(3, frameTravel / 1.2))
                            end

                            -- VURUŞ İŞLEMLERİ (Şoklama)
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
                                if noteBottom < laneCenterY - 10 then 
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
                
                -- Hata Payı Temizliği
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
            for i=1,9 do LaneStats["Lane"..i] = {Seen=0, Taps=0} end
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
        -- Unload olurken olası basılı kalan tüm tuşları serbest bırak (4-9K arası)
        for _, keys in pairs(KeyMaps) do
            for _, key in pairs(keys) do VirtualInputManager:SendKeyEvent(false, key, false, game) end
        end
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
