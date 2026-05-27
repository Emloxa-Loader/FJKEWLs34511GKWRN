-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY FINAL CORE (ULTIMATE 4K-9K SUPPORT)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local LocalPlayer = Players.LocalPlayer

    -- ==========================================
    -- 1. KEYMAP (TÜM MODLAR İÇİN EKSİKSİZ)
    -- ==========================================
    local KeyMaps = {
        [4] = {Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Up, Enum.KeyCode.Right},
        [5] = {Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.Space, Enum.KeyCode.J, Enum.KeyCode.K},
        [6] = {Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L},
        [7] = {Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.Space, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L},
        [8] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L, Enum.KeyCode.Semicolon},
        [9] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.Space, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L, Enum.KeyCode.Semicolon}
    }

    -- ==========================================
    -- 2. AUTO PLAYER (DEVASA HESAPLAMA MOTORU)
    -- ==========================================
    local FunkyTab = Window:CreateTab("Auto Player")
    local AutoPlayerEnabled = false
    
    local ActiveHolds = {}
    local TappedNotes = {}
    local CountedNotes = {} 
    local LastYPositions = {} 
    local LastNoteSeenTime = tick()
    local LaneStats = {}

    -- Her maç başı istatistikleri sıfırlayan yardımcı fonksiyon
    local function ResetStats(laneCount)
        LaneStats = {}
        for i = 1, laneCount do
            LaneStats["Lane" .. i] = {Seen = 0, Taps = 0}
        end
    end

    FunkyTab:CreateToggle("Enable Auto Player (Full Engine)", function(s) AutoPlayerEnabled = s end)

    RunService.RenderStepped:Connect(function(deltaTime)
        if not AutoPlayerEnabled then 
            for holdNote, key in pairs(ActiveHolds) do
                VirtualInputManager:SendKeyEvent(false, key, false, game)
                ActiveHolds[holdNote] = nil
            end
            return 
        end
        
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
        
        -- Dinamik Lane Algılama
        local laneCount = 0
        for _, obj in pairs(fields:GetChildren()) do if obj.Name:find("Lane") then laneCount = laneCount + 1 end end
        if laneCount == 0 or not KeyMaps[laneCount] then return end
        
        -- İstatistik tablosu boşsa başlat
        if #LaneStats == 0 then ResetStats(laneCount) end

        for i = 1, laneCount do
            local laneName = "Lane" .. i
            local laneFrame = fields:FindFirstChild(laneName)
            local laneKey = KeyMaps[laneCount][i]
            
            if laneFrame and laneKey then
                -- Şerit Üstü İstatistik UI
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
                statLabel.Text = "Seen: " .. (LaneStats[laneName] and LaneStats[laneName].Seen or 0) .. " | Taps: " .. (LaneStats[laneName] and LaneStats[laneName].Taps or 0)

                local laneCenterY = laneFrame.AbsolutePosition.Y + (laneFrame.AbsoluteSize.Y / 2)
                local notesFolder = laneFrame:FindFirstChild("Notes")
                
                if notesFolder then
                    for _, note in pairs(notesFolder:GetChildren()) do
                        if note:IsA("GuiObject") then
                            local noteTop = note.AbsolutePosition.Y
                            local noteBottom = noteTop + note.AbsoluteSize.Y
                            local noteCenterY = noteTop + (note.AbsoluteSize.Y / 2)
                            local dist = math.abs(noteCenterY - laneCenterY)
                            
                            -- Işınlanma/Object Pooling Koruması
                            if LastYPositions[note] and math.abs(noteCenterY - LastYPositions[note]) > 50 then
                                TappedNotes[note] = nil
                            end
                            LastYPositions[note] = noteCenterY

                            -- Seen Sayacı
                            if not CountedNotes[note] then
                                CountedNotes[note] = true
                                if LaneStats[laneName] then LaneStats[laneName].Seen = LaneStats[laneName].Seen + 1 end
                            end

                            -- Hold Notası Tespiti
                            local childCount = 0
                            for _, c in ipairs(note:GetChildren()) do if c:IsA("GuiObject") then childCount = childCount + 1 end end
                            local isHoldNote = childCount > 1 or (note.AbsoluteSize.Y > note.AbsoluteSize.X * 1.5)

                            -- Vuruş (Kusursuz Merkez)
                            if dist <= 3 and not TappedNotes[note] then
                                TappedNotes[note] = tick()
                                if LaneStats[laneName] then LaneStats[laneName].Taps = LaneStats[laneName].Taps + 1 end
                                
                                if isHoldNote then
                                    ActiveHolds[note] = laneKey
                                    task.spawn(function() VirtualInputManager:SendKeyEvent(true, laneKey, false, game) end)
                                else
                                    task.spawn(function()
                                        VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                                        VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                        task.wait(0.01)
                                        VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                                    end)
                                end
                            end

                            -- Hold Notası Bırakma
                            if isHoldNote and TappedNotes[note] then
                                if noteBottom < laneCenterY - 10 then 
                                    if ActiveHolds[note] then
                                        task.spawn(function() VirtualInputManager:SendKeyEvent(false, laneKey, false, game) end)
                                        ActiveHolds[note] = nil
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- Hafıza Temizliği
                for holdNote, key in pairs(ActiveHolds) do
                    if key == laneKey and not holdNote.Parent then 
                        task.spawn(function() VirtualInputManager:SendKeyEvent(false, key, false, game) end)
                        ActiveHolds[holdNote] = nil
                    end
                end
            end
        end

        -- Otomatik Sıfırlama
        if (tick() - LastNoteSeenTime > 2.5) then
            ResetStats(laneCount)
            TappedNotes = {}
            CountedNotes = {}
            LastYPositions = {}
            ActiveHolds = {}
            LastNoteSeenTime = tick()
        end
    end)

    -- ==========================================
    -- 4. MISC & OPTIMIZATION
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

    MiscTab:CreateButton("Unload EMLOXA WARE", function()
        AutoPlayerEnabled = false
        for _, keys in pairs(KeyMaps) do
            for _, key in pairs(keys) do VirtualInputManager:SendKeyEvent(false, key, false, game) end
        end
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
