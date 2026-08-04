-- =========================================================================
-- EMLOXA WARE PREMIUM UI v16.5 (SIDEBAR REDESIGN)
-- SIDEBAR NAVIGATION, SLEEK MODERN LOOK
-- ALL NAMES/IDENTIFIERS PRESERVED FOR COMPATIBILITY
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
--  AUTOMATIC METATABLE NAME SPOOFER (ONCE)
-- ══════════════════════════════════════
local SpoofedName = GenerateRandomString(18)
local SpoofedDisplayName = GenerateRandomString(20)

pcall(function()
	local rawMeta = getrawmetatable(game)
	if setreadonly then setreadonly(rawMeta, false) end
	local oldIndex = rawMeta.__index
	rawMeta.__index = newcclosure(function(self, key)
		if not checkcaller() and self == LocalPlayer then
			if key == "Name" or key == "name" then
				return SpoofedName
			elseif key == "DisplayName" or key == "displayName" then
				return SpoofedDisplayName
			end
		end
		return oldIndex(self, key)
	end)
	if setreadonly then setreadonly(rawMeta, true) end
end)

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
	RemainingSeconds = 7200, -- 2 Hours default daily limit
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

-- INITIAL LIFETIME GAMEPASS CHECK (If user already owns it)
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
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, radius or 8); c.Parent = frame
	return c
end
local function createStroke(frame, color, thickness)
	local s = Instance.new("UIStroke"); s.Color = color or CurrentTheme.Primary; s.Thickness = thickness or 2; s.Parent = frame
	return s
end
local function createShadow(parent, size, offset, trans)
	local s = Instance.new("ImageLabel")
	s.Image = "rbxassetid://6014261993"; s.ScaleType = Enum.ScaleType.Slice; s.SliceCenter = Rect.new(49,49,49,49)
	s.Size = size or UDim2.new(1,20,1,20); s.Position = UDim2.new(0,offset or -10,0,offset or -10)
	s.BackgroundTransparency = 1; s.ImageTransparency = trans or 0.7; s.ImageColor3 = Color3.new(0,0,0); s.Parent = parent
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
	if SafeParent:FindFirstChild("EmloxaWareUI") then SafeParent.EmloxaWareUI:Destroy() end

	local HubGui = Instance.new("ScreenGui")
	HubGui.Name = "EmloxaWareUI"
	HubGui.ResetOnSpawn = false
	HubGui.IgnoreGuiInset = true
	HubGui.Parent = SafeParent

	local OpenIconFrame = Instance.new("Frame")
	OpenIconFrame.Name = "OpenIconFrame"
	OpenIconFrame.Size = UDim2.new(0, 55, 0, 55)
	OpenIconFrame.Position = UDim2.new(0, 15, 0, 75)
	OpenIconFrame.BackgroundColor3 = CurrentTheme.Panel
	OpenIconFrame.Visible = false
	OpenIconFrame.Active = true
	OpenIconFrame.Parent = HubGui
	createCorner(OpenIconFrame, 14)
	local iconStroke = createStroke(OpenIconFrame, CurrentTheme.Primary, 2)
	registerThemeable(OpenIconFrame, {BackgroundColor3 = "Panel"})

	local IconFallback = Instance.new("TextLabel")
	IconFallback.Size = UDim2.new(1,0,1,0)
	IconFallback.BackgroundTransparency = 1
	IconFallback.Text = "E"
	IconFallback.Font = Enum.Font.GothamBlack
	IconFallback.TextScaled = true
	IconFallback.TextColor3 = CurrentTheme.Primary
	IconFallback.Parent = OpenIconFrame
	registerThemeable(IconFallback, {TextColor3 = "Primary"})

	local OpenIcon = Instance.new("ImageButton")
	OpenIcon.Size = UDim2.new(1,0,1,0)
	OpenIcon.BackgroundTransparency = 1
	OpenIcon.Image = "rbxassetid://76693493960487"
	OpenIcon.ScaleType = Enum.ScaleType.Fit
	OpenIcon.Active = true
	OpenIcon.Parent = OpenIconFrame
	createCorner(OpenIcon, 14)

	RunService.RenderStepped:Connect(function()
		iconStroke.Color = Color3.fromHSV(tick()*0.3 % 1, 0.9, 1)
	end)

	local LoadingFrame = Instance.new("Frame")
	LoadingFrame.Name = "LoadingFrame"
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
	LoadLogoContainer.Parent = LoadingFrame

	local LoadFallback = Instance.new("TextLabel")
	LoadFallback.Size = UDim2.new(1,0,1,0)
	LoadFallback.BackgroundTransparency = 1
	LoadFallback.Text = "E"
	LoadFallback.Font = Enum.Font.GothamBlack
	LoadFallback.TextScaled = true
	LoadFallback.TextColor3 = CurrentTheme.Primary
	LoadFallback.Parent = LoadLogoContainer

	local LoadLogo = Instance.new("ImageLabel")
	LoadLogo.Size = UDim2.new(1,0,1,0)
	LoadLogo.BackgroundTransparency = 1
	LoadLogo.Image = "rbxassetid://76693493960487"
	LoadLogo.ScaleType = Enum.ScaleType.Fit
	LoadLogo.Parent = LoadLogoContainer

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

	task.wait(2)
	for _, conn in ipairs(loadingConnections) do conn:Disconnect() end
	TweenService:Create(LoadingFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
	TweenService:Create(LoadLogo, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
	TweenService:Create(LoadFallback, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
	TweenService:Create(LoadText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
	task.wait(0.6)
	LoadingFrame:Destroy()

	-- ==============================
	-- MAIN FRAME
	-- ==============================
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 690, 0, 460)
	MainFrame.Position = UDim2.new(0.5, -345, 0.5, -230)
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true
	MainFrame.Active = true
	MainFrame.Parent = HubGui
	createCorner(MainFrame, 14)
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

	-- ==============================
	-- TOP BAR (Title, Credits, Time, Controls)
	-- ==============================
	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Size = UDim2.new(1,0,0,50)
	TopBar.BackgroundColor3 = CurrentTheme.Panel
	TopBar.BorderSizePixel = 0
	TopBar.Active = true
	TopBar.Parent = MainFrame
	createCorner(TopBar, 14)
	local topCover = Instance.new("Frame", TopBar)
	topCover.Size = UDim2.new(1,0,0.5,0)
	topCover.Position = UDim2.new(0,0,0.5,0)
	topCover.BackgroundColor3 = CurrentTheme.Panel
	topCover.BorderSizePixel = 0
	registerThemeable(TopBar, {BackgroundColor3 = "Panel"})

	local Title = Instance.new("TextLabel")
	Title.Text = " "..hubName
	Title.Font = Enum.Font.GothamBlack
	Title.TextSize = 15
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Size = UDim2.new(0, 180, 1, 0)
	Title.Position = UDim2.new(0, 15, 0, 0)
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

	-- ══════════════════════════════════════
	--  TIME WIDGET & RECHARGE MODAL LOGIC
	-- ══════════════════════════════════════
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

	local function OpenRechargeModal()
		local Overlay = Instance.new("Frame")
		Overlay.Size = UDim2.new(1,0,1,0)
		Overlay.BackgroundColor3 = Color3.new(0,0,0)
		Overlay.BackgroundTransparency = 0.5
		Overlay.Active = true
		Overlay.ZIndex = 100
		Overlay.Parent = HubGui

		local Modal = Instance.new("Frame")
		Modal.Size = UDim2.new(0, 500, 0, 330)
		Modal.Position = UDim2.new(0.5, -250, 0.5, -165)
		Modal.BackgroundColor3 = CurrentTheme.Panel
		Modal.ZIndex = 101
		Modal.Parent = Overlay
		createCorner(Modal, 12)
		createStroke(Modal, CurrentTheme.Primary, 2)
		registerThemeable(Modal, {BackgroundColor3 = "Panel"})

		local MTitle = Instance.new("TextLabel")
		MTitle.Text = "⚡ Extend Subscription Access"
		MTitle.Font = Enum.Font.GothamBlack; MTitle.TextSize = 16
		MTitle.TextColor3 = CurrentTheme.Primary
		MTitle.Size = UDim2.new(1,-40,0,30); MTitle.Position = UDim2.new(0,18,0,12)
		MTitle.BackgroundTransparency = 1; MTitle.TextXAlignment = Enum.TextXAlignment.Left
		MTitle.ZIndex = 102; MTitle.Parent = Modal
		registerThemeable(MTitle, {TextColor3 = "Primary"})

		local MClose = Instance.new("TextButton")
		MClose.Size = UDim2.new(0,28,0,28); MClose.Position = UDim2.new(1,-36,0,12)
		MClose.Text = "X"; MClose.Font = Enum.Font.GothamBold; MClose.TextColor3 = CurrentTheme.Accent
		MClose.BackgroundColor3 = CurrentTheme.PanelLight
		MClose.ZIndex = 102; MClose.Parent = Modal
		createCorner(MClose,6)
		registerThemeable(MClose, {BackgroundColor3 = "PanelLight"})

		MClose.MouseButton1Click:Connect(function() Overlay:Destroy() end)

		local Grid = Instance.new("Frame")
		Grid.Size = UDim2.new(1,-36,1,-60); Grid.Position = UDim2.new(0,18,0,50)
		Grid.BackgroundTransparency = 1
		Grid.ZIndex = 102; Grid.Parent = Modal

		local Layout = Instance.new("UIGridLayout", Grid)
		Layout.CellSize = UDim2.new(0, 222, 0, 120)
		Layout.CellPadding = UDim2.new(0, 18, 0, 18)

		local Options = {
			{Name = "1 Hour Pass", Price = "10 Robux", Sale = "20% SALE", ID = 3613048307, Type = "Product"},
			{Name = "5 Hours Pass", Price = "35 Robux", Sale = "30% SALE", ID = 3613048436, Type = "Product"},
			{Name = "10 Hours Pass", Price = "55 Robux", Sale = "45% SALE", ID = 3613048476, Type = "Product"},
			{Name = "LIFETIME VIP", Price = "500 Robux", Sale = "70% BEST VALUE", ID = 1931252522, Type = "GamePass"}
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

			local CSale = Instance.new("TextLabel")
			CSale.Text = opt.Sale; CSale.Font = Enum.Font.GothamBlack; CSale.TextSize = 10
			CSale.TextColor3 = CurrentTheme.Accent; CSale.Size = UDim2.new(1,-10,0,18)
			CSale.Position = UDim2.new(0,8,0,30); CSale.BackgroundTransparency = 1
			CSale.TextXAlignment = Enum.TextXAlignment.Left
			CSale.ZIndex = 104; CSale.Parent = Card

			local BuyBtn = Instance.new("TextButton")
			BuyBtn.Size = UDim2.new(1,-16,0,34); BuyBtn.Position = UDim2.new(0,8,1,-42)
			BuyBtn.BackgroundColor3 = CurrentTheme.Primary; BuyBtn.Text = "Buy " .. opt.Price
			BuyBtn.Font = Enum.Font.GothamBold; BuyBtn.TextColor3 = Color3.new(1,1,1)
			BuyBtn.TextSize = 12
			BuyBtn.ZIndex = 105; BuyBtn.Parent = Card
			createCorner(BuyBtn, 6)

			BuyBtn.MouseButton1Click:Connect(function()
				pcall(function()
					if opt.Type == "Product" then
						MarketplaceService:PromptProductPurchase(LocalPlayer, opt.ID)
					elseif opt.Type == "GamePass" then
						MarketplaceService:PromptGamePassPurchase(LocalPlayer, opt.ID)
					end
				end)
			end)
		end
	end

	PlusBtn.MouseButton1Click:Connect(OpenRechargeModal)

	-- DevProduct AND GamePass Listeners
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

	-- ══════════════════════════════════════
	--  WINDOW CONTROLS (MINIMIZE / CLOSE)
	-- ══════════════════════════════════════
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
	CloseBtn.Position = UDim2.new(0,50,0.5,-16)
	CloseBtn.Text = "X"
	CloseBtn.Font = Enum.Font.GothamBlack
	CloseBtn.TextSize = 18
	CloseBtn.TextColor3 = CurrentTheme.Accent
	CloseBtn.BackgroundColor3 = CurrentTheme.PanelLight
	CloseBtn.Parent = Controls
	createCorner(CloseBtn, 8)
	registerThemeable(CloseBtn, {BackgroundColor3 = "PanelLight", TextColor3 = "Accent"})

	local function addHover(btn)
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Primary, TextColor3 = Color3.new(1,1,1)}):Play()
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
		animateWindow(isMinimized and UDim2.new(0,690,0,50) or UDim2.new(0,690,0,460))
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
		animateWindow(isMinimized and UDim2.new(0,690,0,50) or UDim2.new(0,690,0,460))
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

	-- ==============================
	-- SIDEBAR TAB CONTAINER (Vertical)
	-- ==============================
	local TabContainer = Instance.new("Frame")
	TabContainer.Name = "TabContainer"
	TabContainer.Size = UDim2.new(0, 150, 1, -50)  -- left sidebar, full height below topbar
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
	TabList.FillDirection = Enum.FillDirection.Vertical  -- vertical sidebar
	TabList.SortOrder = Enum.SortOrder.LayoutOrder
	TabList.Padding = UDim.new(0, 2)
	TabList.Parent = TabContainer

	-- ==============================
	-- CONTENT AREA (right of sidebar)
	-- ==============================
	local PageContainer = Instance.new("Frame")
	PageContainer.Size = UDim2.new(1, -150, 1, -50)   -- fill remaining width, below topbar
	PageContainer.Position = UDim2.new(0, 150, 0, 50)
	PageContainer.BackgroundTransparency = 1
	PageContainer.Active = true
	PageContainer.ClipsDescendants = true
	PageContainer.Parent = MainFrame

	local Pages = {}
	local Tabs = {}

	local function resizeTabs()
		-- Not needed for vertical sidebar; kept for compatibility but does nothing.
	end

	local function CreateTabInternal(tabName, layoutOrder)
		local TabSetup = {}

		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(1, 0, 0, 40)  -- full width, fixed height
		TabBtn.Text = "  " .. tabName          -- small padding
		TabBtn.Font = Enum.Font.GothamBold
		TabBtn.TextSize = 13
		TabBtn.TextColor3 = CurrentTheme.SubTextColor
		TabBtn.TextXAlignment = Enum.TextXAlignment.Left
		TabBtn.BackgroundTransparency = 1
		TabBtn.LayoutOrder = layoutOrder or #Tabs
		TabBtn.Parent = TabContainer
		registerThemeable(TabBtn, {TextColor3 = "SubTextColor"})

		-- Indicator: vertical bar on left side
		local Indicator = Instance.new("Frame")
		Indicator.Size = UDim2.new(0, 3, 1, 0)
		Indicator.Position = UDim2.new(0, 0, 0, 0)
		Indicator.BackgroundColor3 = CurrentTheme.Primary
		Indicator.BackgroundTransparency = 1   -- hidden by default
		Indicator.BorderSizePixel = 0
		Indicator.Parent = TabBtn
		registerThemeable(Indicator, {BackgroundColor3 = "Primary"})

		local PageScroll = Instance.new("ScrollingFrame")
		PageScroll.Size = UDim2.new(1,0,1,0)
		PageScroll.BackgroundTransparency = 1
		PageScroll.BorderSizePixel = 0
		PageScroll.ScrollBarThickness = 4
		PageScroll.ScrollBarImageColor3 = CurrentTheme.Primary
		PageScroll.Active = true
		PageScroll.Visible = false
		PageScroll.CanvasSize = UDim2.new(0,0,0,0)
		PageScroll.Parent = PageContainer

		local PageLayout = Instance.new("UIListLayout")
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.Padding = UDim.new(0,12)
		PageLayout.Parent = PageScroll
		Instance.new("UIPadding", PageScroll).PaddingTop = UDim.new(0,12)
		Instance.new("UIPadding", PageScroll).PaddingLeft = UDim.new(0,15)
		Instance.new("UIPadding", PageScroll).PaddingRight = UDim.new(0,15)

		PageScroll.ChildAdded:Connect(function(child)
			if child:IsA("GuiObject") then
				task.wait()
				PageScroll.CanvasSize = UDim2.new(0,0,0,PageLayout.AbsoluteContentSize.Y + 20)
			end
		end)

		TabBtn.MouseEnter:Connect(function()
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
			for _,p in pairs(Pages) do p.Visible = false end
			for _,t in pairs(Tabs) do
				-- Hide all indicators
				TweenService:Create(t.Indicator, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
				TweenService:Create(t.Btn, TweenInfo.new(0.3), {TextColor3 = CurrentTheme.SubTextColor}):Play()
			end
			PageScroll.Visible = true
			-- Show this indicator
			TweenService:Create(Indicator, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
			TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = Color3.new(1,1,1)}):Play()
			playClickSound()
		end)

		table.insert(Pages, PageScroll)
		table.insert(Tabs, {Btn = TabBtn, Indicator = Indicator})
		resizeTabs()

		-- Activate first tab
		if #Pages == 1 then
			PageScroll.Visible = true
			Indicator.BackgroundTransparency = 0
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
			ToggleFrame.Size = UDim2.new(1,0,0,50)
			ToggleFrame.BackgroundColor3 = CurrentTheme.PanelLight
			ToggleFrame.Active = true
			ToggleFrame.Parent = PageScroll
			createCorner(ToggleFrame,8)
			createStroke(ToggleFrame, CurrentTheme.Primary, 1)
			registerThemeable(ToggleFrame, {BackgroundColor3 = "PanelLight"})

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1,-80,1,0)
			Label.Position = UDim2.new(0,15,0,0)
			Label.Text = name
			Label.Font = Enum.Font.GothamSemibold
			Label.TextSize = 14
			Label.TextColor3 = CurrentTheme.TextColor
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.BackgroundTransparency = 1
			Label.Parent = ToggleFrame
			registerThemeable(Label, {TextColor3 = "TextColor"})

			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(0,50,0,26)
			Btn.Position = UDim2.new(1,-65,0.5,-13)
			Btn.BackgroundColor3 = CurrentTheme.Panel
			Btn.Text = ""
			Btn.Parent = ToggleFrame
			createCorner(Btn,13)
			registerThemeable(Btn, {BackgroundColor3 = "Panel"})

			local Circle = Instance.new("Frame")
			Circle.Size = UDim2.new(0,20,0,20)
			Circle.Position = UDim2.new(0,3,0.5,-10)
			Circle.BackgroundColor3 = Color3.new(1,1,1)
			Circle.Parent = Btn
			createCorner(Circle,10)

			local state = false
			ConfigValues[id] = state
			registerConfig(id, function(val)
				state = val
				local gPos = state and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)
				local gCol = state and CurrentTheme.Primary or CurrentTheme.Panel
				TweenService:Create(Circle, TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Position = gPos}):Play()
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
			ToggleFrame.Size = UDim2.new(1,0,0,50)
			ToggleFrame.BackgroundColor3 = CurrentTheme.PanelLight
			ToggleFrame.Active = true
			ToggleFrame.Parent = PageScroll
			createCorner(ToggleFrame,8)
			createStroke(ToggleFrame, Color3.fromRGB(255, 215, 0), 1.5)
			registerThemeable(ToggleFrame, {BackgroundColor3 = "PanelLight"})

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1,-110,1,0)
			Label.Position = UDim2.new(0,15,0,0)
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
			Badge.TextColor3 = Color3.new(0,0,0)
			Badge.Parent = ToggleFrame
			createCorner(Badge, 4)

			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(0,50,0,26)
			Btn.Position = UDim2.new(1,-65,0.5,-13)
			Btn.BackgroundColor3 = CurrentTheme.Panel
			Btn.Text = ""
			Btn.Parent = ToggleFrame
			createCorner(Btn,13)
			registerThemeable(Btn, {BackgroundColor3 = "Panel"})

			local Circle = Instance.new("Frame")
			Circle.Size = UDim2.new(0,20,0,20)
			Circle.Position = UDim2.new(0,3,0.5,-10)
			Circle.BackgroundColor3 = Color3.new(1,1,1)
			Circle.Parent = Btn
			createCorner(Circle,10)

			local state = false
			ConfigValues[id] = state
			registerConfig(id, function(val)
				state = val
				local gPos = state and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)
				local gCol = state and Color3.fromRGB(255, 215, 0) or CurrentTheme.Panel
				TweenService:Create(Circle, TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Position = gPos}):Play()
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
			BoxFrame.Size = UDim2.new(1,0,0,48)
			BoxFrame.BackgroundColor3 = CurrentTheme.PanelLight
			BoxFrame.Active = true
			BoxFrame.Parent = PageScroll
			createCorner(BoxFrame,8)
			createStroke(BoxFrame, CurrentTheme.Primary, 1)
			registerThemeable(BoxFrame, {BackgroundColor3 = "PanelLight"})

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(0.5,0,1,0)
			Label.Position = UDim2.new(0,15,0,0)
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
			DropdownFrame.Size = UDim2.new(1,0,0,48)
			DropdownFrame.BackgroundColor3 = CurrentTheme.PanelLight
			DropdownFrame.Active = true
			DropdownFrame.ClipsDescendants = true
			DropdownFrame.Parent = PageScroll
			createCorner(DropdownFrame,8)
			createStroke(DropdownFrame, CurrentTheme.Primary, 1)
			registerThemeable(DropdownFrame, {BackgroundColor3 = "PanelLight"})

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1,-30,0,48)
			Label.Position = UDim2.new(0,15,0,0)
			Label.Text = name .. " : " .. tostring(default)
			Label.Font = Enum.Font.GothamSemibold
			Label.TextSize = 14
			Label.TextColor3 = CurrentTheme.TextColor
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.BackgroundTransparency = 1
			Label.Parent = DropdownFrame
			registerThemeable(Label, {TextColor3 = "TextColor"})

			local ToggleBtn = Instance.new("TextButton")
			ToggleBtn.Size = UDim2.new(1,0,0,48)
			ToggleBtn.BackgroundTransparency = 1
			ToggleBtn.Text = ""
			ToggleBtn.Parent = DropdownFrame

			local OptionContainer = Instance.new("Frame")
			OptionContainer.Size = UDim2.new(1,0,1,-48)
			OptionContainer.Position = UDim2.new(0,0,0,48)
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
					OptBtn.Size = UDim2.new(1,0,0,34)
					OptBtn.BackgroundColor3 = CurrentTheme.Panel
					OptBtn.Text = "  " .. option
					OptBtn.Font = Enum.Font.Gotham
					OptBtn.TextSize = 13
					OptBtn.TextColor3 = CurrentTheme.SubTextColor
					OptBtn.TextXAlignment = Enum.TextXAlignment.Left
					OptBtn.Parent = OptionContainer
					createCorner(OptBtn,6)
					registerThemeable(OptBtn, {BackgroundColor3 = "Panel", TextColor3 = "SubTextColor"})

					OptBtn.MouseButton1Click:Connect(function()
						selectedValue = option
						Label.Text = name .. " : " .. option
						ConfigValues[id] = option
						isDropped = false
						TweenService:Create(DropdownFrame, TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,48)}):Play()
						TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = CurrentTheme.TextColor}):Play()
						callback(selectedValue)
						playClickSound()
					end)

					OptBtn.MouseEnter:Connect(function()
						TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.PrimaryDark, TextColor3 = Color3.new(1,1,1)}):Play()
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
				for _,v in pairs(OptionContainer:GetChildren()) do if v:IsA("TextButton") then childCount = childCount + 1 end end
				local targetHeight = isDropped and (48 + (childCount * 34)) or 48
				TweenService:Create(DropdownFrame, TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,targetHeight)}):Play()
				TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = isDropped and CurrentTheme.Primary or CurrentTheme.TextColor}):Play()
				playClickSound()
			end)

			local DropdownAPI = {}
			function DropdownAPI:Refresh(newOptions)
				BuildOptions(newOptions)
				if isDropped then
					local targetHeight = 48 + (#newOptions * 34)
					TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1,0,0,targetHeight)}):Play()
				end
			end
			return DropdownAPI
		end

		function TabSetup:CreateSlider(name, min, max, default, callback)
			local id = generateId("slider_" .. name)
			local SliderFrame = Instance.new("Frame")
			SliderFrame.Size = UDim2.new(1,0,0,65)
			SliderFrame.BackgroundColor3 = CurrentTheme.PanelLight
			SliderFrame.Active = true
			SliderFrame.Parent = PageScroll
			createCorner(SliderFrame,8)
			createStroke(SliderFrame, CurrentTheme.Primary, 1)
			registerThemeable(SliderFrame, {BackgroundColor3 = "PanelLight"})

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1,-50,0,25)
			Label.Position = UDim2.new(0,15,0,8)
			Label.Text = name
			Label.Font = Enum.Font.GothamSemibold
			Label.TextSize = 14
			Label.TextColor3 = CurrentTheme.TextColor
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.BackgroundTransparency = 1
			Label.Parent = SliderFrame
			registerThemeable(Label, {TextColor3 = "TextColor"})

			local ValueText = Instance.new("TextLabel")
			ValueText.Size = UDim2.new(0,50,0,25)
			ValueText.Position = UDim2.new(1,-65,0,8)
			ValueText.Text = tostring(default)
			ValueText.Font = Enum.Font.GothamBold
			ValueText.TextSize = 14
			ValueText.TextColor3 = CurrentTheme.Primary
			ValueText.TextXAlignment = Enum.TextXAlignment.Right
			ValueText.BackgroundTransparency = 1
			ValueText.Parent = SliderFrame
			registerThemeable(ValueText, {TextColor3 = "Primary"})

			local Bar = Instance.new("TextButton")
			Bar.Size = UDim2.new(1,-30,0,8)
			Bar.Position = UDim2.new(0,15,0,42)
			Bar.BackgroundColor3 = CurrentTheme.Panel
			Bar.Text = ""
			Bar.Parent = SliderFrame
			createCorner(Bar,4)
			registerThemeable(Bar, {BackgroundColor3 = "Panel"})

			local Fill = Instance.new("Frame")
			local defaultPercent = (default - min) / (max - min)
			Fill.Size = UDim2.new(defaultPercent,0,1,0)
			Fill.BackgroundColor3 = CurrentTheme.Primary
			Fill.Parent = Bar
			createCorner(Fill,4)
			registerThemeable(Fill, {BackgroundColor3 = "Primary"})

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
					Fill.Size = UDim2.new(percent,0,1,0)
					Knob.Position = UDim2.new(percent, -7, 0.5, -7)
					ValueText.Text = tostring(currentValue)
					callback(currentValue)
				end
			end)
		end

		function TabSetup:CreateButton(name, callback)
			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1,0,0,42)
			Btn.BackgroundColor3 = CurrentTheme.PanelLight
			Btn.Text = name
			Btn.Font = Enum.Font.GothamBold
			Btn.TextSize = 15
			Btn.TextColor3 = CurrentTheme.TextColor
			Btn.Active = true
			Btn.Parent = PageScroll
			createCorner(Btn,8)
			createStroke(Btn, CurrentTheme.Primary, 1)
			registerThemeable(Btn, {BackgroundColor3 = "PanelLight", TextColor3 = "TextColor"})

			local function pressAnim()
				TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.98,0,0,40), BackgroundColor3 = CurrentTheme.Primary}):Play()
				task.wait(0.1)
				TweenService:Create(Btn, TweenInfo.new(0.2), {Size = UDim2.new(1,0,0,42), BackgroundColor3 = CurrentTheme.PanelLight}):Play()
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
			Div.Parent = PageScroll
			registerThemeable(Div, {BackgroundColor3 = "Primary"})
		end

		function TabSetup:CreateNotification(title, message, duration)
			duration = duration or 2
			local Notif = Instance.new("Frame")
			Notif.Size = UDim2.new(0, 250, 0, 70)
			Notif.Position = UDim2.new(1, 10, 1, -80)
			Notif.BackgroundColor3 = CurrentTheme.Panel
			Notif.Active = true
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

	-- ══════════════════════════════════════
	--  MENU TAB (integrated at end)
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

		local function addHover(btn)
			btn.MouseEnter:Connect(function()
				TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Primary, TextColor3 = Color3.new(1,1,1)}):Play()
			end)
			btn.MouseLeave:Connect(function()
				local origColor = btn == BtnNo and CurrentTheme.SubTextColor or Color3.new(1,1,1)
				local origBg = btn == BtnNo and CurrentTheme.PanelLight or CurrentTheme.Primary
				TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = origBg, TextColor3 = origColor}):Play()
			end)
		end

		BtnYes.MouseButton1Click:Connect(function()
			if setclipboard then setclipboard("https://discord.gg/XjfW7N84jT") end
			BtnYes.Text = "Copied!"; BtnYes.BackgroundColor3 = Color3.fromRGB(40,200,100)
			TweenService:Create(BtnYes, TweenInfo.new(0.15), {Size = UDim2.new(0,155,0,36)}):Play()
			task.wait(1); ClosePrompt()
		end)
		BtnNo.MouseButton1Click:Connect(ClosePrompt)
		addHover(BtnYes)
		addHover(BtnNo)
	end

	return WindowSetup
end

return EmloxaLibrary
