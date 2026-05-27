-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY AUTO-PLAYER v21 (HYBRID CORE & PERFECT UI FIX)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local LocalPlayer = Players.LocalPlayer

    -- ==========================================
    -- AYARLAR TABLOSU
    -- ==========================================
    local Settings = {
        AutoPlay = {
            Enabled = false,
            SideOverride = 1, -- 1=Auto, 2=Left, 3=Right
            SickChance = 100,
            GoodChance = 0,
            OkChance = 0,
            BadChance = 0,
            MissChance = 0,
            ShowVisualizer = false
        },
        Advanced = {
            NoteHoldDuration = 0,
            RandomHoldDuration = false,
            AccuracyBuffer = 50,
            CalculateMethodTime = 5,
            RapidCheckDelay = 1,
            Method = 3 -- 1=Calculate, 2=Rapid, 3=Hybrid
        }
    }

    local LaneKeys = { Lane1 = Enum.KeyCode.A, Lane2 = Enum.KeyCode.S, Lane3 = Enum.KeyCode.W, Lane4 = Enum.KeyCode.D }

    -- ==========================================
    -- 1. LOCAL PLAYER SEKME
    -- ==========================================
    local PlayerTab = Window:CreateTab("Local Player")
    
    PlayerTab:CreateToggle("Noclip (Pass Through)", function(s) 
        RunService.Stepped:Connect(function()
            if s and LocalPlayer.Character then
                for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
            end
        end)
    end)
    PlayerTab:CreateSlider("WalkSpeed", 16, 250, 16, function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end 
    end)
    PlayerTab:CreateSlider("JumpPower", 50, 350, 50, function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = v end 
    end)

    -- ==========================================
    -- 2. AUTO PLAY SEKME (CHANCES & OVERRIDE)
    -- ==========================================
    local FunkyTab = Window:CreateTab("Auto play")
    
    FunkyTab:CreateToggle("Enable Auto Player", function(s) Settings.AutoPlay.Enabled = s end)
    
    -- Selectbox alternatifi (Asla UI hatası vermez)
    FunkyTab:CreateSlider("Side Override [ 1=Auto | 2=Left | 3=Right ]", 1, 3, 1, function(v) Settings.AutoPlay.SideOverride = v end)
    
    FunkyTab:CreateToggle("Show Visualizer Dots", function(s) Settings.AutoPlay.ShowVisualizer = s end)

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
    
    -- Selectbox alternatifi (Hatasız Method Seçimi)
    AdvancedTab:CreateSlider("Method [ 1=Calc | 2=Rapid | 3=Hybrid ]", 1, 3, 3, function(v) Settings.Advanced.Method = v end)

    -- ==========================================
    -- GÖRÜNMEZ MATEMATİKSEL NOKTA (DOT) SİSTEMİ
    -- ==========================================
    local function GetOrMakeDot(parentObj, dotName)
        local dot = parentObj:FindFirstChild(dotName)
        if not dot then
            dot = Instance.new("Frame")
            dot.Name = dotName
            dot.Size = UDim2.new(0, 14, 0, 14)
            dot.Position = UDim2.new(0.5, -7, 0.5, -7)
            dot.BackgroundColor3 = Color3.new(1,0,0)
            dot.BorderSizePixel = 0
            dot.ZIndex = 999999
            local corner = Instance.new("UICorner", dot); corner.CornerRadius = UDim.new(1,0)
            dot.Parent = parentObj
        end
        dot.BackgroundTransparency = Settings.AutoPlay.ShowVisualizer and 0.5 or 1 
        return dot
    end

    -- ==========================================
    -- HİBRİT ÇEKİRDEK (RACE CONDITION FIX)
    -- ==========================================
    local TappedNotes = {}
    local ActiveHolds = {}

    local function RollHitAccuracy()
        local roll = math.random(1, 100)
        local s = Settings.AutoPlay.SickChance
        local g = s + Settings.AutoPlay.GoodChance
        local o = g + Settings.AutoPlay.OkChance
        local b = o + Settings.AutoPlay.BadChance
        
        if roll <= s then return "Sick" end
        if roll <= g then return "Good" end
        if roll <= o then return "Ok" end
        if roll <= b then return "Bad" end
        return "Miss"
    end

    local function GetHitOffset()
        local acc = RollHitAccuracy()
        if acc == "Sick" then return math.random(-5, 5)
        elseif acc == "Good" then return math.random(15, 25)
        elseif acc == "Ok" then return math.random(30, 45)
        elseif acc == "Bad" then return math.random(50, 65)
        else return "MISS" end
    end

    RunService.RenderStepped:Connect(function()
        if not Settings.AutoPlay.Enabled then return end
        
        local ui = LocalPlayer.PlayerGui:FindFirstChild("Window")
        if not ui or not ui:FindFirstChild("Game") or not ui.Game:FindFirstChild("Fields") then return end
        
        -- ZEKİ TARAF BULUCU & OVERRIDE
        local mySide = nil
        if Settings.AutoPlay.SideOverride == 2 then
            mySide = "Left"
        elseif Settings.AutoPlay.SideOverride == 3 then
            mySide = "Right"
        else
            -- Otomatik Taraf Bulucu
            local scores = ui.Game:FindFirstChild("HUD") and ui.Game.HUD:FindFirstChild("Scores")
            if scores then
                for _, sideName in pairs({"Left", "Right"}) do
                    local sideUI = scores:FindFirstChild(sideName)
                    if sideUI then
                        for _, obj in pairs(sideUI:GetDescendants()) do
                            if obj:IsA("TextLabel") and (string.find(string.lower(obj.Text), string.lower(LocalPlayer.Name)) or string.find(string.lower(obj.Text), string.lower(LocalPlayer.DisplayName))) then
                                mySide = sideName
                                break
                            end
                        end
                    end
                end
            end
        end
        if not mySide then return end
        
        local inner = ui.Game.Fields[mySide]:FindFirstChild("Inner")
        if not inner then return end

        -- // FAZ 1: TEMİZLİK (RACE CONDITION ÖNLEMEK İÇİN ÖNCE BIRAK) //
        for holdNote, key in pairs(ActiveHolds) do
            if not holdNote.Parent or not holdNote:IsDescendantOf(game) or holdNote.AbsoluteSize.Y < 5 then 
                VirtualInputManager:SendKeyEvent(false, key, false, game)
                ActiveHolds[holdNote] = nil
            end
        end

        -- // FAZ 2: VURUŞ (HYBRID/CALCULATE/RAPID) //
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
                            
                            if not note:GetAttribute("HitOffset") then note:SetAttribute("HitOffset", GetHitOffset()) end
                            local offset = note:GetAttribute("HitOffset")
                            
                            if offset == "MISS" then
                                if math.abs(noteCenterY - laneCenterY) < 10 then TappedNotes[note] = true end
                                continue
                            end

                            local distance = math.abs((noteCenterY + offset) - laneCenterY)
                            
                            -- Method Toleransı
                            local tolerance = Settings.Advanced.AccuracyBuffer
                            if Settings.Advanced.Method == 1 then tolerance = tolerance / 2 end -- Calculate
                            if Settings.Advanced.Method == 3 then tolerance = tolerance * 0.8 end -- Hybrid
                            
                            if distance <= tolerance then
                                local isHoldNote = #note:GetChildren() > 1
                                TappedNotes[note] = true
                                
                                if isHoldNote then
                                    if not ActiveHolds[note] then
                                        ActiveHolds[note] = laneKey
                                        VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                    end
                                else
                                    -- KUSURSUZ ÇİFT VURUŞ (SANAL OLARAK BAS-ÇEK)
                                    task.spawn(function()
                                        -- Eğer tuş takılı kaldıysa şoklama yap (bırak-bas)
                                        VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                                        RunService.RenderStepped:Wait() -- Motorun bunu algılaması için altın bekleme
                                        VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                        
                                        local holdMs = Settings.Advanced.NoteHoldDuration
                                        if Settings.Advanced.RandomHoldDuration then holdMs = math.random(10, 50) end
                                        task.wait((holdMs > 0) and (holdMs / 1000) or 0.015)
                                        
                                        -- Aynı tuşu kullanan başka bir aktif Hold notası var mı kontrol et
                                        local isHeld = false
                                        for activeHoldNote, k in pairs(ActiveHolds) do
                                            if k == laneKey and activeHoldNote.Parent then isHeld = true; break end
                                        end
                                        
                                        if not isHeld then 
                                            VirtualInputManager:SendKeyEvent(false, laneKey, false, game) 
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
        for _, key in pairs(ActiveHolds) do VirtualInputManager:SendKeyEvent(false, key, false, game) end
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
