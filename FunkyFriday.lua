-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY AUTO-PLAYER v12 (FINAL STABLE VERSION)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local LocalPlayer = Players.LocalPlayer

    -- ==========================================
    -- 1. LOCAL PLAYER SEKME
    -- ==========================================
    local PlayerTab = Window:CreateTab("Local Player")
    local NoclipEnabled, FlyEnabled = false, false
    
    PlayerTab:CreateToggle("Noclip (Pass Through)", function(s) NoclipEnabled = s end)
    PlayerTab:CreateSlider("WalkSpeed", 16, 250, 16, function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end 
    end)
    PlayerTab:CreateSlider("JumpPower", 50, 350, 50, function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = v end 
    end)

    -- ==========================================
    -- 2. AUTO PLAYER (HOLD & NORMAL FIX)
    -- ==========================================
    local FunkyTab = Window:CreateTab("Auto Player")
    
    local AutoPlayerEnabled = false
    local ShowVisualizer = false
    local Aggression = 20
    
    local LaneKeys = { Lane1 = Enum.KeyCode.A, Lane2 = Enum.KeyCode.S, Lane3 = Enum.KeyCode.W, Lane4 = Enum.KeyCode.D }

    FunkyTab:CreateToggle("Enable Auto Player (Extreme)", function(s) AutoPlayerEnabled = s end)
    FunkyTab:CreateToggle("Show Visualizer Dots", function(s) ShowVisualizer = s end)
    FunkyTab:CreateSlider("Aggression Range", 10, 80, 20, function(v) Aggression = v end)

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
                            local noteCenterY = note.AbsolutePosition.Y + (note.AbsoluteSize.Y / 2)
                            local dist = math.abs(noteCenterY - laneCenterY)
                            
                            if dist <= Aggression then
                                -- HOLD MANTIĞI: Eğer içinde birden fazla nesne varsa HOLD'dur
                                local isHoldNote = #note:GetChildren() > 1
                                
                                if isHoldNote then
                                    if not ActiveHolds[note] then
                                        ActiveHolds[note] = laneKey
                                        VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                    end
                                else
                                    -- NORMAL NOTA MANTIĞI: HOLD'dan bağımsız çalışır
                                    if not TappedNotes[note] then
                                        TappedNotes[note] = true
                                        VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                        task.delay(0.015, function() VirtualInputManager:SendKeyEvent(false, laneKey, false, game) end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        for holdNote, key in pairs(ActiveHolds) do
            if not holdNote.Parent or not holdNote:IsDescendantOf(game) then 
                VirtualInputManager:SendKeyEvent(false, key, false, game)
                ActiveHolds[holdNote] = nil
            end
        end
    end)

    -- ==========================================
    -- 3. CUSTOM ARROWS SEKME
    -- ==========================================
    local ArrowTab = Window:CreateTab("Custom Arrows")
    local selectedArrowId = nil

    local function ApplyArrowSkin(id)
        selectedArrowId = id
        local ui = LocalPlayer.PlayerGui:FindFirstChild("Window")
        if not ui then return end
        local fields = ui.Game:FindFirstChild("Fields")
        if not fields then return end
        
        -- Mevcut olanları değiştir
        for _, descendant in pairs(fields:GetDescendants()) do
            if descendant:IsA("ImageLabel") then descendant.Image = "rbxassetid://" .. id end
        end
    end

    ArrowTab:CreateButton("Arrow Style 1 (ID: 5721693146)", function() ApplyArrowSkin(5721693146) end)
    ArrowTab:CreateButton("Arrow Style 2 (ID: 10800748312)", function() ApplyArrowSkin(10800748312) end)
    ArrowTab:CreateButton("Arrow Style 3 (ID: 56481798)", function() ApplyArrowSkin(56481798) end)
    ArrowTab:CreateButton("Arrow Style 4 (ID: 14843658201)", function() ApplyArrowSkin(14843658201) end)
    ArrowTab:CreateButton("Default Arrows", function() selectedArrowId = nil end)
    
    -- Not: Sadece bizim gördüğümüzü belirtir
    local NoteLabel = Instance.new("TextLabel", ArrowTab.Parent) -- Sekme içine değil, tabın altına düşecek şekilde
    -- Notu sekme içine eklemek için library'nin yapısına göre eklendi
    ArrowTab:CreateLabel("Note: This change is client-side only and visible only to you.")

    -- Skin uygulayıcı (Spawn olan yeni notalar için)
    ui.Game.Fields.DescendantAdded:Connect(function(obj)
        if selectedArrowId and obj:IsA("ImageLabel") then
            obj.Image = "rbxassetid://" .. selectedArrowId
        end
    end)

    -- ==========================================
    -- 4. MISC & CLEANUP
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")
    MiscTab:CreateButton("Clear Cache", function() TappedNotes = {}; ActiveHolds = {} end)
    MiscTab:CreateButton("Unload EMLOXA", function()
        for _, key in pairs(ActiveHolds) do VirtualInputManager:SendKeyEvent(false, key, false, game) end
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
