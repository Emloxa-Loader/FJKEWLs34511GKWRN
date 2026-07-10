-- =========================================================================
-- EMLOXA WARE: DOORS FULL TACTICAL MODULE (PREMIUM CORE)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer
    local tracerGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    tracerGui.Name = "EmloxaTracerGui"

    local espElements, originalPrompts, activeMonsters = {}, {}, {}
    local MONSTER_NAMES = {"Eyes", "RushMoving", "Dread", "Ambush", "AmbushMoving", "SeekMovingNewClone"}
    local MONSTER_DISPLAY_NAMES = { RushMoving = "Rush", AmbushMoving = "Ambush", SeekMovingNewClone = "Seek" }
    local lastMonsterNotif = 0

    local PlayerTab = Window:CreateTab("Player")
    local ESPTab = Window:CreateTab("ESP")
    local WorldTab = Window:CreateTab("World")
    local AutoTab = Window:CreateTab("Auto")

    local states = {
        speedEnabled=false, speedVal=20, superJump=false, spinbot=false, antiEyes=false, antiScreech=false,
        doorEsp=false, keyEsp=false, bookEsp=false, leverEsp=false, breakerEsp=false, wardrobeEsp=false, monsterEsp=false, monsterNotif=false, tracers=false,
        fullbright=false, fovEnabled=false, fovValue=70, instantPrompt=false,
        autoDoor=false, autoKey=false, autoBook=false, autoLever=false, autoBreaker=false
    }

    PlayerTab:CreateToggle("Enable Speed", function(s) states.speedEnabled = s end)
    PlayerTab:CreateSlider("WalkSpeed", 16, 100, 20, function(v) states.speedVal = v end)
    PlayerTab:CreatePremiumToggle("Super Jump", function(s) states.superJump = s end)
    PlayerTab:CreatePremiumToggle("Anti-Eyes", function(s) states.antiEyes = s end)
    PlayerTab:CreatePremiumToggle("Anti-Screech", function(s) states.antiScreech = s end)

    ESPTab:CreateToggle("Door ESP", function(s) states.doorEsp = s end)
    ESPTab:CreateToggle("Key ESP", function(s) states.keyEsp = s end)
    ESPTab:CreateToggle("Book ESP", function(s) states.bookEsp = s end)
    ESPTab:CreateToggle("Lever ESP", function(s) states.leverEsp = s end)
    ESPTab:CreateToggle("Monster ESP", function(s) states.monsterEsp = s end)
    ESPTab:CreateToggle("Monster Notif", function(s) states.monsterNotif = s end)
    ESPTab:CreateToggle("Tracers", function(s) states.tracers = s; if not s then tracerGui:ClearAllChildren() end end)

    WorldTab:CreateToggle("Fullbright", function(s) states.fullbright = s end)
    WorldTab:CreateToggle("Instant Prompt", function(s) states.instantPrompt = s end)

    AutoTab:CreatePremiumToggle("Auto Door", function(s) states.autoDoor = s end)
    AutoTab:CreatePremiumToggle("Auto Key", function(s) states.autoKey = s end)
    AutoTab:CreatePremiumToggle("Auto Lever", function(s) states.autoLever = s end)

    RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")

        if states.speedEnabled and hum then hum.WalkSpeed = states.speedVal end
        if states.fullbright then Lighting.Ambient = Color3.new(1,1,1) end

        local rooms = workspace:FindFirstChild("CurrentRooms")
        if not rooms then return end

        for _, room in pairs(rooms:GetDescendants()) do
            if room:IsA("ProximityPrompt") then
                room.RequiresLineOfSight = false
                if states.instantPrompt then room.HoldDuration = 0 end
            end
        end

        for _, c in ipairs(workspace:GetChildren()) do
            if table.find(MONSTER_NAMES, c.Name) then
                if states.monsterNotif and not activeMonsters[c] then
                    activeMonsters[c] = true
                    if tick() - lastMonsterNotif > 5 then
                        lastMonsterNotif = tick()
                    end
                end
            end
        end
        
        for obj, elements in pairs(espElements) do
             if not obj or not obj.Parent then
                if elements.highlight then elements.highlight:Destroy() end
                if elements.billboard then elements.billboard:Destroy() end
                espElements[obj] = nil
             end
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if not workspace:FindFirstChild("CurrentRooms") then return end
        for _, room in pairs(workspace.CurrentRooms:GetChildren()) do
            local door = room:FindFirstChild("Door")
            if door and states.doorEsp and not espElements[door] then
                local h = Instance.new("Highlight", door); h.FillColor = Color3.fromRGB(0,150,255)
                local b = Instance.new("BillboardGui", door); b.Size = UDim2.new(0,100,0,50); b.AlwaysOnTop = true
                local l = Instance.new("TextLabel", b); l.Size = UDim2.new(1,0,1,0); l.Text = "DOOR"
                espElements[door] = {highlight=h, billboard=b}
            end
        end
    end)

    local MiscTab = Window:CreateTab("Misc")
    MiscTab:CreateButton("Unload", function() tracerGui:Destroy(); Window:Destroy() end)
end

return GameModule
