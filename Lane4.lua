-- =========================================================================
-- EMLOXA WARE: LANE ENGINE (BAĞIMSIZ ÇEKİRDEK)
-- =========================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- BU SCRIPT HANGİ ŞERİDİ YÖNETECEK? (BUNU DEĞİŞTİR)
-- ==========================================
local TARGET_LANE = 4
local TARGET_KEY = Enum.KeyCode.D

-- Hafıza Yönetimi
local ActiveHolds = {}
local TappedNotes = {}
local NoteLastPositions = {}

-- Küçültülmüş ve Her Zaman Görünür Nokta Ekleme
local function EnsureDot(note)
    if not note:FindFirstChild("EmloxaDot") then
        local dot = Instance.new("Frame")
        dot.Name = "EmloxaDot"
        dot.Size = UDim2.new(0, 8, 0, 8) -- Daha küçük (Eskiden 14'tü)
        dot.Position = UDim2.new(0.5, -4, 0.5, -4)
        dot.BackgroundColor3 = Color3.fromRGB(102, 85, 255) -- EMLOXA Moru
        dot.BorderSizePixel = 0
        dot.BackgroundTransparency = 0 -- HER ZAMAN GÖRÜNÜR
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = dot
        
        dot.Parent = note
    end
end

-- ==========================================
-- ANA MOTOR DÖNGÜSÜ (FULL GÜÇ ODAKLI)
-- ==========================================
RunService.Heartbeat:Connect(function(deltaTime)
    -- ANA ŞALTER KONTROLÜ (_G üzerinden Master Controller'ı dinler)
    if not _G.EmloxaAutoPlay then
        for holdNote, key in pairs(ActiveHolds) do
            VirtualInputManager:SendKeyEvent(false, key, false, game)
            ActiveHolds[holdNote] = nil
        end
        return 
    end
    
    local ui = LocalPlayer.PlayerGui:FindFirstChild("Window")
    local inner = ui and ui:FindFirstChild("Game") and ui.Game:FindFirstChild("Fields")
    if not inner then return end
    
    local mySide = nil
    local scores = ui.Game:FindFirstChild("HUD") and ui.Game.HUD:FindFirstChild("Scores")
    if scores then
        for _, side in pairs({scores.Left, scores.Right}) do
            if side:FindFirstChild(LocalPlayer.Name) or side:FindFirstChild(LocalPlayer.DisplayName) then mySide = side.Name break end
        end
    end
    if not mySide then return end
    
    local laneFrame = inner[mySide].Inner:FindFirstChild("Lane" .. TARGET_LANE)
    if not laneFrame then return end

    local laneCenterY = laneFrame.AbsolutePosition.Y + (laneFrame.AbsoluteSize.Y / 2)
    local notesFolder = laneFrame:FindFirstChild("Notes")
    
    if notesFolder then
        for _, note in pairs(notesFolder:GetChildren()) do
            if note:IsA("GuiObject") then
                EnsureDot(note)

                local noteTop = note.AbsolutePosition.Y
                local noteBottom = noteTop + note.AbsoluteSize.Y
                local noteCenterY = noteTop + (note.AbsoluteSize.Y / 2)
                local dist = math.abs(noteCenterY - laneCenterY)
                
                -- Hız Hesaplama (Calculate ve Hybrid için)
                local noteVelocity = 0
                if NoteLastPositions[note] then
                    noteVelocity = (noteCenterY - NoteLastPositions[note]) / deltaTime
                end
                NoteLastPositions[note] = noteCenterY

                local isHoldNote = false
                local childCount = 0
                for _, c in ipairs(note:GetChildren()) do
                    if c.Name ~= "EmloxaDot" then childCount = childCount + 1 end
                end
                isHoldNote = childCount > 1

                -- Global ayarlara göre mesafe hesaplama
                local aggression = _G.EmloxaAggression or 15
                local method = _G.EmloxaMethod or "Hybrid"
                local shouldHit = false

                if method == "Rapid checks" then
                    shouldHit = (dist <= aggression)
                elseif method == "Calculate" then
                    if noteVelocity > 0 and dist < 150 then
                        local timeToHit = dist / noteVelocity
                        shouldHit = (timeToHit <= (deltaTime * 2))
                    end
                elseif method == "Hybrid" then
                    local dynamicRange = aggression
                    if noteVelocity > 0 then dynamicRange = aggression + (noteVelocity * 0.015) end
                    shouldHit = (dist <= dynamicRange)
                end

                -- Vuruş Mantığı
                if isHoldNote then
                    if (noteTop <= laneCenterY + aggression) and (noteBottom >= laneCenterY - aggression) then
                        if not ActiveHolds[note] then
                            ActiveHolds[note] = TARGET_KEY
                            VirtualInputManager:SendKeyEvent(true, TARGET_KEY, false, game)
                        end
                    end
                else
                    if shouldHit then
                        if not TappedNotes[note] or (tick() - TappedNotes[note] > 1.0) then
                            TappedNotes[note] = tick()
                            
                            VirtualInputManager:SendKeyEvent(false, TARGET_KEY, false, game)
                            VirtualInputManager:SendKeyEvent(true, TARGET_KEY, false, game)
                            
                            task.delay(0.015, function()
                                local isHolding = false
                                for hNote, k in pairs(ActiveHolds) do
                                    if k == TARGET_KEY and hNote.Parent then isHolding = true break end
                                end
                                if not isHolding then
                                    VirtualInputManager:SendKeyEvent(false, TARGET_KEY, false, game)
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
        if key == TARGET_KEY and not holdNote.Parent then 
            VirtualInputManager:SendKeyEvent(false, key, false, game)
            ActiveHolds[holdNote] = nil
        end
    end
end)
