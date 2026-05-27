-- =========================================================================
-- EMLOXA WARE: FUNKY FRIDAY (MASTER CONTROLLER)
-- =========================================================================
local GameModule = {}

function GameModule:Init(Window)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    -- GLOBAL DEĞİŞKENLER (4 ayrı script buradan emir alacak)
    _G.EmloxaAutoPlay = false
    _G.EmloxaAggression = 15
    _G.EmloxaMethod = "Hybrid"

    -- 4 AYRI SCRIPTIN GITHUB LINKLERI (Bunları kendi GitHub linklerinle değiştir)
    local LaneScripts = {
        "https://raw.githubusercontent.com/Emloxa-Loader/FJKEWLs34511GKWRN/refs/heads/main/Lane1.lua",
        "https://raw.githubusercontent.com/Emloxa-Loader/FJKEWLs34511GKWRN/refs/heads/main/Lane2.lua",
        "https://raw.githubusercontent.com/Emloxa-Loader/FJKEWLs34511GKWRN/refs/heads/main/Lane3.lua",
        "https://raw.githubusercontent.com/Emloxa-Loader/FJKEWLs34511GKWRN/refs/heads/main/Lane4.lua"
    }

    -- Scriptleri arka planda sessizce başlat
    for _, url in ipairs(LaneScripts) do
        task.spawn(function()
            pcall(function() loadstring(game:HttpGet(url))() end)
        end)
    end

    -- ==========================================
    -- 1. LOCAL PLAYER SEKME
    -- ==========================================
    local PlayerTab = Window:CreateTab("Local Player")
    
    PlayerTab:CreateToggle("Noclip (Pass Through)", function(s) 
        RunService.Stepped:Connect(function() 
            if s and LocalPlayer.Character then 
                for _, p in pairs(LocalPlayer.Character:GetDescendants()) do 
                    if p:IsA("BasePart") then p.CanCollide = false end 
                end 
            end 
        end)
    end)
    PlayerTab:CreateSlider("WalkSpeed", 16, 250, 16, function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = v end 
    end)
    PlayerTab:CreateSlider("JumpPower", 50, 350, 50, function(v) 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then 
            LocalPlayer.Character.Humanoid.UseJumpPower = true; LocalPlayer.Character.Humanoid.JumpPower = v 
        end 
    end)

    -- ==========================================
    -- 2. AUTO PLAYER (ŞALTER SİSTEMİ)
    -- ==========================================
    local FunkyTab = Window:CreateTab("Auto Player")
    local AdvancedTab = Window:CreateTab("Advanced")

    FunkyTab:CreateToggle("Enable God Mode (4-Core Engine)", function(s) 
        _G.EmloxaAutoPlay = s -- Şalteri aç/kapat, 4 script bunu dinleyecek
    end)

    FunkyTab:CreateSlider("Sick Range (Hassasiyet)", 5, 50, 15, function(v) 
        _G.EmloxaAggression = v 
    end)

    AdvancedTab:CreateDropdown("Autoplay Method", {"Calculate", "Rapid checks", "Hybrid"}, "Hybrid", function(val) 
        _G.EmloxaMethod = val 
    end)

    -- ==========================================
    -- 3. MISC & CLEANUP
    -- ==========================================
    local MiscTab = Window:CreateTab("Misc")
    
    MiscTab:CreateButton("Optimize Graphics (MAX FPS)", function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false
            elseif v:IsA("BasePart") and (v.Material == Enum.Material.Glass or v.Material == Enum.Material.Neon) then v.Material = Enum.Material.SmoothPlastic end
        end
        game:GetService("Lighting").GlobalShadows = false
    end)

    MiscTab:CreateButton("Unload EMLOXA", function()
        _G.EmloxaAutoPlay = false -- Şalteri kapat, diğer scriptler dursun
        local ui = game:GetService("CoreGui"):FindFirstChild("EmloxaWareUI") or LocalPlayer.PlayerGui:FindFirstChild("EmloxaWareUI")
        if ui then ui:Destroy() end
    end)
end

return GameModule
