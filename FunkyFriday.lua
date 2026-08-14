-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY V29 (V27 FULL PERFECT CORE + AUTO-KEY SYSTEM - PREMIUM)
-- ULTRA GELİŞMİŞ NOTA ALGILAMA – İSİM BAĞIMSIZ, OTOMATİK VURUŞ ÇİZGİSİ
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
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
            LocalPlayer.Character.Humanoid.WalkSpeed = v 
        end 
    end)
    PlayerTab:CreateSlider("JumpPower", 50, 350, 50, function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
            local hum = LocalPlayer.Character.Humanoid
            hum.UseJumpPower = true
            hum.JumpPower = v 
        end 
    end)

    -- ==========================================
    -- 2. AUTO PLAYER (PERFECT ENGINE + AUTO-KEY)
    -- ==========================================
    local FunkyTab = Window:CreateTab("Auto Player")
    local AdvancedTab = Window:CreateTab("Advanced")
    
    local AutoPlayerEnabled = false
    local AutoplayMethod = "Hybrid"  -- "Hybrid", "Calculate", "Rapid checks"
    
    local KeyMaps = {
        [4] = {Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Up, Enum.KeyCode.Right},
        [5] = {Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.Space, Enum.KeyCode.J, Enum.KeyCode.K},
        [6] = {Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L},
        [7] = {Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.Space, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L},
        [8] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L, Enum.KeyCode.Semicolon},
        [9] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.Space, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L, Enum.KeyCode.Semicolon}
    }
    
    local LaneStats = {}
    for i = 1, 9 do LaneStats["Lane"..i] = {Seen = 0, Taps = 0} end
    
    -- Nota takip tabloları (obje referansı ile, isim asla kullanılmaz)
    local CountedNotes = {}       -- sayıldı mı?
    local HitNotes = {}           -- vuruldu mu?
    local ActiveHolds = {}        -- hold aktif mi? (note -> key)
    local LastYPositions = {}     -- önceki Y pozisyonu
    local NoteStates = {}         -- "incoming" veya "passed"
    local LastNoteSeenTime = tick()

    FunkyTab:CreatePremiumToggle("Enable God Mode (Flawless V29)", function(s) AutoPlayerEnabled = s end)
    AdvancedTab:CreateDropdown("Autoplay Method", {"Calculate", "Rapid checks", "Hybrid"}, "Hybrid", nil, function(val) AutoplayMethod = val end)

    -- İstatistik etiketi
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

    -- Dinamik nokta (görsel yardım) – isimle ilgisi yok
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

    -- Güvenli tuş gönderimi
    local function SendKeyDown(key)
        task.spawn(function()
            pcall(function() VirtualInputManager:SendKeyEvent(true, key, false, game) end)
        end)
    end
    local function SendKeyUp(key)
        task.spawn(function()
            pcall(function() VirtualInputManager:SendKeyEvent(false, key, false, game) end)
        end)
    end
    local function SendKeyTap(key)
        task.spawn(function()
            SendKeyUp(key)
            SendKeyDown(key)
            task.wait(0.01)
            -- Eğer aynı tuşta aktif hold yoksa bırak
            local isHolding = false
            for _, k in pairs(ActiveHolds) do
                if k == key then isHolding = true break end
            end
            if not isHolding then SendKeyUp(key) end
        end)
    end

    -- Taraf algılama: Scores.Left.Emloxa veya Scores.Right.Emloxa
    local cachedMySide = nil
    local function GetMySide(ui)
        if cachedMySide then
            local fields = ui.Game:FindFirstChild("Fields")
            if fields and fields[cachedMySide] and fields[cachedMySide]:FindFirstChild("Inner") then
                return cachedMySide
            else
                cachedMySide = nil
            end
        end

        local scores = ui.Game:FindFirstChild("HUD") and ui.Game.HUD:FindFirstChild("Scores")
        if scores then
            for _, sideName in ipairs({"Left", "Right"}) do
                local side = scores[sideName]
                if side then
                    -- Öncelikle LocalPlayer adını ara
                    if side:FindFirstChild(LocalPlayer.Name) or side:FindFirstChild(LocalPlayer.DisplayName) then
                        cachedMySide = sideName
                        return sideName
                    end
                    -- Ekstra: Emloxa adında bir çocuk var mı?
                    if side:FindFirstChild("Emloxa") then
                        cachedMySide = sideName
                        return sideName
                    end
                end
            end
        end

        -- Fallback: notaların olduğu taraf
        local fields = ui.Game:FindFirstChild("Fields")
        if fields then
            for _, sideName in ipairs({"Left", "Right"}) do
                local inner = fields[sideName] and fields[sideName]:FindFirstChild("Inner")
                if inner then
                    for _, lane in pairs(inner:GetChildren()) do
                        if lane:IsA("GuiObject") and lane.Name:find("Lane") and lane:FindFirstChild("Notes") then
                            if #lane.Notes:GetChildren() > 0 then
                                cachedMySide = sideName
                                return sideName
                            end
                        end
                    end
                end
            end
        end
        return nil
    end

    -- Otomatik vuruş çizgisi bulma
    local function FindHitY(laneFrame)
        -- Önce açık isimler ara
        local explicit = laneFrame:FindFirstChild("Receptor") or laneFrame:FindFirstChild("Arrow") or laneFrame:FindFirstChild("HitLine") or laneFrame:FindFirstChild("Target")
        if explicit and explicit:IsA("GuiObject") then
            return explicit.AbsolutePosition.Y + explicit.AbsoluteSize.Y / 2
        end

        -- Başka bir çocuk (Notes ve bizim eklediklerimiz hariç)
        for _, child in pairs(laneFrame:GetChildren()) do
            if child:IsA("GuiObject") and child.Name ~= "Notes" and child.Name ~= "EmloxaStats" and child.Name ~= "EmloxaDynamicDot" then
                -- Küçük boyutlu bir hedef muhtemelen receptördür
                if child.AbsoluteSize.Y < laneFrame.AbsoluteSize.Y * 0.5 then
                    return child.AbsolutePosition.Y + child.AbsoluteSize.Y / 2
                end
            end
        end

        -- Varsayılan: lane'in alt kısmından biraz yukarısı
        return laneFrame.AbsolutePosition.Y + laneFrame.AbsoluteSize.Y - 20
    end

    RunService.RenderStepped:Connect(function(deltaTime)
        if not AutoPlayerEnabled then return end
        
        local ui = LocalPlayer.PlayerGui:FindFirstChild("Window")
        if not ui or not ui:FindFirstChild("Game") or not ui.Game:FindFirstChild("Fields") then return end
        
        local mySide = GetMySide(ui)
        if not mySide then return end
        
        local fields = ui.Game.Fields[mySide].Inner
        local anyNoteSeenThisFrame = false

        -- Lane'leri topla ve sırala
        local laneFrames = {}
        for _, obj in pairs(fields:GetChildren()) do
            if obj:IsA("GuiObject") and obj.Name:find("Lane") and obj:FindFirstChild("Notes") then
                table.insert(laneFrames, obj)
            end
        end
        table.sort(laneFrames, function(a, b) 
            return (tonumber(a.Name:match("%d+")) or 0) < (tonumber(b.Name:match("%d+")) or 0)
        end)

        local laneCount = #laneFrames
        if laneCount == 0 or not KeyMaps[laneCount] then return end

        for i = 1, laneCount do
            local laneFrame = laneFrames[i]
            local laneName = "Lane" .. i
            local laneKey = KeyMaps[laneCount][i]
            
            UpdateLaneStats(laneFrame, laneName)
            
            local hitY = FindHitY(laneFrame)
            local notesFolder = laneFrame:FindFirstChild("Notes")
            
            if notesFolder then
                for _, note in pairs(notesFolder:GetChildren()) do
                    if note:IsA("GuiObject") then
                        anyNoteSeenThisFrame = true
                        LastNoteSeenTime = tick()

                        local noteTop = note.AbsolutePosition.Y
                        local noteBottom = noteTop + note.AbsoluteSize.Y
                        local noteCenterY = noteTop + (note.AbsoluteSize.Y / 2)
                        local prevY = LastYPositions[note]

                        -- İlk görülme: say (isim kullanılmıyor, referans ile)
                        if not CountedNotes[note] then
                            CountedNotes[note] = true
                            LaneStats[laneName].Seen = LaneStats[laneName].Seen + 1
                            NoteStates[note] = "incoming"
                        end

                        -- Nota nesnesi yeniden kullanılıyorsa (respawn tespiti)
                        if prevY and NoteStates[note] == "passed" then
                            -- Nota yukarıdan aşağı hareket eder: respawn = Y koordinatı büyükten küçüğe sıçrar
                            if prevY > hitY + 50 and noteCenterY < hitY - 50 then
                                CountedNotes[note] = nil
                                HitNotes[note] = nil
                                ActiveHolds[note] = nil
                                CountedNotes[note] = true
                                LaneStats[laneName].Seen = LaneStats[laneName].Seen + 1
                                NoteStates[note] = "incoming"
                            end
                        end

                        -- Hold notası tespiti (isim kullanılmaz, sadece şekil/çocuk sayısı)
                        local childCount = 0
                        for _, c in ipairs(note:GetChildren()) do
                            if c.Name ~= "EmloxaDynamicDot" then childCount = childCount + 1 end
                        end
                        local isHoldNote = (childCount > 1) or (note.AbsoluteSize.Y > note.AbsoluteSize.X * 1.5)

                        -- Dinamik nokta
                        local dist = math.abs(noteCenterY - hitY)
                        ManageDynamicDot(note, dist)

                        -- Vuruş kontrolü
                        if not HitNotes[note] then
                            local shouldHit = false
                            
                            if isHoldNote then
                                -- Hold başlangıcı: notanın üst kenarı vuruş çizgisine ulaştığında
                                if prevY then
                                    if prevY <= hitY and noteTop >= hitY then
                                        shouldHit = true
                                    end
                                else
                                    -- İlk görülme: zaten çok yakınsa vur
                                    if math.abs(noteTop - hitY) < 25 then
                                        shouldHit = true
                                    end
                                end
                            else
                                -- Normal nota: merkez vuruş çizgisine ulaştığında
                                if prevY then
                                    if (prevY <= hitY and noteCenterY >= hitY) or
                                       (prevY >= hitY and noteCenterY <= hitY) then
                                        shouldHit = true
                                    end
                                else
                                    -- İlk görülme: merkezi çok yakınsa vur
                                    if math.abs(noteCenterY - hitY) < 25 then
                                        shouldHit = true
                                    end
                                end
                            end

                            -- Ek güvence: eğer nota çoktan geçtiyse ve yakınsa
                            if not shouldHit and prevY and math.abs(noteCenterY - hitY) < 15 then
                                shouldHit = true
                            end

                            if shouldHit then
                                HitNotes[note] = true
                                LaneStats[laneName].Taps = LaneStats[laneName].Taps + 1
                                
                                if isHoldNote then
                                    ActiveHolds[note] = laneKey
                                    SendKeyDown(laneKey)
                                else
                                    SendKeyTap(laneKey)
                                end
                            end
                        end

                        -- Hold bırakma: notanın alt kenarı vuruş çizgisine ulaştığında
                        if isHoldNote and HitNotes[note] and ActiveHolds[note] then
                            if prevY then
                                if prevY <= hitY and noteBottom >= hitY then
                                    SendKeyUp(laneKey)
                                    ActiveHolds[note] = nil
                                    NoteStates[note] = "passed"
                                end
                            else
                                if math.abs(noteBottom - hitY) < 25 then
                                    SendKeyUp(laneKey)
                                    ActiveHolds[note] = nil
                                    NoteStates[note] = "passed"
                                end
                            end
                        end

                        -- Normal nota geçtiyse state güncelle
                        if not isHoldNote and HitNotes[note] then
                            if noteTop > hitY + 20 then
                                NoteStates[note] = "passed"
                            end
                        end

                        LastYPositions[note] = noteCenterY
                    end
                end
            end
            
            -- Parent'ı silinmiş hold'ları temizle
            for holdNote, key in pairs(ActiveHolds) do
                if key == laneKey and not holdNote.Parent then
                    SendKeyUp(key)
                    ActiveHolds[holdNote] = nil
                end
            end
        end

        -- 2.5 saniye hiç nota yoksa istatistikleri sıfırla
        if not anyNoteSeenThisFrame and (tick() - LastNoteSeenTime > 2.5) then
            for i = 1, 9 do LaneStats["Lane"..i] = {Seen = 0, Taps = 0} end
            CountedNotes = {}
            HitNotes = {}
            ActiveHolds = {}
            LastYPositions = {}
            NoteStates = {}
            LastNoteSeenTime = tick()
        end
    end)

    -- ==========================================
    -- 3. MISC SEKME
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")
    MiscTab:CreateButton("Optimize Graphics (MAX FPS)", function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Enabled = false
            elseif v:IsA("BasePart") and (v.Material == Enum.Material.Glass or v.Material == Enum.Material.Neon) then
                v.Material = Enum.Material.SmoothPlastic
            end
        end
        game:GetService("Lighting").GlobalShadows = false
    end)
    MiscTab:CreateButton("Unload EMLOXA", function()
        AutoPlayerEnabled = false
        for _, keys in pairs(KeyMaps) do
            for _, key in pairs(keys) do
                SendKeyUp(key)
            end
        end
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaPremium") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaPremium")
        if ui then ui:Destroy() end
    end)
end

return GameModule
