-- =========================================================================
-- EMLOXA WARE: PROJECT AFTERNIGHT (PLACE: 13042495892)
-- VECTOR-BASED MODCHART ENGINE (1K to 18K SUPPORTED)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    -- ==========================================
    -- 1. SIDE SELECTOR UI (YÖN SEÇİCİ)
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
    -- 2. AUTO PLAYER (VECTOR-BASED MODCHART ENGINE)
    -- ==========================================
    local AutoPlayerEnabled = false
    local AutoplayMethod = "Hybrid"
    
    local ProjectTab = Window:CreateTab("Auto Player")
    local AdvancedTab = Window:CreateTab("Advanced")

   -- GÖRSELLERDEN ÇIKARILAN KUSURSUZ TUŞ DİZİLİMLERİ (1K - 10K + 18K)
    local KeyMaps = {
        [1] = {Enum.KeyCode.Space},
        [2] = {Enum.KeyCode.F, Enum.KeyCode.J},
        [3] = {Enum.KeyCode.F, Enum.KeyCode.Space, Enum.KeyCode.J},
        [4] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.W, Enum.KeyCode.D},
        [5] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.Space, Enum.KeyCode.W, Enum.KeyCode.D},
        [6] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L},
        [7] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Space, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L},
        [8] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.H, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L},
        
        -- 9K MODE: Tam senin belirttiğin sıra!
        [9] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.Space, Enum.KeyCode.H, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L},
        
        [10] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.V, Enum.KeyCode.B, Enum.KeyCode.H, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L},
        
        -- 18K için varsayılan klavye yayılımı
        [18] = {
            Enum.KeyCode.Q, Enum.KeyCode.W, Enum.KeyCode.E, Enum.KeyCode.R, Enum.KeyCode.T, Enum.KeyCode.Y,
            Enum.KeyCode.U, Enum.KeyCode.I, Enum.KeyCode.O, Enum.KeyCode.P, Enum.KeyCode.A, Enum.KeyCode.S,
            Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.G, Enum.KeyCode.H, Enum.KeyCode.J, Enum.KeyCode.K
        }
    }
    
    local TappedNotes = {}
    local LastPositions = {} -- Artık sadece Y değil, X ve Y tutuluyor (Vector2)
    local LastNoteSeenTime = tick()
    
    local CurrentlyDown = {}
    local TapReleaseTimes = {}
    for i = 1, 18 do
        CurrentlyDown[i] = false
        TapReleaseTimes[i] = 0
    end

    ProjectTab:CreateToggle("Enable God Mode (Vector Engine)", function(s) AutoPlayerEnabled = s end)
    AdvancedTab:CreateDropdown("Autoplay Method", {"Calculate", "Rapid checks", "Hybrid"}, "Hybrid", function(val) AutoplayMethod = val end)

    -- KUSURSUZ YÖRÜNGE TAHMİNİ (TRAJECTORY PREDICTION)
    local function GetNoteLaneInfo(noteCenter, velocityVec, targetStrums)
        local bestMatchScore = -math.huge
        local bestLaneIndex = nil
        local bestStrum = nil

        for i, strum in ipairs(targetStrums) do
            local strumCenter = Vector2.new(
                strum.AbsolutePosition.X + (strum.AbsoluteSize.X / 2),
                strum.AbsolutePosition.Y + (strum.AbsoluteSize.Y / 2)
            )
            
            local dist = (noteCenter - strumCenter).Magnitude
            
            -- 1. Şart: Nota hedefle iç içeyse hiç hesap yapmadan direkt vur
            if dist < 25 then
                return i, strum
            end

            -- 2. Şart: Vektörel Hedefleme (Nota nereye uçuyor?)
            -- Dot Product mantığı: Notanın yönü ile Strum'un konumu birbiriyle eşleşiyorsa skor 1'e yaklaşır.
            if velocityVec.Magnitude > 10 then
                local noteDirection = velocityVec.Unit
                local directionToStrum = (strumCenter - noteCenter).Unit
                local alignment = noteDirection:Dot(directionToStrum)
                
                -- Uzaklığa ve Gidiş Yönüne dayalı Puanlama Sistemi
                local score = (alignment * 1000) - dist
                
                if score > bestMatchScore then
                    bestMatchScore = score
                    bestLaneIndex = i
                    bestStrum = strum
                end
            else
                -- Eğer hız yoksa (daha yeni doğduysa) klasik X ve Y yakınlığına bak
                local fallbackScore = -dist
                if fallbackScore > bestMatchScore then
                    bestMatchScore = fallbackScore
                    bestLaneIndex = i
                    bestStrum = strum
                end
            end
        end
        return bestLaneIndex, bestStrum
    end

    -- ==========================================
    -- MİLİSANİYELİK KUSURSUZ DÖNGÜ
    -- ==========================================
    RunService.RenderStepped:Connect(function(deltaTime)
        if not AutoPlayerEnabled then return end
        
        local MainUI = LocalPlayer.PlayerGui:FindFirstChild("Main")
        if not MainUI or not MainUI:FindFirstChild("Game") then return end
        local MainGame = MainUI.Game

        local totalStrums = 0
        for _, obj in pairs(MainGame:GetChildren()) do
            if obj.Name:find("Strum") then totalStrums = totalStrums + 1 end
        end
        
        local keysPerSide = math.floor(totalStrums / 2)
        if keysPerSide == 0 then return end 
        
        local currentKeyMap = KeyMaps[keysPerSide] or KeyMaps[4]

        local targetStrums = {}
        local startIndex = (CurrentSide == "Left") and 0 or keysPerSide
        local endIndex = startIndex + keysPerSide - 1

        for i = startIndex, endIndex do
            local strum = MainGame:FindFirstChild("Strum" .. i)
            if strum then table.insert(targetStrums, strum) end
        end

        local anyNoteSeenThisFrame = false
        local holdActiveThisFrame = {}
        for i = 1, keysPerSide do holdActiveThisFrame[i] = false end

        for _, note in pairs(MainGame:GetChildren()) do
            if note:IsA("ImageLabel") and not note.Name:find("Strum") then
                
                -- Notanın 2D Merkez Noktasını Al
                local noteCenter = Vector2.new(
                    note.AbsolutePosition.X + (note.AbsoluteSize.X / 2),
                    note.AbsolutePosition.Y + (note.AbsoluteSize.Y / 2)
                )

                -- Teleport Algılayıcı ve Hız (Velocity) Hesaplama
                local velocityVec = Vector2.new(0, 0)
                if LastPositions[note] then
                    local moveDelta = (noteCenter - LastPositions[note])
                    if moveDelta.Magnitude > 100 then
                        TappedNotes[note] = nil -- Işınlanma tespit edildi, sıfırla
                    else
                        velocityVec = moveDelta / deltaTime
                    end
                end
                LastPositions[note] = noteCenter

                -- Yörünge Motorunu Çalıştır ve Hangi Şeride Ait Olduğunu Bul
                local laneIndex, targetStrum = GetNoteLaneInfo(noteCenter, velocityVec, targetStrums)
                
                if laneIndex and targetStrum then
                    anyNoteSeenThisFrame = true
                    LastNoteSeenTime = tick()

                    local laneKey = currentKeyMap[laneIndex]
                    local strumCenter = Vector2.new(
                        targetStrum.AbsolutePosition.X + (targetStrum.AbsoluteSize.X / 2),
                        targetStrum.AbsolutePosition.Y + (targetStrum.AbsoluteSize.Y / 2)
                    )
                    
                    -- Kuş Uçuşu (2D) Gerçek Mesafe
                    local dist = (noteCenter - strumCenter).Magnitude
                    local isHoldNote = (note.AbsoluteSize.Y > note.AbsoluteSize.X * 1.5)

                    if isHoldNote then
                        -- ===============================================
                        -- 2D BOUNDING BOX (SINIR KUTUSU) HOLD KONTROLÜ
                        -- ===============================================
                        -- Nota ne yöne kayarsa kaysın (sağa, sola, çapraza), Strum merkezi notanın içine girmiş mi?
                        local noteMinX = note.AbsolutePosition.X
                        local noteMaxX = noteMinX + note.AbsoluteSize.X
                        local noteMinY = note.AbsolutePosition.Y
                        local noteMaxY = noteMinY + note.AbsoluteSize.Y

                        local inX = (strumCenter.X >= noteMinX - 15) and (strumCenter.X <= noteMaxX + 15)
                        local inY = (strumCenter.Y >= noteMinY - 15) and (strumCenter.Y <= noteMaxY + 15)

                        if inX and inY then
                            holdActiveThisFrame[laneIndex] = true
                        end
                    else
                        -- ===============================================
                        -- 2D NORMAL NOTA VURUŞU (HEAD TAP)
                        -- ===============================================
                        local shouldHit = false
                        local frameTravel = velocityVec.Magnitude * deltaTime
                        
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
        -- DURUM GÜNCELLEMESİ (TÜM TUŞLARI YÖNETİR)
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

        if not anyNoteSeenThisFrame and (tick() - LastNoteSeenTime > 2.5) then
            TappedNotes = {}
            LastPositions = {}
            
            for i = 1, 18 do
                if CurrentlyDown[i] and currentKeyMap[i] then
                    VirtualInputManager:SendKeyEvent(false, currentKeyMap[i], false, game)
                end
                CurrentlyDown[i] = false
            end
            LastNoteSeenTime = tick()
        end
    end)

    local MiscTab = Window:CreateTab("Misc")

    MiscTab:CreateButton("Unload EMLOXA", function()
        AutoPlayerEnabled = false
        if SideUI then SideUI:Destroy() end
        
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
