-- =========================================================================
-- EMLOXA WARE: PROJECT AFTERNIGHT (PLACE: 13042495892)
-- V16 ADAPTIVE PRECISION ENGINE (AUTO-MODE DETECTION & UI)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    -- ==========================================
    -- 1. MODERN UI (ÜST: YÖN / ALT: MOD)
    -- ==========================================
    local CurrentSide = "Right"
    local SideUI = Instance.new("ScreenGui")
    SideUI.Name = "EmloxaAfternightSideUI"
    SideUI.ResetOnSpawn = false
    
    local success = pcall(function() SideUI.Parent = game:GetService("CoreGui") end)
    if not success then SideUI.Parent = LocalPlayer.PlayerGui end

    -- Üst Panel (Yön Seçici)
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

    -- Alt Panel (Mod Algılayıcı)
    local ModeFrame = Instance.new("Frame")
    ModeFrame.Size = UDim2.new(0, 200, 0, 35)
    ModeFrame.Position = UDim2.new(0.5, -100, 1, -50) -- Ekranın orta alt kısmı
    ModeFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    ModeFrame.BorderSizePixel = 0
    ModeFrame.Parent = SideUI

    local UICornerMode = Instance.new("UICorner")
    UICornerMode.CornerRadius = UDim.new(0, 8)
    UICornerMode.Parent = ModeFrame

    local UIStrokeMode = Instance.new("UIStroke")
    UIStrokeMode.Color = Color3.fromRGB(0, 255, 150) -- Neon Yeşil
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
            CurrentSide = (CurrentSide == "Right") and "Left" or "Right"
            SideText.Text = "EMLOXA: " .. CurrentSide:upper() .. " [Y]"
            UIStroke.Color = (CurrentSide == "Left") and Color3.fromRGB(255, 85, 85) or Color3.fromRGB(102, 85, 255)
        end
    end)

    -- ==========================================
    -- 2. DYNAMIC KEYMAPS
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
    -- 3. CORE AUTO-PLAYER ENGINE
    -- ==========================================
    local AutoPlayerEnabled = false
    local AutoplayMethod = "Hybrid"
    local TappedNotes = {}
    local LastNoteSeenTime = tick()
    local CurrentlyDown = {}

    local ProjectTab = Window:CreateTab("Auto Player")
    local AdvancedTab = Window:CreateTab("Advanced")

    ProjectTab:CreateToggle("Enable Precision Engine V16", function(s) AutoPlayerEnabled = s end)
    AdvancedTab:CreateDropdown("Autoplay Method", {"Calculate", "Rapid checks", "Hybrid"}, "Hybrid", function(val) AutoplayMethod = val end)

    -- Klasör ve Mod Tarayıcı (Senin istediğin özel mantık)
    local function GetTargetFolderAndMode(MainGame)
        for _, child in pairs(MainGame:GetChildren()) do
            -- İsmi 5K, 6K, 9K vb. olan bir obje bulursa direkt o modu ve klasörü döndür
            local matchStr = string.match(child.Name, "^(%d+)K")
            if matchStr then
                return tonumber(matchStr), child
            end
        end
        -- Eğer hiçbir #K klasörü bulamazsa, demek ki oyun 4K modunda ve notalar ana dizinde.
        return 4, MainGame
    end

    local function FindTargetLaneByX(noteX, targetStrums)
        local bestIdx, bestStrum, minDist = nil, nil, 50 
        for i, strum in ipairs(targetStrums) do
            local strumX = strum.AbsolutePosition.X + (strum.AbsoluteSize.X / 2)
            local dist = math.abs(noteX - strumX)
            
            if dist < minDist then
                minDist = dist
                bestIdx = i
                bestStrum = strum
            end
        end
        return bestIdx, bestStrum
    end

    -- ==========================================
    -- 4. RENDER STEPPED (PÜRÜZSÜZ DÖNGÜ)
    -- ==========================================
    RunService.RenderStepped:Connect(function()
        if not AutoPlayerEnabled then return end
        
        local MainUI = LocalPlayer.PlayerGui:FindFirstChild("Main")
        local MainGame = MainUI and MainUI:FindFirstChild("Game")
        if not MainGame then 
            ModeText.Text = "WAITING FOR SONG..."
            return 
        end

        -- Modu ve hedef klasörü bul
        local kps, targetFolder = GetTargetFolderAndMode(MainGame)
        
        -- UI'ı anında güncelle
        if ModeText.Text ~= "DETECTED MODE: " .. kps .. "K" then
            ModeText.Text = "DETECTED MODE: " .. kps .. "K"
        end
        
        local currentMap = KeyMaps[kps] or KeyMaps[4]
        local startIndex = (CurrentSide == "Left") and 0 or kps
        local myStrums = {}
        
        -- Strum'ları hedef klasörün (targetFolder) içinden çek
        for i = 1, kps do
            local s = targetFolder:FindFirstChild("Strum" .. (startIndex + i - 1))
            if s then table.insert(myStrums, s) end
        end

        local anyNoteSeen = false
        local holdActive = {}
        for i = 1, kps do holdActive[i] = false end

        -- Notaları da hedef klasörün (targetFolder) içinden tara
        for _, note in pairs(targetFolder:GetChildren()) do
            if note:IsA("ImageLabel") and not note.Name:find("Strum") then
                
                local noteX = note.AbsolutePosition.X + (note.AbsoluteSize.X / 2)
                local lIdx, targetS = FindTargetLaneByX(noteX, myStrums)
                
                if lIdx and targetS then
                    anyNoteSeen = true
                    LastNoteSeenTime = tick()
                    
                    local key = currentMap[lIdx]
                    local sCenterY = targetS.AbsolutePosition.Y + (targetS.AbsoluteSize.Y / 2)
                    local noteCenterY = note.AbsolutePosition.Y + (note.AbsoluteSize.Y / 2)
                    
                    local distY = math.abs(noteCenterY - sCenterY)
                    local isHold = (note.AbsoluteSize.Y > note.AbsoluteSize.X * 1.5)

                    if isHold then
                        local noteTop = note.AbsolutePosition.Y
                        local noteBottom = noteTop + note.AbsoluteSize.Y
                        
                        if noteTop <= sCenterY + 15 and noteBottom >= sCenterY - 15 then 
                            holdActive[lIdx] = true 
                        end
                    else
                        local hitThreshold = (AutoplayMethod == "Rapid checks") and 10 or 15
                        
                        if distY <= hitThreshold and not TappedNotes[note] then
                            TappedNotes[note] = true
                            
                            task.spawn(function()
                                VirtualInputManager:SendKeyEvent(false, key, false, game)
                                VirtualInputManager:SendKeyEvent(true, key, false, game)
                                task.wait(0.02)
                                if not holdActive[lIdx] then
                                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                                end
                            end)
                        end
                    end
                end
            end
        end

        for i = 1, kps do
            local k = currentMap[i]
            if k then
                if holdActive[i] and not CurrentlyDown[k] then
                    CurrentlyDown[k] = true
                    VirtualInputManager:SendKeyEvent(true, k, false, game)
                elseif not holdActive[i] and CurrentlyDown[k] then
                    CurrentlyDown[k] = false
                    VirtualInputManager:SendKeyEvent(false, k, false, game)
                end
            end
        end

        if not anyNoteSeen and (tick() - LastNoteSeenTime > 1.5) then
            TappedNotes = {}
            for i = 1, 18 do
                if CurrentlyDown[i] and currentMap[i] then
                    VirtualInputManager:SendKeyEvent(false, currentMap[i], false, game)
                end
                CurrentlyDown[i] = false
            end
            LastNoteSeenTime = tick()
        end
    end)

    -- ==========================================
    -- 5. UNLOAD & CLEANUP
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")
    MiscTab:CreateButton("Unload Emloxa", function()
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
