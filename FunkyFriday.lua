-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY V23 (ULTIMATE PRECISION & TELEPORT FIX)
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
    -- 2. AUTO PLAYER (MILLISECOND ENGINE)
    -- ==========================================
    local FunkyTab = Window:CreateTab("Auto Player")
    local AdvancedTab = Window:CreateTab("Advanced")
    
    local AutoPlayerEnabled = false
    local Aggression = 15 
    local AutoplayMethod = "Hybrid"
    
    local LaneKeys = { Lane1 = Enum.KeyCode.A, Lane2 = Enum.KeyCode.S, Lane3 = Enum.KeyCode.W, Lane4 = Enum.KeyCode.D }
    
    -- Şerit İstatistikleri
    local LaneStats = {
        Lane1 = {Seen = 0, Taps = 0},
        Lane2 = {Seen = 0, Taps = 0},
        Lane3 = {Seen = 0, Taps = 0},
        Lane4 = {Seen = 0, Taps = 0}
    }
    
    local ActiveHolds = {}
    local TappedNotes = {}
    local CountedNotes = {} 
    local LastYPositions = {} -- Işınlanma (Object Pooling) Kontrolü İçin

    FunkyTab:CreateToggle("Enable God Mode (Mili-Sec Engine)", function(s) AutoPlayerEnabled = s end)
    FunkyTab:CreateSlider("Sick Hitbox Range", 5, 50, 15, function(v) Aggression = v end)
    AdvancedTab:CreateDropdown("Autoplay Method", {"Calculate", "Rapid checks", "Hybrid"}, "Hybrid", function(val) AutoplayMethod = val end)

    -- Şerit Üstü İstatistik UI
    local function UpdateLaneStats(laneFrame, laneName)
        local statLabel = laneFrame:FindFirstChild("EmloxaStats")
        if not statLabel then
            statLabel = Instance.new("TextLabel")
            statLabel.Name = "EmloxaStats"
            statLabel.Size = UDim2.new(1, 0, 0, 30)
            statLabel.Position = UDim2.new(0, 0, 0, -35)
            statLabel.BackgroundTransparency = 1
            statLabel.Font = Enum.Font.GothamBold
            statLabel.TextSize = 13
            statLabel.TextColor3 = Color3.fromRGB(102, 85, 255)
            statLabel.TextStrokeTransparency = 0
            statLabel.Parent = laneFrame
        end
        statLabel.Text = "Seen: " .. LaneStats[laneName].Seen .. " | Taps: " .. LaneStats[laneName].Taps
    end

    -- Dinamik Nokta (Siyah -> Yeşil)
    local function ManageDynamicDot(note, dist)
        local dot = note:FindFirstChild("EmloxaDynamicDot")
        if not dot then
            dot = Instance.new("Frame")
            dot.Name = "EmloxaDynamicDot"
            dot.Size = UDim2.new(0, 8, 0, 8) -- Daha küçük
            dot.Position = UDim2.new(0.5, -4, 0.5, -4)
            dot.BorderSizePixel = 0
            dot.ZIndex = 999999
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = dot
            dot.Parent = note
        end

        if dist > 150 then
            dot.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Uzaksa Siyah
        else
            local intensity = math.clamp(1 - (dist / 150), 0, 1)
            dot.BackgroundColor3 = Color3.fromRGB(0, math.floor(255 * intensity), 0) -- Yaklaştıkça Parlak Yeşil
        end
    end

    -- ==========================================
    -- MİLİSANİYELİK RENDER DÖNGÜSÜ (UI İÇİN EN HIZLI METOT)
    -- ==========================================
    RunService.RenderStepped:Connect(function(deltaTime)
        if not AutoPlayerEnabled then
            for holdNote, key in pairs(ActiveHolds) do
                VirtualInputManager:SendKeyEvent(false, key, false, game)
                ActiveHolds[holdNote] = nil
            end
            return 
        end
        
        local ui = LocalPlayer.PlayerGui:FindFirstChild("Window")
        local inner = ui and ui:FindFirstChild("Game") and ui.Game:FindFirstChild("Fields")
        if not inner then return end
        
        local mySide = nil
        local scores = ui.Game:FindFirstChild("HUD") and ui.Game.HUD:FindFirstChild("Scores")
        if scores then
            for _, side in pairs({scores.Left, scores.Right}) do
                if side:FindFirstChild(LocalPlayer.Name) or side:FindFirstChild(LocalPlayer.DisplayName) then mySide = side.Name break end
            end
        end
        if not mySide then return end
        
        local fields = inner[mySide].Inner

        for i = 1, 4 do
            local laneName = "Lane" .. i
            local laneFrame = fields:FindFirstChild(laneName)
            local laneKey = LaneKeys[laneName]
            
            if laneFrame then
                UpdateLaneStats(laneFrame, laneName)
                
                local laneCenterY = laneFrame.AbsolutePosition.Y + (laneFrame.AbsoluteSize.Y / 2)
                local notesFolder = laneFrame:FindFirstChild("Notes")
                
                if notesFolder then
                    for _, note in pairs(notesFolder:GetChildren()) do
                        if note:IsA("GuiObject") then
                            local noteTop = note.AbsolutePosition.Y
                            local noteBottom = noteTop + note.AbsoluteSize.Y
                            local noteCenterY = noteTop + (note.AbsoluteSize.Y / 2)
                            local dist = math.abs(noteCenterY - laneCenterY)
                            
                            -- IŞINLANMA (OBJECT POOLING) KONTROLÜ
                            if LastYPositions[note] then
                                -- Eğer nota aniden 100 pikselden fazla sıçradıysa (tepeye ışınlandıysa)
                                if math.abs(noteCenterY - LastYPositions[note]) > 100 then
                                    CountedNotes[note] = nil
                                    TappedNotes[note] = nil
                                end
                            end
                            LastYPositions[note] = noteCenterY

                            -- Nota ekrana girip yaklaşmaya başladığında "Seen" sayacını artır
                            if dist < 400 and not CountedNotes[note] then
                                CountedNotes[note] = true
                                LaneStats[laneName].Seen = LaneStats[laneName].Seen + 1
                            end

                            -- Görsel Nokta (Siyah -> Yeşil)
                            ManageDynamicDot(note, dist)
                            
                            local noteVelocity = 0
                            if LastYPositions[note] then
                                noteVelocity = (noteCenterY - LastYPositions[note]) / deltaTime
                            end

                            local childCount = 0
                            for _, c in ipairs(note:GetChildren()) do
                                if c.Name ~= "EmloxaDynamicDot" then childCount = childCount + 1 end
                            end
                            local isHoldNote = childCount > 1

                            local shouldHit = false
                            if AutoplayMethod == "Rapid checks" then
                                shouldHit = (dist <= Aggression)
                            elseif AutoplayMethod == "Calculate" then
                                if noteVelocity > 0 and dist < 150 then
                                    local timeToHit = dist / noteVelocity
                                    shouldHit = (timeToHit <= (deltaTime * 1.5))
                                end
                            elseif AutoplayMethod == "Hybrid" then
                                local dynamicRange = Aggression
                                if noteVelocity > 0 then dynamicRange = Aggression + (noteVelocity * 0.015) end
                                shouldHit = (dist <= dynamicRange)
                            end

                            if isHoldNote then
                                if (noteTop <= laneCenterY + Aggression) and (noteBottom >= laneCenterY - Aggression) then
                                    if not ActiveHolds[note] then
                                        ActiveHolds[note] = laneKey
                                        LaneStats[laneName].Taps = LaneStats[laneName].Taps + 1
                                        VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                    end
                                end
                            else
                                if shouldHit and not TappedNotes[note] then
                                    TappedNotes[note] = true
                                    LaneStats[laneName].Taps = LaneStats[laneName].Taps + 1
                                    
                                    VirtualInputManager:SendKeyEvent(false, laneKey, false, game)
                                    VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                    
                                    task.delay(0.01, function()
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
                        end
                    end
                end
                
                for holdNote, key in pairs(ActiveHolds) do
                    if key == laneKey and not holdNote.Parent then 
                        VirtualInputManager:SendKeyEvent(false, key, false, game)
                        ActiveHolds[holdNote] = nil
                    end
                end
            end
        end
    end)

    -- ==========================================
    -- 3. MISC & OPTIMIZATION
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")
    
    MiscTab:CreateButton("Clear Cache (Reset Stats)", function() 
        TappedNotes = {} 
        ActiveHolds = {} 
        CountedNotes = {}
        LastYPositions = {}
        for i=1,4 do LaneStats["Lane"..i] = {Seen=0, Taps=0} end
    end)

    MiscTab:CreateButton("Optimize Graphics (MAX FPS)", function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false
            elseif v:IsA("BasePart") and (v.Material == Enum.Material.Glass or v.Material == Enum.Material.Neon) then v.Material = Enum.Material.SmoothPlastic end
        end
        game:GetService("Lighting").GlobalShadows = false
    end)

    MiscTab:CreateButton("Unload EMLOXA", function()
        AutoPlayerEnabled = false
        for _, key in pairs(LaneKeys) do VirtualInputManager:SendKeyEvent(false, key, false, game) end
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
