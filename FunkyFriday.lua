-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY ULTRA-OPTIMIZED CORE (GOD MODE)
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
    -- 2. AUTO PLAYER (ULTRA FAST)
    -- ==========================================
    local FunkyTab = Window:CreateTab("Auto Player")
    local AutoPlayerEnabled = false
    local Aggression = 25 
    
    local LaneKeys = { Lane1 = Enum.KeyCode.A, Lane2 = Enum.KeyCode.S, Lane3 = Enum.KeyCode.W, Lane4 = Enum.KeyCode.D }

    FunkyTab:CreateToggle("Enable God Mode", function(s) AutoPlayerEnabled = s end)
    FunkyTab:CreateSlider("Sick Range (Hassasiyet)", 10, 50, 25, function(v) Aggression = v end)

    -- Görünmez noktaları hazırlama (Görünmez ama oyun mantığı için varlar)
    local function CreateInvisibleDot(parentObj)
        local dot = Instance.new("Frame")
        dot.Name = "EmloxaDot"
        dot.Size = UDim2.new(0, 14, 0, 14)
        dot.Position = UDim2.new(0.5, -7, 0.5, -7)
        dot.BackgroundTransparency = 1 -- Görünmez
        dot.BorderSizePixel = 0
        dot.Parent = parentObj
        return dot
    end

    local TappedNotes = {}
    local ActiveHolds = {}

    RunService.RenderStepped:Connect(function()
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
        
        local inner = ui.Game.Fields[mySide].Inner

        -- Hold temizliği
        for holdNote, key in pairs(ActiveHolds) do
            if not holdNote.Parent then 
                VirtualInputManager:SendKeyEvent(false, key, false, game)
                ActiveHolds[holdNote] = nil
            end
        end

        for i = 1, 4 do
            local laneFrame = inner:FindFirstChild("Lane" .. i)
            if laneFrame then
                local laneCenterY = laneFrame.AbsolutePosition.Y + (laneFrame.AbsoluteSize.Y / 2)
                local notesFolder = laneFrame:FindFirstChild("Notes")
                
                if notesFolder then
                    local laneKey = LaneKeys["Lane" .. i]
                    
                    for _, note in pairs(notesFolder:GetChildren()) do
                        if note:IsA("GuiObject") then
                            -- Görünmez nokta varlığı
                            if not note:FindFirstChild("EmloxaDot") then CreateInvisibleDot(note) end
                            
                            local noteCenterY = note.AbsolutePosition.Y + (note.AbsoluteSize.Y / 2)
                            local dist = math.abs(noteCenterY - laneCenterY)
                            
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
                                        task.spawn(function()
                                            VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                            task.wait(0.015)
                                            VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    -- ==========================================
    -- 3. MISC & ULTRA OPTIMIZATION
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")
    
    MiscTab:CreateButton("Optimize Graphics (MAX FPS)", function()
        -- Dokuları, parçacıkları ve ağır her şeyi kapat
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Explosion") then
                v.Enabled = false
            elseif v:IsA("BasePart") and (v.Material == Enum.Material.Glass or v.Material == Enum.Material.Neon) then
                v.Material = Enum.Material.SmoothPlastic
            end
        end
        game:GetService("Lighting").GlobalShadows = false
        game:GetService("Lighting").FogEnd = 9999
        print("Emloxa Ware: Graphics Optimized!")
    end)

    MiscTab:CreateButton("Unload EMLOXA", function()
        AutoPlayerEnabled = false
        for _, key in pairs(ActiveHolds) do VirtualInputManager:SendKeyEvent(false, key, false, game) end
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
