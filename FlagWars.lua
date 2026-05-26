-- =========================================================================
-- EMLOXA WARE: FLAG WARS TACTICAL CORE v2 (LOCK-ON AIMBOT & PERSISTENT ESP)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local Camera = Workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer

    -- FOV Dairesi için GUI (Sürekli Güncel)
    local FOVGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local FOVCircle = Instance.new("Frame", FOVGui)
    FOVCircle.Size = UDim2.new(0, 200, 0, 200)
    FOVCircle.Position = UDim2.new(0.5, -100, 0.5, -100)
    FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FOVCircle.BackgroundTransparency = 1
    Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", FOVCircle)
    stroke.Color = Color3.fromRGB(255, 0, 0)
    stroke.Thickness = 2
    FOVCircle.Visible = false

    -- ==========================================
    -- 1. LOCAL PLAYER SEKME
    -- ==========================================
    local PlayerTab = Window:CreateTab("Local Player")
    PlayerTab:CreateToggle("Noclip", function(s) 
        RunService.Stepped:Connect(function() 
            if s and LocalPlayer.Character then 
                for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end 
            end 
        end)
    end)
    PlayerTab:CreateSlider("WalkSpeed", 16, 250, 16, function(v) if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end end)

    -- ==========================================
    -- 2. AIMBOT (LOCK-ON & FOV)
    -- ==========================================
    local CombatTab = Window:CreateTab("Aimbot")
    local AimbotEnabled = false
    local TeamCheck = true
    local Smoothing = 10
    local FOVRadius = 200

    CombatTab:CreateToggle("Enable Aimbot", function(s) AimbotEnabled = s end)
    CombatTab:CreateToggle("Show FOV Circle", function(s) FOVCircle.Visible = s end)
    CombatTab:CreateToggle("Team Check", function(s) TeamCheck = s end)
    CombatTab:CreateSlider("FOV Radius", 50, 500, 200, function(v) FOVRadius = v; FOVCircle.Size = UDim2.new(0, v*2, 0, v*2); FOVCircle.Position = UDim2.new(0.5, -v, 0.5, -v) end)
    CombatTab:CreateSlider("Smoothing", 1, 30, 10, function(v) Smoothing = v end)

    local LockedTarget = nil

    RunService.RenderStepped:Connect(function()
        if not AimbotEnabled then LockedTarget = nil; return end
        
        -- Sağ Tık Kontrolü (Lock-on)
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            if not LockedTarget then
                local closest, minDist = nil, FOVRadius
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        if TeamCheck and p.Team == LocalPlayer.Team then continue end
                        local pos, onScreen = Camera:WorldToScreenPoint(p.Character.HumanoidRootPart.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                            if dist < minDist then closest = p.Character.HumanoidRootPart; minDist = dist end
                        end
                    end
                end
                LockedTarget = closest
            end
        else
            LockedTarget = nil
        end

        -- Aimbot İşleme
        if LockedTarget and LockedTarget.Parent and LockedTarget.Parent:FindFirstChild("Humanoid") and LockedTarget.Parent.Humanoid.Health > 0 then
            local lookAt = CFrame.lookAt(Camera.CFrame.Position, LockedTarget.Position)
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, 1/Smoothing)
        end
    end)

    -- ==========================================
    -- 3. HITBOX EXPANDER (CONSTANT CHECK)
    -- ==========================================
    local HitboxTab = Window:CreateTab("Hitbox Expander")
    local HitboxEnabled = false
    local HitboxSize = 2
    
    HitboxTab:CreateToggle("Enable Hitbox", function(s) HitboxEnabled = s end)
    HitboxTab:CreateSlider("Hitbox Size", 2, 100, 2, function(v) HitboxSize = v end)

    RunService.RenderStepped:Connect(function()
        if not HitboxEnabled then return end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if TeamCheck and p.Team == LocalPlayer.Team then continue end
                p.Character.HumanoidRootPart.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                p.Character.HumanoidRootPart.Transparency = 0.5
                p.Character.HumanoidRootPart.CanCollide = false
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
                if ESPEnabled then
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
    MiscTab:CreateButton("Unload", function() FOVGui:Destroy(); local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI") if ui then ui:Destroy() end end)
end

return GameModule
