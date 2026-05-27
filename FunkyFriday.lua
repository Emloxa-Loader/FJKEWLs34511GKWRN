-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY AUTO-PLAYER v19 (FLAWLESS SICK-STRIKE CORE)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

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
    -- 2. AUTO PLAYER (SICK-STRIKE CORE - FLAWLESS)
    -- ==========================================
    local FunkyTab = Window:CreateTab("Auto Player")
    local AutoPlayerEnabled = false
    local ShowVisualizer = false
    local Aggression = 15 -- "Sick" için varsayılanı düşürdük, tam üstündeyken vuracak.
    
    local LaneKeys = { Lane1 = Enum.KeyCode.A, Lane2 = Enum.KeyCode.S, Lane3 = Enum.KeyCode.W, Lane4 = Enum.KeyCode.D }

    FunkyTab:CreateToggle("Enable Auto Player (Flawless Mode)", function(s) AutoPlayerEnabled = s end)
    FunkyTab:CreateToggle("Show Visualizer Dots", function(s) ShowVisualizer = s end)
    FunkyTab:CreateSlider("Sick Range (Tetikleme)", 5, 50, 15, function(v) Aggression = v end)

    local function ManageVisualizerDot(parentObj, dotName, size, color)
        local dot = parentObj:FindFirstChild(dotName)
        if not dot then
            dot = Instance.new("Frame"); dot.Name = dotName; dot.Size = UDim2.new(0, size, 0, size); dot.Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
            dot.BackgroundColor3 = color; dot.BorderSizePixel = 0; dot.ZIndex = 999999
            Instance.new("UIStroke", dot).Thickness = 2; Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0); dot.Parent = parentObj
        end
        local transparency = ShowVisualizer and 0 or 1
        dot.BackgroundTransparency = transparency; dot.UIStroke.Transparency = transparency
    end

    -- Hafıza ve Tuş Takip Sistemi (Tuşların takılı kalmasını engeller)
    local TappedNotes = {}
    local CurrentlyPressed = {
        [Enum.KeyCode.A] = false,
        [Enum.KeyCode.S] = false,
        [Enum.KeyCode.W] = false,
        [Enum.KeyCode.D] = false
    }

    RunService.RenderStepped:Connect(function()
        if not AutoPlayerEnabled then
            -- Kapatıldığında güvenli çıkış: Eğer takılı tuş varsa hemen bırak!
            for _, key in pairs(LaneKeys) do
                if CurrentlyPressed[key] then
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                    CurrentlyPressed[key] = false
                end
            end
            return 
        end
        
        local ui = LocalPlayer.PlayerGui:FindFirstChild("Window")
        if not ui or not ui:FindFirstChild("Game") or not ui.Game:FindFirstChild("Fields") then return end
        
        local mySide = nil
        local scores = ui.Game:FindFirstChild("HUD") and ui.Game.HUD:FindFirstChild("Scores")
        if scores then
            for _, side in pairs({scores.Left, scores.Right}) do
                if side:FindFirstChild(LocalPlayer.Name) or side:FindFirstChild(LocalPlayer.DisplayName) then mySide = side.Name break end
            end
        end
        if not mySide then return end
        
        local inner = ui.Game.Fields[mySide].Inner

        -- Bu karede(frame) basılması gereken tuşları hazırlıyoruz
        local KeysToPressThisFrame = {}
        local KeysToHoldThisFrame = {}

        -- Notaları Tarama Mantığı
        for i = 1, 4 do
            local laneFrame = inner:FindFirstChild("Lane" .. i)
            if laneFrame then
                ManageVisualizerDot(laneFrame, "EmloxaTargetDot", 20, Color3.fromRGB(0, 0, 0))
                local laneCenterY = laneFrame.AbsolutePosition.Y + (laneFrame.AbsoluteSize.Y / 2)
                local notesFolder = laneFrame:FindFirstChild("Notes")
                
                if notesFolder then
                    local laneKey = LaneKeys["Lane" .. i]
                    
                    for _, note in pairs(notesFolder:GetChildren()) do
                        if note:IsA("GuiObject") then
                            ManageVisualizerDot(note, "EmloxaNoteDot", 14, Color3.fromRGB(50, 50, 50))
                            
                            -- Notanın Geometrik Sınırları
                            local noteTop = note.AbsolutePosition.Y
                            local noteBottom = noteTop + note.AbsoluteSize.Y
                            local noteCenterY = noteTop + (note.AbsoluteSize.Y / 2)
                            
                            local isHoldNote = #note:GetChildren() > 1
                            
                            if isHoldNote then
                                -- HOLD NOTASI: Notanın oku merkeze ulaştıysa ve kuyruğu henüz geçmediyse kesişim vardır.
                                if (noteTop <= laneCenterY + Aggression) and (noteBottom >= laneCenterY - Aggression) then
                                    KeysToHoldThisFrame[laneKey] = true
                                end
                            else
                                -- NORMAL NOTA: Sadece tam hedefin ortasındayken tetikle (Kusursuz Sick)
                                local dist = math.abs(noteCenterY - laneCenterY)
                                if dist <= Aggression then
                                    -- Object Pooling Koruması: Oyun aynı çerçeveyi (frame) yeniden kullanıyorsa atlama! (1 saniye zaman kuralı)
                                    if not TappedNotes[note] or (tick() - TappedNotes[note] > 1.0) then
                                        TappedNotes[note] = tick()
                                        KeysToPressThisFrame[laneKey] = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        -- ADIM 3: FİZİKSEL EYLEMLERİ UYGULAMA (GÜVENLİ YÖNETİM)
        for _, laneKey in pairs(LaneKeys) do
            local shouldTap = KeysToPressThisFrame[laneKey]
            local shouldHold = KeysToHoldThisFrame[laneKey]

            if shouldTap then
                -- Şoklama Vuruşu: Tuşu tetikle
                VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                CurrentlyPressed[laneKey] = true

                -- Normal nota çok hızlı olduğu için hemen geri çekilmeli (Hold notası gelmiyorsa)
                task.delay(0.015, function()
                    if not KeysToHoldThisFrame[laneKey] then
                        VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                        CurrentlyPressed[laneKey] = false
                    end
                end)
            elseif shouldHold then
                -- Sadece basılı değilse basılı tut komutu yolla
                if not CurrentlyPressed[laneKey] then
                    VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                    CurrentlyPressed[laneKey] = true
                end
            else
                -- EĞER EKRANDA O ŞERİTTE (LANE) BASILACAK HİÇBİR ŞEY YOKSA VE TUŞ BASILI KALMIŞSA -> ZORLA BIRAK
                if CurrentlyPressed[laneKey] then
                    VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                    CurrentlyPressed[laneKey] = false
                end
            end
        end
    end)

    -- ==========================================
    -- 3. MISC & CLEANUP
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")
    MiscTab:CreateButton("Clear Cache (Fix Memory)", function() TappedNotes = {} end)
    MiscTab:CreateButton("Unload EMLOXA", function()
        AutoPlayerEnabled = false
        task.wait(0.1) -- Tuşların sıfırlanması için kısa süre ver
        for _, key in pairs(LaneKeys) do VirtualInputManager:SendKeyEvent(false, key, false, game) end
        
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
