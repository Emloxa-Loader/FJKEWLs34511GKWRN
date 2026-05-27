-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY (4-CORE MULTI-THREADED SYSTEM)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local LocalPlayer = Players.LocalPlayer

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
    
    -- ==========================================
    -- 2. AUTO PLAYER (4 BAĞIMSIZ MOTOR SİSTEMİ)
    -- ==========================================
    local FunkyTab = Window:CreateTab("Auto Player")
    local AutoPlayerEnabled = false
    local Aggression = 25 
    
    local LaneKeys = { Lane1 = Enum.KeyCode.A, Lane2 = Enum.KeyCode.S, Lane3 = Enum.KeyCode.W, Lane4 = Enum.KeyCode.D }
    
    -- Her şerit için ayrı döngüleri tutacağımız tablo (Kapatmak için lazım)
    local LaneConnections = {}
    local ActiveHolds = {}
    local TappedNotes = {}

    FunkyTab:CreateSlider("Sick Range (Hassasiyet)", 10, 50, 25, function(v) Aggression = v end)

    -- ŞERİT MOTORU: Sadece kendisine atanan şeridi kontrol eden fonksiyon
    local function StartLaneEngine(laneIndex, mySide)
        local ui = LocalPlayer.PlayerGui:FindFirstChild("Window")
        local inner = ui and ui:FindFirstChild("Game") and ui.Game:FindFirstChild("Fields") and ui.Game.Fields[mySide].Inner
        if not inner then return end

        local laneFrame = inner:FindFirstChild("Lane" .. laneIndex)
        local laneKey = LaneKeys["Lane" .. laneIndex]
        
        if not laneFrame or not laneKey then return end

        -- Bu şeride özel, oyunun ekran yenileme hızına (FPS) kilitli bağımsız döngü
        LaneConnections[laneIndex] = RunService.RenderStepped:Connect(function()
            local laneCenterY = laneFrame.AbsolutePosition.Y + (laneFrame.AbsoluteSize.Y / 2)
            local notesFolder = laneFrame:FindFirstChild("Notes")
            
            if notesFolder then
                for _, note in pairs(notesFolder:GetChildren()) do
                    if note:IsA("GuiObject") then
                        local noteCenterY = note.AbsolutePosition.Y + (note.AbsoluteSize.Y / 2)
                        local dist = math.abs(noteCenterY - laneCenterY)
                        
                        -- Nota merkeze geldi mi?
                        if dist <= Aggression then
                            local isHoldNote = #note:GetChildren() > 1
                            
                            if isHoldNote then
                                if not ActiveHolds[note] then
                                    ActiveHolds[note] = laneKey
                                    VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                end
                            else
                                if not TappedNotes[note] then
                                    TappedNotes[note] = true
                                    -- Anlık vur ve bırak
                                    VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                                    VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                    task.delay(0.015, function()
                                        -- Eğer o sırada bir hold notası aktif değilse tuşu bırak
                                        local holding = false
                                        for hNote, k in pairs(ActiveHolds) do if k == laneKey and hNote.Parent then holding = true break end end
                                        if not holding then VirtualInputManager:SendKeyEvent(false, laneKey, false, game) end
                                    end)
                                end
                            end
                        end
                    end
                end
            end
            
            -- Bu şeritte biten Hold notalarını temizle
            for holdNote, key in pairs(ActiveHolds) do
                if key == laneKey and not holdNote.Parent then 
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                    ActiveHolds[holdNote] = nil
                end
            end
        end)
    end

    -- ANA AÇMA/KAPAMA ŞALTERİ
    FunkyTab:CreateToggle("Enable 4-Core God Mode", function(s) 
        AutoPlayerEnabled = s 
        
        if AutoPlayerEnabled then
            -- Hangi tarafta (Left/Right) oynadığımızı bul
            local ui = LocalPlayer.PlayerGui:FindFirstChild("Window")
            local scores = ui and ui:FindFirstChild("Game") and ui.Game:FindFirstChild("HUD") and ui.Game.HUD:FindFirstChild("Scores")
            local mySide = nil
            if scores then
                for _, side in pairs({scores.Left, scores.Right}) do
                    if side:FindFirstChild(LocalPlayer.Name) or side:FindFirstChild(LocalPlayer.DisplayName) then mySide = side.Name break end
                end
            end
            
            if mySide then
                -- 4 Motoru aynı anda birbirinden bağımsız şekilde çalıştır!
                for i = 1, 4 do
                    StartLaneEngine(i, mySide)
                end
            else
                warn("[EMLOXA WARE] Oyun tarafı bulunamadı, sahneye çıkmalısın!")
            end
        else
            -- 4 Motoru anında durdur
            for i = 1, 4 do
                if LaneConnections[i] then
                    LaneConnections[i]:Disconnect()
                    LaneConnections[i] = nil
                end
            end
            -- Basılı kalan tuşları temizle
            for _, key in pairs(LaneKeys) do VirtualInputManager:SendKeyEvent(false, key, false, game) end
            ActiveHolds = {}
        end
    end)

    -- ==========================================
    -- 3. MISC & OPTIMIZATION
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")
    
    MiscTab:CreateButton("Optimize Graphics (MAX FPS)", function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false
            elseif v:IsA("BasePart") and (v.Material == Enum.Material.Glass or v.Material == Enum.Material.Neon) then v.Material = Enum.Material.SmoothPlastic end
        end
        game:GetService("Lighting").GlobalShadows = false
        print("Emloxa Ware: Graphics Optimized!")
    end)

    MiscTab:CreateButton("Unload EMLOXA", function()
        for i = 1, 4 do if LaneConnections[i] then LaneConnections[i]:Disconnect() end end
        for _, key in pairs(LaneKeys) do VirtualInputManager:SendKeyEvent(false, key, false, game) end
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
