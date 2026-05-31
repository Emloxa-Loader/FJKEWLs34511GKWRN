-- =========================================================================
-- EMLOXA WARE: PROJECT AFTERNIGHT (PLACE: 13042495892)
-- V14 NEBULA ENGINE - VECTOR & DYNAMIC MULTI-KEY OPTIMIZED
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    -- ==========================================
    -- 1. SIDE SELECTOR UI (ŞIK & MODERN)
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

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Y then
            CurrentSide = (CurrentSide == "Right") and "Left" or "Right"
            SideText.Text = "EMLOXA: " .. CurrentSide:upper() .. " [Y]"
            UIStroke.Color = (CurrentSide == "Left") and Color3.fromRGB(255, 85, 85) or Color3.fromRGB(102, 85, 255)
        end
    end)

    -- ==========================================
    -- 2. DYNAMIC KEYMAPS (FOTOĞRAFLARA TAM UYUMLU)
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
    local LastPositions = {} 
    local LastNoteSeenTime = tick()
    local CurrentlyDown = {}

    local ProjectTab = Window:CreateTab("Auto Player")
    local AdvancedTab = Window:CreateTab("Advanced")

    ProjectTab:CreateToggle("Enable Nebula Engine V14", function(s) AutoPlayerEnabled = s end)
    AdvancedTab:CreateDropdown("Autoplay Method", {"Calculate", "Rapid checks", "Hybrid"}, "Hybrid", function(val) AutoplayMethod = val end)

    -- Optimizasyon: Her karede Strum'ları aramak yerine, değiştikçe bul
    local CachedStrums = {}
    local function GetStrumData(MainGame)
        local total = 0
        local all = {}
        for _, obj in pairs(MainGame:GetChildren()) do
            if obj.Name:find("Strum") then
                total = total + 1
                table.insert(all, obj)
            end
        end
        return total, all
    end

    -- Vektörel Hedefleme (Hangi lane'e ait olduğunu bulma)
    local function FindTargetLane(noteCenter, velocity, targetStrums)
        local bestIdx, bestStrum, minScore = nil, nil, 100000
        for i, strum in ipairs(targetStrums) do
            local strumPos = strum.AbsolutePosition + (strum.AbsoluteSize / 2)
            local dist = (noteCenter - strumPos).Magnitude
            
            -- Modchart (Hareketli şerit) desteği: Hız vektörü ile strum arasındaki açıya bak
            local score = dist
            if velocity.Magnitude > 10 then
                local alignment = velocity.Unit:Dot((strumPos - noteCenter).Unit)
                score = dist - (alignment * 200) -- Eğer nota strum'a doğru uçuyorsa puanı artır (mesafeyi düşük gör)
            end

            if score < minScore then
                minScore = score
                bestIdx = i
                bestStrum = strum
            end
        end
        return bestIdx, bestStrum
    end

    -- ==========================================
    -- 4. RENDER STEPPED (MİLİSANİYELİK REFLEKS)
    -- ==========================================
    RunService.RenderStepped:Connect(function(deltaTime)
        if not AutoPlayerEnabled then return end
        
        local MainUI = LocalPlayer.PlayerGui:FindFirstChild("Main")
        local MainGame = MainUI and MainUI:FindFirstChild("Game")
        if not MainGame then return end

        -- 4K Klasörü gelse de gelmese de Strum sayısından modu otomatik bul
        local totalStrums, allStrums = GetStrumData(MainGame)
        local kps = math.floor(totalStrums / 2)
        if kps == 0 then return end
        
        local currentMap = KeyMaps[kps] or KeyMaps[4]
        local startIndex = (CurrentSide == "Left") and 0 or kps
        local myStrums = {}
        for i = 1, kps do
            local s = MainGame:FindFirstChild("Strum" .. (startIndex + i - 1))
            if s then table.insert(myStrums, s) end
        end

        local anyNoteSeen = false
        local holdActive = {}
        for i = 1, kps do holdActive[i] = false end

        -- Obje Havuzu Tarama
        for _, note in pairs(MainGame:GetChildren()) do
            if note:IsA("ImageLabel") and not note.Name:find("Strum") then
                local noteCenter = note.AbsolutePosition + (note.AbsoluteSize / 2)
                
                -- Hız ve Hareket Takibi
                local velocity = Vector2.new(0, 0)
                if LastPositions[note] then
                    local deltaPos = (noteCenter - LastPositions[note])
                    if deltaPos.Magnitude > 80 then TappedNotes[note] = nil -- Işınlanma/Reset
                    else velocity = deltaPos / deltaTime end
                end
                LastPositions[note] = noteCenter

                -- Hedef Strum'u Belirle
                local lIdx, targetS = FindTargetLane(noteCenter, velocity, myStrums)
                
                if lIdx and targetS then
                    anyNoteSeen = true
                    LastNoteSeenTime = tick()
                    
                    local key = currentMap[lIdx]
                    local sCenter = targetS.AbsolutePosition + (targetS.AbsoluteSize / 2)
                    local dist = (noteCenter - sCenter).Magnitude
                    local isHold = (note.AbsoluteSize.Y > note.AbsoluteSize.X * 1.5)

                    if isHold then
                        -- Hold Note (Kuyruk) Algılama: Strum notanın içindeyse basılı tut
                        local xMatch = math.abs(noteCenter.X - sCenter.X) < (note.AbsoluteSize.X / 2 + 10)
                        local yMatch = math.abs(noteCenter.Y - sCenter.Y) < (note.AbsoluteSize.Y / 2 + 10)
                        if xMatch and yMatch then holdActive[lIdx] = true end
                    else
                        -- Tap Note (Kafa) Algılama
                        local travel = velocity.Magnitude * deltaTime
                        local threshold = (AutoplayMethod == "Rapid checks") and 5 or math.max(4, travel / 1.2)
                        
                        if dist <= threshold and not TappedNotes[note] then
                            TappedNotes[note] = true
                            task.spawn(function()
                                VirtualInputManager:SendKeyEvent(false, key, false, game) -- Temiz basış
                                VirtualInputManager:SendKeyEvent(true, key, false, game)
                                task.wait(0.035)
                                if not holdActive[lIdx] then
                                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                                end
                            end)
                        end
                    end
                end
            end
        end

        -- Tuş Durumu Yönetimi
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

        -- Optimizasyon: Memory Leak'i Engelle (Giden notaları sil)
        if tick() - LastNoteSeenTime > 2 then
            TappedNotes = {}
            LastPositions = {}
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
