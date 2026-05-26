-- =========================================================================
-- EMLOXA WARE: FLAG WARS TACTICAL CORE (AIMBOT & HITBOX)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera
    
    -- ==========================================
    -- 1. AIMBOT & TACTICAL (ÖZEL HASSASİYET)
    -- ==========================================
    local CombatTab = Window:CreateTab("Aimbot")
    
    local AimbotEnabled = false
    local TeamCheck = true
    local Smoothing = 10
    local FOV = 200
    
    CombatTab:CreateToggle("Enable Aimbot", function(s) AimbotEnabled = s end)
    CombatTab:CreateToggle("Team Check (Don't shoot allies)", function(s) TeamCheck = s end)
    CombatTab:CreateSlider("Smoothing (Lower = Faster)", 1, 50, 10, function(v) Smoothing = v end)
    CombatTab:CreateSlider("FOV Radius", 50, 500, 200, function(v) FOV = v end)

    local function GetClosestPlayer()
        local ClosestPlayer = nil
        local MinDist = FOV
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if TeamCheck and player.Team == LocalPlayer.Team then continue end
                
                local RootPart = player.Character.HumanoidRootPart
                local ScreenPos, OnScreen = Camera:WorldToScreenPoint(RootPart.Position)
                
                if OnScreen then
                    local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if Dist < MinDist then
                        MinDist = Dist
                        ClosestPlayer = RootPart
                    end
                end
            end
        end
        return ClosestPlayer
    end

    RunService.RenderStepped:Connect(function()
        if not AimbotEnabled then return end
        local Target = GetClosestPlayer()
        if Target then
            local LookAt = CFrame.lookAt(Camera.CFrame.Position, Target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(LookAt, 1/Smoothing)
        end
    end)

    -- ==========================================
    -- 2. HITBOX EXPANDER (KALİTELİ DETAYLI)
    -- ==========================================
    local HitboxTab = Window:CreateTab("Hitbox Expander")
    local HitboxSize = 2
    local HitboxEnabled = false
    
    HitboxTab:CreateToggle("Enable Hitbox Expander", function(s) HitboxEnabled = s end)
    HitboxTab:CreateSlider("Size Multiplier (1-100)", 2, 100, 2, function(v) HitboxSize = v end)

    RunService.RenderStepped:Connect(function()
        if not HitboxEnabled then return end
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if TeamCheck and player.Team == LocalPlayer.Team then continue end
                player.Character.HumanoidRootPart.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                player.Character.HumanoidRootPart.Transparency = 0.5
                player.Character.HumanoidRootPart.Color = Color3.fromRGB(255, 0, 0)
                player.Character.HumanoidRootPart.CanCollide = false
            end
        end
    end)

    -- ==========================================
    -- 3. ESP & EXTRAS
    -- ==========================================
    local ExtraTab = Window:CreateTab("Extras")
    local ESPEnabled = false
    
    ExtraTab:CreateToggle("Player ESP (Highlights)", function(s) ESPEnabled = s end)
    
    RunService.RenderStepped:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if ESPEnabled and not player.Character:FindFirstChild("EmloxaESP") then
                    local Highlight = Instance.new("Highlight")
                    Highlight.Name = "EmloxaESP"
                    Highlight.Parent = player.Character
                elseif not ESPEnabled and player.Character:FindFirstChild("EmloxaESP") then
                    player.Character.EmloxaESP:Destroy()
                end
            end
        end
    end)

    -- ==========================================
    -- 4. CLEANUP
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")
    MiscTab:CreateButton("Unload EMLOXA", function()
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
            end
        end
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
