-- =========================================================================
-- EMLOXA WARE PREMIUM UI v17 (NEW DESIGN INTEGRATION)
-- SIDEBAR NAVIGATION, MODERN LOOK, FULL COMPATIBILITY
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
--  ULTRA-RANDOM OBFUSCATED STRING GEN (placeholder - no longer used)
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
--  NAME SPOOF REMOVED - No metatable hooks
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

	-- Open icon (minimized icon) kept but redesigned
	local OpenIconFrame = Instance.new("Frame")
	OpenIconFrame.Name = "OpenIconFrame"
	OpenIconFrame.Size = UDim2.new(0, 55, 0, 55)
	OpenIconFrame.Position = UDim2.new(0, 15, 0, 75)
	OpenIconFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
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
	OpenIcon.Image = "rbxassetid://140536429992333" -- new logo
	OpenIcon.ScaleType = Enum.ScaleType.Fit
	OpenIcon.Active = true
	OpenIcon.Parent = OpenIconFrame
	createCorner(OpenIcon, 14)

	RunService.RenderStepped:Connect(function()
		iconStroke.Color = Color3.fromHSV(tick()*0.3 % 1, 0.9, 1)
	end)

	-- ==============================
	-- LOADING SCREEN (new design)
	-- ==============================
	local LoadingFrame = Instance.new("Frame")
	LoadingFrame.Name = "LoadingFrame"
	LoadingFrame.Size = UDim2.new(0, 360, 0, 300) -- fixed size loading popup
	LoadingFrame.Position = UDim2.new(0.5, -180, 0.5, -150)
	LoadingFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
	LoadingFrame.Active = true
	LoadingFrame.Parent = HubGui
	createCorner(LoadingFrame, 16)
	createStroke(LoadingFrame, CurrentTheme.Primary, 2)

	local LoadLogoContainer = Instance.new("Frame")
	LoadLogoContainer.Size = UDim2.new(0, 120, 0, 120)
	LoadLogoContainer.Position = UDim2.new(0.5, -60, 0.2, 0)
	LoadLogoContainer.BackgroundTransparency = 1
	LoadLogoContainer.Parent = LoadingFrame

	local LoadLogo = Instance.new("ImageLabel")
	LoadLogo.Size = UDim2.new(1,0,1,0)
	LoadLogo.BackgroundTransparency = 1
	LoadLogo.Image = "rbxassetid://140536429992333"
	LoadLogo.ScaleType = Enum.ScaleType.Fit
	LoadLogo.Parent = LoadLogoContainer

	local LoadName = Instance.new("TextLabel")
	LoadName.Size = UDim2.new(1,0,0,30)
	LoadName.Position = UDim2.new(0,0,0.7,0)
	LoadName.BackgroundTransparency = 1
	LoadName.Text = "Emloxa Ware"
	LoadName.Font = Enum.Font.GothamBlack
	LoadName.TextSize = 24
	LoadName.TextColor3 = Color3.new(1,1,1)
	LoadName.Parent = LoadingFrame

	local LoadInfo = Instance.new("TextLabel")
	LoadInfo.Size = UDim2.new(1,0,0,20)
	LoadInfo.Position = UDim2.new(0,0,0.82,0)
	LoadInfo.BackgroundTransparency = 1
	LoadInfo.Text = "Loading"
	LoadInfo.Font = Enum.Font.GothamSemibold
	LoadInfo.TextSize = 14
	LoadInfo.TextColor3 = Color3.fromRGB(200,200,200)
	LoadInfo.Parent = LoadingFrame

	local LoadingBar = Instance.new("Frame")
	LoadingBar.Size = UDim2.new(0.87, 0, 0.09, 0)
	LoadingBar.Position = UDim2.new(0.065, 0, 0.92, 0)
	LoadingBar.BackgroundColor3 = Color3.fromRGB(50,50,50)
	LoadingBar.Parent = LoadingFrame
	createCorner(LoadingBar, 12)

	local NotLoaded = Instance.new("Frame")
	NotLoaded.Size = UDim2.new(0.1,0,1,0)
	NotLoaded.BackgroundColor3 = Color3.fromRGB(51, 89, 0)
	NotLoaded.BorderSizePixel = 0
	NotLoaded.Parent = LoadingBar
	createCorner(NotLoaded, 12)

	local Fullyloaded = Instance.new("Frame")
	Fullyloaded.Size = UDim2.new(0,0,1,0)
	Fullyloaded.BackgroundColor3 = Color3.fromRGB(51, 255, 0)
	Fullyloaded.BorderSizePixel = 0
	Fullyloaded.Visible = false
	Fullyloaded.Parent = LoadingBar
	createCorner(Fullyloaded, 12)

	local loadingConnections = {}
	local spinnerDots = {}
	local spinnerFrame = Instance.new("Frame")
	spinnerFrame.Size = UDim2.new(0, 50, 0, 50)
	spinnerFrame.Position = UDim2.new(0.5, -25, 0.45, 0)
	spinnerFrame.BackgroundTransparency = 1
	spinnerFrame.Parent = LoadingFrame
	for i=1,8 do
		local dot = Instance.new("Frame")
		dot.Size = UDim2.new(0,6,0,6)
		dot.BackgroundColor3 = CurrentTheme.Primary
		dot.Position = UDim2.new(0.5,-3,0,0)
		dot.AnchorPoint = Vector2.new(0.5,0.5)
		dot.Rotation = (i-1)*45
		dot.Parent = spinnerFrame
		createCorner(dot,3)
		local conn = RunService.RenderStepped:Connect(function()
			if dot and dot.Parent then
				local t = tick()*4 + i*0.5
				dot.BackgroundTransparency = 0.3 + math.abs(math.sin(t))*0.3
			end
		end)
		table.insert(loadingConnections, conn)
		table.insert(spinnerDots, dot)
	end

	task.wait(1.8)
	-- Simulate loading progress
	for _, conn in ipairs(loadingConnections) do conn:Disconnect() end
	for _, dot in ipairs(spinnerDots) do dot:Destroy() end
	NotLoaded:TweenSize(UDim2.new(1,0,1,0), "Out", "Quad", 0.5, true)
	task.wait(0.5)
	Fullyloaded.Visible = true
	task.wait(0.3)
	TweenService:Create(LoadingFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
	TweenService:Create(LoadLogo, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
	TweenService:Create(LoadName, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
	TweenService:Create(LoadInfo, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
	task.wait(0.6)
	LoadingFrame:Destroy()

	-- ==============================
	-- MAIN FRAME (new design - fixed 690x460)
	-- ==============================
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 690, 0, 460)
	MainFrame.Position = UDim2.new(0.5, -345, 0.5, -230)
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true
	MainFrame.Active = true
	MainFrame.BackgroundColor3 = Color3.fromRGB(31, 31, 31)
	MainFrame.Parent = HubGui
	createCorner(MainFrame, 14)
	createStroke(MainFrame, CurrentTheme.Primary, 2)
	createShadow(MainFrame, UDim2.new(1,24,1,24), -12, 0.6)
	registerThemeable(MainFrame, {BackgroundColor3 = "Background"})

	-- ==============================
	-- TOP BAR (title, logo, time, controls)
	-- ==============================
	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Size = UDim2.new(1,0,0,88) -- 88px height
	TopBar.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
	TopBar.BorderSizePixel = 0
	TopBar.Active = true
	TopBar.Parent = MainFrame
	createCorner(TopBar, 14)
	registerThemeable(TopBar, {BackgroundColor3 = "Panel"})

	-- Logo on top left
	local Logo = Instance.new("ImageLabel")
	Logo.Size = UDim2.new(0, 30, 0, 30)
	Logo.Position = UDim2.new(0, 12, 0.5, -15)
	Logo.BackgroundTransparency = 1
	Logo.Image = "rbxassetid://140536429992333"
	Logo.ScaleType = Enum.ScaleType.Fit
	Logo.Parent = TopBar

	local Title = Instance.new("TextLabel")
	Title.Text = "EMLOXA WARE"
	Title.Font = Enum.Font.GothamBlack
	Title.TextSize = 16
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Size = UDim2.new(0, 200, 1, 0)
	Title.Position = UDim2.new(0, 50, 0, 0)
	Title.BackgroundTransparency = 1
	Title.TextColor3 = Color3.new(1,1,1)
	Title.Parent = TopBar

	-- Time Container (added per user request)
	local TimeContainer = Instance.new("Frame")
	TimeContainer.Size = UDim2.new(0, 200, 0, 32)
	TimeContainer.Position = UDim2.new(0.5, -100, 0.5, -16)
	TimeContainer.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
	TimeContainer.Parent = TopBar
	createCorner(TimeContainer, 8)
	createStroke(TimeContainer, CurrentTheme.Primary, 1)
	registerThemeable(TimeContainer, {BackgroundColor3 = "PanelLight"})

	local TimeLabel = Instance.new("TextLabel")
	TimeLabel.Size = UDim2.new(1, -30, 1, 0)
	TimeLabel.Position = UDim2.new(0, 8, 0, 0)
	TimeLabel.Text = "02:00:00"
	TimeLabel.Font = Enum.Font.GothamBold
	TimeLabel.TextSize = 12
	TimeLabel.TextColor3 = CurrentTheme.Primary
	TimeLabel.TextXAlignment = Enum.TextXAlignment.Center
	TimeLabel.BackgroundTransparency = 1
	TimeLabel.Parent = TimeContainer
	registerThemeable(TimeLabel, {TextColor3 = "Primary"})

	local PlusBtn = Instance.new("TextButton")
	PlusBtn.Size = UDim2.new(0, 24, 0, 24)
	PlusBtn.Position = UDim2.new(1, -28, 0.5, -12)
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

	-- Controls: minimize and close
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
	MinBtn.BackgroundColor3 = Color3.fromRGB(91,91,91)
	MinBtn.Parent = Controls
	createCorner(MinBtn, 16)
	registerThemeable(MinBtn, {BackgroundColor3 = "PanelLight"})

	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0,32,0,32)
	CloseBtn.Position = UDim2.new(0,50,0.5,-16)
	CloseBtn.Text = "X"
	CloseBtn.Font = Enum.Font.GothamBlack
	CloseBtn.TextSize = 18
	CloseBtn.TextColor3 = Color3.new(1,1,1)
	CloseBtn.BackgroundColor3 = Color3.fromRGB(109,0,0)
	CloseBtn.Parent = Controls
	createCorner(CloseBtn, 16)
	registerThemeable(CloseBtn, {BackgroundColor3 = "Accent", TextColor3 = "TextColor"})

	local function addHover(btn)
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Primary, TextColor3 = Color3.new(1,1,1)}):Play()
		end)
		btn.MouseLeave:Connect(function()
			local origColor = btn == CloseBtn and Color3.fromRGB(109,0,0) or Color3.fromRGB(91,91,91)
			local origText = Color3.new(1,1,1)
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = origColor, TextColor3 = origText}):Play()
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
		animateWindow(isMinimized and UDim2.new(0,690,0,88) or UDim2.new(0,690,0,460))
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
		animateWindow(isMinimized and UDim2.new(0,690,0,88) or UDim2.new(0,690,0,460))
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
	-- SIDEBAR (TabContainer)
	-- ==============================
	local TabContainer = Instance.new("Frame")
	TabContainer.Name = "TabContainer"
	TabContainer.Size = UDim2.new(0, 162, 1, -88) -- width 162, full height below topbar
	TabContainer.Position = UDim2.new(0, 0, 0, 88)
	TabContainer.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
	TabContainer.BorderSizePixel = 0
	TabContainer.Active = true
	TabContainer.Parent = MainFrame
	createCorner(TabContainer, 10)
	registerThemeable(TabContainer, {BackgroundColor3 = "Panel"})

	local TabList = Instance.new("UIListLayout")
	TabList.FillDirection = Enum.FillDirection.Vertical
	TabList.SortOrder = Enum.SortOrder.LayoutOrder
	TabList.Padding = UDim.new(0, 2)
	TabList.Parent = TabContainer

	-- ==============================
	-- CONTENT AREA (PageContainer)
	-- ==============================
	local PageContainer = Instance.new("Frame")
	PageContainer.Size = UDim2.new(1, -170, 1, -96) -- 170 left margin (162 sidebar + 8 gap), 96 top (88 topbar + 8 margin)
	PageContainer.Position = UDim2.new(0, 170, 0, 96)
	PageContainer.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
	PageContainer.BorderSizePixel = 0
	PageContainer.Active = true
	PageContainer.ClipsDescendants = true
	PageContainer.Parent = MainFrame
	createCorner(PageContainer, 10)
	registerThemeable(PageContainer, {BackgroundColor3 = "Panel"})

	local Pages = {}
	local Tabs = {}

	local function resizeTabs()
		-- Not needed
	end

	local function CreateTabInternal(tabName, layoutOrder)
		local TabSetup = {}

		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(1, 0, 0, 40)
		TabBtn.Text = "  " .. tabName
		TabBtn.Font = Enum.Font.GothamBold
		TabBtn.TextSize = 13
		TabBtn.TextColor3 = Color3.fromRGB(200,200,200)
		TabBtn.TextXAlignment = Enum.TextXAlignment.Left
		TabBtn.BackgroundTransparency = 1
		TabBtn.LayoutOrder = layoutOrder or #Tabs
		TabBtn.Parent = TabContainer
		registerThemeable(TabBtn, {TextColor3 = "SubTextColor"})

		local Indicator = Instance.new("Frame")
		Indicator.Size = UDim2.new(1, 0, 0, 2)
		Indicator.Position = UDim2.new(0, 0, 1, 0)
		Indicator.BackgroundColor3 = CurrentTheme.Primary
		Indicator.BackgroundTransparency = 1
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
				TweenService:Create(TabBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200,200,200)}):Play()
			end
		end)

		TabBtn.MouseButton1Click:Connect(function()
			for _,p in pairs(Pages) do p.Visible = false end
			for _,t in pairs(Tabs) do
				TweenService:Create(t.Indicator, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
				TweenService:Create(t.Btn, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(200,200,200)}):Play()
			end
			PageScroll.Visible = true
			TweenService:Create(Indicator, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
			TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = Color3.new(1,1,1)}):Play()
			playClickSound()
		end)

		table.insert(Pages, PageScroll)
		table.insert(Tabs, {Btn = TabBtn, Indicator = Indicator})
		resizeTabs()

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

		-- Reuse all UI element creators (Toggle, PremiumToggle, Textbox, Dropdown, Slider, Button, Divider, Notification) from previous version
		-- (I'll include a compact version of them to avoid repetition, but keeping them identical to your existing code)
		function TabSetup:CreateToggle(name, callback)
			local id = generateId("toggle_" .. name)
			local ToggleFrame = Instance.new("Frame")
			ToggleFrame.Size = UDim2.new(1,0,0,50)
			ToggleFrame.BackgroundColor3 = Color3.fromRGB(30,30,35)
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
			Label.TextColor3 = Color3.new(1,1,1)
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.BackgroundTransparency = 1
			Label.Parent = ToggleFrame
			registerThemeable(Label, {TextColor3 = "TextColor"})

			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(0,50,0,26)
			Btn.Position = UDim2.new(1,-65,0.5,-13)
			Btn.BackgroundColor3 = Color3.fromRGB(50,50,55)
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
				local gCol = state and CurrentTheme.Primary or Color3.fromRGB(50,50,55)
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
			ToggleFrame.BackgroundColor3 = Color3.fromRGB(30,30,35)
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
			Label.TextColor3 = Color3.new(1,1,1)
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
			Btn.BackgroundColor3 = Color3.fromRGB(50,50,55)
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
				local gCol = state and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(50,50,55)
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
			BoxFrame.BackgroundColor3 = Color3.fromRGB(30,30,35)
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
			Label.TextColor3 = Color3.new(1,1,1)
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.BackgroundTransparency = 1
			Label.Parent = BoxFrame
			registerThemeable(Label, {TextColor3 = "TextColor"})

			local TextBoxBg = Instance.new("Frame")
			TextBoxBg.Size = UDim2.new(0.45, 0, 0, 32)
			TextBoxBg.Position = UDim2.new(1, -15, 0.5, -16)
			TextBoxBg.AnchorPoint = Vector2.new(1, 0)
			TextBoxBg.BackgroundColor3 = Color3.fromRGB(50,50,55)
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
			TxtBox.TextColor3 = Color3.new(1,1,1)
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
			DropdownFrame.BackgroundColor3 = Color3.fromRGB(30,30,35)
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
			Label.TextColor3 = Color3.new(1,1,1)
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
					OptBtn.BackgroundColor3 = Color3.fromRGB(50,50,55)
					OptBtn.Text = "  " .. option
					OptBtn.Font = Enum.Font.Gotham
					OptBtn.TextSize = 13
					OptBtn.TextColor3 = Color3.fromRGB(200,200,200)
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
						TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = Color3.new(1,1,1)}):Play()
						callback(selectedValue)
						playClickSound()
					end)

					OptBtn.MouseEnter:Connect(function()
						TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.PrimaryDark, TextColor3 = Color3.new(1,1,1)}):Play()
					end)
					OptBtn.MouseLeave:Connect(function()
						TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50,50,55), TextColor3 = Color3.fromRGB(200,200,200)}):Play()
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
				TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = isDropped and CurrentTheme.Primary or Color3.new(1,1,1)}):Play()
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
			SliderFrame.BackgroundColor3 = Color3.fromRGB(30,30,35)
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
			Label.TextColor3 = Color3.new(1,1,1)
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
			Bar.BackgroundColor3 = Color3.fromRGB(50,50,55)
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
			Btn.BackgroundColor3 = Color3.fromRGB(30,30,35)
			Btn.Text = name
			Btn.Font = Enum.Font.GothamBold
			Btn.TextSize = 15
			Btn.TextColor3 = Color3.new(1,1,1)
			Btn.Active = true
			Btn.Parent = PageScroll
			createCorner(Btn,8)
			createStroke(Btn, CurrentTheme.Primary, 1)
			registerThemeable(Btn, {BackgroundColor3 = "PanelLight", TextColor3 = "TextColor"})

			local function pressAnim()
				TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.98,0,0,40), BackgroundColor3 = CurrentTheme.Primary}):Play()
				task.wait(0.1)
				TweenService:Create(Btn, TweenInfo.new(0.2), {Size = UDim2.new(1,0,0,42), BackgroundColor3 = Color3.fromRGB(30,30,35)}):Play()
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
				TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30,30,35)}):Play()
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
			Notif.BackgroundColor3 = Color3.fromRGB(31,31,31)
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
			MsgLabel.TextColor3 = Color3.new(1,1,1)
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

	-- Recharge modal (TimeAdd) adapted from user design
	local function OpenRechargeModal()
		local Overlay = Instance.new("Frame")
		Overlay.Size = UDim2.new(1,0,1,0)
		Overlay.BackgroundColor3 = Color3.new(0,0,0)
		Overlay.BackgroundTransparency = 0.5
		Overlay.Active = true
		Overlay.ZIndex = 100
		Overlay.Parent = HubGui

		local TimeAdd = Instance.new("Frame")
		TimeAdd.Size = UDim2.new(0, 360, 0, 300) -- Fixed size like loading
		TimeAdd.Position = UDim2.new(0.5, -180, 0.5, -150)
		TimeAdd.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
		TimeAdd.ZIndex = 101
		TimeAdd.Parent = Overlay
		createCorner(TimeAdd, 12)
		createStroke(TimeAdd, CurrentTheme.Primary, 2)

		-- Logo and title
		local UiLogo = Instance.new("ImageLabel")
		UiLogo.Size = UDim2.new(0, 40, 0, 40)
		UiLogo.Position = UDim2.new(0.24, 0, 0.035, 0)
		UiLogo.BackgroundTransparency = 1
		UiLogo.Image = "rbxassetid://140536429992333"
		UiLogo.ScaleType = Enum.ScaleType.Fit
		UiLogo.ZIndex = 102
		UiLogo.Parent = TimeAdd

		local NameLabel = Instance.new("TextLabel")
		NameLabel.Size = UDim2.new(0.69, 0, 0.14, 0)
		NameLabel.Position = UDim2.new(0.21, 0, 0.016, 0)
		NameLabel.BackgroundTransparency = 1
		NameLabel.Text = "Emloxa Ware"
		NameLabel.Font = Enum.Font.GothamBlack
		NameLabel.TextSize = 22
		NameLabel.TextColor3 = Color3.new(1,1,1)
		NameLabel.ZIndex = 102
		NameLabel.Parent = TimeAdd

		local Line1 = Instance.new("Frame")
		Line1.Size = UDim2.new(1,0,0,2)
		Line1.Position = UDim2.new(0,0,0.156,0)
		Line1.BackgroundColor3 = Color3.new(1,1,1)
		Line1.ZIndex = 102
		Line1.Parent = TimeAdd

		-- Hour options
		local _1Hour = Instance.new("TextLabel")
		_1Hour.Size = UDim2.new(0.41,0,0.13,0)
		_1Hour.Position = UDim2.new(0.052,0,0.224,0)
		_1Hour.Text = "1 HOUR"
		_1Hour.Font = Enum.Font.Michroma
		_1Hour.TextScaled = true
		_1Hour.TextColor3 = Color3.new(1,1,1)
		_1Hour.BackgroundTransparency = 1
		_1Hour.ZIndex = 102
		_1Hour.Parent = TimeAdd

		local _5Hour = Instance.new("TextLabel")
		_5Hour.Size = UDim2.new(0.41,0,0.13,0)
		_5Hour.Position = UDim2.new(0.549,0,0.224,0)
		_5Hour.Text = "5 HOUR"
		_5Hour.Font = Enum.Font.Michroma
		_5Hour.TextScaled = true
		_5Hour.TextColor3 = Color3.new(1,1,1)
		_5Hour.BackgroundTransparency = 1
		_5Hour.ZIndex = 102
		_5Hour.Parent = TimeAdd

		local _10Hour = Instance.new("TextLabel")
		_10Hour.Size = UDim2.new(0.41,0,0.13,0)
		_10Hour.Position = UDim2.new(0.052,0,0.531,0)
		_10Hour.Text = "10 HOUR"
		_10Hour.Font = Enum.Font.Michroma
		_10Hour.TextScaled = true
		_10Hour.TextColor3 = Color3.new(1,1,1)
		_10Hour.BackgroundTransparency = 1
		_10Hour.ZIndex = 102
		_10Hour.Parent = TimeAdd

		local LifetimeLabel = Instance.new("TextLabel")
		LifetimeLabel.Size = UDim2.new(0.41,0,0.13,0)
		LifetimeLabel.Position = UDim2.new(0.549,0,0.531,0)
		LifetimeLabel.Text = "LIFETIME"
		LifetimeLabel.Font = Enum.Font.GothamBlack
		LifetimeLabel.TextScaled = true
		LifetimeLabel.TextColor3 = Color3.fromRGB(241, 252, 24)
		LifetimeLabel.BackgroundTransparency = 1
		LifetimeLabel.ZIndex = 102
		LifetimeLabel.Parent = TimeAdd

		-- Prices and robux icons
		local _10RBX = Instance.new("TextButton")
		_10RBX.Size = UDim2.new(0.292,0,0.078,0)
		_10RBX.Position = UDim2.new(0.052,0,0.344,0)
		_10RBX.BackgroundColor3 = Color3.fromRGB(72,72,72)
		_10RBX.Text = "10"
		_10RBX.Font = Enum.Font.GothamBold
		_10RBX.TextColor3 = Color3.fromRGB(251,255,19)
		_10RBX.ZIndex = 103
		_10RBX.Parent = TimeAdd
		createCorner(_10RBX, 8)

		local _35RBX = Instance.new("TextButton")
		_35RBX.Size = UDim2.new(0.292,0,0.078,0)
		_35RBX.Position = UDim2.new(0.549,0,0.354,0)
		_35RBX.BackgroundColor3 = Color3.fromRGB(72,72,72)
		_35RBX.Text = "35"
		_35RBX.Font = Enum.Font.GothamBold
		_35RBX.TextColor3 = Color3.fromRGB(251,255,19)
		_35RBX.ZIndex = 103
		_35RBX.Parent = TimeAdd
		createCorner(_35RBX, 8)

		local _55RBX = Instance.new("TextButton")
		_55RBX.Size = UDim2.new(0.292,0,0.078,0)
		_55RBX.Position = UDim2.new(0.052,0,0.672,0)
		_55RBX.BackgroundColor3 = Color3.fromRGB(72,72,72)
		_55RBX.Text = "55"
		_55RBX.Font = Enum.Font.GothamBold
		_55RBX.TextColor3 = Color3.fromRGB(251,255,19)
		_55RBX.ZIndex = 103
		_55RBX.Parent = TimeAdd
		createCorner(_55RBX, 8)

		local _500RBX = Instance.new("TextButton")
		_500RBX.Size = UDim2.new(0.292,0,0.078,0)
		_500RBX.Position = UDim2.new(0.549,0,0.672,0)
		_500RBX.BackgroundColor3 = Color3.fromRGB(72,72,72)
		_500RBX.Text = "500"
		_500RBX.Font = Enum.Font.GothamBold
		_500RBX.TextColor3 = Color3.fromRGB(251,255,19)
		_500RBX.ZIndex = 103
		_500RBX.Parent = TimeAdd
		createCorner(_500RBX, 8)

		-- Robux icons
		for i, pos in ipairs({{0.362,0.333}, {0.859,0.343}, {0.362,0.661}, {0.859,0.661}}) do
			local icon = Instance.new("ImageLabel")
			icon.Size = UDim2.new(0.101,0,0.128,0)
			icon.Position = UDim2.new(pos[1],0,pos[2],0)
			icon.BackgroundTransparency = 1
			icon.Image = "rbxassetid://16893548283"
			icon.ScaleType = Enum.ScaleType.Fit
			icon.ZIndex = 102
			icon.Parent = TimeAdd
		end

		-- Sale labels
		local function addSaleLabel(text, posX, posY)
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(0.212,0,0.054,0)
			lbl.Position = UDim2.new(posX,0,posY,0)
			lbl.Rotation = -15
			lbl.BackgroundTransparency = 1
			lbl.Text = text
			lbl.Font = Enum.Font.GothamBlack
			lbl.TextScaled = true
			lbl.TextColor3 = Color3.fromRGB(252,0,4)
			lbl.ZIndex = 102
			lbl.Parent = TimeAdd
		end
		addSaleLabel("SAVE %15", 0.497, 0.193)
		addSaleLabel("SAVE %45", -0.0005, 0.495)
		addSaleLabel("SAVE %90", 0.497, 0.495)

		local popular = Instance.new("TextLabel")
		popular.Size = UDim2.new(0.212,0,0.072,0)
		popular.Position = UDim2.new(0.283,0,0.485,0)
		popular.Rotation = 15
		popular.BackgroundTransparency = 1
		popular.Text = "MOST POPULAR"
		popular.Font = Enum.Font.GothamBlack
		popular.TextScaled = true
		popular.TextColor3 = Color3.fromRGB(252,236,11)
		popular.ZIndex = 102
		popular.Parent = TimeAdd

		local CloseBtn = Instance.new("TextButton")
		CloseBtn.Size = UDim2.new(0.426,0,0.13,0)
		CloseBtn.Position = UDim2.new(0.283,0,0.833,0)
		CloseBtn.BackgroundTransparency = 1
		CloseBtn.Text = "Close"
		CloseBtn.Font = Enum.Font.GothamBold
		CloseBtn.TextColor3 = Color3.fromRGB(255,1,5)
		CloseBtn.ZIndex = 102
		CloseBtn.Parent = TimeAdd

		CloseBtn.MouseButton1Click:Connect(function() Overlay:Destroy() end)

		-- Buy button connections (reuse existing IDs)
		_10RBX.MouseButton1Click:Connect(function()
			pcall(function() MarketplaceService:PromptProductPurchase(LocalPlayer, 3613048307) end)
		end)
		_35RBX.MouseButton1Click:Connect(function()
			pcall(function() MarketplaceService:PromptProductPurchase(LocalPlayer, 3613048436) end)
		end)
		_55RBX.MouseButton1Click:Connect(function()
			pcall(function() MarketplaceService:PromptProductPurchase(LocalPlayer, 3613048476) end)
		end)
		_500RBX.MouseButton1Click:Connect(function()
			pcall(function() MarketplaceService:PromptGamePassPurchase(LocalPlayer, 1931252522) end)
		end)
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

	function WindowSetup:CreateTab(tabName)
		return CreateTabInternal(tabName, #Tabs + 1)
	end

	function WindowSetup:ShowDiscordPrompt()
		-- Keep original Discord prompt (unchanged)
		local PromptFrame = Instance.new("Frame")
		PromptFrame.Size = UDim2.new(0, 350, 0, 140)
		PromptFrame.Position = UDim2.new(1, 20, 1, -160)
		PromptFrame.BackgroundColor3 = Color3.fromRGB(31,31,31)
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
		PDesc.TextColor3 = Color3.new(1,1,1)
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
		BtnNo.BackgroundColor3 = Color3.fromRGB(91,91,91); BtnNo.Text = "No Thanks"
		BtnNo.Font = Enum.Font.Gotham; BtnNo.TextColor3 = Color3.new(1,1,1); BtnNo.TextSize = 13
		BtnNo.Parent = PromptFrame; createCorner(BtnNo,8)
		registerThemeable(BtnNo, {BackgroundColor3 = "PanelLight", TextColor3 = "TextColor"})

		TweenService:Create(PromptFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1,-370,1,-160)}):Play()

		local function ClosePrompt()
			TweenService:Create(PromptFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1,20,1,-160)}):Play()
			task.wait(0.5); PromptFrame:Destroy()
		end

		BtnYes.MouseButton1Click:Connect(function()
			if setclipboard then setclipboard("https://discord.gg/XjfW7N84jT") end
			BtnYes.Text = "Copied!"; BtnYes.BackgroundColor3 = Color3.fromRGB(40,200,100)
			TweenService:Create(BtnYes, TweenInfo.new(0.15), {Size = UDim2.new(0,155,0,36)}):Play()
			task.wait(1); ClosePrompt()
		end)
		BtnNo.MouseButton1Click:Connect(ClosePrompt)
		local function addHover(btn, originalBg, isCloseBtn)
			btn.MouseEnter:Connect(function()
				TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Primary, TextColor3 = Color3.new(1,1,1)}):Play()
			end)
			btn.MouseLeave:Connect(function()
				TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = originalBg, TextColor3 = Color3.new(1,1,1)}):Play()
			end)
		end
		addHover(BtnYes, CurrentTheme.Primary)
		addHover(BtnNo, Color3.fromRGB(91,91,91))
	end

	return WindowSetup
end

return EmloxaLibrary
