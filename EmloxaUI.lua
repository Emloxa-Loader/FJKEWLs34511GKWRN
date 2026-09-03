-- =========================================================================
-- EMLOXA WARE PREMIUM UI v19.0 (OPTIMIZED AURUM EDITION)
-- Fully optimized with memory management, error handling, and performance improvements
-- =========================================================================

local EmloxaLibrary = {}

-- ══════════════════════════════════════
--  SERVICES & CORE REFERENCES
-- ══════════════════════════════════════
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════
--  MEMORY MANAGEMENT & CLEANUP
-- ══════════════════════════════════════
local ActiveConnections = {}
local ActiveTweens = {}
local CachedObjects = {}

local function TrackConnection(connection)
    table.insert(ActiveConnections, connection)
    return connection
end

local function TrackTween(tweenObj)
    table.insert(ActiveTweens, tweenObj)
    return tweenObj
end

local function CleanupConnections()
    for i = #ActiveConnections, 1, -1 do
        local conn = ActiveConnections[i]
        if conn and conn.Connected then
            pcall(function() conn:Disconnect() end)
        end
        table.remove(ActiveConnections, i)
    end
end

local function CleanupTweens()
    for i = #ActiveTweens, 1, -1 do
        local tween = ActiveTweens[i]
        if tween then
            pcall(function() tween:Cancel() end)
        end
        table.remove(ActiveTweens, i)
    end
end

-- ══════════════════════════════════════
--  ASSET DOWNLOADER (Isolated Repo)
-- ══════════════════════════════════════
local LOGO_URL = "https://raw.githubusercontent.com/Emrox2313/Datas/refs/heads/main/foto.png"
local FALLBACK_LOGO = "rbxassetid://107602224137000"

local INTRO_MUSIC_URL = "https://github.com/Emrox2313/Datas/raw/refs/heads/main/loading.mp3"
local FALLBACK_MUSIC = "rbxassetid://3017127417"

local AssetCache = {}

local function getDownloadedAsset(url, fileName, fallback)
    if AssetCache[fileName] then
        return AssetCache[fileName]
    end

    local success, customAsset = pcall(function()
        if writefile and getcustomasset then
            local assetData
            local req = (syn and syn.request) or (http and http.request) or request
            if req then
                local response = req({Url = url, Method = "GET"})
                assetData = response.Body
            elseif game.HttpGet then
                assetData = game:HttpGet(url)
            end
            
            if not assetData then error("Download failed") end
            writefile(fileName, assetData)
            local asset = getcustomasset(fileName)
            AssetCache[fileName] = asset
            return asset
        else
            error("getcustomasset not supported")
        end
    end)

    if success and customAsset then
        return customAsset
    else
        AssetCache[fileName] = fallback
        return fallback
    end
end

local function loadLogo(imageObject)
    task.spawn(function()
        imageObject.Image = getDownloadedAsset(LOGO_URL, "sys_ui_cache_01.png", FALLBACK_LOGO)
    end)
end

-- ══════════════════════════════════════
--  SOUND ENGINE (With Error Handling)
-- ══════════════════════════════════════
local SoundPool = {}
local MAX_SOUNDS = 5

local function createSound(id, volume, looped, parent)
    local success, sound = pcall(function()
        local s = Instance.new("Sound")
        if string.find(tostring(id), "rbxasset") then
            s.SoundId = tostring(id)
        else
            s.SoundId = "rbxassetid://" .. tostring(id)
        end
        s.Volume = volume or 0.5
        s.Looped = looped or false
        s.Parent = parent or SoundService
        return s
    end)
    
    return success and sound or nil
end

local function playSound(id, volume, parent)
    pcall(function()
        -- Limit concurrent sounds
        if #SoundPool >= MAX_SOUNDS then
            local oldest = table.remove(SoundPool, 1)
            if oldest and oldest.Parent then
                oldest:Destroy()
            end
        end

        local sound = createSound(id, volume or 0.5, false, parent or SoundService)
        if sound then
            table.insert(SoundPool, sound)
            sound:Play()
            
            TrackConnection(sound.Ended:Connect(function()
                task.wait(0.1)
                if sound and sound.Parent then
                    sound:Destroy()
                end
                -- Remove from pool
                for i, s in ipairs(SoundPool) do
                    if s == sound then
                        table.remove(SoundPool, i)
                        break
                    end
                end
            end))
        end
    end)
end

-- ══════════════════════════════════════
--  HUI PROTECTION
-- ══════════════════════════════════════
local function GetSafeParent()
    local success, hui = pcall(function() return gethui() end)
    if success and hui then return hui end
    local successCore, core = pcall(function() return game:GetService("CoreGui") end)
    if successCore and core then return core end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function ProtectUI(gui)
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
        elseif protectgui then
            protectgui(gui)
        end
    end)
end

-- ══════════════════════════════════════
--  PHANTOM DECOY SYSTEM
-- ══════════════════════════════════════
local function SpawnDecoys()
    pcall(function()
        local fakeNames = {
            "EmloxaWare", "EMLOXA_PREMIUM_UI", "CoreUI_Telemetry_x86", 
            "RobloxGui_Overlay", "Sys_Audio_Cache", "Emloxa_V18", 
            "Dev_TestUI", "Sys_Data_Container", "MainFrame", "UI_Cache"
        }
        
        local SafeParent = GetSafeParent()
        
        for i = 1, 10 do 
            local fakeGui = Instance.new("ScreenGui")
            if math.random(1, 100) <= 30 then
                local res = ""
                for j = 1, 15 do res = res .. string.char(math.random(97, 122)) end
                fakeGui.Name = res
            else
                fakeGui.Name = fakeNames[math.random(1, #fakeNames)] .. "_" .. tostring(math.random(10,99))
            end
            fakeGui.ResetOnSpawn = false
            fakeGui.Parent = SafeParent
            ProtectUI(fakeGui)
        end
    end)
end

-- ══════════════════════════════════════
--  FILE SYSTEM & CONFIGS
-- ══════════════════════════════════════
local isfolder = isfolder or function() return false end
local makefolder = makefolder or function() end
local isfile = isfile or function() return false end
local writefile = writefile or function() end
local readfile = readfile or function() return "{}" end
local delfile = delfile or function() end
local listfiles = listfiles or function() return {} end

local BaseConfigFolder = "Sys_App_Data_01"
if not isfolder(BaseConfigFolder) then makefolder(BaseConfigFolder) end
local ConfigFolder = BaseConfigFolder .. "/" .. tostring(game.PlaceId)
if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end

local function GetSavedConfigs()
    local list = {}
    pcall(function()
        for _, file in ipairs(listfiles(ConfigFolder)) do
            local fileName = file:match("([^/\\]+)%.json$")
            if fileName and not fileName:find("^%.") then 
                table.insert(list, fileName) 
            end
        end
    end)
    if #list == 0 then table.insert(list, "No Configs Found") end
    return list
end

local ConfigValues = {}
local ConfigCallbacks = {}

local function registerConfig(id, setValue)
    table.insert(ConfigCallbacks, {id = id, set = setValue})
end

-- Clean up invalid config callbacks
local function CleanupConfigCallbacks()
    for i = #ConfigCallbacks, 1, -1 do
        local entry = ConfigCallbacks[i]
        if not entry or not entry.set then
            table.remove(ConfigCallbacks, i)
        end
    end
end

-- ══════════════════════════════════════
--  GITHUB VIP & HWID LOGIC
-- ══════════════════════════════════════
local function GetHWID()
    local clientID = ""
    pcall(function() 
        clientID = RbxAnalyticsService:GetClientId() 
    end)
    if clientID == "" or not clientID then
        clientID = tostring(LocalPlayer.UserId) .. "_DEVICE_HWID"
    end
    return clientID
end

local TimeDataFile = BaseConfigFolder .. "/.sys_limit_daily.json"
local CurrentHWIDData = {
    HWID = GetHWID(),
    RemainingSeconds = 7200, 
    LastResetDate = os.date("%Y-%m-%d"),
    IsLifetime = false,
    CurrentDailyLimit = 7200
}

local function SaveTimeData()
    pcall(function() 
        writefile(TimeDataFile, HttpService:JSONEncode(CurrentHWIDData)) 
    end)
end

local function LoadTimeData()
    if isfile(TimeDataFile) then
        pcall(function()
            local json = readfile(TimeDataFile)
            local decoded = HttpService:JSONDecode(json)
            if decoded and decoded.HWID == GetHWID() then
                CurrentHWIDData = decoded
            end
        end)
    end
end
LoadTimeData()

local VIP_JSON_URL = "https://raw.githubusercontent.com/Emrox2313/Datas/main/vip_users.json"

local function CheckGitHubVIP()
    if LocalPlayer.Name == "deadnegzel61" then return true end
    
    local success, result = pcall(function()
        local req = (syn and syn.request) or (http and http.request) or request
        if req then
            local response = req({Url = VIP_JSON_URL, Method = "GET"})
            return HttpService:JSONDecode(response.Body)
        elseif game.HttpGet then
            local data = game:HttpGet(VIP_JSON_URL)
            return HttpService:JSONDecode(data)
        end
    end)
    
    if success and result and result.vip_users then
        local userIdStr = tostring(LocalPlayer.UserId)
        local expiryDate = result.vip_users[userIdStr]
        if expiryDate then
            local currentYear, currentMonth, currentDay = os.date("%Y"), os.date("%m"), os.date("%d")
            local expYear, expMonth, expDay = expiryDate:match("(%d+)-(%d+)-(%d+)")
            if expYear and expMonth and expDay then
                local currentDateNum = tonumber(currentYear .. currentMonth .. currentDay)
                local expDateNum = tonumber(expYear .. expMonth .. expDay)
                if currentDateNum <= expDateNum then return true end
            end
        end
    end
    return false
end

-- Initialize VIP status
task.spawn(function()
    local maxLimit = 7200
    local isLife = false
    
    local success, results = pcall(function()
        local p4 = MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, 1940574828)
        local p6 = MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, 1940772812)
        local p8 = MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, 1942452785)
        local pLife = MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, 1931252522)
        return {p4, p6, p8, pLife}
    end)
    
    if success then
        if results[4] then 
            isLife = true
        elseif results[3] then 
            maxLimit = 28800 
        elseif results[2] then 
            maxLimit = 21600 
        elseif results[1] then 
            maxLimit = 14400 
        end
    end
    
    if CheckGitHubVIP() then
        isLife = true
        maxLimit = 999999
    end
    
    local today = os.date("%Y-%m-%d")
    if CurrentHWIDData.LastResetDate ~= today then
        CurrentHWIDData.RemainingSeconds = maxLimit
        CurrentHWIDData.LastResetDate = today
    else
        if CurrentHWIDData.CurrentDailyLimit and CurrentHWIDData.CurrentDailyLimit < maxLimit then
            local diff = maxLimit - CurrentHWIDData.CurrentDailyLimit
            CurrentHWIDData.RemainingSeconds = CurrentHWIDData.RemainingSeconds + diff
        end
    end
    
    CurrentHWIDData.CurrentDailyLimit = maxLimit
    CurrentHWIDData.IsLifetime = isLife
    SaveTimeData()
end)

-- ══════════════════════════════════════
--  ENHANCED THEME SYSTEM (From Aurum)
-- ══════════════════════════════════════
local Themes = {
    ["Amethyst"] = {
        Background = Color3.fromRGB(15, 14, 20),
        Sidebar = Color3.fromRGB(11, 10, 16),
        Card = Color3.fromRGB(22, 20, 30),
        CardHover = Color3.fromRGB(28, 26, 38),
        Stroke = Color3.fromRGB(45, 40, 60),
        Accent = Color3.fromRGB(150, 90, 255),
        AccentBright = Color3.fromRGB(190, 140, 255),
        Gold = Color3.fromRGB(255, 200, 90),
        TextMain = Color3.fromRGB(235, 233, 240),
        TextDim = Color3.fromRGB(150, 147, 165),
        Success = Color3.fromRGB(90, 230, 150),
        Danger = Color3.fromRGB(255, 90, 110),
        
        -- Legacy compatibility
        Primary = Color3.fromRGB(150, 90, 255),
        PrimaryDark = Color3.fromRGB(120, 70, 220),
        Panel = Color3.fromRGB(22, 20, 30),
        PanelLight = Color3.fromRGB(30, 30, 38),
        TextColor = Color3.fromRGB(235, 233, 240),
        SubTextColor = Color3.fromRGB(150, 147, 165),
    },
    ["Crimson"] = {
        Background = Color3.fromRGB(17, 12, 14),
        Sidebar = Color3.fromRGB(13, 9, 10),
        Card = Color3.fromRGB(26, 18, 20),
        CardHover = Color3.fromRGB(34, 22, 25),
        Stroke = Color3.fromRGB(60, 35, 40),
        Accent = Color3.fromRGB(255, 80, 100),
        AccentBright = Color3.fromRGB(255, 130, 145),
        Gold = Color3.fromRGB(255, 190, 90),
        TextMain = Color3.fromRGB(240, 233, 235),
        TextDim = Color3.fromRGB(160, 145, 148),
        Success = Color3.fromRGB(90, 230, 150),
        Danger = Color3.fromRGB(255, 60, 80),
        
        Primary = Color3.fromRGB(255, 80, 100),
        PrimaryDark = Color3.fromRGB(200, 60, 80),
        Panel = Color3.fromRGB(26, 18, 20),
        PanelLight = Color3.fromRGB(34, 22, 25),
        TextColor = Color3.fromRGB(240, 233, 235),
        SubTextColor = Color3.fromRGB(160, 145, 148),
    },
    ["Emerald"] = {
        Background = Color3.fromRGB(11, 16, 14),
        Sidebar = Color3.fromRGB(8, 12, 10),
        Card = Color3.fromRGB(16, 24, 20),
        CardHover = Color3.fromRGB(21, 31, 26),
        Stroke = Color3.fromRGB(35, 55, 45),
        Accent = Color3.fromRGB(80, 230, 160),
        AccentBright = Color3.fromRGB(130, 255, 195),
        Gold = Color3.fromRGB(255, 210, 100),
        TextMain = Color3.fromRGB(230, 240, 235),
        TextDim = Color3.fromRGB(145, 160, 152),
        Success = Color3.fromRGB(90, 230, 150),
        Danger = Color3.fromRGB(255, 90, 110),
        
        Primary = Color3.fromRGB(80, 230, 160),
        PrimaryDark = Color3.fromRGB(60, 180, 130),
        Panel = Color3.fromRGB(16, 24, 20),
        PanelLight = Color3.fromRGB(21, 31, 26),
        TextColor = Color3.fromRGB(230, 240, 235),
        SubTextColor = Color3.fromRGB(145, 160, 152),
    },
    ["Sapphire"] = {
        Background = Color3.fromRGB(10, 13, 20),
        Sidebar = Color3.fromRGB(7, 10, 16),
        Card = Color3.fromRGB(15, 20, 30),
        CardHover = Color3.fromRGB(20, 26, 38),
        Stroke = Color3.fromRGB(35, 45, 65),
        Accent = Color3.fromRGB(80, 150, 255),
        AccentBright = Color3.fromRGB(130, 185, 255),
        Gold = Color3.fromRGB(255, 200, 90),
        TextMain = Color3.fromRGB(230, 235, 245),
        TextDim = Color3.fromRGB(140, 150, 165),
        Success = Color3.fromRGB(90, 230, 150),
        Danger = Color3.fromRGB(255, 90, 110),
        
        Primary = Color3.fromRGB(80, 150, 255),
        PrimaryDark = Color3.fromRGB(60, 120, 220),
        Panel = Color3.fromRGB(15, 20, 30),
        PanelLight = Color3.fromRGB(20, 26, 38),
        TextColor = Color3.fromRGB(230, 235, 245),
        SubTextColor = Color3.fromRGB(140, 150, 165),
    },
    ["Monochrome"] = {
        Background = Color3.fromRGB(14, 14, 14),
        Sidebar = Color3.fromRGB(10, 10, 10),
        Card = Color3.fromRGB(21, 21, 21),
        CardHover = Color3.fromRGB(28, 28, 28),
        Stroke = Color3.fromRGB(50, 50, 50),
        Accent = Color3.fromRGB(230, 230, 230),
        AccentBright = Color3.fromRGB(255, 255, 255),
        Gold = Color3.fromRGB(200, 200, 200),
        TextMain = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(150, 150, 150),
        Success = Color3.fromRGB(90, 230, 150),
        Danger = Color3.fromRGB(255, 90, 110),
        
        Primary = Color3.fromRGB(230, 230, 230),
        PrimaryDark = Color3.fromRGB(180, 180, 180),
        Panel = Color3.fromRGB(21, 21, 21),
        PanelLight = Color3.fromRGB(28, 28, 28),
        TextColor = Color3.fromRGB(240, 240, 240),
        SubTextColor = Color3.fromRGB(150, 150, 150),
    },
}

local CurrentTheme = Themes["Amethyst"]

-- Helper functions
local function createCorner(frame, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = frame
    return c
end

local function createStroke(frame, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or CurrentTheme.Primary
    s.Thickness = thickness or 1
    s.Parent = frame
    return s
end

local function createShadow(parent, size, offset, trans)
    local s = Instance.new("ImageLabel")
    s.Image = "rbxassetid://6014261993"
    s.ScaleType = Enum.ScaleType.Slice
    s.SliceCenter = Rect.new(49,49,49,49)
    s.Size = size or UDim2.new(1,20,1,20)
    s.Position = UDim2.new(0,offset or -10,0,offset or -10)
    s.BackgroundTransparency = 1
    s.ImageTransparency = trans or 0.7
    s.ImageColor3 = Color3.new(0,0,0)
    s.Parent = parent
    return s
end

local function playHoverSound() 
    playSound(88442833509532, 0.5) 
end

local function playClickSound() 
    playSound(87437544236708, 0.5) 
end

-- Optimized theme system with cleanup
local ThemeObjects = {}

local function registerThemeable(obj, propertyMap)
    table.insert(ThemeObjects, {object = obj, props = propertyMap})
end

local function CleanupThemeObjects()
    for i = #ThemeObjects, 1, -1 do
        local entry = ThemeObjects[i]
        if not entry.object or not entry.object.Parent then
            table.remove(ThemeObjects, i)
        end
    end
end

local function applyTheme(theme)
    CurrentTheme = theme
    CleanupThemeObjects() -- Remove dead references
    
    for _, entry in ipairs(ThemeObjects) do
        local obj = entry.object
        local props = entry.props
        if obj and obj.Parent then
            pcall(function()
                for propName, themeKey in pairs(props) do
                    local color = theme[themeKey]
                    if color then 
                        local tween = TweenService:Create(obj, TweenInfo.new(0.3), {[propName] = color})
                        TrackTween(tween)
                        tween:Play()
                    end
                end
            end)
        end
    end
end

function EmloxaLibrary:SetTheme(themeName)
    local theme = Themes[themeName]
    if theme then 
        applyTheme(theme) 
    end
end

function EmloxaLibrary:GetThemeNames()
    local names = {}
    for name,_ in pairs(Themes) do 
        table.insert(names, name) 
    end
    return names
end

-- ══════════════════════════════════════
--  OPTIMIZED FRAME PRELOADER
-- ══════════════════════════════════════
local BASE_FRAME_URL = "https://raw.githubusercontent.com/Emrox2313/Datas/refs/heads/main/"
local CAT_FRAMES = {
    {file = "frame_00_delay-0.07s.png", time = 0.07}, {file = "frame_01_delay-0.06s.png", time = 0.06},
    {file = "frame_02_delay-0.07s.png", time = 0.07}, {file = "frame_03_delay-0.07s.png", time = 0.07},
    {file = "frame_04_delay-0.06s.png", time = 0.06}, {file = "frame_05_delay-0.07s.png", time = 0.07},
    {file = "frame_06_delay-0.07s.png", time = 0.07}, {file = "frame_07_delay-0.06s.png", time = 0.06},
    {file = "frame_08_delay-0.07s.png", time = 0.07}, {file = "frame_09_delay-0.07s.png", time = 0.07},
    {file = "frame_10_delay-0.06s.png", time = 0.06}, {file = "frame_11_delay-0.07s.png", time = 0.07},
    {file = "frame_12_delay-0.07s.png", time = 0.07}, {file = "frame_13_delay-0.06s.png", time = 0.06},
    {file = "frame_14_delay-0.07s.png", time = 0.07}, {file = "frame_15_delay-0.07s.png", time = 0.07},
    {file = "frame_16_delay-0.06s.png", time = 0.06}, {file = "frame_17_delay-0.07s.png", time = 0.07},
    {file = "frame_18_delay-0.07s.png", time = 0.07}, {file = "frame_19_delay-0.06s.png", time = 0.06},
    {file = "frame_20_delay-0.07s.png", time = 0.07}, {file = "frame_21_delay-0.07s.png", time = 0.07},
    {file = "frame_22_delay-0.06s.png", time = 0.06}, {file = "frame_23_delay-0.07s.png", time = 0.07},
    {file = "frame_24_delay-0.07s.png", time = 0.07}, {file = "frame_25_delay-0.06s.png", time = 0.06},
    {file = "frame_26_delay-0.07s.png", time = 0.07}, {file = "frame_27_delay-0.07s.png", time = 0.07},
    {file = "frame_28_delay-0.06s.png", time = 0.06}, {file = "frame_29_delay-0.07s.png", time = 0.07},
    {file = "frame_30_delay-0.07s.png", time = 0.07}, {file = "frame_31_delay-0.06s.png", time = 0.06}
}

local frameCache = {}

local function ShowPreloadNotification(HubGui)
    playSound(131390520971848, 0.7) 
    
    local Notif = Instance.new("Frame")
    Notif.Size = UDim2.new(0, 320, 0, 70)
    Notif.Position = UDim2.new(1, 10, 1, -80)
    Notif.BackgroundColor3 = CurrentTheme.Panel
    Notif.Active = true
    Notif.ZIndex = 999999
    Notif.Parent = HubGui
    createCorner(Notif,10)
    createStroke(Notif, CurrentTheme.Primary,2)
    createShadow(Notif, UDim2.new(1,14,1,14), -7, 0.7)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = "Emloxa Ware"
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 15
    TitleLabel.TextColor3 = CurrentTheme.Primary
    TitleLabel.Size = UDim2.new(1,-20,0,22)
    TitleLabel.Position = UDim2.new(0,10,0,8)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 999999
    TitleLabel.Parent = Notif

    local MsgLabel = Instance.new("TextLabel")
    MsgLabel.Text = "Script executed, please wait while assets load..."
    MsgLabel.Font = Enum.Font.Gotham
    MsgLabel.TextSize = 12
    MsgLabel.TextColor3 = CurrentTheme.TextColor
    MsgLabel.Size = UDim2.new(1,-20,0,30)
    MsgLabel.Position = UDim2.new(0,10,0,32)
    MsgLabel.BackgroundTransparency = 1
    MsgLabel.TextXAlignment = Enum.TextXAlignment.Left
    MsgLabel.TextWrapped = true
    MsgLabel.ZIndex = 999999
    MsgLabel.Parent = Notif
    
    local tween = TweenService:Create(Notif, TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Position = UDim2.new(1,-330,1,-80)})
    TrackTween(tween)
    tween:Play()
    
    return Notif
end

-- Optimized intro with proper cleanup
local function ShowDancinIntro(HubGui, callback)
    local IntroGui = Instance.new("Frame")
    IntroGui.Size = UDim2.new(1,0,1,0)
    IntroGui.BackgroundColor3 = Color3.fromRGB(135, 206, 250)
    IntroGui.BorderSizePixel = 0
    IntroGui.ZIndex = 999998
    IntroGui.Active = true
    IntroGui.Parent = HubGui

    local OrangeGlow = Instance.new("Frame")
    OrangeGlow.Size = UDim2.new(1, 0, 0.6, 0)
    OrangeGlow.Position = UDim2.new(0, 0, 1, 0)
    OrangeGlow.AnchorPoint = Vector2.new(0, 1)
    OrangeGlow.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    OrangeGlow.BorderSizePixel = 0
    OrangeGlow.ZIndex = 999998
    OrangeGlow.Parent = IntroGui

    local GlowGradient = Instance.new("UIGradient")
    GlowGradient.Rotation = 90
    GlowGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.2),
        NumberSequenceKeypoint.new(1, 0)
    }
    GlowGradient.Parent = OrangeGlow

    local musicAssetId = getDownloadedAsset(INTRO_MUSIC_URL, "emloxa_loading_music.mp3", FALLBACK_MUSIC)
    local IntroMusic = Instance.new("Sound")
    IntroMusic.SoundId = musicAssetId
    IntroMusic.Volume = 2
    IntroMusic.Looped = true
    IntroMusic.Parent = IntroGui
    IntroMusic:Play()

    local CenterText = Instance.new("TextLabel")
    CenterText.Size = UDim2.new(0, 500, 0, 100)
    CenterText.AnchorPoint = Vector2.new(0.5, 0.5)
    CenterText.Position = UDim2.new(0.5, 0, 0.45, 0)
    CenterText.Text = "EMLOXA WARE"
    CenterText.Font = Enum.Font.GothamBlack
    CenterText.TextSize = 50
    CenterText.TextColor3 = Color3.new(1,1,1)
    CenterText.BackgroundTransparency = 1
    CenterText.ZIndex = 999998
    CenterText.Parent = IntroGui
    createShadow(CenterText, UDim2.new(1,30,1,30), -15, 0.5).ZIndex = 999997

    local LeftGif = Instance.new("ImageLabel")
    LeftGif.Size = UDim2.new(0, 220, 0, 220)
    LeftGif.AnchorPoint = Vector2.new(0.5, 0.5)
    LeftGif.Position = UDim2.new(0.2, 0, 0.5, 0)
    LeftGif.BackgroundTransparency = 1
    LeftGif.Image = frameCache[1] or FALLBACK_LOGO
    LeftGif.ZIndex = 999998
    LeftGif.Parent = IntroGui

    local RightGif = Instance.new("ImageLabel")
    RightGif.Size = UDim2.new(0, 220, 0, 220)
    RightGif.AnchorPoint = Vector2.new(0.5, 0.5)
    RightGif.Position = UDim2.new(0.8, 0, 0.5, 0)
    RightGif.BackgroundTransparency = 1
    RightGif.Image = frameCache[1] or FALLBACK_LOGO
    RightGif.ZIndex = 999998
    RightGif.Parent = IntroGui

    local SkipText = Instance.new("TextLabel")
    SkipText.Size = UDim2.new(1, 0, 0, 50)
    SkipText.Position = UDim2.new(0, 0, 0.85, 0)
    SkipText.Text = "Click Anywhere To Skip :)"
    SkipText.Font = Enum.Font.GothamBold
    SkipText.TextSize = 20
    SkipText.TextColor3 = Color3.new(1, 1, 1)
    SkipText.BackgroundTransparency = 1
    SkipText.ZIndex = 999998
    SkipText.Visible = false 
    SkipText.Parent = IntroGui

    local SkipButton = Instance.new("TextButton")
    SkipButton.Size = UDim2.new(1, 0, 1, 0)
    SkipButton.BackgroundTransparency = 1
    SkipButton.Text = ""
    SkipButton.ZIndex = 999999
    SkipButton.Active = false 
    SkipButton.Parent = IntroGui

    local isPlaying = true
    local animationConn

    -- Frame animation loop
    task.spawn(function()
        local frameIndex = 1
        while isPlaying and IntroGui.Parent do
            local currentFrameData = CAT_FRAMES[frameIndex]
            
            if isPlaying and frameCache[frameIndex] then
                pcall(function()
                    LeftGif.Image = frameCache[frameIndex]
                    RightGif.Image = frameCache[frameIndex]
                end)
            end
            
            task.wait(currentFrameData.time) 
            
            frameIndex = frameIndex + 1
            if frameIndex > #CAT_FRAMES then frameIndex = 1 end
        end
    end)

    -- Show skip button after 5 seconds
    task.spawn(function()
        task.wait(5)
        if isPlaying and SkipText.Parent then
            SkipText.Visible = true
            SkipButton.Active = true
            
            -- Blinking animation
            local blinkConn
            blinkConn = RunService.Heartbeat:Connect(function()
                if not isPlaying or not SkipText.Parent then
                    if blinkConn then blinkConn:Disconnect() end
                    return
                end
            end)
            
            while isPlaying and SkipText.Parent do
                local t1 = TweenService:Create(SkipText, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 0.8})
                TrackTween(t1)
                t1:Play()
                task.wait(0.7)
                
                if not isPlaying then break end
                
                local t2 = TweenService:Create(SkipText, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 0})
                TrackTween(t2)
                t2:Play()
                task.wait(0.7)
            end
        end
    end)

    -- Music-reactive animation with proper cleanup
    local currentGlowHeight = 0.5
    local currentScale = 1
    local renderConn
    
    renderConn = TrackConnection(RunService.RenderStepped:Connect(function(deltaTime)
        if not isPlaying or not IntroGui.Parent then
            if renderConn then renderConn:Disconnect() end
            return
        end
        
        local success = pcall(function()
            local loudness = IntroMusic.PlaybackLoudness
            local targetGlowHeight = 0.4 + (loudness / 1000) * 0.8 
            local targetScale = 1 + (loudness / 600) * 0.35 
            
            currentGlowHeight = currentGlowHeight + (targetGlowHeight - currentGlowHeight) * 12 * deltaTime
            currentScale = currentScale + (targetScale - currentScale) * 18 * deltaTime
            
            OrangeGlow.Size = UDim2.new(1, 0, currentGlowHeight, 0)
            CenterText.Size = UDim2.new(0, 500 * currentScale, 0, 100 * currentScale)
            CenterText.TextSize = 50 * currentScale
            
            LeftGif.Size = UDim2.new(0, 220 * currentScale, 0, 220 * currentScale)
            RightGif.Size = UDim2.new(0, 220 * currentScale, 0, 220 * currentScale)
            
            CenterText.TextColor3 = Color3.fromHSV(tick() * 0.2 % 1, 0.4, 1)
        end)
        
        if not success and renderConn then
            renderConn:Disconnect()
        end
    end))

    local hasClicked = false
    local skipConn = TrackConnection(SkipButton.MouseButton1Click:Connect(function()
        if hasClicked then return end
        hasClicked = true
        isPlaying = false
        
        if renderConn then renderConn:Disconnect() end
        
        playClickSound()
        
        local t1 = TweenService:Create(IntroMusic, TweenInfo.new(1.2), {Volume = 0})
        local t2 = TweenService:Create(IntroGui, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
        local t3 = TweenService:Create(OrangeGlow, TweenInfo.new(1), {BackgroundTransparency = 1})
        local t4 = TweenService:Create(CenterText, TweenInfo.new(0.5), {TextTransparency = 1, TextStrokeTransparency = 1})
        local t5 = TweenService:Create(SkipText, TweenInfo.new(0.5), {TextTransparency = 1})
        local t6 = TweenService:Create(LeftGif, TweenInfo.new(0.5), {ImageTransparency = 1})
        local t7 = TweenService:Create(RightGif, TweenInfo.new(0.5), {ImageTransparency = 1})
        
        TrackTween(t1); TrackTween(t2); TrackTween(t3); TrackTween(t4)
        TrackTween(t5); TrackTween(t6); TrackTween(t7)
        
        t1:Play(); t2:Play(); t3:Play(); t4:Play(); t5:Play(); t6:Play(); t7:Play()
        
        task.wait(1.2)
        pcall(function() IntroGui:Destroy() end)
        if callback then callback() end
    end))
end

-- ══════════════════════════════════════
--  OPTIMIZED IDENTITY HIDER (No nil errors)
-- ══════════════════════════════════════
local identityHiderStateFile = BaseConfigFolder .. "/identity_hider_state.json"
local identityHiderEnabled = false
local knownLocations = {}

local heartbeatConn = nil
local fullScanRunning = false

local disguiseName = "EMLOXAWARE USER"
local disguiseDisplayName = "EMLOXAWARE USER"
local disguiseAvatarURL = ""
local disguiseUserId = 1

local oldIndexMetamethod = nil
local isHookInjected = false

local function LoadIdentityHiderState()
    local success, result = pcall(function()
        if isfile(identityHiderStateFile) then
            local json = readfile(identityHiderStateFile)
            local data = HttpService:JSONDecode(json)
            if type(data) == "boolean" then return data end
        end
        return false
    end)
    
    return success and result or false
end

local function SaveIdentityHiderState(state)
    pcall(function() 
        writefile(identityHiderStateFile, HttpService:JSONEncode(state)) 
    end)
end

local function SelectTargetPlayer(targetString)
    local target = nil
    
    if targetString and targetString ~= "" then
        local searchStr = string.lower(targetString)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and (string.lower(p.Name):sub(1, #searchStr) == searchStr or string.lower(p.DisplayName):sub(1, #searchStr) == searchStr) then
                target = p
                break
            end
        end
    end

    if not target then
        local others = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(others, p) end
        end
        if #others > 0 then
            target = others[math.random(#others)]
        end
    end

    if target then
        disguiseName = target.Name
        disguiseDisplayName = target.DisplayName
        disguiseUserId = target.UserId
        
        task.spawn(function()
            local success, content = pcall(function()
                return Players:GetUserThumbnailAsync(target.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            end)
            if success and content then
                disguiseAvatarURL = content
            else
                disguiseAvatarURL = ""
            end
        end)
    else
        disguiseName = "EMLOXAWARE USER"
        disguiseDisplayName = "EMLOXAWARE USER"
        disguiseUserId = 1
        disguiseAvatarURL = ""
    end
end

local function InjectIdentityHook()
    if isHookInjected then return end
    isHookInjected = true
    
    pcall(function()
        oldIndexMetamethod = hookmetamethod(game, "__index", function(self, key)
            if identityHiderEnabled and self == LocalPlayer then
                if key == "Name" then
                    return disguiseName
                elseif key == "DisplayName" then
                    return disguiseDisplayName
                elseif key == "UserId" then
                    return disguiseUserId
                end
            end
            return oldIndexMetamethod(self, key)
        end)
    end)
end

local function ProcessInstance(instance)
    if not instance or not instance.Parent then return false end
    
    local relevant = false

    pcall(function()
        if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
            local original = instance.Text
            if original and original ~= "" then
                local newText = original
                local changed = false
                
                if original == LocalPlayer.Name then
                    newText = disguiseName
                    changed = true
                elseif original == LocalPlayer.DisplayName then
                    newText = disguiseDisplayName
                    changed = true
                else
                    local replaced1, count1 = string.gsub(newText, LocalPlayer.Name, disguiseName)
                    if count1 > 0 then newText = replaced1; changed = true end
                    
                    local replaced2, count2 = string.gsub(newText, LocalPlayer.DisplayName, disguiseDisplayName)
                    if count2 > 0 then newText = replaced2; changed = true end
                end
                
                if changed then
                    instance.Text = newText
                    relevant = true
                end
            end
        end

        if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
            local img = instance.Image
            if img and img ~= "" then
                if string.find(img, tostring(LocalPlayer.UserId)) then
                    if disguiseAvatarURL ~= "" then
                        instance.Image = disguiseAvatarURL
                    else
                        instance.Image = ""
                    end
                    instance.ImageTransparency = 0
                    relevant = true
                end
            end
        end
    end)

    return relevant
end

local function FastScan()
    for instance, _ in pairs(knownLocations) do
        if not instance or not instance.Parent then
            knownLocations[instance] = nil
        else
            local stillRelevant = ProcessInstance(instance)
            if not stillRelevant then
                knownLocations[instance] = nil
            end
        end
    end
end

local function FullScan()
    pcall(function()
        local containers = {
            game:GetService("CoreGui"),
            LocalPlayer:WaitForChild("PlayerGui"),
            workspace
        }
        
        for _, container in ipairs(containers) do
            if container then
                for _, obj in ipairs(container:GetDescendants()) do
                    if obj and obj.Parent then
                        local relevant = ProcessInstance(obj)
                        if relevant then
                            knownLocations[obj] = true
                        end
                    end
                end
            end
        end
    end)
end

local function FullScanLoop()
    while fullScanRunning do
        if identityHiderEnabled then 
            FullScan() 
        end
        task.wait(1)
    end
end

local function StartIdentityHider()
    if heartbeatConn then return end
    
    InjectIdentityHook()
    
    heartbeatConn = TrackConnection(RunService.Heartbeat:Connect(function()
        if identityHiderEnabled then 
            FastScan() 
        end
    end))
    
    fullScanRunning = true
    task.spawn(FullScanLoop)
end

local function StopIdentityHider()
    if heartbeatConn then
        heartbeatConn:Disconnect()
        heartbeatConn = nil
    end
    fullScanRunning = false
end

local function SetIdentityHider(state, targetString)
    identityHiderEnabled = state
    if state then
        SelectTargetPlayer(targetString)
        StartIdentityHider()
    else
        StopIdentityHider()
    end
    SaveIdentityHiderState(state)
end

-- ══════════════════════════════════════
--  MAIN UI CREATOR (AURUM DESIGN)
-- ══════════════════════════════════════
function EmloxaLibrary:CreateWindow(hubName)
    local WindowSetup = {}
    
    task.spawn(SpawnDecoys)

    local SafeParent = GetSafeParent()
    
    -- Cleanup old instances
    for _, v in pairs(SafeParent:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name == "CoreUI_Telemetry_x64" then
            v:Destroy()
        end
    end

    local HubGui = Instance.new("ScreenGui")
    HubGui.Name = "CoreUI_Telemetry_x64"
    HubGui.ResetOnSpawn = false
    HubGui.IgnoreGuiInset = true
    HubGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    HubGui.DisplayOrder = 999999
    HubGui.Parent = SafeParent
    ProtectUI(HubGui)

    -- ═══ MAIN FRAME (Aurum Style) ═══
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Sys_Data_Container"
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = false
    MainFrame.Active = true
    MainFrame.Parent = HubGui
    createCorner(MainFrame, 12)
    createStroke(MainFrame, CurrentTheme.Accent, 2)
    createShadow(MainFrame, UDim2.new(1,24,1,24), -12, 0.6)
    MainFrame.BackgroundColor3 = CurrentTheme.Background
    registerThemeable(MainFrame, {BackgroundColor3 = "Background"})

    local mainGradient = Instance.new("UIGradient")
    mainGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, CurrentTheme.Background),
        ColorSequenceKeypoint.new(1, CurrentTheme.Sidebar)
    }
    mainGradient.Rotation = 135
    mainGradient.Parent = MainFrame

    -- ═══ OPEN ICON ═══
    local OpenIconFrame = Instance.new("Frame")
    OpenIconFrame.Name = "Sys_Icon_Layer"
    OpenIconFrame.Size = UDim2.new(0, 55, 0, 55)
    OpenIconFrame.Position = UDim2.new(0, 15, 0, 75)
    OpenIconFrame.BackgroundColor3 = CurrentTheme.Card
    OpenIconFrame.Visible = false
    OpenIconFrame.Active = true
    OpenIconFrame.Parent = HubGui
    createCorner(OpenIconFrame, 12)
    local iconStroke = createStroke(OpenIconFrame, CurrentTheme.Accent, 2)
    registerThemeable(OpenIconFrame, {BackgroundColor3 = "Card"})

    local OpenIcon = Instance.new("ImageButton")
    OpenIcon.Size = UDim2.new(1,0,1,0)
    OpenIcon.BackgroundTransparency = 1
    loadLogo(OpenIcon)
    OpenIcon.ScaleType = Enum.ScaleType.Fit
    OpenIcon.Active = true
    OpenIcon.Parent = OpenIconFrame
    createCorner(OpenIcon, 12)

    -- Rainbow stroke animation
    TrackConnection(RunService.RenderStepped:Connect(function()
        if iconStroke and iconStroke.Parent then
            iconStroke.Color = Color3.fromHSV(tick()*0.3 % 1, 0.9, 1)
        end
    end))

    -- ═══ PRELOAD & INTRO ═══
    task.spawn(function()
        local loadingNotif = ShowPreloadNotification(HubGui)
        
        -- Load frames in background
        for i, frameData in ipairs(CAT_FRAMES) do
            pcall(function()
                frameCache[i] = getDownloadedAsset(BASE_FRAME_URL .. frameData.file, "emloxa_cat_"..(i-1)..".png", FALLBACK_LOGO)
            end)
        end
        
        local t = TweenService:Create(loadingNotif, TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Position = UDim2.new(1,10,1,-80)})
        TrackTween(t)
        t:Play()
        task.wait(0.5)
        pcall(function() loadingNotif:Destroy() end)

        ShowDancinIntro(HubGui, function()
            MainFrame.Visible = true
            playSound(128170212983132, 0.5)
            
            local openTween = TweenService:Create(MainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 820, 0, 490)})
            TrackTween(openTween)
            openTween:Play()
            
            task.wait(0.6)
            WindowSetup:ShowDiscordPrompt()
        end)
    end)

    -- ═══ TOP BAR (Aurum Style) ═══
    local TopBar = Instance.new("Frame")
    TopBar.Name = "Header_Nav"
    TopBar.Size = UDim2.new(1,0,0,46)
    TopBar.BackgroundColor3 = CurrentTheme.Sidebar
    TopBar.BorderSizePixel = 0
    TopBar.Active = true
    TopBar.Parent = MainFrame
    createCorner(TopBar, 12)
    registerThemeable(TopBar, {BackgroundColor3 = "Sidebar"})
    
    local topCover = Instance.new("Frame", TopBar)
    topCover.Size = UDim2.new(1,0,0,16)
    topCover.Position = UDim2.new(0,0,1,-16)
    topCover.BackgroundColor3 = CurrentTheme.Sidebar
    topCover.BorderSizePixel = 0

    local TopLogo = Instance.new("ImageLabel")
    TopLogo.Size = UDim2.new(0, 30, 0, 30)
    TopLogo.Position = UDim2.new(0, 12, 0.5, -15)
    TopLogo.BackgroundTransparency = 1
    TopLogo.ClipsDescendants = true
    loadLogo(TopLogo)
    TopLogo.ScaleType = Enum.ScaleType.Fit
    TopLogo.Parent = TopBar
    createCorner(TopLogo, 6)

    local Title = Instance.new("TextLabel")
    Title.Text = hubName
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Size = UDim2.new(0, 150, 1, 0)
    Title.Position = UDim2.new(0, 52, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Parent = TopBar
    
    -- Rainbow title animation
    TrackConnection(RunService.RenderStepped:Connect(function()
        if Title and Title.Parent then
            Title.TextColor3 = Color3.fromHSV(tick()%5/5,0.9,1)
        end
    end))

    -- ═══ TIME CONTAINER (Keep original + button) ═══
    local TimeContainer = Instance.new("Frame")
    TimeContainer.Size = UDim2.new(0, 200, 0, 32)
    TimeContainer.Position = UDim2.new(1, -305, 0.5, -16)
    TimeContainer.BackgroundColor3 = CurrentTheme.PanelLight
    TimeContainer.Parent = TopBar
    createCorner(TimeContainer, 8)
    local timeStroke = createStroke(TimeContainer, CurrentTheme.Primary, 1)
    registerThemeable(TimeContainer, {BackgroundColor3 = "PanelLight"})

    local TimeIcon = Instance.new("TextLabel")
    TimeIcon.Size = UDim2.new(0, 24, 1, 0)
    TimeIcon.Position = UDim2.new(0, 6, 0, 0)
    TimeIcon.Text = "⏳"
    TimeIcon.Font = Enum.Font.GothamBold
    TimeIcon.TextSize = 14
    TimeIcon.BackgroundTransparency = 1
    TimeIcon.Parent = TimeContainer

    local TimeLabel = Instance.new("TextLabel")
    TimeLabel.Size = UDim2.new(1, -62, 1, 0)
    TimeLabel.Position = UDim2.new(0, 30, 0, 0)
    TimeLabel.Text = "02:00:00"
    TimeLabel.Font = Enum.Font.GothamBold
    TimeLabel.TextSize = 12
    TimeLabel.TextColor3 = CurrentTheme.Primary
    TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
    TimeLabel.BackgroundTransparency = 1
    TimeLabel.Parent = TimeContainer
    registerThemeable(TimeLabel, {TextColor3 = "Primary"})

    local PlusBtn = Instance.new("TextButton")
    PlusBtn.Size = UDim2.new(0, 24, 0, 24)
    PlusBtn.Position = UDim2.new(1, -30, 0.5, -12)
    PlusBtn.BackgroundColor3 = CurrentTheme.Primary
    PlusBtn.Text = "+"
    PlusBtn.Font = Enum.Font.GothamBlack
    PlusBtn.TextSize = 18
    PlusBtn.TextColor3 = Color3.new(1,1,1)
    PlusBtn.ZIndex = 5
    PlusBtn.Parent = TimeContainer
    createCorner(PlusBtn, 6)
    registerThemeable(PlusBtn, {BackgroundColor3 = "Primary"})

    -- Time countdown
    task.spawn(function()
        while task.wait(1) do
            if not CurrentHWIDData.IsLifetime then
                if CurrentHWIDData.RemainingSeconds > 0 then
                    CurrentHWIDData.RemainingSeconds = CurrentHWIDData.RemainingSeconds - 1
                    SaveTimeData()
                end
                local hrs = math.floor(CurrentHWIDData.RemainingSeconds / 3600)
                local mins = math.floor((CurrentHWIDData.RemainingSeconds % 3600) / 60)
                local secs = CurrentHWIDData.RemainingSeconds % 60
                
                if TimeLabel and TimeLabel.Parent then
                    TimeLabel.Text = string.format("%02d:%02d:%02d", hrs, mins, secs)
                end
            else
                if TimeLabel and TimeLabel.Parent then
                    TimeLabel.Text = "LIFETIME"
                    TimeLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
                end
            end
        end
    end)

    -- Plus button logic (keep original modal)
    local function canPurchaseExtension()
        if LocalPlayer.Name == "deadnegzel61" then return true end
        return not CurrentHWIDData.IsLifetime
    end

    local function ShowCopiedNotification(msg)
        playSound(131390520971848, 0.7)
        
        local Notif = Instance.new("Frame")
        Notif.Size = UDim2.new(0, 300, 0, 70)
        Notif.Position = UDim2.new(1, 10, 1, -80)
        Notif.BackgroundColor3 = CurrentTheme.Panel
        Notif.Active = true
        Notif.ZIndex = 999999
        Notif.Parent = HubGui
        createCorner(Notif,10)
        createStroke(Notif, CurrentTheme.Primary, 2)
        
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Text = "📋 Link Copied!"
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextSize = 14
        TitleLabel.TextColor3 = CurrentTheme.Primary
        TitleLabel.Size = UDim2.new(1,-20,0,20)
        TitleLabel.Position = UDim2.new(0,10,0,8)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.ZIndex = 999999
        TitleLabel.Parent = Notif
        registerThemeable(TitleLabel, {TextColor3 = "Primary"})
        
        local MsgLabel = Instance.new("TextLabel")
        MsgLabel.Text = msg or "Buy via browser if the in-game prompt doesn't open."
        MsgLabel.Font = Enum.Font.Gotham
        MsgLabel.TextSize = 12
        MsgLabel.TextColor3 = CurrentTheme.TextColor
        MsgLabel.Size = UDim2.new(1,-20,0,30)
        MsgLabel.Position = UDim2.new(0,10,0,32)
        MsgLabel.BackgroundTransparency = 1
        MsgLabel.TextXAlignment = Enum.TextXAlignment.Left
        MsgLabel.TextWrapped = true
        MsgLabel.ZIndex = 999999
        MsgLabel.Parent = Notif
        registerThemeable(MsgLabel, {TextColor3 = "TextColor"})
        
        local t1 = TweenService:Create(Notif, TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Position = UDim2.new(1,-310,1,-80)})
        TrackTween(t1)
        t1:Play()
        
        task.wait(4)
        
        local t2 = TweenService:Create(Notif, TweenInfo.new(0.4), {Position = UDim2.new(1,10,1,-80)})
        TrackTween(t2)
        t2:Play()
        
        task.wait(0.4)
        pcall(function() Notif:Destroy() end)
    end

    local function OpenRechargeModal()
        if not canPurchaseExtension() then return end
        
        local Overlay = Instance.new("Frame")
        Overlay.Size = UDim2.new(1,0,1,0)
        Overlay.BackgroundColor3 = Color3.new(0,0,0)
        Overlay.BackgroundTransparency = 0.5
        Overlay.Active = true
        Overlay.ZIndex = 999998
        Overlay.Parent = HubGui

        local Modal = Instance.new("Frame")
        Modal.Size = UDim2.new(0, 500, 0, 360)
        Modal.Position = UDim2.new(0.5, -250, 0.5, -180)
        Modal.BackgroundColor3 = CurrentTheme.Panel
        Modal.ZIndex = 999999
        Modal.Parent = Overlay
        createCorner(Modal, 12)
        createStroke(Modal, CurrentTheme.Primary, 2)
        registerThemeable(Modal, {BackgroundColor3 = "Panel"})

        local MTitle = Instance.new("TextLabel")
        MTitle.Text = "⚡ Upgrade Daily Limit"
        MTitle.Font = Enum.Font.GothamBlack
        MTitle.TextSize = 16
        MTitle.TextColor3 = CurrentTheme.Primary
        MTitle.Size = UDim2.new(1,-40,0,30)
        MTitle.Position = UDim2.new(0,18,0,12)
        MTitle.BackgroundTransparency = 1
        MTitle.TextXAlignment = Enum.TextXAlignment.Left
        MTitle.ZIndex = 999999
        MTitle.Parent = Modal
        registerThemeable(MTitle, {TextColor3 = "Primary"})

        local MDesc = Instance.new("TextLabel")
        MDesc.Text = "Buy a pass once to permanently increase your DAILY usage limit!"
        MDesc.Font = Enum.Font.Gotham
        MDesc.TextSize = 11
        MDesc.TextColor3 = CurrentTheme.SubTextColor
        MDesc.Size = UDim2.new(1,-40,0,20)
        MDesc.Position = UDim2.new(0,18,0,38)
        MDesc.BackgroundTransparency = 1
        MDesc.TextXAlignment = Enum.TextXAlignment.Left
        MDesc.ZIndex = 999999
        MDesc.Parent = Modal

        local MClose = Instance.new("TextButton")
        MClose.Size = UDim2.new(0,28,0,28)
        MClose.Position = UDim2.new(1,-36,0,12)
        MClose.Text = "X"
        MClose.Font = Enum.Font.GothamBold
        MClose.TextColor3 = CurrentTheme.Accent
        MClose.BackgroundColor3 = CurrentTheme.PanelLight
        MClose.ZIndex = 999999
        MClose.Parent = Modal
        createCorner(MClose,6)
        registerThemeable(MClose, {BackgroundColor3 = "PanelLight"})
        
        TrackConnection(MClose.MouseButton1Click:Connect(function() 
            pcall(function() Overlay:Destroy() end)
        end))

        local Grid = Instance.new("Frame")
        Grid.Size = UDim2.new(1,-36,1,-80)
        Grid.Position = UDim2.new(0,18,0,70)
        Grid.BackgroundTransparency = 1
        Grid.ZIndex = 999999
        Grid.Parent = Modal

        local Layout = Instance.new("UIGridLayout", Grid)
        Layout.CellSize = UDim2.new(0, 222, 0, 120)
        Layout.CellPadding = UDim2.new(0, 18, 0, 18)

        local Options = {
            {Name = "4 Hours Daily", Price = "25 Robux", Info = "+2 Hrs to Default", ID = 1940574828},
            {Name = "6 Hours Daily", Price = "55 Robux", Info = "+4 Hrs to Default", ID = 1940772812},
            {Name = "8 Hours Daily", Price = "70 Robux", Info = "+6 Hrs to Default", ID = 1942452785},
            {Name = "LIFETIME VIP", Price = "250 Robux", Info = "Unlimited Usage", ID = 1931252522}
        }

        for _, opt in ipairs(Options) do
            local Card = Instance.new("Frame")
            Card.BackgroundColor3 = CurrentTheme.PanelLight
            Card.ZIndex = 999999
            Card.Parent = Grid
            createCorner(Card, 8)
            createStroke(Card, CurrentTheme.Primary, 1)

            local CName = Instance.new("TextLabel")
            CName.Text = opt.Name
            CName.Font = Enum.Font.GothamBold
            CName.TextSize = 13
            CName.TextColor3 = CurrentTheme.TextColor
            CName.Size = UDim2.new(1,-10,0,24)
            CName.Position = UDim2.new(0,8,0,6)
            CName.BackgroundTransparency = 1
            CName.TextXAlignment = Enum.TextXAlignment.Left
            CName.ZIndex = 999999
            CName.Parent = Card

            local CInfo = Instance.new("TextLabel")
            CInfo.Text = opt.Info
            CInfo.Font = Enum.Font.GothamBlack
            CInfo.TextSize = 10
            CInfo.TextColor3 = CurrentTheme.Accent
            CInfo.Size = UDim2.new(1,-10,0,18)
            CInfo.Position = UDim2.new(0,8,0,30)
            CInfo.BackgroundTransparency = 1
            CInfo.TextXAlignment = Enum.TextXAlignment.Left
            CInfo.ZIndex = 999999
            CInfo.Parent = Card

            local BuyBtn = Instance.new("TextButton")
            BuyBtn.Size = UDim2.new(1,-16,0,34)
            BuyBtn.Position = UDim2.new(0,8,1,-42)
            BuyBtn.BackgroundColor3 = CurrentTheme.Primary
            BuyBtn.Text = "Buy " .. opt.Price
            BuyBtn.Font = Enum.Font.GothamBold
            BuyBtn.TextColor3 = Color3.new(1,1,1)
            BuyBtn.TextSize = 12
            BuyBtn.ZIndex = 999999
            BuyBtn.Parent = Card
            createCorner(BuyBtn, 6)

            TrackConnection(BuyBtn.MouseButton1Click:Connect(function()
                pcall(function()
                    MarketplaceService:PromptGamePassPurchase(LocalPlayer, opt.ID)
                end)
                if setclipboard then 
                    setclipboard("https://www.roblox.com/game-pass/" .. tostring(opt.ID))
                end
                task.spawn(ShowCopiedNotification)
            end))
        end
    end
    
    TrackConnection(PlusBtn.MouseButton1Click:Connect(OpenRechargeModal))

    -- Purchase completion handler
    TrackConnection(MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, isPurchased)
        if isPurchased and player == LocalPlayer then
            local newLimit = nil
            local wasLife = CurrentHWIDData.IsLifetime
            
            if gamePassId == 1931252522 then
                CurrentHWIDData.IsLifetime = true
                wasLife = true
            elseif gamePassId == 1942452785 then 
                newLimit = 28800
            elseif gamePassId == 1940772812 then 
                newLimit = 21600
            elseif gamePassId == 1940574828 then 
                newLimit = 14400
            end

            if not wasLife and newLimit and newLimit > CurrentHWIDData.CurrentDailyLimit then
                local added = newLimit - CurrentHWIDData.CurrentDailyLimit
                CurrentHWIDData.RemainingSeconds = CurrentHWIDData.RemainingSeconds + added
                CurrentHWIDData.CurrentDailyLimit = newLimit
            end
            
            SaveTimeData()
            playSound(131390520971848, 0.7)
            
            -- Show success notification
            local Notif = Instance.new("Frame")
            Notif.Size = UDim2.new(0, 240, 0, 60)
            Notif.Position = UDim2.new(1, 10, 1, -80)
            Notif.BackgroundColor3 = CurrentTheme.Panel
            Notif.Active = true
            Notif.ZIndex = 999999
            Notif.Parent = HubGui
            createCorner(Notif,10)
            createStroke(Notif, CurrentTheme.Primary,2)
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Text = "Purchase Complete!"
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.TextSize = 14
            TitleLabel.TextColor3 = CurrentTheme.Primary
            TitleLabel.Size = UDim2.new(1,-20,0,20)
            TitleLabel.Position = UDim2.new(0,10,0,8)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.ZIndex = 999999
            TitleLabel.Parent = Notif
            
            local MsgLabel = Instance.new("TextLabel")
            if CurrentHWIDData.IsLifetime then
                MsgLabel.Text = "Lifetime VIP activated!"
            else
                MsgLabel.Text = "Daily limit increased successfully!"
            end
            MsgLabel.Font = Enum.Font.Gotham
            MsgLabel.TextSize = 12
            MsgLabel.TextColor3 = CurrentTheme.TextColor
            MsgLabel.Size = UDim2.new(1,-20,0,20)
            MsgLabel.Position = UDim2.new(0,10,0,32)
            MsgLabel.BackgroundTransparency = 1
            MsgLabel.TextXAlignment = Enum.TextXAlignment.Left
            MsgLabel.ZIndex = 999999
            MsgLabel.Parent = Notif
            
            local t1 = TweenService:Create(Notif, TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Position = UDim2.new(1,-250,1,-80)})
            TrackTween(t1)
            t1:Play()
            
            task.wait(3)
            
            local t2 = TweenService:Create(Notif, TweenInfo.new(0.4), {Position = UDim2.new(1,10,1,-80)})
            TrackTween(t2)
            t2:Play()
            
            task.wait(0.4)
            pcall(function() Notif:Destroy() end)
        end
    end))

    -- ═══ WINDOW CONTROLS ═══
    local Controls = Instance.new("Frame")
    Controls.Size = UDim2.new(0, 90, 1, 0)
    Controls.Position = UDim2.new(1, -100, 0, 0)
    Controls.BackgroundTransparency = 1
    Controls.Parent = TopBar

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0,32,0,32)
    MinBtn.Position = UDim2.new(0,0,0.5,-16)
    MinBtn.Text = "─"
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 20
    MinBtn.TextColor3 = Color3.new(1,1,1)
    MinBtn.BackgroundColor3 = CurrentTheme.PanelLight
    MinBtn.Parent = Controls
    createCorner(MinBtn, 8)
    registerThemeable(MinBtn, {BackgroundColor3 = "PanelLight"})

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0,32,0,32)
    CloseBtn.Position = UDim2.new(0,44,0.5,-16)
    CloseBtn.Text = "X"
    CloseBtn.Font = Enum.Font.GothamBlack
    CloseBtn.TextSize = 16
    CloseBtn.TextColor3 = CurrentTheme.Accent
    CloseBtn.BackgroundColor3 = CurrentTheme.PanelLight
    CloseBtn.Parent = Controls
    createCorner(CloseBtn, 8)
    registerThemeable(CloseBtn, {BackgroundColor3 = "PanelLight", TextColor3 = "Accent"})

    local function addHover(btn)
        TrackConnection(btn.MouseEnter:Connect(function()
            local t = TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Primary, TextColor3 = Color3.new(1,1,1)})
            TrackTween(t)
            t:Play()
            playHoverSound()
        end))
        
        TrackConnection(btn.MouseLeave:Connect(function()
            local origColor = btn == CloseBtn and CurrentTheme.Accent or Color3.new(1,1,1)
            local t = TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.PanelLight, TextColor3 = origColor})
            TrackTween(t)
            t:Play()
        end))
    end
    
    addHover(MinBtn)
    addHover(CloseBtn)

    local isMinimized = false
    
    local function animateWindow(targetSize)
        local t = TweenService:Create(MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize})
        TrackTween(t)
        t:Play()
    end

    TrackConnection(MinBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        playClickSound()
        animateWindow(isMinimized and UDim2.new(0,820,0,46) or UDim2.new(0,820,0,490))
        
        local t = TweenService:Create(MinBtn, TweenInfo.new(0.2), {TextColor3 = isMinimized and CurrentTheme.Primary or Color3.new(1,1,1)})
        TrackTween(t)
        t:Play()
    end))

    TrackConnection(CloseBtn.MouseButton1Click:Connect(function()
        playClickSound()
        
        local t = TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)})
        TrackTween(t)
        t:Play()
        
        task.wait(0.35)
        MainFrame.Visible = false
        OpenIconFrame.Visible = true
        OpenIconFrame.Size = UDim2.new(0,0,0,0)
        
        local t2 = TweenService:Create(OpenIconFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0,55,0,55)})
        TrackTween(t2)
        t2:Play()
    end))

    TrackConnection(OpenIcon.MouseButton1Click:Connect(function()
        playClickSound()
        
        local t = TweenService:Create(OpenIconFrame, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)})
        TrackTween(t)
        t:Play()
        
        task.wait(0.25)
        OpenIconFrame.Visible = false
        MainFrame.Visible = true
        animateWindow(isMinimized and UDim2.new(0,820,0,46) or UDim2.new(0,820,0,490))
    end))

    -- ═══ DRAGGING ═══
    local dragging, dragStart, startPos = false, nil, nil
    
    TrackConnection(TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end))
    
    TrackConnection(TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = false 
        end
    end))
    
    TrackConnection(UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            MainFrame.Position = MainFrame.Position:Lerp(targetPos, 0.35)
        end
    end))

    -- ═══ SIDEBAR (Aurum Style) ═══
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 195, 1, -46)
    Sidebar.Position = UDim2.new(0, 0, 0, 46)
    Sidebar.BackgroundColor3 = CurrentTheme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    registerThemeable(Sidebar, {BackgroundColor3 = "Sidebar"})

    local SidebarScroll = Instance.new("ScrollingFrame")
    SidebarScroll.Size = UDim2.fromScale(1,1)
    SidebarScroll.BackgroundTransparency = 1
    SidebarScroll.BorderSizePixel = 0
    SidebarScroll.ScrollBarThickness = 2
    SidebarScroll.ScrollBarImageColor3 = CurrentTheme.Accent
    SidebarScroll.ScrollBarImageTransparency = 0.5
    SidebarScroll.CanvasSize = UDim2.new(0,0,0,0)
    SidebarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SidebarScroll.Parent = Sidebar

    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 6)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Parent = SidebarScroll
    
    local sidePadding = Instance.new("UIPadding", SidebarScroll)
    sidePadding.PaddingTop = UDim.new(0, 14)
    sidePadding.PaddingLeft = UDim.new(0, 10)
    sidePadding.PaddingRight = UDim.new(0, 10)
    sidePadding.PaddingBottom = UDim.new(0, 10)

    -- ═══ CONTENT AREA ═══
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -195, 1, -46)
    ContentArea.Position = UDim2.fromOffset(195, 46)
    ContentArea.BackgroundTransparency = 1
    ContentArea.ClipsDescendants = true
    ContentArea.Parent = MainFrame

    local Pages = {}
    local Tabs = {}

    -- ═══ TAB CREATION (Keep original names) ═══
    local function CreateTabInternal(tabName, layoutOrder)
        local TabSetup = {}

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 38)
        TabBtn.Text = tabName
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 13
        TabBtn.TextColor3 = CurrentTheme.TextDim
        TabBtn.TextXAlignment = Enum.TextXAlignment.Center
        TabBtn.BackgroundColor3 = CurrentTheme.Sidebar
        TabBtn.LayoutOrder = layoutOrder or #Tabs
        TabBtn.Parent = SidebarScroll
        createCorner(TabBtn, 8)
        registerThemeable(TabBtn, {TextColor3 = "TextDim", BackgroundColor3 = "Sidebar"})

        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 3, 0.6, 0)
        Indicator.AnchorPoint = Vector2.new(0, 0.5)
        Indicator.Position = UDim2.new(0, 2, 0.5, 0)
        Indicator.BackgroundColor3 = CurrentTheme.AccentBright
        Indicator.BackgroundTransparency = 1
        Indicator.BorderSizePixel = 0
        Indicator.Parent = TabBtn
        createCorner(Indicator, 2)

        -- Gradient for indicator
        local indicatorGrad = Instance.new("UIGradient")
        indicatorGrad.Rotation = 90
        indicatorGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, CurrentTheme.AccentBright),
            ColorSequenceKeypoint.new(1, CurrentTheme.Gold or CurrentTheme.Accent)
        })
        indicatorGrad.Parent = Indicator

        local PageScroll = Instance.new("ScrollingFrame")
        PageScroll.Size = UDim2.new(1,0,1,0)
        PageScroll.BackgroundTransparency = 1
        PageScroll.BorderSizePixel = 0
        PageScroll.ScrollBarThickness = 3
        PageScroll.ScrollBarImageColor3 = CurrentTheme.Accent
        PageScroll.Active = true
        PageScroll.Visible = false
        PageScroll.CanvasSize = UDim2.new(0,0,0,0)
        PageScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        PageScroll.Parent = ContentArea

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0,12)
        PageLayout.Parent = PageScroll
        
        local pagePadding = Instance.new("UIPadding", PageScroll)
        pagePadding.PaddingTop = UDim.new(0,18)
        pagePadding.PaddingLeft = UDim.new(0,20)
        pagePadding.PaddingRight = UDim.new(0,16)
        pagePadding.PaddingBottom = UDim.new(0,18)

        TrackConnection(TabBtn.MouseEnter:Connect(function()
            playHoverSound()
            if PageScroll.Visible ~= true then
                local t = TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.CardHover})
                TrackTween(t)
                t:Play()
            end
        end))
        
        TrackConnection(TabBtn.MouseLeave:Connect(function()
            if PageScroll.Visible ~= true then
                local t = TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Sidebar})
                TrackTween(t)
                t:Play()
            end
        end))

        TrackConnection(TabBtn.MouseButton1Click:Connect(function()
            playClickSound()
            
            for _,p in pairs(Pages) do p.Visible = false end
            for _,t in pairs(Tabs) do
                local t1 = TweenService:Create(t.Indicator, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
                local t2 = TweenService:Create(t.Btn, TweenInfo.new(0.3), {TextColor3 = CurrentTheme.TextDim, BackgroundColor3 = CurrentTheme.Sidebar})
                TrackTween(t1); TrackTween(t2)
                t1:Play(); t2:Play()
            end
            
            PageScroll.Visible = true
            
            local t1 = TweenService:Create(Indicator, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
            local t2 = TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = CurrentTheme.TextMain, BackgroundColor3 = CurrentTheme.Card})
            TrackTween(t1); TrackTween(t2)
            t1:Play(); t2:Play()
        end))

        table.insert(Pages, PageScroll)
        table.insert(Tabs, {Btn = TabBtn, Indicator = Indicator})

        -- Auto-select first tab
        if #Pages == 1 then
            PageScroll.Visible = true
            Indicator.BackgroundTransparency = 0
            TabBtn.TextColor3 = CurrentTheme.TextMain
            TabBtn.BackgroundColor3 = CurrentTheme.Card
        end

        local elementCounter = 0
        local function generateId(baseName)
            elementCounter = elementCounter + 1
            return baseName .. "_" .. elementCounter
        end

        -- ═══ ELEMENT CREATORS (Keep original names & functions) ═══
        
        function TabSetup:CreateToggle(name, callback)
            local id = generateId("toggle_" .. name)
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1,0,0,44)
            ToggleFrame.BackgroundColor3 = CurrentTheme.Card
            ToggleFrame.Active = true
            ToggleFrame.Parent = PageScroll
            createCorner(ToggleFrame,10)
            createStroke(ToggleFrame, CurrentTheme.Stroke, 1)
            registerThemeable(ToggleFrame, {BackgroundColor3 = "Card"})

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1,-80,1,0)
            Label.Position = UDim2.new(0,16,0,0)
            Label.Text = name
            Label.Font = Enum.Font.GothamSemibold
            Label.TextSize = 13.5
            Label.TextColor3 = CurrentTheme.TextMain
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = ToggleFrame
            registerThemeable(Label, {TextColor3 = "TextMain"})

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(0,44,0,24)
            Btn.Position = UDim2.new(1,-56,0.5,-12)
            Btn.BackgroundColor3 = CurrentTheme.Stroke
            Btn.Text = ""
            Btn.Parent = ToggleFrame
            createCorner(Btn,12)
            registerThemeable(Btn, {BackgroundColor3 = "Stroke"})

            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0,18,0,18)
            Circle.Position = UDim2.new(0,3,0.5,-9)
            Circle.BackgroundColor3 = Color3.new(1,1,1)
            Circle.Parent = Btn
            createCorner(Circle,9)

            local state = false
            ConfigValues[id] = state
            
            registerConfig(id, function(val)
                state = val
                local gPos = state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
                local gCol = state and CurrentTheme.Accent or CurrentTheme.Stroke
                
                local t1 = TweenService:Create(Circle, TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Position = gPos})
                local t2 = TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = gCol})
                TrackTween(t1); TrackTween(t2)
                t1:Play(); t2:Play()
                
                if callback then 
                    pcall(function() callback(state) end)
                end
            end)

            TrackConnection(Btn.MouseEnter:Connect(playHoverSound))
            
            TrackConnection(Btn.MouseButton1Click:Connect(function()
                playClickSound()
                state = not state
                ConfigValues[id] = state
                
                for _, entry in ipairs(ConfigCallbacks) do
                    if entry.id == id then
                        entry.set(state)
                        break
                    end
                end
            end))

            local ToggleAPI = {}
            function ToggleAPI:SetState(val)
                val = val and true or false
                if state ~= val then
                    for _, entry in ipairs(ConfigCallbacks) do
                        if entry.id == id then
                            entry.set(val)
                            break
                        end
                    end
                end
            end
            function ToggleAPI:GetState()
                return state
            end
            return ToggleAPI
        end

        function TabSetup:CreatePremiumToggle(name, callback)
            local id = generateId("prem_toggle_" .. name)
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1,0,0,44)
            ToggleFrame.BackgroundColor3 = CurrentTheme.Card
            ToggleFrame.Active = true
            ToggleFrame.Parent = PageScroll
            createCorner(ToggleFrame,10)
            createStroke(ToggleFrame, Color3.fromRGB(255, 215, 0), 1)
            registerThemeable(ToggleFrame, {BackgroundColor3 = "Card"})

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1,-120,1,0)
            Label.Position = UDim2.new(0,16,0,0)
            Label.Text = name
            Label.Font = Enum.Font.GothamBold
            Label.TextSize = 13.5
            Label.TextColor3 = CurrentTheme.TextMain
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = ToggleFrame
            registerThemeable(Label, {TextColor3 = "TextMain"})

            local Badge = Instance.new("TextLabel")
            Badge.Size = UDim2.new(0, 50, 0, 16)
            Badge.Position = UDim2.new(1, -115, 0.5, -8)
            Badge.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
            Badge.Text = "PREMIUM"
            Badge.Font = Enum.Font.GothamBlack
            Badge.TextSize = 9
            Badge.TextColor3 = Color3.new(0,0,0)
            Badge.Parent = ToggleFrame
            createCorner(Badge, 4)

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(0,44,0,24)
            Btn.Position = UDim2.new(1,-56,0.5,-12)
            Btn.BackgroundColor3 = CurrentTheme.Stroke
            Btn.Text = ""
            Btn.Parent = ToggleFrame
            createCorner(Btn,12)

            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0,18,0,18)
            Circle.Position = UDim2.new(0,3,0.5,-9)
            Circle.BackgroundColor3 = Color3.new(1,1,1)
            Circle.Parent = Btn
            createCorner(Circle,9)

            local state = false
            ConfigValues[id] = state
            
            registerConfig(id, function(val)
                state = val
                local gPos = state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
                local gCol = state and Color3.fromRGB(255, 215, 0) or CurrentTheme.Stroke
                
                local t1 = TweenService:Create(Circle, TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Position = gPos})
                local t2 = TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = gCol})
                TrackTween(t1); TrackTween(t2)
                t1:Play(); t2:Play()
                
                pcall(function() callback(state) end)
            end)

            TrackConnection(Btn.MouseEnter:Connect(playHoverSound))
            
            TrackConnection(Btn.MouseButton1Click:Connect(function()
                playClickSound()
                state = not state
                ConfigValues[id] = state
                
                for _, entry in ipairs(ConfigCallbacks) do
                    if entry.id == id then
                        entry.set(state)
                        break
                    end
                end
            end))
        end

        function TabSetup:CreateTextbox(name, placeholder, callback)
            local id = generateId("textbox_" .. name)
            
            local BoxFrame = Instance.new("Frame")
            BoxFrame.Size = UDim2.new(1,0,0,44)
            BoxFrame.BackgroundColor3 = CurrentTheme.Card
            BoxFrame.Active = true
            BoxFrame.Parent = PageScroll
            createCorner(BoxFrame,10)
            createStroke(BoxFrame, CurrentTheme.Stroke, 1)
            registerThemeable(BoxFrame, {BackgroundColor3 = "Card"})

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.5,0,1,0)
            Label.Position = UDim2.new(0,16,0,0)
            Label.Text = name
            Label.Font = Enum.Font.GothamSemibold
            Label.TextSize = 13.5
            Label.TextColor3 = CurrentTheme.TextMain
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = BoxFrame
            registerThemeable(Label, {TextColor3 = "TextMain"})

            local TextBoxBg = Instance.new("Frame")
            TextBoxBg.Size = UDim2.new(0.40, 0, 0, 28)
            TextBoxBg.Position = UDim2.new(1, -12, 0.5, -14)
            TextBoxBg.AnchorPoint = Vector2.new(1, 0)
            TextBoxBg.BackgroundColor3 = CurrentTheme.PanelLight
            TextBoxBg.Parent = BoxFrame
            createCorner(TextBoxBg, 6)
            registerThemeable(TextBoxBg, {BackgroundColor3 = "PanelLight"})

            local TxtBox = Instance.new("TextBox")
            TxtBox.Size = UDim2.new(1, -10, 1, 0)
            TxtBox.Position = UDim2.new(0, 5, 0, 0)
            TxtBox.BackgroundTransparency = 1
            TxtBox.Text = ""
            TxtBox.PlaceholderText = placeholder or "Type here..."
            TxtBox.Font = Enum.Font.Gotham
            TxtBox.TextSize = 12
            TxtBox.TextColor3 = CurrentTheme.TextMain
            TxtBox.TextXAlignment = Enum.TextXAlignment.Left
            TxtBox.ClearTextOnFocus = false
            TxtBox.Parent = TextBoxBg
            registerThemeable(TxtBox, {TextColor3 = "TextMain"})

            TrackConnection(TxtBox.FocusLost:Connect(function() 
                pcall(function() callback(TxtBox.Text) end)
            end))
        end

        function TabSetup:CreateDropdown(name, options, default, callback)
            local id = generateId("dropdown_" .. name)
            
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(1,0,0,44)
            DropdownFrame.BackgroundColor3 = CurrentTheme.Card
            DropdownFrame.Active = true
            DropdownFrame.ClipsDescendants = true
            DropdownFrame.Parent = PageScroll
            createCorner(DropdownFrame,10)
            createStroke(DropdownFrame, CurrentTheme.Stroke, 1)
            registerThemeable(DropdownFrame, {BackgroundColor3 = "Card"})

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1,-30,0,44)
            Label.Position = UDim2.new(0,16,0,0)
            Label.Text = name .. " : " .. tostring(default)
            Label.Font = Enum.Font.GothamSemibold
            Label.TextSize = 13.5
            Label.TextColor3 = CurrentTheme.TextMain
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = DropdownFrame
            registerThemeable(Label, {TextColor3 = "TextMain"})

            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Size = UDim2.new(1,0,0,44)
            ToggleBtn.BackgroundTransparency = 1
            ToggleBtn.Text = ""
            ToggleBtn.Parent = DropdownFrame

            local OptionContainer = Instance.new("Frame")
            OptionContainer.Size = UDim2.new(1,0,1,-44)
            OptionContainer.Position = UDim2.new(0,0,0,44)
            OptionContainer.BackgroundTransparency = 1
            OptionContainer.Parent = DropdownFrame
            
            local UIListLayout = Instance.new("UIListLayout", OptionContainer)
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

            local isDropped = false
            local selectedValue = default
            ConfigValues[id] = default
            
            registerConfig(id, function(val)
                selectedValue = val
                Label.Text = name .. " : " .. val
                pcall(function() callback(val) end)
            end)

            local function BuildOptions(optList)
                for _, child in ipairs(OptionContainer:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                
                for _, option in ipairs(optList) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1,0,0,32)
                    OptBtn.BackgroundColor3 = CurrentTheme.PanelLight
                    OptBtn.Text = "  " .. option
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.TextSize = 12.5
                    OptBtn.TextColor3 = CurrentTheme.TextDim
                    OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                    OptBtn.Parent = OptionContainer
                    createCorner(OptBtn,6)
                    registerThemeable(OptBtn, {BackgroundColor3 = "PanelLight", TextColor3 = "TextDim"})

                    TrackConnection(OptBtn.MouseButton1Click:Connect(function()
                        playClickSound()
                        selectedValue = option
                        Label.Text = name .. " : " .. option
                        ConfigValues[id] = option
                        isDropped = false
                        
                        local t1 = TweenService:Create(DropdownFrame, TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,44)})
                        local t2 = TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = CurrentTheme.TextMain})
                        TrackTween(t1); TrackTween(t2)
                        t1:Play(); t2:Play()
                        
                        pcall(function() callback(selectedValue) end)
                    end))

                    TrackConnection(OptBtn.MouseEnter:Connect(function()
                        playHoverSound()
                        local t = TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.CardHover, TextColor3 = Color3.new(1,1,1)})
                        TrackTween(t)
                        t:Play()
                    end))
                    
                    TrackConnection(OptBtn.MouseLeave:Connect(function()
                        local t = TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.PanelLight, TextColor3 = CurrentTheme.TextDim})
                        TrackTween(t)
                        t:Play()
                    end))
                end
            end
            
            BuildOptions(options)

            TrackConnection(ToggleBtn.MouseButton1Click:Connect(function()
                playClickSound()
                isDropped = not isDropped
                
                local childCount = 0
                for _,v in pairs(OptionContainer:GetChildren()) do 
                    if v:IsA("TextButton") then childCount = childCount + 1 end 
                end
                
                local targetHeight = isDropped and (44 + (childCount * 32)) or 44
                
                local t1 = TweenService:Create(DropdownFrame, TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,targetHeight)})
                local t2 = TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = isDropped and CurrentTheme.Accent or CurrentTheme.TextMain})
                TrackTween(t1); TrackTween(t2)
                t1:Play(); t2:Play()
            end))

            local DropdownAPI = {}
            function DropdownAPI:Refresh(newOptions)
                BuildOptions(newOptions)
                if isDropped then
                    local targetHeight = 44 + (#newOptions * 32)
                    local t = TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1,0,0,targetHeight)})
                    TrackTween(t)
                    t:Play()
                end
            end
            return DropdownAPI
        end

        function TabSetup:CreateSlider(name, min, max, default, callback)
            local id = generateId("slider_" .. name)
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1,0,0,58)
            SliderFrame.BackgroundColor3 = CurrentTheme.Card
            SliderFrame.Active = true
            SliderFrame.Parent = PageScroll
            createCorner(SliderFrame,10)
            createStroke(SliderFrame, CurrentTheme.Stroke, 1)
            registerThemeable(SliderFrame, {BackgroundColor3 = "Card"})

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1,-50,0,24)
            Label.Position = UDim2.new(0,16,0,8)
            Label.Text = name
            Label.Font = Enum.Font.GothamSemibold
            Label.TextSize = 13.5
            Label.TextColor3 = CurrentTheme.TextMain
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = SliderFrame
            registerThemeable(Label, {TextColor3 = "TextMain"})

            local ValueText = Instance.new("TextLabel")
            ValueText.Size = UDim2.new(0,50,0,24)
            ValueText.Position = UDim2.new(1,-60,0,8)
            ValueText.Text = tostring(default)
            ValueText.Font = Enum.Font.GothamBold
            ValueText.TextSize = 13.5
            ValueText.TextColor3 = CurrentTheme.Accent
            ValueText.TextXAlignment = Enum.TextXAlignment.Right
            ValueText.BackgroundTransparency = 1
            ValueText.Parent = SliderFrame
            registerThemeable(ValueText, {TextColor3 = "Accent"})

            local Bar = Instance.new("TextButton")
            Bar.Size = UDim2.new(1,-32,0,6)
            Bar.Position = UDim2.new(0,16,0,40)
            Bar.BackgroundColor3 = CurrentTheme.Stroke
            Bar.Text = ""
            Bar.Parent = SliderFrame
            createCorner(Bar,3)
            registerThemeable(Bar, {BackgroundColor3 = "Stroke"})

            local defaultPercent = (default - min) / (max - min)
            
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(defaultPercent,0,1,0)
            Fill.BackgroundColor3 = CurrentTheme.Accent
            Fill.Parent = Bar
            createCorner(Fill,3)
            registerThemeable(Fill, {BackgroundColor3 = "Accent"})

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0,14,0,14)
            Knob.Position = UDim2.new(defaultPercent, -7, 0.5, -7)
            Knob.BackgroundColor3 = Color3.new(1,1,1)
            Knob.BorderSizePixel = 0
            Knob.Parent = Bar
            createCorner(Knob, 7)

            local currentValue = default
            ConfigValues[id] = currentValue
            
            registerConfig(id, function(val)
                currentValue = math.clamp(val, min, max)
                local percent = (currentValue - min) / (max - min)
                Fill.Size = UDim2.new(percent,0,1,0)
                Knob.Position = UDim2.new(percent, -7, 0.5, -7)
                ValueText.Text = tostring(currentValue)
                pcall(function() callback(currentValue) end)
            end)

            local draggingSlider = false
            
            TrackConnection(Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = true
                    playClickSound()
                end
            end))
            
            TrackConnection(UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then 
                    draggingSlider = false 
                end
            end))
            
            TrackConnection(UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = input.Position.X
                    local barPos = Bar.AbsolutePosition.X
                    local barSize = Bar.AbsoluteSize.X
                    local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
                    currentValue = math.floor(min + ((max - min) * percent))
                    ConfigValues[id] = currentValue
                    Fill.Size = UDim2.new(percent,0,1,0)
                    Knob.Position = UDim2.new(percent, -7, 0.5, -7)
                    ValueText.Text = tostring(currentValue)
                    pcall(function() callback(currentValue) end)
                end
            end))
        end

        function TabSetup:CreateButton(name, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1,0,0,42)
            Btn.BackgroundColor3 = CurrentTheme.Card
            Btn.Text = name
            Btn.Font = Enum.Font.GothamBold
            Btn.TextSize = 14
            Btn.TextColor3 = CurrentTheme.TextMain
            Btn.Active = true
            Btn.Parent = PageScroll
            createCorner(Btn,10)
            createStroke(Btn, CurrentTheme.Stroke, 1)
            registerThemeable(Btn, {BackgroundColor3 = "Card", TextColor3 = "TextMain"})

            TrackConnection(Btn.MouseEnter:Connect(playHoverSound))
            
            TrackConnection(Btn.MouseButton1Click:Connect(function()
                playClickSound()
                
                local t1 = TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.98,0,0,40), BackgroundColor3 = CurrentTheme.Accent})
                TrackTween(t1)
                t1:Play()
                
                task.wait(0.1)
                
                local t2 = TweenService:Create(Btn, TweenInfo.new(0.2), {Size = UDim2.new(1,0,0,42), BackgroundColor3 = CurrentTheme.Card})
                TrackTween(t2)
                t2:Play()
                
                pcall(function() callback() end)
            end))
        end

        function TabSetup:CreateDivider()
            local Div = Instance.new("Frame")
            Div.Size = UDim2.new(1, 0, 0, 1)
            Div.BackgroundColor3 = CurrentTheme.Stroke
            Div.BackgroundTransparency = 0.5
            Div.BorderSizePixel = 0
            Div.Parent = PageScroll
            registerThemeable(Div, {BackgroundColor3 = "Stroke"})
        end

        function TabSetup:CreateNotification(title, message, duration)
            duration = duration or 2
            playSound(131390520971848, 0.7) 
            
            local Notif = Instance.new("Frame")
            Notif.Size = UDim2.new(0, 280, 0, 70)
            Notif.Position = UDim2.new(1, 10, 1, -80)
            Notif.BackgroundColor3 = CurrentTheme.Card
            Notif.Active = true
            Notif.ZIndex = 999999
            Notif.Parent = HubGui
            createCorner(Notif,10)
            createStroke(Notif, CurrentTheme.Accent,2)
            createShadow(Notif, UDim2.new(1,14,1,14), -7, 0.7)
            registerThemeable(Notif, {BackgroundColor3 = "Card"})

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Text = title
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.TextSize = 15
            TitleLabel.TextColor3 = CurrentTheme.Accent
            TitleLabel.Size = UDim2.new(1,-20,0,22)
            TitleLabel.Position = UDim2.new(0,10,0,8)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.ZIndex = 999999
            TitleLabel.Parent = Notif
            registerThemeable(TitleLabel, {TextColor3 = "Accent"})

            local MsgLabel = Instance.new("TextLabel")
            MsgLabel.Text = message
            MsgLabel.Font = Enum.Font.Gotham
            MsgLabel.TextSize = 12.5
            MsgLabel.TextColor3 = CurrentTheme.TextMain
            MsgLabel.Size = UDim2.new(1,-20,0,30)
            MsgLabel.Position = UDim2.new(0,10,0,32)
            MsgLabel.BackgroundTransparency = 1
            MsgLabel.TextXAlignment = Enum.TextXAlignment.Left
            MsgLabel.TextWrapped = true
            MsgLabel.ZIndex = 999999
            MsgLabel.Parent = Notif
            registerThemeable(MsgLabel, {TextColor3 = "TextMain"})

            local t1 = TweenService:Create(Notif, TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Position = UDim2.new(1,-290,1,-80)})
            TrackTween(t1)
            t1:Play()
            
            task.wait(duration)
            
            local t2 = TweenService:Create(Notif, TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Position = UDim2.new(1,10,1,-80)})
            TrackTween(t2)
            t2:Play()
            
            task.wait(0.4)
            pcall(function() Notif:Destroy() end)
        end

        return TabSetup
    end

    -- ═══ MENU TAB (Settings) ═══
    local MenuTab = CreateTabInternal("Menu", 9999)
    
    local targetPlayerInput = ""
    
    MenuTab:CreateTextbox("Identity Target", "Leave blank for random...", function(val)
        targetPlayerInput = val
        if identityHiderEnabled then
            SelectTargetPlayer(targetPlayerInput)
        end
    end)

    local identityHiderToggle = MenuTab:CreateToggle("Identity Hider", function(state)
        SetIdentityHider(state, targetPlayerInput)
    end)

    local savedHiderState = LoadIdentityHiderState()
    if savedHiderState then
        identityHiderToggle:SetState(true)
    end

    MenuTab:CreateDropdown("Theme", EmloxaLibrary:GetThemeNames(), "Amethyst", function(val)
        EmloxaLibrary:SetTheme(val)
    end)

    MenuTab:CreateDivider()

    local ConfigNameInput = ""
    local SelectedConfig = "No Configs Found"

    MenuTab:CreateTextbox("New Config Name", "Type config name here...", function(val)
        ConfigNameInput = val
    end)

    local ConfigDropdown
    ConfigDropdown = MenuTab:CreateDropdown("Saved Configs", GetSavedConfigs(), GetSavedConfigs()[1], function(val)
        SelectedConfig = val
    end)

    MenuTab:CreateButton("💾 Save Config", function()
        if ConfigNameInput == "" then 
            MenuTab:CreateNotification("Error", "Please enter a config name first!", 2) 
            return 
        end
        
        CleanupConfigCallbacks()
        
        local data = {}
        for _, entry in ipairs(ConfigCallbacks) do
            data[entry.id] = ConfigValues[entry.id]
        end
        
        local success, err = pcall(function()
            local json = HttpService:JSONEncode(data)
            writefile(ConfigFolder .. "/" .. ConfigNameInput .. ".json", json)
        end)
        
        if success then
            MenuTab:CreateNotification("Success", "Saved Config: " .. ConfigNameInput, 2)
            if ConfigDropdown then ConfigDropdown:Refresh(GetSavedConfigs()) end
        else
            MenuTab:CreateNotification("Error", "Could not save config: " .. tostring(err), 2)
        end
    end)

    MenuTab:CreateButton("📂 Load Config", function()
        if SelectedConfig == "" or SelectedConfig == "No Configs Found" then return end
        
        local path = ConfigFolder .. "/" .. SelectedConfig .. ".json"
        
        if isfile(path) then
            local success, json = pcall(function() return readfile(path) end)
            
            if success then
                local decodeSuccess, data = pcall(HttpService.JSONDecode, HttpService, json)
                
                if decodeSuccess then
                    for id, value in pairs(data) do 
                        ConfigValues[id] = value 
                    end
                    
                    for _, entry in ipairs(ConfigCallbacks) do
                        if ConfigValues[entry.id] ~= nil then
                            pcall(function() entry.set(ConfigValues[entry.id]) end)
                        end
                    end
                    
                    MenuTab:CreateNotification("Success", "Loaded Config: " .. SelectedConfig, 2)
                else
                    MenuTab:CreateNotification("Error", "Failed to decode config file!", 2)
                end
            end
        else
            MenuTab:CreateNotification("Error", "Config file not found!", 2)
        end
    end)

    MenuTab:CreateButton("🗑️ Delete Config", function()
        if SelectedConfig == "" or SelectedConfig == "No Configs Found" then return end
        
        local path = ConfigFolder .. "/" .. SelectedConfig .. ".json"
        
        if isfile(path) then
            delfile(path)
            MenuTab:CreateNotification("Deleted", "Config Removed: " .. SelectedConfig, 2)
            if ConfigDropdown then ConfigDropdown:Refresh(GetSavedConfigs()) end
        else
            MenuTab:CreateNotification("Error", "File does not exist.", 2)
        end
    end)

    MenuTab:CreateButton("📤 Export Config", function()
        if SelectedConfig == "" or SelectedConfig == "No Configs Found" then
            MenuTab:CreateNotification("Error", "No config selected!", 2)
            return
        end
        
        local path = ConfigFolder .. "/" .. SelectedConfig .. ".json"
        
        if isfile(path) then
            local json = readfile(path)
            if setclipboard then
                setclipboard(json)
                MenuTab:CreateNotification("Exported", "Config JSON copied to clipboard!", 2)
            else
                MenuTab:CreateNotification("Error", "Clipboard not supported!", 2)
            end
        else
            MenuTab:CreateNotification("Error", "Config file not found!", 2)
        end
    end)

    MenuTab:CreateButton("📥 Import Config", function()
        local Overlay = Instance.new("Frame")
        Overlay.Size = UDim2.new(1,0,1,0)
        Overlay.BackgroundColor3 = Color3.new(0,0,0)
        Overlay.BackgroundTransparency = 0.5
        Overlay.Active = true
        Overlay.ZIndex = 999998
        Overlay.Parent = HubGui

        local Modal = Instance.new("Frame")
        Modal.Size = UDim2.new(0, 400, 0, 300)
        Modal.Position = UDim2.new(0.5, -200, 0.5, -150)
        Modal.BackgroundColor3 = CurrentTheme.Card
        Modal.ZIndex = 999999
        Modal.Parent = Overlay
        createCorner(Modal, 12)
        createStroke(Modal, CurrentTheme.Accent, 2)
        registerThemeable(Modal, {BackgroundColor3 = "Card"})

        local MTitle = Instance.new("TextLabel")
        MTitle.Text = "📥 Import Config"
        MTitle.Font = Enum.Font.GothamBlack
        MTitle.TextSize = 16
        MTitle.TextColor3 = CurrentTheme.Accent
        MTitle.Size = UDim2.new(1,-40,0,30)
        MTitle.Position = UDim2.new(0,18,0,12)
        MTitle.BackgroundTransparency = 1
        MTitle.TextXAlignment = Enum.TextXAlignment.Left
        MTitle.ZIndex = 999999
        MTitle.Parent = Modal
        registerThemeable(MTitle, {TextColor3 = "Accent"})

        local NameLabel = Instance.new("TextLabel")
        NameLabel.Text = "Config Name:"
        NameLabel.Font = Enum.Font.GothamSemibold
        NameLabel.TextSize = 12
        NameLabel.TextColor3 = CurrentTheme.TextMain
        NameLabel.Size = UDim2.new(1,-36,0,20)
        NameLabel.Position = UDim2.new(0,18,0,50)
        NameLabel.BackgroundTransparency = 1
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.ZIndex = 999999
        NameLabel.Parent = Modal

        local NameBox = Instance.new("TextBox")
        NameBox.Size = UDim2.new(1,-36,0,30)
        NameBox.Position = UDim2.new(0,18,0,72)
        NameBox.BackgroundColor3 = CurrentTheme.PanelLight
        NameBox.Text = ""
        NameBox.PlaceholderText = "Enter config name..."
        NameBox.Font = Enum.Font.Gotham
        NameBox.TextSize = 12
        NameBox.TextColor3 = CurrentTheme.TextMain
        NameBox.ClearTextOnFocus = false
        NameBox.ZIndex = 999999
        NameBox.Parent = Modal
        createCorner(NameBox, 6)
        registerThemeable(NameBox, {BackgroundColor3 = "PanelLight", TextColor3 = "TextMain"})

        local JSONLabel = Instance.new("TextLabel")
        JSONLabel.Text = "Paste JSON:"
        JSONLabel.Font = Enum.Font.GothamSemibold
        JSONLabel.TextSize = 12
        JSONLabel.TextColor3 = CurrentTheme.TextMain
        JSONLabel.Size = UDim2.new(1,-36,0,20)
        JSONLabel.Position = UDim2.new(0,18,0,110)
        JSONLabel.BackgroundTransparency = 1
        JSONLabel.TextXAlignment = Enum.TextXAlignment.Left
        JSONLabel.ZIndex = 999999
        JSONLabel.Parent = Modal

        local JSONBox = Instance.new("TextBox")
        JSONBox.Size = UDim2.new(1,-36,0,100)
        JSONBox.Position = UDim2.new(0,18,0,132)
        JSONBox.BackgroundColor3 = CurrentTheme.PanelLight
        JSONBox.Text = ""
        JSONBox.PlaceholderText = "Paste config JSON here..."
        JSONBox.Font = Enum.Font.Gotham
        JSONBox.TextSize = 10
        JSONBox.TextColor3 = CurrentTheme.TextMain
        JSONBox.ClearTextOnFocus = false
        JSONBox.TextWrapped = true
        JSONBox.ZIndex = 999999
        JSONBox.Parent = Modal
        createCorner(JSONBox, 6)
        registerThemeable(JSONBox, {BackgroundColor3 = "PanelLight", TextColor3 = "TextMain"})

        local ImportBtn = Instance.new("TextButton")
        ImportBtn.Size = UDim2.new(0,120,0,34)
        ImportBtn.Position = UDim2.new(0,18,1,-44)
        ImportBtn.BackgroundColor3 = CurrentTheme.Accent
        ImportBtn.Text = "Import"
        ImportBtn.Font = Enum.Font.GothamBold
        ImportBtn.TextColor3 = Color3.new(1,1,1)
        ImportBtn.TextSize = 13
        ImportBtn.ZIndex = 999999
        ImportBtn.Parent = Modal
        createCorner(ImportBtn, 8)
        registerThemeable(ImportBtn, {BackgroundColor3 = "Accent"})

        local CancelBtn = Instance.new("TextButton")
        CancelBtn.Size = UDim2.new(0,120,0,34)
        CancelBtn.Position = UDim2.new(1,-138,1,-44)
        CancelBtn.BackgroundColor3 = CurrentTheme.PanelLight
        CancelBtn.Text = "Cancel"
        CancelBtn.Font = Enum.Font.Gotham
        CancelBtn.TextColor3 = CurrentTheme.TextDim
        CancelBtn.TextSize = 13
        CancelBtn.ZIndex = 999999
        CancelBtn.Parent = Modal
        createCorner(CancelBtn, 8)
        registerThemeable(CancelBtn, {BackgroundColor3 = "PanelLight", TextColor3 = "TextDim"})

        local function CloseImport()
            local t = TweenService:Create(Modal, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
            TrackTween(t)
            t:Play()
            task.wait(0.3)
            pcall(function() Overlay:Destroy() end)
        end

        TrackConnection(CancelBtn.MouseButton1Click:Connect(CloseImport))
        
        TrackConnection(ImportBtn.MouseButton1Click:Connect(function()
            local cfgName = NameBox.Text
            local jsonData = JSONBox.Text
            
            if cfgName == "" or jsonData == "" then
                MenuTab:CreateNotification("Error", "Name or JSON cannot be empty!", 2)
                return
            end
            
            local success, err = pcall(function()
                HttpService:JSONDecode(jsonData)
                writefile(ConfigFolder .. "/" .. cfgName .. ".json", jsonData)
            end)
            
            if success then
                CloseImport()
                MenuTab:CreateNotification("Success", "Imported Config: " .. cfgName, 2)
                if ConfigDropdown then ConfigDropdown:Refresh(GetSavedConfigs()) end
            else
                MenuTab:CreateNotification("Error", "Invalid JSON format!", 2)
            end
        end))
    end)

    function WindowSetup:CreateTab(tabName)
        return CreateTabInternal(tabName, #Tabs + 1)
    end

    function WindowSetup:ShowDiscordPrompt()
        local PromptFrame = Instance.new("Frame")
        PromptFrame.Size = UDim2.new(0, 350, 0, 140)
        PromptFrame.Position = UDim2.new(1, 20, 1, -160)
        PromptFrame.BackgroundColor3 = CurrentTheme.Card
        PromptFrame.Active = true
        PromptFrame.Parent = HubGui
        createCorner(PromptFrame, 12)
        createStroke(PromptFrame, CurrentTheme.Accent, 2)
        createShadow(PromptFrame, UDim2.new(1,18,1,18), -9, 0.7)
        registerThemeable(PromptFrame, {BackgroundColor3 = "Card"})

        local PTitle = Instance.new("TextLabel")
        PTitle.Text = "🔥 Emloxa Discord"
        PTitle.Font = Enum.Font.GothamBlack
        PTitle.TextSize = 18
        PTitle.TextColor3 = CurrentTheme.Accent
        PTitle.Size = UDim2.new(1,-20,0,30)
        PTitle.Position = UDim2.new(0,10,0,10)
        PTitle.BackgroundTransparency = 1
        PTitle.TextXAlignment = Enum.TextXAlignment.Left
        PTitle.Parent = PromptFrame
        registerThemeable(PTitle, {TextColor3 = "Accent"})

        local PDesc = Instance.new("TextLabel")
        PDesc.Text = "Join our Discord for the latest scripts and support!"
        PDesc.Font = Enum.Font.Gotham
        PDesc.TextSize = 13
        PDesc.TextColor3 = CurrentTheme.TextMain
        PDesc.Size = UDim2.new(1,-20,0,50)
        PDesc.Position = UDim2.new(0,10,0,45)
        PDesc.BackgroundTransparency = 1
        PDesc.TextXAlignment = Enum.TextXAlignment.Left
        PDesc.TextWrapped = true
        PDesc.Parent = PromptFrame
        registerThemeable(PDesc, {TextColor3 = "TextMain"})

        local BtnYes = Instance.new("TextButton")
        BtnYes.Size = UDim2.new(0,150,0,34)
        BtnYes.Position = UDim2.new(0,15,1,-44)
        BtnYes.BackgroundColor3 = CurrentTheme.Accent
        BtnYes.Text = "Copy Link"
        BtnYes.Font = Enum.Font.GothamBold
        BtnYes.TextColor3 = Color3.new(1,1,1)
        BtnYes.TextSize = 13
        BtnYes.Parent = PromptFrame
        createCorner(BtnYes,8)
        registerThemeable(BtnYes, {BackgroundColor3 = "Accent"})

        local BtnNo = Instance.new("TextButton")
        BtnNo.Size = UDim2.new(0,150,0,34)
        BtnNo.Position = UDim2.new(1,-165,1,-44)
        BtnNo.BackgroundColor3 = CurrentTheme.PanelLight
        BtnNo.Text = "No Thanks"
        BtnNo.Font = Enum.Font.Gotham
        BtnNo.TextColor3 = CurrentTheme.TextDim
        BtnNo.TextSize = 13
        BtnNo.Parent = PromptFrame
        createCorner(BtnNo,8)
        registerThemeable(BtnNo, {BackgroundColor3 = "PanelLight", TextColor3 = "TextDim"})

        local t = TweenService:Create(PromptFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1,-370,1,-160)})
        TrackTween(t)
        t:Play()

        local function ClosePrompt()
            local t2 = TweenService:Create(PromptFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1,20,1,-160)})
            TrackTween(t2)
            t2:Play()
            task.wait(0.5)
            pcall(function() PromptFrame:Destroy() end)
        end

        TrackConnection(BtnYes.MouseEnter:Connect(playHoverSound))
        TrackConnection(BtnNo.MouseEnter:Connect(playHoverSound))
        
        TrackConnection(BtnYes.MouseButton1Click:Connect(function()
            playClickSound()
            if setclipboard then setclipboard("https://discord.gg/XjfW7N84jT") end
            BtnYes.Text = "Copied!"
            BtnYes.BackgroundColor3 = Color3.fromRGB(40,200,100)
            local t3 = TweenService:Create(BtnYes, TweenInfo.new(0.15), {Size = UDim2.new(0,155,0,36)})
            TrackTween(t3)
            t3:Play()
            task.wait(1)
            ClosePrompt()
        end))
        
        TrackConnection(BtnNo.MouseButton1Click:Connect(function()
            playClickSound()
            ClosePrompt()
        end))
    end

    return WindowSetup
end

return EmloxaLibrary
