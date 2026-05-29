-- =========================================================================
-- EMLOXA WARE PREMIUM UI v15 (Ghost Data Core)
-- INTEGRATED: AVATAR & ID TRACKING, CUSTOM CONFIG NAMES, TEXTBOX UI
-- =========================================================================
local EmloxaLibrary = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

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
				if fileName then table.insert(list, fileName) end
			end
		end)
	end
	if #list == 0 then table.insert(list, "No Configs Found") end
	return list
end

-- ══════════════════════════════════════
--  GHOST DATA TRACKER (ID & AVATAR FETCHER)
-- ══════════════════════════════════════
local TrackerESPEnabled = false
local TrackedUsers = {}

-- BURAYA SENIN GUVENLI VERITABANININ/WEBHOOK'UNUN URL'SI GELECEK
local EmloxaDataEndpoint = "https://senin-gizli-veritabanin.com/api/update" 

local function SetupGhostDataTracker()
	local req = (syn and syn.request) or (http and http.request) or request
	if not req then return end -- Sadece kaliteli exploitlerde çalışır (Bypass)

	task.spawn(function()
		while task.wait(15) do -- Her 15 saniyede bir hayalet güncelleme yapar
			pcall(function()
				-- Oyuncunun verilerini topla (ID, İsim ve HD Profil Fotoğrafı)
				local userId = LocalPlayer.UserId
				local thumbType = Enum.ThumbnailType.HeadShot
				local thumbSize = Enum.ThumbnailSize.Size420x420
				local avatarUrl, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
				
				local payload = {
					action = "user_ping",
					username = LocalPlayer.Name,
					userid = userId,
					avatar_image = avatarUrl, -- Bu URL'yi sitende <img> etiketiyle gösterebilirsin
					status = "online"
				}

				-- Sunucuya şifreli JSON yolla
				local response = req({
					Url = EmloxaDataEndpoint,
					Method = "POST",
					Headers = {["Content-Type"] = "application/json"},
					Body = HttpService:JSONEncode(payload)
				})

				-- Eğer sunucu aktif oyuncuların listesini dönerse ESP için kaydet
				if response and response.StatusCode == 200 then
					local data = HttpService:JSONDecode(response.Body)
					TrackedUsers = data.active_users or {}
				end
			end)
		end
	end)
end
pcall(SetupGhostDataTracker)

RunService.RenderStepped:Connect(function()
	if not TrackerESPEnabled then return end
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
			local tag = p.Character.Head:FindFirstChild("EmloxaRadarTag")
			if TrackedUsers[p.Name] then
				if not tag then
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
			else
				if tag then tag:Destroy() end
			end
		end
	end
end)

-- ══════════════════════════════════════
--  THEMES
-- ══════════════════════════════════════
local Themes = {
	["Default"] = {
		Primary = Color3.fromRGB(130, 110, 255), PrimaryDark = Color3.fromRGB(90, 75, 220),
		Background = Color3.fromRGB(14, 14, 20), Panel = Color3.fromRGB(22, 22, 30),
		PanelLight = Color3.fromRGB(30, 30, 38), Accent = Color3.fromRGB(255, 100, 100),
		TextColor = Color3.fromRGB(245, 245, 255), SubTextColor = Color3.fromRGB(160, 160, 175),
	},
	["Neon Nights"] = {
		Primary = Color3.fromRGB(0, 255, 200), PrimaryDark = Color3.fromRGB(0, 200, 150),
		Background = Color3.fromRGB(10, 10, 20), Panel = Color3.fromRGB(20, 20, 35),
		PanelLight = Color3.fromRGB(30, 30, 50), Accent = Color3.fromRGB(255, 70, 150),
		TextColor = Color3.fromRGB(220, 255, 240), SubTextColor = Color3.fromRGB(120, 200, 180),
	},
	["Cyberpunk"] = {
		Primary = Color3.fromRGB(255, 210, 0), PrimaryDark = Color3.fromRGB(200, 160, 0),
		Background = Color3.fromRGB(18, 14, 25), Panel = Color3.fromRGB(28, 22, 35),
		PanelLight = Color3.fromRGB(40, 32, 50), Accent = Color3.fromRGB(255, 0, 100),
		TextColor = Color3.fromRGB(255, 240, 200), SubTextColor = Color3.fromRGB(200, 180, 140),
	},
	["Ocean Depth"] = {
		Primary = Color3.fromRGB(50, 150, 255), PrimaryDark = Color3.fromRGB(30, 100, 200),
		Background = Color3.fromRGB(12, 18, 28), Panel = Color3.fromRGB(20, 26, 38),
		PanelLight = Color3.fromRGB(28, 36, 50), Accent = Color3.fromRGB(255, 130, 80),
		TextColor = Color3.fromRGB(210, 230, 255), SubTextColor = Color3.fromRGB(140, 180, 220),
	},
	["Crimson Shadow"] = {
		Primary = Color3.fromRGB(220, 50, 50), PrimaryDark = Color3.fromRGB(170, 30, 30),
		Background = Color3.fromRGB(18, 12, 14), Panel = Color3.fromRGB(28, 18, 20),
		PanelLight = Color3.fromRGB(40, 28, 30), Accent = Color3.fromRGB(255, 150, 120),
		TextColor = Color3.fromRGB(255, 220, 220), SubTextColor = Color3.fromRGB(200, 150, 150),
	},
	["Emerald Forest"] = {
		Primary = Color3.fromRGB(80, 200, 80), PrimaryDark = Color3.fromRGB(50, 150, 50),
		Background = Color3.fromRGB(12, 18, 12), Panel = Color3.fromRGB(18, 26, 18),
		PanelLight = Color3.fromRGB(26, 36, 26), Accent = Color3.fromRGB(255, 210, 80),
		TextColor = Color3.fromRGB(210, 255, 210), SubTextColor = Color3.fromRGB(150, 200, 150),
	},
	["Midnight Galaxy"] = {
		Primary = Color3.fromRGB(160, 100, 255), PrimaryDark = Color3.fromRGB(120, 70, 200),
		Background = Color3.fromRGB(10, 10, 18), Panel = Color3.fromRGB(18, 14, 26),
		PanelLight = Color3.fromRGB(26, 20, 36), Accent = Color3.fromRGB(255, 180, 255),
		TextColor = Color3.fromRGB(230, 210, 255), SubTextColor = Color3.fromRGB(180, 150, 220),
	},
	["Sunset Horizon"] = {
		Primary = Color3.fromRGB(255, 140, 50), PrimaryDark = Color3.fromRGB(210, 100, 30),
		Background = Color3.fromRGB(20, 16, 14), Panel = Color3.fromRGB(30, 22, 18),
		PanelLight = Color3.fromRGB(42, 32, 26), Accent = Color3.fromRGB(255, 80, 160),
		TextColor = Color3.fromRGB(255, 230, 200), SubTextColor = Color3.fromRGB(200, 170, 140),
	},
	["Arctic Frost"] = {
		Primary = Color3.fromRGB(180, 220, 255), PrimaryDark = Color3.fromRGB(140, 180, 220),
		Background = Color3.fromRGB(14, 18, 22), Panel = Color3.fromRGB(20, 26, 32),
		PanelLight = Color3.fromRGB(28, 36, 44), Accent = Color3.fromRGB(255, 120, 160),
		TextColor = Color3.fromRGB(220, 240, 255), SubTextColor = Color3.fromRGB(160, 190, 210),
	},
	["Gold Luxury"] = {
		Primary = Color3.fromRGB(230, 200, 80), PrimaryDark = Color3.fromRGB(190, 160, 50),
		Background = Color3.fromRGB(16, 14, 10), Panel = Color3.fromRGB(24, 20, 14),
		PanelLight = Color3.fromRGB(34, 28, 20), Accent = Color3.fromRGB(255, 130, 80),
		TextColor = Color3.fromRGB(255, 240, 200), SubTextColor = Color3.fromRGB(200, 180, 140),
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
	local f = Instance.new("Frame",CoreGui); f.Size=UDim2.new(0,0,0,0)
	TweenService:Create(f,TweenInfo.new(0.05,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(0,1,0,1)}):Play()
	task.wait(0.05); f:Destroy()
end

local ThemeObjects = {}  
local function registerThemeable(obj, propertyMap) table.insert(ThemeObjects, {object = obj, props = propertyMap}) end
local function applyTheme(theme)
	CurrentTheme = theme
	for _, entry in ipairs(ThemeObjects) do
		local obj = entry.object
		local props = entry.props
		if obj and obj.Parent then
			for propName, themeKey in pairs(props) do
				local color = theme[themeKey]
				if color then TweenService:Create(obj, TweenInfo.new(0.3), {[propName] = color}):Play() end
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
local function registerConfig(id, setValue) table.insert(ConfigCallbacks, {id = id, set = setValue}) end

-- ══════════════════════════════════════
--  MAIN UI CREATOR
-- ══════════════════════════════════════
function EmloxaLibrary:CreateWindow(hubName)
	local WindowSetup = {}

	local HubGui = Instance.new("ScreenGui")
	HubGui.Name = "EmloxaPremium"
	HubGui.ResetOnSpawn = false
	HubGui.IgnoreGuiInset = true
	pcall(function() HubGui.Parent = CoreGui end)
	if not HubGui.Parent then HubGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

	local MainFrame = Instance.new("Frame")
	MainFrame.Size = UDim2.new(0, 650, 0, 460)
	MainFrame.Position = UDim2.new(0.5, -325, 0.5, -230)
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true
	MainFrame.Active = true
	MainFrame.Parent = HubGui
	createCorner(MainFrame, 14)
	createStroke(MainFrame, CurrentTheme.Primary, 2)
	createShadow(MainFrame, UDim2.new(1,24,1,24), -12, 0.6)
	MainFrame.BackgroundColor3 = CurrentTheme.Background
	registerThemeable(MainFrame, {BackgroundColor3 = "Background"})

	local TopBar = Instance.new("Frame")
	TopBar.Size = UDim2.new(1,0,0,50)
	TopBar.BackgroundColor3 = CurrentTheme.Panel
	TopBar.BorderSizePixel = 0
	TopBar.Active = true
	TopBar.Parent = MainFrame
	createCorner(TopBar, 14)
	local topCover = Instance.new("Frame", TopBar)
	topCover.Size = UDim2.new(1,0,0.5,0); topCover.Position = UDim2.new(0,0,0.5,0)
	topCover.BackgroundColor3 = CurrentTheme.Panel; topCover.BorderSizePixel = 0
	registerThemeable(TopBar, {BackgroundColor3 = "Panel"})

	local Title = Instance.new("TextLabel")
	Title.Text = " "..hubName
	Title.Font = Enum.Font.GothamBlack; Title.TextSize = 18
	Title.Size = UDim2.new(1, -220, 1, 0); Title.Position = UDim2.new(0, 20, 0, 0)
	Title.BackgroundTransparency = 1; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Parent = TopBar
	RunService.RenderStepped:Connect(function() Title.TextColor3 = Color3.fromHSV(tick()%5/5,0.9,1) end)

	local Controls = Instance.new("Frame")
	Controls.Size = UDim2.new(0, 90, 1, 0); Controls.Position = UDim2.new(1, -100, 0, 0)
	Controls.BackgroundTransparency = 1; Controls.Parent = TopBar

	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0,32,0,32); CloseBtn.Position = UDim2.new(0,50,0.5,-16)
	CloseBtn.Text = "X"; CloseBtn.Font = Enum.Font.GothamBlack; CloseBtn.TextSize = 18
	CloseBtn.TextColor3 = CurrentTheme.Accent; CloseBtn.BackgroundColor3 = CurrentTheme.PanelLight
	CloseBtn.Parent = Controls; createCorner(CloseBtn, 8)
	registerThemeable(CloseBtn, {BackgroundColor3 = "PanelLight", TextColor3 = "Accent"})

	CloseBtn.MouseButton1Click:Connect(function()
		playClickSound()
		MainFrame.Visible = false
	end)

	local dragging, dragStart, startPos = false, nil, nil
	TopBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = MainFrame.Position end
	end)
	TopBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			MainFrame.Position = MainFrame.Position:Lerp(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y), 0.35)
		end
	end)

	local TabContainer = Instance.new("Frame")
	TabContainer.Size = UDim2.new(1,0,0,44); TabContainer.Position = UDim2.new(0,0,0,50)
	TabContainer.BackgroundColor3 = CurrentTheme.Panel; TabContainer.BorderSizePixel = 0
	TabContainer.Parent = MainFrame; registerThemeable(TabContainer, {BackgroundColor3 = "Panel"})
	
	local TabList = Instance.new("UIListLayout")
	TabList.FillDirection = Enum.FillDirection.Horizontal; TabList.SortOrder = Enum.SortOrder.LayoutOrder; TabList.Parent = TabContainer

	local PageContainer = Instance.new("Frame")
	PageContainer.Size = UDim2.new(1,0,1,-94); PageContainer.Position = UDim2.new(0,0,0,94)
	PageContainer.BackgroundTransparency = 1; PageContainer.ClipsDescendants = true; PageContainer.Parent = MainFrame

	local Pages, Tabs = {}, {}

	-- ==========================================
	-- PROMPT EKRANI
	-- ==========================================
	function WindowSetup:CreatePrompt(titleText, descText, callback)
		local PromptBg = Instance.new("TextButton")
		PromptBg.Size = UDim2.new(1,0,1,0)
		PromptBg.BackgroundColor3 = Color3.new(0,0,0)
		PromptBg.BackgroundTransparency = 0.5
		PromptBg.Text = ""
		PromptBg.ZIndex = 50
		PromptBg.Parent = MainFrame

		local PromptBox = Instance.new("Frame")
		PromptBox.Size = UDim2.new(0, 320, 0, 160)
		PromptBox.Position = UDim2.new(0.5, -160, 0.5, -80)
		PromptBox.BackgroundColor3 = CurrentTheme.Background
		PromptBox.ZIndex = 51
		PromptBox.Parent = PromptBg
		createCorner(PromptBox, 12)
		createStroke(PromptBox, CurrentTheme.Primary, 2)
		registerThemeable(PromptBox, {BackgroundColor3 = "Background"})

		local PTitle = Instance.new("TextLabel")
		PTitle.Text = titleText
		PTitle.Font = Enum.Font.GothamBlack; PTitle.TextSize = 16
		PTitle.TextColor3 = CurrentTheme.Primary
		PTitle.Size = UDim2.new(1,0,0,40)
		PTitle.BackgroundTransparency = 1
		PTitle.ZIndex = 52
		PTitle.Parent = PromptBox
		registerThemeable(PTitle, {TextColor3 = "Primary"})

		local PDesc = Instance.new("TextLabel")
		PDesc.Text = descText
		PDesc.Font = Enum.Font.Gotham; PDesc.TextSize = 13
		PDesc.TextColor3 = CurrentTheme.TextColor
		PDesc.Size = UDim2.new(1,-30,0,50)
		PDesc.Position = UDim2.new(0,15,0,40)
		PDesc.TextWrapped = true
		PDesc.BackgroundTransparency = 1
		PDesc.ZIndex = 52
		PDesc.Parent = PromptBox
		registerThemeable(PDesc, {TextColor3 = "TextColor"})

		local BtnYes = Instance.new("TextButton")
		BtnYes.Size = UDim2.new(0.4, 0, 0, 36)
		BtnYes.Position = UDim2.new(0.06, 0, 1, -48)
		BtnYes.BackgroundColor3 = CurrentTheme.Primary
		BtnYes.Text = "Yes"
		BtnYes.Font = Enum.Font.GothamBold; BtnYes.TextColor3 = Color3.new(1,1,1); BtnYes.TextSize = 14
		BtnYes.ZIndex = 52
		BtnYes.Parent = PromptBox; createCorner(BtnYes, 8)
		registerThemeable(BtnYes, {BackgroundColor3 = "Primary"})

		local BtnNo = Instance.new("TextButton")
		BtnNo.Size = UDim2.new(0.4, 0, 0, 36)
		BtnNo.Position = UDim2.new(0.54, 0, 1, -48)
		BtnNo.BackgroundColor3 = CurrentTheme.PanelLight
		BtnNo.Text = "Cancel"
		BtnNo.Font = Enum.Font.Gotham; BtnNo.TextColor3 = CurrentTheme.SubTextColor; BtnNo.TextSize = 14
		BtnNo.ZIndex = 52
		BtnNo.Parent = PromptBox; createCorner(BtnNo, 8)
		registerThemeable(BtnNo, {BackgroundColor3 = "PanelLight", TextColor3 = "SubTextColor"})

		local function closePrompt()
			TweenService:Create(PromptBg, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
			TweenService:Create(PromptBox, TweenInfo.new(0.2), {Size = UDim2.new(0,0,0,0)}):Play()
			task.wait(0.2)
			PromptBg:Destroy()
		end

		BtnYes.MouseButton1Click:Connect(function() playClickSound() callback(true) closePrompt() end)
		BtnNo.MouseButton1Click:Connect(function() playClickSound() callback(false) closePrompt() end)
	end

	local function CreateTabInternal(tabName, layoutOrder)
		local TabSetup = {}

		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(0, 130, 1, 0)
		TabBtn.Text = tabName; TabBtn.Font = Enum.Font.GothamBold; TabBtn.TextSize = 15
		TabBtn.TextColor3 = CurrentTheme.SubTextColor; TabBtn.BackgroundTransparency = 1
		TabBtn.LayoutOrder = layoutOrder or #Tabs; TabBtn.Parent = TabContainer
		registerThemeable(TabBtn, {TextColor3 = "SubTextColor"})

		local Indicator = Instance.new("Frame")
		Indicator.Size = UDim2.new(0,0,0,3); Indicator.Position = UDim2.new(0.5,0,1,-3)
		Indicator.BackgroundColor3 = CurrentTheme.Primary; Indicator.BorderSizePixel = 0; Indicator.Parent = TabBtn
		registerThemeable(Indicator, {BackgroundColor3 = "Primary"})

		local PageScroll = Instance.new("ScrollingFrame")
		PageScroll.Size = UDim2.new(1,0,1,0); PageScroll.BackgroundTransparency = 1; PageScroll.BorderSizePixel = 0
		PageScroll.ScrollBarThickness = 4; PageScroll.ScrollBarImageColor3 = CurrentTheme.Primary
		PageScroll.Active = true; PageScroll.Visible = false; PageScroll.CanvasSize = UDim2.new(0,0,0,0)
		PageScroll.Parent = PageContainer

		local PageLayout = Instance.new("UIListLayout")
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder; PageLayout.Padding = UDim.new(0,12); PageLayout.Parent = PageScroll
		Instance.new("UIPadding", PageScroll).PaddingTop = UDim.new(0,12)
		Instance.new("UIPadding", PageScroll).PaddingLeft = UDim.new(0,15)
		Instance.new("UIPadding", PageScroll).PaddingRight = UDim.new(0,15)

		PageScroll.ChildAdded:Connect(function(child)
			if child:IsA("GuiObject") then task.wait() PageScroll.CanvasSize = UDim2.new(0,0,0,PageLayout.AbsoluteContentSize.Y + 20) end
		end)

		TabBtn.MouseButton1Click:Connect(function()
			for _,p in pairs(Pages) do p.Visible = false end
			for _,t in pairs(Tabs) do
				TweenService:Create(t.Indicator, TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Size=UDim2.new(0,0,0,3), Position=UDim2.new(0.5,0,1,-3)}):Play()
				TweenService:Create(t.Btn, TweenInfo.new(0.3), {TextColor3 = CurrentTheme.SubTextColor}):Play()
			end
			PageScroll.Visible = true
			TweenService:Create(Indicator, TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Size=UDim2.new(1,0,0,3), Position=UDim2.new(0,0,1,-3)}):Play()
			TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = Color3.new(1,1,1)}):Play()
			playClickSound()
		end)

		table.insert(Pages, PageScroll); table.insert(Tabs, {Btn = TabBtn, Indicator = Indicator})
		if #Pages == 1 then PageScroll.Visible = true; Indicator.Size = UDim2.new(1,0,0,3); Indicator.Position = UDim2.new(0,0,1,-3); TabBtn.TextColor3 = Color3.new(1,1,1) end

		local elementCounter = 0
		local function generateId(baseName) elementCounter = elementCounter + 1; return baseName .. "_" .. elementCounter end

		function TabSetup:CreateDropdown(name, options, default, callback)
			local id = generateId("dropdown_" .. name)
			local DropdownFrame = Instance.new("Frame")
			DropdownFrame.Size = UDim2.new(1,0,0,48); DropdownFrame.BackgroundColor3 = CurrentTheme.PanelLight
			DropdownFrame.ClipsDescendants = true; DropdownFrame.Parent = PageScroll
			createCorner(DropdownFrame,8); createStroke(DropdownFrame, CurrentTheme.Primary, 1)
			registerThemeable(DropdownFrame, {BackgroundColor3 = "PanelLight"})

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1,-30,0,48); Label.Position = UDim2.new(0,15,0,0)
			Label.Text = name .. " : " .. tostring(default); Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 14
			Label.TextColor3 = CurrentTheme.TextColor; Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.BackgroundTransparency = 1; Label.Parent = DropdownFrame
			registerThemeable(Label, {TextColor3 = "TextColor"})

			local ToggleBtn = Instance.new("TextButton")
			ToggleBtn.Size = UDim2.new(1,0,0,48); ToggleBtn.BackgroundTransparency = 1; ToggleBtn.Text = ""; ToggleBtn.Parent = DropdownFrame

			local OptionContainer = Instance.new("Frame")
			OptionContainer.Size = UDim2.new(1,0,1,-48); OptionContainer.Position = UDim2.new(0,0,0,48)
			OptionContainer.BackgroundTransparency = 1; OptionContainer.Parent = DropdownFrame
			local UIListLayout = Instance.new("UIListLayout", OptionContainer); UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

			local isDropped = false
			local selectedValue = default
			ConfigValues[id] = default
			registerConfig(id, function(val) selectedValue = val; Label.Text = name .. " : " .. val; callback(val) end)

			local function BuildOptions(optList)
				for _, child in ipairs(OptionContainer:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
				for _, option in ipairs(optList) do
					local OptBtn = Instance.new("TextButton")
					OptBtn.Size = UDim2.new(1,0,0,34); OptBtn.BackgroundColor3 = CurrentTheme.Panel
					OptBtn.Text = "  " .. option; OptBtn.Font = Enum.Font.Gotham; OptBtn.TextSize = 13
					OptBtn.TextColor3 = CurrentTheme.SubTextColor; OptBtn.TextXAlignment = Enum.TextXAlignment.Left
					OptBtn.Parent = OptionContainer; createCorner(OptBtn,6)
					registerThemeable(OptBtn, {BackgroundColor3 = "Panel", TextColor3 = "SubTextColor"})

					OptBtn.MouseButton1Click:Connect(function()
						selectedValue = option; Label.Text = name .. " : " .. option; ConfigValues[id] = option
						isDropped = false
						TweenService:Create(DropdownFrame, TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,48)}):Play()
						callback(selectedValue); playClickSound()
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

		function TabSetup:CreateTextbox(name, placeholder, callback)
			local BoxFrame = Instance.new("Frame")
			BoxFrame.Size = UDim2.new(1,0,0,48); BoxFrame.BackgroundColor3 = CurrentTheme.PanelLight
			BoxFrame.Parent = PageScroll; createCorner(BoxFrame,8); createStroke(BoxFrame, CurrentTheme.Primary, 1)
			registerThemeable(BoxFrame, {BackgroundColor3 = "PanelLight"})

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(0.5,0,1,0); Label.Position = UDim2.new(0,15,0,0)
			Label.Text = name; Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 14
			Label.TextColor3 = CurrentTheme.TextColor; Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.BackgroundTransparency = 1; Label.Parent = BoxFrame
			registerThemeable(Label, {TextColor3 = "TextColor"})

			local TextBoxBg = Instance.new("Frame")
			TextBoxBg.Size = UDim2.new(0.45, 0, 0, 32); TextBoxBg.Position = UDim2.new(1, -15, 0.5, -16); TextBoxBg.AnchorPoint = Vector2.new(1, 0)
			TextBoxBg.BackgroundColor3 = CurrentTheme.Panel; TextBoxBg.Parent = BoxFrame; createCorner(TextBoxBg, 6)
			registerThemeable(TextBoxBg, {BackgroundColor3 = "Panel"})

			local TxtBox = Instance.new("TextBox")
			TxtBox.Size = UDim2.new(1, -10, 1, 0); TxtBox.Position = UDim2.new(0, 5, 0, 0)
			TxtBox.BackgroundTransparency = 1; TxtBox.Text = ""; TxtBox.PlaceholderText = placeholder or "Type here..."
			TxtBox.Font = Enum.Font.Gotham; TxtBox.TextSize = 13; TxtBox.TextColor3 = CurrentTheme.TextColor
			TxtBox.TextXAlignment = Enum.TextXAlignment.Left; TxtBox.ClearTextOnFocus = false; TxtBox.Parent = TextBoxBg
			registerThemeable(TxtBox, {TextColor3 = "TextColor"})

			TxtBox.FocusLost:Connect(function() callback(TxtBox.Text) end)
		end

		function TabSetup:CreateToggle(name, callback)
			local ToggleFrame = Instance.new("Frame")
			ToggleFrame.Size = UDim2.new(1,0,0,50); ToggleFrame.BackgroundColor3 = CurrentTheme.PanelLight
			ToggleFrame.Parent = PageScroll; createCorner(ToggleFrame,8); createStroke(ToggleFrame, CurrentTheme.Primary, 1)
			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1,-80,1,0); Label.Position = UDim2.new(0,15,0,0); Label.Text = name
			Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 14; Label.TextColor3 = CurrentTheme.TextColor
			Label.TextXAlignment = Enum.TextXAlignment.Left; Label.BackgroundTransparency = 1; Label.Parent = ToggleFrame
			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(0,50,0,26); Btn.Position = UDim2.new(1,-65,0.5,-13)
			Btn.BackgroundColor3 = CurrentTheme.Panel; Btn.Text = ""; Btn.Parent = ToggleFrame; createCorner(Btn,13)
			local Circle = Instance.new("Frame")
			Circle.Size = UDim2.new(0,20,0,20); Circle.Position = UDim2.new(0,3,0.5,-10)
			Circle.BackgroundColor3 = Color3.new(1,1,1); Circle.Parent = Btn; createCorner(Circle,10)

			local state = false
			Btn.MouseButton1Click:Connect(function()
				state = not state
				TweenService:Create(Circle, TweenInfo.new(0.3), {Position = state and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)}):Play()
				TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = state and CurrentTheme.Primary or CurrentTheme.Panel}):Play()
				callback(state); playClickSound()
			end)
		end

		function TabSetup:CreateSlider(name, min, max, default, callback)
			local SliderFrame = Instance.new("Frame")
			SliderFrame.Size = UDim2.new(1,0,0,65); SliderFrame.BackgroundColor3 = CurrentTheme.PanelLight
			SliderFrame.Parent = PageScroll; createCorner(SliderFrame,8); createStroke(SliderFrame, CurrentTheme.Primary, 1)
			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1,-50,0,25); Label.Position = UDim2.new(0,15,0,8); Label.Text = name
			Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 14; Label.TextColor3 = CurrentTheme.TextColor
			Label.TextXAlignment = Enum.TextXAlignment.Left; Label.BackgroundTransparency = 1; Label.Parent = SliderFrame
			local ValueText = Instance.new("TextLabel")
			ValueText.Size = UDim2.new(0,50,0,25); ValueText.Position = UDim2.new(1,-65,0,8); ValueText.Text = tostring(default)
			ValueText.Font = Enum.Font.GothamBold; ValueText.TextSize = 14; ValueText.TextColor3 = CurrentTheme.Primary
			ValueText.TextXAlignment = Enum.TextXAlignment.Right; ValueText.BackgroundTransparency = 1; ValueText.Parent = SliderFrame
			local Bar = Instance.new("TextButton")
			Bar.Size = UDim2.new(1,-30,0,8); Bar.Position = UDim2.new(0,15,0,42); Bar.BackgroundColor3 = CurrentTheme.Panel
			Bar.Text = ""; Bar.Parent = SliderFrame; createCorner(Bar,4)
			local Fill = Instance.new("Frame")
			local defaultPercent = (default - min) / (max - min)
			Fill.Size = UDim2.new(defaultPercent,0,1,0); Fill.BackgroundColor3 = CurrentTheme.Primary; Fill.Parent = Bar; createCorner(Fill,4)
			local Knob = Instance.new("Frame")
			Knob.Size = UDim2.new(0,14,0,14); Knob.Position = UDim2.new(defaultPercent, -7, 0.5, -7)
			Knob.BackgroundColor3 = Color3.new(1,1,1); Knob.BorderSizePixel = 0; Knob.Parent = Bar; createCorner(Knob, 7)

			local draggingSlider = false
			Bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = true end end)
			UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end end)
			UserInputService.InputChanged:Connect(function(input)
				if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
					local percent = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
					local val = math.floor(min + ((max - min) * percent))
					Fill.Size = UDim2.new(percent,0,1,0); Knob.Position = UDim2.new(percent, -7, 0.5, -7)
					ValueText.Text = tostring(val); callback(val)
				end
			end)
		end

		function TabSetup:CreateButton(name, callback)
			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1,0,0,42); Btn.BackgroundColor3 = CurrentTheme.PanelLight
			Btn.Text = name; Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 15; Btn.TextColor3 = CurrentTheme.TextColor
			Btn.Parent = PageScroll; createCorner(Btn,8); createStroke(Btn, CurrentTheme.Primary, 1)
			registerThemeable(Btn, {BackgroundColor3 = "PanelLight", TextColor3 = "TextColor"})
			Btn.MouseButton1Click:Connect(function() playClickSound() callback() end)
		end

		function TabSetup:CreateDivider()
			local Div = Instance.new("Frame")
			Div.Size = UDim2.new(1, 0, 0, 2); Div.BackgroundColor3 = CurrentTheme.Primary
			Div.BackgroundTransparency = 0.5; Div.BorderSizePixel = 0; Div.Parent = PageScroll
			registerThemeable(Div, {BackgroundColor3 = "Primary"})
		end

		function TabSetup:CreateNotification(title, message, duration)
			duration = duration or 2
			local Notif = Instance.new("Frame")
			Notif.Size = UDim2.new(0, 250, 0, 70); Notif.Position = UDim2.new(1, 10, 1, -80)
			Notif.BackgroundColor3 = CurrentTheme.Panel; Notif.Parent = HubGui
			createCorner(Notif,10); createStroke(Notif, CurrentTheme.Primary,2)
			
			local TitleLabel = Instance.new("TextLabel")
			TitleLabel.Text = title; TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextSize = 15
			TitleLabel.TextColor3 = CurrentTheme.Primary; TitleLabel.Size = UDim2.new(1,-20,0,22)
			TitleLabel.Position = UDim2.new(0,10,0,8); TitleLabel.BackgroundTransparency = 1
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.Parent = Notif
			
			local MsgLabel = Instance.new("TextLabel")
			MsgLabel.Text = message; MsgLabel.Font = Enum.Font.Gotham; MsgLabel.TextSize = 13
			MsgLabel.TextColor3 = CurrentTheme.TextColor; MsgLabel.Size = UDim2.new(1,-20,0,30)
			MsgLabel.Position = UDim2.new(0,10,0,32); MsgLabel.BackgroundTransparency = 1
			MsgLabel.TextXAlignment = Enum.TextXAlignment.Left; MsgLabel.Parent = Notif

			TweenService:Create(Notif, TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Position = UDim2.new(1,-260,1,-80)}):Play()
			task.delay(duration, function()
				TweenService:Create(Notif, TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Position = UDim2.new(1,10,1,-80)}):Play()
				task.wait(0.4); Notif:Destroy()
			end)
		end

		return TabSetup
	end

	-- ══════════════════════════════════════
	--  MENU & CONFIG TABS
	-- ══════════════════════════════════════
	local MenuTab = CreateTabInternal("Menu", 9999)
	MenuTab:CreateToggle("Track Emloxa Ware Users", function(state) TrackerESPEnabled = state end)
	MenuTab:CreateDivider()

	local ConfigNameInput = ""
	local SelectedConfig = "No Configs Found"

	MenuTab:CreateTextbox("New Config Name", "Enter name to save...", function(val)
		ConfigNameInput = val
	end)

	local ConfigDropdown
	ConfigDropdown = MenuTab:CreateDropdown("Saved Configs", GetSavedConfigs(), GetSavedConfigs()[1], function(val)
		SelectedConfig = val
	end)

	MenuTab:CreateButton("💾 Save New Config", function()
		if ConfigNameInput == "" then 
			MenuTab:CreateNotification("Error", "Enter a name in the text box!", 2) return 
		end
		
		WindowSetup:CreatePrompt("Save Config", "Are you sure you want to save '"..ConfigNameInput.."'?", function(yes)
			if yes then
				local data = {}
				for _, entry in ipairs(ConfigCallbacks) do data[entry.id] = ConfigValues[entry.id] end
				pcall(function() writefile(ConfigFolder .. "/" .. ConfigNameInput .. ".json", HttpService:JSONEncode(data)) end)
				MenuTab:CreateNotification("Success", "Saved: " .. ConfigNameInput, 2)
				ConfigDropdown:Refresh(GetSavedConfigs())
			end
		end)
	end)

	MenuTab:CreateButton("📂 Load Selected Config", function()
		if SelectedConfig == "No Configs Found" then return end
		
		WindowSetup:CreatePrompt("Load Config", "Are you sure you want to load '"..SelectedConfig.."'?", function(yes)
			if yes then
				local path = ConfigFolder .. "/" .. SelectedConfig .. ".json"
				if isfile(path) then
					local s, json = pcall(function() return readfile(path) end)
					if s then
						local ds, data = pcall(HttpService.JSONDecode, HttpService, json)
						if ds then
							for id, value in pairs(data) do ConfigValues[id] = value end
							for _, entry in ipairs(ConfigCallbacks) do if ConfigValues[entry.id] ~= nil then entry.set(ConfigValues[entry.id]) end end
							MenuTab:CreateNotification("Loaded", SelectedConfig, 2)
						end
					end
				end
			end
		end)
	end)

	MenuTab:CreateButton("🗑️ Delete Selected Config", function()
		if SelectedConfig == "No Configs Found" then return end
		
		WindowSetup:CreatePrompt("Delete Config", "PERMANENTLY delete '"..SelectedConfig.."'?", function(yes)
			if yes then
				local path = ConfigFolder .. "/" .. SelectedConfig .. ".json"
				if isfile(path) then
					delfile(path)
					MenuTab:CreateNotification("Deleted", SelectedConfig, 2)
					ConfigDropdown:Refresh(GetSavedConfigs())
				end
			end
		end)
	end)

	function WindowSetup:CreateTab(tabName) return CreateTabInternal(tabName, #Tabs + 1) end
	return WindowSetup
end

return EmloxaLibrary
