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
    local CurrentSide = "Right" -- Varsayılan taraf
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
                UIStroke.Color = Color3.fromRGB(255, 85, 85) -- Sola geçince kırmızımsı
            else
                CurrentSide = "Right"
                SideText.Text = "PLAYING: RIGHT [Y]"
                UIStroke.Color = Color3.fromRGB(102, 85, 255) -- Sağa geçince mor
            end
        end
    end)

    -- ==========================================
    -- 2. AUTO PLAYER (PERFECT ENGINE)
    -- ==========================================
    local AutoPlayerEnabled = false
    local AutoplayMethod = "Hybrid"
    
    local ProjectTab = Window:CreateTab("Auto Player")
    local AdvancedTab = Window:CreateTab("Advanced")

    -- Sadece 4K Tuş Dizilimi
    local KeyMap = {Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Up, Enum.KeyCode.Right}
    
    local ActiveHolds = {}
    local TappedNotes = {}
    local LastYPositions = {} 
    local LastNoteSeenTime = tick()

    ProjectTab:CreateToggle("Enable God Mode (Afternight V1)", function(s) AutoPlayerEnabled = s end)
    AdvancedTab:CreateDropdown("Autoplay Method", {"Calculate", "Rapid checks", "Hybrid"}, "Hybrid", function(val) AutoplayMethod = val end)

    -- Hangi notanın hangi lane'de olduğunu X koordinatından bulma fonksiyonu
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
                
                -- Eğer notanın merkezi ile Strum'un merkezi X ekseninde yakınsa (hata payı 30px)
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

        for _, note in pairs(MainGame:GetChildren()) do
            -- Tüm ImageLabel'ları tara (Strum'ları es geç)
            if note:IsA("ImageLabel") and not note.Name:find("Strum") then
                
                local laneIndex, targetStrum = GetNoteLaneInfo(note, MainGame)
                
                -- Sadece bizim seçtiğimiz taraftaki bir lane'e aitse işle
                if laneIndex and targetStrum then
                    anyNoteSeenThisFrame = true
                    LastNoteSeenTime = tick()

                    local laneKey = KeyMap[laneIndex]
                    local laneCenterY = targetStrum.AbsolutePosition.Y + (targetStrum.AbsoluteSize.Y / 2)

                    local noteTop = note.AbsolutePosition.Y
                    local noteBottom = noteTop + note.AbsoluteSize.Y
                    local noteCenterY = noteTop + (note.AbsoluteSize.Y / 2)
                    local dist = math.abs(noteCenterY - laneCenterY)
                    
                    -- KUSURSUZ HAFIZA SİLİCİ (TELEPORT ALGILAYICI)
                    if LastYPositions[note] and math.abs(noteCenterY - LastYPositions[note]) > 50 then
                        TappedNotes[note] = nil
                        ActiveHolds[note] = nil
                    end
                    
                    -- Hız Hesaplama
                    local noteVelocity = 0
                    if LastYPositions[note] then
                        noteVelocity = math.abs(noteCenterY - LastYPositions[note]) / deltaTime
                    end
                    LastYPositions[note] = noteCenterY

                    -- Hold Notası Tespiti (Görsel uzunluğa göre)
                    local isHoldNote = (note.AbsoluteSize.Y > note.AbsoluteSize.X * 1.5)

                    -- Kusursuz Merkez (Sick) Matematiği
                    local shouldHit = false
                    local frameTravel = noteVelocity * deltaTime
                    
                    if AutoplayMethod == "Rapid checks" then
                        shouldHit = (dist <= 5) 
                    elseif AutoplayMethod == "Calculate" then
                        shouldHit = (dist <= math.max(2, frameTravel / 1.5))
                    elseif AutoplayMethod == "Hybrid" then
                        shouldHit = (dist <= math.max(4, frameTravel / 1.2))
                    end

                    -- VURUŞ İŞLEMLERİ (Şoklama)
                    if shouldHit and not TappedNotes[note] then
                        TappedNotes[note] = true
                        
                        if isHoldNote then
                            ActiveHolds[note] = laneKey
                            task.spawn(function()
                                VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                            end)
                        else
                            task.spawn(function()
                                VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                                VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                
                                task.wait(0.01)
                                
                                local isHolding = false
                                for hNote, k in pairs(ActiveHolds) do
                                    if k == laneKey and hNote.Parent then isHolding = true break end
                                end
                                if not isHolding then
                                    VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                                end
                            end)
                        end
                    end
                    
                    -- Hold Notası Kuyruk Bırakma
                    if isHoldNote and TappedNotes[note] then
                        -- Afternight'ta notalar aşağıdan yukarı mı, yukarıdan aşağı mı kayıyor kontrolü:
                        -- Eğere Strum üstteyse (Y'si düşükse) nota yukarı gidiyordur. Notanın alt kısmı strum'u geçince bırak.
                        if noteBottom < laneCenterY - 10 then 
                            if ActiveHolds[note] then
                                task.spawn(function()
                                    VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                                end)
                                ActiveHolds[note] = nil
                            end
                        end
                    end
                end
            end
        end

        -- Hata Payı Temizliği (Silinen hold notaları)
        for holdNote, key in pairs(ActiveHolds) do
            if not holdNote.Parent then 
                task.spawn(function()
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                end)
                ActiveHolds[holdNote] = nil
            end
        end

        -- ==========================================
        -- OTOMATİK SIFIRLAMA (Şarkı Bitişi)
        -- ==========================================
        if not anyNoteSeenThisFrame and (tick() - LastNoteSeenTime > 2.5) then
            TappedNotes = {}
            LastYPositions = {}
            
            for holdNote, key in pairs(ActiveHolds) do
                VirtualInputManager:SendKeyEvent(false, key, false, game)
            end
            ActiveHolds = {}
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
