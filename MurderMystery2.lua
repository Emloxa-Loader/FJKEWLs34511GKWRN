-- =========================================================================
-- EMLOXA WARE: MURDER MYSTERY 2 (PLACE: 13042495892)
-- V1.0 ULTIMATE TOOL
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local Workspace = game:GetService("Workspace")
    local LocalPlayer = Players.LocalPlayer

    -- ========== UTILITY FUNCTIONS ==========
    local function GetNil(Name, DebugId)
        for _, Object in getnilinstances() do
            if Object.Name == Name and Object:GetDebugId() == DebugId then
                return Object
            end
        end
    end

    local function findMapFolder()
        -- Harita klasörünü bulur (BeachResort, MilBase vs.)
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Folder") and obj:FindFirstChild("Spawns") then
                return obj
            end
        end
        return nil
    end

    local function getCoinContainer()
        -- CoinContainer'ı her haritada bulur
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Folder") then
                local coinContainer = obj:FindFirstChild("CoinContainer")
                if coinContainer then
                    return coinContainer
                end
            end
        end
        return nil
    end

    local function getGunDrop()
        local map = findMapFolder()
        if map then
            return map:FindFirstChild("GunDrop")
        end
        return nil
    end

    local function teleportTo(pos)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char:SetPrimaryPartCFrame(CFrame.new(pos))
        end
    end

    local function equipTool(toolName)
        local backpack = LocalPlayer.Backpack
        local char = LocalPlayer.Character
        local tool = backpack:FindFirstChild(toolName) or (char and char:FindFirstChild(toolName))
        if tool and tool.Parent ~= char then
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then
                hum:EquipTool(tool)
            end
        end
    end

    local function getPlayersExceptSelf()
        local list = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                table.insert(list, plr)
            end
        end
        return list
    end

    -- ========== COIN AUTOFARM ==========
    local CoinFarmEnabled = false
    local CoinFarmMode = "Legit" -- "Legit" / "Rage"
    local CoinFarmSpeed = 0.5 -- Tween süresi (saniye, düşük = hızlı)

    local CoinTab = Window:CreateTab("Coin Farm")

    CoinTab:CreateToggle("AutoFarm Coins", function(val)
        CoinFarmEnabled = val
    end)

    CoinTab:CreateDropdown("Farm Mode", {"Legit", "Rage"}, "Legit", function(val)
        CoinFarmMode = val
    end)

    CoinTab:CreateSlider("Tween Speed (Legit)", 0.1, 2, 0.5, function(val)
        CoinFarmSpeed = val
    end)

    local lastRageTime = 0
    local rageCooldown = 0.3 -- Rage modunda TP bekleme süresi

    RunService.Heartbeat:Connect(function()
        if not CoinFarmEnabled then return end

        local container = getCoinContainer()
        if not container then return end

        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        -- Noclip aç
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end

        -- Haritanın altına ışınla (y koordinatı sabit düşük)
        if root.Position.Y > -10 then
            root.CFrame = CFrame.new(root.Position.X, -30, root.Position.Z)
        end

        -- CoinVisual'ları tara
        local coinServer = container:FindFirstChild("Coin_Server")
        if not coinServer then return end
        local coinVisuals = coinServer:GetChildren()

        local closestCoin = nil
        local closestDist = math.huge

        for _, coin in ipairs(coinVisuals) do
            if coin:IsA("BasePart") and coin.Name == "CoinVisual" then
                local dist = (coin.Position - root.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestCoin = coin
                end
            end
        end

        if closestCoin then
            if CoinFarmMode == "Legit" then
                -- Tween ile yumuşak toplama
                local goal = {}
                goal.CFrame = CFrame.new(closestCoin.Position)
                local tweenInfo = TweenInfo.new(CoinFarmSpeed, Enum.EasingStyle.Linear)
                local tween = TweenService:Create(root, tweenInfo, goal)
                tween:Play()
            elseif CoinFarmMode == "Rage" then
                -- Bekleme süresiyle direkt ışınlanma
                if tick() - lastRageTime > rageCooldown then
                    lastRageTime = tick()
                    root.CFrame = CFrame.new(closestCoin.Position)
                end
            end
        end
    end)

    -- ========== MURDER TAB ==========
    local MurderTab = Window:CreateTab("Murder")
    local FakeDeathEnabled = false

    MurderTab:CreateToggle("Fake Death (H)", function(val)
        FakeDeathEnabled = val
        -- Ekran bildirimi
        local gui = Instance.new("ScreenGui")
        gui.Name = "FakeDeathHint"
        gui.ResetOnSpawn = false
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 200, 0, 30)
        label.Position = UDim2.new(0.5, -100, 0, 100)
        label.BackgroundTransparency = 0.5
        label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        label.Text = val and "FAKE DEATH: ON" or "FAKE DEATH: OFF"
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.Parent = gui
        gui.Parent = LocalPlayer.PlayerGui
        task.delay(2, function() gui:Destroy() end)
    end)

    -- H tuşu fake death toggle
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.H then
            FakeDeathEnabled = not FakeDeathEnabled
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                if FakeDeathEnabled then
                    -- Yüz üstü yatma efekti: root'u yere yatır
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = CFrame.new(root.Position) * CFrame.Angles(math.rad(90), 0, 0)
                    end
                else
                    -- Düzelt
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = CFrame.new(root.Position)
                    end
                end
            end
        end
    end)

    MurderTab:CreateButton("Kill All (Knife)", function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        -- Bıçak var mı kontrol et, kuşan
        local knife = LocalPlayer.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife")
        if not knife then return end
        equipTool("Knife")

        -- Tüm oyuncuları karakterin önüne ışınla
        for _, plr in ipairs(getPlayersExceptSelf()) do
            local targetChar = plr.Character
            if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                local tpPos = root.CFrame * CFrame.new(0, 0, -5) -- Önü
                targetChar:SetPrimaryPartCFrame(tpPos)
            end
        end

        task.wait(0.3)

        -- Bıçak olayını tetikle
        local knifeEvent = GetNil("KnifeStabbed", "1_1294408")
        if knifeEvent then
            knifeEvent:FireServer()
        else
            -- Yedek sol tık
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    end)

    -- ========== SHERIFF TAB ==========
    local SheriffTab = Window:CreateTab("Sheriff")

    SheriffTab:CreateButton("Kill Murderer", function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        -- Katili bul (sheriff'te katil genelde tek bir kişidir, basitçe tüm oyuncuları tara)
        local murderer = nil
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local c = plr.Character
                if c and c:FindFirstChild("Knife") then
                    murderer = plr
                    break
                end
            end
        end

        if not murderer or not murderer.Character or not murderer.Character:FindFirstChild("HumanoidRootPart") then
            return
        end

        local mRoot = murderer.Character.HumanoidRootPart

        -- Kendini katilin biraz gerisine ışınla
        local behindPos = mRoot.CFrame * CFrame.new(0, 0, 5)
        root.CFrame = behindPos * CFrame.Angles(0, math.rad(180), 0) -- Katile dön

        task.wait(0.5)

        -- Shoot eventi dene
        local shootEvent = GetNil("Shoot", "1_1411212")
        if shootEvent then
            local myGun = char:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
            local gunHandle = myGun and myGun:FindFirstChild("Handle")
            local startCF = gunHandle and gunHandle.CFrame or root.CFrame
            local targetCF = CFrame.new(mRoot.Position)
            shootEvent:FireServer(startCF, targetCF)
        else
            -- Alternatif GunFired
            local ws = game:GetService("ReplicatedStorage"):FindFirstChild("ClientServices")
            if ws then
                local weaponService = ws:FindFirstChild("WeaponService")
                if weaponService then
                    local gunFired = weaponService:FindFirstChild("GunFired")
                    if gunFired then
                        local handleObj = GetNil("Handle", "1_1578716") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun") and LocalPlayer.Character.Gun:FindFirstChild("Handle"))
                        local startV3 = handleObj and handleObj.Position or root.Position
                        firesignal(gunFired.OnClientEvent, handleObj, startV3, mRoot.Position, handleObj)
                    end
                end
            end
            -- Sol tık yedek
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    end)

    -- ========== TELEPORT TAB ==========
    local TeleportTab = Window:CreateTab("Teleport")

    TeleportTab:CreateButton("Teleport Lobby", function()
        local lobby = Workspace:FindFirstChild("Lobby")
        if lobby then
            local spawns = lobby:FindFirstChild("Spawns")
            if spawns then
                local spawnParts = spawns:GetChildren()
                if #spawnParts >= 14 then
                    teleportTo(spawnParts[14].Position)
                end
            end
        end
    end)

    TeleportTab:CreateButton("Teleport Map", function()
        local map = findMapFolder()
        if map then
            local spawns = map:FindFirstChild("Spawns")
            if spawns then
                local spawnParts = spawns:GetChildren()
                if #spawnParts >= 12 then
                    teleportTo(spawnParts[12].Position)
                end
            end
        end
    end)

    TeleportTab:CreateButton("Teleport Murder", function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Knife") then
                teleportTo(plr.Character.HumanoidRootPart.Position)
                return
            end
        end
    end)

    TeleportTab:CreateButton("Teleport Sheriff", function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Backpack:FindFirstChild("Gun") or (plr.Character and plr.Character:FindFirstChild("Gun")) then
                teleportTo(plr.Character.HumanoidRootPart.Position)
                return
            end
        end
    end)

    -- ========== AUTO GET GUN ==========
    local AutoGetGunEnabled = false
    local gunTeleportBackPos = nil

    TeleportTab:CreateToggle("Auto Get Gun", function(val)
        AutoGetGunEnabled = val
        if val then
            -- Gitmeden önce pozisyonu kaydet
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                gunTeleportBackPos = char.HumanoidRootPart.Position
            end
        end
    end)

    RunService.Heartbeat:Connect(function()
        if not AutoGetGunEnabled then return end
        local gunDrop = getGunDrop()
        if not gunDrop then return end

        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        -- Silahı alana kadar drop kısmına git
        if gunDrop and gunDrop:IsA("BasePart") and gunDrop.Parent then
            root.CFrame = CFrame.new(gunDrop.Position + Vector3.new(0, 3, 0))
        else
            -- Drop yok olduysa veya silah alındıysa geri dön
            if gunTeleportBackPos then
                root.CFrame = CFrame.new(gunTeleportBackPos)
                gunTeleportBackPos = nil
                AutoGetGunEnabled = false
            end
        end
    end)

    -- ========== FLING TAB ==========
    local FlingTab = Window:CreateTab("Fling")

    local function flingTarget(targetChar)
        local rootPart = targetChar:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        -- Temel fling: Yüksek hızda döndür ve fırlat
        local bodyGyro = Instance.new("BodyAngularVelocity")
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.AngularVelocity = Vector3.new(0, 100, 0)
        bodyGyro.Parent = rootPart

        local bodyVel = Instance.new("BodyVelocity")
        bodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVel.Velocity = Vector3.new(0, 500, 0)
        bodyVel.Parent = rootPart

        task.delay(2, function()
            bodyGyro:Destroy()
            bodyVel:Destroy()
        end)
    end

    FlingTab:CreateButton("Fling Kill All", function()
        local targets = getPlayersExceptSelf()
        for _, plr in ipairs(targets) do
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                flingTarget(char)
                -- Bir sonrakine geçmeden önce hedefin fırladığını algılamak için bekle
                repeat
                    task.wait(0.5)
                until not char or not char:FindFirstChild("HumanoidRootPart") or (char.HumanoidRootPart.Velocity.Magnitude < 5)
            end
        end
    end)

    FlingTab:CreateButton("Kill Murder (Fling)", function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                local char = plr.Character
                if char and char:FindFirstChild("Knife") then
                    flingTarget(char)
                    break
                end
            end
        end
    end)

    -- ========== MISC TAB ==========
    local MiscTab = Window:CreateTab("Misc")

    -- Fly
    local FlyEnabled = false
    local flyBodyGyro, flyBodyVel
    MiscTab:CreateToggle("Fly", function(val)
        FlyEnabled = val
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            if val then
                flyBodyGyro = Instance.new("BodyGyro")
                flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                flyBodyGyro.CFrame = char.HumanoidRootPart.CFrame
                flyBodyGyro.Parent = char.HumanoidRootPart

                flyBodyVel = Instance.new("BodyVelocity")
                flyBodyVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                flyBodyVel.Velocity = Vector3.zero
                flyBodyVel.Parent = char.HumanoidRootPart
            else
                if flyBodyGyro then flyBodyGyro:Destroy() end
                if flyBodyVel then flyBodyVel:Destroy() end
            end
        end
    end)

    -- Speed
    local WalkSpeed = 16
    MiscTab:CreateSlider("Walk Speed", 16, 200, 16, function(val)
        WalkSpeed = val
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = val
        end
    end)

    -- JumpPower
    local JumpPower = 50
    MiscTab:CreateSlider("Jump Power", 50, 300, 50, function(val)
        JumpPower = val
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = val
        end
    end)

    -- Noclip
    local NoclipEnabled = false
    MiscTab:CreateToggle("Noclip", function(val)
        NoclipEnabled = val
    end)

    -- Noclip döngüsü
    RunService.Stepped:Connect(function()
        if NoclipEnabled then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)

    -- Fly kontrol döngüsü
    RunService.Heartbeat:Connect(function()
        if FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character.HumanoidRootPart
            local camera = Workspace.CurrentCamera
            local moveDir = Vector3.zero

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0, 1, 0) end

            flyBodyGyro.CFrame = camera.CFrame
            flyBodyVel.Velocity = moveDir * 50
        end
    end)

    -- ========== UNLOAD ==========
    MiscTab:CreateButton("Unload Script", function()
        CoinFarmEnabled = false
        AutoGetGunEnabled = false
        NoclipEnabled = false
        FlyEnabled = false
        if flyBodyGyro then flyBodyGyro:Destroy() end
        if flyBodyVel then flyBodyVel:Destroy() end

        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
