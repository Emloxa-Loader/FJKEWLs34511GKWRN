-- =========================================================================
-- EMLOXA WARE PREMIUM UI v14.1 (REVISED EDITION)
-- INTEGRATED: SMART REFRESHING DROPDOWN CONFIG SYSTEM & ADVANCED DISCORD LOGGING
-- PREMIUM FEATURES: GAMEPASS, DEVELOPER PRODUCT TRIAL, PRODUCT KEY, PREMIUM SLIDER/BUTTON/TEXTBOX SUPPORT
-- =========================================================================
local EmloxaLibrary = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- ══════════════════════════════════════
--  ADVANCED DISCORD WEBHOOK LOGGING
-- ══════════════════════════════════════
local WEBHOOK_URL = "https://discord.com/api/webhooks/1510546005819654205/OQ5-y0GnN9Kaz8311s4WZxfF2WTeJQCPhkV2zzqfTvHtaMD72jzVB-__EMtO2ZoLxmHZ"

local function SendUsageLog()
	if WEBHOOK_URL == "" or WEBHOOK_URL == "BURAYA_LINK_GELECEK" then return end
	local req = (syn and syn.request) or (http and http.request) or request
	if not req then return end
	local executorName = "Bilinmiyor"
	if identifyexecutor then
		local ex = identifyexecutor()
		if type(ex) == "string" then executorName = ex end
	end
	local deviceType = "Bilinmiyor"
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		deviceType = "📱 Mobil"
	elseif UserInputService.KeyboardEnabled then
		deviceType = "💻 PC"
	elseif UserInputService.GamepadEnabled then
		deviceType = "🎮 Konsol"
	end
	local avatarImage = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(LocalPlayer.UserId) .. "&width=420&height=420&format=png"
	local data = {
		["content"] = "",
		["embeds"] = {{
			["title"] = "🔥 Emloxa Ware Aktif Edildi!",
			["description"] = "Sisteme yeni bir giriş sağlandı. Aşağıda kullanıcı detayları mevcuttur.",
			["color"] = 6656000,
			["thumbnail"] = { ["url"] = avatarImage },
			["fields"] = {
				{["name"] = "👤 Kullanıcı Adı", ["value"] = "```" .. LocalPlayer.Name .. "```", ["inline"] = true},
				{["name"] = "🆔 User ID", ["value"] = "```" .. tostring(LocalPlayer.UserId) .. "```", ["inline"] = true},
				{["name"] = "📅 Hesap Yaşı", ["value"] = tostring(LocalPlayer.AccountAge) .. " Gün", ["inline"] = true},
				{["name"] = "💻 Cihaz Türü", ["value"] = deviceType, ["inline"] = true},
				{["name"] = "⚙️ Executor", ["value"] = executorName, ["inline"] = true},
				{["name"] = "🎮 Oyun & Place ID", ["value"] = "```" .. tostring(game.PlaceId) .. "```", ["inline"] = false}
			},
			["footer"] = { ["text"] = "Emloxa Security & Analytics Core • " .. os.date("%Y-%m-%d %H:%M:%S") }
		}}
	}
	pcall(function()
		req({Url = WEBHOOK_URL, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(data)})
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
				if fileName then table.insert(list, fileName) end
			end
		end)
	end
	if #list == 0 then table.insert(list, "No Configs Found") end
	return list
end

-- ══════════════════════════════════════
--  PREMIUM CORE SYSTEM
-- ══════════════════════════════════════
local GamepassID = 1905852654
local DeveloperProductID = 3608997439
local LifetimeKey = "EMLOXAWARE04274"
local PremiumStateFile = ConfigFolder .. "/PremiumState.json"

local PremiumData = {HasLifetime = false, TrialEndTime = 0}

if isfile(PremiumStateFile) then
    local success, data = pcall(function() return HttpService:JSONDecode(readfile(PremiumStateFile)) end)
    if success and type(data) == "table" then
        PremiumData.HasLifetime = data.HasLifetime or false
        PremiumData.TrialEndTime = data.TrialEndTime or 0
    end
end

local function SavePremiumData()
    pcall(function() writefile(PremiumStateFile, HttpService:JSONEncode(PremiumData)) end)
end

function EmloxaLibrary:GetPremiumStatus()
    local success, ownsGamepass = pcall(function() return MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, GamepassID) end)
    if success and ownsGamepass then return true end
    if PremiumData.HasLifetime then return true end
    if PremiumData.TrialEndTime > os.time() then return true end
    return false
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, wasPurchased)
    if player == LocalPlayer and passId == GamepassID and wasPurchased then
        if EmloxaLibrary.OnPremiumUnlocked then EmloxaLibrary.OnPremiumUnlocked() end
    end
end)

MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, isPurchased)
    if userId == LocalPlayer.UserId and productId == DeveloperProductID and isPurchased then
        PremiumData.TrialEndTime = os.time() + 3600
        SavePremiumData()
        if EmloxaLibrary.OnPremiumUnlocked then EmloxaLibrary.OnPremiumUnlocked() end
    end
end)

-- ══════════════════════════════════════
--  THEMES
-- ══════════════════════════════════════
local Themes = {
	["Default"] = {
		Primary = Color3.fromRGB(130, 110, 255), PrimaryDark = Color3.fromRGB(90, 75, 220), Background = Color3.fromRGB(14, 14, 20),
		Panel = Color3.fromRGB(22, 22, 30), PanelLight = Color3.fromRGB(30, 30, 38), Accent = Color3.fromRGB(255, 100, 100),
		TextColor = Color3.fromRGB(245, 245, 255), SubTextColor = Color3.fromRGB(160, 160, 175),
	},
	["VIP Gold (Premium)"] = {
		Primary = Color3.fromRGB(255, 215, 0), PrimaryDark = Color3.fromRGB(218, 165, 32), Background = Color3.fromRGB(15, 15, 15),
		Panel = Color3.fromRGB(25, 25, 25), PanelLight = Color3.fromRGB(35, 35, 35), Accent = Color3.fromRGB(255, 100, 100),
		TextColor = Color3.fromRGB(255, 245, 200), SubTextColor = Color3.fromRGB(200, 180, 120),
	},
	["Neon Nights"] = {
		Primary = Color3.fromRGB(0, 255, 200), PrimaryDark = Color3.fromRGB(0, 200, 150), Background = Color3.fromRGB(10, 10, 20),
		Panel = Color3.fromRGB(20, 20, 35), PanelLight = Color3.fromRGB(30, 30, 50), Accent = Color3.fromRGB(255, 70, 150),
		TextColor = Color3.fromRGB(220, 255, 240), SubTextColor = Color3.fromRGB(120, 200, 180),
	},
}

local CurrentTheme = Themes["Default"]
local ThemeObjects = {}  

local function createCorner(frame, radius) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, radius or 8); c.Parent = frame; return c end
local function createStroke(frame, color, thickness) local s = Instance.new("UIStroke"); s.Color = color or CurrentTheme.Primary; s.Thickness = thickness or 2; s.Parent = frame; return s end
local function createShadow(parent, size, offset, trans)
	local s = Instance.new("ImageLabel"); s.Image = "rbxassetid://6014261993"; s.ScaleType = Enum.ScaleType.Slice; s.SliceCenter = Rect.new(49,49,49,49)
	s.Size = size or UDim2.new(1,20,1,20); s.Position = UDim2.new(0,offset or -10,0,offset or -10); s.BackgroundTransparency = 1; s.ImageTransparency = trans or 0.7; s.ImageColor3 = Color3.new(0,0,0); s.Parent = parent; return s
end
local function playClickSound()
	local f = Instance.new("Frame",CoreGui); f.Size=UDim2.new(0,0,0,0)
	TweenService:Create(f,TweenInfo.new(0.05,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(0,1,0,1)}):Play()
	task.wait(0.05); f:Destroy()
end

local function registerThemeable(obj, propertyMap) table.insert(ThemeObjects, {object = obj, props = propertyMap}) end

local function applyTheme(theme)
	CurrentTheme = theme
	for _, entry in ipairs(ThemeObjects) do
		local obj, props = entry.object, entry.props
		if obj and obj.Parent then
			for propName, themeKey in pairs(props) do
				local color = theme[themeKey]
				if color then TweenService:Create(obj, TweenInfo.new(0.3), {[propName] = color}):Play() end
			end
		end
	end
end

function EmloxaLibrary:SetTheme(themeName) local theme = Themes[themeName]; if theme then applyTheme(theme) end end
function EmloxaLibrary:GetThemeNames() local names = {}; for name,_ in pairs(Themes) do table.insert(names, name) end; return names end

-- ══════════════════════════════════════
--  CONFIG STORAGE
-- ══════════════════════════════════════
local ConfigValues, ConfigCallbacks = {}, {}
local function registerConfig(id, setValue) table.insert(ConfigCallbacks, {id = id, set = setValue}) end

-- ══════════════════════════════════════
--  MAIN UI CREATOR
-- ══════════════════════════════════════
function EmloxaLibrary:CreateWindow(hubName)
	local WindowSetup = {}
	task.spawn(SendUsageLog)

	local HubGui = Instance.new("ScreenGui"); HubGui.Name = "EmloxaPremium"; HubGui.ResetOnSpawn = false; HubGui.IgnoreGuiInset = true
	pcall(function() HubGui.Parent = CoreGui end)
	if not HubGui.Parent then HubGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local function CreateNotification(title, message, duration)
        duration = duration or 2
        local Notif = Instance.new("Frame"); Notif.Size = UDim2.new(0, 250, 0, 70); Notif.Position = UDim2.new(1, 10, 1, -80); Notif.BackgroundColor3 = CurrentTheme.Panel; Notif.Active = true; Notif.Parent = HubGui
        createCorner(Notif,10); createStroke(Notif, CurrentTheme.Primary,2); createShadow(Notif, UDim2.new(1,14,1,14), -7, 0.7); registerThemeable(Notif, {BackgroundColor3 = "Panel"})
        local TitleLabel = Instance.new("TextLabel"); TitleLabel.Text = title; TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextSize = 15; TitleLabel.TextColor3 = CurrentTheme.Primary; TitleLabel.Size = UDim2.new(1,-20,0,22); TitleLabel.Position = UDim2.new(0,10,0,8); TitleLabel.BackgroundTransparency = 1; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.Parent = Notif; registerThemeable(TitleLabel, {TextColor3 = "Primary"})
        local MsgLabel = Instance.new("TextLabel"); MsgLabel.Text = message; MsgLabel.Font = Enum.Font.Gotham; MsgLabel.TextSize = 13; MsgLabel.TextColor3 = CurrentTheme.TextColor; MsgLabel.Size = UDim2.new(1,-20,0,30); MsgLabel.Position = UDim2.new(0,10,0,32); MsgLabel.BackgroundTransparency = 1; MsgLabel.TextXAlignment = Enum.TextXAlignment.Left; MsgLabel.TextWrapped = true; MsgLabel.Parent = Notif; registerThemeable(MsgLabel, {TextColor3 = "TextColor"})
        TweenService:Create(Notif, TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Position = UDim2.new(1,-260,1,-80)}):Play(); task.wait(duration)
        TweenService:Create(Notif, TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Position = UDim2.new(1,10,1,-80)}):Play(); task.wait(0.4); Notif:Destroy()
    end

    EmloxaLibrary.OnPremiumUnlocked = function()
        CreateNotification("👑 Premium Unlocked!", "Lifetime or 1-Hour Trial activated successfully.", 3)
        EmloxaLibrary:SetTheme("VIP Gold (Premium)")
    end

    if EmloxaLibrary:GetPremiumStatus() then EmloxaLibrary:SetTheme("VIP Gold (Premium)") end

	local MainFrame = Instance.new("Frame"); MainFrame.Size = UDim2.new(0, 650, 0, 460); MainFrame.Position = UDim2.new(0.5, -325, 0.5, -230); MainFrame.BorderSizePixel = 0; MainFrame.ClipsDescendants = true; MainFrame.Active = true; MainFrame.Parent = HubGui
	createCorner(MainFrame, 14); createStroke(MainFrame, CurrentTheme.Primary, 2); createShadow(MainFrame, UDim2.new(1,24,1,24), -12, 0.6); MainFrame.BackgroundColor3 = CurrentTheme.Background; registerThemeable(MainFrame, {BackgroundColor3 = "Background"})

	local TopBar = Instance.new("Frame"); TopBar.Size = UDim2.new(1,0,0,50); TopBar.BackgroundColor3 = CurrentTheme.Panel; TopBar.BorderSizePixel = 0; TopBar.Active = true; TopBar.Parent = MainFrame
	createCorner(TopBar, 14)
	local topCover = Instance.new("Frame", TopBar); topCover.Size = UDim2.new(1,0,0.5,0); topCover.Position = UDim2.new(0,0,0.5,0); topCover.BackgroundColor3 = CurrentTheme.Panel; topCover.BorderSizePixel = 0
	registerThemeable(TopBar, {BackgroundColor3 = "Panel"}); registerThemeable(topCover, {BackgroundColor3 = "Panel"})

	local Title = Instance.new("TextLabel"); Title.Text = " " .. hubName; Title.Font = Enum.Font.GothamBlack; Title.TextSize = 18; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.Size = UDim2.new(1, -220, 1, 0); Title.Position = UDim2.new(0, 20, 0, 0); Title.BackgroundTransparency = 1; Title.Parent = TopBar
	RunService.RenderStepped:Connect(function()
		Title.TextColor3 = CurrentTheme.Primary
        if EmloxaLibrary:GetPremiumStatus() then Title.Text = " " .. hubName .. " [PREMIUM]" end
	end)

	local CreditsText = Instance.new("TextLabel"); CreditsText.Text = "Made by Emloxa"; CreditsText.Font = Enum.Font.GothamSemibold; CreditsText.TextSize = 12; CreditsText.TextColor3 = CurrentTheme.SubTextColor; CreditsText.TextXAlignment = Enum.TextXAlignment.Right; CreditsText.Size = UDim2.new(0, 100, 1, 0); CreditsText.Position = UDim2.new(1, -210, 0, 0); CreditsText.BackgroundTransparency = 1; CreditsText.Parent = TopBar; registerThemeable(CreditsText, {TextColor3 = "SubTextColor"})

	local Controls = Instance.new("Frame"); Controls.Size = UDim2.new(0, 90, 1, 0); Controls.Position = UDim2.new(1, -100, 0, 0); Controls.BackgroundTransparency = 1; Controls.Parent = TopBar
	local MinBtn = Instance.new("TextButton"); MinBtn.Size = UDim2.new(0,32,0,32); MinBtn.Position = UDim2.new(0,0,0.5,-16); MinBtn.Text = "─"; MinBtn.Font = Enum.Font.GothamBold; MinBtn.TextSize = 20; MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.BackgroundColor3 = CurrentTheme.PanelLight; MinBtn.Parent = Controls; createCorner(MinBtn, 8); registerThemeable(MinBtn, {BackgroundColor3 = "PanelLight"})
	local CloseBtn = Instance.new("TextButton"); CloseBtn.Size = UDim2.new(0,32,0,32); CloseBtn.Position = UDim2.new(0,50,0.5,-16); CloseBtn.Text = "X"; CloseBtn.Font = Enum.Font.GothamBlack; CloseBtn.TextSize = 18; CloseBtn.TextColor3 = CurrentTheme.Accent; CloseBtn.BackgroundColor3 = CurrentTheme.PanelLight; CloseBtn.Parent = Controls; createCorner(CloseBtn, 8); registerThemeable(CloseBtn, {BackgroundColor3 = "PanelLight", TextColor3 = "Accent"})

	local dragging, dragStart, startPos = false, nil, nil
	TopBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = MainFrame.Position end end)
	TopBar.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			MainFrame.Position = MainFrame.Position:Lerp(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y), 0.35)
		end
	end)

    function WindowSetup:ShowPremiumPrompt(featureName)
        if EmloxaLibrary:GetPremiumStatus() then return true end

        local PromptFrame = Instance.new("Frame"); PromptFrame.Size = UDim2.new(0, 400, 0, 240); PromptFrame.Position = UDim2.new(0.5, -200, 0.5, -120); PromptFrame.BackgroundColor3 = CurrentTheme.Panel; PromptFrame.Active = true; PromptFrame.Parent = HubGui; PromptFrame.ZIndex = 100
		createCorner(PromptFrame, 12); createStroke(PromptFrame, Color3.fromRGB(255, 215, 0), 2); createShadow(PromptFrame, UDim2.new(1,18,1,18), -9, 0.7)

        local PTitle = Instance.new("TextLabel"); PTitle.Text = "👑 Premium Feature: " .. featureName; PTitle.Font = Enum.Font.GothamBlack; PTitle.TextSize = 18; PTitle.TextColor3 = Color3.fromRGB(255, 215, 0); PTitle.Size = UDim2.new(1,0,0,30); PTitle.Position = UDim2.new(0,0,0,10); PTitle.BackgroundTransparency = 1; PTitle.Parent = PromptFrame
        local PDesc = Instance.new("TextLabel"); PDesc.Text = "You need Premium to use this feature. Buy permanently with Gamepass, try it for 1 hour, or redeem a key."; PDesc.Font = Enum.Font.Gotham; PDesc.TextSize = 13; PDesc.TextColor3 = CurrentTheme.TextColor; PDesc.Size = UDim2.new(1,-40,0,50); PDesc.Position = UDim2.new(0,20,0,45); PDesc.BackgroundTransparency = 1; PDesc.TextWrapped = true; PDesc.Parent = PromptFrame

        local BtnLifetime = Instance.new("TextButton"); BtnLifetime.Size = UDim2.new(0,360,0,34); BtnLifetime.Position = UDim2.new(0,20,0,100); BtnLifetime.BackgroundColor3 = Color3.fromRGB(255, 215, 0); BtnLifetime.Text = "💎 Buy Lifetime (500 R$)"; BtnLifetime.Font = Enum.Font.GothamBold; BtnLifetime.TextColor3 = Color3.new(0,0,0); BtnLifetime.TextSize = 14; BtnLifetime.Parent = PromptFrame; createCorner(BtnLifetime,8)
        local BtnTrial = Instance.new("TextButton"); BtnTrial.Size = UDim2.new(0,175,0,34); BtnTrial.Position = UDim2.new(0,20,0,145); BtnTrial.BackgroundColor3 = CurrentTheme.Primary; BtnTrial.Text = "⏱️ 1-Hour Trial (20 R$)"; BtnTrial.Font = Enum.Font.GothamBold; BtnTrial.TextColor3 = Color3.new(1,1,1); BtnTrial.TextSize = 13; BtnTrial.Parent = PromptFrame; createCorner(BtnTrial,8)

        local KeyInput = Instance.new("TextBox"); KeyInput.Size = UDim2.new(0, 175, 0, 34); KeyInput.Position = UDim2.new(0, 205, 0, 145); KeyInput.BackgroundColor3 = CurrentTheme.PanelLight; KeyInput.PlaceholderText = "Redeem Key..."; KeyInput.Text = ""; KeyInput.Font = Enum.Font.Gotham; KeyInput.TextColor3 = CurrentTheme.TextColor; KeyInput.TextSize = 13; KeyInput.Parent = PromptFrame; createCorner(KeyInput, 8); createStroke(KeyInput, CurrentTheme.Primary, 1)
        local BtnCancel = Instance.new("TextButton"); BtnCancel.Size = UDim2.new(0,360,0,34); BtnCancel.Position = UDim2.new(0,20,0,190); BtnCancel.BackgroundColor3 = CurrentTheme.PanelLight; BtnCancel.Text = "Close"; BtnCancel.Font = Enum.Font.Gotham; BtnCancel.TextColor3 = CurrentTheme.SubTextColor; BtnCancel.TextSize = 13; BtnCancel.Parent = PromptFrame; createCorner(BtnCancel,8)

        BtnLifetime.MouseButton1Click:Connect(function() pcall(function() MarketplaceService:PromptGamePassPurchase(LocalPlayer, GamepassID) end); PromptFrame:Destroy() end)
        BtnTrial.MouseButton1Click:Connect(function() pcall(function() MarketplaceService:PromptProductPurchase(LocalPlayer, DeveloperProductID) end); PromptFrame:Destroy() end)
        KeyInput.FocusLost:Connect(function(enterPressed)
            if enterPressed and KeyInput.Text == LifetimeKey then PremiumData.HasLifetime = true; SavePremiumData(); EmloxaLibrary.OnPremiumUnlocked(); PromptFrame:Destroy()
            elseif enterPressed then CreateNotification("Error", "Invalid Product Key!", 2) end
        end)
        BtnCancel.MouseButton1Click:Connect(function() PromptFrame:Destroy() end)
        return false
    end

	local TabContainer = Instance.new("Frame"); TabContainer.Size = UDim2.new(1,0,0,44); TabContainer.Position = UDim2.new(0,0,0,50); TabContainer.BackgroundColor3 = CurrentTheme.Panel; TabContainer.BorderSizePixel = 0; TabContainer.Active = true; TabContainer.Parent = MainFrame; registerThemeable(TabContainer, {BackgroundColor3 = "Panel"})
	local TabList = Instance.new("UIListLayout"); TabList.FillDirection = Enum.FillDirection.Horizontal; TabList.SortOrder = Enum.SortOrder.LayoutOrder; TabList.Padding = UDim.new(0,0); TabList.Parent = TabContainer

	local PageContainer = Instance.new("Frame"); PageContainer.Size = UDim2.new(1,0,1,-94); PageContainer.Position = UDim2.new(0,0,0,94); PageContainer.BackgroundTransparency = 1; PageContainer.Active = true; PageContainer.ClipsDescendants = true; PageContainer.Parent = MainFrame
	local Pages, Tabs = {}, {}

	local function CreateTabInternal(tabName, layoutOrder)
		local TabSetup = {}
        local elementCounter = 0
		local function generateId(baseName) elementCounter = elementCounter + 1; return baseName .. "_" .. elementCounter end

		local TabBtn = Instance.new("TextButton"); TabBtn.Size = UDim2.new(0, 130, 1, 0); TabBtn.Text = tabName; TabBtn.Font = Enum.Font.GothamBold; TabBtn.TextSize = 15; TabBtn.TextColor3 = CurrentTheme.SubTextColor; TabBtn.BackgroundTransparency = 1; TabBtn.LayoutOrder = layoutOrder or #Tabs; TabBtn.Parent = TabContainer; registerThemeable(TabBtn, {TextColor3 = "SubTextColor"})
		local Indicator = Instance.new("Frame"); Indicator.Size = UDim2.new(0,0,0,3); Indicator.Position = UDim2.new(0.5,0,1,-3); Indicator.BackgroundColor3 = CurrentTheme.Primary; Indicator.BorderSizePixel = 0; Indicator.Parent = TabBtn; registerThemeable(Indicator, {BackgroundColor3 = "Primary"})

		local PageScroll = Instance.new("ScrollingFrame"); PageScroll.Size = UDim2.new(1,0,1,0); PageScroll.BackgroundTransparency = 1; PageScroll.BorderSizePixel = 0; PageScroll.ScrollBarThickness = 4; PageScroll.ScrollBarImageColor3 = CurrentTheme.Primary; PageScroll.Active = true; PageScroll.Visible = false; PageScroll.CanvasSize = UDim2.new(0,0,0,0); PageScroll.Parent = PageContainer
		local PageLayout = Instance.new("UIListLayout"); PageLayout.SortOrder = Enum.SortOrder.LayoutOrder; PageLayout.Padding = UDim.new(0,12); PageLayout.Parent = PageScroll
		Instance.new("UIPadding", PageScroll).PaddingTop = UDim.new(0,12); Instance.new("UIPadding", PageScroll).PaddingLeft = UDim.new(0,15); Instance.new("UIPadding", PageScroll).PaddingRight = UDim.new(0,15)
		PageScroll.ChildAdded:Connect(function(child) if child:IsA("GuiObject") then task.wait() PageScroll.CanvasSize = UDim2.new(0,0,0,PageLayout.AbsoluteContentSize.Y + 20) end end)

		TabBtn.MouseButton1Click:Connect(function()
			for _,p in pairs(Pages) do p.Visible = false end
			for _,t in pairs(Tabs) do TweenService:Create(t.Indicator, TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Size=UDim2.new(0,0,0,3), Position=UDim2.new(0.5,0,1,-3)}):Play(); TweenService:Create(t.Btn, TweenInfo.new(0.3), {TextColor3 = CurrentTheme.SubTextColor}):Play() end
			PageScroll.Visible = true
			TweenService:Create(Indicator, TweenInfo.new(0.4,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Size=UDim2.new(1,0,0,3), Position=UDim2.new(0,0,1,-3)}):Play()
			TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = Color3.new(1,1,1)}):Play()
			playClickSound()
		end)

		table.insert(Pages, PageScroll); table.insert(Tabs, {Btn = TabBtn, Indicator = Indicator})
		if #Pages == 1 then PageScroll.Visible = true; Indicator.Size = UDim2.new(1,0,0,3); Indicator.Position = UDim2.new(0,0,1,-3); TabBtn.TextColor3 = Color3.new(1,1,1) end

		function TabSetup:CreateToggle(name, callback)
			local id = generateId("toggle_" .. name)
			local ToggleFrame = Instance.new("Frame"); ToggleFrame.Size = UDim2.new(1,0,0,50); ToggleFrame.BackgroundColor3 = CurrentTheme.PanelLight; ToggleFrame.Active = true; ToggleFrame.Parent = PageScroll; createCorner(ToggleFrame,8); createStroke(ToggleFrame, CurrentTheme.Primary, 1); registerThemeable(ToggleFrame, {BackgroundColor3 = "PanelLight"})
			local Label = Instance.new("TextLabel"); Label.Size = UDim2.new(1,-80,1,0); Label.Position = UDim2.new(0,15,0,0); Label.Text = name; Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 14; Label.TextColor3 = CurrentTheme.TextColor; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.BackgroundTransparency = 1; Label.Parent = ToggleFrame; registerThemeable(Label, {TextColor3 = "TextColor"})
			local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(0,50,0,26); Btn.Position = UDim2.new(1,-65,0.5,-13); Btn.BackgroundColor3 = CurrentTheme.Panel; Btn.Text = ""; Btn.Parent = ToggleFrame; createCorner(Btn,13); registerThemeable(Btn, {BackgroundColor3 = "Panel"})
			local Circle = Instance.new("Frame"); Circle.Size = UDim2.new(0,20,0,20); Circle.Position = UDim2.new(0,3,0.5,-10); Circle.BackgroundColor3 = Color3.new(1,1,1); Circle.Parent = Btn; createCorner(Circle,10)

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
				for _, entry in ipairs(ConfigCallbacks) do if entry.id == id then entry.set(state) break end end
				playClickSound()
			end)
		end

        function TabSetup:CreatePremiumToggle(name, callback)
            local id = generateId("premiumtoggle_" .. name)
			local ToggleFrame = Instance.new("Frame"); ToggleFrame.Size = UDim2.new(1,0,0,50); ToggleFrame.BackgroundColor3 = CurrentTheme.PanelLight; ToggleFrame.Active = true; ToggleFrame.Parent = PageScroll; createCorner(ToggleFrame,8); createStroke(ToggleFrame, Color3.fromRGB(255, 215, 0), 1); registerThemeable(ToggleFrame, {BackgroundColor3 = "PanelLight"})
			local Label = Instance.new("TextLabel"); Label.Size = UDim2.new(1,-80,1,0); Label.Position = UDim2.new(0,15,0,0); Label.Text = "👑 " .. name; Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 14; Label.TextColor3 = CurrentTheme.TextColor; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.BackgroundTransparency = 1; Label.Parent = ToggleFrame; registerThemeable(Label, {TextColor3 = "TextColor"})
			local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(0,50,0,26); Btn.Position = UDim2.new(1,-65,0.5,-13); Btn.BackgroundColor3 = CurrentTheme.Panel; Btn.Text = ""; Btn.Parent = ToggleFrame; createCorner(Btn,13); registerThemeable(Btn, {BackgroundColor3 = "Panel"})
			local Circle = Instance.new("Frame"); Circle.Size = UDim2.new(0,20,0,20); Circle.Position = UDim2.new(0,3,0.5,-10); Circle.BackgroundColor3 = Color3.new(1,1,1); Circle.Parent = Btn; createCorner(Circle,10)

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
                if not EmloxaLibrary:GetPremiumStatus() then
                    WindowSetup:ShowPremiumPrompt(name)
                    return
                end
				state = not state
				ConfigValues[id] = state
				for _, entry in ipairs(ConfigCallbacks) do if entry.id == id then entry.set(state) break end end
				playClickSound()
			end)
		end

        function TabSetup:CreateTextbox(name, placeholder, callback)
			local id = generateId("textbox_" .. name)
			local BoxFrame = Instance.new("Frame"); BoxFrame.Size = UDim2.new(1,0,0,48); BoxFrame.BackgroundColor3 = CurrentTheme.PanelLight; BoxFrame.Active = true; BoxFrame.Parent = PageScroll; createCorner(BoxFrame,8); createStroke(BoxFrame, CurrentTheme.Primary, 1); registerThemeable(BoxFrame, {BackgroundColor3 = "PanelLight"})
			local Label = Instance.new("TextLabel"); Label.Size = UDim2.new(0.5,0,1,0); Label.Position = UDim2.new(0,15,0,0); Label.Text = name; Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 14; Label.TextColor3 = CurrentTheme.TextColor; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.BackgroundTransparency = 1; Label.Parent = BoxFrame; registerThemeable(Label, {TextColor3 = "TextColor"})
			local TextBoxBg = Instance.new("Frame"); TextBoxBg.Size = UDim2.new(0.45, 0, 0, 32); TextBoxBg.Position = UDim2.new(1, -15, 0.5, -16); TextBoxBg.AnchorPoint = Vector2.new(1, 0); TextBoxBg.BackgroundColor3 = CurrentTheme.Panel; TextBoxBg.Parent = BoxFrame; createCorner(TextBoxBg, 6); registerThemeable(TextBoxBg, {BackgroundColor3 = "Panel"})
			local TxtBox = Instance.new("TextBox"); TxtBox.Size = UDim2.new(1, -10, 1, 0); TxtBox.Position = UDim2.new(0, 5, 0, 0); TxtBox.BackgroundTransparency = 1; TxtBox.Text = ""; TxtBox.PlaceholderText = placeholder or "Type here..."; TxtBox.Font = Enum.Font.Gotham; TxtBox.TextSize = 13; TxtBox.TextColor3 = CurrentTheme.TextColor; TxtBox.TextXAlignment = Enum.TextXAlignment.Left; TxtBox.ClearTextOnFocus = false; TxtBox.Parent = TextBoxBg; registerThemeable(TxtBox, {TextColor3 = "TextColor"})

			TxtBox.FocusLost:Connect(function() callback(TxtBox.Text) end)
		end

		function TabSetup:CreateSlider(name, min, max, default, callback)
			local id = generateId("slider_" .. name)
			local SliderFrame = Instance.new("Frame"); SliderFrame.Size = UDim2.new(1,0,0,65); SliderFrame.BackgroundColor3 = CurrentTheme.PanelLight; SliderFrame.Active = true; SliderFrame.Parent = PageScroll; createCorner(SliderFrame,8); createStroke(SliderFrame, CurrentTheme.Primary, 1); registerThemeable(SliderFrame, {BackgroundColor3 = "PanelLight"})
			local Label = Instance.new("TextLabel"); Label.Size = UDim2.new(1,-50,0,25); Label.Position = UDim2.new(0,15,0,8); Label.Text = name; Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 14; Label.TextColor3 = CurrentTheme.TextColor; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.BackgroundTransparency = 1; Label.Parent = SliderFrame; registerThemeable(Label, {TextColor3 = "TextColor"})
			local ValueText = Instance.new("TextLabel"); ValueText.Size = UDim2.new(0,50,0,25); ValueText.Position = UDim2.new(1,-65,0,8); ValueText.Text = tostring(default); ValueText.Font = Enum.Font.GothamBold; ValueText.TextSize = 14; ValueText.TextColor3 = CurrentTheme.Primary; ValueText.TextXAlignment = Enum.TextXAlignment.Right; ValueText.BackgroundTransparency = 1; ValueText.Parent = SliderFrame; registerThemeable(ValueText, {TextColor3 = "Primary"})
			local Bar = Instance.new("TextButton"); Bar.Size = UDim2.new(1,-30,0,8); Bar.Position = UDim2.new(0,15,0,42); Bar.BackgroundColor3 = CurrentTheme.Panel; Bar.Text = ""; Bar.Parent = SliderFrame; createCorner(Bar,4); registerThemeable(Bar, {BackgroundColor3 = "Panel"})
			local Fill = Instance.new("Frame"); local defaultPercent = (default - min) / (max - min); Fill.Size = UDim2.new(defaultPercent,0,1,0); Fill.BackgroundColor3 = CurrentTheme.Primary; Fill.Parent = Bar; createCorner(Fill,4); registerThemeable(Fill, {BackgroundColor3 = "Primary"})
			local Knob = Instance.new("Frame"); Knob.Size = UDim2.new(0,14,0,14); Knob.Position = UDim2.new(defaultPercent, -7, 0.5, -7); Knob.BackgroundColor3 = Color3.new(1,1,1); Knob.BorderSizePixel = 0; Knob.Parent = Bar; createCorner(Knob, 7)

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
			Bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = true end end)
			UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end end)
			UserInputService.InputChanged:Connect(function(input)
				if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
					local mousePos, barPos, barSize = input.Position.X, Bar.AbsolutePosition.X, Bar.AbsoluteSize.X
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

		function TabSetup:CreateDropdown(name, options, default, premiumOptions, callback)
            local id = generateId("dropdown_" .. name)
			local DropdownFrame = Instance.new("Frame"); DropdownFrame.Size = UDim2.new(1,0,0,48); DropdownFrame.BackgroundColor3 = CurrentTheme.PanelLight; DropdownFrame.Active = true; DropdownFrame.ClipsDescendants = true; DropdownFrame.Parent = PageScroll; createCorner(DropdownFrame,8); createStroke(DropdownFrame, CurrentTheme.Primary, 1); registerThemeable(DropdownFrame, {BackgroundColor3 = "PanelLight"})
			local Label = Instance.new("TextLabel"); Label.Size = UDim2.new(1,-30,0,48); Label.Position = UDim2.new(0,15,0,0); Label.Text = name .. " : " .. tostring(default); Label.Font = Enum.Font.GothamSemibold; Label.TextSize = 14; Label.TextColor3 = CurrentTheme.TextColor; Label.TextXAlignment = Enum.TextXAlignment.Left; Label.BackgroundTransparency = 1; Label.Parent = DropdownFrame; registerThemeable(Label, {TextColor3 = "TextColor"})
			local ToggleBtn = Instance.new("TextButton"); ToggleBtn.Size = UDim2.new(1,0,0,48); ToggleBtn.BackgroundTransparency = 1; ToggleBtn.Text = ""; ToggleBtn.Parent = DropdownFrame
			local OptionContainer = Instance.new("Frame"); OptionContainer.Size = UDim2.new(1,0,1,-48); OptionContainer.Position = UDim2.new(0,0,0,48); OptionContainer.BackgroundTransparency = 1; OptionContainer.Parent = DropdownFrame
			local UIListLayout = Instance.new("UIListLayout", OptionContainer); UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

			local isDropped = false
            premiumOptions = premiumOptions or {}
            
            local selectedValue = default
			ConfigValues[id] = default
			registerConfig(id, function(val)
				selectedValue = val
				Label.Text = name .. " : " .. val
				callback(val)
			end)

			local function BuildOptions(optList)
				for _, child in ipairs(OptionContainer:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
				for _, option in ipairs(optList) do
                    local isPremiumOption = table.find(premiumOptions, option)
					local OptBtn = Instance.new("TextButton"); OptBtn.Size = UDim2.new(1,0,0,34); OptBtn.BackgroundColor3 = CurrentTheme.Panel; OptBtn.Text = (isPremiumOption and "  👑 " or "  ") .. option; OptBtn.Font = Enum.Font.Gotham; OptBtn.TextSize = 13; OptBtn.TextColor3 = isPremiumOption and Color3.fromRGB(255, 215, 0) or CurrentTheme.SubTextColor; OptBtn.TextXAlignment = Enum.TextXAlignment.Left; OptBtn.Parent = OptionContainer; createCorner(OptBtn,6)
					registerThemeable(OptBtn, {BackgroundColor3 = "Panel", TextColor3 = isPremiumOption and nil or "SubTextColor"})

					OptBtn.MouseButton1Click:Connect(function()
                        if isPremiumOption and not EmloxaLibrary:GetPremiumStatus() then
                            WindowSetup:ShowPremiumPrompt(option)
                            return
                        end
						selectedValue = option
                        ConfigValues[id] = option
						Label.Text = name .. " : " .. option
						isDropped = false
						TweenService:Create(DropdownFrame, TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,48)}):Play()
						TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = CurrentTheme.TextColor}):Play()
						callback(option)
						playClickSound()
					end)
				end
			end
			BuildOptions(options)

			ToggleBtn.MouseButton1Click:Connect(function()
				isDropped = not isDropped
				local childCount = 0
				for _,v in pairs(OptionContainer:GetChildren()) do if v:IsA("TextButton") then childCount = childCount + 1 end end
				TweenService:Create(DropdownFrame, TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out), {Size = UDim2.new(1,0,0,isDropped and (48 + (childCount * 34)) or 48)}):Play()
				TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = isDropped and CurrentTheme.Primary or CurrentTheme.TextColor}):Play()
				playClickSound()
			end)
            
            local DropdownAPI = {}
			function DropdownAPI:Refresh(newOptions)
				BuildOptions(newOptions)
				if isDropped then TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1,0,0,48 + (#newOptions * 34))}):Play() end
			end
			return DropdownAPI
		end
		
		function TabSetup:CreateButton(name, callback)
			local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(1,0,0,42); Btn.BackgroundColor3 = CurrentTheme.PanelLight; Btn.Text = name; Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 15; Btn.TextColor3 = CurrentTheme.TextColor; Btn.Active = true; Btn.Parent = PageScroll; createCorner(Btn,8); createStroke(Btn, CurrentTheme.Primary, 1); registerThemeable(Btn, {BackgroundColor3 = "PanelLight", TextColor3 = "TextColor"})
			local function pressAnim() TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.98,0,0,40), BackgroundColor3 = CurrentTheme.Primary}):Play(); task.wait(0.1); TweenService:Create(Btn, TweenInfo.new(0.2), {Size = UDim2.new(1,0,0,42), BackgroundColor3 = CurrentTheme.PanelLight}):Play() end
			Btn.MouseButton1Click:Connect(function() pressAnim(); playClickSound(); callback() end)
			Btn.MouseEnter:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.PrimaryDark}):Play() end)
			Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.PanelLight}):Play() end)
		end

        function TabSetup:CreatePremiumButton(name, callback)
			local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(1,0,0,42); Btn.BackgroundColor3 = CurrentTheme.PanelLight; Btn.Text = "👑 " .. name; Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 15; Btn.TextColor3 = CurrentTheme.TextColor; Btn.Active = true; Btn.Parent = PageScroll; createCorner(Btn,8); createStroke(Btn, Color3.fromRGB(255, 215, 0), 1); registerThemeable(Btn, {BackgroundColor3 = "PanelLight", TextColor3 = "TextColor"})
			local function pressAnim() TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.98,0,0,40), BackgroundColor3 = CurrentTheme.Primary}):Play(); task.wait(0.1); TweenService:Create(Btn, TweenInfo.new(0.2), {Size = UDim2.new(1,0,0,42), BackgroundColor3 = CurrentTheme.PanelLight}):Play() end
			Btn.MouseButton1Click:Connect(function() 
                if not EmloxaLibrary:GetPremiumStatus() then WindowSetup:ShowPremiumPrompt(name) return end
                pressAnim(); playClickSound(); callback() 
            end)
			Btn.MouseEnter:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.PrimaryDark}):Play() end)
			Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.PanelLight}):Play() end)
		end

        function TabSetup:CreateDivider()
			local Div = Instance.new("Frame"); Div.Size = UDim2.new(1, 0, 0, 2); Div.BackgroundColor3 = CurrentTheme.Primary; Div.BackgroundTransparency = 0.5; Div.BorderSizePixel = 0; Div.Parent = PageScroll; registerThemeable(Div, {BackgroundColor3 = "Primary"})
		end

		return TabSetup
	end

	local MenuTab = CreateTabInternal("Menu", 9999)
	MenuTab:CreateDropdown("Theme", EmloxaLibrary:GetThemeNames(), "Default", nil, function(val) EmloxaLibrary:SetTheme(val) end)
    MenuTab:CreateDivider()
    local ConfigNameInput, SelectedConfig = "", "No Configs Found"
	MenuTab:CreateTextbox("New Config Name", "Type config name here...", function(val) ConfigNameInput = val end)
	local ConfigDropdown
	ConfigDropdown = MenuTab:CreateDropdown("Saved Configs", GetSavedConfigs(), GetSavedConfigs()[1], nil, function(val) SelectedConfig = val end)

	MenuTab:CreateButton("💾 Save Config", function()
		if ConfigNameInput == "" then return end
		local data = {}
		for _, entry in ipairs(ConfigCallbacks) do data[entry.id] = ConfigValues[entry.id] end
		local success, err = pcall(function() writefile(ConfigFolder .. "/" .. ConfigNameInput .. ".json", HttpService:JSONEncode(data)) end)
		if success then if ConfigDropdown then ConfigDropdown:Refresh(GetSavedConfigs()) end end
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

	function WindowSetup:CreateTab(tabName) return CreateTabInternal(tabName, #Tabs + 1) end

	return WindowSetup
end

return EmloxaLibrary
