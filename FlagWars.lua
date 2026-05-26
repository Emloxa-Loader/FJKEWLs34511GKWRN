-- =========================================================================
-- EMLOXA WARE: FLAG WARS TACTICAL CORE v3 (DYNAMIC CLEANUP & MOUSE-FOLLOW)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer

    -- FOV Dairesi (Mouse takip eden)
    local FOVGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local FOVCircle = Instance.new("Frame", FOVGui)
    FOVCircle.BackgroundTransparency = 1
    FOVCircle.ZIndex = 999
    local stroke = Instance.new("UIStroke", FOVCircle)
    stroke.Color = Color3.fromRGB(255, 0, 0)
    stroke.Thickness = 2
    FOVCircle.Visible = false

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
    PlayerTab:CreateSlider("WalkSpeed", 16, 250, 16, function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end 
    end)

    -- ==========================================
    -- 2. AIMBOT (LOCK-ON & FOV)
    -- ==========================================
    local CombatTab = Window:CreateTab("Aimbot")
    local AimbotEnabled = false
    local TeamCheck = true
    local FOVRadius = 200
    
    CombatTab:CreateToggle("Enable Aimbot", function(s) AimbotEnabled = s end)
    CombatTab:CreateToggle("Show FOV Circle", function(s) FOVCircle.Visible = s end)
    CombatTab:CreateToggle("Team Check (Smart)", function(s) TeamCheck = s end)
    CombatTab:CreateSlider("FOV Radius", 50, 500, 200, function(v) 
        FOVRadius = v
        FOVCircle.Size = UDim2.new(0, v*2, 0, v*2)
    end)

    local LockedTarget = nil

    RunService.RenderStepped:Connect(function()
        -- Mouse takip eden FOV Dairesi
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = UDim2.new(0, mousePos.X - FOVRadius, 0, mousePos.Y - FOVRadius)

        if not AimbotEnabled then LockedTarget = nil; return end
        
        -- Sağ Tık Kontrolü
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            if not LockedTarget or not LockedTarget.Parent then
                local closest, minDist = nil, FOVRadius
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        if TeamCheck and p.Team == LocalPlayer.Team then continue end
                        local pos, onScreen = Camera:WorldToScreenPoint(p.Character.HumanoidRootPart.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                            if dist < minDist then closest = p.Character.HumanoidRootPart; minDist = dist end
                        end
                    end
                end
                LockedTarget = closest
            end
        else
            LockedTarget = nil
        end

        if LockedTarget and LockedTarget.Parent and LockedTarget.Parent:FindFirstChild("Humanoid") and LockedTarget.Parent.Humanoid.Health > 0 then
            -- Team Check (Anlık kontrol)
            local p = Players:GetPlayerFromCharacter(LockedTarget.Parent)
            if TeamCheck and p and p.Team == LocalPlayer.Team then LockedTarget = nil; return end
            
            local lookAt = CFrame.lookAt(Camera.CFrame.Position, LockedTarget.Position)
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, 0.2)
        end
    end)

    -- ==========================================
    -- 3. HITBOX EXPANDER (DYNAMIC CLEANUP)
    -- ==========================================
    local HitboxTab = Window:CreateTab("Hitbox Expander")
    local HitboxEnabled = false
    local HitboxSize = 2
    HitboxTab:CreateToggle("Enable Hitbox", function(s) HitboxEnabled = s end)
    HitboxTab:CreateSlider("Hitbox Size", 2, 100, 2, function(v) HitboxSize = v end)

    RunService.RenderStepped:Connect(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local isAlly = (TeamCheck and p.Team == LocalPlayer.Team)
                if HitboxEnabled and not isAlly then
                    p.Character.HumanoidRootPart.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                    p.Character.HumanoidRootPart.Transparency = 0.5
                    p.Character.HumanoidRootPart.CanCollide = false
                else
                    p.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1) -- Varsayılan boyut
                    p.Character.HumanoidRootPart.Transparency = 1
                end
            end
        end
    end)

    -- ==========================================
    -- 4. ESP (CONSTANT PERSISTENT)
    -- ==========================================
    local ESPTab = Window:CreateTab("ESP")
    local ESPEnabled = false
    ESPTab:CreateToggle("Enable ESP", function(s) ESPEnabled = s end)

    RunService.RenderStepped:Connect(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local isAlly = (TeamCheck and p.Team == LocalPlayer.Team)
                if ESPEnabled and not isAlly then
                    if not p.Character:FindFirstChild("EmloxaESP") then
                        local hl = Instance.new("Highlight", p.Character)
                        hl.Name = "EmloxaESP"
                        hl.FillColor = Color3.fromRGB(255, 0, 0)
                    end
                else
                    if p.Character:FindFirstChild("EmloxaESP") then p.Character.EmloxaESP:Destroy() end
                end
            end
        end
    end)

    -- ==========================================
    -- 5. MISC & CLEANUP
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")
    MiscTab:CreateButton("Unload", function() 
        FOVGui:Destroy()
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI") 
        if ui then ui:Destroy() end 
    end)
end

return GameModule
