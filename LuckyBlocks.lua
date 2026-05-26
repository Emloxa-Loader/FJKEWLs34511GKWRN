-- =========================================================================
-- EMLOXA WARE: LUCKY BLOCKS BATTLEGROUNDS MAXIMUM POWER MODULE v3
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- ==========================================
    -- 1. LOCAL PLAYER SEKME SİSTEMİ
    -- ==========================================
    local PlayerTab = Window:CreateTab("Local Player")
    local NoclipEnabled, FlyEnabled = false, false
    local FlySpeed, CurrentSpeed, CurrentJump = 50, 16, 50

    PlayerTab:CreateToggle("Noclip (Pass Through Walls)", function(state) NoclipEnabled = state end)
    PlayerTab:CreateSlider("WalkSpeed Force", 16, 250, 16, function(v)
        CurrentSpeed = v
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end
    end)
    PlayerTab:CreateSlider("JumpPower Force", 50, 350, 50, function(v)
        CurrentJump = v
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = v end
    end)

    PlayerTab:CreateToggle("Fly Hack", function(state)
        FlyEnabled = state
        local Character = LocalPlayer.Character
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")
        local Humanoid = Character and Character:FindFirstChild("Humanoid")
        if not Root or not Humanoid then return end
        
        if FlyEnabled then
            Humanoid.PlatformStand = true
            local BodyVelocity = Instance.new("BodyVelocity", Root)
            BodyVelocity.Name = "EmloxaFly"; BodyVelocity.Velocity = Vector3.new(0, 0, 0); BodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
            
            -- KAMERAYA BAKMA SİSTEMİ
            local BodyGyro = Instance.new("BodyGyro", Root)
            BodyGyro.Name = "EmloxaGyro"; BodyGyro.P = 9e4; BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9); BodyGyro.CFrame = Root.CFrame
            
            task.spawn(function()
                while FlyEnabled and Root and BodyVelocity.Parent do
                    local dir = Vector3.new(0, 0, 0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                    
                    BodyVelocity.Velocity = dir.Unit * FlySpeed
                    if dir == Vector3.new(0, 0, 0) then BodyVelocity.Velocity = Vector3.new(0, 0.1, 0) end
                    
                    BodyGyro.CFrame = Camera.CFrame -- Yönü kameraya kilitler
                    task.wait()
                end
            end)
        else
            Humanoid.PlatformStand = false
            if Root:FindFirstChild("EmloxaFly") then Root.EmloxaFly:Destroy() end
            if Root:FindFirstChild("EmloxaGyro") then Root.EmloxaGyro:Destroy() end
        end
    end)
    PlayerTab:CreateSlider("Fly Speed", 20, 200, 50, function(v) FlySpeed = v end)

    RunService.Stepped:Connect(function()
        local Char = LocalPlayer.Character
        if Char then
            if NoclipEnabled then for _, p in pairs(Char:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end end end
            local Hum = Char:FindFirstChild("Humanoid")
            if Hum and not FlyEnabled then Hum.WalkSpeed = CurrentSpeed; Hum.UseJumpPower = true; Hum.JumpPower = CurrentJump end
        end
    end)

    -- ==========================================
    -- 2. LUCKY BLOCKS SEKME SİSTEMİ
    -- ==========================================
    local LuckyTab = Window:CreateTab("Lucky Blocks")
    local Blocks = {{"Lucky Block", "SpawnLuckyBlock"}, {"Super Block", "SpawnSuperBlock"}, {"Diamond Block", "SpawnDiamondBlock"}, {"Rainbow Block", "SpawnRainbowBlock"}, {"Galaxy Block", "SpawnGalaxyBlock"}}
    local LoopConnections = {}

    for _, b in pairs(Blocks) do
        LuckyTab:CreateButton("Get " .. b[1], function() local r = ReplicatedStorage:FindFirstChild(b[2]); if r then r:FireServer() end end)
        LuckyTab:CreateToggle("Loop " .. b[1], function(state)
            if state then LoopConnections[b[1]] = RunService.RenderStepped:Connect(function() local r = ReplicatedStorage:FindFirstChild(b[2]); if r then r:FireServer() end end)
            else if LoopConnections[b[1]] then LoopConnections[b[1]]:Disconnect(); LoopConnections[b[1]] = nil end end
        end)
    end

    -- ==========================================
    -- 3. ULTRA HIZLI DUPE SİSTEMİ
    -- ==========================================
    local DupeTab = Window:CreateTab("Dupe Tool")
    local DupeTargetAmount = 10
    local DupeInProgress = false

    DupeTab:CreateSlider("Target Dupe Amount", 1, 100, 10, function(value) DupeTargetAmount = value end)

    DupeTab:CreateButton("Start Dupe (Held Item)", function()
        if DupeInProgress then return end
        
        local Character = LocalPlayer.Character
        local HeldTool = Character and Character:FindFirstChildOfClass("Tool")
        if not HeldTool then print("[EMLOXA WARE] Error: Eline tool almalısın!"); return end
        
        local TargetItemName = HeldTool.Name
        DupeInProgress = true
        print("[EMLOXA WARE] Ultra Fast Dupe Started for: " .. TargetItemName)

        task.spawn(function()
            local timeout = 0
            local lastOwned = 0

            -- task.wait() ile oyun motorunun izin verdiği MAKSİMUM hıza çıkıldı
            while DupeInProgress do
                local totalOwned = 0
                for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do if item.Name == TargetItemName then totalOwned = totalOwned + 1 end end
                for _, item in pairs(Character:GetChildren()) do if item:IsA("Tool") and item.Name == TargetItemName then totalOwned = totalOwned + 1 end end
                
                if totalOwned >= DupeTargetAmount then break end

                -- AKILLI TIMEOUT: Eşya sayısı artıyorsa zaman aşımını sıfırla! Asla gereksiz yere kapanmaz.
                if totalOwned > lastOwned then
                    timeout = 0
                    lastOwned = totalOwned
                end
                
                if timeout > 300 then 
                    print("[EMLOXA WARE] Dupe stopped due to inactivity (timeout).")
                    break 
                end

                local galaxy = ReplicatedStorage:FindFirstChild("SpawnGalaxyBlock")
                if galaxy then galaxy:FireServer() end

                for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if item:IsA("Tool") then
                        if item.Name == TargetItemName then item.Parent = Character 
                        else item:Destroy() end
                    end
                end

                for _, item in pairs(workspace:GetChildren()) do
                    if item:IsA("Tool") and item:FindFirstChild("Handle") then
                        if item.Name == TargetItemName then item.Handle.CFrame = Character.HumanoidRootPart.CFrame 
                        else item:Destroy() end
                    end
                end

                timeout = timeout + 1
                task.wait() -- HIZ LİMİTİ KALDIRILDI!
            end
            DupeInProgress = false
        end)
    end)
    DupeTab:CreateButton("Stop Dupe Process", function() DupeInProgress = false end)

    -- ==========================================
    -- 4. KILLER SİSTEMİ
    -- ==========================================
    local KillerTab = Window:CreateTab("Killer")
    local KillerEnabled, IgnoreFriends = false, true
    local KillerConnection = nil

    KillerTab:CreateToggle("Ignore Friends", function(s) IgnoreFriends = s end)
    KillerTab:CreateToggle("Enable Killer (Bring All)", function(state)
        KillerEnabled = state
        if KillerEnabled then
            KillerConnection = RunService.Heartbeat:Connect(function()
                local MyChar = LocalPlayer.Character
                local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
                if MyRoot then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                            if IgnoreFriends and player:IsFriendsWith(LocalPlayer.UserId) then continue end
                            player.Character.HumanoidRootPart.CFrame = MyRoot.CFrame * CFrame.new(0, 0, -3.5)
                        end
                    end
                end
            end)
        else
            if KillerConnection then KillerConnection:Disconnect(); KillerConnection = nil end
        end
    end)
end

return GameModule
