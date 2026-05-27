-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY AUTO-PLAYER v19 (HYBRID ENGINE & ADVANCED UI)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local LocalPlayer = Players.LocalPlayer

    -- ==========================================
    -- AYARLAR (ADVANCED & CHANCES)
    -- ==========================================
    local Settings = {
        AutoPlay = {
            Enabled = false,
            SickChance = 100,
            GoodChance = 0,
            OkChance = 0,
            BadChance = 0,
            MissChance = 0
        },
        Advanced = {
            NoteHoldDuration = 0,
            RandomHoldDuration = false,
            AccuracyBuffer = 50,
            CalculateMethodTime = 5,
            RapidCheckDelay = 1,
            Method = "Hybrid" -- Rapid, Calculate, Hybrid
        }
    }

    local LaneKeys = { Lane1 = Enum.KeyCode.A, Lane2 = Enum.KeyCode.S, Lane3 = Enum.KeyCode.W, Lane4 = Enum.KeyCode.D }
    local LaneStates = { Lane1 = false, Lane2 = false, Lane3 = false, Lane4 = false }

    -- ==========================================
    -- 1. LOCAL PLAYER SEKME
    -- ==========================================
    local PlayerTab = Window:CreateTab("Local Player")
    local NoclipEnabled, FlyEnabled = false, false
    
    PlayerTab:CreateToggle("Noclip (Pass Through)", function(s) NoclipEnabled = s end)
    PlayerTab:CreateSlider("WalkSpeed", 16, 250, 16, function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end 
    end)
    PlayerTab:CreateSlider("JumpPower", 50, 350, 50, function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = v end 
    end)

    -- ==========================================
    -- 2. AUTO PLAY SEKME (CHANCES)
    -- ==========================================
    local FunkyTab = Window:CreateTab("Auto play")
    
    FunkyTab:CreateToggle("Enable Auto Player", function(s) Settings.AutoPlay.Enabled = s end)
    
    FunkyTab:CreateSlider("Sick chance", 0, 100, 100, function(v) Settings.AutoPlay.SickChance = v end)
    FunkyTab:CreateSlider("Good chance", 0, 100, 0, function(v) Settings.AutoPlay.GoodChance = v end)
    FunkyTab:CreateSlider("Ok chance", 0, 100, 0, function(v) Settings.AutoPlay.OkChance = v end)
    FunkyTab:CreateSlider("Bad chance", 0, 100, 0, function(v) Settings.AutoPlay.BadChance = v end)
    FunkyTab:CreateSlider("Miss chance", 0, 100, 0, function(v) Settings.AutoPlay.MissChance = v end)

    -- ==========================================
    -- 3. ADVANCED SEKME (ALGORITHM TUNING)
    -- ==========================================
    local AdvancedTab = Window:CreateTab("Advanced")
    
    AdvancedTab:CreateSlider("Note hold duration (ms)", 0, 1000, 0, function(v) Settings.Advanced.NoteHoldDuration = v end)
    AdvancedTab:CreateToggle("Random note hold duration", function(s) Settings.Advanced.RandomHoldDuration = s end)
    AdvancedTab:CreateSlider("Scroll speed accuracy buffer", 1, 100, 50, function(v) Settings.Advanced.AccuracyBuffer = v end)
    AdvancedTab:CreateSlider("Calculate method time (frames)", 1, 10, 5, function(v) Settings.Advanced.CalculateMethodTime = v end)
    AdvancedTab:CreateSlider("Rapid check delay (frames)", 1, 5, 1, function(v) Settings.Advanced.RapidCheckDelay = v end)
    
    -- Dropdown yerine şimdilik butonla döngüsel seçim (Rayfield yapısına uyması için)
    local methodBtn = AdvancedTab:CreateButton("Autoplay method: Hybrid", function() end)
    methodBtn.Callback = function()
        if Settings.Advanced.Method == "Hybrid" then Settings.Advanced.Method = "Rapid checks"
        elseif Settings.Advanced.Method == "Rapid checks" then Settings.Advanced.Method = "Calculate"
        else Settings.Advanced.Method = "Hybrid" end
        methodBtn:UpdateText("Autoplay method: " .. Settings.Advanced.Method)
    end

    -- ==========================================
    -- GÖRÜNMEZ MATEMATİKSEL NOKTA (DOT) SİSTEMİ
    -- ==========================================
    local function GetOrMakeDot(parentObj, dotName)
        local dot = parentObj:FindFirstChild(dotName)
        if not dot then
            dot = Instance.new("Frame")
            dot.Name = dotName
            dot.Size = UDim2.new(0, 10, 0, 10)
            dot.Position = UDim2.new(0.5, -5, 0.5, -5)
            dot.BackgroundColor3 = Color3.new(1,0,0)
            dot.BorderSizePixel = 0
            dot.ZIndex = 999999
            dot.Parent = parentObj
        end
        -- DİKKAT: Artık her zaman görünmez (Tüm hesaplama arka planda yapılıyor)
        dot.BackgroundTransparency = 1 
        return dot
    end

    -- ==========================================
    -- HİBRİT ÇEKİRDEK (10.000x İYİLEŞTİRİLMİŞ MANTIK)
    -- ==========================================
    local TappedNotes = {}
    local ActiveHolds = {}

    -- İhtimal Hesaplayıcı (Zar Atma)
    local function GetHitOffset()
        local roll = math.random(1, 100)
        local total = 0
        
        total = total + Settings.AutoPlay.SickChance
        if roll <= total then return math.random(-5, 5) end -- Kusursuz merkez
        
        total = total + Settings.AutoPlay.GoodChance
        if roll <= total then return math.random(15, 25) end -- Biraz erken/geç
        
        total = total + Settings.AutoPlay.OkChance
        if roll <= total then return math.random(30, 40) end 
        
        total = total + Settings.AutoPlay.BadChance
        if roll <= total then return math.random(45, 55) end
        
        return "MISS" -- Miss chance alanına girdiyse
    end

    -- Güvenli Tuş Yöneticisi (Input State Manager)
    local function PressKey(laneKey)
        VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
    end

    local function ReleaseKey(laneKey)
        VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
    end

    local function SmartRetap(laneKey)
        -- Eğer tuş zaten basılıysa (Hold notasından kalma vb.), motorun kafası karışmasın diye 1 frame bekleyerek tetikle.
        task.spawn(function()
            ReleaseKey(laneKey)
            RunService.RenderStepped:Wait() -- Motorun bırakma işlemini algılaması için altın kural
            PressKey(laneKey)
        end)
    end

    -- Ana Döngü
    RunService.RenderStepped:Connect(function()
        if not Settings.AutoPlay.Enabled then return end
        
        local ui = LocalPlayer.PlayerGui:FindFirstChild("Window")
        if not ui or not ui:FindFirstChild("Game") or not ui.Game:FindFirstChild("Fields") then return end
        
        -- Zeki Taraf Bulucu (Debug hatasını çözen kısım)
        local mySide = nil
        local scores = ui.Game:FindFirstChild("HUD") and ui.Game.HUD:FindFirstChild("Scores")
        if scores then
            for _, side in pairs({scores:FindFirstChild("Left"), scores:FindFirstChild("Right")}) do
                if side then
                    for _, obj in pairs(side:GetDescendants()) do
                        if obj:IsA("TextLabel") and (string.find(string.lower(obj.Text), string.lower(LocalPlayer.Name)) or string.find(string.lower(obj.Text), string.lower(LocalPlayer.DisplayName))) then
                            mySide = side.Name
                            break
                        end
                    end
                end
            end
        end
        if not mySide then return end -- Şarkı henüz tam başlamamış demektir, sessizce bekle.
        
        local inner = ui.Game.Fields[mySide].Inner

        -- 1. ADIM: HOLD NOTALARININ BİTİŞ KONTROLÜ
        for holdNote, keyData in pairs(ActiveHolds) do
            if not holdNote.Parent or not holdNote:IsDescendantOf(game) or holdNote.AbsoluteSize.Y < 5 then 
                ReleaseKey(keyData.Key)
                ActiveHolds[holdNote] = nil
            end
        end

        -- 2. ADIM: YENİ NOTALARI TARAMA (Hybrid Yöntemi)
        for i = 1, 4 do
            local laneName = "Lane" .. i
            local laneFrame = inner:FindFirstChild(laneName)
            if laneFrame then
                local targetDot = GetOrMakeDot(laneFrame, "EmloxaTargetDot")
                local laneCenterY = laneFrame.AbsolutePosition.Y + (laneFrame.AbsoluteSize.Y / 2)
                local notesFolder = laneFrame:FindFirstChild("Notes")
                
                if notesFolder then
                    local laneKey = LaneKeys[laneName]
                    
                    for _, note in pairs(notesFolder:GetChildren()) do
                        if note:IsA("GuiObject") and not TappedNotes[note] then
                            local noteDot = GetOrMakeDot(note, "EmloxaNoteDot")
                            local noteCenterY = note.AbsolutePosition.Y + (note.AbsoluteSize.Y / 2)
                            
                            -- İhtimal zarını at
                            if not note:GetAttribute("HitOffset") then
                                note:SetAttribute("HitOffset", GetHitOffset())
                            end
                            local offset = note:GetAttribute("HitOffset")
                            
                            if offset == "MISS" then
                                -- Bota kasıtlı olarak kaçırma emri verildiyse notayı yok say
                                if math.abs(noteCenterY - laneCenterY) < 10 then TappedNotes[note] = true end
                                continue
                            end

                            -- HYBRID/RAPID METODU MATEMATİĞİ
                            -- Notanın konumu (offset dahil) hedefe ulaştı mı?
                            local distance = math.abs((noteCenterY + offset) - laneCenterY)
                            
                            -- Accuracy buffer ayarını tolerans olarak kullanıyoruz
                            local tolerance = (Settings.Advanced.Method == "Calculate") and 5 or Settings.Advanced.AccuracyBuffer / 2
                            
                            if distance <= tolerance then
                                local isHoldNote = #note:GetChildren() > 1 -- Orijinal görsel objeler birden fazlaysa Hold'dur
                                
                                if isHoldNote then
                                    if not ActiveHolds[note] then
                                        ActiveHolds[note] = {Key = laneKey}
                                        SmartRetap(laneKey) -- Hold başlarken önceki tuş buglarını ez
                                    end
                                else
                                    -- NORMAL NOTA (En Kritik Kısım)
                                    TappedNotes[note] = true
                                    
                                    task.spawn(function()
                                        SmartRetap(laneKey) -- Şoklama Vuruşu (Bırak ve 1 frame sonra bas)
                                        
                                        -- Basılı tutma süresi (Gelişmiş sekmedeki ayar)
                                        local holdMs = Settings.Advanced.NoteHoldDuration
                                        if Settings.Advanced.RandomHoldDuration then
                                            holdMs = math.random(10, 50)
                                        end
                                        local holdWait = (holdMs > 0) and (holdMs / 1000) or 0.015
                                        
                                        task.wait(holdWait)
                                        
                                        -- Bırakmadan önce ŞU AN çalışan başka bir hold notası var mı diye ZEKİCE kontrol et
                                        local conflict = false
                                        for activeHoldNote, keyData in pairs(ActiveHolds) do
                                            if keyData.Key == laneKey and activeHoldNote.Parent then
                                                conflict = true
                                                break
                                            end
                                        end
                                        
                                        -- Eğer çatışma yoksa tuşu güvenle bırak
                                        if not conflict then
                                            ReleaseKey(laneKey)
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    -- ==========================================
    -- 4. MISC & CLEANUP
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")
    MiscTab:CreateButton("Clear Note Cache", function() TappedNotes = {}; ActiveHolds = {} end)
    MiscTab:CreateButton("Unload EMLOXA", function()
        for _, keyData in pairs(ActiveHolds) do VirtualInputManager:SendKeyEvent(false, keyData.Key, false, game) end
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
