-- =========================================================================
-- EMLOXA WARE: DOORS TACTICAL CORE (INTEGRATED FULL VERSION)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    
    local tracerGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    tracerGui.Name = "EmloxaTracerGui"
    tracerGui.DisplayOrder = 99997

    local character, humanoid, rootPart
    local defaultWalkSpeed, defaultJumpPower = 16, 50
    local espElements, originalPrompts = {}, {}
    local soundBypassEnabled = false

    local function onCharacterAdded(char)
        character = char
        humanoid = char:WaitForChild("Humanoid")
        rootPart = char:WaitForChild("HumanoidRootPart")
        char.DescendantAdded:Connect(function(desc)
            if soundBypassEnabled and desc.Name == "Sound" and desc:IsA("Sound") then
                local isTool = false; local p = desc.Parent
                while p do if p:IsA("Tool") then isTool = true break end p = p.Parent end
                if not isTool then desc:Destroy() end
            end
        end)
    end
    LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    if LocalPlayer.Character then onCharacterAdded(LocalPlayer.Character) end

    -- ==========================================
    -- 1. SEKMELER (RAYFIELD FORMATI)
    -- ==========================================
    local PlayerTab = Window:CreateTab("Player")
    local ESPTab = Window:CreateTab("ESP")
    local WorldTab = Window:CreateTab("World")
    local AutoTab = Window:CreateTab("Auto")
    local MiscTab = Window:CreateTab("Misc")

    -- Player Variables
    local speedEnabled, superJump, spinbot, antiEyes, antiScreech = false, false, false, false, false
    local speedValue, spinbotValue = 20, 20

    PlayerTab:CreateToggle("Enable Speed", function(s) speedEnabled = s end)
    PlayerTab:CreateSlider("WalkSpeed", 16, 100, 20, function(v) speedValue = v end)
    PlayerTab:CreateToggle("Super Jump", function(s) superJump = s end)
    PlayerTab:CreateToggle("Enable Spinbot", function(s) spinbot = s end)
    PlayerTab:CreateSlider("Spin Speed", 1, 100, 20, function(v) spinbotValue = v end)
    PlayerTab:CreateToggle("Anti-Eyes", function(s) antiEyes = s end)
    PlayerTab:CreateToggle("Anti-Screech", function(s) antiScreech = s end)
    PlayerTab:CreateToggle("Sound Bypass", function(s) soundBypassEnabled = s end)

    -- ESP Variables
    local doorEsp, keyEsp, bookEsp, leverEsp, breakerEsp, wardrobeEsp, monsterEsp, tracerEsp = false, false, false, false, false, false, false, false
    ESPTab:CreateToggle("Door ESP", function(s) doorEsp = s end)
    ESPTab:CreateToggle("Key ESP", function(s) keyEsp = s end)
    ESPTab:CreateToggle("Book ESP", function(s) bookEsp = s end)
    ESPTab:CreateToggle("Lever ESP", function(s) leverEsp = s end)
    ESPTab:CreateToggle("Breaker ESP", function(s) breakerEsp = s end)
    ESPTab:CreateToggle("Wardrobe ESP", function(s) wardrobeEsp = s end)
    ESPTab:CreateToggle("Monster ESP", function(s) monsterEsp = s end)
    ESPTab:CreateToggle("Tracers", function(s) tracerEsp = s; if not s then tracerGui:ClearAllChildren() end end)

    -- World Variables
    local fullbright, fovEnabled, instantPrompt = false, false, false
    local fovValue = 70
    WorldTab:CreateToggle("Fullbright", function(s) fullbright = s end)
    WorldTab:CreateToggle("Custom FOV", function(s) fovEnabled = s end)
    WorldTab:CreateSlider("FOV Value", 70, 120, 70, function(v) fovValue = v end)
    WorldTab:CreateToggle("Instant Prompt", function(s) instantPrompt = s end)

    -- Auto Interact Variables
    local autoDoor, autoKey, autoBook, autoLever, autoBreaker = false, false, false, false, false
    AutoTab:CreateToggle("Auto Door", function(s) autoDoor = s end)
    AutoTab:CreateToggle("Auto Key", function(s) autoKey = s end)
    AutoTab:CreateToggle("Auto Book", function(s) autoBook = s end)
    AutoTab:CreateToggle("Auto Lever", function(s) autoLever = s end)
    AutoTab:CreateToggle("Auto Breaker", function(s) autoBreaker = s end)

    -- ==========================================
    -- 2. ANA DÖNGÜ (BACKEND LOGIC)
    -- ==========================================
    RunService.RenderStepped:Connect(function()
        -- Player Logic
        if speedEnabled and humanoid then humanoid.WalkSpeed = speedValue end
        if fovEnabled then Camera.FieldOfView = fovValue end
        if spinbot and rootPart then rootPart.CFrame *= CFrame.Angles(0, math.rad(spinbotValue), 0) end
        if fullbright then Lighting.Ambient = Color3.new(1,1,1) end

        -- Anti Features
        if antiEyes and workspace:FindFirstChild("Eyes") then 
            local e = workspace.Eyes:FindFirstChildWhichIsA("BasePart")
            if e and rootPart then rootPart.CFrame = CFrame.new(rootPart.Position, Vector3.new(e.Position.X, rootPart.Position.Y, e.Position.Z)) end 
        end
        if antiScreech and Camera:FindFirstChild("Screech") then Camera.Screech:Destroy() end

        -- ESP & Logic
        local rooms = workspace:FindFirstChild("CurrentRooms")
        if not rooms then return end

        for _, room in pairs(rooms:GetChildren()) do
            -- Instant Prompt
            for _, p in pairs(room:GetDescendants()) do
                if p:IsA("ProximityPrompt") then
                    p.RequiresLineOfSight = false
                    if instantPrompt then p.HoldDuration = 0 end
                end
            end

            -- ESP Logic
            if doorEsp then 
                local d = room:FindFirstChild("Door")
                if d and not espElements[d] then
                    local h = Instance.new("Highlight", d); h.FillColor = Color3.fromRGB(0, 150, 255)
                    espElements[d] = {h, "Door"}
                end
            end
        end
        
        -- ESP Clear (If toggle off)
        if not doorEsp then 
            for obj, data in pairs(espElements) do 
                if data[2] == "Door" then data[1]:Destroy(); espElements[obj] = nil end 
            end 
        end
    end)

    -- ==========================================
    -- 3. MISC & UNLOAD
    -- ==========================================
    MiscTab:CreateButton("Unload", function() 
        tracerGui:Destroy()
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end 
    end)
end

return GameModule
