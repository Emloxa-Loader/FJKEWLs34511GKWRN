-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY AUTO-PLAYER v8 (CLOSEST-NOTE-PRIORITY CORE)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local LocalPlayer = Players.LocalPlayer

    local FunkyTab = Window:CreateTab("Auto Player")
    local AutoPlayerEnabled = false
    local ShowVisualizer = false
    local HitOffset = 0 
    
    local LaneKeys = {
        Lane1 = Enum.KeyCode.A,
        Lane2 = Enum.KeyCode.S,
        Lane3 = Enum.KeyCode.W,
        Lane4 = Enum.KeyCode.D
    }

    FunkyTab:CreateToggle("Enable Auto Player (Priority Mode)", function(s) AutoPlayerEnabled = s end)
    FunkyTab:CreateToggle("Show Visualizer Dots", function(s) ShowVisualizer = s end)
    FunkyTab:CreateSlider("Hit Offset", -50, 50, 0, function(v) HitOffset = v end)

    local function ManageVisualizerDot(parentObj, dotName, size, color)
        local dot = parentObj:FindFirstChild(dotName)
        if not ShowVisualizer then if dot then dot:Destroy() end return end
        if not dot then
            dot = Instance.new("Frame"); dot.Name = dotName; dot.Size = UDim2.new(0, size, 0, size); dot.Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
            dot.BackgroundColor3 = color; dot.BorderSizePixel = 0; dot.ZIndex = 999999
            Instance.new("UIStroke", dot).Thickness = 2; Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0); dot.Parent = parentObj
        end
    end

    local TappedNotes = {}
    local ActiveHolds = {}

    RunService.RenderStepped:Connect(function()
        if not AutoPlayerEnabled then return end
        
        local ui = LocalPlayer.PlayerGui:FindFirstChild("Window")
        if not ui or not ui:FindFirstChild("Game") or not ui.Game:FindFirstChild("Fields") then return end
        
        -- Taraf bulma (Otomatik)
        local mySide = nil
        local scores = ui.Game:FindFirstChild("HUD") and ui.Game.HUD:FindFirstChild("Scores")
        if scores then
            for _, side in pairs({scores.Left, scores.Right}) do
                if side:FindFirstChild(LocalPlayer.Name) or side:FindFirstChild(LocalPlayer.DisplayName) then mySide = side.Name break end
            end
        end
        if not mySide then return end
        
        local inner = ui.Game.Fields[mySide].Inner

        -- LANE TARAMA
        for i = 1, 4 do
            local laneFrame = inner:FindFirstChild("Lane" .. i)
            if laneFrame then
                ManageVisualizerDot(laneFrame, "EmloxaTargetDot", 20, Color3.fromRGB(0, 0, 0))
                local laneCenterY = laneFrame.AbsolutePosition.Y + (laneFrame.AbsoluteSize.Y / 2) + HitOffset
                local notesFolder = laneFrame:FindFirstChild("Notes")
                
                if notesFolder then
                    local laneKey = LaneKeys["Lane" .. i]
                    local closestNote = nil
                    local minDistance = 9999 -- En yakın notayı bulmak için

                    -- ADIM 1: Sadece en yakın notayı bul
                    for _, note in pairs(notesFolder:GetChildren()) do
                        if note:IsA("GuiObject") then
                            ManageVisualizerDot(note, "EmloxaNoteDot", 14, Color3.fromRGB(50, 50, 50))
                            local noteCenterY = note.AbsolutePosition.Y + (note.AbsoluteSize.Y / 2)
                            local dist = math.abs(noteCenterY - laneCenterY)
                            
                            if dist < minDistance then
                                minDistance = dist
                                closestNote = note
                            end
                        end
                    end

                    -- ADIM 2: Sadece en yakın olanı işleme al (Kusursuz Vuruş)
                    if closestNote and minDistance <= 12 then
                        local isHoldNote = #closestNote:GetChildren() > 1
                        
                        if isHoldNote then
                            if not ActiveHolds[closestNote] then
                                ActiveHolds[closestNote] = laneKey
                                VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                            end
                        elseif not TappedNotes[closestNote] then
                            TappedNotes[closestNote] = true
                            task.spawn(function()
                                VirtualInputManager:SendKeyEvent(true, laneKey, false, game)
                                task.delay(0.01, function() VirtualInputManager:SendKeyEvent(false, laneKey, false, game) end)
                            end)
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

    local MiscTab = Window:CreateTab("Misc")
    MiscTab:CreateButton("Clear Note Cache", function() TappedNotes = {}; ActiveHolds = {} end)
    MiscTab:CreateButton("Unload EMLOXA WARE", function()
        for _, key in pairs(ActiveHolds) do VirtualInputManager:SendKeyEvent(false, key, false, game) end
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
