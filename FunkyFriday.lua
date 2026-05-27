-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY ULTIMATE FINAL (FULL KAPSAMLI ENGINE)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local LocalPlayer = Players.LocalPlayer

    -- ==========================================
    -- 1. KEYMAP (TÜM MODLAR İÇİN EKSİKSİZ)
    -- ==========================================
    local KeyMaps = {
        [4] = {Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Up, Enum.KeyCode.Right},
        [5] = {Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.Space, Enum.KeyCode.J, Enum.KeyCode.K},
        [6] = {Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.LeftControl},
        [7] = {Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.Space, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.LeftControl},
        [8] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.LeftControl, Enum.KeyCode.Semicolon},
        [9] = {Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.F, Enum.KeyCode.Space, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.LeftControl, Enum.KeyCode.Semicolon}
    }

    -- ==========================================
    -- 2. LOCAL PLAYER SEKME
    -- ==========================================
    local PlayerTab = Window:CreateTab("Local Player")
    
    PlayerTab:CreateToggle("Noclip (Pass Through)", function(s) 
        RunService.Stepped:Connect(function() 
            if s and LocalPlayer.Character then 
                for _, p in pairs(LocalPlayer.Character:GetDescendants()) do 
                    if p:IsA("BasePart") then p.CanCollide = false end 
                end 
            end 
        end)
    end)
    PlayerTab:CreateSlider("WalkSpeed", 16, 250, 16, function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end 
    end)
    PlayerTab:CreateSlider("JumpPower", 50, 350, 50, function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
            LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = v 
        end 
    end)

    -- ==========================================
    -- 3. AUTO PLAYER (FULL ENGINE)
    -- ==========================================
    local FunkyTab = Window:CreateTab("Auto Player")
    local AutoPlayerEnabled = false
    
    local ActiveHolds = {}
    local TappedNotes = {}
    local LastYPositions = {} 
    local CountedNotes = {}

    FunkyTab:CreateToggle("Enable Auto Player (Full Engine)", function(s) AutoPlayerEnabled = s end)

    RunService.RenderStepped:Connect(function(deltaTime)
        if not AutoPlayerEnabled then 
            -- Kapatıldığında tüm tuşları zorla bırak
            for holdNote, key in pairs(ActiveHolds) do
                VirtualInputManager:SendKeyEvent(false, key, false, game)
                ActiveHolds[holdNote] = nil
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
        
        local fields = ui.Game.Fields[mySide].Inner
        local laneCount = 0
        for _, obj in pairs(fields:GetChildren()) do if obj.Name:find("Lane") then laneCount = laneCount + 1 end end
        if laneCount == 0 or not KeyMaps[laneCount] then return end

        for i = 1, laneCount do
            local laneName = "Lane" .. i
            local laneFrame = fields:FindFirstChild(laneName)
            local laneKey = KeyMaps[laneCount][i]
            
            if laneFrame and laneKey then
                local laneCenterY = laneFrame.AbsolutePosition.Y + (laneFrame.AbsoluteSize.Y / 2)
                local notesFolder = laneFrame:FindFirstChild("Notes")
                
                if notesFolder then
                    for _, note in pairs(notesFolder:GetChildren()) do
                        if note:IsA("GuiObject") then
                            local noteTop = note.AbsolutePosition.Y
                            local noteBottom = noteTop + note.AbsoluteSize.Y
                            local noteCenterY = noteTop + (note.AbsoluteSize.Y / 2)
                            local dist = math.abs(noteCenterY - laneCenterY)
                            
                            -- Işınlanma/Object Pooling Koruması
                            if LastYPositions[note] and math.abs(noteCenterY - LastYPositions[note]) > 50 then
                                TappedNotes[note] = nil
                            end
                            LastYPositions[note] = noteCenterY

                            -- Hold Notası Tespiti
                            local childCount = 0
                            for _, c in ipairs(note:GetChildren()) do if c:IsA("GuiObject") then childCount = childCount + 1 end end
                            local isHoldNote = childCount > 1 or (note.AbsoluteSize.Y > note.AbsoluteSize.X * 1.5)

                            -- Kusursuz Sick Vuruşu (Dist <= 3 piksel tolerans)
                            if dist <= 3 and not TappedNotes[note] then
                                TappedNotes[note] = tick()
                                
                                if isHoldNote then
                                    ActiveHolds[note] = laneKey
                                    task.spawn(function() VirtualInputManager:SendKeyEvent(true, laneKey, false, game) end)
                                else
                                    task.spawn(function()
                                        VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                                        VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                        task.wait(0.01)
                                        VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                                    end)
                                end
                            end

                            -- Hold Notası Bırakma
                            if isHoldNote and TappedNotes[note] then
                                if noteBottom < laneCenterY - 10 then 
                                    if ActiveHolds[note] then
                                        task.spawn(function() VirtualInputManager:SendKeyEvent(false, laneKey, false, game) end)
                                        ActiveHolds[note] = nil
                                    end
                                end
                            end
                        end
                    end
                end
                
                -- Hafıza Temizliği
                for holdNote, key in pairs(ActiveHolds) do
                    if key == laneKey and not holdNote.Parent then 
                        task.spawn(function() VirtualInputManager:SendKeyEvent(false, key, false, game) end)
                        ActiveHolds[holdNote] = nil
                    end
                end
            end
        end
    end)

    -- ==========================================
    -- 4. MISC & OPTIMIZATION (FULL PACK)
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")
    
    MiscTab:CreateButton("Optimize Graphics (MAX FPS)", function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false
            elseif v:IsA("BasePart") and (v.Material == Enum.Material.Glass or v.Material == Enum.Material.Neon) then v.Material = Enum.Material.SmoothPlastic end
        end
        game:GetService("Lighting").GlobalShadows = false
    end)

    MiscTab:CreateButton("Unload EMLOXA WARE", function()
        AutoPlayerEnabled = false
        for _, keys in pairs(KeyMaps) do
            for _, key in pairs(keys) do VirtualInputManager:SendKeyEvent(false, key, false, game) end
        end
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
