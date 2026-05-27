-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY AUTO-PLAYER v21 (ULTRA OPTIMIZED + 10 MODES)
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
    -- 2. AUTO PLAYER (10 MODLU TEST MERKEZİ)
    -- ==========================================
    local FunkyTab = Window:CreateTab("Auto Player")
    local AdvancedTab = Window:CreateTab("Advanced")
    
    local AutoPlayerEnabled = false
    local ShowVisualizer = false
    local Aggression = 20
    local CurrentMode = "1. Emloxa Classic"
    
    local LaneKeys = { Lane1 = Enum.KeyCode.A, Lane2 = Enum.KeyCode.S, Lane3 = Enum.KeyCode.W, Lane4 = Enum.KeyCode.D }

    FunkyTab:CreateToggle("Enable Auto Player (God Mode)", function(s) AutoPlayerEnabled = s end)
    FunkyTab:CreateToggle("Show Visualizer Dots", function(s) ShowVisualizer = s end)
    FunkyTab:CreateSlider("Aggression Range", 5, 80, 20, function(v) Aggression = v end)

    -- İSTEDİĞİN 10 FARKLI SPAM/TEST MODU
    local Modes = {
        "1. Emloxa Classic",        -- Orijinal mantığın lag fixli hali
        "2. Godspeed (Max CPS)",    -- task.wait yok, saniyelik anlık vuruş
        "3. Threaded Strike",       -- Coroutine kullanarak işlemciyi rahatlatır
        "4. Early Predictor",       -- Agresifliğin üst sınırında erken vurur
        "5. Strict Center",         -- Sadece tam merkezdeyse vurur (Hassas)
        "6. Hold Ignorer",          -- Uzun notaları normal nota gibi hızlıca ezer geçer
        "7. Multi-Tap (No Cache)",  -- Önceden basılanları hatırlaMAZ, gördüğüne vurur (Aşırı Spam)
        "8. Rhythm Lock",           -- VIM kilitlenmesini engellemek için hafif gecikmeli
        "9. Bottom-Up Scan",        -- Sadece şeridin en altındaki notaya odaklanır (Ultra FPS)
        "10. Aggressive Overdrive"  -- Aynı nota için birden fazla VIM sinyali yollar (Kaçırma ihtimali %0)
    }
    AdvancedTab:CreateDropdown("Autoplay Logic Mode", Modes, "1. Emloxa Classic", function(val) CurrentMode = val end)

    -- OPTİMİZASYON: Sadece ShowVisualizer açıksa UI oluştur! Yoksa oyunu çökertir.
    local function ManageVisualizerDot(parentObj, dotName, size, color)
        if not ShowVisualizer then 
            local existing = parentObj:FindFirstChild(dotName)
            if existing then existing:Destroy() end
            return 
        end
        
        local dot = parentObj:FindFirstChild(dotName)
        if not dot then
            dot = Instance.new("Frame"); dot.Name = dotName; dot.Size = UDim2.new(0, size, 0, size); dot.Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
            dot.BackgroundColor3 = color; dot.BorderSizePixel = 0; dot.ZIndex = 999999
            Instance.new("UIStroke", dot).Thickness = 2; Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0); dot.Parent = parentObj
        end
        dot.BackgroundTransparency = 0; dot.UIStroke.Transparency = 0
    end

    local TappedNotes = {}
    local ActiveHolds = {}

    -- Vuruş Simülasyonu Fonksiyonu (Modlara göre şekillenir)
    local function ExecuteTap(laneKey, note, dist)
        if CurrentMode == "7. Multi-Tap (No Cache)" then
            -- Cache yok, direkt bas!
        else
            if TappedNotes[note] then return end
            TappedNotes[note] = true
        end

        if CurrentMode == "2. Godspeed (Max CPS)" then
            -- Bekleme süresi olmadan saniyesinde bas-çek
            VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
            VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
            VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
            
        elseif CurrentMode == "3. Threaded Strike" then
            coroutine.wrap(function()
                VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                task.wait(0.01)
                local isHold = false
                for _, k in pairs(ActiveHolds) do if k == laneKey then isHold = true break end end
                if not isHold then VirtualInputManager:SendKeyEvent(false, laneKey, false, game) end
            end)()

        elseif CurrentMode == "10. Aggressive Overdrive" then
            VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
            VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
            VirtualInputManager:SendKeyEvent(true, laneKey, false, game) -- Çifte sinyal garantisi
            task.delay(0.015, function()
                local isHold = false
                for _, k in pairs(ActiveHolds) do if k == laneKey then isHold = true break end end
                if not isHold then VirtualInputManager:SendKeyEvent(false, laneKey, false, game) end
            end)

        else
            -- 1. Emloxa Classic ve Diğerleri
            task.spawn(function()
                VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                
                if CurrentMode == "8. Rhythm Lock" then task.wait(0.02) else task.wait(0.015) end
                
                local isCurrentlyHeld = false
                for activeHoldNote, k in pairs(ActiveHolds) do
                    if k == laneKey and activeHoldNote.Parent then
                        isCurrentlyHeld = true; break
                    end
                end
                if not isCurrentlyHeld then
                    VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                end
            end)
        end
    end

    RunService.RenderStepped:Connect(function()
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
        
        local inner = ui.Game.Fields[mySide].Inner

        -- ADIM 1: HOLD TEMİZLİĞİ
        for holdNote, key in pairs(ActiveHolds) do
            if not holdNote.Parent or not holdNote:IsDescendantOf(game) then 
                VirtualInputManager:SendKeyEvent(false, key, false, game)
                ActiveHolds[holdNote] = nil
            end
        end

        -- ADIM 2: NOTA İŞLEME
        for i = 1, 4 do
            local laneFrame = inner:FindFirstChild("Lane" .. i)
            if laneFrame then
                ManageVisualizerDot(laneFrame, "EmloxaTargetDot", 20, Color3.fromRGB(0, 0, 0))
                local laneCenterY = laneFrame.AbsolutePosition.Y + (laneFrame.AbsoluteSize.Y / 2)
                local notesFolder = laneFrame:FindFirstChild("Notes")
                
                if notesFolder then
                    local laneKey = LaneKeys["Lane" .. i]
                    local notesArray = notesFolder:GetChildren()

                    -- Mod 9 için sadece en sondaki notayı al
                    if CurrentMode == "9. Bottom-Up Scan" and #notesArray > 0 then
                        notesArray = {notesArray[1]}
                    end
                    
                    for _, note in pairs(notesArray) do
                        if note:IsA("GuiObject") then
                            ManageVisualizerDot(note, "EmloxaNoteDot", 14, Color3.fromRGB(50, 50, 50))
                            local noteCenterY = note.AbsolutePosition.Y + (note.AbsoluteSize.Y / 2)
                            local dist = math.abs(noteCenterY - laneCenterY)
                            
                            -- HEDEF ALGILAMA MODLARI
                            local targetReached = false
                            if CurrentMode == "4. Early Predictor" then
                                targetReached = (noteCenterY >= laneCenterY - Aggression and noteCenterY <= laneCenterY)
                            elseif CurrentMode == "5. Strict Center" then
                                targetReached = (dist <= 5)
                            else
                                targetReached = (dist <= Aggression)
                            end
                            
                            if targetReached then
                                local isHoldNote = (#note:GetChildren() > 1)
                                if CurrentMode == "6. Hold Ignorer" then isHoldNote = false end
                                
                                if isHoldNote then
                                    if not ActiveHolds[note] then
                                        ActiveHolds[note] = laneKey
                                        VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                                        VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                    end
                                else
                                    ExecuteTap(laneKey, note, dist)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    -- ==========================================
    -- 3. MISC & CLEANUP
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")
    MiscTab:CreateButton("Clear Cache (Fix Lag)", function() TappedNotes = {}; ActiveHolds = {} end)
    MiscTab:CreateButton("Unload EMLOXA", function()
        AutoPlayerEnabled = false
        task.wait(0.1)
        for _, key in pairs(ActiveHolds) do VirtualInputManager:SendKeyEvent(false, key, false, game) end
        for _, key in pairs(LaneKeys) do VirtualInputManager:SendKeyEvent(false, key, false, game) end
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
