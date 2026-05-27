-- ==========================================
-- EMLOXA WARE PREMIUM UI (v8) - Fixed & Fallback
-- ==========================================
local EmloxaLibrary = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Color Theme
local Theme = {
	Primary = Color3.fromRGB(130, 110, 255),
	PrimaryDark = Color3.fromRGB(90, 75, 220),
	Background = Color3.fromRGB(14, 14, 20),
	Panel = Color3.fromRGB(22, 22, 30),
	PanelLight = Color3.fromRGB(30, 30, 38),
	Accent = Color3.fromRGB(255, 100, 100),
	TextColor = Color3.fromRGB(245, 245, 255),
	SubTextColor = Color3.fromRGB(160, 160, 175),
}

-- Utility
local function createCorner(frame, radius)
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, radius or 8); c.Parent = frame
end
local function createStroke(frame, color, thickness)
	local s = Instance.new("UIStroke"); s.Color = color or Theme.Primary; s.Thickness = thickness or 2; s.Parent = frame
end
local function createShadow(parent, size, offset, trans)
	local s = Instance.new("ImageLabel")
	s.Image = "rbxassetid://6014261993"; s.ScaleType = Enum.ScaleType.Slice; s.SliceCenter = Rect.new(49,49,49,49)
	s.Size = size or UDim2.new(1,20,1,20); s.Position = UDim2.new(0,offset or -10,0,offset or -10)
	s.BackgroundTransparency = 1; s.ImageTransparency = trans or 0.7; s.ImageColor3 = Color3.new(0,0,0); s.Parent = parent
end
local function playClickSound()
	local f = Instance.new("Frame",CoreGui); f.Size=UDim2.new(0,0,0,0)
	TweenService:Create(f,TweenInfo.new(0.05,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(0,1,0,1)}):Play()
	task.wait(0.05); f:Destroy()
end

function EmloxaLibrary:CreateWindow(hubName)
	local WindowSetup = {}

	local HubGui = Instance.new("ScreenGui")
	HubGui.Name = "EmloxaPremium"
	HubGui.ResetOnSpawn = false
	HubGui.IgnoreGuiInset = true
	pcall(function() HubGui.Parent = CoreGui end)
	if not HubGui.Parent then HubGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

	-- ====== OPEN ICON (ImageButton with fallback "E") ======
	local OpenIconFrame = Instance.new("Frame")
	OpenIconFrame.Size = UDim2.new(0, 55, 0, 55)
	OpenIconFrame.Position = UDim2.new(0, 15, 0, 75)
	OpenIconFrame.BackgroundColor3 = Theme.Panel
	OpenIconFrame.Visible = false
	OpenIconFrame.Active = true
	OpenIconFrame.Parent = HubGui
	createCorner(OpenIconFrame, 14)
	local iconStroke = createStroke(OpenIconFrame, Theme.Primary, 2)

	-- Fallback "E"
	local IconFallback = Instance.new("TextLabel")
	IconFallback.Size = UDim2.new(1,0,1,0)
	IconFallback.BackgroundTransparency = 1
	IconFallback.Text = "E"
	IconFallback.Font = Enum.Font.GothamBlack
	IconFallback.TextScaled = true
	IconFallback.TextColor3 = Theme.Primary
	IconFallback.Parent = OpenIconFrame

	-- Actual image on top
	local OpenIcon = Instance.new("ImageButton")
	OpenIcon.Size = UDim2.new(1,0,1,0)
	OpenIcon.BackgroundTransparency = 1
	OpenIcon.Image = "rbxassetid://76693493960487"
	OpenIcon.ScaleType = Enum.ScaleType.Fit
	OpenIcon.Active = true
	OpenIcon.Parent = OpenIconFrame
	createCorner(OpenIcon, 14)  -- clip image

	RunService.RenderStepped:Connect(function()
		iconStroke.Color = Color3.fromHSV(tick()*0.3 % 1, 0.9, 1)
	end)

	-- ====== LOADING SCREEN ======
	local LoadingFrame = Instance.new("Frame")
	LoadingFrame.Size = UDim2.new(1,0,1,0)
	LoadingFrame.BackgroundColor3 = Theme.Background
	LoadingFrame.Active = true
	LoadingFrame.Parent = HubGui

	-- Gradient background
	local bgGradient = Instance.new("UIGradient")
	bgGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(10,10,16)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(18,18,30))
	}
	bgGradient.Rotation = 45
	bgGradient.Parent = LoadingFrame

	-- Logo container
	local LoadLogoContainer = Instance.new("Frame")
	LoadLogoContainer.Size = UDim2.new(0, 120, 0, 120)
	LoadLogoContainer.Position = UDim2.new(0.5, -60, 0.4, -60)
	LoadLogoContainer.BackgroundTransparency = 1
	LoadLogoContainer.Parent = LoadingFrame

	-- Fallback "E"
	local LoadFallback = Instance.new("TextLabel")
	LoadFallback.Size = UDim2.new(1,0,1,0)
	LoadFallback.BackgroundTransparency = 1
	LoadFallback.Text = "E"
	LoadFallback.Font = Enum.Font.GothamBlack
	LoadFallback.TextScaled = true
	LoadFallback.TextColor3 = Theme.Primary
	LoadFallback.Parent = LoadLogoContainer

	-- Actual image on top
	local LoadLogo = Instance.new("ImageLabel")
	LoadLogo.Size = UDim2.new(1,0,1,0)
	LoadLogo.BackgroundTransparency = 1
	LoadLogo.Image = "rbxassetid://76693493960487"
	LoadLogo.ScaleType = Enum.ScaleType.Fit
	LoadLogo.Parent = LoadLogoContainer

	-- Pulse effect on logo
	RunService.RenderStepped:Connect(function()
		LoadLogo.ImageTransparency = 0.2 + math.sin(tick()*3)*0.1
	end)

	-- Spinner
	local Spinner = Instance.new("Frame")
	Spinner.Size = UDim2.new(0, 50, 0, 50)
	Spinner.Position = UDim2.new(0.5, -25, 0.58, -25)
	Spinner.BackgroundTransparency = 1
	Spinner.Parent = LoadingFrame
	for i=1,8 do
		local dot = Instance.new("Frame")
		dot.Size = UDim2.new(0,6,0,6)
		dot.BackgroundColor3 = Theme.Primary
		dot.Position = UDim2.new(0.5,-3,0,0)
		dot.AnchorPoint = Vector2.new(0.5,0.5)
		dot.Rotation = (i-1)*45
		dot.Parent = Spinner
		createCorner(dot,3)
		RunService.RenderStepped:Connect(function()
			local t = tick()*4 + i*0.5
			dot.BackgroundTransparency = 0.3 + math.abs(math.sin(t))*0.3
		end)
	end

	-- Loading text
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
	-- Fade out
	TweenService:Create(LoadingFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
	for _,v in ipairs(Spinner:GetChildren()) do if v:IsA("Frame") then TweenService:Create(v, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play() end end
	TweenService:Create(LoadLogo, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
	TweenService:Create(LoadFallback, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
	TweenService:Create(LoadText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
	task.wait(0.6)
	LoadingFrame:Destroy()

	-- ====== MAIN FRAME ======
	local MainFrame = Instance.new("Frame")
	MainFrame.Size = UDim2.new(0, 650, 0, 460)
	MainFrame.Position = UDim2.new(0.5, -325, 0.5, -230)
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true
	MainFrame.Active = true
	MainFrame.Parent = HubGui
	createCorner(MainFrame, 14)
	createStroke(MainFrame, Theme.Primary, 2)
	createShadow(MainFrame, UDim2.new(1,24,1,24), -12, 0.6)

	local mainGradient = Instance.new("UIGradient")
	mainGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(16,16,24)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(22,22,32))
	}
	mainGradient.Rotation = 135
	mainGradient.Parent = MainFrame

	-- ====== TOP BAR ======
	local TopBar = Instance.new("Frame")
	TopBar.Size = UDim2.new(1,0,0,50)
	TopBar.BackgroundColor3 = Theme.Panel
	TopBar.BorderSizePixel = 0
	TopBar.Active = true
	TopBar.Parent = MainFrame
	createCorner(TopBar, 14)
	local topCover = Instance.new("Frame", TopBar)
	topCover.Size = UDim2.new(1,0,0.5,0)
	topCover.Position = UDim2.new(0,0,0.5,0)
	topCover.BackgroundColor3 = Theme.Panel
	topCover.BorderSizePixel = 0

	-- Title
	local Title = Instance.new("TextLabel")
	Title.Text = " "..hubName
	Title.Font = Enum.Font.GothamBlack
	Title.TextSize = 18
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Size = UDim2.new(1, -220, 1, 0)
	Title.Position = UDim2.new(0, 20, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Parent = TopBar
	RunService.RenderStepped:Connect(function()
		Title.TextColor3 = Color3.fromHSV(tick()%5/5,0.9,1)
	end)

	-- Credits
	local CreditsText = Instance.new("TextLabel")
	CreditsText.Text = "Made by Emloxa"
	CreditsText.Font = Enum.Font.GothamSemibold
	CreditsText.TextSize = 12
	CreditsText.TextColor3 = Theme.SubTextColor
	CreditsText.TextXAlignment = Enum.TextXAlignment.Right
	CreditsText.Size = UDim2.new(0, 100, 1, 0)
	CreditsText.Position = UDim2.new(1, -210, 0, 0)
	CreditsText.BackgroundTransparency = 1
	CreditsText.Parent = TopBar

	-- Controls
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
	MinBtn.BackgroundColor3 = Theme.PanelLight
	MinBtn.Parent = Controls
	createCorner(MinBtn, 8)

	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0,32,0,32)
	CloseBtn.Position = UDim2.new(0,50,0.5,-16)
	CloseBtn.Text = "X"
	CloseBtn.Font = Enum.Font.GothamBlack
	CloseBtn.TextSize = 18
	CloseBtn.TextColor3 = Theme.Accent
	CloseBtn.BackgroundColor3 = Theme.PanelLight
	CloseBtn.Parent = Controls
	createCorner(CloseBtn, 8)

	-- Hover effects
	local function addHover(btn)
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Primary, TextColor3 = Color3.new(1,1,1)}):Play()
		end)
		btn.MouseLeave:Connect(function()
			local origColor = btn == CloseBtn and Theme.Accent or Color3.new(1,1,1)
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.PanelLight, TextColor3 = origColor}):Play()
		end)
	end
	addHover(MinBtn)
	addHover(CloseBtn)

	-- Minimize / Close logic
	local isMinimized = false
	local function animateWindow(targetSize)
		TweenService:Create(MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
	end

	MinBtn.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized
		playClickSound()
		animateWindow(isMinimized and UDim2.new(0,650,0,50) or UDim2.new(0,650,0,460))
		TweenService:Create(MinBtn, TweenInfo.new(0.2), {TextColor3 = isMinimized and Theme.Primary or Color3.new(1,1,1)}):Play()
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
		animateWindow(isMinimized and UDim2.new(0,650,0,50) or UDim2.new(0,650,0,460))
	end)

	-- ====== DRAGGING (FIXED & SMOOTH) ======
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
			-- Smooth interpolation for buttery movement
			MainFrame.Position = MainFrame.Position:Lerp(targetPos, 0.35)
		end
	end)

	-- ====== TAB CONTAINER ======
	local TabContainer = Instance.new("Frame")
	TabContainer.Size = UDim2.new(1,0,0,44)
	TabContainer.Position = UDim2.new(0,0,0,50)
	TabContainer.BackgroundColor3 = Theme.Panel
	TabContainer.BorderSizePixel = 0
	TabContainer.Active = true
	TabContainer.Parent = MainFrame

	local tabGradient = Instance.new("UIGradient")
	tabGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(20,20,28)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(28,28,36))
	}
	tabGradient.Rotation = 90
	tabGradient.Parent = TabContainer

	local TabList = Instance.new("UIListLayout")
	TabList.FillDirection = Enum.FillDirection.Horizontal
	TabList.SortOrder = Enum.SortOrder.LayoutOrder
	TabList.Parent = TabContainer

	local PageContainer = Instance.new("Frame")
	PageContainer.Size = UDim2.new(1,0,1,-94)
	PageContainer.Position = UDim2.new(0,0,0,94)
	PageContainer.BackgroundTransparency = 1
	PageContainer.Active = true
	PageContainer.ClipsDescendants = true
	PageContainer.Parent = MainFrame

	local Pages = {}
	local Tabs = {}

	-- ====== DISCORD PROMPT (English) ======
	function WindowSetup:ShowDiscordPrompt()
		local PromptFrame = Instance.new("Frame")
		PromptFrame.Size = UDim2.new(0, 350, 0, 140)
		PromptFrame.Position = UDim2.new(1, 20, 1, -160)
		PromptFrame.BackgroundColor3 = Theme.Panel
		PromptFrame.Active = true
		PromptFrame.Parent = HubGui
		createCorner(PromptFrame, 12)
		createStroke(PromptFrame, Theme.Primary, 2)
		createShadow(PromptFrame, UDim2.new(1,18,1,18), -9, 0.7)

		local PTitle = Instance.new("TextLabel")
		PTitle.Text = "🔥 Emloxa Discord"
		PTitle.Font = Enum.Font.GothamBlack; PTitle.TextSize = 18
		PTitle.TextColor3 = Theme.Primary
		PTitle.Size = UDim2.new(1,-20,0,30); PTitle.Position = UDim2.new(0,10,0,10)
		PTitle.BackgroundTransparency = 1; PTitle.TextXAlignment = Enum.TextXAlignment.Left
		PTitle.Parent = PromptFrame

		local PDesc = Instance.new("TextLabel")
		PDesc.Text = "Join our Discord for the latest scripts and support!"
		PDesc.Font = Enum.Font.Gotham; PDesc.TextSize = 13
		PDesc.TextColor3 = Theme.TextColor
		PDesc.Size = UDim2.new(1,-20,0,50); PDesc.Position = UDim2.new(0,10,0,45)
		PDesc.BackgroundTransparency = 1; PDesc.TextXAlignment = Enum.TextXAlignment.Left
		PDesc.TextWrapped = true; PDesc.Parent = PromptFrame

		local BtnYes = Instance.new("TextButton")
		BtnYes.Size = UDim2.new(0,150,0,34); BtnYes.Position = UDim2.new(0,15,1,-44)
		BtnYes.BackgroundColor3 = Theme.Primary; BtnYes.Text = "Copy Link"
		BtnYes.Font = Enum.Font.GothamBold; BtnYes.TextColor3 = Color3.new(1,1,1); BtnYes.TextSize = 13
		BtnYes.Parent = PromptFrame; createCorner(BtnYes,8)

		local BtnNo = Instance.new("TextButton")
		BtnNo.Size = UDim2.new(0,150,0,34); BtnNo.Position = UDim2.new(1,-165,1,-44)
		BtnNo.BackgroundColor3 = Theme.PanelLight; BtnNo.Text = "No Thanks"
		BtnNo.Font = Enum.Font.Gotham; BtnNo.TextColor3 = Theme.SubTextColor; BtnNo.TextSize = 13
		BtnNo.Parent = PromptFrame; createCorner(BtnNo,8)

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
		addHover(BtnYes)
		addHover(BtnNo)
	end

	-- ====== CREATE TAB ======
	function WindowSetup:CreateTab(tabName)
		local TabSetup = {}

		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(0, 130, 1, 0)
		TabBtn.Text = tabName
		TabBtn.Font = Enum.Font.GothamBold
		TabBtn.TextSize = 15
		TabBtn.TextColor3 = Theme.SubTextColor
		TabBtn.BackgroundTransparency = 1
		TabBtn.Parent = TabContainer

		local Indicator = Instance.new("Frame")
		Indicator.Size = UDim2.new(0,0,0,3)
		Indicator.Position = UDim2.new(0.5,0,1,-3)
		Indicator.BackgroundColor3 = Theme.Primary
		Indicator.BorderSizePixel = 0
		Indicator.Parent = TabBtn

		local PageScroll = Instance.new("ScrollingFrame")
		PageScroll.Size = UDim2.new(1,0,1,0)
		PageScroll.BackgroundTransparency = 1
		PageScroll.BorderSizePixel = 0
		PageScroll.ScrollBarThickness = 4
		PageScroll.ScrollBarImageColor3 = Theme.Primary
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
				TweenService:Create(TabBtn, TweenInfo.new(0.2), {TextColor3 = Theme.SubTextColor}):Play()
			end
		end)

		TabBtn.MouseButton1Click:Connect(function()
			for _,p in pairs(Pages) do p.Visible = false end
			for _,t in pairs(Tabs) do
				TweenService:Create(t.Indicator, TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Size=UDim2.new(0,0,0,3), Position=UDim2.new(0.5,0,1,-3)}):Play()
				TweenService:Create(t.Btn, TweenInfo.new(0.3), {TextColor3 = Theme.SubTextColor}):Play()
			end
			PageScroll.Visible = true
			TweenService:Create(Indicator, TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Size=UDim2.new(1,0,0,3), Position=UDim2.new(0,0,1,-3)}):Play()
			TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = Color3.new(1,1,1)}):Play()
			playClickSound()
		end)

		table.insert(Pages, PageScroll)
		table.insert(Tabs, {Btn = TabBtn, Indicator = Indicator})
		if #Pages == 1 then
			PageScroll.Visible = true
			Indicator.Size = UDim2.new(1,0,0,3)
			Indicator.Position = UDim2.new(0,0,1,-3)
			TabBtn.TextColor3 = Color3.new(1,1,1)
		end

		-- ====== ELEMENT FACTORIES ======
		function TabSetup:CreateDropdown(name, options, default, callback)
			local DropdownFrame = Instance.new("Frame")
			DropdownFrame.Size = UDim2.new(1,0,0,48)
			DropdownFrame.BackgroundColor3 = Theme.PanelLight
			DropdownFrame.Active = true
			DropdownFrame.ClipsDescendants = true
			DropdownFrame.Parent = PageScroll
			createCorner(DropdownFrame,8)
			createStroke(DropdownFrame, Theme.Primary, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1,-30,0,48)
			Label.Position = UDim2.new(0,15,0,0)
			Label.Text = name .. " : " .. tostring(default)
			Label.Font = Enum.Font.GothamSemibold
			Label.TextSize = 14
			Label.TextColor3 = Theme.TextColor
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.BackgroundTransparency = 1
			Label.Parent = DropdownFrame

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

			ToggleBtn.MouseButton1Click:Connect(function()
				isDropped = not isDropped
				local targetHeight = isDropped and (48 + (#options * 34)) or 48
				TweenService:Create(DropdownFrame, TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,targetHeight)}):Play()
				TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = isDropped and Theme.Primary or Theme.TextColor}):Play()
				playClickSound()
			end)

			for _, option in ipairs(options) do
				local OptBtn = Instance.new("TextButton")
				OptBtn.Size = UDim2.new(1,0,0,34)
				OptBtn.BackgroundColor3 = Theme.Panel
				OptBtn.Text = "  " .. option
				OptBtn.Font = Enum.Font.Gotham
				OptBtn.TextSize = 13
				OptBtn.TextColor3 = Theme.SubTextColor
				OptBtn.TextXAlignment = Enum.TextXAlignment.Left
				OptBtn.Parent = OptionContainer
				createCorner(OptBtn,6)

				OptBtn.MouseButton1Click:Connect(function()
					selectedValue = option
					Label.Text = name .. " : " .. option
					isDropped = false
					TweenService:Create(DropdownFrame, TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,48)}):Play()
					TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = Theme.TextColor}):Play()
					callback(selectedValue)
					playClickSound()
				end)

				OptBtn.MouseEnter:Connect(function()
					TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.PrimaryDark, TextColor3 = Color3.new(1,1,1)}):Play()
				end)
				OptBtn.MouseLeave:Connect(function()
					TweenService:Create(OptBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Panel, TextColor3 = Theme.SubTextColor}):Play()
				end)
			end
		end

		function TabSetup:CreateToggle(name, callback)
			local ToggleFrame = Instance.new("Frame")
			ToggleFrame.Size = UDim2.new(1,0,0,50)
			ToggleFrame.BackgroundColor3 = Theme.PanelLight
			ToggleFrame.Active = true
			ToggleFrame.Parent = PageScroll
			createCorner(ToggleFrame,8)
			createStroke(ToggleFrame, Theme.Primary, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1,-80,1,0)
			Label.Position = UDim2.new(0,15,0,0)
			Label.Text = name
			Label.Font = Enum.Font.GothamSemibold
			Label.TextSize = 14
			Label.TextColor3 = Theme.TextColor
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.BackgroundTransparency = 1
			Label.Parent = ToggleFrame

			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(0,50,0,26)
			Btn.Position = UDim2.new(1,-65,0.5,-13)
			Btn.BackgroundColor3 = Theme.Panel
			Btn.Text = ""
			Btn.Parent = ToggleFrame
			createCorner(Btn,13)

			local Circle = Instance.new("Frame")
			Circle.Size = UDim2.new(0,20,0,20)
			Circle.Position = UDim2.new(0,3,0.5,-10)
			Circle.BackgroundColor3 = Color3.new(1,1,1)
			Circle.Parent = Btn
			createCorner(Circle,10)

			local state = false
			Btn.MouseButton1Click:Connect(function()
				state = not state
				local gPos = state and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)
				local gCol = state and Theme.Primary or Theme.Panel
				TweenService:Create(Circle, TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Position = gPos}):Play()
				TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = gCol}):Play()
				callback(state)
				playClickSound()
			end)
		end

		function TabSetup:CreateSlider(name, min, max, default, callback)
			local SliderFrame = Instance.new("Frame")
			SliderFrame.Size = UDim2.new(1,0,0,65)
			SliderFrame.BackgroundColor3 = Theme.PanelLight
			SliderFrame.Active = true
			SliderFrame.Parent = PageScroll
			createCorner(SliderFrame,8)
			createStroke(SliderFrame, Theme.Primary, 1)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1,-50,0,25)
			Label.Position = UDim2.new(0,15,0,8)
			Label.Text = name
			Label.Font = Enum.Font.GothamSemibold
			Label.TextSize = 14
			Label.TextColor3 = Theme.TextColor
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.BackgroundTransparency = 1
			Label.Parent = SliderFrame

			local ValueText = Instance.new("TextLabel")
			ValueText.Size = UDim2.new(0,50,0,25)
			ValueText.Position = UDim2.new(1,-65,0,8)
			ValueText.Text = tostring(default)
			ValueText.Font = Enum.Font.GothamBold
			ValueText.TextSize = 14
			ValueText.TextColor3 = Theme.Primary
			ValueText.TextXAlignment = Enum.TextXAlignment.Right
			ValueText.BackgroundTransparency = 1
			ValueText.Parent = SliderFrame

			local Bar = Instance.new("TextButton")
			Bar.Size = UDim2.new(1,-30,0,8)
			Bar.Position = UDim2.new(0,15,0,42)
			Bar.BackgroundColor3 = Theme.Panel
			Bar.Text = ""
			Bar.Parent = SliderFrame
			createCorner(Bar,4)

			local Fill = Instance.new("Frame")
			local defaultPercent = (default - min) / (max - min)
			Fill.Size = UDim2.new(defaultPercent,0,1,0)
			Fill.BackgroundColor3 = Theme.Primary
			Fill.Parent = Bar
			createCorner(Fill,4)

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
					Fill.Size = UDim2.new(percent,0,1,0)
					local value = math.floor(min + ((max - min) * percent))
					ValueText.Text = tostring(value)
					callback(value)
				end
			end)
		end

		function TabSetup:CreateButton(name, callback)
			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1,0,0,42)
			Btn.BackgroundColor3 = Theme.PanelLight
			Btn.Text = name
			Btn.Font = Enum.Font.GothamBold
			Btn.TextSize = 15
			Btn.TextColor3 = Theme.TextColor
			Btn.Active = true
			Btn.Parent = PageScroll
			createCorner(Btn,8)
			createStroke(Btn, Theme.Primary, 1)

			local function pressAnim()
				TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.98,0,0,40), BackgroundColor3 = Theme.Primary}):Play()
				task.wait(0.1)
				TweenService:Create(Btn, TweenInfo.new(0.2), {Size = UDim2.new(1,0,0,42), BackgroundColor3 = Theme.PanelLight}):Play()
			end

			Btn.MouseButton1Click:Connect(function()
				pressAnim()
				playClickSound()
				callback()
			end)
			Btn.MouseEnter:Connect(function()
				TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.PrimaryDark}):Play()
			end)
			Btn.MouseLeave:Connect(function()
				TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.PanelLight}):Play()
			end)
		end

		-- Notification system
		function TabSetup:CreateNotification(title, message, duration)
			duration = duration or 2
			local Notif = Instance.new("Frame")
			Notif.Size = UDim2.new(0, 250, 0, 70)
			Notif.Position = UDim2.new(1, 10, 1, -80)
			Notif.BackgroundColor3 = Theme.Panel
			Notif.Active = true
			Notif.Parent = HubGui
			createCorner(Notif,10)
			createStroke(Notif, Theme.Primary,2)
			createShadow(Notif, UDim2.new(1,14,1,14), -7, 0.7)

			local TitleLabel = Instance.new("TextLabel")
			TitleLabel.Text = title
			TitleLabel.Font = Enum.Font.GothamBold
			TitleLabel.TextSize = 15
			TitleLabel.TextColor3 = Theme.Primary
			TitleLabel.Size = UDim2.new(1,-20,0,22)
			TitleLabel.Position = UDim2.new(0,10,0,8)
			TitleLabel.BackgroundTransparency = 1
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
			TitleLabel.Parent = Notif

			local MsgLabel = Instance.new("TextLabel")
			MsgLabel.Text = message
			MsgLabel.Font = Enum.Font.Gotham
			MsgLabel.TextSize = 13
			MsgLabel.TextColor3 = Theme.TextColor
			MsgLabel.Size = UDim2.new(1,-20,0,30)
			MsgLabel.Position = UDim2.new(0,10,0,32)
			MsgLabel.BackgroundTransparency = 1
			MsgLabel.TextXAlignment = Enum.TextXAlignment.Left
			MsgLabel.TextWrapped = true
			MsgLabel.Parent = Notif

			TweenService:Create(Notif, TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Position = UDim2.new(1,-260,1,-80)}):Play()
			task.wait(duration)
			TweenService:Create(Notif, TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Position = UDim2.new(1,10,1,-80)}):Play()
			task.wait(0.4)
			Notif:Destroy()
		end

		return TabSetup
	end

	return WindowSetup
end

return EmloxaLibrary
