-- =========================================================================
-- EMLOXA WARE PREMIUM UI v18.3 (MAXIMUM STEALTH & HYBRID DECOY SYSTEM)
-- ALL ASSET NAMES & INSTANCES DISGUISED AS SYSTEM FILES WITH 100 DECOYS
-- =========================================================================
local EmloxaLibrary = {}

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
--  ASSET DOWNLOADER (Isolated Repo)
-- ══════════════════════════════════════
local LOGO_URL = "https://raw.githubusercontent.com/Emrox2313/Datas/refs/heads/main/foto.png"
local FALLBACK_LOGO = "rbxassetid://107602224137000"

local MUSIC_URL = "https://github.com/Emrox2313/Datas/raw/refs/heads/main/song.mp3"
local FALLBACK_MUSIC = "rbxassetid://140348392510911"

local function getDownloadedAsset(url, fileName, fallback)
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
            return getcustomasset(fileName)
        else
            error("getcustomasset not supported")
        end
    end)

    if success and customAsset then
        return customAsset
    else
        return fallback
    end
end

local function loadLogo(imageObject)
    imageObject.Image = getDownloadedAsset(LOGO_URL, "sys_ui_cache_01.png", FALLBACK_LOGO)
end

-- ══════════════════════════════════════
--  SOUND ENGINE
-- ══════════════════════════════════════
local function createSound(id, volume, looped, parent)
    local sound = Instance.new("Sound")
    if string.find(tostring(id), "rbxasset") then
        sound.SoundId = tostring(id)
    else
        sound.SoundId = "rbxassetid://" .. tostring(id)
    end
    sound.Volume = volume or 0.5
    sound.Looped = looped or false
    sound.Parent = parent or SoundService
    return sound
end

local function playSound(id, volume, parent)
    local sound = createSound(id, volume or 0.5, false, parent or SoundService)
    sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
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
--  PHANTOM DECOY SYSTEM (HYBRID)
-- ══════════════════════════════════════
local function SpawnDecoys()
    local fakeNames = {
        "EmloxaWare", "EMLOXA_PREMIUM_UI", "CoreUI_Telemetry_x86", 
        "RobloxGui_Overlay", "Sys_Audio_Cache", "Emloxa_V18", 
        "Dev_TestUI", "Sys_Data_Container", "MainFrame", "UI_Cache"
    }
    
    local SafeParent = GetSafeParent()
    
    -- 10 Gerçekçi (Ağır) Sahte Menü
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

        local fakeMain = Instance.new("Frame")
        fakeMain.Name = "MainFrame"
        fakeMain.Size = UDim2.new(0, 500, 0, 300)
        fakeMain.Position = UDim2.new(999, 0, 999, 0) 
        fakeMain.Visible = false 
        fakeMain.Parent = fakeGui
        
        local fakeTitle = Instance.new("TextLabel")
        fakeTitle.Name = "HubTitle"
        fakeTitle.Text = "Loading Asset..."
        fakeTitle.Parent = fakeMain

        local lastParent = fakeMain
        for k = 1, math.random(8, 15) do
            local junkObj
            local randType = math.random(1, 3)
            
            if randType == 1 then
                junkObj = Instance.new("Frame")
                junkObj.Name = "Sys_Data_" .. tostring(math.random(1000,9999))
            elseif randType == 2 then
                junkObj = Instance.new("TextLabel")
                junkObj.Name = "Label_" .. tostring(math.random(100,999))
                junkObj.Text = ""
            else
                junkObj = Instance.new("ImageLabel")
                junkObj.Name = "Logo_Cache"
            end
            
            junkObj.Parent = lastParent
            lastParent = junkObj
        end
    end

    -- 90 Hafif (Optimize Edilmiş) Sahte Menü
    for i = 1, 90 do
        local fakeGui = Instance.new("ScreenGui")
        
        if math.random(1, 100) <= 50 then
            local res = ""
            for j = 1, math.random(10, 20) do res = res .. string.char(math.random(97, 122)) end
            fakeGui.Name = res
        else
            fakeGui.Name = fakeNames[math.random(1, #fakeNames)] .. "_lite_" .. tostring(math.random(100,999))
        end
        
        fakeGui.ResetOnSpawn = false
        fakeGui.Parent = SafeParent
        ProtectUI(fakeGui)

        -- Sadece %50 ihtimalle içine tek bir Frame koy (Optimizasyon için)
        if math.random(1, 100) <= 50 then
            local fakeMain = Instance.new("Frame")
            fakeMain.Name = "Container"
            fakeMain.Visible = false
            fakeMain.Parent = fakeGui
        end
    end
end

-- ══════════════════════════════════════
--  WEBHOOK LOGGING
-- ══════════════════════════════════════
local WEBHOOK_URL = "https://discord.com/api/webhooks/1510546005819654205/OQ5-y0GnN9Kaz8311s4WZxfF2WTeJQCPhkV2zzqfTvHtaMD72jzVB-__EMtO2ZoLxmHZ"

local function SendUsageLog()
    if WEBHOOK_URL == "" or WEBHOOK_URL == "BURAYA_LINK_GELECEK" then return end
    local req = (syn and syn.request) or (http and http.request) or request
    if not req then return end
    local executorName = "Unknown"
    if identifyexecutor then
        local ex = identifyexecutor()
        if type(ex) == "string" then executorName = ex end
    end
    local deviceType = "Unknown"
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        deviceType = "📱 Mobile"
    elseif UserInputService.KeyboardEnabled then
        deviceType = "💻 PC"
    elseif UserInputService.GamepadEnabled then
        deviceType = "🎮 Console"
    end
    local avatarImage = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(LocalPlayer.UserId) .. "&width=420&height=420&format=png"
    local data = {
        ["content"] = "",
        ["embeds"] = {{
            ["title"] = "🔥 Emloxa Ware Activated!",
            ["description"] = "A new user session has started.",
            ["color"] = 6656000,
            ["thumbnail"] = {["url"] = avatarImage},
            ["fields"] = {
                {["name"] = "👤 Username", ["value"] = "```" .. LocalPlayer.Name .. "```", ["inline"] = true},
                {["name"] = "🆔 User ID", ["value"] = "```" .. tostring(LocalPlayer.UserId) .. "```", ["inline"] = true},
                {["name"] = "📅 Account Age", ["value"] = tostring(LocalPlayer.AccountAge) .. " Days", ["inline"] = true},
                {["name"] = "💻 Device", ["value"] = deviceType, ["inline"] = true},
                {["name"] = "⚙️ Executor", ["value"] = executorName, ["inline"] = true},
                {["name"] = "🎮 Game Place ID", ["value"] = "```" .. tostring(game.PlaceId) .. "```", ["inline"] = false}
            },
            ["footer"] = {["text"] = "Emloxa Security Core • " .. os.date("%Y-%m-%d %H:%M:%S")}
        }}
    }
    pcall(function()
        req({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
end

-- ══════════════════════════════════════
--  FILE SYSTEM
-- ══════════════════════════════════════
local isfolder = isfolder or function() return false end
local makefolder = makefolder or function() end
local isfile = isfile or function() return false end
local writefile = writefile or function() end
local readfile = readfile or function() return "{}" end
local delfile = delfile or function() end
local listfiles = listfiles or function() return {} end

local ConfigFolder = "Sys_App_Data_01"
if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end

local function GetSavedConfigs()
    local list = {}
    if listfiles then
        pcall(function()
            for _, file in ipairs(listfiles(ConfigFolder)) do
                local fileName = file:match("([^/\\]+)%.json$")
                if fileName and not fileName:find("^%.") then table.insert(list, fileName) end
            end
        end)
    end
    if #list == 0 then table.insert(list, "No Configs Found") end
    return list
end

-- ══════════════════════════════════════
--  HWID & DAILY LIMIT LOGIC
-- ══════════════════════════════════════
local function GetHWID()
    local clientID = ""
    pcall(function() clientID = RbxAnalyticsService:GetClientId() end)
    if clientID == "" or not clientID then
        clientID = tostring(LocalPlayer.UserId) .. "_DEVICE_HWID"
    end
    return clientID
end

local TimeDataFile = ConfigFolder .. "/.sys_limit_daily.json"

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
        if results[4] then isLife = true
        elseif results[3] then maxLimit = 28800 
        elseif results[2] then maxLimit = 21600 
        elseif results[1] then maxLimit = 14400 
        end
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
--  THEMES
-- ══════════════════════════════════════
local Themes = {
    ["Default"] = {
        Primary = Color3.fromRGB(130, 110, 255),
        PrimaryDark = Color3.fromRGB(90, 75, 220),
        Background = Color3.fromRGB(14, 14, 20),
        Panel = Color3.fromRGB(22, 22, 30),
        PanelLight = Color3.fromRGB(30, 30, 38),
        Accent = Color3.fromRGB(255, 100, 100),
        TextColor = Color3.fromRGB(245, 245, 255),
        SubTextColor = Color3.fromRGB(160, 160, 175),
    },
    ["Neon Nights"] = {
        Primary = Color3.fromRGB(0, 255, 200),
        PrimaryDark = Color3.fromRGB(0, 200, 150),
        Background = Color3.fromRGB(10, 10, 20),
        Panel = Color3.fromRGB(20, 20, 35),
        PanelLight = Color3.fromRGB(30, 30, 50),
        Accent = Color3.fromRGB(255, 70, 150),
        TextColor = Color3.fromRGB(220, 255, 240),
        SubTextColor = Color3.fromRGB(120, 200, 180),
    },
    ["Cyberpunk"] = {
        Primary = Color3.fromRGB(255, 210, 0),
        PrimaryDark = Color3.fromRGB(200, 160, 0),
        Background = Color3.fromRGB(18, 14, 25),
        Panel = Color3.fromRGB(28, 22, 35),
        PanelLight = Color3.fromRGB(40, 32, 50),
        Accent = Color3.fromRGB(255, 0, 100),
        TextColor = Color3.fromRGB(255, 240, 200),
        SubTextColor = Color3.fromRGB(200, 180, 140),
    },
}

local CurrentTheme = Themes["Default"]

local function createCorner(frame, radius)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, radius or 6); c.Parent = frame
    return c
end
local function createStroke(frame, color, thickness)
    local s = Instance.new("UIStroke"); s.Color = color or CurrentTheme.Primary; s.Thickness = thickness or 1; s.Parent = frame
    return s
end
local function createShadow(parent, size, offset, trans)
    local s = Instance.new("ImageLabel")
    s.Image = "rbxassetid://6014261993"; s.ScaleType = Enum.ScaleType.Slice; s.SliceCenter = Rect.new(49,49,49,49)
    s.Size = size or UDim2.new(1,20,1,20); s.Position = UDim2.new(0,offset or -10,0,offset or -10)
    s.BackgroundTransparency = 1; s.ImageTransparency = trans or 0.7; s.ImageColor3 = Color3.new(0,0,0); s.Parent = parent
    return s
end

local function playHoverSound()
    playSound(88442833509532, 0.5)
end
local function playClickSound()
    playSound(87437544236708, 0.5)
end

local ThemeObjects = {}
local function registerThemeable(obj, propertyMap)
    table.insert(ThemeObjects, {object = obj, props = propertyMap})
end
local function applyTheme(theme)
    CurrentTheme = theme
    for _, entry in ipairs(ThemeObjects) do
        local obj = entry.object
        local props = entry.props
        if obj and obj.Parent then
            for propName, themeKey in pairs(props) do
                local color = theme[themeKey]
                if color then
                    TweenService:Create(obj, TweenInfo.new(0.3), {[propName] = color}):Play()
                end
            end
        end
    end
end
function EmloxaLibrary:SetTheme(themeName)
    local theme = Themes[themeName]
    if theme then applyTheme(theme) end
end
function EmloxaLibrary:GetThemeNames()
    local names = {}
    for name,_ in pairs(Themes) do table.insert(names, name) end
    return names
end

-- ══════════════════════════════════════
--  CONFIG STORAGE
-- ══════════════════════════════════════
local ConfigValues = {}
local ConfigCallbacks = {}
local function registerConfig(id, setValue)
    table.insert(ConfigCallbacks, {id = id, set = setValue})
end

-- ══════════════════════════════════════
--  MAIN UI CREATOR
-- ══════════════════════════════════════
function EmloxaLibrary:CreateWindow(hubName)
    local WindowSetup = {}
    
    -- YENİ EKLENEN SİSTEM: 100 Tane Sahte Hedefi Asenkron Olarak Oyuna Salar
    task.spawn(SpawnDecoys)
    
    task.spawn(SendUsageLog)

    local SafeParent = GetSafeParent()

    for _, v in pairs(SafeParent:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name == "CoreUI_Telemetry_x64" then
            v:Destroy()
        end
    end

    local HubGui = Instance.new("ScreenGui")
    HubGui.Name = "CoreUI_Telemetry_x64" 
    HubGui.ResetOnSpawn = false
    HubGui.IgnoreGuiInset = true
    HubGui.Parent = SafeParent
    
    ProtectUI(HubGui)

    local OpenIconFrame = Instance.new("Frame")
    OpenIconFrame.Name = "Sys_Icon_Layer"
    OpenIconFrame.Size = UDim2.new(0, 55, 0, 55)
    OpenIconFrame.Position = UDim2.new(0, 15, 0, 75)
    OpenIconFrame.BackgroundColor3 = CurrentTheme.Panel
    OpenIconFrame.Visible = false
    OpenIconFrame.Active = true
    OpenIconFrame.Parent = HubGui
    createCorner(OpenIconFrame, 12)
    local iconStroke = createStroke(OpenIconFrame, CurrentTheme.Primary, 2)
    registerThemeable(OpenIconFrame, {BackgroundColor3 = "Panel"})

    local OpenIcon = Instance.new("ImageButton")
    OpenIcon.Size = UDim2.new(1,0,1,0)
    OpenIcon.BackgroundTransparency = 1
    loadLogo(OpenIcon)
    OpenIcon.ScaleType = Enum.ScaleType.Fit
    OpenIcon.Active = true
    OpenIcon.Parent = OpenIconFrame
    createCorner(OpenIcon, 12)

    RunService.RenderStepped:Connect(function()
        iconStroke.Color = Color3.fromHSV(tick()*0.3 % 1, 0.9, 1)
    end)

    local LoadingFrame = Instance.new("Frame")
    LoadingFrame.Name = "Load_Buffer"
    LoadingFrame.Size = UDim2.new(1,0,1,0)
    LoadingFrame.BackgroundColor3 = CurrentTheme.Background
    LoadingFrame.Active = true
    LoadingFrame.Parent = HubGui
    local loadingConnections = {}

    local bgGradient = Instance.new("UIGradient")
    bgGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(10,10,16)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18,18,30))
    }
    bgGradient.Rotation = 45
    bgGradient.Parent = LoadingFrame

    local LoadLogoContainer = Instance.new("Frame")
    LoadLogoContainer.Size = UDim2.new(0, 120, 0, 120)
    LoadLogoContainer.Position = UDim2.new(0.5, -60, 0.4, -60)
    LoadLogoContainer.BackgroundTransparency = 1
    LoadLogoContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    LoadLogoContainer.Position = UDim2.new(0.5, 0, 0.4, 0)
    LoadLogoContainer.Parent = LoadingFrame

    local LoadLogo = Instance.new("ImageLabel")
    LoadLogo.Size = UDim2.new(1,0,1,0)
    LoadLogo.BackgroundTransparency = 1
    LoadLogo.ClipsDescendants = true
    loadLogo(LoadLogo)
    LoadLogo.ScaleType = Enum.ScaleType.Fit
    LoadLogo.Parent = LoadLogoContainer
    createCorner(LoadLogo, 16)

    local pulseTween = TweenService:Create(LoadLogoContainer, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Size = UDim2.new(0, 135, 0, 135)})
    pulseTween:Play()

    local Spinner = Instance.new("Frame")
    Spinner.Size = UDim2.new(0, 50, 0, 50)
    Spinner.Position = UDim2.new(0.5, -25, 0.58, -25)
    Spinner.BackgroundTransparency = 1
    Spinner.Parent = LoadingFrame
    for i=1,8 do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0,6,0,6)
        dot.BackgroundColor3 = CurrentTheme.Primary
        dot.Position = UDim2.new(0.5,-3,0,0)
        dot.AnchorPoint = Vector2.new(0.5,0.5)
        dot.Rotation = (i-1)*45
        dot.Parent = Spinner
        createCorner(dot,3)
        local conn = RunService.RenderStepped:Connect(function()
            if dot and dot.Parent then
                local t = tick()*4 + i*0.5
                dot.BackgroundTransparency = 0.3 + math.abs(math.sin(t))*0.3
            end
        end)
        table.insert(loadingConnections, conn)
    end

    local LoadText = Instance.new("TextLabel")
    LoadText.Text = "EMLOXA WARE"
    LoadText.Font = Enum.Font.GothamBlack
    LoadText.TextSize = 28
    LoadText.BackgroundTransparency = 1
    LoadText.Size = UDim2.new(1,0,0,50)
    LoadText.Position = UDim2.new(0,0,0.72,0)
    LoadText.Parent = LoadingFrame
    RunService.RenderStepped:Connect(function()
        LoadText.TextColor3 = Color3.fromHSV(tick()*0.2 % 1, 0.9, 1)
    end)

    playSound(3320590485, 0.5)
    task.wait(2.5)
    for _, conn in ipairs(loadingConnections) do conn:Disconnect() end
    pulseTween:Cancel()
    
    TweenService:Create(LoadingFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoadLogo, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
    TweenService:Create(LoadText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    task.wait(0.6)
    LoadingFrame:Destroy()
    playSound(128170212983132, 0.5)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Sys_Data_Container"
    MainFrame.Size = UDim2.new(0, 710, 0, 480) 
    MainFrame.Position = UDim2.new(0.5, -355, 0.5, -240)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.Parent = HubGui
    createCorner(MainFrame, 12)
    createStroke(MainFrame, CurrentTheme.Primary, 2)
    createShadow(MainFrame, UDim2.new(1,24,1,24), -12, 0.6)
    MainFrame.BackgroundColor3 = CurrentTheme.Background
    registerThemeable(MainFrame, {BackgroundColor3 = "Background"})

    local mainGradient = Instance.new("UIGradient")
    mainGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(16,16,24)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(22,22,32))
    }
    mainGradient.Rotation = 135
    mainGradient.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.Name = "Header_Nav"
    TopBar.Size = UDim2.new(1,0,0,50)
    TopBar.BackgroundColor3 = CurrentTheme.Panel
    TopBar.BorderSizePixel = 0
    TopBar.Active = true
    TopBar.Parent = MainFrame
    createCorner(TopBar, 12)
    local topCover = Instance.new("Frame", TopBar)
    topCover.Size = UDim2.new(1,0,0.5,0)
    topCover.Position = UDim2.new(0,0,0.5,0)
    topCover.BackgroundColor3 = CurrentTheme.Panel
    topCover.BorderSizePixel = 0
    registerThemeable(TopBar, {BackgroundColor3 = "Panel"})

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
    RunService.RenderStepped:Connect(function()
        Title.TextColor3 = Color3.fromHSV(tick()%5/5,0.9,1)
    end)

    local CreditsText = Instance.new("TextLabel")
    CreditsText.Text = "Made by Emloxa"
    CreditsText.Font = Enum.Font.GothamSemibold
    CreditsText.TextSize = 11
    CreditsText.TextColor3 = CurrentTheme.SubTextColor
    CreditsText.TextXAlignment = Enum.TextXAlignment.Right
    CreditsText.Size = UDim2.new(0, 100, 1, 0)
    CreditsText.Position = UDim2.new(1, -415, 0, 0)
    CreditsText.BackgroundTransparency = 1
    CreditsText.Parent = TopBar
    registerThemeable(CreditsText, {TextColor3 = "SubTextColor"})

    local TimeContainer = Instance.new("Frame")
    TimeContainer.Size = UDim2.new(0, 200, 0, 32)
    TimeContainer.Position = UDim2.new(1, -305, 0.5, -16)
    TimeContainer.BackgroundColor3 = CurrentTheme.PanelLight
    TimeContainer.Parent = TopBar
    createCorner(TimeContainer, 8)
    local timeStroke = createStroke(TimeContainer, CurrentTheme.Primary, 1)
    registerThemeable(TimeContainer, {BackgroundColor3 = "PanelLight"})

    local Controls = Instance.new("Frame")
    Controls.Size = UDim2.new(0, 90, 1, 0)
    Controls.Position = UDim2.new(1, -100, 0, 0)
    Controls.BackgroundTransparency = 1
    Controls.Parent = TopBar

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
                TimeLabel.Text = string.format("%02d:%02d:%02d", hrs, mins, secs)
            else
                TimeLabel.Text = "LIFETIME"
                TimeLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
            end
        end
    end)

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
        Notif.ZIndex = 200
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
        TitleLabel.ZIndex = 205
        TitleLabel.Parent = Notif
        
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
        MsgLabel.ZIndex = 205
        MsgLabel.Parent = Notif
        
        TweenService:Create(Notif, TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Position = UDim2.new(1,-310,1,-80)}):Play()
        task.wait(4)
        TweenService:Create(Notif, TweenInfo.new(0.4), {Position = UDim2.new(1,10,1,-80)}):Play()
        task.wait(0.4)
        Notif:Destroy()
    end

    local function OpenRechargeModal()
        if not canPurchaseExtension() then return end
        local Overlay = Instance.new("Frame")
        Overlay.Size = UDim2.new(1,0,1,0)
        Overlay.BackgroundColor3 = Color3.new(0,0,0)
        Overlay.BackgroundTransparency = 0.5
        Overlay.Active = true
        Overlay.ZIndex = 100
        Overlay.Parent = HubGui

        local Modal = Instance.new("Frame")
        Modal.Size = UDim2.new(0, 500, 0, 360)
        Modal.Position = UDim2.new(0.5, -250, 0.5, -180)
        Modal.BackgroundColor3 = CurrentTheme.Panel
        Modal.ZIndex = 101
        Modal.Parent = Overlay
        createCorner(Modal, 12)
        createStroke(Modal, CurrentTheme.Primary, 2)
        registerThemeable(Modal, {BackgroundColor3 = "Panel"})

        local MTitle = Instance.new("TextLabel")
        MTitle.Text = "⚡ Upgrade Daily Limit"
        MTitle.Font = Enum.Font.GothamBlack; MTitle.TextSize = 16
        MTitle.TextColor3 = CurrentTheme.Primary
        MTitle.Size = UDim2.new(1,-40,0,30); MTitle.Position = UDim2.new(0,18,0,12)
        MTitle.BackgroundTransparency = 1; MTitle.TextXAlignment = Enum.TextXAlignment.Left
        MTitle.ZIndex = 102; MTitle.Parent = Modal
        registerThemeable(MTitle, {TextColor3 = "Primary"})

        local MDesc = Instance.new("TextLabel")
        MDesc.Text = "Buy a pass once to permanently increase your DAILY usage limit! Auto-selects highest tier."
        MDesc.Font = Enum.Font.Gotham; MDesc.TextSize = 11
        MDesc.TextColor3 = CurrentTheme.SubTextColor
        MDesc.Size = UDim2.new(1,-40,0,20); MDesc.Position = UDim2.new(0,18,0,38)
        MDesc.BackgroundTransparency = 1; MDesc.TextXAlignment = Enum.TextXAlignment.Left
        MDesc.ZIndex = 102; MDesc.Parent = Modal

        local MClose = Instance.new("TextButton")
        MClose.Size = UDim2.new(0,28,0,28); MClose.Position = UDim2.new(1,-36,0,12)
        MClose.Text = "X"; MClose.Font = Enum.Font.GothamBold; MClose.TextColor3 = CurrentTheme.Accent
        MClose.BackgroundColor3 = CurrentTheme.PanelLight
        MClose.ZIndex = 102; MClose.Parent = Modal
        createCorner(MClose,6)
        registerThemeable(MClose, {BackgroundColor3 = "PanelLight"})
        MClose.MouseButton1Click:Connect(function() Overlay:Destroy() end)

        local Grid = Instance.new("Frame")
        Grid.Size = UDim2.new(1,-36,1,-80); Grid.Position = UDim2.new(0,18,0,70)
        Grid.BackgroundTransparency = 1
        Grid.ZIndex = 102; Grid.Parent = Modal

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
            Card.ZIndex = 103; Card.Parent = Grid
            createCorner(Card, 8)
            createStroke(Card, CurrentTheme.Primary, 1)

            local CName = Instance.new("TextLabel")
            CName.Text = opt.Name; CName.Font = Enum.Font.GothamBold; CName.TextSize = 13
            CName.TextColor3 = CurrentTheme.TextColor; CName.Size = UDim2.new(1,-10,0,24)
            CName.Position = UDim2.new(0,8,0,6); CName.BackgroundTransparency = 1
            CName.TextXAlignment = Enum.TextXAlignment.Left
            CName.ZIndex = 104; CName.Parent = Card

            local CInfo = Instance.new("TextLabel")
            CInfo.Text = opt.Info; CInfo.Font = Enum.Font.GothamBlack; CInfo.TextSize = 10
            CInfo.TextColor3 = CurrentTheme.Accent; CInfo.Size = UDim2.new(1,-10,0,18)
            CInfo.Position = UDim2.new(0,8,0,30); CInfo.BackgroundTransparency = 1
            CInfo.TextXAlignment = Enum.TextXAlignment.Left
            CInfo.ZIndex = 104; CInfo.Parent = Card

            local BuyBtn = Instance.new("TextButton")
            BuyBtn.Size = UDim2.new(1,-16,0,34); BuyBtn.Position = UDim2.new(0,8,1,-42)
            BuyBtn.BackgroundColor3 = CurrentTheme.Primary; BuyBtn.Text = "Buy " .. opt.Price
            BuyBtn.Font = Enum.Font.GothamBold; BuyBtn.TextColor3 = Color3.new(1,1,1)
            BuyBtn.TextSize = 12
            BuyBtn.ZIndex = 105; BuyBtn.Parent = Card
            createCorner(BuyBtn, 6)

            BuyBtn.MouseButton1Click:Connect(function()
                pcall(function()
                    MarketplaceService:PromptGamePassPurchase(LocalPlayer, opt.ID)
                end)
                if setclipboard then
                    setclipboard("https://www.roblox.com/game-pass/" .. tostring(opt.ID))
                end
                task.spawn(ShowCopiedNotification)
            end)
        end
    end
    PlusBtn.MouseButton1Click:Connect(OpenRechargeModal)

    MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, isPurchased)
        if isPurchased and player == LocalPlayer then
            local newLimit = nil
            local wasLife = CurrentHWIDData.IsLifetime
            
            if gamePassId == 1931252522 then
                CurrentHWIDData.IsLifetime = true
                wasLife = true
            elseif gamePassId == 1942452785 then newLimit = 28800
            elseif gamePassId == 1940772812 then newLimit = 21600
            elseif gamePassId == 1940574828 then newLimit = 14400
            end

            if not wasLife and newLimit and newLimit > CurrentHWIDData.CurrentDailyLimit then
                local added = newLimit - CurrentHWIDData.CurrentDailyLimit
                CurrentHWIDData.RemainingSeconds = CurrentHWIDData.RemainingSeconds + added
                CurrentHWIDData.CurrentDailyLimit = newLimit
            end
            
            SaveTimeData()
            playSound(131390520971848, 0.7)
            
            local Notif = Instance.new("Frame")
            Notif.Size = UDim2.new(0, 240, 0, 60)
            Notif.Position = UDim2.new(1, 10, 1, -80)
            Notif.BackgroundColor3 = CurrentTheme.Panel
            Notif.Active = true
            Notif.ZIndex = 200
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
            TitleLabel.ZIndex = 205
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
            MsgLabel.ZIndex = 205
            MsgLabel.Parent = Notif
            
            TweenService:Create(Notif, TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Position = UDim2.new(1,-250,1,-80)}):Play()
            task.wait(3)
            TweenService:Create(Notif, TweenInfo.new(0.4), {Position = UDim2.new(1,10,1,-80)}):Play()
            task.wait(0.4)
            Notif:Destroy()
        end
    end)

    local musicAssetId = getDownloadedAsset(MUSIC_URL, "sys_audio_cache_01.mp3", FALLBACK_MUSIC)
    local bgMusic = createSound(musicAssetId, 0.25, true, HubGui)
    bgMusic.Name = "Sys_Audio_Stream"
    
    local bgMusicEnabled = true
    local bgMusicConfigFile = ConfigFolder .. "/.bgmusic.json"
    if isfile(bgMusicConfigFile) then
        pcall(function()
            local json = readfile(bgMusicConfigFile)
            local data = HttpService:JSONDecode(json)
            if data and data.Enabled ~= nil then bgMusicEnabled = data.Enabled end
        end)
    end
    if bgMusicEnabled then bgMusic:Play() else bgMusic:Stop() end

    local function saveBGMusicState()
        pcall(function()
            writefile(bgMusicConfigFile, HttpService:JSONEncode({Enabled = bgMusicEnabled}))
        end)
    end

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
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Primary, TextColor3 = Color3.new(1,1,1)}):Play()
            playHoverSound()
        end)
        btn.MouseLeave:Connect(function()
            local origColor = btn == CloseBtn and CurrentTheme.Accent or Color3.new(1,1,1)
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.PanelLight, TextColor3 = origColor}):Play()
        end)
    end
    addHover(MinBtn)
    addHover(CloseBtn)

    local isMinimized = false
    local function animateWindow(targetSize)
        TweenService:Create(MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
    end

    MinBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        playClickSound()
        animateWindow(isMinimized and UDim2.new(0,710,0,50) or UDim2.new(0,710,0,480))
        TweenService:Create(MinBtn, TweenInfo.new(0.2), {TextColor3 = isMinimized and CurrentTheme.Primary or Color3.new(1,1,1)}):Play()
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        playClickSound()
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}):Play()
        task.wait(0.35)
        MainFrame.Visible = false
        OpenIconFrame.Visible = true
        OpenIconFrame.Size = UDim2.new(0,0,0,0)
        TweenService:Create(OpenIconFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0,55,0,55)}):Play()
    end)

    OpenIcon.MouseButton1Click:Connect(function()
        playClickSound()
        TweenService:Create(OpenIconFrame, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}):Play()
        task.wait(0.25)
        OpenIconFrame.Visible = false
        MainFrame.Visible = true
        animateWindow(isMinimized and UDim2.new(0,710,0,50) or UDim2.new(0,710,0,480))
    end)

    local dragging, dragStart, startPos = false, nil, nil
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local targetPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            MainFrame.Position = MainFrame.Position:Lerp(targetPos, 0.35)
        end
    end)

    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "Nav_Panel"
    TabContainer.Size = UDim2.new(0, 160, 1, -50)
    TabContainer.Position = UDim2.new(0, 0, 0, 50)
    TabContainer.BackgroundColor3 = CurrentTheme.Panel
    TabContainer.BorderSizePixel = 0
    TabContainer.Active = true
    TabContainer.Parent = MainFrame
    registerThemeable(TabContainer, {BackgroundColor3 = "Panel"})

    local tabGradient = Instance.new("UIGradient")
    tabGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20,20,28)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(28,28,36))
    }
    tabGradient.Rotation = 90
    tabGradient.Parent = TabContainer

    local TabList = Instance.new("UIListLayout")
    TabList.FillDirection = Enum.FillDirection.Vertical
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 4)
    TabList.Parent = TabContainer

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -160, 1, -50)
    PageContainer.Position = UDim2.new(0, 160, 0, 50)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Active = true
    PageContainer.ClipsDescendants = true
    PageContainer.Parent = MainFrame

    local Pages = {}
    local Tabs = {}

    local function CreateTabInternal(tabName, layoutOrder)
        local TabSetup = {}

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 42)
        TabBtn.Text = tabName
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 13
        TabBtn.TextColor3 = CurrentTheme.SubTextColor
        TabBtn.TextXAlignment = Enum.TextXAlignment.Center
        TabBtn.BackgroundTransparency = 1
        TabBtn.LayoutOrder = layoutOrder or #Tabs
        TabBtn.Parent = TabContainer
        registerThemeable(TabBtn, {TextColor3 = "SubTextColor"})

        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 0, 0, 2)
        Indicator.AnchorPoint = Vector2.new(0.5, 1)
        Indicator.Position = UDim2.new(0.5, 0, 1, 0)
        Indicator.BackgroundColor3 = Color3.new(1,1,1)
        Indicator.BorderSizePixel = 0
        Indicator.Parent = TabBtn

        local PageScroll = Instance.new("ScrollingFrame")
        PageScroll.Size = UDim2.new(1,0,1,0)
        PageScroll.BackgroundTransparency = 1
        PageScroll.BorderSizePixel = 0
        PageScroll.ScrollBarThickness = 3
        PageScroll.ScrollBarImageColor3 = CurrentTheme.Primary
        PageScroll.Active = true
        PageScroll.Visible = false
        PageScroll.CanvasSize = UDim2.new(0,0,0,0)
        PageScroll.Parent = PageContainer

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0,10) 
        PageLayout.Parent = PageScroll
        Instance.new("UIPadding", PageScroll).PaddingTop = UDim.new(0,12)
        Instance.new("UIPadding", PageScroll).PaddingLeft = UDim.new(0,18)
        Instance.new("UIPadding", PageScroll).PaddingRight = UDim.new(0,18)

        PageScroll.ChildAdded:Connect(function(child)
            if child:IsA("GuiObject") then
                task.wait()
                PageScroll.CanvasSize = UDim2.new(0,0,0,PageLayout.AbsoluteContentSize.Y + 24)
            end
        end)

        TabBtn.MouseEnter:Connect(function()
            playHoverSound()
            if PageScroll.Visible ~= true then
                TweenService:Create(TabBtn, TweenInfo.new(0.2), {TextColor3 = Color3.new(1,1,1)}):Play()
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if PageScroll.Visible ~= true then
                TweenService:Create(TabBtn, TweenInfo.new(0.2), {TextColor3 = CurrentTheme.SubTextColor}):Play()
            end
        end)

        TabBtn.MouseButton1Click:Connect(function()
            playClickSound()
            for _,p in pairs(Pages) do p.Visible = false end
            for _,t in pairs(Tabs) do
                TweenService:Create(t.Indicator, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0,0,0,2)}):Play()
                TweenService:Create(t.Btn, TweenInfo.new(0.3), {TextColor3 = CurrentTheme.SubTextColor}):Play()
            end
            PageScroll.Visible = true
            TweenService:Create(Indicator, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -30, 0, 2)}):Play()
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = Color3.new(1,1,1)}):Play()
        end)

        table.insert(Pages, PageScroll)
        table.insert(Tabs, {Btn = TabBtn, Indicator = Indicator})

        if #Pages == 1 then
            PageScroll.Visible = true
            Indicator.Size = UDim2.new(1, -30, 0, 2)
            TabBtn.TextColor3 = Color3.new(1,1,1)
        end

        local elementCounter = 0
        local function generateId(baseName)
            elementCounter = elementCounter + 1
            return baseName .. "_" .. elementCounter
        end

        function TabSetup:CreateToggle(name, callback)
            local id = generateId("toggle_" .. name)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1,0,0,42) 
            ToggleFrame.BackgroundColor3 = CurrentTheme.PanelLight
            ToggleFrame.Active = true
            ToggleFrame.Parent = PageScroll
            createCorner(ToggleFrame,6)
            createStroke(ToggleFrame, CurrentTheme.Primary, 1)
            registerThemeable(ToggleFrame, {BackgroundColor3 = "PanelLight"})

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1,-80,1,0)
            Label.Position = UDim2.new(0,14,0,0)
            Label.Text = name
            Label.Font = Enum.Font.GothamSemibold
            Label.TextSize = 13
            Label.TextColor3 = CurrentTheme.TextColor
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = ToggleFrame
            registerThemeable(Label, {TextColor3 = "TextColor"})

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(0,42,0,22)
            Btn.Position = UDim2.new(1,-56,0.5,-11)
            Btn.BackgroundColor3 = CurrentTheme.Panel
            Btn.Text = ""
            Btn.Parent = ToggleFrame
            createCorner(Btn,11)
            registerThemeable(Btn, {BackgroundColor3 = "Panel"})

            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0,16,0,16)
            Circle.Position = UDim2.new(0,3,0.5,-8)
            Circle.BackgroundColor3 = Color3.new(1,1,1)
            Circle.Parent = Btn
            createCorner(Circle,8)

            local state = false
            ConfigValues[id] = state
            registerConfig(id, function(val)
                state = val
                local gPos = state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
                local gCol = state and CurrentTheme.Primary or CurrentTheme.Panel
                TweenService:Create(Circle, TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Position = gPos}):Play()
                TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = gCol}):Play()
                callback(state)
            end)

            Btn.MouseEnter:Connect(playHoverSound)
            Btn.MouseButton1Click:Connect(function()
                playClickSound()
                state = not state
                ConfigValues[id] = state
                for _, entry in ipairs(ConfigCallbacks) do
                    if entry.id == id then
                        entry.set(state)
                        break
                    end
                end
            end)
        end

        function TabSetup:CreatePremiumToggle(name, callback)
            local id = generateId("prem_toggle_" .. name)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1,0,0,42)
            ToggleFrame.BackgroundColor3 = CurrentTheme.PanelLight
            ToggleFrame.Active = true
            ToggleFrame.Parent = PageScroll
            createCorner(ToggleFrame,6)
            createStroke(ToggleFrame, Color3.fromRGB(255, 215, 0), 1)
            registerThemeable(ToggleFrame, {BackgroundColor3 = "PanelLight"})

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1,-110,1,0)
            Label.Position = UDim2.new(0,14,0,0)
            Label.Text = name 
            Label.Font = Enum.Font.GothamBold
            Label.TextSize = 13
            Label.TextColor3 = CurrentTheme.TextColor
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = ToggleFrame
            registerThemeable(Label, {TextColor3 = "TextColor"})

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
            Btn.Size = UDim2.new(0,42,0,22)
            Btn.Position = UDim2.new(1,-56,0.5,-11)
            Btn.BackgroundColor3 = CurrentTheme.Panel
            Btn.Text = ""
            Btn.Parent = ToggleFrame
            createCorner(Btn,11)
            registerThemeable(Btn, {BackgroundColor3 = "Panel"})

            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0,16,0,16)
            Circle.Position = UDim2.new(0,3,0.5,-8)
            Circle.BackgroundColor3 = Color3.new(1,1,1)
            Circle.Parent = Btn
            createCorner(Circle,8)

            local state = false
            ConfigValues[id] = state
            registerConfig(id, function(val)
                state = val
                local gPos = state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
                local gCol = state and Color3.fromRGB(255, 215, 0) or CurrentTheme.Panel
                TweenService:Create(Circle, TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Position = gPos}):Play()
                TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = gCol}):Play()
                callback(state)
            end)

            Btn.MouseEnter:Connect(playHoverSound)
            Btn.MouseButton1Click:Connect(function()
                playClickSound()
                state = not state
                ConfigValues[id] = state
                for _, entry in ipairs(ConfigCallbacks) do
                    if entry.id == id then
                        entry.set(state)
                        break
                    end
                end
            end)
        end

        function TabSetup:CreateTextbox(name, placeholder, callback)
            local id = generateId("textbox_" .. name)
            local BoxFrame = Instance.new("Frame")
            BoxFrame.Size = UDim2.new(1,0,0,42)
            BoxFrame.BackgroundColor3 = CurrentTheme.PanelLight
            BoxFrame.Active = true
            BoxFrame.Parent = PageScroll
            createCorner(BoxFrame,6)
            createStroke(BoxFrame, CurrentTheme.Primary, 1)
            registerThemeable(BoxFrame, {BackgroundColor3 = "PanelLight"})

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.5,0,1,0)
            Label.Position = UDim2.new(0,14,0,0)
            Label.Text = name
            Label.Font = Enum.Font.GothamSemibold
            Label.TextSize = 13
            Label.TextColor3 = CurrentTheme.TextColor
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = BoxFrame
            registerThemeable(Label, {TextColor3 = "TextColor"})

            local TextBoxBg = Instance.new("Frame")
            TextBoxBg.Size = UDim2.new(0.40, 0, 0, 26)
            TextBoxBg.Position = UDim2.new(1, -12, 0.5, -13)
            TextBoxBg.AnchorPoint = Vector2.new(1, 0)
            TextBoxBg.BackgroundColor3 = CurrentTheme.Panel
            TextBoxBg.Parent = BoxFrame
            createCorner(TextBoxBg, 4)
            registerThemeable(TextBoxBg, {BackgroundColor3 = "Panel"})

            local TxtBox = Instance.new("TextBox")
            TxtBox.Size = UDim2.new(1, -10, 1, 0)
            TxtBox.Position = UDim2.new(0, 5, 0, 0)
            TxtBox.BackgroundTransparency = 1
            TxtBox.Text = ""
            TxtBox.PlaceholderText = placeholder or "Type here..."
            TxtBox.Font = Enum.Font.Gotham
            TxtBox.TextSize = 12
            TxtBox.TextColor3 = CurrentTheme.TextColor
            TxtBox.TextXAlignment = Enum.TextXAlignment.Left
            TxtBox.ClearTextOnFocus = false
            TxtBox.Parent = TextBoxBg
            registerThemeable(TxtBox, {TextColor3 = "TextColor"})

            TxtBox.FocusLost:Connect(function()
                callback(TxtBox.Text)
            end)
        end

        function TabSetup:CreateDropdown(name, options, default, callback)
            local id = generateId("dropdown_" .. name)
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Size = UDim2.new(1,0,0,42)
            DropdownFrame.BackgroundColor3 = CurrentTheme.PanelLight
            DropdownFrame.Active = true
            DropdownFrame.ClipsDescendants = true
            DropdownFrame.Parent = PageScroll
            createCorner(DropdownFrame,6)
            createStroke(DropdownFrame, CurrentTheme.Primary, 1)
            registerThemeable(DropdownFrame, {BackgroundColor3 = "PanelLight"})

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1,-30,0,42)
            Label.Position = UDim2.new(0,14,0,0)
            Label.Text = name .. " : " .. tostring(default)
            Label.Font = Enum.Font.GothamSemibold
            Label.TextSize = 13
            Label.TextColor3 = CurrentTheme.TextColor
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = DropdownFrame
            registerThemeable(Label, {TextColor3 = "TextColor"})

            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Size = UDim2.new(1,0,0,42)
            ToggleBtn.BackgroundTransparency = 1
            ToggleBtn.Text = ""
            ToggleBtn.Parent = DropdownFrame

            local OptionContainer = Instance.new("Frame")
            OptionContainer.Size = UDim2.new(1,0,1,-42)
            OptionContainer.Position = UDim2.new(0,0,0,42)
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
                callback(val)
            end)

            local function BuildOptions(optList)
                for _, child in ipairs(OptionContainer:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                for _, option in ipairs(optList) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1,0,0,30)
                    OptBtn.BackgroundColor3 = CurrentTheme.Panel
                    OptBtn.Text = "  " .. option
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.TextSize = 12
                    OptBtn.TextColor3 = CurrentTheme.SubTextColor
                    OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                    OptBtn.Parent = OptionContainer
                    createCorner(OptBtn,4)
                    registerThemeable(OptBtn, {BackgroundColor3 = "Panel", TextColor3 = "SubTextColor"})

                    OptBtn.MouseButton1Click:Connect(function()
                        playClickSound()
                        selectedValue = option
                        Label.Text = name .. " : " .. option
                        ConfigValues[id] = option
                        isDropped = false
                        TweenService:Create(DropdownFrame, TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,42)}):Play()
                        TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = CurrentTheme.TextColor}):Play()
                        callback(selectedValue)
                    end)

                    OptBtn.MouseEnter:Connect(function()
                        playHoverSound()
                        TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.PrimaryDark, TextColor3 = Color3.new(1,1,1)}):Play()
                    end)
                    OptBtn.MouseLeave:Connect(function()
                        TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Panel, TextColor3 = CurrentTheme.SubTextColor}):Play()
                    end)
                end
            end
            BuildOptions(options)

            ToggleBtn.MouseButton1Click:Connect(function()
                playClickSound()
                isDropped = not isDropped
                local childCount = 0
                for _,v in pairs(OptionContainer:GetChildren()) do if v:IsA("TextButton") then childCount = childCount + 1 end end
                local targetHeight = isDropped and (42 + (childCount * 30)) or 42
                TweenService:Create(DropdownFrame, TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,targetHeight)}):Play()
                TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = isDropped and CurrentTheme.Primary or CurrentTheme.TextColor}):Play()
            end)

            local DropdownAPI = {}
            function DropdownAPI:Refresh(newOptions)
                BuildOptions(newOptions)
                if isDropped then
                    local targetHeight = 42 + (#newOptions * 30)
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1,0,0,targetHeight)}):Play()
                end
            end
            return DropdownAPI
        end

        function TabSetup:CreateSlider(name, min, max, default, callback)
            local id = generateId("slider_" .. name)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1,0,0,52)
            SliderFrame.BackgroundColor3 = CurrentTheme.PanelLight
            SliderFrame.Active = true
            SliderFrame.Parent = PageScroll
            createCorner(SliderFrame,6)
            createStroke(SliderFrame, CurrentTheme.Primary, 1)
            registerThemeable(SliderFrame, {BackgroundColor3 = "PanelLight"})

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1,-50,0,24)
            Label.Position = UDim2.new(0,14,0,6)
            Label.Text = name
            Label.Font = Enum.Font.GothamSemibold
            Label.TextSize = 13
            Label.TextColor3 = CurrentTheme.TextColor
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = SliderFrame
            registerThemeable(Label, {TextColor3 = "TextColor"})

            local ValueText = Instance.new("TextLabel")
            ValueText.Size = UDim2.new(0,50,0,24)
            ValueText.Position = UDim2.new(1,-60,0,6)
            ValueText.Text = tostring(default)
            ValueText.Font = Enum.Font.GothamBold
            ValueText.TextSize = 13
            ValueText.TextColor3 = CurrentTheme.Primary
            ValueText.TextXAlignment = Enum.TextXAlignment.Right
            ValueText.BackgroundTransparency = 1
            ValueText.Parent = SliderFrame
            registerThemeable(ValueText, {TextColor3 = "Primary"})

            local Bar = Instance.new("TextButton")
            Bar.Size = UDim2.new(1,-28,0,4)
            Bar.Position = UDim2.new(0,14,0,36)
            Bar.BackgroundColor3 = CurrentTheme.Panel
            Bar.Text = ""
            Bar.Parent = SliderFrame
            createCorner(Bar,2)
            registerThemeable(Bar, {BackgroundColor3 = "Panel"})

            local Fill = Instance.new("Frame")
            local defaultPercent = (default - min) / (max - min)
            Fill.Size = UDim2.new(defaultPercent,0,1,0)
            Fill.BackgroundColor3 = CurrentTheme.Primary
            Fill.Parent = Bar
            createCorner(Fill,2)
            registerThemeable(Fill, {BackgroundColor3 = "Primary"})

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0,12,0,12)
            Knob.Position = UDim2.new(defaultPercent, -6, 0.5, -6)
            Knob.BackgroundColor3 = Color3.new(1,1,1)
            Knob.BorderSizePixel = 0
            Knob.Parent = Bar
            createCorner(Knob, 6)

            local currentValue = default
            ConfigValues[id] = currentValue
            registerConfig(id, function(val)
                currentValue = math.clamp(val, min, max)
                local percent = (currentValue - min) / (max - min)
                Fill.Size = UDim2.new(percent,0,1,0)
                Knob.Position = UDim2.new(percent, -6, 0.5, -6)
                ValueText.Text = tostring(currentValue)
                callback(currentValue)
            end)

            local draggingSlider = false
            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = true
                    playClickSound()
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = input.Position.X
                    local barPos = Bar.AbsolutePosition.X
                    local barSize = Bar.AbsoluteSize.X
                    local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
                    currentValue = math.floor(min + ((max - min) * percent))
                    ConfigValues[id] = currentValue
                    Fill.Size = UDim2.new(percent,0,1,0)
                    Knob.Position = UDim2.new(percent, -6, 0.5, -6)
                    ValueText.Text = tostring(currentValue)
                    callback(currentValue)
                end
            end)
        end

        function TabSetup:CreateButton(name, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1,0,0,40)
            Btn.BackgroundColor3 = CurrentTheme.PanelLight
            Btn.Text = name
            Btn.Font = Enum.Font.GothamBold
            Btn.TextSize = 14
            Btn.TextColor3 = CurrentTheme.TextColor
            Btn.Active = true
            Btn.Parent = PageScroll
            createCorner(Btn,6)
            createStroke(Btn, CurrentTheme.Primary, 1)
            registerThemeable(Btn, {BackgroundColor3 = "PanelLight", TextColor3 = "TextColor"})

            Btn.MouseEnter:Connect(playHoverSound)
            Btn.MouseButton1Click:Connect(function()
                playClickSound()
                TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.98,0,0,38), BackgroundColor3 = CurrentTheme.Primary}):Play()
                task.wait(0.1)
                TweenService:Create(Btn, TweenInfo.new(0.2), {Size = UDim2.new(1,0,0,40), BackgroundColor3 = CurrentTheme.PanelLight}):Play()
                callback()
            end)
        end

        function TabSetup:CreateDivider()
            local Div = Instance.new("Frame")
            Div.Size = UDim2.new(1, 0, 0, 2)
            Div.BackgroundColor3 = CurrentTheme.Primary
            Div.BackgroundTransparency = 0.5
            Div.BorderSizePixel = 0
            Div.Parent = PageScroll
            registerThemeable(Div, {BackgroundColor3 = "Primary"})
        end

        function TabSetup:CreateNotification(title, message, duration)
            duration = duration or 2
            playSound(131390520971848, 0.7) 
            
            local Notif = Instance.new("Frame")
            Notif.Size = UDim2.new(0, 250, 0, 70)
            Notif.Position = UDim2.new(1, 10, 1, -80)
            Notif.BackgroundColor3 = CurrentTheme.Panel
            Notif.Active = true
            Notif.ZIndex = 200
            Notif.Parent = HubGui
            createCorner(Notif,10)
            createStroke(Notif, CurrentTheme.Primary,2)
            createShadow(Notif, UDim2.new(1,14,1,14), -7, 0.7)
            registerThemeable(Notif, {BackgroundColor3 = "Panel"})

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Text = title
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.TextSize = 15
            TitleLabel.TextColor3 = CurrentTheme.Primary
            TitleLabel.Size = UDim2.new(1,-20,0,22)
            TitleLabel.Position = UDim2.new(0,10,0,8)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.ZIndex = 205
            TitleLabel.Parent = Notif
            registerThemeable(TitleLabel, {TextColor3 = "Primary"})

            local MsgLabel = Instance.new("TextLabel")
            MsgLabel.Text = message
            MsgLabel.Font = Enum.Font.Gotham
            MsgLabel.TextSize = 13
            MsgLabel.TextColor3 = CurrentTheme.TextColor
            MsgLabel.Size = UDim2.new(1,-20,0,30)
            MsgLabel.Position = UDim2.new(0,10,0,32)
            MsgLabel.BackgroundTransparency = 1
            MsgLabel.TextXAlignment = Enum.TextXAlignment.Left
            MsgLabel.TextWrapped = true
            MsgLabel.ZIndex = 205
            MsgLabel.Parent = Notif
            registerThemeable(MsgLabel, {TextColor3 = "TextColor"})

            TweenService:Create(Notif, TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Position = UDim2.new(1,-260,1,-80)}):Play()
            task.wait(duration)
            TweenService:Create(Notif, TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Position = UDim2.new(1,10,1,-80)}):Play()
            task.wait(0.4)
            Notif:Destroy()
        end

        return TabSetup
    end

    local MenuTab = CreateTabInternal("Menu", 9999)
    
    MenuTab:CreateDropdown("Theme", EmloxaLibrary:GetThemeNames(), "Default", function(val)
        EmloxaLibrary:SetTheme(val)
    end)

    MenuTab:CreateToggle("Background Music", function(state)
        bgMusicEnabled = state
        saveBGMusicState()
        if state then bgMusic:Play() else bgMusic:Stop() end
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
            MenuTab:CreateNotification("Error", "Could not save config.", 2)
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
                    for id, value in pairs(data) do ConfigValues[id] = value end
                    for _, entry in ipairs(ConfigCallbacks) do
                        if ConfigValues[entry.id] ~= nil then
                            entry.set(ConfigValues[entry.id])
                        end
                    end
                    MenuTab:CreateNotification("Success", "Loaded Config: " .. SelectedConfig, 2)
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

    function WindowSetup:CreateTab(tabName)
        return CreateTabInternal(tabName, #Tabs + 1)
    end

    function WindowSetup:ShowDiscordPrompt()
        local PromptFrame = Instance.new("Frame")
        PromptFrame.Size = UDim2.new(0, 350, 0, 140)
        PromptFrame.Position = UDim2.new(1, 20, 1, -160)
        PromptFrame.BackgroundColor3 = CurrentTheme.Panel
        PromptFrame.Active = true
        PromptFrame.Parent = HubGui
        createCorner(PromptFrame, 12)
        createStroke(PromptFrame, CurrentTheme.Primary, 2)
        createShadow(PromptFrame, UDim2.new(1,18,1,18), -9, 0.7)
        registerThemeable(PromptFrame, {BackgroundColor3 = "Panel"})

        local PTitle = Instance.new("TextLabel")
        PTitle.Text = "🔥 Emloxa Discord"
        PTitle.Font = Enum.Font.GothamBlack; PTitle.TextSize = 18
        PTitle.TextColor3 = CurrentTheme.Primary
        PTitle.Size = UDim2.new(1,-20,0,30); PTitle.Position = UDim2.new(0,10,0,10)
        PTitle.BackgroundTransparency = 1; PTitle.TextXAlignment = Enum.TextXAlignment.Left
        PTitle.Parent = PromptFrame
        registerThemeable(PTitle, {TextColor3 = "Primary"})

        local PDesc = Instance.new("TextLabel")
        PDesc.Text = "Join our Discord for the latest scripts and support!"
        PDesc.Font = Enum.Font.Gotham; PDesc.TextSize = 13
        PDesc.TextColor3 = CurrentTheme.TextColor
        PDesc.Size = UDim2.new(1,-20,0,50); PDesc.Position = UDim2.new(0,10,0,45)
        PDesc.BackgroundTransparency = 1; PDesc.TextXAlignment = Enum.TextXAlignment.Left
        PDesc.TextWrapped = true; PDesc.Parent = PromptFrame
        registerThemeable(PDesc, {TextColor3 = "TextColor"})

        local BtnYes = Instance.new("TextButton")
        BtnYes.Size = UDim2.new(0,150,0,34); BtnYes.Position = UDim2.new(0,15,1,-44)
        BtnYes.BackgroundColor3 = CurrentTheme.Primary; BtnYes.Text = "Copy Link"
        BtnYes.Font = Enum.Font.GothamBold; BtnYes.TextColor3 = Color3.new(1,1,1); BtnYes.TextSize = 13
        BtnYes.Parent = PromptFrame; createCorner(BtnYes,8)
        registerThemeable(BtnYes, {BackgroundColor3 = "Primary"})

        local BtnNo = Instance.new("TextButton")
        BtnNo.Size = UDim2.new(0,150,0,34); BtnNo.Position = UDim2.new(1,-165,1,-44)
        BtnNo.BackgroundColor3 = CurrentTheme.PanelLight; BtnNo.Text = "No Thanks"
        BtnNo.Font = Enum.Font.Gotham; BtnNo.TextColor3 = CurrentTheme.SubTextColor; BtnNo.TextSize = 13
        BtnNo.Parent = PromptFrame; createCorner(BtnNo,8)
        registerThemeable(BtnNo, {BackgroundColor3 = "PanelLight", TextColor3 = "SubTextColor"})

        TweenService:Create(PromptFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1,-370,1,-160)}):Play()

        local function ClosePrompt()
            TweenService:Create(PromptFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1,20,1,-160)}):Play()
            task.wait(0.5); PromptFrame:Destroy()
        end

        BtnYes.MouseEnter:Connect(playHoverSound)
        BtnNo.MouseEnter:Connect(playHoverSound)
        BtnYes.MouseButton1Click:Connect(function()
            playClickSound()
            if setclipboard then setclipboard("https://discord.gg/XjfW7N84jT") end
            BtnYes.Text = "Copied!"; BtnYes.BackgroundColor3 = Color3.fromRGB(40,200,100)
            TweenService:Create(BtnYes, TweenInfo.new(0.15), {Size = UDim2.new(0,155,0,36)}):Play()
            task.wait(1); ClosePrompt()
        end)
        BtnNo.MouseButton1Click:Connect(function()
            playClickSound()
            ClosePrompt()
        end)
    end

    return WindowSetup
end

return EmloxaLibrary
