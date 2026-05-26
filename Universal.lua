-- EMLOXA WARE MAIN EXECUTOR SCRIPT v3 (Aimbot & Universal Update)
local PlaceId = game.PlaceId
local EmloxaLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Emloxa-Loader/FJKEWLs34511GKWRN/refs/heads/main/EmloxaUI.lua"))()

-- Oyun İsmine Göre Başlık Belirleme
local HubTitle = (PlaceId == 3214114884) and "EMLOXA WARE - Flag Wars" or "EMLOXA WARE - Universal"
local Window = EmloxaLibrary:CreateWindow(HubTitle)

-- Servisler
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- =========================================
-- SİSTEMLER VE FONKSİYONLAR
-- =========================================

-- Noclip & Infinite Jump
local InfiniteJumpEnabled = false
UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local NoclipEnabled = false
RunService.Stepped:Connect(function()
    if NoclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    end
end)

-- Gelişmiş ESP & Tracers
local ESPEnabled = false
local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("EmloxaESP")
            if ESPEnabled then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "EmloxaESP"
                    highlight.FillColor = Color3.fromRGB(102, 85, 255)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = player.Character
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end

local TracersEnabled = false
local Tracers = {}
local function UpdateTracers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not Tracers[player] then
                local line = Drawing.new("Line")
                line.Color = Color3.fromRGB(102, 85, 255)
                line.Thickness = 1.5; line.Transparency = 1; line.Visible = false
                Tracers[player] = line
            end
            local line = Tracers[player]
            if TracersEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 then
                local vector, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if onScreen then
                    line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    line.To = Vector2.new(vector.X, vector.Y)
                    line.Visible = true
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        end
    end
end

-- =========================================
-- YENİ: AİMBOT SİSTEMİ
-- =========================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(102, 85, 255)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Radius = 100

local AimbotEnabled = false
local ShowFOV = false
local IsAiming = false
local AimbotSmoothing = 1 -- 1 Anında kitlenir, düşük rakam yavaş kitlenir.

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then IsAiming = true end -- SAĞ TIK
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then IsAiming = false end
end)

local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = FOVCircle.Radius
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 and player.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

-- RGB ve Disco
local RGBCharEnabled, DiscoEnabled = false, false
local RGBCharSpeed = 2
local OriginalColors = {}
local origAmbient, origOutdoor, origFog = Lighting.Ambient, Lighting.OutdoorAmbient, Lighting.FogColor

RunService.RenderStepped:Connect(function()
    UpdateESP()
    UpdateTracers()
    
    -- FOV ve Aimbot Render
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = mousePos
    FOVCircle.Visible = ShowFOV

    if AimbotEnabled and IsAiming then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local targetPos = target.Character.Head.Position
            local currentCameraCFrame = Camera.CFrame
            -- Smoothness formülü (Yumuşak Kitlenme)
            Camera.CFrame = currentCameraCFrame:Lerp(CFrame.new(currentCameraCFrame.Position, targetPos), AimbotSmoothing)
        end
    end

    -- RGB & Disco
    if RGBCharEnabled and LocalPlayer.Character then
        local color = Color3.fromHSV((tick() * RGBCharSpeed * 0.1) % 1, 1, 1)
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                if not OriginalColors[part] then OriginalColors[part] = part.Color end
                part.Color = color
            end
        end
    end
    if DiscoEnabled then
        local color = Color3.fromHSV((tick() * 0.5) % 1, 1, 1)
        Lighting.Ambient = color; Lighting.OutdoorAmbient = color; Lighting.FogColor = color
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if Tracers[player] then Tracers[player]:Remove(); Tracers[player] = nil end
end)

-- =========================================
-- SEKME VE ÖZELLİKLERİN EKLENMESİ
-- =========================================

-- ORTAK AİMBOT MENÜSÜ FONKSİYONU
local function CreateAimbotTab(Tab)
    Tab:CreateToggle("Enable Aimbot (Right Click)", function(state) AimbotEnabled = state end)
    Tab:CreateToggle("Show FOV Circle", function(state) ShowFOV = state end)
    Tab:CreateSlider("FOV Radius", 30, 400, 100, function(value) FOVCircle.Radius = value end)
    Tab:CreateSlider("Smoothing (1-10)", 1, 10, 10, function(value)
        AimbotSmoothing = value / 10 -- 10 ise %100 (anında)
    end)
end

if PlaceId == 3214114884 then
    -- FLAG WARS ÖZEL MENÜSÜ
    local AimbotTab = Window:CreateTab("Aimbot")
    CreateAimbotTab(AimbotTab)
    
    local VisualsTab = Window:CreateTab("Visuals")
    VisualsTab:CreateToggle("Player ESP (Through Walls)", function(state) ESPEnabled = state end)
    VisualsTab:CreateToggle("Tracers", function(state) TracersEnabled = state end)
    VisualsTab:CreateSlider("Field of View (FOV)", 70, 120, 70, function(value) Camera.FieldOfView = value end)

    local MovementTab = Window:CreateTab("Movement")
    MovementTab:CreateToggle("Noclip", function(state) NoclipEnabled = state end)
    MovementTab:CreateToggle("Infinite Jump", function(state) InfiniteJumpEnabled = state end)
    MovementTab:CreateSlider("WalkSpeed", 16, 200, 16, function(value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = value end
    end)
else
    -- VARSAYILAN (UNIVERSAL) MENÜ
    local AimbotTab = Window:CreateTab("Aimbot")
    CreateAimbotTab(AimbotTab)

    local PlayerTab = Window:CreateTab("Local Player")
    PlayerTab:CreateToggle("Noclip (Walk Through Walls)", function(state) NoclipEnabled = state end)
    PlayerTab:CreateToggle("Infinite Jump", function(state) InfiniteJumpEnabled = state end)
    PlayerTab:CreateSlider("Set WalkSpeed", 16, 250, 16, function(value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = value end
    end)
    PlayerTab:CreateSlider("Set JumpPower", 50, 300, 50, function(value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = value
        end
    end)

    local VisualsTab = Window:CreateTab("Visuals")
    VisualsTab:CreateToggle("ESP (Through Walls)", function(state) ESPEnabled = state end)
    VisualsTab:CreateToggle("Tracers (Lines)", function(state) TracersEnabled = state end)
    VisualsTab:CreateSlider("Field of View (FOV)", 70, 120, 70, function(value) Camera.FieldOfView = value end)

    local MiscTab = Window:CreateTab("Misc")
    MiscTab:CreateToggle("RGB Character", function(state)
        RGBCharEnabled = state
        if not state and LocalPlayer.Character then
            for part, origColor in pairs(OriginalColors) do
                if part and part.Parent == LocalPlayer.Character then part.Color = origColor end
            end
            OriginalColors = {}
        end
    end)
    MiscTab:CreateToggle("Disco Mode (Sky)", function(state)
        DiscoEnabled = state
        if not state then Lighting.Ambient = origAmbient; Lighting.OutdoorAmbient = origOutdoor; Lighting.FogColor = origFog end
    end)
    MiscTab:CreateButton("Unload EMLOXA WARE", function()
        ESPEnabled = false; TracersEnabled = false; NoclipEnabled = false; RGBCharEnabled = false; DiscoEnabled = false
        FOVCircle:Remove()
        Lighting.Ambient = origAmbient; Lighting.OutdoorAmbient = origOutdoor; Lighting.FogColor = origFog
        for _, line in pairs(Tracers) do line:Remove() end
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end
