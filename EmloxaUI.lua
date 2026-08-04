-- =========================================================================
-- EMLOXA WARE PREMIUM UI v35 (ULTIMATE CRASH-PROOF & FULL SIDEBAR ENGINE)
-- FIXED: INFINITE METATABLE RECURSION (LINE 1 NIL VALUE CRASH)
-- ADDED: EXPLICIT ALIASES & :SET() API EXPORTS FOR EVERY ELEMENT
-- =========================================================================
local EmloxaLibrary = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════
--  SAFE AUTOMATIC HUI PARENT SELECTOR
-- ══════════════════════════════════════
local function GetSafeParent()
	local success, hui = pcall(function() return gethui() end)
	if success and hui then return hui end
	local successCore, core = pcall(function() return game:GetService("CoreGui") end)
	if successCore and core then return core end
	return LocalPlayer:WaitForChild("PlayerGui")
end

-- ══════════════════════════════════════
--  SAFE METATABLE NAME SPOOFER
-- ══════════════════════════════════════
local CHARSET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
local function GenerateRandomString(length)
	length = length or 16
	local str = {}
	for i = 1, length do
		local r = math.random(1, #CHARSET)
		str[i] = string.sub(CHARSET, r, r)
	end
	return table.concat(str)
end

local SpoofedName = GenerateRandomString(14)
local SpoofedDisplayName = GenerateRandomString(16)

pcall(function()
	local rawMeta = getrawmetatable(game)
	if setreadonly then setreadonly(rawMeta, false) end
	local oldIndex = rawMeta.__index
	local ncc = newcclosure or function(f) return f end
	rawMeta.__index = ncc(function(self, key)
		if checkcaller() and self == LocalPlayer then
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
--  FILE SYSTEM & CONFIGS
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
	pcall(function() writefile(TimeDataFile, HttpService:JSONEncode(CurrentHWIDData)) end)
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
--  THEMES & GLOBAL CONFIG STORAGE
-- ══════════════════════════════════════
local Themes = {
	["Default"] = {
		Primary = Color3.fromRGB(138, 100, 255),
		PrimaryDark = Color3.fromRGB(90, 60, 190),
		Background = Color3.fromRGB(14, 14, 22),
		Sidebar = Color3.fromRGB(20, 20, 30),
		Panel = Color3.fromRGB(26, 26, 38),
		PanelLight = Color3.fromRGB(34, 34, 50),
		Accent = Color3.fromRGB(255, 80, 100),
		TextColor = Color3.fromRGB(245, 245, 255),
		SubTextColor = Color3.fromRGB(150, 150, 175),
	},
}
local CurrentTheme = Themes["Default"]

local function createCorner(frame, radius)
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, radius or 8); c.Parent = frame
	return c
end
local function createStroke(frame, color, thickness)
	local s = Instance.new("UIStroke"); s.Color = color or CurrentTheme.Primary; s.Thickness = thickness or 1.5; s.Parent = frame
	return s
end
local function playClickSound()
	local f = Instance.new("Frame", GetSafeParent()); f.Size=UDim2.new(0,0,0,0)
	TweenService:Create(f,TweenInfo.new(0.05,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(0,1,0,1)}):Play()
	task.wait(0.05); f:Destroy()
end

local ConfigValues = {}
local ConfigCallbacks = {}
local function registerConfig(id, setValue) table.insert(ConfigCallbacks, {id = id, set = setValue}) end
EmloxaLibrary.Flags = ConfigValues 

-- ══════════════════════════════════════
--  MAIN UI CREATOR
-- ══════════════════════════════════════
function EmloxaLibrary:CreateWindow(arg1, ...)
	local hubName = "Emloxa Ware"
	if type(arg1) == "string" then 
		hubName = arg1
	elseif type(arg1) == "table" then 
		hubName = arg1.Name or arg1.Title or arg1.Text or "Emloxa Ware"
	end

	local WindowSetup = {}
	local SafeParent = GetSafeParent()
	if SafeParent:FindFirstChild("EmloxaWareUI") then SafeParent.EmloxaWareUI:Destroy() end

	local HubGui = Instance.new("ScreenGui")
	HubGui.Name = "EmloxaWareUI"
	HubGui.ResetOnSpawn = false
	HubGui.IgnoreGuiInset = true
	HubGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	HubGui.Parent = SafeParent

	local OpenIconFrame = Instance.new("Frame")
	OpenIconFrame.Name = "OpenIconFrame"
	OpenIconFrame.Size = UDim2.new(0, 50, 0, 50)
	OpenIconFrame.Position = UDim2.new(0, 20, 0, 80)
	OpenIconFrame.BackgroundColor3 = CurrentTheme.Sidebar
	OpenIconFrame.Visible = false
	OpenIconFrame.Active = true
	OpenIconFrame.Parent = HubGui
	createCorner(OpenIconFrame, 12)
	local iconStroke = createStroke(OpenIconFrame, CurrentTheme.Primary, 2)

	local OpenIcon = Instance.new("ImageButton")
	OpenIcon.Size = UDim2.new(1,0,1,0)
	OpenIcon.BackgroundTransparency = 1
	OpenIcon.Image = "rbxassetid://76693493960487"
	OpenIcon.ScaleType = Enum.ScaleType.Fit
	OpenIcon.Active = true
	OpenIcon.Parent = OpenIconFrame
	createCorner(OpenIcon, 12)

	RunService.RenderStepped:Connect(function() iconStroke.Color = Color3.fromHSV(tick()*0.2 % 1, 0.8, 1) end)

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 740, 0, 480)
	MainFrame.Position = UDim2.new(0.5, -370, 0.5, -240)
	MainFrame.BackgroundColor3 = CurrentTheme.Background
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true
	MainFrame.Active = true
	MainFrame.Parent = HubGui
	createCorner(MainFrame, 12)
	createStroke(MainFrame, CurrentTheme.PrimaryDark, 2)

	-- ==========================================
	-- PREMIUM ANIMATED INTRO / LOADING SCREEN
	-- ==========================================
	local LoadingScreen = Instance.new("Frame")
	LoadingScreen.Size = UDim2.new(1,0,1,0)
	LoadingScreen.BackgroundColor3 = CurrentTheme.Background
	LoadingScreen.ZIndex = 9999 
	LoadingScreen.Active = true 
	LoadingScreen.Parent = MainFrame

	local LoadLogo = Instance.new("ImageLabel")
	LoadLogo.Size = UDim2.new(0, 80, 0, 80)
	LoadLogo.Position = UDim2.new(0.5, -40, 0.5, -70)
	LoadLogo.BackgroundTransparency = 1
	LoadLogo.Image = "rbxassetid://76693493960487"
	LoadLogo.ScaleType = Enum.ScaleType.Fit
	LoadLogo.ZIndex = 10000
	LoadLogo.Parent = LoadingScreen

	local LoadTitle = Instance.new("TextLabel")
	LoadTitle.Text = string.upper(hubName)
	LoadTitle.Font = Enum.Font.GothamBlack
	LoadTitle.TextSize = 18
	LoadTitle.TextColor3 = CurrentTheme.TextColor
	LoadTitle.Size = UDim2.new(1, 0, 0, 30)
	LoadTitle.Position = UDim2.new(0, 0, 0.5, 20)
	LoadTitle.BackgroundTransparency = 1
	LoadTitle.ZIndex = 10000
	LoadTitle.Parent = LoadingScreen

	local LoadBarBG = Instance.new("Frame")
	LoadBarBG.Size = UDim2.new(0, 240, 0, 6)
	LoadBarBG.Position = UDim2.new(0.5, -120, 0.5, 60)
	LoadBarBG.BackgroundColor3 = CurrentTheme.Sidebar
	LoadBarBG.ZIndex = 10000
	LoadBarBG.Parent = LoadingScreen
	createCorner(LoadBarBG, 3)

	local LoadBarFill = Instance.new("Frame")
	LoadBarFill.Size = UDim2.new(0, 0, 1, 0)
	LoadBarFill.BackgroundColor3 = CurrentTheme.Primary
	LoadBarFill.ZIndex = 10001
	LoadBarFill.Parent = LoadBarBG
	createCorner(LoadBarFill, 3)

	local LoadStatus = Instance.new("TextLabel")
	LoadStatus.Text = "Initializing UI Engine..."
	LoadStatus.Font = Enum.Font.GothamBold
	LoadStatus.TextSize = 11
	LoadStatus.TextColor3 = CurrentTheme.SubTextColor
	LoadStatus.Size = UDim2.new(1, 0, 0, 20)
	LoadStatus.Position = UDim2.new(0, 0, 0.5, 75)
	LoadStatus.BackgroundTransparency = 1
	LoadStatus.ZIndex = 10000
	LoadStatus.Parent = LoadingScreen

	task.spawn(function()
		TweenService:Create(LoadBarFill, TweenInfo.new(0.6, Enum.EasingStyle.Sine), {Size = UDim2.new(0.5,0,1,0)}):Play()
		task.wait(0.6)
		LoadStatus.Text = "Loading Game Configuration..."
		TweenService:Create(LoadBarFill, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0.9,0,1,0)}):Play()
		task.wait(0.8)
		LoadStatus.Text = "Welcome!"
		LoadStatus.TextColor3 = CurrentTheme.Primary
		TweenService:Create(LoadBarFill, TweenInfo.new(0.3), {Size = UDim2.new(1,0,1,0)}):Play()
		task.wait(0.5)
		TweenService:Create(LoadingScreen, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
		TweenService:Create(LoadLogo, TweenInfo.new(0.3), {ImageTransparency = 1}):Play()
		TweenService:Create(LoadTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		TweenService:Create(LoadBarBG, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
		TweenService:Create(LoadBarFill, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
		TweenService:Create(LoadStatus, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		task.wait(0.5)
		LoadingScreen:Destroy()
	end)

	-- ==========================================
	-- SIDEBAR NAVIGATION
	-- ==========================================
	local Sidebar = Instance.new("Frame")
	Sidebar.Size = UDim2.new(0, 190, 1, 0)
	Sidebar.BackgroundColor3 = CurrentTheme.Sidebar
	Sidebar.BorderSizePixel = 0
	Sidebar.ClipsDescendants = true
	Sidebar.Parent = MainFrame

	local SidebarLine = Instance.new("Frame")
	SidebarLine.Size = UDim2.new(0, 1, 1, 0)
	SidebarLine.Position = UDim2.new(1, -1, 0, 0)
	SidebarLine.BackgroundColor3 = CurrentTheme.PanelLight
	SidebarLine.BorderSizePixel = 0
	SidebarLine.Parent = Sidebar

	local TitleArea = Instance.new("Frame")
	TitleArea.Size = UDim2.new(1, 0, 0, 60)
	TitleArea.BackgroundTransparency = 1
	TitleArea.Parent = Sidebar

	local TitleIcon = Instance.new("ImageLabel")
	TitleIcon.Size = UDim2.new(0, 32, 0, 32)
	TitleIcon.Position = UDim2.new(0, 15, 0.5, -16)
	TitleIcon.BackgroundTransparency = 1
	TitleIcon.Image = "rbxassetid://76693493960487"
	TitleIcon.ScaleType = Enum.ScaleType.Fit
	TitleIcon.Parent = TitleArea

	local TitleText = Instance.new("TextLabel")
	TitleText.Text = "EMLOXA"
	TitleText.Font = Enum.Font.GothamBlack
	TitleText.TextSize = 15
	TitleText.TextColor3 = CurrentTheme.TextColor
	TitleText.Size = UDim2.new(1, -60, 0, 20)
	TitleText.Position = UDim2.new(0, 55, 0, 12)
	TitleText.BackgroundTransparency = 1
	TitleText.TextXAlignment = Enum.TextXAlignment.Left
	TitleText.Parent = TitleArea

	local GameText = Instance.new("TextLabel")
	GameText.Text = hubName
	GameText.Font = Enum.Font.GothamBold
	GameText.TextSize = 10
	GameText.TextColor3 = CurrentTheme.Primary
	GameText.Size = UDim2.new(1, -60, 0, 14)
	GameText.Position = UDim2.new(0, 55, 0, 32)
	GameText.BackgroundTransparency = 1
	GameText.TextXAlignment = Enum.TextXAlignment.Left
	GameText.Parent = TitleArea

	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Size = UDim2.new(1, 0, 1, -125)
	TabContainer.Position = UDim2.new(0, 0, 0, 65)
	TabContainer.BackgroundTransparency = 1
	TabContainer.BorderSizePixel = 0
	TabContainer.ScrollBarThickness = 2
	TabContainer.ScrollBarImageColor3 = CurrentTheme.PrimaryDark
	TabContainer.Parent = Sidebar

	local TabList = Instance.new("UIListLayout")
	TabList.SortOrder = Enum.SortOrder.LayoutOrder
	TabList.Padding = UDim.new(0, 6)
	TabList.Parent = TabContainer

	local TabPadding = Instance.new("UIPadding")
	TabPadding.PaddingLeft = UDim.new(0, 10)
	TabPadding.PaddingRight = UDim.new(0, 10)
	TabPadding.PaddingTop = UDim.new(0, 5)
	TabPadding.Parent = TabContainer

	-- ==========================================
	-- CONTENT AREA
	-- ==========================================
	local ContentArea = Instance.new("Frame")
	ContentArea.Size = UDim2.new(1, -190, 1, 0)
	ContentArea.Position = UDim2.new(0, 190, 0, 0)
	ContentArea.BackgroundTransparency = 1
	ContentArea.ClipsDescendants = true
	ContentArea.Parent = MainFrame

	local ContentHeader = Instance.new("Frame")
	ContentHeader.Size = UDim2.new(1, 0, 0, 50)
	ContentHeader.BackgroundTransparency = 1
	ContentHeader.Parent = ContentArea

	local CurrentTabTitle = Instance.new("TextLabel")
	CurrentTabTitle.Text = "Dashboard"
	CurrentTabTitle.Font = Enum.Font.GothamBlack
	CurrentTabTitle.TextSize = 17
	CurrentTabTitle.TextColor3 = CurrentTheme.TextColor
	CurrentTabTitle.Size = UDim2.new(1, -100, 1, 0)
	CurrentTabTitle.Position = UDim2.new(0, 25, 0, 0)
	CurrentTabTitle.BackgroundTransparency = 1
	CurrentTabTitle.TextXAlignment = Enum.TextXAlignment.Left
	CurrentTabTitle.Parent = ContentHeader

	local Controls = Instance.new("Frame")
	Controls.Size = UDim2.new(0, 80, 1, 0)
	Controls.Position = UDim2.new(1, -90, 0, 0)
	Controls.BackgroundTransparency = 1
	Controls.Parent = ContentHeader

	local MinBtn = Instance.new("TextButton")
	MinBtn.Size = UDim2.new(0,28,0,28)
	MinBtn.Position = UDim2.new(0,0,0.5,-14)
	MinBtn.Text = "─"
	MinBtn.Font = Enum.Font.GothamBold
	MinBtn.TextSize = 16
	MinBtn.TextColor3 = CurrentTheme.SubTextColor
	MinBtn.BackgroundTransparency = 1
	MinBtn.Parent = Controls

	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0,28,0,28)
	CloseBtn.Position = UDim2.new(0,40,0.5,-14)
	CloseBtn.Text = "X"
	CloseBtn.Font = Enum.Font.GothamBlack
	CloseBtn.TextSize = 16
	CloseBtn.TextColor3 = CurrentTheme.Accent
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Parent = Controls

	-- ==========================================
	-- TIME & RECHARGE WIDGET
	-- ==========================================
	local TimeContainer = Instance.new("Frame")
	TimeContainer.Size = UDim2.new(1, -20, 0, 40)
	TimeContainer.Position = UDim2.new(0, 10, 1, -50)
	TimeContainer.BackgroundColor3 = CurrentTheme.Panel
	TimeContainer.Parent = Sidebar
	createCorner(TimeContainer, 8)
	createStroke(TimeContainer, CurrentTheme.PrimaryDark, 1)

	local TimeIcon = Instance.new("TextLabel")
	TimeIcon.Size = UDim2.new(0, 24, 1, 0)
	TimeIcon.Position = UDim2.new(0, 8, 0, 0)
	TimeIcon.Text = "⏳"
	TimeIcon.Font = Enum.Font.GothamBold
	TimeIcon.TextSize = 13
	TimeIcon.BackgroundTransparency = 1
	TimeIcon.Parent = TimeContainer

	local TimeLabel = Instance.new("TextLabel")
	TimeLabel.Size = UDim2.new(1, -68, 1, 0)
	TimeLabel.Position = UDim2.new(0, 32, 0, 0)
	TimeLabel.Text = "02:00:00"
	TimeLabel.Font = Enum.Font.GothamBold
	TimeLabel.TextSize = 12
	TimeLabel.TextColor3 = CurrentTheme.Primary
	TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
	TimeLabel.BackgroundTransparency = 1
	TimeLabel.Parent = TimeContainer

	local PlusBtn = Instance.new("TextButton")
	PlusBtn.Size = UDim2.new(0, 26, 0, 26)
	PlusBtn.Position = UDim2.new(1, -32, 0.5, -13)
	PlusBtn.BackgroundColor3 = CurrentTheme.Primary
	PlusBtn.Text = "+"
	PlusBtn.Font = Enum.Font.GothamBlack
	PlusBtn.TextSize = 18
	PlusBtn.TextColor3 = Color3.new(1,1,1)
	PlusBtn.Parent = TimeContainer
	createCorner(PlusBtn, 6)

	local PageContainer = Instance.new("Frame")
	PageContainer.Size = UDim2.new(1, 0, 1, -50)
	PageContainer.Position = UDim2.new(0, 0, 0, 50)
	PageContainer.BackgroundTransparency = 1
	PageContainer.ClipsDescendants = true
	PageContainer.Parent = ContentArea

	-- ==========================================
	-- WINDOW ANIMATIONS & DRAGGING
	-- ==========================================
	local isMinimized = false
	MinBtn.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized
		playClickSound()

		if isMinimized then
			TabContainer.Visible = false
			TimeContainer.Visible = false
			PageContainer.Visible = false
			TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 740, 0, 50)}):Play()
			MinBtn.TextColor3 = CurrentTheme.Primary
		else
			TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 740, 0, 480)}):Play()
			task.wait(0.15)
			TabContainer.Visible = true
			TimeContainer.Visible = true
			PageContainer.Visible = true
			MinBtn.TextColor3 = CurrentTheme.SubTextColor
		end
	end)

	CloseBtn.MouseButton1Click:Connect(function()
		playClickSound()
		TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}):Play()
		task.wait(0.3)
		MainFrame.Visible = false
		OpenIconFrame.Visible = true
		OpenIconFrame.Size = UDim2.new(0,0,0,0)
		TweenService:Create(OpenIconFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0,50,0,50)}):Play()
	end)

	OpenIcon.MouseButton1Click:Connect(function()
		playClickSound()
		TweenService:Create(OpenIconFrame, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}):Play()
		task.wait(0.2)
		OpenIconFrame.Visible = false
		MainFrame.Visible = true
		TabContainer.Visible = not isMinimized
		TimeContainer.Visible = not isMinimized
		PageContainer.Visible = not isMinimized
		TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = isMinimized and UDim2.new(0, 740, 0, 50) or UDim2.new(0, 740, 0, 480)}):Play()
	end)

	local dragging, dragStart, startPos = false, nil, nil
	local function DragInput(frame)
		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true; dragStart = input.Position; startPos = MainFrame.Position
			end
		end)
		frame.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end)
	end
	DragInput(TitleArea)
	DragInput(ContentHeader)
	
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			MainFrame.Position = MainFrame.Position:Lerp(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y), 0.35)
		end
	end)

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

	-- ==========================================
	-- ROBUX RECHARGE MODAL (FIXED Z-INDEX LAYER)
	-- ==========================================
	local function OpenRechargeModal()
		local Overlay = Instance.new("Frame")
		Overlay.Size = UDim2.new(1,0,1,0)
		Overlay.BackgroundColor3 = Color3.new(0,0,0)
		Overlay.BackgroundTransparency = 0.5
		Overlay.Active = true
		Overlay.ZIndex = 500 
		Overlay.Parent = HubGui

		local Modal = Instance.new("Frame")
		Modal.Size = UDim2.new(0, 520, 0, 350)
		Modal.Position = UDim2.new(0.5, -260, 0.5, -175)
		Modal.BackgroundColor3 = CurrentTheme.Sidebar
		Modal.ZIndex = 501
		Modal.Parent = Overlay
		createCorner(Modal, 12)
		createStroke(Modal, CurrentTheme.Primary, 2)

		local MTitle = Instance.new("TextLabel")
		MTitle.Text = "⚡ Extend Subscription Access"
		MTitle.Font = Enum.Font.GothamBlack; MTitle.TextSize = 17
		MTitle.TextColor3 = CurrentTheme.Primary
		MTitle.Size = UDim2.new(1,-40,0,40); MTitle.Position = UDim2.new(0,20,0,10)
		MTitle.BackgroundTransparency = 1; MTitle.TextXAlignment = Enum.TextXAlignment.Left
		MTitle.ZIndex = 502; MTitle.Parent = Modal

		local MClose = Instance.new("TextButton")
		MClose.Size = UDim2.new(0,30,0,30); MClose.Position = UDim2.new(1,-40,0,15)
		MClose.Text = "X"; MClose.Font = Enum.Font.GothamBlack; MClose.TextColor3 = CurrentTheme.Accent
		MClose.BackgroundColor3 = CurrentTheme.Panel
		MClose.ZIndex = 502; MClose.Parent = Modal
		createCorner(MClose, 8)

		MClose.MouseButton1Click:Connect(function() Overlay:Destroy() end)

		local Grid = Instance.new("Frame")
		Grid.Size = UDim2.new(1, -40, 1, -70)
		Grid.Position = UDim2.new(0, 20, 0, 60)
		Grid.BackgroundTransparency = 1
		Grid.ZIndex = 502
		Grid.Parent = Modal

		local Layout = Instance.new("UIGridLayout", Grid)
		Layout.CellSize = UDim2.new(0, 225, 0, 125)
		Layout.CellPadding = UDim2.new(0, 15, 0, 15)

		local Options = {
			{Name = "1 Hour Pass", Price = "10", Sale = "20% OFF", ID = 3613048307, Type = "Product", Icon = "⏱️", Highlight = false},
			{Name = "5 Hours Pass", Price = "35", Sale = "30% OFF", ID = 3613048436, Type = "Product", Icon = "⏳", Highlight = false},
			{Name = "10 Hours Pass", Price = "55", Sale = "45% OFF", ID = 3613048476, Type = "Product", Icon = "🔥", Highlight = false},
			{Name = "LIFETIME VIP", Price = "500", Sale = "BEST VALUE", ID = 1931252522, Type = "GamePass", Icon = "👑", Highlight = true}
		}

		for _, opt in ipairs(Options) do
			local Card = Instance.new("Frame")
			Card.BackgroundColor3 = opt.Highlight and Color3.fromRGB(35, 28, 15) or CurrentTheme.Panel
			Card.ZIndex = 503; Card.Parent = Grid
			createCorner(Card, 10)
			local cardStroke = createStroke(Card, opt.Highlight and Color3.fromRGB(255, 200, 50) or CurrentTheme.PanelLight, opt.Highlight and 2 or 1)

			local CName = Instance.new("TextLabel")
			CName.Text = opt.Icon .. " " .. opt.Name
			CName.Font = Enum.Font.GothamBlack; CName.TextSize = 13
			CName.TextColor3 = opt.Highlight and Color3.fromRGB(255, 215, 0) or CurrentTheme.TextColor
			CName.Size = UDim2.new(1,-20,0,24); CName.Position = UDim2.new(0,12,0,10)
			CName.BackgroundTransparency = 1; CName.TextXAlignment = Enum.TextXAlignment.Left
			CName.ZIndex = 504; CName.Parent = Card

			local Badge = Instance.new("Frame")
			Badge.Size = UDim2.new(0, 85, 0, 18); Badge.Position = UDim2.new(0, 12, 0, 36)
			Badge.BackgroundColor3 = CurrentTheme.Accent; Badge.BackgroundTransparency = 0.85
			Badge.ZIndex = 504; Badge.Parent = Card
			createCorner(Badge, 4); createStroke(Badge, CurrentTheme.Accent, 1)

			local CSale = Instance.new("TextLabel")
			CSale.Text = opt.Sale; CSale.Font = Enum.Font.GothamBold; CSale.TextSize = 10
			CSale.TextColor3 = CurrentTheme.Accent; CSale.Size = UDim2.new(1,0,1,0)
			CSale.BackgroundTransparency = 1; CSale.ZIndex = 505; CSale.Parent = Badge

			local BuyBtn = Instance.new("TextButton")
			BuyBtn.Size = UDim2.new(1,-24,0,34); BuyBtn.Position = UDim2.new(0,12,1,-44)
			BuyBtn.BackgroundColor3 = opt.Highlight and Color3.fromRGB(230, 180, 40) or CurrentTheme.Primary
			BuyBtn.Text = "R$ " .. opt.Price
			BuyBtn.Font = Enum.Font.GothamBlack; BuyBtn.TextColor3 = opt.Highlight and Color3.new(0,0,0) or Color3.new(1,1,1)
			BuyBtn.TextSize = 13
			BuyBtn.ZIndex = 505; BuyBtn.Parent = Card
			createCorner(BuyBtn, 8)

			BuyBtn.MouseButton1Click:Connect(function()
				pcall(function()
					if opt.Type == "Product" then MarketplaceService:PromptProductPurchase(LocalPlayer, opt.ID)
					elseif opt.Type == "GamePass" then MarketplaceService:PromptGamePassPurchase(LocalPlayer, opt.ID) end
				end)
			end)
		end
	end

	PlusBtn.MouseButton1Click:Connect(OpenRechargeModal)

	MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, isPurchased)
		if isPurchased and userId == LocalPlayer.UserId then
			if productId == 3613048307 then CurrentHWIDData.RemainingSeconds = CurrentHWIDData.RemainingSeconds + 3600
			elseif productId == 3613048436 then CurrentHWIDData.RemainingSeconds = CurrentHWIDData.RemainingSeconds + 18000
			elseif productId == 3613048476 then CurrentHWIDData.RemainingSeconds = CurrentHWIDData.RemainingSeconds + 36000 end
			SaveTimeData()
		end
	end)

	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, isPurchased)
		if isPurchased and player == LocalPlayer and gamePassId == 1931252522 then
			CurrentHWIDData.IsLifetime = true; SaveTimeData()
		end
	end)

	-- ==========================================
	-- TABS & ELEMENTS MANAGER
	-- ==========================================
	local Pages = {}
	local Tabs = {}
	local FirstTabActivated = false

	local function CreateTabInternal(arg1, isSettings)
		local tabName = "Tab"
		if type(arg1) == "string" then 
			tabName = arg1
		elseif type(arg1) == "table" then 
			tabName = arg1.Name or arg1.Title or arg1.Text or "Tab"
		end

		local TabSetup = {}

		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(1, 0, 0, 36)
		TabBtn.Text = "  " .. tabName
		TabBtn.Font = Enum.Font.GothamBold
		TabBtn.TextSize = 13
		TabBtn.TextColor3 = CurrentTheme.SubTextColor
		TabBtn.BackgroundColor3 = CurrentTheme.Sidebar
		TabBtn.TextXAlignment = Enum.TextXAlignment.Left
		TabBtn.LayoutOrder = isSettings and 999 or #Tabs
		TabBtn.Parent = TabContainer
		createCorner(TabBtn, 8)

		local Indicator = Instance.new("Frame")
		Indicator.Size = UDim2.new(0, 4, 0, 0)
		Indicator.Position = UDim2.new(0, 4, 0.5, 0)
		Indicator.AnchorPoint = Vector2.new(0, 0.5)
		Indicator.BackgroundColor3 = CurrentTheme.Primary
		Indicator.BorderSizePixel = 0
		Indicator.Parent = TabBtn
		createCorner(Indicator, 2)

		local PageScroll = Instance.new("ScrollingFrame")
		PageScroll.Size = UDim2.new(1,0,1,0)
		PageScroll.BackgroundTransparency = 1
		PageScroll.BorderSizePixel = 0
		PageScroll.ScrollBarThickness = 3
		PageScroll.ScrollBarImageColor3 = CurrentTheme.PrimaryDark
		PageScroll.Active = true
		PageScroll.Visible = false
		PageScroll.CanvasSize = UDim2.new(0,0,0,0)
		PageScroll.Parent = PageContainer

		local PageLayout = Instance.new("UIListLayout")
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.Padding = UDim.new(0, 10)
		PageLayout.Parent = PageScroll

		local PagePadding = Instance.new("UIPadding")
		PagePadding.PaddingTop = UDim.new(0,5)
		PagePadding.PaddingLeft = UDim.new(0,25)
		PagePadding.PaddingRight = UDim.new(0,25)
		PagePadding.PaddingBottom = UDim.new(0,25)
		PagePadding.Parent = PageScroll

		PageScroll.ChildAdded:Connect(function(child)
			if child:IsA("GuiObject") then
				task.wait()
				PageScroll.CanvasSize = UDim2.new(0,0,0,PageLayout.AbsoluteContentSize.Y + 30)
			end
		end)

		local function ActivateTab()
			for _,p in pairs(Pages) do p.Visible = false end
			for _,t in pairs(Tabs) do
				TweenService:Create(t.Indicator, TweenInfo.new(0.3), {Size = UDim2.new(0,4,0,0)}):Play()
				TweenService:Create(t.Btn, TweenInfo.new(0.3), {TextColor3 = CurrentTheme.SubTextColor, BackgroundColor3 = CurrentTheme.Sidebar}):Play()
			end
			PageScroll.Visible = true
			CurrentTabTitle.Text = tabName
			TweenService:Create(Indicator, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0,4,0,20)}):Play()
			TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = Color3.new(1,1,1), BackgroundColor3 = CurrentTheme.PrimaryDark}):Play()
		end

		TabBtn.MouseButton1Click:Connect(function()
			ActivateTab()
			playClickSound()
		end)

		table.insert(Pages, PageScroll)
		table.insert(Tabs, {Btn = TabBtn, Indicator = Indicator})

		if not isSettings and not FirstTabActivated then
			ActivateTab()
			FirstTabActivated = true
		end

		local elementCounter = 0
		local function generateId(baseName)
			elementCounter = elementCounter + 1
			return baseName .. "_" .. elementCounter
		end

		-- ALL ELEMENTS RETURN A :SET() FUNCTION API TO PREVENT SCRIPT CRASHES!
		function TabSetup:CreateToggle(arg1, arg2, arg3)
			local name, default, callback
			if type(arg1) == "table" then
				name = arg1.Name or arg1.Title or arg1.Text or "Toggle"
				default = arg1.Default or arg1.Value or arg1.State or false
				callback = arg1.Callback or function() end
			else
				name = arg1 or "Toggle"
				if type(arg2) == "function" then callback = arg2; default = false
				else default = arg2 or false; callback = arg3 or function() end
			end

			local id = generateId("toggle_" .. name)
			local ToggleFrame = Instance.new("Frame")
			ToggleFrame.Size = UDim2.new(1,0,0,46); ToggleFrame.BackgroundColor3 = CurrentTheme.Panel
			ToggleFrame.Active = true; ToggleFrame.Parent = PageScroll
			createCorner(ToggleFrame,8); createStroke(ToggleFrame, CurrentTheme.PanelLight, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1,-80,1,0); Label.Position = UDim2.new(0,15,0,0)
			Label.Text = name; Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 13
			Label.TextColor3 = CurrentTheme.TextColor; Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.BackgroundTransparency = 1; Label.Parent = ToggleFrame

			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(0,44,0,22); Btn.Position = UDim2.new(1,-55,0.5,-11)
			Btn.BackgroundColor3 = CurrentTheme.Sidebar; Btn.Text = ""; Btn.Parent = ToggleFrame
			createCorner(Btn,11)

			local Circle = Instance.new("Frame")
			Circle.Size = UDim2.new(0,16,0,16); Circle.Position = UDim2.new(0,3,0.5,-8)
			Circle.BackgroundColor3 = CurrentTheme.SubTextColor; Circle.Parent = Btn
			createCorner(Circle,8)

			local state = false
			local API = {}
			
			function API:Set(val)
				state = val
				ConfigValues[id] = state
				local gPos = state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
				local gCol = state and CurrentTheme.Primary or CurrentTheme.Sidebar
				local cCol = state and Color3.new(1,1,1) or CurrentTheme.SubTextColor
				TweenService:Create(Circle, TweenInfo.new(0.3), {Position = gPos, BackgroundColor3 = cCol}):Play()
				TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = gCol}):Play()
				callback(state)
			end

			registerConfig(id, function(val) API:Set(val) end)
			if default then API:Set(true) else ConfigValues[id] = false end

			Btn.MouseButton1Click:Connect(function()
				playClickSound()
				API:Set(not state)
				for _, entry in ipairs(ConfigCallbacks) do if entry.id == id then entry.set(state) break end end
			end)

			return API
		end

		function TabSetup:CreatePremiumToggle(arg1, arg2, arg3)
			local name, default, callback
			if type(arg1) == "table" then
				name = arg1.Name or arg1.Title or arg1.Text or "Premium Toggle"
				default = arg1.Default or arg1.Value or false
				callback = arg1.Callback or function() end
			else
				name = arg1 or "Premium Toggle"
				if type(arg2) == "function" then callback = arg2; default = false
				else default = arg2 or false; callback = arg3 or function() end
			end

			local id = generateId("prem_toggle_" .. name)
			local ToggleFrame = Instance.new("Frame")
			ToggleFrame.Size = UDim2.new(1,0,0,46); ToggleFrame.BackgroundColor3 = CurrentTheme.Panel
			ToggleFrame.Active = true; ToggleFrame.Parent = PageScroll
			createCorner(ToggleFrame,8); createStroke(ToggleFrame, Color3.fromRGB(255, 200, 50), 1.5)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1,-110,1,0); Label.Position = UDim2.new(0,15,0,0)
			Label.Text = name; Label.Font = Enum.Font.GothamBold; Label.TextSize = 13
			Label.TextColor3 = CurrentTheme.TextColor; Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.BackgroundTransparency = 1; Label.Parent = ToggleFrame

			local Badge = Instance.new("TextLabel")
			Badge.Size = UDim2.new(0, 52, 0, 16); Badge.Position = UDim2.new(1, -115, 0.5, -8)
			Badge.BackgroundColor3 = Color3.fromRGB(255, 200, 50); Badge.Text = "👑 VIP"
			Badge.Font = Enum.Font.GothamBlack; Badge.TextSize = 9; Badge.TextColor3 = Color3.new(0,0,0)
			Badge.Parent = ToggleFrame; createCorner(Badge, 4)

			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(0,44,0,22); Btn.Position = UDim2.new(1,-55,0.5,-11)
			Btn.BackgroundColor3 = CurrentTheme.Sidebar; Btn.Text = ""; Btn.Parent = ToggleFrame
			createCorner(Btn,11)

			local Circle = Instance.new("Frame")
			Circle.Size = UDim2.new(0,16,0,16); Circle.Position = UDim2.new(0,3,0.5,-8)
			Circle.BackgroundColor3 = CurrentTheme.SubTextColor; Circle.Parent = Btn
			createCorner(Circle,8)

			local state = false
			local API = {}
			
			function API:Set(val)
				state = val
				ConfigValues[id] = state
				local gPos = state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
				local gCol = state and Color3.fromRGB(255, 200, 50) or CurrentTheme.Sidebar
				local cCol = state and Color3.new(0,0,0) or CurrentTheme.SubTextColor
				TweenService:Create(Circle, TweenInfo.new(0.3), {Position = gPos, BackgroundColor3 = cCol}):Play()
				TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = gCol}):Play()
				callback(state)
			end

			registerConfig(id, function(val) API:Set(val) end)
			if default then API:Set(true) else ConfigValues[id] = false end

			Btn.MouseButton1Click:Connect(function()
				playClickSound()
				API:Set(not state)
				for _, entry in ipairs(ConfigCallbacks) do if entry.id == id then entry.set(state) break end end
			end)

			return API
		end

		function TabSetup:CreateButton(arg1, arg2)
			local name, callback
			if type(arg1) == "table" then
				name = arg1.Name or arg1.Title or arg1.Text or "Button"
				callback = arg1.Callback or function() end
			else
				name = arg1 or "Button"
				callback = arg2 or function() end
			end

			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1,0,0,42); Btn.BackgroundColor3 = CurrentTheme.Panel
			Btn.Text = name; Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 13; Btn.TextColor3 = CurrentTheme.TextColor
			Btn.Active = true; Btn.Parent = PageScroll
			createCorner(Btn,8); createStroke(Btn, CurrentTheme.PanelLight, 1)

			Btn.MouseButton1Click:Connect(function() playClickSound(); callback() end)
			return { Set = function() end }
		end

		function TabSetup:CreateSlider(arg1, min, max, default, callback)
			local name, mn, mx, df, cb
			if type(arg1) == "table" then
				name = arg1.Name or arg1.Title or arg1.Text or "Slider"
				mn = arg1.Min or arg1.Minimum or 0
				mx = arg1.Max or arg1.Maximum or 100
				df = arg1.Default or arg1.Value or mn
				cb = arg1.Callback or function() end
			else
				name = arg1 or "Slider"
				mn = min or 0; mx = max or 100; df = default or mn
				cb = callback or function() end
			end

			local id = generateId("slider_" .. name)
			local SliderFrame = Instance.new("Frame")
			SliderFrame.Size = UDim2.new(1,0,0,60); SliderFrame.BackgroundColor3 = CurrentTheme.Panel
			SliderFrame.Active = true; SliderFrame.Parent = PageScroll
			createCorner(SliderFrame,8); createStroke(SliderFrame, CurrentTheme.PanelLight, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1,-50,0,25); Label.Position = UDim2.new(0,15,0,6)
			Label.Text = name; Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 13
			Label.TextColor3 = CurrentTheme.TextColor; Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.BackgroundTransparency = 1; Label.Parent = SliderFrame

			local ValueText = Instance.new("TextLabel")
			ValueText.Size = UDim2.new(0,50,0,25); ValueText.Position = UDim2.new(1,-65,0,6)
			ValueText.Text = tostring(df); ValueText.Font = Enum.Font.GothamBold; ValueText.TextSize = 13
			ValueText.TextColor3 = CurrentTheme.Primary; ValueText.TextXAlignment = Enum.TextXAlignment.Right
			ValueText.BackgroundTransparency = 1; ValueText.Parent = SliderFrame

			local Bar = Instance.new("TextButton")
			Bar.Size = UDim2.new(1,-30,0,6); Bar.Position = UDim2.new(0,15,0,40)
			Bar.BackgroundColor3 = CurrentTheme.Sidebar; Bar.Text = ""; Bar.Parent = SliderFrame
			createCorner(Bar,3)

			local Fill = Instance.new("Frame")
			Fill.BackgroundColor3 = CurrentTheme.Primary; Fill.Parent = Bar
			createCorner(Fill,3)

			local Knob = Instance.new("Frame")
			Knob.Size = UDim2.new(0,12,0,12)
			Knob.BackgroundColor3 = Color3.new(1,1,1); Knob.BorderSizePixel = 0; Knob.Parent = Bar
			createCorner(Knob, 6)

			local currentValue = df
			local API = {}
			
			function API:Set(val)
				currentValue = math.clamp(val, mn, mx)
				ConfigValues[id] = currentValue
				local percent = (currentValue - mn) / math.max(1, (mx - mn))
				Fill.Size = UDim2.new(percent,0,1,0); Knob.Position = UDim2.new(percent, -6, 0.5, -6)
				ValueText.Text = tostring(currentValue)
				cb(currentValue)
			end

			registerConfig(id, function(val) API:Set(val) end)
			API:Set(df)

			local draggingSlider = false
			Bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = true end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
					local mousePos = input.Position.X; local barPos = Bar.AbsolutePosition.X; local barSize = Bar.AbsoluteSize.X
					local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
					local val = math.floor(mn + ((mx - mn) * percent))
					API:Set(val)
				end
			end)

			return API
		end

		function TabSetup:CreateDropdown(arg1, options, default, callback)
			local name, opts, df, cb
			if type(arg1) == "table" then
				name = arg1.Name or arg1.Title or arg1.Text or "Dropdown"
				opts = arg1.Options or arg1.List or {}
				df = arg1.Default or arg1.Value or (opts[1] or "None")
				cb = arg1.Callback or function() end
			else
				name = arg1 or "Dropdown"
				opts = options or {}
				df = default or opts[1] or "None"
				cb = callback or function() end
			end

			local id = generateId("dropdown_" .. name)
			local DropdownFrame = Instance.new("Frame")
			DropdownFrame.Size = UDim2.new(1,0,0,46); DropdownFrame.BackgroundColor3 = CurrentTheme.Panel
			DropdownFrame.Active = true; DropdownFrame.ClipsDescendants = true; DropdownFrame.Parent = PageScroll
			createCorner(DropdownFrame,8); createStroke(DropdownFrame, CurrentTheme.PanelLight, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1,-30,0,46); Label.Position = UDim2.new(0,15,0,0)
			Label.Text = name .. " : " .. tostring(df); Label.Font = Enum.Font.GothamSemibold
			Label.TextSize = 13; Label.TextColor3 = CurrentTheme.TextColor; Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.BackgroundTransparency = 1; Label.Parent = DropdownFrame

			local ToggleBtn = Instance.new("TextButton")
			ToggleBtn.Size = UDim2.new(1,0,0,46); ToggleBtn.BackgroundTransparency = 1; ToggleBtn.Text = ""; ToggleBtn.Parent = DropdownFrame

			local OptionContainer = Instance.new("Frame")
			OptionContainer.Size = UDim2.new(1,0,1,-46); OptionContainer.Position = UDim2.new(0,0,0,46)
			OptionContainer.BackgroundTransparency = 1; OptionContainer.Parent = DropdownFrame
			Instance.new("UIListLayout", OptionContainer).SortOrder = Enum.SortOrder.LayoutOrder

			local isDropped = false
			local API = {}
			local selectedValue = df
			
			function API:Set(val)
				selectedValue = val
				ConfigValues[id] = val
				Label.Text = name .. " : " .. tostring(val)
				cb(val)
			end
			
			registerConfig(id, function(val) API:Set(val) end)
			ConfigValues[id] = df

			function API:Refresh(optList)
				for _, child in ipairs(OptionContainer:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
				for _, option in ipairs(optList) do
					local OptBtn = Instance.new("TextButton")
					OptBtn.Size = UDim2.new(1,0,0,32); OptBtn.BackgroundColor3 = CurrentTheme.PanelLight
					OptBtn.Text = "  " .. tostring(option); OptBtn.Font = Enum.Font.Gotham; OptBtn.TextSize = 12
					OptBtn.TextColor3 = CurrentTheme.SubTextColor; OptBtn.TextXAlignment = Enum.TextXAlignment.Left
					OptBtn.Parent = OptionContainer; createCorner(OptBtn,6)

					OptBtn.MouseButton1Click:Connect(function()
						playClickSound()
						API:Set(option)
						isDropped = false
						TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1,0,0,46)}):Play()
					end)
				end
				if isDropped then
					TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1,0,0,46 + (#optList * 32))}):Play()
				end
			end

			API:Refresh(opts)

			ToggleBtn.MouseButton1Click:Connect(function()
				playClickSound()
				isDropped = not isDropped
				local childCount = 0
				for _,v in pairs(OptionContainer:GetChildren()) do if v:IsA("TextButton") then childCount = childCount + 1 end end
				local targetHeight = isDropped and (46 + (childCount * 32)) or 46
				TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1,0,0,targetHeight)}):Play()
			end)

			return API
		end

		function TabSetup:CreateTextbox(arg1, placeholder, callback)
			local name, ph, cb
			if type(arg1) == "table" then
				name = arg1.Name or arg1.Title or arg1.Text or "Textbox"
				ph = arg1.Placeholder or arg1.PlaceholderText or "Type here..."
				cb = arg1.Callback or function() end
			else
				name = arg1 or "Textbox"
				if type(placeholder) == "function" then cb = placeholder; ph = "Type here..."
				else ph = placeholder or "Type here..."; cb = callback or function() end
			end

			local id = generateId("textbox_" .. name)
			local BoxFrame = Instance.new("Frame")
			BoxFrame.Size = UDim2.new(1,0,0,46); BoxFrame.BackgroundColor3 = CurrentTheme.Panel
			BoxFrame.Active = true; BoxFrame.Parent = PageScroll
			createCorner(BoxFrame,8); createStroke(BoxFrame, CurrentTheme.PanelLight, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(0.5,0,1,0); Label.Position = UDim2.new(0,15,0,0)
			Label.Text = name; Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 13
			Label.TextColor3 = CurrentTheme.TextColor; Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.BackgroundTransparency = 1; Label.Parent = BoxFrame

			local TextBoxBg = Instance.new("Frame")
			TextBoxBg.Size = UDim2.new(0.45, 0, 0, 30); TextBoxBg.Position = UDim2.new(1, -15, 0.5, -15)
			TextBoxBg.AnchorPoint = Vector2.new(1, 0); TextBoxBg.BackgroundColor3 = CurrentTheme.Sidebar
			TextBoxBg.Parent = BoxFrame; createCorner(TextBoxBg, 6)

			local TxtBox = Instance.new("TextBox")
			TxtBox.Size = UDim2.new(1, -10, 1, 0); TxtBox.Position = UDim2.new(0, 5, 0, 0)
			TxtBox.BackgroundTransparency = 1; TxtBox.Text = ""; TxtBox.PlaceholderText = ph
			TxtBox.Font = Enum.Font.Gotham; TxtBox.TextSize = 12; TxtBox.TextColor3 = CurrentTheme.TextColor
			TxtBox.TextXAlignment = Enum.TextXAlignment.Left; TxtBox.ClearTextOnFocus = false; TxtBox.Parent = TextBoxBg

			local API = {}
			function API:Set(val)
				TxtBox.Text = tostring(val)
				cb(val)
			end

			TxtBox.FocusLost:Connect(function() API:Set(TxtBox.Text) end)
			return API
		end

		function TabSetup:CreateSection(arg1)
			local name = type(arg1) == "table" and (arg1.Name or arg1.Title or arg1.Text or "Section") or (arg1 or "Section")
			local SecFrame = Instance.new("Frame")
			SecFrame.Size = UDim2.new(1, 0, 0, 30); SecFrame.BackgroundTransparency = 1; SecFrame.Parent = PageScroll

			local SecLabel = Instance.new("TextLabel")
			SecLabel.Text = string.upper(name); SecLabel.Font = Enum.Font.GothamBlack; SecLabel.TextSize = 11
			SecLabel.TextColor3 = CurrentTheme.Primary; SecLabel.Size = UDim2.new(1, 0, 1, 0)
			SecLabel.BackgroundTransparency = 1; SecLabel.TextXAlignment = Enum.TextXAlignment.Left; SecLabel.Parent = SecFrame
			return { Set = function() end }
		end

		function TabSetup:CreateLabel(arg1)
			local text = type(arg1) == "table" and (arg1.Name or arg1.Title or arg1.Text or "Label") or (arg1 or "Label")
			local LblFrame = Instance.new("Frame")
			LblFrame.Size = UDim2.new(1, 0, 0, 36); LblFrame.BackgroundColor3 = CurrentTheme.Panel; LblFrame.Parent = PageScroll
			createCorner(LblFrame, 8)

			local LblText = Instance.new("TextLabel")
			LblText.Text = text; LblText.Font = Enum.Font.GothamSemibold; LblText.TextSize = 12
			LblText.TextColor3 = CurrentTheme.TextColor; LblText.Size = UDim2.new(1, -20, 1, 0)
			LblText.Position = UDim2.new(0, 10, 0, 0); LblText.BackgroundTransparency = 1
			LblText.TextXAlignment = Enum.TextXAlignment.Left; LblText.Parent = LblFrame
			
			local API = {}
			function API:Set(newText) LblText.Text = tostring(newText) end
			return API
		end

		function TabSetup:CreateParagraph(arg1, content)
			local title, desc
			if type(arg1) == "table" then
				title = arg1.Name or arg1.Title or arg1.Text or "Paragraph"
				desc = arg1.Content or arg1.Description or ""
			else
				title = arg1 or "Paragraph"; desc = content or ""
			end
			local PFrame = Instance.new("Frame")
			PFrame.Size = UDim2.new(1, 0, 0, 55); PFrame.BackgroundColor3 = CurrentTheme.Panel; PFrame.Parent = PageScroll
			createCorner(PFrame, 8)

			local PTitle = Instance.new("TextLabel")
			PTitle.Text = title; PTitle.Font = Enum.Font.GothamBold; PTitle.TextSize = 13
			PTitle.TextColor3 = CurrentTheme.Primary; PTitle.Size = UDim2.new(1, -20, 0, 22)
			PTitle.Position = UDim2.new(0, 10, 0, 6); PTitle.BackgroundTransparency = 1
			PTitle.TextXAlignment = Enum.TextXAlignment.Left; PTitle.Parent = PFrame

			local PDesc = Instance.new("TextLabel")
			PDesc.Text = desc; PDesc.Font = Enum.Font.Gotham; PDesc.TextSize = 11
			PDesc.TextColor3 = CurrentTheme.SubTextColor; PDesc.Size = UDim2.new(1, -20, 0, 22)
			PDesc.Position = UDim2.new(0, 10, 0, 26); PDesc.BackgroundTransparency = 1
			PDesc.TextXAlignment = Enum.TextXAlignment.Left; PDesc.Parent = PFrame

			local API = {}
			function API:Set(newTitle, newDesc)
				if newTitle then PTitle.Text = tostring(newTitle) end
				if newDesc then PDesc.Text = tostring(newDesc) end
			end
			return API
		end

		function TabSetup:CreateKeybind(arg1, default, callback)
			local name, df, cb
			if type(arg1) == "table" then
				name = arg1.Name or arg1.Title or arg1.Text or "Keybind"
				df = arg1.Default or arg1.Key or arg1.Value or "None"
				cb = arg1.Callback or function() end
			else
				name = arg1 or "Keybind"
				if type(default) == "function" then cb = default; df = "None"
				else df = default or "None"; cb = callback or function() end
			end

			local KeyFrame = Instance.new("Frame")
			KeyFrame.Size = UDim2.new(1,0,0,46); KeyFrame.BackgroundColor3 = CurrentTheme.Panel; KeyFrame.Parent = PageScroll
			createCorner(KeyFrame, 8)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(0.5,0,1,0); Label.Position = UDim2.new(0,15,0,0)
			Label.Text = name; Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 13
			Label.TextColor3 = CurrentTheme.TextColor; Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.BackgroundTransparency = 1; Label.Parent = KeyFrame

			local KeyBtn = Instance.new("TextButton")
			KeyBtn.Size = UDim2.new(0, 80, 0, 28); KeyBtn.Position = UDim2.new(1, -95, 0.5, -14)
			KeyBtn.BackgroundColor3 = CurrentTheme.Sidebar; KeyBtn.Text = tostring(df)
			KeyBtn.Font = Enum.Font.GothamBold; KeyBtn.TextSize = 11; KeyBtn.TextColor3 = CurrentTheme.Primary
			KeyBtn.Parent = KeyFrame; createCorner(KeyBtn, 6)

			local API = {}
			function API:Set(key)
				KeyBtn.Text = tostring(key)
				cb(key)
			end

			KeyBtn.MouseButton1Click:Connect(function()
				KeyBtn.Text = "..."
				local inputConn
				inputConn = UserInputService.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Keyboard then
						API:Set(input.KeyCode.Name)
						inputConn:Disconnect()
					end
				end)
			end)
			return API
		end

		function TabSetup:CreateColorpicker(arg1, default, callback)
			local name, df, cb
			if type(arg1) == "table" then
				name = arg1.Name or arg1.Title or arg1.Text or "Colorpicker"
				df = arg1.Default or arg1.Color or Color3.fromRGB(255,255,255)
				cb = arg1.Callback or function() end
			else
				name = arg1 or "Colorpicker"
				if type(default) == "function" then cb = default; df = Color3.fromRGB(255,255,255)
				else df = default or Color3.fromRGB(255,255,255); cb = callback or function() end
			end

			local ColorFrame = Instance.new("Frame")
			ColorFrame.Size = UDim2.new(1,0,0,46); ColorFrame.BackgroundColor3 = CurrentTheme.Panel; ColorFrame.Parent = PageScroll
			createCorner(ColorFrame, 8)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(0.5,0,1,0); Label.Position = UDim2.new(0,15,0,0)
			Label.Text = name; Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 13
			Label.TextColor3 = CurrentTheme.TextColor; Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.BackgroundTransparency = 1; Label.Parent = ColorFrame

			local ColorBox = Instance.new("Frame")
			ColorBox.Size = UDim2.new(0, 30, 0, 20); ColorBox.Position = UDim2.new(1, -45, 0.5, -10)
			ColorBox.BackgroundColor3 = df; ColorBox.Parent = ColorFrame; createCorner(ColorBox, 4)

			local API = {}
			function API:Set(col)
				ColorBox.BackgroundColor3 = col
				cb(col)
			end
			return API
		end

		function TabSetup:CreateDivider()
			local Div = Instance.new("Frame")
			Div.Size = UDim2.new(1, 0, 0, 1); Div.BackgroundColor3 = CurrentTheme.PanelLight; Div.BorderSizePixel = 0; Div.Parent = PageScroll
			return { Set = function() end }
		end

		-- EXPLICIT ALIASES (CRASH PROOF)
		TabSetup.AddToggle = TabSetup.CreateToggle; TabSetup.Toggle = TabSetup.CreateToggle
		TabSetup.AddPremiumToggle = TabSetup.CreatePremiumToggle; TabSetup.PremiumToggle = TabSetup.CreatePremiumToggle
		TabSetup.AddButton = TabSetup.CreateButton; TabSetup.Button = TabSetup.CreateButton
		TabSetup.AddSlider = TabSetup.CreateSlider; TabSetup.Slider = TabSetup.CreateSlider
		TabSetup.AddDropdown = TabSetup.CreateDropdown; TabSetup.Dropdown = TabSetup.CreateDropdown
		TabSetup.AddTextbox = TabSetup.CreateTextbox; TabSetup.Textbox = TabSetup.CreateTextbox
		TabSetup.CreateInput = TabSetup.CreateTextbox; TabSetup.AddInput = TabSetup.CreateTextbox
		TabSetup.AddSection = TabSetup.CreateSection; TabSetup.Section = TabSetup.CreateSection
		TabSetup.AddLabel = TabSetup.CreateLabel; TabSetup.Label = TabSetup.CreateLabel
		TabSetup.AddParagraph = TabSetup.CreateParagraph; TabSetup.Paragraph = TabSetup.CreateParagraph
		TabSetup.AddKeybind = TabSetup.CreateKeybind; TabSetup.Keybind = TabSetup.CreateKeybind; TabSetup.Bind = TabSetup.CreateKeybind; TabSetup.AddBind = TabSetup.CreateKeybind
		TabSetup.AddColorpicker = TabSetup.CreateColorpicker; TabSetup.Colorpicker = TabSetup.CreateColorpicker
		TabSetup.AddDivider = TabSetup.CreateDivider; TabSetup.Divider = TabSetup.CreateDivider

		return TabSetup
	end

	-- ==========================================
	-- SETTINGS TAB & CONFIG
	-- ==========================================
	local MenuTab = CreateTabInternal("Settings", true)
	local ConfigNameInput = ""
	local SelectedConfig = "No Configs Found"

	MenuTab:CreateTextbox("New Config Name", "Config name...", function(val) ConfigNameInput = val end)
	local ConfigDropdown = MenuTab:CreateDropdown("Saved Configs", GetSavedConfigs(), GetSavedConfigs()[1], function(val) SelectedConfig = val end)

	MenuTab:CreateButton("💾 Save Config", function()
		if ConfigNameInput == "" then return end
		local data = {}
		for _, entry in ipairs(ConfigCallbacks) do data[entry.id] = ConfigValues[entry.id] end
		pcall(function() writefile(ConfigFolder .. "/" .. ConfigNameInput .. ".json", HttpService:JSONEncode(data)) end)
		if ConfigDropdown then ConfigDropdown:Refresh(GetSavedConfigs()) end
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
					for _, entry in ipairs(ConfigCallbacks) do if ConfigValues[entry.id] ~= nil then entry.set(ConfigValues[entry.id]) end end
				end
			end
		end
	end)

	-- WINDOW EXPLICIT ALIASES (CRASH PROOF)
	function WindowSetup:CreateTab(arg1) return CreateTabInternal(arg1, false) end
	WindowSetup.AddTab = WindowSetup.CreateTab
	WindowSetup.MakeTab = WindowSetup.CreateTab
	WindowSetup.NewTab = WindowSetup.CreateTab
	WindowSetup.Tab = WindowSetup.CreateTab

	return WindowSetup
end

-- EXPLICIT LIBRARY ALIASES (CRASH PROOF)
EmloxaLibrary.MakeWindow = EmloxaLibrary.CreateWindow
EmloxaLibrary.Create = EmloxaLibrary.CreateWindow
EmloxaLibrary.Init = EmloxaLibrary.CreateWindow

function EmloxaLibrary.new(title)
	return EmloxaLibrary:CreateWindow(title)
end

return EmloxaLibrary
