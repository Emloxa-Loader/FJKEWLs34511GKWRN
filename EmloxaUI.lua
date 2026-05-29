-- =========================================================================
-- EMLOXA UI LIBRARY (V_FINAL - BUTTON HOTFIX)
-- CONFIG MANAGER & EMLOXA WARE RADAR INTEGRATED
-- =========================================================================
local EmloxaUI = {}
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Dosya Sistemi Koruması (Exploitlerin hata vermemesi için sahte fonksiyonlar)
local isfolder = isfolder or function() return false end
local makefolder = makefolder or function() end
local isfile = isfile or function() return false end
local writefile = writefile or function() end
local readfile = readfile or function() return "{}" end
local delfile = delfile or function() end

local ConfigFolder = "EmloxaWare_Configs"
if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end

-- ==========================================
-- EMLOXA GİZLİ RADAR (TRACKER) PROTOKOLÜ
-- ==========================================
local TrackerEnabled = false
local TrackedUsers = {}

local function SetupEmloxaRadar()
    local ChatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if not ChatEvents then return end

    -- Gelen mesajları dinle (Sadece EMLOXA_PING ve PONG mesajlarını yakalar)
    ChatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(msgData)
        if not TrackerEnabled then return end
        local msg = msgData.Message
        local sender = msgData.FromSpeaker
        
        if sender ~= LocalPlayer.Name then
            if msg == "[EMLOXA_PING]" then
                -- Başka biri ping attı, biz de buradayız demek için Pong gönder
                ChatEvents.SayMessageRequest:FireServer("[EMLOXA_PONG]", "All")
                TrackedUsers[sender] = true
                print("Emloxa Radar: User Found ->", sender)
            elseif msg == "[EMLOXA_PONG]" then
                -- Biz ping attık, o cevap verdi
                TrackedUsers[sender] = true
                print("Emloxa Radar: User Found ->", sender)
            end
        end
    end)
end
pcall(SetupEmloxaRadar)

-- ==========================================
-- UI OLUŞTURUCU (ANA KÜTÜPHANE)
-- ==========================================
function EmloxaUI:CreateWindow(Config)
    local Window = {
        Elements = {}, -- Config için tüm ayarları burada tutacağız
        Tabs = {}
    }

    -- Ana Arayüz (Burayı kendi EmloxaUI görsel tasarımına bağlayabilirsin)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "EmloxaWareUI"
    ScreenGui.Parent = CoreGui
    
    -- ==========================================
    -- SEKME (TAB) VE ELEMENT FONKSİYONLARI
    -- ==========================================
    function Window:CreateTab(tabName)
        local Tab = {}
        
        -- TOGGLE OLUŞTURUCU
        function Tab:CreateToggle(name, callback)
            local state = false
            Window.Elements[name] = {
                Type = "Toggle",
                GetValue = function() return state end,
                SetValue = function(val)
                    state = val
                    -- Toggle rengini ve görselini burada değiştir
                    pcall(callback, state)
                end
            }
        end
        
        -- SLIDER OLUŞTURUCU
        function Tab:CreateSlider(name, min, max, default, callback)
            local value = default
            Window.Elements[name] = {
                Type = "Slider",
                GetValue = function() return value end,
                SetValue = function(val)
                    value = val
                    -- Slider çubuğunu ve metnini burada güncelle
                    pcall(callback, value)
                end
            }
        end

        -- DROPDOWN OLUŞTURUCU
        function Tab:CreateDropdown(name, options, default, callback)
            local selected = default
            Window.Elements[name] = {
                Type = "Dropdown",
                GetValue = function() return selected end,
                SetValue = function(val)
                    selected = val
                    -- Dropdown metnini burada güncelle
                    pcall(callback, selected)
                end
            }
        end

        -- BUTTON OLUŞTURUCU (HATA BURADAN KAYNAKLANIYORDU, EKLENDİ!)
        function Tab:CreateButton(name, callback)
            -- Butonlar bir değer(value) saklamadığı için Config sistemine kaydetmiyoruz
            -- Sadece tıklandığında callback'i çalıştıran görsel altyapıyı buraya yazabilirsin
            -- Örnek (Görsel kodlarını buraya entegre edersin):
            -- TextButton.MouseButton1Click:Connect(function() pcall(callback) end)
            
            -- Hata vermemesi için kütüphaneye tanımlandı.
            return true
        end

        -- DIVIDER OLUŞTURUCU (Başka scriptlerde hata çıkmaması için boş fonksiyon)
        function Tab:CreateDivider()
            return true
        end

        return Tab
    end

    -- ==========================================
    -- MENU VE CONFIG SİSTEMİ (OTOMATİK EKLENİR)
    -- ==========================================
    local MenuTab = Window:CreateTab("Menu & Config")
    local CurrentConfigName = "Default"

    -- 1. EMLOXA RADAR (KULLANICI TAKİBİ)
    MenuTab:CreateToggle("Track Emloxa Ware Users", function(state)
        TrackerEnabled = state
        if state then
            -- Açıldığında sunucuya gizli sinyal gönder
            local ChatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if ChatEvents then
                ChatEvents.SayMessageRequest:FireServer("[EMLOXA_PING]", "All")
            end
        else
            TrackedUsers = {} -- Kapatıldığında listeyi temizle
        end
    end)

    -- Tracker kullananları ESP ile işaretleme döngüsü
    RunService.RenderStepped:Connect(function()
        if not TrackerEnabled then return end
        for playerName, _ in pairs(TrackedUsers) do
            local p = Players:FindFirstChild(playerName)
            if p and p.Character and p.Character:FindFirstChild("Head") then
                if not p.Character.Head:FindFirstChild("EmloxaRadarTag") then
                    local bg = Instance.new("BillboardGui", p.Character.Head)
                    bg.Name = "EmloxaRadarTag"
                    bg.Size = UDim2.new(0, 150, 0, 40)
                    bg.StudsOffset = Vector3.new(0, 3, 0)
                    bg.AlwaysOnTop = true
                    
                    local txt = Instance.new("TextLabel", bg)
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.Text = "👑 EMLOXA USER"
                    txt.TextColor3 = Color3.fromRGB(102, 85, 255)
                    txt.TextStrokeTransparency = 0
                    txt.Font = Enum.Font.GothamBold
                end
            end
        end
    end)

    -- 2. CONFIG YÖNETİCİSİ
    MenuTab:CreateDropdown("Selected Config", {"Default", "Legit", "Rage", "EvadeGod"}, "Default", function(val)
        CurrentConfigName = val
    end)

    -- Config Kaydet
    MenuTab:CreateButton("💾 Save Config", function()
        local dataToSave = {}
        for elementName, elementData in pairs(Window.Elements) do
            dataToSave[elementName] = elementData.GetValue()
        end
        
        local success, err = pcall(function()
            local json = HttpService:JSONEncode(dataToSave)
            writefile(ConfigFolder .. "/" .. CurrentConfigName .. ".json", json)
        end)
        
        if success then
            print("Emloxa: Config Saved -> " .. CurrentConfigName)
        else
            warn("Emloxa Config Error: " .. tostring(err))
        end
    end)

    -- Config Yükle
    MenuTab:CreateButton("📂 Load Config", function()
        local path = ConfigFolder .. "/" .. CurrentConfigName .. ".json"
        if isfile(path) then
            local success, json = pcall(function() return readfile(path) end)
            if success then
                local decoded = HttpService:JSONDecode(json)
                for elementName, savedValue in pairs(decoded) do
                    if Window.Elements[elementName] then
                        -- Kaydedilen değeri UI elementine zorla uygula
                        Window.Elements[elementName].SetValue(savedValue)
                    end
                end
                print("Emloxa: Config Loaded -> " .. CurrentConfigName)
            end
        else
            print("Emloxa: Config file not found!")
        end
    end)

    -- Config Sil
    MenuTab:CreateButton("🗑️ Delete Config", function()
        local path = ConfigFolder .. "/" .. CurrentConfigName .. ".json"
        if isfile(path) then
            delfile(path)
            print("Emloxa: Config Deleted -> " .. CurrentConfigName)
        end
    end)

    return Window
end

return EmloxaUI
