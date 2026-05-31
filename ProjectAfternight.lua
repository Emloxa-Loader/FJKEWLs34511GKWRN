-- =========================================================================
-- EMLOXA WARE: PROJECT AFTERNIGHT (PLACE: 13042495892)
-- ADVANCED VECTOR ENGINE + PLAYERGUI INTEL DETECTOR (1K to 18K)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    -- ==========================================
    -- 1. SIDE SELECTOR UI (YÖN SEÇİCİ ARAYÜZ)
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
    -- 2. AUTO PLAYER (CORE MODCHART VECTOR ENGINE)
    -- ==========================================
    local AutoPlayerEnabled = false
    local AutoplayMethod = "Hybrid"
    
    local ProjectTab = Window:CreateTab("Auto Player")
    local AdvancedTab = Window:CreateTab("Advanced")

    -- KUSURSUZ VE SIRA DOĞRULAMALI TUŞ HARİTALARI
    local KeyMaps = {
        [1] = {Enum.KeyCode.Space},
        [2] = {Enum.KeyCode.F, Enum.KeyCode.J},
        [3] = {Enum.KeyCode.F, Enum.KeyCode.Space, Enum.KeyCode.J},
        [4] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.W, Enum.KeyCode.D},
        [5] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.Space, Enum.KeyCode.W, Enum.KeyCode.D},
        [6] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L},
        [7] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Space, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L},
        [8] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.H, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L},
        
        -- 9K MODE: Tam senin belirttiğin kusursuz parmak sırası!
        [9] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.Space, Enum.KeyCode.H, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L},
        
        [10] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.V, Enum.KeyCode.B, Enum.KeyCode.H, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L},
        [18] = {
            Enum.KeyCode.Q, Enum.KeyCode.W, Enum.KeyCode.E, Enum.KeyCode.R, Enum.KeyCode.T, Enum.KeyCode.Y,
            Enum.KeyCode.U, Enum.KeyCode.I, Enum.KeyCode.O, Enum.KeyCode.P, Enum.KeyCode.A, Enum.KeyCode.S,
            Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.G, Enum.KeyCode.H, Enum.KeyCode.J, Enum.KeyCode.K
        }
    }
    
    local TappedNotes = {}
    local LastPositions = {} 
    local LastNoteSeenTime = tick()
    
    local CurrentlyDown = {}
    local TapReleaseTimes = {}
    for i = 1, 18 do
        CurrentlyDown[i] = false
        TapReleaseTimes[i] = 0
    end

    ProjectTab:CreateToggle("Enable God Mode (Vector Engine)", function(s) AutoPlayerEnabled = s end)
    AdvancedTab:CreateDropdown("Autoplay Method", {"Calculate", "Rapid checks", "Hybrid"}, "Hybrid", function(val) AutoplayMethod = val end)

    -- GELİŞMİŞ VEKTÖREL YÖRÜNGE TAHMİNİ
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
            
            if dist < 25 then
                return i, strum
            end

            if velocityVec.Magnitude > 10 then
                local noteDirection = velocityVec.Unit
                local directionToStrum = (strumCenter - noteCenter).Unit
                local alignment = noteDirection:Dot(directionToStrum)
                
                local score = (alignment * 1000) - dist
                if score > bestMatchScore then
                    bestMatchScore = score
                    bestLaneIndex = i
                    bestStrum = strum
                end
            else
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

        -- KURAL 1: DOĞRUDAN PLAYERGUI İÇERİSİNDEKİ KLASÖRÜ BULUP MODU SAPTAMA
        local keysPerSide = nil
        for i = 1, 18 do
            if LocalPlayer.PlayerGui:FindFirstChild(i .. "K") then
                keysPerSide = i
                break
            end
        end
        
        if not keysPerSide then return end -- Klasör henüz sisteme düşmediyse bekle
        
        local currentKeyMap = KeyMaps[keysPerSide] or KeyMaps[4]

        -- Sahnedeki fiili yüklü Strum nesnelerini indeks numaralarına göre çekelim
        local availableStrums = {}
        local totalAvailableStrums = 0
        for _, obj in pairs(MainGame:GetChildren()) do
            if obj.Name:find("Strum") then
                local num = tonumber(obj.Name:match("%d+"))
                if num then
                    availableStrums[num] = obj
                    totalAvailableStrums = totalAvailableStrums + 1
                end
            end
        end

        -- KURAL 2: AKILLI HARİTALANDIRMA (RAKİP GİZLİYSE TETİKLENİR)
        local targetStrums = {}
        
        if totalAvailableStrums == keysPerSide then
            -- Eğer yüklenen strum sayısı mod sayısına tam eşitse (örn: 9K modunda sadece 9 strum varsa)
            -- Demek ki karşı taraf gizlenmiştir; eldeki tüm strumları sıralı olarak doğrudan senin tarafa bağla!
            local sortedIndices = {}
            for k in pairs(availableStrums) do table.insert(sortedIndices, k) end
            table.sort(sortedIndices)
            for _, idx in ipairs(sortedIndices) do
                table.insert(targetStrums, availableStrums[idx])
            end
        else
            -- Hem rakip hem bizim lane'ler mevcutsa normal indeks aralığını kullan (Sol=0'dan başlar, Sağ=keysPerSide'dan)
            local startIndex = (CurrentSide == "Left") and 0 or keysPerSide
            local endIndex = startIndex + keysPerSide - 1
            for i = startIndex, endIndex do
                local strum = availableStrums[i]
                if strum then table.insert(targetStrums, strum) end
            end
        end

        local anyNoteSeenThisFrame = false
        local holdActiveThisFrame = {}
        for i = 1, keysPerSide do holdActiveThisFrame[i] = false end

        -- 3. ADIM: NOTALARI ANALİZ ET VE VEKTÖREL ÇARPIŞTIR
        for _, note in pairs(MainGame:GetChildren()) do
            if note:IsA("ImageLabel") and not note.Name:find("Strum") then
                
                local noteCenter = Vector2.new(
                    note.AbsolutePosition.X + (note.AbsoluteSize.X / 2),
                    note.AbsolutePosition.Y + (note.AbsoluteSize.Y / 2)
                )

                local velocityVec = Vector2.new(0, 0)
                if LastPositions[note] then
                    local moveDelta = (noteCenter - LastPositions[note])
                    if moveDelta.Magnitude > 100 then
                        TappedNotes[note] = nil 
                    else
                        velocityVec = moveDelta / deltaTime
                    end
                end
                LastPositions[note] = noteCenter

                -- Akıllı yörünge motorundan geçiş
                local laneIndex, targetStrum = GetNoteLaneInfo(noteCenter, velocityVec, targetStrums)
                
                if laneIndex and targetStrum then
                    anyNoteSeenThisFrame = true
                    LastNoteSeenTime = tick()

                    local laneKey = currentKeyMap[laneIndex]
                    local strumCenter = Vector2.new(
                        targetStrum.AbsolutePosition.X + (targetStrum.AbsoluteSize.X / 2),
                        targetStrum.AbsolutePosition.Y + (targetStrum.AbsoluteSize.Y / 2)
                    )
                    
                    local dist = (noteCenter - strumCenter).Magnitude
                    local isHoldNote = (note.AbsoluteSize.Y > note.AbsoluteSize.X * 1.5)

                    if isHoldNote then
                        -- 2D BOUNDING BOX HOLD KONTROLÜ
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
                        -- NORMAL TAP VURUŞU
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
        -- DURUM GÜNCELLEMESİ (TÜM ŞERİTLERİ SÜRER)
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

        -- Şarkı bitişinde hafızayı temizleme ve tuş bırakma
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

    -- ==========================================
    -- 3. MISC & UNLOAD
    -- ==========================================
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
