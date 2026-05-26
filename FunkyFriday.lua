-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY AUTO-PLAYER v12 (THE FINAL DEFINITIVE VERSION)
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
        local hud = ui.Game:FindFirstChild("HUD")
        if hud and hud:FindFirstChild("Scores") then
            for _, side in pairs({hud.Scores.Left, hud.Scores.Right}) do
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
    -- 3. CUSTOM ARROWS (LOOP MODE & PREVIEW)
    -- ==========================================
    local ArrowTab = Window:CreateTab("Custom Arrows")
    local activeSkinId = nil
    local targetSide = "Both" -- Both, Left, Right

    local function ApplySkin(id)
        activeSkinId = id
        local ui = LocalPlayer.PlayerGui:FindFirstChild("Window")
        if not ui then return end
        for _, obj in pairs(ui.Game.Fields:GetDescendants()) do
            if obj:IsA("ImageLabel") then obj.Image = "rbxassetid://" .. id end
        end
    end

    ArrowTab:CreateButton("Style 1 (Preview)", function() ApplySkin(5721693146) end)
    ArrowTab:CreateButton("Style 2 (Preview)", function() ApplySkin(10800748312) end)
    ArrowTab:CreateButton("Style 3 (Preview)", function() ApplySkin(56481798) end)
    ArrowTab:CreateButton("Style 4 (Preview)", function() ApplySkin(14843658201) end)
    ArrowTab:CreateButton("Default Arrows", function() activeSkinId = nil end)
    
    -- Loop (Sürekli uygulama)
    RunService.RenderStepped:Connect(function()
        if activeSkinId then
            local ui = LocalPlayer.PlayerGui:FindFirstChild("Window")
            if ui and ui:FindFirstChild("Game") then
                for _, obj in pairs(ui.Game.Fields:GetDescendants()) do
                    if obj:IsA("ImageLabel") and obj.Image ~= "rbxassetid://" .. activeSkinId then
                        obj.Image = "rbxassetid://" .. activeSkinId
                    end
                end
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
    
    -- Client-side note label
    local Label = Instance.new("TextLabel", ArrowTab.Parent)
    Label.Text = "Note: This is client-side only."
end

return GameModule
