-- =========================================================================
-- EMLOXA WARE: PROJECT AFTERNIGHT (PLACE: 13042495892)
-- MULTI-KEY DYNAMIC ENGINE (1K to 18K SUPPORTED)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    -- ==========================================
    -- 1. EKRANIN ÜST ORTASINA SIDE SELECTOR UI
    -- ==========================================
    local CurrentSide = "Right"
    local SideUI = Instance.new("ScreenGui")
    SideUI.Name = "EmloxaAfternightSideUI"
    SideUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local success = pcall(function() SideUI.Parent = game:GetService("CoreGui") end)
    if not success then SideUI.Parent = LocalPlayer.PlayerGui end

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 200, 0, 40)
    MainFrame.Position = UDim2.new(0.5, -100, 0, 20)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = SideUI

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(102, 85, 255)
    UIStroke.Thickness = 2
    UIStroke.Parent = MainFrame

    local SideText = Instance.new("TextLabel")
    SideText.Size = UDim2.new(1, 0, 1, 0)
    SideText.BackgroundTransparency = 1
    SideText.Font = Enum.Font.GothamBold
    SideText.Text = "PLAYING: RIGHT [Y]"
    SideText.TextColor3 = Color3.fromRGB(255, 255, 255)
    SideText.TextSize = 14
    SideText.Parent = MainFrame

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Y then
            if CurrentSide == "Right" then
                CurrentSide = "Left"
                SideText.Text = "PLAYING: LEFT [Y]"
                UIStroke.Color = Color3.fromRGB(255, 85, 85)
            else
                CurrentSide = "Right"
                SideText.Text = "PLAYING: RIGHT [Y]"
                UIStroke.Color = Color3.fromRGB(102, 85, 255)
            end
        end
    end)

    -- ==========================================
    -- 2. AUTO PLAYER (DYNAMIC MULTI-KEY ENGINE)
    -- ==========================================
    local AutoPlayerEnabled = false
    local AutoplayMethod = "Hybrid"
    
    local ProjectTab = Window:CreateTab("Auto Player")
    local AdvancedTab = Window:CreateTab("Advanced")

    -- GÖRSELLERDEN ÇIKARILAN BÜTÜN TUŞ DİZİLİMLERİ (1K - 10K + 18K)
    local KeyMaps = {
        [1] = {Enum.KeyCode.Space},
        [2] = {Enum.KeyCode.F, Enum.KeyCode.J},
        [3] = {Enum.KeyCode.F, Enum.KeyCode.Space, Enum.KeyCode.J},
        [4] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.W, Enum.KeyCode.D},
        [5] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.Space, Enum.KeyCode.W, Enum.KeyCode.D},
        [6] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L},
        [7] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Space, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L},
        [8] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.H, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L},
        [9] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.Space, Enum.KeyCode.H, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L},
        [10] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.V, Enum.KeyCode.B, Enum.KeyCode.H, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L},
        
        -- 18K için varsayılan klavye yayılımı (İstersen buradaki tuşları kendi zevkine göre değiştirebilirsin)
        [18] = {
            Enum.KeyCode.Q, Enum.KeyCode.W, Enum.KeyCode.E, Enum.KeyCode.R, Enum.KeyCode.T, Enum.KeyCode.Y,
            Enum.KeyCode.U, Enum.KeyCode.I, Enum.KeyCode.O, Enum.KeyCode.P, Enum.KeyCode.A, Enum.KeyCode.S,
            Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.G, Enum.KeyCode.H, Enum.KeyCode.J, Enum.KeyCode.K
        }
    }
    
    local TappedNotes = {}
    local LastYPositions = {} 
    local LastNoteSeenTime = tick()
    
    -- Dinamik Şerit (State) Değişkenleri (En fazla 18K destekli)
    local CurrentlyDown = {}
    local TapReleaseTimes = {}
    for i = 1, 18 do
        CurrentlyDown[i] = false
        TapReleaseTimes[i] = 0
    end

    ProjectTab:CreateToggle("Enable God Mode (Multi-Key Dynamic)", function(s) AutoPlayerEnabled = s end)
    AdvancedTab:CreateDropdown("Autoplay Method", {"Calculate", "Rapid checks", "Hybrid"}, "Hybrid", function(val) AutoplayMethod = val end)

    -- ==========================================
    -- MİLİSANİYELİK KUSURSUZ DÖNGÜ
    -- ==========================================
    RunService.RenderStepped:Connect(function(deltaTime)
        if not AutoPlayerEnabled then return end
        
        local MainUI = LocalPlayer.PlayerGui:FindFirstChild("Main")
        if not MainUI or not MainUI:FindFirstChild("Game") then return end
        local MainGame = MainUI.Game

        -- 1. ADIM: EKRANDAKİ STRUM'LARI SAY VE MODU BUL (1K, 4K, 7K vb.)
        local totalStrums = 0
        for _, obj in pairs(MainGame:GetChildren()) do
            if obj.Name:find("Strum") then totalStrums = totalStrums + 1 end
        end
        
        local keysPerSide = math.floor(totalStrums / 2)
        if keysPerSide == 0 then return end -- Şarkı henüz başlamadıysa bekle
        
        -- Hangi KeyMap'i kullanacağımızı belirle (Bilinmeyen modsa varsayılan olarak 4K kullan)
        local currentKeyMap = KeyMaps[keysPerSide] or KeyMaps[4]

        -- 2. ADIM: SEÇİLEN TARAFA GÖRE (SOL/SAĞ) GEÇERLİ STRUM'LARI LİSTELE
        local targetStrums = {}
        local startIndex = (CurrentSide == "Left") and 0 or keysPerSide
        local endIndex = startIndex + keysPerSide - 1

        for i = startIndex, endIndex do
            local strum = MainGame:FindFirstChild("Strum" .. i)
            if strum then
                table.insert(targetStrums, strum)
            end
        end

        local anyNoteSeenThisFrame = false
        
        -- Bu frame'de hangi lane'lerde basılı tutulması gerektiğini tutan dinamik tablo
        local holdActiveThisFrame = {}
        for i = 1, keysPerSide do holdActiveThisFrame[i] = false end

        -- 3. ADIM: EKRANDAKİ NOTALARI (IMAGELABEL) İŞLE
        for _, note in pairs(MainGame:GetChildren()) do
            if note:IsA("ImageLabel") and not note.Name:find("Strum") then
                
                -- Notanın hangi lane'de olduğunu bul
                local laneIndex = nil
                local targetStrum = nil
                local noteX = note.AbsolutePosition.X + (note.AbsoluteSize.X / 2)
                
                for i, strum in ipairs(targetStrums) do
                    local strumX = strum.AbsolutePosition.X + (strum.AbsoluteSize.X / 2)
                    if math.abs(noteX - strumX) < 30 then
                        laneIndex = i
                        targetStrum = strum
                        break
                    end
                end
                
                if laneIndex and targetStrum then
                    anyNoteSeenThisFrame = true
                    LastNoteSeenTime = tick()

                    local laneKey = currentKeyMap[laneIndex]
                    local laneCenterY = targetStrum.AbsolutePosition.Y + (targetStrum.AbsoluteSize.Y / 2)

                    local noteTop = note.AbsolutePosition.Y
                    local noteBottom = noteTop + note.AbsoluteSize.Y
                    local noteCenterY = noteTop + (note.AbsoluteSize.Y / 2)
                    local dist = math.abs(noteCenterY - laneCenterY)
                    
                    if LastYPositions[note] and math.abs(noteCenterY - LastYPositions[note]) > 50 then
                        TappedNotes[note] = nil
                    end
                    
                    local noteVelocity = 0
                    if LastYPositions[note] then
                        noteVelocity = math.abs(noteCenterY - LastYPositions[note]) / deltaTime
                    end
                    LastYPositions[note] = noteCenterY

                    -- Eğer boyu, eninin 1.5 katından büyükse bu bağımsız bir Hold Body (Kuyruk)
                    local isHoldNote = (note.AbsoluteSize.Y > note.AbsoluteSize.X * 1.5)

                    if isHoldNote then
                        -- ===============================================
                        -- BAĞIMSIZ HOLD (KUYRUK) ALGILAMA SİSTEMİ
                        -- ===============================================
                        if noteTop <= laneCenterY + 15 and noteBottom >= laneCenterY - 15 then
                            holdActiveThisFrame[laneIndex] = true
                        end
                    else
                        -- ===============================================
                        -- NORMAL KAFA (HEAD) NOTASI VURUŞU
                        -- ===============================================
                        local shouldHit = false
                        local frameTravel = noteVelocity * deltaTime
                        
                        if AutoplayMethod == "Rapid checks" then
                            shouldHit = (dist <= 5) 
                        elseif AutoplayMethod == "Calculate" then
                            shouldHit = (dist <= math.max(2, frameTravel / 1.5))
                        elseif AutoplayMethod == "Hybrid" then
                            shouldHit = (dist <= math.max(4, frameTravel / 1.2))
                        end

                        if shouldHit and not TappedNotes[note] then
                            TappedNotes[note] = true
                            TapReleaseTimes[laneIndex] = tick() + 0.035 
                            
                            VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                            VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                            CurrentlyDown[laneIndex] = true
                        end
                    end
                end
            end
        end

        -- ==========================================
        -- DURUM GÜNCELLEMESİ VE TUŞ KONTROLÜ
        -- ==========================================
        for i = 1, keysPerSide do
            local key = currentKeyMap[i]
            if key then
                local shouldBeDown = holdActiveThisFrame[i] or (tick() < TapReleaseTimes[i])
                
                if shouldBeDown and not CurrentlyDown[i] then
                    CurrentlyDown[i] = true
                    VirtualInputManager:SendKeyEvent(true, key, false, game)
                elseif not shouldBeDown and CurrentlyDown[i] then
                    CurrentlyDown[i] = false
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                end
            end
        end

        -- Şarkı bittiğinde her şeyi sıfırla
        if not anyNoteSeenThisFrame and (tick() - LastNoteSeenTime > 2.5) then
            TappedNotes = {}
            LastYPositions = {}
            
            for i = 1, 18 do
                if CurrentlyDown[i] and currentKeyMap[i] then
                    VirtualInputManager:SendKeyEvent(false, currentKeyMap[i], false, game)
                end
                CurrentlyDown[i] = false
            end
            LastNoteSeenTime = tick()
        end
    end)

    -- ==========================================
    -- 3. MISC & UNLOAD
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")

    MiscTab:CreateButton("Unload EMLOXA", function()
        AutoPlayerEnabled = false
        if SideUI then SideUI:Destroy() end
        
        -- Kapatırken olası basılı tuşları temizle
        for _, keys in pairs(KeyMaps) do
            for _, key in ipairs(keys) do
                VirtualInputManager:SendKeyEvent(false, key, false, game) 
            end
        end
        
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
