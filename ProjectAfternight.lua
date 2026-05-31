-- =========================================================================
-- EMLOXA WARE: PROJECT AFTERNIGHT (PLACE: 13042495892)
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

    -- Y Tuşu ile Taraf Değiştirme
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
    -- 2. AUTO PLAYER (HOLD NOTE ENGINE)
    -- ==========================================
    local AutoPlayerEnabled = false
    local AutoplayMethod = "Hybrid"
    
    local ProjectTab = Window:CreateTab("Auto Player")
    local AdvancedTab = Window:CreateTab("Advanced")

    -- W A S D TUŞ DİZİLİMİ (Sol=A, Alt=S, Üst=W, Sağ=D)
    local KeyMap = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.W, Enum.KeyCode.D}
    
    local TappedNotes = {}
    local LastYPositions = {} 
    local LastNoteSeenTime = tick()
    
    -- Şerit Durumu (State) Değişkenleri
    local CurrentlyDown = {false, false, false, false}
    local TapReleaseTimes = {0, 0, 0, 0}

    ProjectTab:CreateToggle("Enable God Mode (Advanced Hold Logic)", function(s) AutoPlayerEnabled = s end)
    AdvancedTab:CreateDropdown("Autoplay Method", {"Calculate", "Rapid checks", "Hybrid"}, "Hybrid", function(val) AutoplayMethod = val end)

    local function GetNoteLaneInfo(note, MainGame)
        local strums = {}
        if CurrentSide == "Left" then
            strums = {
                MainGame:FindFirstChild("Strum0"), MainGame:FindFirstChild("Strum1"),
                MainGame:FindFirstChild("Strum2"), MainGame:FindFirstChild("Strum3")
            }
        else
            strums = {
                MainGame:FindFirstChild("Strum4"), MainGame:FindFirstChild("Strum5"),
                MainGame:FindFirstChild("Strum6"), MainGame:FindFirstChild("Strum7")
            }
        end

        for i, strum in ipairs(strums) do
            if strum then
                local noteX = note.AbsolutePosition.X + (note.AbsoluteSize.X / 2)
                local strumX = strum.AbsolutePosition.X + (strum.AbsoluteSize.X / 2)
                
                if math.abs(noteX - strumX) < 30 then
                    return i, strum
                end
            end
        end
        return nil, nil
    end

    -- ==========================================
    -- MİLİSANİYELİK KUSURSUZ DÖNGÜ
    -- ==========================================
    RunService.RenderStepped:Connect(function(deltaTime)
        if not AutoPlayerEnabled then return end
        
        local MainUI = LocalPlayer.PlayerGui:FindFirstChild("Main")
        if not MainUI or not MainUI:FindFirstChild("Game") then return end
        local MainGame = MainUI.Game

        local anyNoteSeenThisFrame = false
        local holdActiveThisFrame = {false, false, false, false}

        -- Tüm objeleri tara ve durumlarını değerlendir
        for _, note in pairs(MainGame:GetChildren()) do
            if note:IsA("ImageLabel") and not note.Name:find("Strum") then
                
                local laneIndex, targetStrum = GetNoteLaneInfo(note, MainGame)
                
                if laneIndex and targetStrum then
                    anyNoteSeenThisFrame = true
                    LastNoteSeenTime = tick()

                    local laneKey = KeyMap[laneIndex]
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
                        -- Kuyruğun üst kısmı Strum'u geçmiş ve alt kısmı henüz Strum'dan çıkmamışsa:
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
                            -- Normal nota vurulduğunda çok kısa süreliğine tuşu basılı tutma süresi tanır
                            TapReleaseTimes[laneIndex] = tick() + 0.035 
                            
                            -- Vuruşun %100 algılanması için tuşu tazele
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
        -- Her şerit için basılı tutulup tutulmayacağına karar verilir.
        for i = 1, 4 do
            local key = KeyMap[i]
            -- Eğer o şeritten bir kuyruk geçiyorsa VEYA normal bir notaya yeni basıldıysa tuş aşağıda kalmalıdır.
            local shouldBeDown = holdActiveThisFrame[i] or (tick() < TapReleaseTimes[i])
            
            if shouldBeDown and not CurrentlyDown[i] then
                CurrentlyDown[i] = true
                VirtualInputManager:SendKeyEvent(true, key, false, game)
            elseif not shouldBeDown and CurrentlyDown[i] then
                CurrentlyDown[i] = false
                VirtualInputManager:SendKeyEvent(false, key, false, game)
            end
        end

        -- Şarkı bittiğinde her şeyi sıfırla
        if not anyNoteSeenThisFrame and (tick() - LastNoteSeenTime > 2.5) then
            TappedNotes = {}
            LastYPositions = {}
            
            for i = 1, 4 do
                if CurrentlyDown[i] then
                    VirtualInputManager:SendKeyEvent(false, KeyMap[i], false, game)
                    CurrentlyDown[i] = false
                end
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
        
        for _, key in pairs(KeyMap) do 
            VirtualInputManager:SendKeyEvent(false, key, false, game) 
        end
        
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
