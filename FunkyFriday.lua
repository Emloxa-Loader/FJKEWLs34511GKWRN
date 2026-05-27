-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY AUTO-PLAYER v20 (HYBRID FLAWLESS CORE)
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
    local NoclipEnabled = false
    
    PlayerTab:CreateToggle("Noclip (Pass Through)", function(s) NoclipEnabled = s end)
    PlayerTab:CreateSlider("WalkSpeed", 16, 250, 16, function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end 
    end)
    PlayerTab:CreateSlider("JumpPower", 50, 350, 50, function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = v end 
    end)

    -- ==========================================
    -- 2. AUTO PLAYER (ADVANCED HYBRID CORE)
    -- ==========================================
    local FunkyTab = Window:CreateTab("Auto Player")
    local AdvancedTab = Window:CreateTab("Advanced") -- İSTEDİĞİN ADVANCED SEKMESİ EKLENDİ
    
    local AutoPlayerEnabled = false
    local ShowVisualizer = false
    local SickRange = 5
    local AutoplayMethod = "Hybrid" -- Varsayılan metod
    
    local LaneKeys = { Lane1 = Enum.KeyCode.A, Lane2 = Enum.KeyCode.S, Lane3 = Enum.KeyCode.W, Lane4 = Enum.KeyCode.D }

    FunkyTab:CreateToggle("Enable Auto Player", function(s) AutoPlayerEnabled = s end)
    FunkyTab:CreateToggle("Show Visualizer Dots", function(s) ShowVisualizer = s end)
    
    -- ADVANCED TAB AYARLARI
    AdvancedTab:CreateDropdown("Autoplay Method", {"Calculate", "Rapid checks", "Hybrid"}, "Hybrid", function(val)
        AutoplayMethod = val
    end)
    AdvancedTab:CreateSlider("Sick Hitbox Range", 1, 30, 5, function(v) SickRange = v end)

    local function ManageVisualizerDot(parentObj, dotName, size, color)
        local dot = parentObj:FindFirstChild(dotName)
        if not dot then
            dot = Instance.new("Frame"); dot.Name = dotName; dot.Size = UDim2.new(0, size, 0, size); dot.Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
            dot.BackgroundColor3 = color; dot.BorderSizePixel = 0; dot.ZIndex = 999999
            Instance.new("UIStroke", dot).Thickness = 2; Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0); dot.Parent = parentObj
        end
        local transparency = ShowVisualizer and 0 or 1
        dot.BackgroundTransparency = transparency; dot.UIStroke.Transparency = transparency
    end

    local TappedNotes = {}
    local CurrentlyPressed = {
        [Enum.KeyCode.A] = false, [Enum.KeyCode.S] = false,
        [Enum.KeyCode.W] = false, [Enum.KeyCode.D] = false
    }
    
    -- Calculate metodu için önceki frame pozisyonlarını tutarız (Hız hesaplamak için)
    local NoteLastPositions = {}

    -- FPS'e bağımlı olmayan, oyunun fizik motoruyla senkronize çalışan Heartbeat kullanıyoruz (Rapid Checks için altın kural)
    RunService.Heartbeat:Connect(function(deltaTime)
        if not AutoPlayerEnabled then
            for _, key in pairs(LaneKeys) do
                if CurrentlyPressed[key] then
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                    CurrentlyPressed[key] = false
                end
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
        
        local inner = ui.Game.Fields[mySide].Inner
        local KeysToPressThisFrame = {}
        local KeysToHoldThisFrame = {}

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
                            
                            local noteTop = note.AbsolutePosition.Y
                            local noteBottom = noteTop + note.AbsoluteSize.Y
                            local noteCenterY = noteTop + (note.AbsoluteSize.Y / 2)
                            local isHoldNote = #note:GetChildren() > 1
                            local distanceToCenter = math.abs(noteCenterY - laneCenterY)

                            -- HIZ HESAPLAMA (Calculate Metodu için)
                            local noteVelocity = 0
                            if NoteLastPositions[note] then
                                noteVelocity = (noteCenterY - NoteLastPositions[note]) / deltaTime
                            end
                            NoteLastPositions[note] = noteCenterY

                            if isHoldNote then
                                -- HOLD (Basılı Tutma) Notaları için Kusursuz Matematik
                                if (noteTop <= laneCenterY + SickRange) and (noteBottom >= laneCenterY - SickRange) then
                                    KeysToHoldThisFrame[laneKey] = true
                                end
                            else
                                -- NORMAL NOTALAR: Seçilen Metoda Göre Algoritma
                                if not TappedNotes[note] or (tick() - TappedNotes[note] > 1.5) then
                                    
                                    if AutoplayMethod == "Rapid checks" then
                                        -- Sadece görsel mesafeye göre acımasız ve hızlı tarama (Senin orijinal mantığının çok hızlısı)
                                        if distanceToCenter <= SickRange then
                                            TappedNotes[note] = tick()
                                            KeysToPressThisFrame[laneKey] = true
                                        end

                                    elseif AutoplayMethod == "Calculate" then
                                        -- Hız (V) = Yol (X) / Zaman (T) denklemi. Notanın merkeze varmasına ne kadar süre kaldığını bul.
                                        if noteVelocity > 0 and distanceToCenter < 150 then -- Sadece yaklaşıyorsa hesapla
                                            local timeToHit = distanceToCenter / noteVelocity
                                            if timeToHit <= (deltaTime * 2) then -- Önümüzdeki 1-2 frame içinde çarpacaksa bas!
                                                TappedNotes[note] = tick()
                                                KeysToPressThisFrame[laneKey] = true
                                            end
                                        end

                                    elseif AutoplayMethod == "Hybrid" then
                                        -- Hem mesafeyi (Rapid) hem hızı (Calculate) birleştirir. En hatasız metod.
                                        local dynamicRange = SickRange
                                        if noteVelocity > 0 then
                                            -- Hız arttıkça hedef kutusunu (SickRange) milisaniyelik gecikmeyi tolere etmesi için dinamik esnet.
                                            dynamicRange = SickRange + (noteVelocity * 0.01)
                                        end
                                        
                                        if distanceToCenter <= dynamicRange then
                                            TappedNotes[note] = tick()
                                            KeysToPressThisFrame[laneKey] = true
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        -- TUŞ GÖNDERİMİ (Sanal Klavye)
        for _, laneKey in pairs(LaneKeys) do
            if KeysToPressThisFrame[laneKey] then
                VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                CurrentlyPressed[laneKey] = true

                -- Tuşu anında bırak (Kusursuz tıklama hissiyatı)
                task.delay(0.01, function()
                    if not KeysToHoldThisFrame[laneKey] then
                        VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                        CurrentlyPressed[laneKey] = false
                    end
                end)
            elseif KeysToHoldThisFrame[laneKey] then
                if not CurrentlyPressed[laneKey] then
                    VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                    CurrentlyPressed[laneKey] = true
                end
            else
                if CurrentlyPressed[laneKey] then
                    VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                    CurrentlyPressed[laneKey] = false
                end
            end
        end
    end)

    -- ==========================================
    -- 3. MISC & CLEANUP
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")
    MiscTab:CreateButton("Clear Cache (Fix Memory)", function() 
        TappedNotes = {} 
        NoteLastPositions = {}
    end)
    MiscTab:CreateButton("Unload EMLOXA", function()
        AutoPlayerEnabled = false
        task.wait(0.1)
        for _, key in pairs(LaneKeys) do VirtualInputManager:SendKeyEvent(false, key, false, game) end
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
