-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY (4-CORE ENGINE + HYBRID METHODS)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local LocalPlayer = Players.LocalPlayer

    -- ==========================================
    -- 1. LOCAL PLAYER SEKME (HIZ & ZIPLAMA EKLENDİ)
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
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
            LocalPlayer.Character.Humanoid.WalkSpeed = v 
        end 
    end)
    
    PlayerTab:CreateSlider("JumpPower", 50, 350, 50, function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
            LocalPlayer.Character.Humanoid.UseJumpPower = true
            LocalPlayer.Character.Humanoid.JumpPower = v 
        end 
    end)

    -- ==========================================
    -- 2. AUTO PLAYER & ADVANCED
    -- ==========================================
    local FunkyTab = Window:CreateTab("Auto Player")
    local AdvancedTab = Window:CreateTab("Advanced")
    
    local AutoPlayerEnabled = false
    local Aggression = 15 
    local AutoplayMethod = "Hybrid"
    
    local LaneKeys = { Lane1 = Enum.KeyCode.A, Lane2 = Enum.KeyCode.S, Lane3 = Enum.KeyCode.W, Lane4 = Enum.KeyCode.D }
    
    local LaneConnections = {}
    local ActiveHolds = {}
    local TappedNotes = {}
    local NoteLastPositions = {}

    FunkyTab:CreateSlider("Sick Hitbox Range", 5, 50, 15, function(v) Aggression = v end)
    
    -- Görseldeki Metotlar Eklendi
    AdvancedTab:CreateDropdown("Autoplay Method", {"Calculate", "Rapid checks", "Hybrid"}, "Hybrid", function(val) 
        AutoplayMethod = val 
    end)

    -- Görünmez Nokta İşlemi (Hata Verdirmeyen Güvenli Mantık)
    local function EnsureInvisibleDot(note)
        if not note:FindFirstChild("EmloxaTracker") then
            local dot = Instance.new("Frame")
            dot.Name = "EmloxaTracker"
            dot.Size = UDim2.new(0, 5, 0, 5)
            dot.Position = UDim2.new(0.5, -2, 0.5, -2)
            dot.BackgroundTransparency = 1 -- HER ZAMAN 1 (Görünmez)
            dot.BorderSizePixel = 0
            dot.Parent = note
        end
    end

    -- ==========================================
    -- 3. 4-CORE ENGINE (HER ŞERİT İÇİN AYRI BEYİN)
    -- ==========================================
    local function StartLaneEngine(laneIndex, mySide)
        local ui = LocalPlayer.PlayerGui:FindFirstChild("Window")
        local inner = ui and ui:FindFirstChild("Game") and ui.Game:FindFirstChild("Fields") and ui.Game.Fields[mySide].Inner
        if not inner then return end

        local laneFrame = inner:FindFirstChild("Lane" .. laneIndex)
        local laneKey = LaneKeys["Lane" .. laneIndex]
        if not laneFrame or not laneKey then return end

        -- Heartbeat kullanımı Calculate metodu için fiziksel zamanı (deltaTime) verir
        LaneConnections[laneIndex] = RunService.Heartbeat:Connect(function(deltaTime)
            local laneCenterY = laneFrame.AbsolutePosition.Y + (laneFrame.AbsoluteSize.Y / 2)
            local notesFolder = laneFrame:FindFirstChild("Notes")
            
            if notesFolder then
                for _, note in pairs(notesFolder:GetChildren()) do
                    if note:IsA("GuiObject") then
                        -- Noktayı şeffaf olarak entegre et
                        EnsureInvisibleDot(note)

                        local noteTop = note.AbsolutePosition.Y
                        local noteBottom = noteTop + note.AbsoluteSize.Y
                        local noteCenterY = noteTop + (note.AbsoluteSize.Y / 2)
                        local dist = math.abs(noteCenterY - laneCenterY)
                        
                        -- Hız (Velocity) Hesaplama
                        local noteVelocity = 0
                        if NoteLastPositions[note] then
                            noteVelocity = (noteCenterY - NoteLastPositions[note]) / deltaTime
                        end
                        NoteLastPositions[note] = noteCenterY

                        -- Orijinal nota parçası kontrolü (EmloxaTracker hariç)
                        local origChildren = 0
                        for _, c in ipairs(note:GetChildren()) do
                            if c.Name ~= "EmloxaTracker" then origChildren = origChildren + 1 end
                        end
                        local isHoldNote = origChildren > 1

                        -- METOTLARA GÖRE VURUŞ KARARI
                        local shouldHit = false

                        if AutoplayMethod == "Rapid checks" then
                            shouldHit = (dist <= Aggression)
                            
                        elseif AutoplayMethod == "Calculate" then
                            if noteVelocity > 0 and dist < 150 then
                                local timeToHit = dist / noteVelocity
                                -- Önümüzdeki karelerde merkeze varacaksa vur
                                shouldHit = (timeToHit <= (deltaTime * 2))
                            end
                            
                        elseif AutoplayMethod == "Hybrid" then
                            local dynamicRange = Aggression
                            if noteVelocity > 0 then
                                dynamicRange = Aggression + (noteVelocity * 0.015)
                            end
                            shouldHit = (dist <= dynamicRange)
                        end

                        -- FİZİKSEL UYGULAMA (TUŞ BASIMI)
                        if isHoldNote then
                            -- Hold notası
                            if (noteTop <= laneCenterY + Aggression) and (noteBottom >= laneCenterY - Aggression) then
                                if not ActiveHolds[note] then
                                    ActiveHolds[note] = laneKey
                                    VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                end
                            end
                        else
                            -- Normal Nota
                            if shouldHit then
                                if not TappedNotes[note] or (tick() - TappedNotes[note] > 1.0) then
                                    TappedNotes[note] = tick()
                                    
                                    VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                                    VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                    
                                    task.delay(0.015, function()
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
                        end
                    end
                end
            end
            
            -- Biten Hold notalarını temizle
            for holdNote, key in pairs(ActiveHolds) do
                if key == laneKey and not holdNote.Parent then 
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                    ActiveHolds[holdNote] = nil
                end
            end
        end)
    end

    FunkyTab:CreateToggle("Enable 4-Core AutoPlayer", function(s) 
        AutoPlayerEnabled = s 
        if AutoPlayerEnabled then
            local ui = LocalPlayer.PlayerGui:FindFirstChild("Window")
            local scores = ui and ui:FindFirstChild("Game") and ui.Game:FindFirstChild("HUD") and ui.Game.HUD:FindFirstChild("Scores")
            local mySide = nil
            if scores then
                for _, side in pairs({scores.Left, scores.Right}) do
                    if side:FindFirstChild(LocalPlayer.Name) or side:FindFirstChild(LocalPlayer.DisplayName) then mySide = side.Name break end
                end
            end
            
            if mySide then
                for i = 1, 4 do StartLaneEngine(i, mySide) end
            else
                warn("[EMLOXA WARE] Sahneye çıkmalısın!")
            end
        else
            for i = 1, 4 do
                if LaneConnections[i] then LaneConnections[i]:Disconnect(); LaneConnections[i] = nil end
            end
            for _, key in pairs(LaneKeys) do VirtualInputManager:SendKeyEvent(false, key, false, game) end
            ActiveHolds = {}
        end
    end)

    -- ==========================================
    -- 4. MISC & TEMİZLİK
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
        for i = 1, 4 do if LaneConnections[i] then LaneConnections[i]:Disconnect() end end
        for _, key in pairs(LaneKeys) do VirtualInputManager:SendKeyEvent(false, key, false, game) end
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
