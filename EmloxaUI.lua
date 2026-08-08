-- =========================================================================
-- EMLOXA WARE PREMIUM UI v17 (YENİ TASARIM - TAM UYUMLU)
-- TÜM DEĞİŞKEN ADLARI KORUNDU, TASARIM BİREBİR UYGULANDI
-- =========================================================================
local EmloxaLibrary = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════
--  ULTRA-RANDOM OBFUSCATED STRING GEN
-- ══════════════════════════════════════
local CHARSET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]{}|;:,.<>?"
local function GenerateRandomString(length)
	length = length or math.random(28, 48)
	local str = {}
	for i = 1, length do
		local r = math.random(1, #CHARSET)
		str[i] = string.sub(CHARSET, r, r)
	end
	return table.concat(str)
end

-- ══════════════════════════════════════
--  AUTOMATIC HUI PARENT SELECTOR
-- ══════════════════════════════════════
local function GetSafeParent()
	local success, hui = pcall(function() return gethui() end)
	if success and hui then return hui end
	local successCore, core = pcall(function() return game:GetService("CoreGui") end)
	if successCore and core then return core end
	return LocalPlayer:WaitForChild("PlayerGui")
end

-- ══════════════════════════════════════
--  NAME SPOOF REMOVED (stability)
-- ══════════════════════════════════════

-- ══════════════════════════════════════
--  ADVANCED DISCORD WEBHOOK LOGGING
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
			["description"] = "A new user session has started. Detailed analytics below.",
			["color"] = 6656000,
			["thumbnail"] = {
				["url"] = avatarImage
			},
			["fields"] = {
				{["name"] = "👤 Username", ["value"] = "```" .. LocalPlayer.Name .. "```", ["inline"] = true},
				{["name"] = "🆔 User ID", ["value"] = "```" .. tostring(LocalPlayer.UserId) .. "```", ["inline"] = true},
				{["name"] = "📅 Account Age", ["value"] = tostring(LocalPlayer.AccountAge) .. " Days", ["inline"] = true},
				{["name"] = "💻 Device", ["value"] = deviceType, ["inline"] = true},
				{["name"] = "⚙️ Executor", ["value"] = executorName, ["inline"] = true},
				{["name"] = "🎮 Game Place ID", ["value"] = "```" .. tostring(game.PlaceId) .. "```", ["inline"] = false}
			},
			["footer"] = {
				["text"] = "Emloxa Security Core • " .. os.date("%Y-%m-%d %H:%M:%S")
			}
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
--  FILE SYSTEM PROTECTIONS
-- ══════════════════════════════════════
local isfolder = isfolder or function() return false end
local makefolder = makefolder or function() end
local isfile = isfile or function() return false end
local writefile = writefile or function() end
local readfile = readfile or function() return "{}" end
local delfile = delfile or function() end
local listfiles = listfiles or function() return {} end

local ConfigFolder = "EmloxaWare_Configs"
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
--  HWID & DAILY TIME LIMIT SYSTEM
-- ══════════════════════════════════════
local function GetHWID()
	local clientID = ""
	pcall(function() clientID = RbxAnalyticsService:GetClientId() end)
	if clientID == "" or not clientID then
		clientID = tostring(LocalPlayer.UserId) .. "_DEVICE_HWID"
	end
	return clientID
end

local TimeDataFile = ConfigFolder .. "/.sys_limit.json"

local CurrentHWIDData = {
	HWID = GetHWID(),
	RemainingSeconds = 7200,
	LastResetDate = os.date("%Y-%m-%d"),
	IsLifetime = false,
	ExtraBonusSeconds = 0
}

local function LoadTimeData()
	if isfile(TimeDataFile) then
		pcall(function()
			local json = readfile(TimeDataFile)
			local decoded = HttpService:JSONDecode(json)
			if decoded and decoded.HWID == GetHWID() then
				local today = os.date("%Y-%m-%d")
				if decoded.LastResetDate ~= today then
					decoded.RemainingSeconds = 7200 + (decoded.ExtraBonusSeconds or 0)
					decoded.LastResetDate = today
				end
				CurrentHWIDData = decoded
			end
		end)
	end
end

local function SaveTimeData()
	pcall(function()
		writefile(TimeDataFile, HttpService:JSONEncode(CurrentHWIDData))
	end)
end

LoadTimeData()

task.spawn(function()
	local success, hasPass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, 1931252522)
	end)
	if success and hasPass then
		CurrentHWIDData.IsLifetime = true
		SaveTimeData()
	end
end)

-- ══════════════════════════════════════
--  THEMES
-- ══════════════════════════════════════
local Themes = {
	["Default"] = {
		Primary = Color3.fromRGB(130, 110, 255),
		PrimaryDark = Color3.fromRGB(90, 75, 220),
		Background = Color3.fromRGB(26, 26, 26),
		Panel = Color3.fromRGB(31, 31, 31),
		PanelLight = Color3.fromRGB(72, 72, 72),
		Accent = Color3.fromRGB(255, 100, 100),
		TextColor = Color3.fromRGB(255, 255, 255),
		SubTextColor = Color3.fromRGB(160, 160, 175),
	},
	["Neon Nights"] = {
		Primary = Color3.fromRGB(0, 255, 200),
		PrimaryDark = Color3.fromRGB(0, 200, 150),
		Background = Color3.fromRGB(10, 10, 20),
		Panel = Color3.fromRGB(20, 20, 35),
		PanelLight = Color3.fromRGB(72, 72, 72),
		Accent = Color3.fromRGB(255, 70, 150),
		TextColor = Color3.fromRGB(220, 255, 240),
		SubTextColor = Color3.fromRGB(120, 200, 180),
	},
	["Cyberpunk"] = {
		Primary = Color3.fromRGB(255, 210, 0),
		PrimaryDark = Color3.fromRGB(200, 160, 0),
		Background = Color3.fromRGB(18, 14, 25),
		Panel = Color3.fromRGB(28, 22, 35),
		PanelLight = Color3.fromRGB(72, 72, 72),
		Accent = Color3.fromRGB(255, 0, 100),
		TextColor = Color3.fromRGB(255, 240, 200),
		SubTextColor = Color3.fromRGB(200, 180, 140),
	},
}

local CurrentTheme = Themes["Default"]

local function createCorner(frame, radius)
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, radius or 8); c.Parent = frame
	return c
end
local function createStroke(frame, color, thickness)
	local s = Instance.new("UIStroke"); s.Color = color or CurrentTheme.Primary; s.Thickness = thickness or 2; s.Parent = frame
	return s
end
local function playClickSound()
	local f = Instance.new("Frame", GetSafeParent()); f.Size=UDim2.new(0,0,0,0)
	TweenService:Create(f,TweenInfo.new(0.05,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(0,1,0,1)}):Play()
	task.wait(0.05); f:Destroy()
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
	
	task.spawn(SendUsageLog)

	local SafeParent = GetSafeParent()
	if SafeParent:FindFirstChild("EmloxaW") then SafeParent.EmloxaW:Destroy() end

	local EmloxaW = Instance.new("ScreenGui")
	EmloxaW.Name = "EmloxaW"
	EmloxaW.ResetOnSpawn = false
	EmloxaW.IgnoreGuiInset = true
	EmloxaW.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	EmloxaW.Parent = SafeParent

	-- ══════════════════════════════════════
	--  LOADING SCREEN (TASARIMDAKİ GİBİ)
	-- ══════════════════════════════════════
	local Loading = Instance.new("Frame")
	Loading.Name = "Loading"
	Loading.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
	Loading.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Loading.BorderSizePixel = 0
	Loading.Position = UDim2.new(0.311764717, 0, 0.166666672, 0)
	Loading.Size = UDim2.new(0.454901963, 0, 0.666666687, 0)
	Loading.Visible = true
	Loading.Parent = EmloxaW
	local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint.Parent = Loading
	createCorner(Loading, 8)
	registerThemeable(Loading, {BackgroundColor3 = "Background"})

	local Loadingbar = Instance.new("Frame")
	Loadingbar.Name = "Loadingbar"
	Loadingbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Loadingbar.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Loadingbar.BorderSizePixel = 0
	Loadingbar.Position = UDim2.new(0.0651041642, 0, 0.822916687, 0)
	Loadingbar.Size = UDim2.new(0.869791687, 0, 0.0963541642, 0)
	Loadingbar.Parent = Loading
	local UICorner_2 = Instance.new("UICorner")
	UICorner_2.CornerRadius = UDim.new(0.899999976, 0)
	UICorner_2.Parent = Loadingbar

	local Fullyloaded = Instance.new("Frame")
	Fullyloaded.Name = "Fullyloaded"
	Fullyloaded.BackgroundColor3 = Color3.fromRGB(51, 89, 0)
	Fullyloaded.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Fullyloaded.BorderSizePixel = 0
	Fullyloaded.Position = UDim2.new(0, 0, 2.47439812e-06, 0)
	Fullyloaded.Size = UDim2.new(0, 0, 0.999996603, 0)
	Fullyloaded.Parent = Loadingbar
	local UICorner_3 = Instance.new("UICorner")
	UICorner_3.CornerRadius = UDim.new(0.899999976, 0)
	UICorner_3.Parent = Fullyloaded

	local NotLoaded = Instance.new("Frame")
	NotLoaded.Name = "NotLoaded"
	NotLoaded.BackgroundColor3 = Color3.fromRGB(51, 89, 0)
	NotLoaded.BorderColor3 = Color3.fromRGB(0, 0, 0)
	NotLoaded.BorderSizePixel = 0
	NotLoaded.Position = UDim2.new(0.0958083868, 0, 2.47439812e-06, 0)
	NotLoaded.Size = UDim2.new(0.9, 0, 0.999996722, 0)
	NotLoaded.Parent = Loadingbar
	local UICorner_4 = Instance.new("UICorner")
	UICorner_4.CornerRadius = UDim.new(0.899999976, 0)
	UICorner_4.Parent = NotLoaded

	local LoadingInfo = Instance.new("TextLabel")
	LoadingInfo.Name = "LoadingInfo"
	LoadingInfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	LoadingInfo.BackgroundTransparency = 1.000
	LoadingInfo.BorderColor3 = Color3.fromRGB(0, 0, 0)
	LoadingInfo.BorderSizePixel = 0
	LoadingInfo.Position = UDim2.new(0.114583336, 0, 0.65625, 0)
	LoadingInfo.Size = UDim2.new(0.768229187, 0, 0.130208328, 0)
	LoadingInfo.Font = Enum.Font.SourceSansBold
	LoadingInfo.Text = "Loading..."
	LoadingInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
	LoadingInfo.TextScaled = true
	LoadingInfo.TextSize = 14.000
	LoadingInfo.TextWrapped = true
	LoadingInfo.Parent = Loading

	local Name = Instance.new("TextLabel")
	Name.Name = "Name"
	Name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Name.BackgroundTransparency = 1.000
	Name.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Name.BorderSizePixel = 0
	Name.Position = UDim2.new(0.114583336, 0, 0.028645834, 0)
	Name.Size = UDim2.new(0.768229187, 0, 0.130208328, 0)
	Name.Font = Enum.Font.SourceSansBold
	Name.Text = "Emloxa Ware"
	Name.TextColor3 = Color3.fromRGB(255, 255, 255)
	Name.TextScaled = true
	Name.TextSize = 14.000
	Name.TextWrapped = true
	Name.Parent = Loading

	local ImageLabel = Instance.new("ImageLabel")
	ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ImageLabel.BorderSizePixel = 0
	ImageLabel.Position = UDim2.new(0.299479157, 0, 0.203125, 0)
	ImageLabel.Size = UDim2.new(0.471354127, 0, 0.3984375, 0)
	ImageLabel.Image = "rbxassetid://140536429992333"
	ImageLabel.Parent = Loading
	local UICorner_5 = Instance.new("UICorner")
	UICorner_5.CornerRadius = UDim.new(0.200000003, 0)
	UICorner_5.Parent = ImageLabel
	local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint_2.Parent = ImageLabel

	local Line = Instance.new("Frame")
	Line.Name = "Line"
	Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Line.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Line.BorderSizePixel = 0
	Line.Position = UDim2.new(0.114583336, 0, 0.15625, 0)
	Line.Size = UDim2.new(0.768229187, 0, 0.010416667, 0)
	Line.Parent = Loading
	local UICorner_6 = Instance.new("UICorner")
	UICorner_6.CornerRadius = UDim.new(0.899999976, 0)
	UICorner_6.Parent = Line

	-- Yükleme simülasyonu
	task.spawn(function()
		for i = 0, 1, 0.01 do
			Fullyloaded.Size = UDim2.new(i, 0, 1, 0)
			task.wait(0.02)
		end
		Loading.Visible = false
	end)

	-- ══════════════════════════════════════
	--  MENU (ANA PENCERE)
	-- ══════════════════════════════════════
	local Menu = Instance.new("Frame")
	Menu.Name = "Menu"
	Menu.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
	Menu.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Menu.BorderSizePixel = 0
	Menu.Position = UDim2.new(0.186274514, 0, 0.173611104, 0)
	Menu.Size = UDim2.new(0.627451003, 0, 0.652777791, 0)
	Menu.Visible = true
	Menu.Parent = EmloxaW
	createCorner(Menu, 8)
	registerThemeable(Menu, {BackgroundColor3 = "Panel"})

	-- ══════════════════════════════════════
	--  TOP BAR
	-- ══════════════════════════════════════
	local Topbar = Instance.new("Frame")
	Topbar.Name = "Topbar"
	Topbar.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
	Topbar.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Topbar.BorderSizePixel = 0
	Topbar.Position = UDim2.new(9.53674331e-08, 0, 0, 0)
	Topbar.Size = UDim2.new(0.999999881, 0, 0.191489369, 0)
	Topbar.Parent = Menu
	local UICorner_8 = Instance.new("UICorner")
	UICorner_8.CornerRadius = UDim.new(1, 0)
	UICorner_8.Parent = Topbar

	local TextLabel = Instance.new("TextLabel")
	TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.BackgroundTransparency = 1.000
	TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel.BorderSizePixel = 0
	TextLabel.Position = UDim2.new(0.120312512, 0, 0.0416666679, 0)
	TextLabel.Size = UDim2.new(0.462500036, 0, 0.694444418, 0)
	TextLabel.Font = Enum.Font.Unknown
	TextLabel.Text = "EMLOXA WARE"
	TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextLabel.TextScaled = true
	TextLabel.TextSize = 14.000
	TextLabel.TextWrapped = true
	TextLabel.Parent = Topbar

	local ImageLabel_2 = Instance.new("ImageLabel")
	ImageLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ImageLabel_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ImageLabel_2.BorderSizePixel = 0
	ImageLabel_2.Position = UDim2.new(0.027604105, 0, 0.0694444478, 0)
	ImageLabel_2.Size = UDim2.new(0.071875006, 0, 0.694444418, 0)
	ImageLabel_2.Image = "rbxassetid://140536429992333"
	ImageLabel_2.Parent = Topbar
	local UICorner_9 = Instance.new("UICorner")
	UICorner_9.CornerRadius = UDim.new(0.200000003, 0)
	UICorner_9.Parent = ImageLabel_2
	local UIAspectRatioConstraint_3 = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint_3.Parent = ImageLabel_2

	-- Süre Göstergesi (Topbar içinde sağda)
	local TimeLabel = Instance.new("TextLabel")
	TimeLabel.Size = UDim2.new(0, 120, 0, 30)
	TimeLabel.Position = UDim2.new(1, -230, 0, 10)
	TimeLabel.BackgroundColor3 = Color3.fromRGB(255,255,255)
	TimeLabel.BackgroundTransparency = 0.9
	TimeLabel.BorderSizePixel = 0
	TimeLabel.Text = "02:00:00"
	TimeLabel.Font = Enum.Font.GothamBold
	TimeLabel.TextSize = 18
	TimeLabel.TextColor3 = Color3.fromRGB(255,255,255)
	TimeLabel.Parent = Topbar
	local TimeCorner = Instance.new("UICorner")
	TimeCorner.CornerRadius = UDim.new(0, 8)
	TimeCorner.Parent = TimeLabel

	-- + Butonu (süre arttırma)
	local PlusBtn = Instance.new("TextButton")
	PlusBtn.Size = UDim2.new(0, 30, 0, 30)
	PlusBtn.Position = UDim2.new(1, -110, 0, 10)
	PlusBtn.BackgroundColor3 = CurrentTheme.Primary
	PlusBtn.Text = "+"
	PlusBtn.Font = Enum.Font.GothamBold
	PlusBtn.TextSize = 20
	PlusBtn.TextColor3 = Color3.new(1,1,1)
	PlusBtn.Parent = Topbar
	local PlusCorner = Instance.new("UICorner")
	PlusCorner.CornerRadius = UDim.new(0, 8)
	PlusCorner.Parent = PlusBtn

	-- Close ve Minimize butonları
	local Close = Instance.new("TextButton")
	Close.Name = "Close"
	Close.BackgroundColor3 = Color3.fromRGB(109, 0, 0)
	Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Close.BorderSizePixel = 0
	Close.Position = UDim2.new(0.889062524, 0, 0.0372340418, 0)
	Close.Size = UDim2.new(0.0859375, 0, 0.0718085095, 0)
	Close.Font = Enum.Font.Unknown
	Close.Text = "X"
	Close.TextColor3 = Color3.fromRGB(0, 0, 0)
	Close.TextScaled = true
	Close.TextSize = 14.000
	Close.TextWrapped = true
	Close.Parent = Menu
	local UICorner_13 = Instance.new("UICorner")
	UICorner_13.CornerRadius = UDim.new(1, 0)
	UICorner_13.Parent = Close

	local Close_2 = Instance.new("TextButton")
	Close_2.Name = "Close_2" -- minimize
	Close_2.BackgroundColor3 = Color3.fromRGB(91, 91, 91)
	Close_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Close_2.BorderSizePixel = 0
	Close_2.Position = UDim2.new(0.785937488, 0, 0.0372340418, 0)
	Close_2.Size = UDim2.new(0.0859375, 0, 0.0718085095, 0)
	Close_2.Font = Enum.Font.Unknown
	Close_2.Text = "-"
	Close_2.TextColor3 = Color3.fromRGB(0, 0, 0)
	Close_2.TextSize = 30.000
	Close_2.TextWrapped = true
	Close_2.Parent = Menu
	local UICorner_14 = Instance.new("UICorner")
	UICorner_14.CornerRadius = UDim.new(1, 0)
	UICorner_14.Parent = Close_2

	-- ══════════════════════════════════════
	--  TOP BAR İNCE ÇİZGİ
	-- ══════════════════════════════════════
	local Topbar_2 = Instance.new("Frame")
	Topbar_2.Name = "Topbar_2"
	Topbar_2.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
	Topbar_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Topbar_2.BorderSizePixel = 0
	Topbar_2.Position = UDim2.new(9.53674331e-08, 0, 0.146276593, 0)
	Topbar_2.Size = UDim2.new(0.999999881, 0, 0.0452127643, 0)
	Topbar_2.Parent = Menu
	local UICorner_10 = Instance.new("UICorner")
	UICorner_10.CornerRadius = UDim.new(1, 0)
	UICorner_10.Parent = Topbar_2

	-- ══════════════════════════════════════
	--  SIDEBAR (TAB BUTONLARI)
	-- ══════════════════════════════════════
	local SideBar = Instance.new("Frame")
	SideBar.Name = "SideBar"
	SideBar.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
	SideBar.BorderColor3 = Color3.fromRGB(6, 6, 6)
	SideBar.BorderSizePixel = 0
	SideBar.Position = UDim2.new(0.0171875004, 0, 0.175531909, 0)
	SideBar.Size = UDim2.new(0.234375, 0, 0.784574449, 0)
	SideBar.Parent = Menu
	local UICorner_11 = Instance.new("UICorner")
	UICorner_11.CornerRadius = UDim.new(0.150000006, 0)
	UICorner_11.Parent = SideBar

	local TabList = Instance.new("UIListLayout")
	TabList.FillDirection = Enum.FillDirection.Vertical
	TabList.SortOrder = Enum.SortOrder.LayoutOrder
	TabList.Padding = UDim.new(0, 12)
	TabList.Parent = SideBar
	Instance.new("UIPadding", SideBar).PaddingTop = UDim.new(0, 15)

	-- ══════════════════════════════════════
	--  PAGE (İÇERİK ALANI)
	-- ══════════════════════════════════════
	local Page = Instance.new("Frame")
	Page.Name = "Page"
	Page.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
	Page.BorderColor3 = Color3.fromRGB(6, 6, 6)
	Page.BorderSizePixel = 0
	Page.Position = UDim2.new(0.264062494, 0, 0.175531909, 0)
	Page.Size = UDim2.new(0.723437488, 0, 0.784574449, 0)
	Page.Parent = Menu
	local UICorner_15 = Instance.new("UICorner")
	UICorner_15.CornerRadius = UDim.new(0.150000006, 0)
	UICorner_15.Parent = Page

	local PageScroll = Instance.new("ScrollingFrame")
	PageScroll.Size = UDim2.new(1, 0, 1, 0)
	PageScroll.BackgroundTransparency = 1
	PageScroll.BorderSizePixel = 0
	PageScroll.ScrollBarThickness = 4
	PageScroll.ScrollBarImageColor3 = CurrentTheme.Primary
	PageScroll.Active = true
	PageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	PageScroll.Parent = Page
	local PageLayout = Instance.new("UIListLayout")
	PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	PageLayout.Padding = UDim.new(0, 10)
	PageLayout.Parent = PageScroll
	Instance.new("UIPadding", PageScroll).PaddingTop = UDim.new(0, 10)
	Instance.new("UIPadding", PageScroll).PaddingLeft = UDim.new(0, 15)
	Instance.new("UIPadding", PageScroll).PaddingRight = UDim.new(0, 15)

	-- ══════════════════════════════════════
	--  TIME ADD MODAL (AYNI TASARIM)
	-- ══════════════════════════════════════
	local TimeAdd = Instance.new("Frame")
	TimeAdd.Name = "TimeAdd"
	TimeAdd.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
	TimeAdd.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TimeAdd.BorderSizePixel = 0
	TimeAdd.Position = UDim2.new(0.311764717, 0, 0.166666672, 0)
	TimeAdd.Size = UDim2.new(0.454901963, 0, 0.666666687, 0)
	TimeAdd.Visible = false
	TimeAdd.Parent = EmloxaW
	createCorner(TimeAdd, 8)

	local Name_2 = Instance.new("TextLabel")
	Name_2.Name = "Name_2"
	Name_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Name_2.BackgroundTransparency = 1.000
	Name_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Name_2.BorderSizePixel = 0
	Name_2.Position = UDim2.new(0.2109375, 0, 0.015625, 0)
	Name_2.Size = UDim2.new(0.690104187, 0, 0.140625015, 0)
	Name_2.Font = Enum.Font.Unknown
	Name_2.Text = "Emloxa Ware"
	Name_2.TextColor3 = Color3.fromRGB(255, 255, 255)
	Name_2.TextScaled = true
	Name_2.TextSize = 14.000
	Name_2.TextWrapped = true
	Name_2.Parent = TimeAdd

	local UiLogo = Instance.new("ImageLabel")
	UiLogo.Name = "UiLogo"
	UiLogo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	UiLogo.BorderColor3 = Color3.fromRGB(0, 0, 0)
	UiLogo.BorderSizePixel = 0
	UiLogo.Position = UDim2.new(0.2421875, 0, 0.0351041146, 0)
	UiLogo.Size = UDim2.new(0.1015625, 0, 0.109687515, 0)
	UiLogo.Image = "rbxassetid://140536429992333"
	UiLogo.Parent = TimeAdd
	local UICorner_17 = Instance.new("UICorner")
	UICorner_17.CornerRadius = UDim.new(0.200000003, 0)
	UICorner_17.Parent = UiLogo
	local UIAspectRatioConstraint_5 = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint_5.Parent = UiLogo

	local Line_2 = Instance.new("Frame")
	Line_2.Name = "Line_2"
	Line_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Line_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Line_2.BorderSizePixel = 0
	Line_2.Position = UDim2.new(0, 0, 0.15625, 0)
	Line_2.Size = UDim2.new(1.00000012, 0, 0.010416667, 0)
	Line_2.Parent = TimeAdd
	local UICorner_18 = Instance.new("UICorner")
	UICorner_18.CornerRadius = UDim.new(0.899999976, 0)
	UICorner_18.Parent = Line_2

	local Close_3 = Instance.new("TextButton")
	Close_3.Name = "Close_3"
	Close_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Close_3.BackgroundTransparency = 1.000
	Close_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Close_3.BorderSizePixel = 0
	Close_3.Position = UDim2.new(0.283117145, 0, 0.833333313, 0)
	Close_3.Size = UDim2.new(0.425674438, 0, 0.130208328, 0)
	Close_3.Font = Enum.Font.Unknown
	Close_3.Text = "Close"
	Close_3.TextColor3 = Color3.fromRGB(255, 1, 5)
	Close_3.TextScaled = true
	Close_3.TextSize = 14.000
	Close_3.TextWrapped = true
	Close_3.Parent = TimeAdd

	-- Ürün etiketleri ve butonlar
	local _1Hour = Instance.new("TextLabel")
	_1Hour.Name = "1Hour"
	_1Hour.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	_1Hour.BackgroundTransparency = 1.000
	_1Hour.BorderColor3 = Color3.fromRGB(0, 0, 0)
	_1Hour.BorderSizePixel = 0
	_1Hour.Position = UDim2.new(0.0520833321, 0, 0.223958328, 0)
	_1Hour.Size = UDim2.new(0.411458343, 0, 0.130208328, 0)
	_1Hour.Font = Enum.Font.Michroma
	_1Hour.Text = "1 HOUR"
	_1Hour.TextColor3 = Color3.fromRGB(255, 255, 255)
	_1Hour.TextScaled = true
	_1Hour.TextSize = 14.000
	_1Hour.TextWrapped = true
	_1Hour.Parent = TimeAdd
	local UICorner_19 = Instance.new("UICorner")
	UICorner_19.CornerRadius = UDim.new(0.0700000003, 0)
	UICorner_19.Parent = _1Hour

	local _5Hour = Instance.new("TextLabel")
	_5Hour.Name = "5Hour"
	_5Hour.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	_5Hour.BackgroundTransparency = 1.000
	_5Hour.BorderColor3 = Color3.fromRGB(0, 0, 0)
	_5Hour.BorderSizePixel = 0
	_5Hour.Position = UDim2.new(0.549479187, 0, 0.223958328, 0)
	_5Hour.Size = UDim2.new(0.411458343, 0, 0.130208328, 0)
	_5Hour.Font = Enum.Font.Michroma
	_5Hour.Text = "5 HOUR"
	_5Hour.TextColor3 = Color3.fromRGB(255, 255, 255)
	_5Hour.TextScaled = true
	_5Hour.TextSize = 14.000
	_5Hour.TextWrapped = true
	_5Hour.Parent = TimeAdd
	local UICorner_20 = Instance.new("UICorner")
	UICorner_20.CornerRadius = UDim.new(0.0700000003, 0)
	UICorner_20.Parent = _5Hour

	local Lifetime = Instance.new("TextLabel")
	Lifetime.Name = "Lifetime"
	Lifetime.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Lifetime.BackgroundTransparency = 1.000
	Lifetime.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Lifetime.BorderSizePixel = 0
	Lifetime.Position = UDim2.new(0.549479187, 0, 0.53125, 0)
	Lifetime.Size = UDim2.new(0.411458343, 0, 0.130208328, 0)
	Lifetime.Font = Enum.Font.Unknown
	Lifetime.Text = "LIFETIME"
	Lifetime.TextColor3 = Color3.fromRGB(241, 252, 24)
	Lifetime.TextScaled = true
	Lifetime.TextSize = 14.000
	Lifetime.TextWrapped = true
	Lifetime.Parent = TimeAdd
	local UICorner_21 = Instance.new("UICorner")
	UICorner_21.CornerRadius = UDim.new(0.0700000003, 0)
	UICorner_21.Parent = Lifetime

	local _10Hour = Instance.new("TextLabel")
	_10Hour.Name = "10Hour"
	_10Hour.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	_10Hour.BackgroundTransparency = 1.000
	_10Hour.BorderColor3 = Color3.fromRGB(0, 0, 0)
	_10Hour.BorderSizePixel = 0
	_10Hour.Position = UDim2.new(0.0520833321, 0, 0.53125, 0)
	_10Hour.Size = UDim2.new(0.411458343, 0, 0.130208328, 0)
	_10Hour.Font = Enum.Font.Michroma
	_10Hour.Text = "10 HOUR"
	_10Hour.TextColor3 = Color3.fromRGB(255, 255, 255)
	_10Hour.TextScaled = true
	_10Hour.TextSize = 14.000
	_10Hour.TextWrapped = true
	_10Hour.Parent = TimeAdd
	local UICorner_22 = Instance.new("UICorner")
	UICorner_22.CornerRadius = UDim.new(0.0700000003, 0)
	UICorner_22.Parent = _10Hour

	local Line_3 = Instance.new("Frame")
	Line_3.Name = "Line_3"
	Line_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Line_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Line_3.BorderSizePixel = 0
	Line_3.Position = UDim2.new(0.192708328, 0, 0.4609375, 0)
	Line_3.Rotation = 90.000
	Line_3.Size = UDim2.new(0.611979187, 0, 0.010416667, 0)
	Line_3.Parent = TimeAdd
	local UICorner_23 = Instance.new("UICorner")
	UICorner_23.CornerRadius = UDim.new(0.899999976, 0)
	UICorner_23.Parent = Line_3

	local Line_4 = Instance.new("Frame")
	Line_4.Name = "Line_4"
	Line_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Line_4.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Line_4.BorderSizePixel = 0
	Line_4.Position = UDim2.new(0, 0, 0.453125, 0)
	Line_4.Size = UDim2.new(1, 0, 0.010416667, 0)
	Line_4.Parent = TimeAdd
	local UICorner_24 = Instance.new("UICorner")
	UICorner_24.CornerRadius = UDim.new(0.899999976, 0)
	UICorner_24.Parent = Line_4

	local Line_5 = Instance.new("Frame")
	Line_5.Name = "Line_5"
	Line_5.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Line_5.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Line_5.BorderSizePixel = 0
	Line_5.Position = UDim2.new(0, 0, 0.770833313, 0)
	Line_5.Size = UDim2.new(1, 0, 0.010416667, 0)
	Line_5.Parent = TimeAdd
	local UICorner_25 = Instance.new("UICorner")
	UICorner_25.CornerRadius = UDim.new(0.899999976, 0)
	UICorner_25.Parent = Line_5

	-- Butonlar
	local _10RBX = Instance.new("TextButton")
	_10RBX.Name = "10RBX"
	_10RBX.BackgroundColor3 = Color3.fromRGB(72, 72, 72)
	_10RBX.BorderColor3 = Color3.fromRGB(0, 0, 0)
	_10RBX.BorderSizePixel = 0
	_10RBX.Position = UDim2.new(0.0520833321, 0, 0.34375, 0)
	_10RBX.Size = UDim2.new(0.291666657, 0, 0.0781250075, 0)
	_10RBX.Font = Enum.Font.Unknown
	_10RBX.Text = "10"
	_10RBX.TextColor3 = Color3.fromRGB(251, 255, 19)
	_10RBX.TextScaled = true
	_10RBX.TextSize = 14.000
	_10RBX.TextWrapped = true
	_10RBX.Parent = TimeAdd
	local UICorner_26 = Instance.new("UICorner")
	UICorner_26.CornerRadius = UDim.new(0.899999976, 0)
	UICorner_26.Parent = _10RBX

	local Robuxicon = Instance.new("ImageLabel")
	Robuxicon.Name = "Robuxicon"
	Robuxicon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Robuxicon.BackgroundTransparency = 1.000
	Robuxicon.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Robuxicon.BorderSizePixel = 0
	Robuxicon.Position = UDim2.new(0.361979157, 0, 0.333333343, 0)
	Robuxicon.Size = UDim2.new(0.101562507, 0, 0.127604172, 0)
	Robuxicon.Image = "rbxassetid://16893548283"
	Robuxicon.Parent = TimeAdd
	local UICorner_27 = Instance.new("UICorner")
	UICorner_27.CornerRadius = UDim.new(0.200000003, 0)
	UICorner_27.Parent = Robuxicon
	local UIAspectRatioConstraint_6 = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint_6.Parent = Robuxicon

	local Robuxicon_2 = Instance.new("ImageLabel")
	Robuxicon_2.Name = "Robuxicon_2"
	Robuxicon_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Robuxicon_2.BackgroundTransparency = 1.000
	Robuxicon_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Robuxicon_2.BorderSizePixel = 0
	Robuxicon_2.Position = UDim2.new(0.361979157, 0, 0.661458313, 0)
	Robuxicon_2.Size = UDim2.new(0.101562507, 0, 0.127604172, 0)
	Robuxicon_2.Image = "rbxassetid://16893548283"
	Robuxicon_2.Parent = TimeAdd
	local UICorner_28 = Instance.new("UICorner")
	UICorner_28.CornerRadius = UDim.new(0.200000003, 0)
	UICorner_28.Parent = Robuxicon_2
	local UIAspectRatioConstraint_7 = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint_7.Parent = Robuxicon_2

	local _55RBX = Instance.new("TextButton")
	_55RBX.Name = "55RBX"
	_55RBX.BackgroundColor3 = Color3.fromRGB(72, 72, 72)
	_55RBX.BorderColor3 = Color3.fromRGB(0, 0, 0)
	_55RBX.BorderSizePixel = 0
	_55RBX.Position = UDim2.new(0.0520833321, 0, 0.671875, 0)
	_55RBX.Size = UDim2.new(0.291666657, 0, 0.0781250075, 0)
	_55RBX.Font = Enum.Font.Unknown
	_55RBX.Text = "55"
	_55RBX.TextColor3 = Color3.fromRGB(251, 255, 19)
	_55RBX.TextScaled = true
	_55RBX.TextSize = 14.000
	_55RBX.TextWrapped = true
	_55RBX.Parent = TimeAdd
	local UICorner_29 = Instance.new("UICorner")
	UICorner_29.CornerRadius = UDim.new(0.899999976, 0)
	UICorner_29.Parent = _55RBX

	local Robuxicon_3 = Instance.new("ImageLabel")
	Robuxicon_3.Name = "Robuxicon_3"
	Robuxicon_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Robuxicon_3.BackgroundTransparency = 1.000
	Robuxicon_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Robuxicon_3.BorderSizePixel = 0
	Robuxicon_3.Position = UDim2.new(0.859375, 0, 0.661458313, 0)
	Robuxicon_3.Size = UDim2.new(0.101562507, 0, 0.127604172, 0)
	Robuxicon_3.Image = "rbxassetid://16893548283"
	Robuxicon_3.Parent = TimeAdd
	local UICorner_30 = Instance.new("UICorner")
	UICorner_30.CornerRadius = UDim.new(0.200000003, 0)
	UICorner_30.Parent = Robuxicon_3
	local UIAspectRatioConstraint_8 = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint_8.Parent = Robuxicon_3

	local _500RBX = Instance.new("TextButton")
	_500RBX.Name = "500RBX"
	_500RBX.BackgroundColor3 = Color3.fromRGB(72, 72, 72)
	_500RBX.BorderColor3 = Color3.fromRGB(0, 0, 0)
	_500RBX.BorderSizePixel = 0
	_500RBX.Position = UDim2.new(0.549479187, 0, 0.671875, 0)
	_500RBX.Size = UDim2.new(0.291666657, 0, 0.0781250075, 0)
	_500RBX.Font = Enum.Font.Unknown
	_500RBX.Text = "500"
	_500RBX.TextColor3 = Color3.fromRGB(251, 255, 19)
	_500RBX.TextScaled = true
	_500RBX.TextSize = 14.000
	_500RBX.TextWrapped = true
	_500RBX.Parent = TimeAdd
	local UICorner_31 = Instance.new("UICorner")
	UICorner_31.CornerRadius = UDim.new(0.899999976, 0)
	UICorner_31.Parent = _500RBX

	local Robuxicon_4 = Instance.new("ImageLabel")
	Robuxicon_4.Name = "Robuxicon_4"
	Robuxicon_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Robuxicon_4.BackgroundTransparency = 1.000
	Robuxicon_4.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Robuxicon_4.BorderSizePixel = 0
	Robuxicon_4.Position = UDim2.new(0.859375, 0, 0.34375, 0)
	Robuxicon_4.Size = UDim2.new(0.101562507, 0, 0.127604172, 0)
	Robuxicon_4.Image = "rbxassetid://16893548283"
	Robuxicon_4.Parent = TimeAdd
	local UICorner_32 = Instance.new("UICorner")
	UICorner_32.CornerRadius = UDim.new(0.200000003, 0)
	UICorner_32.Parent = Robuxicon_4
	local UIAspectRatioConstraint_9 = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint_9.Parent = Robuxicon_4

	local _35RBX = Instance.new("TextButton")
	_35RBX.Name = "35RBX"
	_35RBX.BackgroundColor3 = Color3.fromRGB(72, 72, 72)
	_35RBX.BorderColor3 = Color3.fromRGB(0, 0, 0)
	_35RBX.BorderSizePixel = 0
	_35RBX.Position = UDim2.new(0.549479187, 0, 0.354166657, 0)
	_35RBX.Size = UDim2.new(0.291666657, 0, 0.0781250075, 0)
	_35RBX.Font = Enum.Font.Unknown
	_35RBX.Text = "35"
	_35RBX.TextColor3 = Color3.fromRGB(251, 255, 19)
	_35RBX.TextScaled = true
	_35RBX.TextSize = 14.000
	_35RBX.TextWrapped = true
	_35RBX.Parent = TimeAdd
	local UICorner_33 = Instance.new("UICorner")
	UICorner_33.CornerRadius = UDim.new(0.899999976, 0)
	UICorner_33.Parent = _35RBX

	local save90 = Instance.new("TextLabel")
	save90.Name = "save90"
	save90.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	save90.BackgroundTransparency = 1.000
	save90.BorderColor3 = Color3.fromRGB(0, 0, 0)
	save90.BorderSizePixel = 0
	save90.Position = UDim2.new(0.496937603, 0, 0.49510631, 0)
	save90.Rotation = -15.000
	save90.Size = UDim2.new(0.211853966, 0, 0.0540581606, 0)
	save90.Font = Enum.Font.Unknown
	save90.Text = "SAVE %90"
	save90.TextColor3 = Color3.fromRGB(252, 0, 4)
	save90.TextScaled = true
	save90.TextSize = 14.000
	save90.TextWrapped = true
	save90.Parent = TimeAdd
	local UICorner_34 = Instance.new("UICorner")
	UICorner_34.CornerRadius = UDim.new(0.0700000003, 0)
	UICorner_34.Parent = save90

	local save45 = Instance.new("TextLabel")
	save45.Name = "save45"
	save45.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	save45.BackgroundTransparency = 1.000
	save45.BorderColor3 = Color3.fromRGB(0, 0, 0)
	save45.BorderSizePixel = 0
	save45.Position = UDim2.new(-0.000458240509, 0, 0.49510631, 0)
	save45.Rotation = -15.000
	save45.Size = UDim2.new(0.211853966, 0, 0.0540581606, 0)
	save45.Font = Enum.Font.Unknown
	save45.Text = "SAVE %45"
	save45.TextColor3 = Color3.fromRGB(252, 0, 4)
	save45.TextScaled = true
	save45.TextSize = 14.000
	save45.TextWrapped = true
	save45.Parent = TimeAdd
	local UICorner_35 = Instance.new("UICorner")
	UICorner_35.CornerRadius = UDim.new(0.0700000003, 0)
	UICorner_35.Parent = save45

	local save15 = Instance.new("TextLabel")
	save15.Name = "save15"
	save15.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	save15.BackgroundTransparency = 1.000
	save15.BorderColor3 = Color3.fromRGB(0, 0, 0)
	save15.BorderSizePixel = 0
	save15.Position = UDim2.new(0.496937603, 0, 0.193022966, 0)
	save15.Rotation = -15.000
	save15.Size = UDim2.new(0.211853966, 0, 0.0540581606, 0)
	save15.Font = Enum.Font.Unknown
	save15.Text = "SAVE %15"
	save15.TextColor3 = Color3.fromRGB(252, 0, 4)
	save15.TextScaled = true
	save15.TextSize = 14.000
	save15.TextWrapped = true
	save15.Parent = TimeAdd
	local UICorner_36 = Instance.new("UICorner")
	UICorner_36.CornerRadius = UDim.new(0.0700000003, 0)
	UICorner_36.Parent = save15

	local popular = Instance.new("TextLabel")
	popular.Name = "popular"
	popular.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	popular.BackgroundTransparency = 1.000
	popular.BorderColor3 = Color3.fromRGB(0, 0, 0)
	popular.BorderSizePixel = 0
	popular.Position = UDim2.new(0.283117145, 0, 0.485255808, 0)
	popular.Rotation = 15.000
	popular.Size = UDim2.new(0.211853966, 0, 0.0720273778, 0)
	popular.Font = Enum.Font.Unknown
	popular.Text = "MOST POPULAR"
	popular.TextColor3 = Color3.fromRGB(252, 236, 11)
	popular.TextScaled = true
	popular.TextSize = 14.000
	popular.TextWrapped = true
	popular.Parent = TimeAdd
	local UICorner_37 = Instance.new("UICorner")
	UICorner_37.CornerRadius = UDim.new(0.0700000003, 0)
	UICorner_37.Parent = popular

	-- Ürün ID'leri ile bağlantı
	local productIDs = {
		["10RBX"] = 3613048307,  -- 1 Hour
		["35RBX"] = 3613048436,  -- 5 Hours
		["55RBX"] = 3613048476,  -- 10 Hours
		["500RBX"] = 1931252522, -- Lifetime (GamePass)
	}
	local function buyProduct(id, isGamePass)
		if isGamePass then
			MarketplaceService:PromptGamePassPurchase(LocalPlayer, id)
		else
			MarketplaceService:PromptProductPurchase(LocalPlayer, id)
		end
	end
	_10RBX.MouseButton1Click:Connect(function() buyProduct(productIDs["10RBX"], false) end)
	_35RBX.MouseButton1Click:Connect(function() buyProduct(productIDs["35RBX"], false) end)
	_55RBX.MouseButton1Click:Connect(function() buyProduct(productIDs["55RBX"], false) end)
	_500RBX.MouseButton1Click:Connect(function() buyProduct(productIDs["500RBX"], true) end)

	Close_3.MouseButton1Click:Connect(function() TimeAdd.Visible = false end)

	-- + butonu tıklama
	PlusBtn.MouseButton1Click:Connect(function()
		TimeAdd.Visible = not TimeAdd.Visible
	end)

	-- Satın alma sonrası süre ekleme (mevcut mantık)
	MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, isPurchased)
		if isPurchased and userId == LocalPlayer.UserId then
			if productId == 3613048307 then
				CurrentHWIDData.RemainingSeconds = CurrentHWIDData.RemainingSeconds + 3600
				CurrentHWIDData.ExtraBonusSeconds = CurrentHWIDData.ExtraBonusSeconds + 3600
			elseif productId == 3613048436 then
				CurrentHWIDData.RemainingSeconds = CurrentHWIDData.RemainingSeconds + 18000
				CurrentHWIDData.ExtraBonusSeconds = CurrentHWIDData.ExtraBonusSeconds + 18000
			elseif productId == 3613048476 then
				CurrentHWIDData.RemainingSeconds = CurrentHWIDData.RemainingSeconds + 36000
				CurrentHWIDData.ExtraBonusSeconds = CurrentHWIDData.ExtraBonusSeconds + 36000
			end
			SaveTimeData()
		end
	end)
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, isPurchased)
		if isPurchased and player == LocalPlayer and gamePassId == 1931252522 then
			CurrentHWIDData.IsLifetime = true
			SaveTimeData()
		end
	end)

	-- Süre sayacı
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
			end
		end
	end)

	-- ══════════════════════════════════════
	--  TAB SİSTEMİ
	-- ══════════════════════════════════════
	local Pages = {}
	local Tabs = {}

	local function CreateTabInternal(tabName, layoutOrder)
		local TabSetup = {}

		local Button = Instance.new("TextButton")
		Button.Name = "Button"
		Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Button.BackgroundTransparency = 1.000
		Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Button.BorderSizePixel = 0
		Button.Font = Enum.Font.Unknown
		Button.Text = tabName
		Button.TextColor3 = Color3.fromRGB(255, 255, 255)
		Button.TextScaled = true
		Button.TextSize = 14.000
		Button.TextWrapped = true
		Button.Size = UDim2.new(0.85, 0, 0.1, 0)
		Button.LayoutOrder = layoutOrder or #Tabs
		Button.Parent = SideBar
		registerThemeable(Button, {TextColor3 = "TextColor"})

		local Seiliolanvurgulama = Instance.new("Frame")
		Seiliolanvurgulama.Name = "Seiliolanvurgulama"
		Seiliolanvurgulama.BackgroundColor3 = CurrentTheme.Primary
		Seiliolanvurgulama.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Seiliolanvurgulama.BorderSizePixel = 0
		Seiliolanvurgulama.Position = UDim2.new(0.1, 0, 1, 0)
		Seiliolanvurgulama.Size = UDim2.new(0.8, 0, 0.1, 0)
		Seiliolanvurgulama.Visible = false
		Seiliolanvurgulama.Parent = Button
		local UICorner_12 = Instance.new("UICorner")
		UICorner_12.CornerRadius = UDim.new(0.899999976, 0)
		UICorner_12.Parent = Seiliolanvurgulama

		local TabPage = Instance.new("ScrollingFrame")
		TabPage.Size = UDim2.new(1, 0, 1, 0)
		TabPage.BackgroundTransparency = 1
		TabPage.BorderSizePixel = 0
		TabPage.ScrollBarThickness = 4
		TabPage.ScrollBarImageColor3 = CurrentTheme.Primary
		TabPage.Active = true
		TabPage.Visible = false
		TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
		TabPage.Parent = PageScroll
		local UIPadding = Instance.new("UIPadding")
		UIPadding.PaddingTop = UDim.new(0, 10)
		UIPadding.PaddingLeft = UDim.new(0, 10)
		UIPadding.PaddingRight = UDim.new(0, 10)
		UIPadding.Parent = TabPage

		local Layout = Instance.new("UIListLayout")
		Layout.SortOrder = Enum.SortOrder.LayoutOrder
		Layout.Padding = UDim.new(0, 10)
		Layout.Parent = TabPage

		TabPage.ChildAdded:Connect(function(child)
			if child:IsA("GuiObject") then
				task.wait()
				TabPage.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
			end
		end)

		Button.MouseButton1Click:Connect(function()
			for _, p in ipairs(Pages) do p.Visible = false end
			for _, t in ipairs(Tabs) do
				t.Indicator.Visible = false
			end
			TabPage.Visible = true
			Seiliolanvurgulama.Visible = true
			playClickSound()
		end)

		table.insert(Pages, TabPage)
		table.insert(Tabs, {Btn = Button, Indicator = Seiliolanvurgulama})

		if #Pages == 1 then
			TabPage.Visible = true
			Seiliolanvurgulama.Visible = true
		end

		local elementCounter = 0
		local function generateId(baseName)
			elementCounter = elementCounter + 1
			return baseName .. "_" .. elementCounter
		end

		-- === TÜM ELEMENT FONKSİYONLARI (öncekiyle aynı) ===
		function TabSetup:CreateToggle(name, callback)
			local id = generateId("toggle_" .. name)
			local ToggleFrame = Instance.new("Frame")
			ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
			ToggleFrame.BackgroundColor3 = CurrentTheme.PanelLight
			ToggleFrame.Active = true
			ToggleFrame.Parent = TabPage
			createCorner(ToggleFrame, 8)
			createStroke(ToggleFrame, CurrentTheme.Primary, 1)
			registerThemeable(ToggleFrame, {BackgroundColor3 = "PanelLight"})

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -80, 1, 0)
			Label.Position = UDim2.new(0, 15, 0, 0)
			Label.Text = name
			Label.Font = Enum.Font.GothamSemibold
			Label.TextSize = 14
			Label.TextColor3 = CurrentTheme.TextColor
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.BackgroundTransparency = 1
			Label.Parent = ToggleFrame
			registerThemeable(Label, {TextColor3 = "TextColor"})

			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(0, 50, 0, 26)
			Btn.Position = UDim2.new(1, -65, 0.5, -13)
			Btn.BackgroundColor3 = CurrentTheme.Panel
			Btn.Text = ""
			Btn.Parent = ToggleFrame
			createCorner(Btn, 13)
			registerThemeable(Btn, {BackgroundColor3 = "Panel"})

			local Circle = Instance.new("Frame")
			Circle.Size = UDim2.new(0, 20, 0, 20)
			Circle.Position = UDim2.new(0, 3, 0.5, -10)
			Circle.BackgroundColor3 = Color3.new(1, 1, 1)
			Circle.Parent = Btn
			createCorner(Circle, 10)

			local state = false
			ConfigValues[id] = state
			registerConfig(id, function(val)
				state = val
				local gPos = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
				local gCol = state and CurrentTheme.Primary or CurrentTheme.Panel
				TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = gPos}):Play()
				TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = gCol}):Play()
				callback(state)
			end)

			Btn.MouseButton1Click:Connect(function()
				state = not state
				ConfigValues[id] = state
				for _, entry in ipairs(ConfigCallbacks) do
					if entry.id == id then
						entry.set(state)
						break
					end
				end
				playClickSound()
			end)
		end

		function TabSetup:CreatePremiumToggle(name, callback)
			local id = generateId("prem_toggle_" .. name)
			local ToggleFrame = Instance.new("Frame")
			ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
			ToggleFrame.BackgroundColor3 = CurrentTheme.PanelLight
			ToggleFrame.Active = true
			ToggleFrame.Parent = TabPage
			createCorner(ToggleFrame, 8)
			createStroke(ToggleFrame, Color3.fromRGB(255, 215, 0), 1.5)
			registerThemeable(ToggleFrame, {BackgroundColor3 = "PanelLight"})

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -110, 1, 0)
			Label.Position = UDim2.new(0, 15, 0, 0)
			Label.Text = name
			Label.Font = Enum.Font.GothamBold
			Label.TextSize = 14
			Label.TextColor3 = CurrentTheme.TextColor
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.BackgroundTransparency = 1
			Label.Parent = ToggleFrame
			registerThemeable(Label, {TextColor3 = "TextColor"})

			local Badge = Instance.new("TextLabel")
			Badge.Size = UDim2.new(0, 52, 0, 18)
			Badge.Position = UDim2.new(1, -125, 0.5, -9)
			Badge.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
			Badge.Text = "PREMIUM"
			Badge.Font = Enum.Font.GothamBlack
			Badge.TextSize = 9
			Badge.TextColor3 = Color3.new(0, 0, 0)
			Badge.Parent = ToggleFrame
			createCorner(Badge, 4)

			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(0, 50, 0, 26)
			Btn.Position = UDim2.new(1, -65, 0.5, -13)
			Btn.BackgroundColor3 = CurrentTheme.Panel
			Btn.Text = ""
			Btn.Parent = ToggleFrame
			createCorner(Btn, 13)
			registerThemeable(Btn, {BackgroundColor3 = "Panel"})

			local Circle = Instance.new("Frame")
			Circle.Size = UDim2.new(0, 20, 0, 20)
			Circle.Position = UDim2.new(0, 3, 0.5, -10)
			Circle.BackgroundColor3 = Color3.new(1, 1, 1)
			Circle.Parent = Btn
			createCorner(Circle, 10)

			local state = false
			ConfigValues[id] = state
			registerConfig(id, function(val)
				state = val
				local gPos = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
				local gCol = state and Color3.fromRGB(255, 215, 0) or CurrentTheme.Panel
				TweenService:Create(Circle, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = gPos}):Play()
				TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = gCol}):Play()
				callback(state)
			end)

			Btn.MouseButton1Click:Connect(function()
				state = not state
				ConfigValues[id] = state
				for _, entry in ipairs(ConfigCallbacks) do
					if entry.id == id then
						entry.set(state)
						break
					end
				end
				playClickSound()
			end)
		end

		function TabSetup:CreateTextbox(name, placeholder, callback)
			local id = generateId("textbox_" .. name)
			local BoxFrame = Instance.new("Frame")
			BoxFrame.Size = UDim2.new(1, 0, 0, 48)
			BoxFrame.BackgroundColor3 = CurrentTheme.PanelLight
			BoxFrame.Active = true
			BoxFrame.Parent = TabPage
			createCorner(BoxFrame, 8)
			createStroke(BoxFrame, CurrentTheme.Primary, 1)
			registerThemeable(BoxFrame, {BackgroundColor3 = "PanelLight"})

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(0.5, 0, 1, 0)
			Label.Position = UDim2.new(0, 15, 0, 0)
			Label.Text = name
			Label.Font = Enum.Font.GothamSemibold
			Label.TextSize = 14
			Label.TextColor3 = CurrentTheme.TextColor
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.BackgroundTransparency = 1
			Label.Parent = BoxFrame
			registerThemeable(Label, {TextColor3 = "TextColor"})

			local TextBoxBg = Instance.new("Frame")
			TextBoxBg.Size = UDim2.new(0.45, 0, 0, 32)
			TextBoxBg.Position = UDim2.new(1, -15, 0.5, -16)
			TextBoxBg.AnchorPoint = Vector2.new(1, 0)
			TextBoxBg.BackgroundColor3 = CurrentTheme.Panel
			TextBoxBg.Parent = BoxFrame
			createCorner(TextBoxBg, 6)
			registerThemeable(TextBoxBg, {BackgroundColor3 = "Panel"})

			local TxtBox = Instance.new("TextBox")
			TxtBox.Size = UDim2.new(1, -10, 1, 0)
			TxtBox.Position = UDim2.new(0, 5, 0, 0)
			TxtBox.BackgroundTransparency = 1
			TxtBox.Text = ""
			TxtBox.PlaceholderText = placeholder or "Type here..."
			TxtBox.Font = Enum.Font.Gotham
			TxtBox.TextSize = 13
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
			DropdownFrame.Size = UDim2.new(1, 0, 0, 48)
			DropdownFrame.BackgroundColor3 = CurrentTheme.PanelLight
			DropdownFrame.Active = true
			DropdownFrame.ClipsDescendants = true
			DropdownFrame.Parent = TabPage
			createCorner(DropdownFrame, 8)
			createStroke(DropdownFrame, CurrentTheme.Primary, 1)
			registerThemeable(DropdownFrame, {BackgroundColor3 = "PanelLight"})

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -30, 0, 48)
			Label.Position = UDim2.new(0, 15, 0, 0)
			Label.Text = name .. " : " .. tostring(default)
			Label.Font = Enum.Font.GothamSemibold
			Label.TextSize = 14
			Label.TextColor3 = CurrentTheme.TextColor
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.BackgroundTransparency = 1
			Label.Parent = DropdownFrame
			registerThemeable(Label, {TextColor3 = "TextColor"})

			local ToggleBtn = Instance.new("TextButton")
			ToggleBtn.Size = UDim2.new(1, 0, 0, 48)
			ToggleBtn.BackgroundTransparency = 1
			ToggleBtn.Text = ""
			ToggleBtn.Parent = DropdownFrame

			local OptionContainer = Instance.new("Frame")
			OptionContainer.Size = UDim2.new(1, 0, 1, -48)
			OptionContainer.Position = UDim2.new(0, 0, 0, 48)
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
					OptBtn.Size = UDim2.new(1, 0, 0, 34)
					OptBtn.BackgroundColor3 = CurrentTheme.Panel
					OptBtn.Text = "  " .. option
					OptBtn.Font = Enum.Font.Gotham
					OptBtn.TextSize = 13
					OptBtn.TextColor3 = CurrentTheme.SubTextColor
					OptBtn.TextXAlignment = Enum.TextXAlignment.Left
					OptBtn.Parent = OptionContainer
					createCorner(OptBtn, 6)
					registerThemeable(OptBtn, {BackgroundColor3 = "Panel", TextColor3 = "SubTextColor"})

					OptBtn.MouseButton1Click:Connect(function()
						selectedValue = option
						Label.Text = name .. " : " .. option
						ConfigValues[id] = option
						isDropped = false
						TweenService:Create(DropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 48)}):Play()
						TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = CurrentTheme.TextColor}):Play()
						callback(selectedValue)
						playClickSound()
					end)

					OptBtn.MouseEnter:Connect(function()
						TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.PrimaryDark, TextColor3 = Color3.new(1, 1, 1)}):Play()
					end)
					OptBtn.MouseLeave:Connect(function()
						TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Panel, TextColor3 = CurrentTheme.SubTextColor}):Play()
					end)
				end
			end
			BuildOptions(options)

			ToggleBtn.MouseButton1Click:Connect(function()
				isDropped = not isDropped
				local childCount = 0
				for _, v in pairs(OptionContainer:GetChildren()) do if v:IsA("TextButton") then childCount = childCount + 1 end end
				local targetHeight = isDropped and (48 + (childCount * 34)) or 48
				TweenService:Create(DropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
				TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = isDropped and CurrentTheme.Primary or CurrentTheme.TextColor}):Play()
				playClickSound()
			end)

			local DropdownAPI = {}
			function DropdownAPI:Refresh(newOptions)
				BuildOptions(newOptions)
				if isDropped then
					local targetHeight = 48 + (#newOptions * 34)
					TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
				end
			end
			return DropdownAPI
		end

		function TabSetup:CreateSlider(name, min, max, default, callback)
			local id = generateId("slider_" .. name)
			local SliderFrame = Instance.new("Frame")
			SliderFrame.Size = UDim2.new(1, 0, 0, 65)
			SliderFrame.BackgroundColor3 = CurrentTheme.PanelLight
			SliderFrame.Active = true
			SliderFrame.Parent = TabPage
			createCorner(SliderFrame, 8)
			createStroke(SliderFrame, CurrentTheme.Primary, 1)
			registerThemeable(SliderFrame, {BackgroundColor3 = "PanelLight"})

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -50, 0, 25)
			Label.Position = UDim2.new(0, 15, 0, 8)
			Label.Text = name
			Label.Font = Enum.Font.GothamSemibold
			Label.TextSize = 14
			Label.TextColor3 = CurrentTheme.TextColor
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.BackgroundTransparency = 1
			Label.Parent = SliderFrame
			registerThemeable(Label, {TextColor3 = "TextColor"})

			local ValueText = Instance.new("TextLabel")
			ValueText.Size = UDim2.new(0, 50, 0, 25)
			ValueText.Position = UDim2.new(1, -65, 0, 8)
			ValueText.Text = tostring(default)
			ValueText.Font = Enum.Font.GothamBold
			ValueText.TextSize = 14
			ValueText.TextColor3 = CurrentTheme.Primary
			ValueText.TextXAlignment = Enum.TextXAlignment.Right
			ValueText.BackgroundTransparency = 1
			ValueText.Parent = SliderFrame
			registerThemeable(ValueText, {TextColor3 = "Primary"})

			local Bar = Instance.new("TextButton")
			Bar.Size = UDim2.new(1, -30, 0, 8)
			Bar.Position = UDim2.new(0, 15, 0, 42)
			Bar.BackgroundColor3 = CurrentTheme.Panel
			Bar.Text = ""
			Bar.Parent = SliderFrame
			createCorner(Bar, 4)
			registerThemeable(Bar, {BackgroundColor3 = "Panel"})

			local Fill = Instance.new("Frame")
			local defaultPercent = (default - min) / (max - min)
			Fill.Size = UDim2.new(defaultPercent, 0, 1, 0)
			Fill.BackgroundColor3 = CurrentTheme.Primary
			Fill.Parent = Bar
			createCorner(Fill, 4)
			registerThemeable(Fill, {BackgroundColor3 = "Primary"})

			local Knob = Instance.new("Frame")
			Knob.Size = UDim2.new(0, 14, 0, 14)
			Knob.Position = UDim2.new(defaultPercent, -7, 0.5, -7)
			Knob.BackgroundColor3 = Color3.new(1, 1, 1)
			Knob.BorderSizePixel = 0
			Knob.Parent = Bar
			createCorner(Knob, 7)

			local currentValue = default
			ConfigValues[id] = currentValue
			registerConfig(id, function(val)
				currentValue = math.clamp(val, min, max)
				local percent = (currentValue - min) / (max - min)
				Fill.Size = UDim2.new(percent, 0, 1, 0)
				Knob.Position = UDim2.new(percent, -7, 0.5, -7)
				ValueText.Text = tostring(currentValue)
				callback(currentValue)
			end)

			local draggingSlider = false
			Bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = true end
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
					Fill.Size = UDim2.new(percent, 0, 1, 0)
					Knob.Position = UDim2.new(percent, -7, 0.5, -7)
					ValueText.Text = tostring(currentValue)
					callback(currentValue)
				end
			end)
		end

		function TabSetup:CreateButton(name, callback)
			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, 0, 0, 42)
			Btn.BackgroundColor3 = CurrentTheme.PanelLight
			Btn.Text = name
			Btn.Font = Enum.Font.GothamBold
			Btn.TextSize = 15
			Btn.TextColor3 = CurrentTheme.TextColor
			Btn.Active = true
			Btn.Parent = TabPage
			createCorner(Btn, 8)
			createStroke(Btn, CurrentTheme.Primary, 1)
			registerThemeable(Btn, {BackgroundColor3 = "PanelLight", TextColor3 = "TextColor"})

			local function pressAnim()
				TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.98, 0, 0, 40), BackgroundColor3 = CurrentTheme.Primary}):Play()
				task.wait(0.1)
				TweenService:Create(Btn, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = CurrentTheme.PanelLight}):Play()
			end

			Btn.MouseButton1Click:Connect(function()
				pressAnim()
				playClickSound()
				callback()
			end)
			Btn.MouseEnter:Connect(function()
				TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.PrimaryDark}):Play()
			end)
			Btn.MouseLeave:Connect(function()
				TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.PanelLight}):Play()
			end)
		end

		function TabSetup:CreateDivider()
			local Div = Instance.new("Frame")
			Div.Size = UDim2.new(1, 0, 0, 2)
			Div.BackgroundColor3 = CurrentTheme.Primary
			Div.BackgroundTransparency = 0.5
			Div.BorderSizePixel = 0
			Div.Parent = TabPage
			registerThemeable(Div, {BackgroundColor3 = "Primary"})
		end

		function TabSetup:CreateNotification(title, message, duration)
			duration = duration or 2
			local Notif = Instance.new("Frame")
			Notif.Size = UDim2.new(0, 250, 0, 70)
			Notif.Position = UDim2.new(1, 10, 1, -80)
			Notif.BackgroundColor3 = CurrentTheme.Panel
			Notif.Active = true
			Notif.Parent = EmloxaW
			createCorner(Notif, 10)
			createStroke(Notif, CurrentTheme.Primary, 2)
			registerThemeable(Notif, {BackgroundColor3 = "Panel"})

			local TitleLabel = Instance.new("TextLabel")
			TitleLabel.Text = title
			TitleLabel.Font = Enum.Font.GothamBold
			TitleLabel.TextSize = 15
			TitleLabel.TextColor3 = CurrentTheme.Primary
			TitleLabel.Size = UDim2.new(1, -20, 0, 22)
			TitleLabel.Position = UDim2.new(0, 10, 0, 8)
			TitleLabel.BackgroundTransparency = 1
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
			TitleLabel.Parent = Notif
			registerThemeable(TitleLabel, {TextColor3 = "Primary"})

			local MsgLabel = Instance.new("TextLabel")
			MsgLabel.Text = message
			MsgLabel.Font = Enum.Font.Gotham
			MsgLabel.TextSize = 13
			MsgLabel.TextColor3 = CurrentTheme.TextColor
			MsgLabel.Size = UDim2.new(1, -20, 0, 30)
			MsgLabel.Position = UDim2.new(0, 10, 0, 32)
			MsgLabel.BackgroundTransparency = 1
			MsgLabel.TextXAlignment = Enum.TextXAlignment.Left
			MsgLabel.TextWrapped = true
			MsgLabel.Parent = Notif
			registerThemeable(MsgLabel, {TextColor3 = "TextColor"})

			TweenService:Create(Notif, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(1, -260, 1, -80)}):Play()
			task.wait(duration)
			TweenService:Create(Notif, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 10, 1, -80)}):Play()
			task.wait(0.4)
			Notif:Destroy()
		end

		return TabSetup
	end

	-- ══════════════════════════════════════
	--  MENU TAB (CONFIG)
	-- ══════════════════════════════════════
	local MenuTab = CreateTabInternal("Menu", 9999)
	MenuTab:CreateDropdown("Theme", EmloxaLibrary:GetThemeNames(), "Default", function(val)
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

	-- Pencere kontrol butonları
	Close.MouseButton1Click:Connect(function()
		Menu.Visible = false
	end)
	Close_2.MouseButton1Click:Connect(function() -- minimize
		Page.Visible = not Page.Visible
		SideBar.Visible = not SideBar.Visible
	end)

	function WindowSetup:CreateTab(tabName)
		return CreateTabInternal(tabName, #Tabs + 1)
	end

	return WindowSetup
end

return EmloxaLibrary
