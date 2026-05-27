-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY V28 (AUTO-KEY & DYNAMIC LANE ENGINE)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local LocalPlayer = Players.LocalPlayer

    -- ==========================================
    -- 1. KEYMAP (Senin İstediğin Tuş Düzeni)
    -- ==========================================
    local KeyMaps = {
        [4] = {Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Up, Enum.KeyCode.Right},
        [5] = {Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.Space, Enum.KeyCode.J, Enum.KeyCode.K},
        [6] = {Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.LeftControl}, -- "Sol" olarak LeftControl
        [7] = {Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.Space, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.LeftControl},
        [8] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.LeftControl, Enum.KeyCode.Semicolon},
        [9] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.Space, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.LeftControl, Enum.KeyCode.Semicolon}
    }

    -- ==========================================
    -- 2. AUTO PLAYER (DYNAMIC ENGINE)
    -- ==========================================
    local FunkyTab = Window:CreateTab("Auto Player")
    local AutoPlayerEnabled = false
    local ActiveHolds = {}
    local TappedNotes = {}
    local LastYPositions = {} 
    local CountedNotes = {}

    FunkyTab:CreateToggle("Enable Auto Player (Auto-Key Mode)", function(s) AutoPlayerEnabled = s end)

    RunService.RenderStepped:Connect(function(deltaTime)
        if not AutoPlayerEnabled then return end
        
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
        
        local fields = ui.Game.Fields[mySide].Inner
        
        -- DİNAMİK LANE SAYISI (Ekranda kaç lane varsa onu al)
        local laneCount = 0
        for _, obj in pairs(fields:GetChildren()) do if obj.Name:find("Lane") then laneCount = laneCount + 1 end end
        if laneCount == 0 or not KeyMaps[laneCount] then return end

        for i = 1, laneCount do
            local laneName = "Lane" .. i
            local laneFrame = fields:FindFirstChild(laneName)
            local laneKey = KeyMaps[laneCount][i] -- Tuş haritasından otomatik seç
            
            if laneFrame and laneKey then
                local laneCenterY = laneFrame.AbsolutePosition.Y + (laneFrame.AbsoluteSize.Y / 2)
                local notesFolder = laneFrame:FindFirstChild("Notes")
                
                if notesFolder then
                    for _, note in pairs(notesFolder:GetChildren()) do
                        if note:IsA("GuiObject") then
                            local noteCenterY = note.AbsolutePosition.Y + (note.AbsoluteSize.Y / 2)
                            local dist = math.abs(noteCenterY - laneCenterY)
                            
                            -- Işınlanma Koruması
                            if LastYPositions[note] and math.abs(noteCenterY - LastYPositions[note]) > 50 then
                                TappedNotes[note] = nil
                            end
                            LastYPositions[note] = noteCenterY

                            -- Hold Tespit
                            local childCount = 0
                            for _, c in ipairs(note:GetChildren()) do if c:IsA("GuiObject") then childCount = childCount + 1 end end
                            local isHoldNote = childCount > 1 or (note.AbsoluteSize.Y > note.AbsoluteSize.X * 1.5)

                            -- Vuruş (Sick için tam merkez toleransı: 3 piksel)
                            if dist <= 3 and not TappedNotes[note] then
                                TappedNotes[note] = tick()
                                
                                if isHoldNote then
                                    ActiveHolds[note] = laneKey
                                    task.spawn(function() VirtualInputManager:SendKeyEvent(true, laneKey, false, game) end)
                                else
                                    task.spawn(function()
                                        VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                        task.wait(0.01)
                                        VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                                    end)
                                end
                            end

                            -- Hold Bırakma
                            if isHoldNote and TappedNotes[note] then
                                if note.AbsolutePosition.Y + note.AbsoluteSize.Y < laneCenterY - 10 then 
                                    if ActiveHolds[note] then
                                        task.spawn(function() VirtualInputManager:SendKeyEvent(false, laneKey, false, game) end)
                                        ActiveHolds[note] = nil
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- Hata Payı Temizliği
                for holdNote, key in pairs(ActiveHolds) do
                    if key == laneKey and not holdNote.Parent then 
                        task.spawn(function() VirtualInputManager:SendKeyEvent(false, key, false, game) end)
                        ActiveHolds[holdNote] = nil
                    end
                end
            end
        end
    end)

    -- Misc
    local MiscTab = Window:CreateTab("Misc")
    MiscTab:CreateButton("Unload EMLOXA", function()
        AutoPlayerEnabled = false
        for _, keys in pairs(KeyMaps) do
            for _, key in pairs(keys) do VirtualInputManager:SendKeyEvent(false, key, false, game) end
        end
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
