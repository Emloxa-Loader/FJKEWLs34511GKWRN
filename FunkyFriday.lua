-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY AUTO-PLAYER v16 (ULTIMATE OVERLAY SKINNING)
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
    local NoclipEnabled, FlyEnabled = false, false
    
    PlayerTab:CreateToggle("Noclip (Pass Through)", function(s) NoclipEnabled = s end)
    PlayerTab:CreateSlider("WalkSpeed", 16, 250, 16, function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end 
    end)
    PlayerTab:CreateSlider("JumpPower", 50, 350, 50, function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = v end 
    end)

    -- ==========================================
    -- 2. AUTO PLAYER (PRIORITY CORE)
    -- ==========================================
    local FunkyTab = Window:CreateTab("Auto Player")
    local AutoPlayerEnabled = false
    local ShowVisualizer = false
    local Aggression = 20
    
    local LaneKeys = { Lane1 = Enum.KeyCode.A, Lane2 = Enum.KeyCode.S, Lane3 = Enum.KeyCode.W, Lane4 = Enum.KeyCode.D }

    FunkyTab:CreateToggle("Enable Auto Player", function(s) AutoPlayerEnabled = s end)
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
                    local closestNote = nil
                    local minDistance = 9999
                    
                    for _, note in pairs(notesFolder:GetChildren()) do
                        if note:IsA("GuiObject") then
                            ManageVisualizerDot(note, "EmloxaNoteDot", 14, Color3.fromRGB(50, 50, 50))
                            local dist = math.abs((note.AbsolutePosition.Y + (note.AbsoluteSize.Y / 2)) - laneCenterY)
                            if dist < minDistance then minDistance = dist; closestNote = note end
                        end
                    end
                    
                    if closestNote and minDistance <= Aggression then
                        local isHoldNote = #closestNote:GetChildren() > 1
                        if isHoldNote then
                            if not ActiveHolds[closestNote] then
                                ActiveHolds[closestNote] = laneKey
                                VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                            end
                        elseif not TappedNotes[closestNote] then
                            TappedNotes[closestNote] = true
                            VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                            task.spawn(function() task.wait(0.015); VirtualInputManager:SendKeyEvent(false, laneKey, false, game) end)
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
    -- 3. CUSTOM ARROWS (OVERLAY SKINNING)
    -- ==========================================
    local ArrowTab = Window:CreateTab("Custom Arrows")
    local activeSkinId = nil
    local targetSide = "Both"

    local function ApplyOverlay(parent)
        for _, obj in pairs(parent:GetDescendants()) do
            if (obj:IsA("ImageLabel") or obj:IsA("ImageButton")) and obj.Name ~= "EmloxaSkin" then
                -- Orijinali gizle
                if obj.ImageTransparency < 1 then obj.ImageTransparency = 1 end
                
                -- Overlay oluştur/güncelle
                local overlay = obj:FindFirstChild("EmloxaSkin")
                if not overlay then
                    overlay = Instance.new("ImageLabel")
                    overlay.Name = "EmloxaSkin"
                    overlay.Size = UDim2.new(1, 0, 1, 0)
                    overlay.BackgroundTransparency = 1
                    overlay.ZIndex = obj.ZIndex + 1
                    overlay.Parent = obj
                end
                if overlay.Image ~= "rbxassetid://" .. activeSkinId then
                    overlay.Image = "rbxassetid://" .. activeSkinId
                end
            end
        end
    end

    ArrowTab:CreateButton("Style 1", function() activeSkinId = 5721693146 end)
    ArrowTab:CreateButton("Style 2", function() activeSkinId = 10800748312 end)
    ArrowTab:CreateButton("Style 3", function() activeSkinId = 56481798 end)
    ArrowTab:CreateButton("Style 4", function() activeSkinId = 14843658201 end)
    ArrowTab:CreateButton("Default (Remove)", function() activeSkinId = nil end)
    
    local sideBtn = ArrowTab:CreateButton("Apply To: Both", function()
        if targetSide == "Both" then targetSide = "Left"
        elseif targetSide == "Left" then targetSide = "Right"
        else targetSide = "Both" end
        sideBtn:UpdateText("Apply To: " .. targetSide)
    end)

    -- Loop
    RunService.RenderStepped:Connect(function()
        if activeSkinId then
            local ui = LocalPlayer.PlayerGui:FindFirstChild("Window")
            if ui and ui:FindFirstChild("Game") then
                local fields = ui.Game.Fields
                local targets = (targetSide == "Both") and {fields.Left, fields.Right} or {fields[targetSide]}
                for _, t in pairs(targets) do ApplyOverlay(t) end
            end
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
    
    local Label = Instance.new("TextLabel", ArrowTab.Parent)
    Label.Text = "Note: Changes are client-side."
end

return GameModule
