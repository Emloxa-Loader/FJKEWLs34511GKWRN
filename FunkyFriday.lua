-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY AUTO-PLAYER v19 (FLAWLESS "SICK" CORE)
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
    local NoclipEnabled = false
    
    PlayerTab:CreateToggle("Noclip (Pass Through)", function(s) NoclipEnabled = s end)
    PlayerTab:CreateSlider("WalkSpeed", 16, 250, 16, function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end 
    end)
    PlayerTab:CreateSlider("JumpPower", 50, 350, 50, function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = v end 
    end)

    -- ==========================================
    -- 2. AUTO PLAYER (FLAWLESS SICK CORE)
    -- ==========================================
    local FunkyTab = Window:CreateTab("Auto Player")
    local AutoPlayerEnabled = false
    local SickWindow = 12 -- "Sick" isabeti için optimum piksel aralığı (Çok hassas)
    
    local LaneKeys = { Lane1 = Enum.KeyCode.A, Lane2 = Enum.KeyCode.S, Lane3 = Enum.KeyCode.W, Lane4 = Enum.KeyCode.D }

    FunkyTab:CreateToggle("Enable Auto Player (Flawless Mode)", function(s) AutoPlayerEnabled = s end)
    FunkyTab:CreateSlider("Sick Hit Window (Accuracy)", 5, 40, 12, function(v) SickWindow = v end)

    -- Akıllı Hafıza (Garbage Collection). Oyun notayı sildiğinde tablodan da otomatik silinir, RAM şişmez.
    local TappedNotes = setmetatable({}, {__mode = "k"})
    local LastNotePositions = setmetatable({}, {__mode = "k"})
    local HeldNotes = {} -- [laneKey] = {Note = noteObj}

    -- Oyun bittiğinde veya kapandığında basılı kalan tuşları temizler
    local function ReleaseAllKeys()
        for _, key in pairs(LaneKeys) do
            VirtualInputManager:SendKeyEvent(false, key, false, game)
        end
        HeldNotes = {}
    end

    RunService.RenderStepped:Connect(function()
        if not AutoPlayerEnabled then return end
        
        local ui = LocalPlayer.PlayerGui:FindFirstChild("Window")
        if not ui or not ui:FindFirstChild("Game") or not ui.Game:FindFirstChild("Fields") then 
            ReleaseAllKeys() -- Arayüz yoksa, şarkı bittiyse tuşları bırak
            return 
        end
        
        local mySide = nil
        local scores = ui.Game:FindFirstChild("HUD") and ui.Game.HUD:FindFirstChild("Scores")
        if scores then
            for _, side in pairs({scores.Left, scores.Right}) do
                if side:FindFirstChild(LocalPlayer.Name) or side:FindFirstChild(LocalPlayer.DisplayName) then 
                    mySide = side.Name 
                    break 
                end
            end
        end
        if not mySide then return end
        
        local inner = ui.Game.Fields[mySide].Inner

        for i = 1, 4 do
            local laneFrame = inner:FindFirstChild("Lane" .. i)
            if laneFrame then
                local laneCenterY = laneFrame.AbsolutePosition.Y + (laneFrame.AbsoluteSize.Y / 2)
                local notesFolder = laneFrame:FindFirstChild("Notes")
                local laneKey = LaneKeys["Lane" .. i]
                
                if notesFolder then
                    -- 1. HOLD (UZUN) NOTA BİTİŞ KONTROLÜ
                    if HeldNotes[laneKey] then
                        local activeNote = HeldNotes[laneKey].Note
                        -- Eğer nota ekrandan silindiyse veya bittiyse tuşu sal
                        if not activeNote or not activeNote.Parent or not activeNote:IsDescendantOf(notesFolder) then
                            VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                            HeldNotes[laneKey] = nil
                        end
                    end

                    -- 2. YENİ GELEN NOTALARI İŞLEME
                    for _, note in pairs(notesFolder:GetChildren()) do
                        if note:IsA("GuiObject") and not TappedNotes[note] then
                            local noteCenterY = note.AbsolutePosition.Y + (note.AbsoluteSize.Y / 2)
                            local dist = math.abs(noteCenterY - laneCenterY)
                            
                            -- ANTİ-MİSS SİSTEMİ (Frame Drop Koruması)
                            -- Nota bir önceki frame'de merkezden uzaktaysa ve şimdi merkezi ışınlanarak geçtiyse yakala
                            local lastY = LastNotePositions[note]
                            local crossedCenter = false
                            if lastY then
                                if (lastY > laneCenterY and noteCenterY <= laneCenterY) or (lastY < laneCenterY and noteCenterY >= laneCenterY) then
                                    crossedCenter = true
                                end
                            end
                            LastNotePositions[note] = noteCenterY
                            
                            -- VURUŞ ANI (Kusursuz Sick aralığında veya FPS drop yüzünden merkezi atladıysa)
                            if dist <= SickWindow or crossedCenter then
                                TappedNotes[note] = true
                                
                                -- Hold Note Tespiti: Notaların Y boyutu, X boyutundan %20 daha büyükse %100 hold notasıdır
                                local isHoldNote = note.AbsoluteSize.Y > (note.AbsoluteSize.X * 1.2)
                                
                                -- Ardışık hızlı notalar (Jacks) için önce tuşu SIFIRLA ve tekrar bas
                                VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                                VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                
                                if isHoldNote then
                                    -- Hold notayı hafızaya al, bitene kadar basılı kalacak
                                    HeldNotes[laneKey] = {Note = note}
                                else
                                    -- Normal nota ise sadece 1 frame bekleyip tuşu bırak (İnsanüstü tepki süresi)
                                    task.spawn(function()
                                        RunService.RenderStepped:Wait() 
                                        -- Eğer tam o frame'de yeni bir hold nota gelmediyse tuşu kaldır
                                        if not HeldNotes[laneKey] then
                                            VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                                        end
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
    -- 3. MISC & CLEANUP
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")
    MiscTab:CreateButton("Clear Cache (Fix Stuck Keys)", function() ReleaseAllKeys() end)
    MiscTab:CreateButton("Unload EMLOXA", function()
        ReleaseAllKeys()
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
