-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY AUTO-PLAYER v20 (HYBRID CORE & UI FIX)
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
            SideOverride = "Auto", -- Auto, Left, Right
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
            Method = "Hybrid [ Calculate + Rapid; The most accurate with FPS price ]"
        }
    }

    local LaneKeys = { Lane1 = Enum.KeyCode.A, Lane2 = Enum.KeyCode.S, Lane3 = Enum.KeyCode.W, Lane4 = Enum.KeyCode.D }

    -- ==========================================
    -- 1. LOCAL PLAYER SEKME
    -- ==========================================
    local PlayerTab = Window:CreateTab("Local Player")
    
    PlayerTab:CreateToggle({ Name = "Noclip (Pass Through)", CurrentValue = false, Flag = "FFNoclip", Callback = function(s) 
        RunService.Stepped:Connect(function()
            if s and LocalPlayer.Character then
                for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
            end
        end)
    end})
    PlayerTab:CreateSlider({ Name = "WalkSpeed", Range = {16, 250}, Increment = 1, CurrentValue = 16, Flag = "FFWS", Callback = function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end 
    end})
    PlayerTab:CreateSlider({ Name = "JumpPower", Range = {50, 350}, Increment = 1, CurrentValue = 50, Flag = "FFJP", Callback = function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = v end 
    end})

    -- ==========================================
    -- 2. AUTO PLAY SEKME
    -- ==========================================
    local FunkyTab = Window:CreateTab("Auto play")
    
    FunkyTab:CreateToggle({ Name = "Enable Auto Player", CurrentValue = false, Flag = "FFAE", Callback = function(s) Settings.AutoPlay.Enabled = s end })
    
    -- EĞER BOT TARAFINI BULAMAZSA DİYE ZORUNLU SEÇİM
    FunkyTab:CreateDropdown({
        Name = "Player Side Override (If bot doesn't work)",
        Options = {"Auto", "Left", "Right"},
        CurrentOption = {"Auto"},
        MultipleOptions = false,
        Flag = "FFSideOverride",
        Callback = function(opt) Settings.AutoPlay.SideOverride = opt[1] end
    })

    FunkyTab:CreateToggle({ Name = "Show Visualizer Dots", CurrentValue = false, Flag = "FFVis", Callback = function(s) Settings.AutoPlay.ShowVisualizer = s end })

    FunkyTab:CreateSlider({ Name = "Sick chance", Range = {0, 100}, Increment = 1, CurrentValue = 100, Flag = "FFSick", Callback = function(v) Settings.AutoPlay.SickChance = v end })
    FunkyTab:CreateSlider({ Name = "Good chance", Range = {0, 100}, Increment = 1, CurrentValue = 0, Flag = "FFGood", Callback = function(v) Settings.AutoPlay.GoodChance = v end })
    FunkyTab:CreateSlider({ Name = "Ok chance", Range = {0, 100}, Increment = 1, CurrentValue = 0, Flag = "FFOk", Callback = function(v) Settings.AutoPlay.OkChance = v end })
    FunkyTab:CreateSlider({ Name = "Bad chance", Range = {0, 100}, Increment = 1, CurrentValue = 0, Flag = "FFBad", Callback = function(v) Settings.AutoPlay.BadChance = v end })
    FunkyTab:CreateSlider({ Name = "Miss chance", Range = {0, 100}, Increment = 1, CurrentValue = 0, Flag = "FFMiss", Callback = function(v) Settings.AutoPlay.MissChance = v end })

    -- ==========================================
    -- 3. ADVANCED SEKME (ALGORITHM TUNING)
    -- ==========================================
    local AdvancedTab = Window:CreateTab("Advanced")
    
    AdvancedTab:CreateSlider({ Name = "Note hold duration (ms)", Range = {0, 1000}, Increment = 10, CurrentValue = 0, Flag = "FFHoldDur", Callback = function(v) Settings.Advanced.NoteHoldDuration = v end })
    AdvancedTab:CreateToggle({ Name = "Random note hold duration", CurrentValue = false, Flag = "FFRndHold", Callback = function(s) Settings.Advanced.RandomHoldDuration = s end })
    AdvancedTab:CreateSlider({ Name = "Scroll speed accuracy buffer", Range = {1, 100}, Increment = 1, CurrentValue = 50, Flag = "FFAccBuff", Callback = function(v) Settings.Advanced.AccuracyBuffer = v end })
    AdvancedTab:CreateSlider({ Name = "Calculate method time (frames)", Range = {1, 10}, Increment = 1, CurrentValue = 5, Flag = "FFCalcTime", Callback = function(v) Settings.Advanced.CalculateMethodTime = v end })
    AdvancedTab:CreateSlider({ Name = "Rapid check delay (frames)", Range = {1, 5}, Increment = 1, CurrentValue = 1, Flag = "FFRapidDelay", Callback = function(v) Settings.Advanced.RapidCheckDelay = v end })
    
    -- KUSURSUZ DROPDOWN EKLENTİSİ
    AdvancedTab:CreateDropdown({
        Name = "Autoplay method",
        Options = {
            "Calculate [ Least laggy + Only accurate at 2+ scroll speed ]",
            "Rapid checks [ The golden middle ]",
            "Hybrid [ Calculate + Rapid; The most accurate with FPS price ]"
        },
        CurrentOption = {"Hybrid [ Calculate + Rapid; The most accurate with FPS price ]"},
        MultipleOptions = false,
        Flag = "FFMethod",
        Callback = function(opt) Settings.Advanced.Method = opt[1] end
    })

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
        -- Visualizer Toggle'ına bağlı olarak görünürlük
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
        if Settings.AutoPlay.SideOverride ~= "Auto" then
            mySide = Settings.AutoPlay.SideOverride
        else
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
                            
                            -- Method Toleransı (Accuracy Buffer'a göre)
                            local tolerance = Settings.Advanced.AccuracyBuffer
                            if string.find(Settings.Advanced.Method, "Calculate") then tolerance = tolerance / 2 end
                            if string.find(Settings.Advanced.Method, "Hybrid") then tolerance = tolerance * 0.8 end
                            
                            if distance <= tolerance then
                                local isHoldNote = #note:GetChildren() > 1
                                TappedNotes[note] = true
                                
                                if isHoldNote then
                                    if not ActiveHolds[note] then
                                        ActiveHolds[note] = laneKey
                                        VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                    end
                                else
                                    -- Kusursuz Çift Vuruş (Sanal olarak bas-çek)
                                    task.spawn(function()
                                        VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                        
                                        local holdMs = Settings.Advanced.NoteHoldDuration
                                        if Settings.Advanced.RandomHoldDuration then holdMs = math.random(10, 50) end
                                        task.wait((holdMs > 0) and (holdMs / 1000) or 0.015)
                                        
                                        -- Başka bir Hold notası bu tuşu KULLANMIYORSA bırak
                                        local isHeld = false
                                        for activeHoldNote, k in pairs(ActiveHolds) do
                                            if k == laneKey and activeHoldNote.Parent then isHeld = true; break end
                                        end
                                        if not isHeld then VirtualInputManager:SendKeyEvent(false, laneKey, false, game) end
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
    MiscTab:CreateButton({ Name = "Clear Note Cache", Callback = function() TappedNotes = {}; ActiveHolds = {} end })
    MiscTab:CreateButton({ Name = "Unload EMLOXA", Callback = function()
        for _, key in pairs(ActiveHolds) do VirtualInputManager:SendKeyEvent(false, key, false, game) end
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end})
end

return GameModule
