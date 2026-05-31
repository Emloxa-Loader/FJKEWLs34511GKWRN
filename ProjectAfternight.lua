-- =========================================================================
-- EMLOXA WARE: PROJECT AFTERNIGHT (PLACE: 13042495892)
-- V18 ULTIMATE PRECISION ENGINE (FLAWLESS MODE DETECTOR)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    -- ==========================================
    -- 1. EKRAN UI (YÖN SEÇİCİ & MOD ALGILAYICI)
    -- ==========================================
    local CurrentSide = "Right"
    local SideUI = Instance.new("ScreenGui")
    SideUI.Name = "EmloxaAfternightSideUI"
    SideUI.ResetOnSpawn = false
    
    local success = pcall(function() SideUI.Parent = game:GetService("CoreGui") end)
    if not success then SideUI.Parent = LocalPlayer.PlayerGui end

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 220, 0, 45)
    MainFrame.Position = UDim2.new(0.5, -110, 0, 15)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = SideUI

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(102, 85, 255)
    UIStroke.Thickness = 2.5
    UIStroke.Parent = MainFrame

    local SideText = Instance.new("TextLabel")
    SideText.Size = UDim2.new(1, 0, 1, 0)
    SideText.BackgroundTransparency = 1
    SideText.Font = Enum.Font.GothamBold
    SideText.Text = "EMLOXA: RIGHT [Y]"
    SideText.TextColor3 = Color3.fromRGB(255, 255, 255)
    SideText.TextSize = 15
    SideText.Parent = MainFrame

    local ModeFrame = Instance.new("Frame")
    ModeFrame.Size = UDim2.new(0, 200, 0, 35)
    ModeFrame.Position = UDim2.new(0.5, -100, 1, -50)
    ModeFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    ModeFrame.BorderSizePixel = 0
    ModeFrame.Parent = SideUI

    local UICornerMode = Instance.new("UICorner")
    UICornerMode.CornerRadius = UDim.new(0, 8)
    UICornerMode.Parent = ModeFrame

    local UIStrokeMode = Instance.new("UIStroke")
    UIStrokeMode.Color = Color3.fromRGB(0, 255, 150)
    UIStrokeMode.Thickness = 2
    UIStrokeMode.Parent = ModeFrame

    local ModeText = Instance.new("TextLabel")
    ModeText.Size = UDim2.new(1, 0, 1, 0)
    ModeText.BackgroundTransparency = 1
    ModeText.Font = Enum.Font.GothamBold
    ModeText.Text = "WAITING FOR SONG..."
    ModeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ModeText.TextSize = 14
    ModeText.Parent = ModeFrame

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Y then
            if CurrentSide == "Right" then
                CurrentSide = "Left"
                SideText.Text = "EMLOXA: LEFT [Y]"
                UIStroke.Color = Color3.fromRGB(255, 85, 85)
            else
                CurrentSide = "Right"
                SideText.Text = "EMLOXA: RIGHT [Y]"
                UIStroke.Color = Color3.fromRGB(102, 85, 255)
            end
        end
    end)

    -- ==========================================
    -- 2. DYNAMIC KEYMAPS (1K - 18K)
    -- ==========================================
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
        [18] = {
            Enum.KeyCode.Q, Enum.KeyCode.W, Enum.KeyCode.E, Enum.KeyCode.R, Enum.KeyCode.T, Enum.KeyCode.Y,
            Enum.KeyCode.U, Enum.KeyCode.I, Enum.KeyCode.O, Enum.KeyCode.P, Enum.KeyCode.A, Enum.KeyCode.S,
            Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.G, Enum.KeyCode.H, Enum.KeyCode.J, Enum.KeyCode.K
        }
    }

    -- ==========================================
    -- 3. AUTO PLAYER 
    -- ==========================================
    local AutoPlayerEnabled = false
    local AutoplayMethod = "Hybrid"
    
    local ProjectTab = Window:CreateTab("Auto Player")
    local AdvancedTab = Window:CreateTab("Advanced")

    ProjectTab:CreateToggle("Enable God Mode (Classic V18)", function(s) AutoPlayerEnabled = s end)
    AdvancedTab:CreateDropdown("Autoplay Method", {"Calculate", "Rapid checks", "Hybrid"}, "Hybrid", function(val) AutoplayMethod = val end)

    local TappedNotes = {}
    local LastYPositions = {} 
    local LastNoteSeenTime = tick()
    
    local CurrentlyDown = {}
    local TapReleaseTimes = {}
    for i = 1, 18 do
        CurrentlyDown[i] = false
        TapReleaseTimes[i] = 0
    end

    -- ==========================================
    -- HATA DÜZELTMESİ: GELİŞMİŞ KLASÖR BULUCU
    -- ==========================================
    local function GetTargetFolderAndMode(MainGame)
        for _, child in pairs(MainGame:GetChildren()) do
            -- İsmin içindeki harfleri büyüt (küçük 'k' yazıldıysa bile yakalar)
            -- Ve ismin neresinde olursa olsun rakam ve K'yi arar (Örn: "Mode_9K" -> 9)
            local matchStr = string.match(string.upper(child.Name), "(%d+)K")
            if matchStr then 
                return tonumber(matchStr), child 
            end
        end
        -- Eğer döngü biter ve hiçbirinde K yazmazsa, direkt 4K modundadır.
        return 4, MainGame
    end

    local function GetNoteLaneInfo(note, targetStrums)
        local noteX = note.AbsolutePosition.X + (note.AbsoluteSize.X / 2)
        for i, strum in ipairs(targetStrums) do
            if strum then
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
        local MainGame = MainUI and MainUI:FindFirstChild("Game")
        if not MainGame then 
            ModeText.Text = "WAITING FOR SONG..."
            return 
        end

        local kps, targetFolder = GetTargetFolderAndMode(MainGame)
        
        if ModeText.Text ~= "DETECTED MODE: " .. kps .. "K" then
            ModeText.Text = "DETECTED MODE: " .. kps .. "K"
        end

        local currentMap = KeyMaps[kps] or KeyMaps[4]
        local startIndex = (CurrentSide == "Left") and 0 or kps
        local myStrums = {}
        for i = 1, kps do
            local s = targetFolder:FindFirstChild("Strum" .. (startIndex + i - 1))
            if s then table.insert(myStrums, s) end
        end

        local anyNoteSeenThisFrame = false
        local holdActiveThisFrame = {}
        for i = 1, kps do holdActiveThisFrame[i] = false end

        for _, note in pairs(targetFolder:GetChildren()) do
            if note:IsA("ImageLabel") and not note.Name:find("Strum") then
                
                local laneIndex, targetStrum = GetNoteLaneInfo(note, myStrums)
                
                if laneIndex and targetStrum then
                    anyNoteSeenThisFrame = true
                    LastNoteSeenTime = tick()

                    local laneKey = currentMap[laneIndex]
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

                    local isHoldNote = (note.AbsoluteSize.Y > note.AbsoluteSize.X * 1.5)

                    if isHoldNote then
                        if noteTop <= laneCenterY + 15 and noteBottom >= laneCenterY - 15 then
                            holdActiveThisFrame[laneIndex] = true
                        end
                    else
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

        for i = 1, kps do
            local key = currentMap[i]
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
            LastYPositions = {}
            
            for i = 1, 18 do
                if CurrentlyDown[i] and currentMap[i] then
                    VirtualInputManager:SendKeyEvent(false, currentMap[i], false, game)
                    CurrentlyDown[i] = false
                end
            end
            LastNoteSeenTime = tick()
        end
    end)

    -- ==========================================
    -- 4. MISC & UNLOAD
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")

    MiscTab:CreateButton("Unload EMLOXA", function()
        AutoPlayerEnabled = false
        if SideUI then SideUI:Destroy() end
        
        for _, map in pairs(KeyMaps) do
            for _, k in ipairs(map) do VirtualInputManager:SendKeyEvent(false, k, false, game) end
        end
        
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
