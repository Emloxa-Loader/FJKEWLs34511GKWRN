-- =========================================================================
-- EMLOXA WARE PREMIUM UI v19.0 AURUM EDITION
-- Complete UI overhaul with Aurum design system
-- =========================================================================

local EmloxaLibrary = {}

-- ══════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════
--  SOUND SYSTEM (AURUM)
-- ══════════════════════════════════════
local SoundIds = {
	Hover   = "rbxassetid://6895079853",
	Click   = "rbxassetid://6895079853",
	Toggle  = "rbxassetid://6895079832",
	Open    = "rbxassetid://8672297049",
	Close   = "rbxassetid://8672297049",
	Notify  = "rbxassetid://6895079898",
	Tab     = "rbxassetid://6895079832",
	Slider  = "rbxassetid://6895079750",
	Error   = "rbxassetid://6895079778",
	Type    = "rbxassetid://6895079750",
	Whoosh  = "rbxassetid://8672297049",
	Confirm = "rbxassetid://6895079898",
}

local SoundsEnabled = true
local SoundVolume = 0.4
local SoundFolder = Instance.new("Folder")
SoundFolder.Name = "EmloxaSounds"

local function playSound(name, volume, pitch)
	if not SoundsEnabled then return end
	local id = SoundIds[name]
	if not id then return end
	pcall(function()
		local s = Instance.new("Sound")
		s.SoundId = id
		s.Volume = (volume or 0.4) * SoundVolume * 2.5
		s.PlaybackSpeed = pitch or 1
		s.Parent = SoundFolder
		s:Play()
		Debris:AddItem(s, 3)
	end)
end

-- ══════════════════════════════════════
--  AURUM THEME SYSTEM
-- ══════════════════════════════════════
local ThemePresets = {
	Amethyst = {
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
	},
	Crimson = {
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
	},
	Emerald = {
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
	},
	Sapphire = {
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
	},
	Monochrome = {
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
	},
	Sunset = {
		Background = Color3.fromRGB(18, 13, 12),
		Sidebar = Color3.fromRGB(14, 10, 9),
		Card = Color3.fromRGB(27, 19, 17),
		CardHover = Color3.fromRGB(34, 24, 21),
		Stroke = Color3.fromRGB(62, 42, 35),
		Accent = Color3.fromRGB(255, 140, 70),
		AccentBright = Color3.fromRGB(255, 175, 110),
		Gold = Color3.fromRGB(255, 210, 100),
		TextMain = Color3.fromRGB(242, 233, 228),
		TextDim = Color3.fromRGB(163, 148, 140),
		Success = Color3.fromRGB(90, 230, 150),
		Danger = Color3.fromRGB(255, 90, 110),
	},
}

local Config = {
	ThemeName = "Amethyst",
	CornerRadius = 10,
	SoundsOn = true,
	SoundVol = 0.4,
	ToggleKey = Enum.KeyCode.RightShift,
}

local Theme = ThemePresets[Config.ThemeName]

local Fonts = {
	Title = Enum.Font.GothamBlack,
	Bold  = Enum.Font.GothamBold,
	Semi  = Enum.Font.GothamSemibold,
	Reg   = Enum.Font.Gotham,
	Mono  = Enum.Font.RobotoMono,
}

-- ══════════════════════════════════════
--  HELPER FUNCTIONS (AURUM)
-- ══════════════════════════════════════
local function tween(obj, info, props)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

local EASE_OUT    = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local EASE_OUT_S  = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local EASE_SPRING = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local EASE_SOFT   = TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local EASE_SNAP   = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function new(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do inst[k] = v end
	for _, c in ipairs(children or {}) do c.Parent = inst end
	return inst
end

local function corner(radius)
	return new("UICorner", { CornerRadius = UDim.new(0, radius or Config.CornerRadius) })
end

local function stroke(color, thickness, transparency)
	return new("UIStroke", { Color = color or Theme.Stroke, Thickness = thickness or 1, Transparency = transparency or 0 })
end

local function gradient(colorSeq, rotation)
	return new("UIGradient", { Color = colorSeq, Rotation = rotation or 0 })
end

local function padding(l, t, r, b)
	return new("UIPadding", {
		PaddingLeft = UDim.new(0, l or 0),
		PaddingTop = UDim.new(0, t or 0),
		PaddingRight = UDim.new(0, r or l or 0),
		PaddingBottom = UDim.new(0, b or t or 0),
	})
end

local ThemedInstances = {}
local function themed(inst, propName, themeKey)
	table.insert(ThemedInstances, { inst = inst, prop = propName, key = themeKey })
	inst[propName] = Theme[themeKey]
	return inst
end

local function applyThemeToAll()
	for _, entry in ipairs(ThemedInstances) do
		if entry.inst and entry.inst.Parent then
			tween(entry.inst, EASE_OUT_S, { [entry.prop] = Theme[entry.key] })
		end
	end
end

local function ripple(parent, x, y)
	pcall(function()
		local r = new("Frame", {
			Size = UDim2.fromOffset(0, 0),
			Position = UDim2.fromOffset(x, y),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.new(1,1,1),
			BackgroundTransparency = 0.7,
			ZIndex = 50,
			Parent = parent,
		}, { corner(50) })
		local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 1.6
		tween(r, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(maxSize, maxSize),
			BackgroundTransparency = 1,
		})
		Debris:AddItem(r, 0.55)
	end)
end

-- ══════════════════════════════════════
--  HUI PROTECTION & ASSETS
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
--  ASSET LOADER
-- ══════════════════════════════════════
local LOGO_URL = "https://raw.githubusercontent.com/Emrox2313/Datas/refs/heads/main/foto.png"
local FALLBACK_LOGO = "rbxassetid://107602224137000"

local INTRO_MUSIC_URL = "https://github.com/Emrox2313/Datas/raw/refs/heads/main/loading.mp3"
local FALLBACK_MUSIC = "rbxassetid://3017127417"

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
	task.spawn(function()
		imageObject.Image = getDownloadedAsset(LOGO_URL, "sys_ui_cache_01.png", FALLBACK_LOGO)
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

-- ══════════════════════════════════════
--  HWID & VIP SYSTEM
-- ══════════════════════════════════════
local function GetHWID()
	local clientID = ""
	pcall(function() clientID = RbxAnalyticsService:GetClientId() end)
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
--  ROOT GUI (AURUM STYLE)
-- ══════════════════════════════════════
local SafeParent = GetSafeParent()

for _, v in pairs(SafeParent:GetChildren()) do
	if v:IsA("ScreenGui") and (v.Name == "EmloxaAdminUI" or v.Name == "CoreUI_Telemetry_x64") then
		v:Destroy()
	end
end

local ScreenGui = new("ScreenGui", {
	Name = "EmloxaAdminUI",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	IgnoreGuiInset = true,
	DisplayOrder = 999,
})

SoundFolder.Parent = ScreenGui
ScreenGui.Parent = SafeParent
ProtectUI(ScreenGui)

-- ══════════════════════════════════════
--  AURUM LOADER SCREEN
-- ══════════════════════════════════════
local LoaderFrame = new("Frame", {
	Name = "Loader",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(4, 4, 7),
	ZIndex = 100,
	Parent = ScreenGui,
})

local LoaderGradient = gradient(ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 6, 14)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(5,4,9)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(2, 2, 4)),
}), 45)
LoaderGradient.Parent = LoaderFrame

task.spawn(function()
	local rot = 45
	while LoaderFrame.Parent do
		rot += 0.15
		LoaderGradient.Rotation = rot
		task.wait()
	end
end)

-- Particle drift
for i = 1, 24 do
	local dot = new("Frame", {
		Size = UDim2.fromOffset(2, 2),
		Position = UDim2.fromScale(math.random(), 1.1),
		BackgroundColor3 = Theme.AccentBright,
		BackgroundTransparency = 0.5 + math.random() * 0.4,
		ZIndex = 99,
		Parent = LoaderFrame,
	}, { corner(2) })
	
	task.spawn(function()
		while dot.Parent do
			local dur = 3 + math.random() * 4
			dot.Position = UDim2.fromScale(math.random(), 1.1)
			tween(dot, TweenInfo.new(dur, Enum.EasingStyle.Linear), {
				Position = UDim2.fromScale(dot.Position.X.Scale, -0.1)
			})
			task.wait(dur)
		end
	end)
end

local GlowRing = new("ImageLabel", {
	Name = "GlowRing",
	Size = UDim2.fromOffset(340, 340),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.42),
	BackgroundTransparency = 1,
	Image = "rbxassetid://4996891970",
	ImageColor3 = Theme.Accent,
	ImageTransparency = 0.55,
	ZIndex = 100,
	Parent = LoaderFrame,
})

local GlowRingOuter = new("ImageLabel", {
	Name = "GlowRingOuter",
	Size = UDim2.fromOffset(220, 220),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.42),
	BackgroundTransparency = 1,
	Image = "rbxassetid://4996891970",
	ImageColor3 = Theme.Gold,
	ImageTransparency = 0.75,
	ZIndex = 99,
	Parent = LoaderFrame,
})

local LogoText = new("TextLabel", {
	Name = "LogoText",
	Size = UDim2.fromOffset(500, 80),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.4),
	BackgroundTransparency = 1,
	Text = "EMLOXA",
	TextColor3 = Theme.TextMain,
	Font = Fonts.Title,
	TextSize = 40,
	TextTransparency = 1,
	ZIndex = 101,
	Parent = LoaderFrame,
})

gradient(ColorSequence.new({
	ColorSequenceKeypoint.new(0, Theme.AccentBright),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,255,255)),
	ColorSequenceKeypoint.new(1, Theme.Gold),
})).Parent = LogoText

local SubText = new("TextLabel", {
	Size = UDim2.fromOffset(500, 24),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.475),
	BackgroundTransparency = 1,
	Text = "INITIALIZING",
	TextColor3 = Theme.TextDim,
	Font = Fonts.Semi,
	TextSize = 12,
	TextTransparency = 1,
	ZIndex = 101,
	Parent = LoaderFrame,
})

local LoaderStages = {
	"INITIALIZING CORE",
	"LOADING THEME ENGINE",
	"BUILDING INTERFACE",
	"CALIBRATING ANIMATIONS",
	"FINALIZING"
}

local BarBack = new("Frame", {
	Size = UDim2.fromOffset(300, 3),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.56),
	BackgroundColor3 = Color3.fromRGB(30, 28, 38),
	BackgroundTransparency = 1,
	ZIndex = 101,
	Parent = LoaderFrame,
}, { corner(4) })

local BarFill = new("Frame", {
	Size = UDim2.new(0, 0, 1, 0),
	BackgroundColor3 = Theme.Accent,
	BorderSizePixel = 0,
	ZIndex = 102,
	Parent = BarBack,
}, { corner(4) })

gradient(ColorSequence.new({
	ColorSequenceKeypoint.new(0, Theme.Accent),
	ColorSequenceKeypoint.new(1, Theme.Gold),
})).Parent = BarFill

local PercentText = new("TextLabel", {
	Size = UDim2.fromOffset(320, 20),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.605),
	BackgroundTransparency = 1,
	Text = "0%",
	TextColor3 = Theme.TextDim,
	Font = Fonts.Mono,
	TextSize = 11,
	TextTransparency = 1,
	ZIndex = 101,
	Parent = LoaderFrame,
})

local LoaderDone = false

task.spawn(function()
	tween(LogoText, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		TextTransparency = 0,
		Position = UDim2.fromScale(0.5, 0.42)
	})
	tween(SubText, EASE_OUT, { TextTransparency = 0.3 })
	tween(BarBack, EASE_OUT, { BackgroundTransparency = 0 })
	task.wait(0.2)

	local spinning = true
	task.spawn(function()
		local rot, rot2 = 0, 0
		while spinning do
			rot += 1.1
			rot2 -= 0.7
			GlowRing.Rotation = rot
			GlowRingOuter.Rotation = rot2
			task.wait()
		end
	end)

	local stageIdx = 1
	local fake = { v = 0 }
	local t = tween(fake, TweenInfo.new(1.9, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { v = 100 })
	
	local conn
	conn = RunService.RenderStepped:Connect(function()
		local val = math.floor(fake.v)
		PercentText.Text = string.format("%d%%", val)
		PercentText.TextTransparency = 0
		BarFill.Size = UDim2.new(fake.v / 100, 0, 1, 0)
		local newStage = math.clamp(math.floor(val / (100/#LoaderStages)) + 1, 1, #LoaderStages)
		if newStage ~= stageIdx then
			stageIdx = newStage
			SubText.Text = LoaderStages[stageIdx]
		end
	end)
	
	t.Completed:Wait()
	conn:Disconnect()
	spinning = false
	
	PercentText.Text = "100%"
	BarFill.Size = UDim2.new(1, 0, 1, 0)
	SubText.Text = "WELCOME, " .. string.upper(LocalPlayer.DisplayName)
	playSound("Whoosh", 0.3)

	task.wait(0.5)
	tween(GlowRing, EASE_OUT, { ImageTransparency = 1, Size = UDim2.fromOffset(700, 700) })
	tween(GlowRingOuter, EASE_OUT, { ImageTransparency = 1, Size = UDim2.fromOffset(500, 500) })
	tween(LogoText, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		TextTransparency = 1,
		Position = LogoText.Position - UDim2.fromOffset(0, 24),
		TextSize = 34
	})
	tween(SubText, EASE_OUT, { TextTransparency = 1 })
	tween(BarBack, EASE_OUT, { BackgroundTransparency = 1 })
	tween(PercentText, EASE_OUT, { TextTransparency = 1 })
	tween(LoaderFrame, TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		BackgroundTransparency = 1
	})
	
	task.wait(0.6)
	LoaderFrame.Visible = false
	LoaderFrame:Destroy()
	LoaderDone = true
end)

-- ══════════════════════════════════════
--  MAIN WINDOW (AURUM DESIGN)
-- ══════════════════════════════════════
function EmloxaLibrary:CreateWindow(hubName)
	local WindowSetup = {}
	
	local DEFAULT_W, DEFAULT_H = 820, 490
	local MIN_W, MIN_H = 620, 400
	local MAX_W, MAX_H = 1150, 780
	
	local MainFrame = themed(new("Frame", {
		Name = "MainFrame",
		Size = UDim2.fromOffset(DEFAULT_W, DEFAULT_H),
		Position = UDim2.fromScale(0.5, 0.52),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Visible = false,
		Parent = ScreenGui,
	}, { corner(), stroke(Theme.Stroke, 1) }), "BackgroundColor3", "Background")

	new("UIGradient", {
		Parent = MainFrame,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(18,16,24)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10,9,14)),
		}),
		Rotation = 65,
	})

	new("ImageLabel", {
		Name = "Shadow",
		Image = "rbxassetid://6014261993",
		ImageColor3 = Color3.new(0,0,0),
		ImageTransparency = 0.4,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49,49,450,450),
		Size = UDim2.new(1, 60, 1, 60),
		Position = UDim2.fromOffset(-30,-30),
		BackgroundTransparency = 1,
		ZIndex = -1,
		Parent = MainFrame,
	})

	-- Aurora glow
	local Aurora1 = new("ImageLabel", {
		Name = "Aurora1",
		Image = "rbxassetid://4996891970",
		ImageColor3 = Theme.Accent,
		ImageTransparency = 0.86,
		Size = UDim2.new(1, 240, 1, 240),
		Position = UDim2.fromOffset(-120,-120),
		BackgroundTransparency = 1,
		ZIndex = -3,
		Parent = MainFrame,
	})
	
	local Aurora2 = new("ImageLabel", {
		Name = "Aurora2",
		Image = "rbxassetid://4996891970",
		ImageColor3 = Theme.Gold,
		ImageTransparency = 0.92,
		Size = UDim2.new(1, 160, 1, 160),
		Position = UDim2.fromOffset(-80,-80),
		BackgroundTransparency = 1,
		ZIndex = -2,
		Parent = MainFrame,
	})
	
	task.spawn(function()
		while Aurora1.Parent do
			tween(Aurora1, EASE_SOFT, {
				ImageTransparency = 0.92,
				Size = UDim2.new(1,280,1,280),
				Position = UDim2.fromOffset(-140,-140)
			})
			tween(Aurora2, EASE_SOFT, {
				ImageTransparency = 0.88,
				Size = UDim2.new(1,140,1,140),
				Position = UDim2.fromOffset(-70,-70)
			})
			task.wait(0.9)
			tween(Aurora1, EASE_SOFT, {
				ImageTransparency = 0.84,
				Size = UDim2.new(1,220,1,220),
				Position = UDim2.fromOffset(-110,-110)
			})
			tween(Aurora2, EASE_SOFT, {
				ImageTransparency = 0.94,
				Size = UDim2.new(1,180,1,180),
				Position = UDim2.fromOffset(-90,-90)
			})
			task.wait(0.9)
		end
	end)

	-- ═══ TOP BAR (AURUM) ═══
	local TopBar = themed(new("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 46),
		BorderSizePixel = 0,
		Parent = MainFrame,
	}), "BackgroundColor3", "Sidebar")
	
	new("UICorner", { CornerRadius = UDim.new(0, Config.CornerRadius) }).Parent = TopBar
	new("Frame", {
		Size = UDim2.new(1, 0, 0, 16),
		Position = UDim2.new(0, 0, 1, -16),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		Parent = TopBar,
	})

	local TitleWrap = new("Frame", {
		Size = UDim2.fromOffset(150, 46),
		Position = UDim2.fromOffset(18, 0),
		BackgroundTransparency = 1,
		Parent = TopBar
	})
	
	local TitleLbl = new("TextLabel", {
		Size = UDim2.fromOffset(120, 46),
		BackgroundTransparency = 1,
		Text = hubName,
		TextColor3 = Theme.TextMain,
		Font = Fonts.Title,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = TitleWrap,
	})
	
	local TitleGrad = gradient(ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.AccentBright),
		ColorSequenceKeypoint.new(1, Theme.Gold),
	}))
	TitleGrad.Parent = TitleLbl
	
	task.spawn(function()
		local off = 0
		while TitleLbl.Parent do
			off += 0.006
			TitleGrad.Offset = Vector2.new(math.sin(off) * 0.3, 0)
			task.wait()
		end
	end)

	local StatusDot = new("Frame", {
		Size = UDim2.fromOffset(7,7),
		Position = UDim2.fromOffset(92, 20),
		BackgroundColor3 = Theme.Success,
		Parent = TitleWrap,
	}, { corner(4) })
	
	task.spawn(function()
		while StatusDot.Parent do
			tween(StatusDot, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				BackgroundTransparency = 0.6
			})
			task.wait(0.8)
			tween(StatusDot, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				BackgroundTransparency = 0
			})
			task.wait(0.8)
		end
	end)

	-- Clock
	local ClockLbl = new("TextLabel", {
		Size = UDim2.fromOffset(70, 46),
		Position = UDim2.new(1, -158, 0, 0),
		BackgroundTransparency = 1,
		Text = "--:--:--",
		TextColor3 = Theme.TextDim,
		Font = Fonts.Mono,
		TextSize = 11.5,
		Parent = TopBar,
	})
	
	task.spawn(function()
		while ClockLbl.Parent do
			ClockLbl.Text = os.date("%H:%M:%S")
			task.wait(1)
		end
	end)

	-- Minimize & Close buttons
	local MinimizeBtn = themed(new("TextButton", {
		Name = "MinimizeBtn",
		Size = UDim2.fromOffset(30, 30),
		Position = UDim2.new(1, -78, 0, 8),
		Text = "—",
		TextColor3 = Theme.TextDim,
		Font = Fonts.Bold,
		TextSize = 14,
		AutoButtonColor = false,
		Parent = TopBar,
	}, { corner(8) }), "BackgroundColor3", "Card")

	local CloseBtn = themed(new("TextButton", {
		Name = "CloseBtn",
		Size = UDim2.fromOffset(30, 30),
		Position = UDim2.new(1, -40, 0, 8),
		Text = "✕",
		TextColor3 = Theme.TextDim,
		Font = Fonts.Bold,
		TextSize = 14,
		AutoButtonColor = false,
		Parent = TopBar,
	}, { corner(8) }), "BackgroundColor3", "Card")

	for _, pair in ipairs({ {MinimizeBtn, Theme.Gold}, {CloseBtn, Theme.Danger} }) do
		local btn, hoverColor = pair[1], pair[2]
		btn.MouseEnter:Connect(function()
			playSound("Hover", 0.2)
			tween(btn, EASE_OUT_S, {
				BackgroundColor3 = hoverColor,
				TextColor3 = Color3.new(1,1,1)
			})
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, EASE_OUT_S, {
				BackgroundColor3 = Theme.Card,
				TextColor3 = Theme.TextDim
			})
		end)
	end

	-- Dragging
	do
		local dragging, dragStart, startPos
		TopBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = MainFrame.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - dragStart
				MainFrame.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end)
	end

	-- ═══ BOTTOM BAR (AURUM) ═══
	local BottomBar = themed(new("Frame", {
		Name = "BottomBar",
		Size = UDim2.new(1, 0, 0, 40),
		Position = UDim2.new(0, 0, 1, -40),
		BorderSizePixel = 0,
		Parent = MainFrame,
	}), "BackgroundColor3", "Sidebar")
	
	new("Frame", {
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		Parent = BottomBar
	})
	new("UICorner", { CornerRadius = UDim.new(0, Config.CornerRadius) }).Parent = BottomBar

	local AvatarImg = new("ImageLabel", {
		Name = "Avatar",
		Size = UDim2.fromOffset(26, 26),
		Position = UDim2.fromOffset(8, 7),
		BackgroundColor3 = Color3.fromRGB(40,38,50),
		Parent = BottomBar,
	}, { corner(13), stroke(Theme.Accent, 1.5) })
	
	task.spawn(function()
		local ok, content = pcall(function()
			return Players:GetUserThumbnailAsync(
				LocalPlayer.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size100x100
			)
		end)
		if ok then AvatarImg.Image = content end
	end)

	local HelloLbl = new("TextLabel", {
		Size = UDim2.new(0, 160, 1, 0),
		Position = UDim2.fromOffset(42, 0),
		BackgroundTransparency = 1,
		Text = "Hello, " .. LocalPlayer.DisplayName,
		TextColor3 = Theme.TextMain,
		Font = Fonts.Semi,
		TextSize = 12.5,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = BottomBar,
	})

	local PingLbl = new("TextLabel", {
		Size = UDim2.fromOffset(150, 40),
		Position = UDim2.new(0.5, -75, 0, 0),
		BackgroundTransparency = 1,
		Text = "Ping: -- ms  •  -- FPS",
		TextColor3 = Theme.TextDim,
		Font = Fonts.Mono,
		TextSize = 10.5,
		Parent = BottomBar,
	})

	task.spawn(function()
		local frames, lastT = 0, os.clock()
		while BottomBar.Parent do
			frames += 1
			local now = os.clock()
			if now - lastT >= 1 then
				local fps = math.floor(frames / (now - lastT))
				local ping = 0
				local ok, val = pcall(function()
					return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
				end)
				if ok then ping = math.floor(val) end
				PingLbl.Text = string.format("Ping: %d ms  •  %d FPS", ping, fps)
				frames, lastT = 0, now
			end
			RunService.RenderStepped:Wait()
		end
	end)

	local VersionLbl = new("TextLabel", {
		Size = UDim2.fromOffset(150, 40),
		Position = UDim2.new(1, -158, 0, 0),
		BackgroundTransparency = 1,
		Text = "Emloxa v19 Aurum",
		TextColor3 = Theme.TextDim,
		Font = Fonts.Reg,
		TextSize = 10.5,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = BottomBar,
	})

	-- ═══ SIDEBAR (AURUM) ═══
	local Sidebar = themed(new("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, 195, 1, -86),
		Position = UDim2.fromOffset(0, 46),
		BorderSizePixel = 0,
		Parent = MainFrame,
	}), "BackgroundColor3", "Sidebar")

	local SidebarLine = themed(new("Frame", {
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		BorderSizePixel = 0,
		Parent = Sidebar,
	}), "BackgroundColor3", "Stroke")
	
	local sidebarLineGrad = gradient(ColorSequence.new(Theme.Stroke))
	sidebarLineGrad.Parent = SidebarLine
	sidebarLineGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.3),
		NumberSequenceKeypoint.new(1, 1),
	})
	sidebarLineGrad.Rotation = 90

	local SidebarScroll = new("ScrollingFrame", {
		Size = UDim2.fromScale(1,1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Accent,
		ScrollBarImageTransparency = 0.5,
		CanvasSize = UDim2.new(0,0,0,0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = Sidebar,
	})
	
	new("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = SidebarScroll
	})
	padding(10, 14, 10, 10).Parent = SidebarScroll

	local ContentArea = new("Frame", {
		Name = "ContentArea",
		Size = UDim2.new(1, -195, 1, -86),
		Position = UDim2.fromOffset(195, 46),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = MainFrame,
	})

	-- ═══ RESIZE HANDLE ═══
	local ResizeHandle = new("Frame", {
		Name = "ResizeHandle",
		Size = UDim2.fromOffset(20, 20),
		Position = UDim2.new(1, -20, 1, -20),
		BackgroundTransparency = 1,
		ZIndex = 50,
		Parent = MainFrame,
	})
	
	local ResizeIcon = new("ImageLabel", {
		Size = UDim2.fromScale(1,1),
		BackgroundTransparency = 1,
		Image = "rbxassetid://3926305904",
		ImageRectOffset = Vector2.new(4,684),
		ImageRectSize = Vector2.new(36,36),
		ImageColor3 = Theme.TextDim,
		ImageTransparency = 0.3,
		Rotation = 90,
		Parent = ResizeHandle,
	})
	
	local ResizeGrabber = new("TextButton", {
		Size = UDim2.fromScale(1,1),
		BackgroundTransparency = 1,
		Text = "",
		ZIndex = 51,
		Parent = ResizeHandle
	})
	
	ResizeGrabber.MouseEnter:Connect(function()
		tween(ResizeIcon, EASE_OUT_S, {
			ImageColor3 = Theme.AccentBright,
			ImageTransparency = 0
		})
	end)
	
	ResizeGrabber.MouseLeave:Connect(function()
		tween(ResizeIcon, EASE_OUT_S, {
			ImageColor3 = Theme.TextDim,
			ImageTransparency = 0.3
		})
	end)

	do
		local resizing = false
		local startMouse, startSize
		ResizeGrabber.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				resizing = true
				startMouse = input.Position
				startSize = MainFrame.Size
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						resizing = false
					end
				end)
			end
		end)
		
		UserInputService.InputChanged:Connect(function(input)
			if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - startMouse
				local newW = math.clamp(startSize.X.Offset + delta.X, MIN_W, MAX_W)
				local newH = math.clamp(startSize.Y.Offset + delta.Y, MIN_H, MAX_H)
				MainFrame.Size = UDim2.fromOffset(newW, newH)
			end
		end)
		
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				resizing = false
			end
		end)
	end

	-- ═══ NOTIFICATION SYSTEM (AURUM) ═══
	local NotifyHolder = new("Frame", {
		Name = "NotifyHolder",
		Size = UDim2.fromOffset(320, 560),
		Position = UDim2.new(1, -20, 1, -20),
		AnchorPoint = Vector2.new(1, 1),
		BackgroundTransparency = 1,
		Parent = ScreenGui,
	})
	
	new("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		Padding = UDim.new(0, 8),
		Parent = NotifyHolder,
	})

	local NotifyColors = {
		Info = Theme.Accent,
		Success = Theme.Success,
		Warning = Theme.Gold,
		Error = Theme.Danger
	}
	
	local NotifyIcons = {
		Info = "ℹ",
		Success = "✓",
		Warning = "⚠",
		Error = "✕"
	}
	
	local notifyCounter = 0

	local function notify(title, message, kind, duration, opts)
		kind = kind or "Info"
		duration = duration or 4
		opts = opts or {}
		local color = NotifyColors[kind] or Theme.Accent
		notifyCounter += 1

		local Card = new("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.Card,
			BackgroundTransparency = 1,
			LayoutOrder = notifyCounter,
			Parent = NotifyHolder,
		}, { corner(10), stroke(Theme.Stroke, 1, 1) })
		
		padding(14, 12, 14, 12).Parent = Card

		local AccentBar = new("Frame", {
			Size = UDim2.new(0, 3, 1, 0),
			BackgroundColor3 = color,
			BackgroundTransparency = 1,
			Parent = Card
		}, { corner(2) })
		
		new("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0,4),
			Parent = Card
		})

		local Header = new("Frame", {
			Size = UDim2.new(1, 0, 0, 18),
			BackgroundTransparency = 1,
			Parent = Card
		})
		
		local IconLbl = new("TextLabel", {
			Size = UDim2.fromOffset(18,18),
			BackgroundTransparency = 1,
			Text = NotifyIcons[kind] or "ℹ",
			TextColor3 = color,
			TextTransparency = 1,
			Font = Fonts.Bold,
			TextSize = 13,
			Parent = Header,
		})
		
		local TitleLabel = new("TextLabel", {
			Size = UDim2.new(1, -46, 1, 0),
			Position = UDim2.fromOffset(22, 0),
			BackgroundTransparency = 1,
			Text = title or "Notification",
			TextColor3 = Theme.TextMain,
			TextTransparency = 1,
			Font = Fonts.Bold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Header,
		})
		
		local CloseX = new("TextButton", {
			Size = UDim2.fromOffset(18,18),
			Position = UDim2.new(1,-18,0,0),
			BackgroundTransparency = 1,
			Text = "✕",
			TextColor3 = Theme.TextDim,
			TextTransparency = 1,
			Font = Fonts.Bold,
			TextSize = 11,
			Parent = Header,
		})

		local MsgLbl = new("TextLabel", {
			Size = UDim2.new(1, -22, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Position = UDim2.fromOffset(22, 0),
			BackgroundTransparency = 1,
			Text = message or "",
			TextColor3 = Theme.TextDim,
			TextTransparency = 1,
			Font = Fonts.Reg,
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Card,
		})

		local ActionBtn
		if opts.actionText then
			ActionBtn = new("TextButton", {
				Size = UDim2.new(1, -22, 0, 26),
				Position = UDim2.fromOffset(22, 0),
				BackgroundColor3 = color,
				BackgroundTransparency = 1,
				Text = opts.actionText,
				TextColor3 = Color3.new(1,1,1),
				TextTransparency = 1,
				Font = Fonts.Bold,
				TextSize = 12,
				AutoButtonColor = false,
				Parent = Card,
			}, { corner(6) })
			
			ActionBtn.MouseEnter:Connect(function()
				tween(ActionBtn, EASE_OUT_S, { BackgroundTransparency = 0.15 })
			end)
			ActionBtn.MouseLeave:Connect(function()
				tween(ActionBtn, EASE_OUT_S, { BackgroundTransparency = 0 })
			end)
		end

		local ProgressBack = new("Frame", {
			Size = UDim2.new(1, 0, 0, 3),
			BackgroundColor3 = Color3.fromRGB(255,255,255),
			BackgroundTransparency = 1,
			Parent = Card
		}, { corner(2) })
		
		local ProgressFill = new("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = color,
			BackgroundTransparency = 1,
			Parent = ProgressBack
		}, { corner(2) })

		playSound("Notify", 0.35)

		local dismissed = false
		local function dismiss()
			if dismissed then return end
			dismissed = true
			if not Card.Parent then return end
			
			tween(Card, EASE_OUT, {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -30, 0, Card.AbsoluteSize.Y)
			})
			tween(AccentBar, EASE_OUT_S, { BackgroundTransparency = 1 })
			tween(IconLbl, EASE_OUT_S, { TextTransparency = 1 })
			tween(TitleLabel, EASE_OUT_S, { TextTransparency = 1 })
			tween(CloseX, EASE_OUT_S, { TextTransparency = 1 })
			tween(MsgLbl, EASE_OUT_S, { TextTransparency = 1 })
			if ActionBtn then
				tween(ActionBtn, EASE_OUT_S, {
					TextTransparency = 1,
					BackgroundTransparency = 1
				})
			end
			tween(ProgressBack, EASE_OUT_S, { BackgroundTransparency = 1 })
			task.delay(0.25, function()
				pcall(function() Card:Destroy() end)
			end)
		end

		CloseX.MouseButton1Click:Connect(function()
			playSound("Click", 0.2)
			dismiss()
		end)
		
		if ActionBtn then
			ActionBtn.MouseButton1Click:Connect(function()
				playSound("Click", 0.3)
				if opts.actionCallback then
					pcall(function() opts.actionCallback() end)
				end
				dismiss()
			end)
		end

		local paused = false
		local remaining = duration
		local startTime = os.clock()
		
		Card.MouseEnter:Connect(function()
			paused = true
			remaining = remaining - (os.clock() - startTime)
		end)
		
		Card.MouseLeave:Connect(function()
			if paused then
				paused = false
				startTime = os.clock()
				tween(ProgressFill, TweenInfo.new(math.max(remaining, 0.2), Enum.EasingStyle.Linear), {
					Size = UDim2.new(0, 0, 1, 0)
				})
				task.delay(math.max(remaining, 0.2), function()
					if not paused then dismiss() end
				end)
			end
		end)

		Card.Size = UDim2.new(1, 40, 0, 0)
		tween(Card, EASE_SPRING, {
			BackgroundTransparency = 0.05,
			Size = UDim2.new(1, 0, 0, 0)
		})
		tween(AccentBar, EASE_OUT, { BackgroundTransparency = 0 })
		tween(IconLbl, EASE_OUT, { TextTransparency = 0 })
		tween(TitleLabel, EASE_OUT, { TextTransparency = 0 })
		tween(CloseX, EASE_OUT, { TextTransparency = 0.3 })
		tween(MsgLbl, EASE_OUT, { TextTransparency = 0.15 })
		if ActionBtn then
			tween(ActionBtn, EASE_OUT, {
				TextTransparency = 0,
				BackgroundTransparency = 0
			})
		end
		tween(ProgressBack, EASE_OUT, { BackgroundTransparency = 0.85 })
		tween(ProgressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
			Size = UDim2.new(0, 0, 1, 0)
		})

		task.delay(duration, function()
			if not paused then dismiss() end
		end)
		
		return { Dismiss = dismiss }
	end

	-- ═══ CONFIRM DIALOG (AURUM) ═══
	local DialogOverlay = new("Frame", {
		Name = "DialogOverlay",
		Size = UDim2.fromScale(1,1),
		BackgroundColor3 = Color3.new(0,0,0),
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 300,
		Parent = ScreenGui,
	})

	local function confirmDialog(title, message, onConfirm, onCancel, confirmText, cancelText)
		DialogOverlay.Visible = true
		tween(DialogOverlay, EASE_OUT_S, { BackgroundTransparency = 0.5 })

		local Box = new("Frame", {
			Size = UDim2.fromOffset(360, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.42),
			BackgroundColor3 = Theme.Background,
			ZIndex = 301,
			Parent = DialogOverlay,
		}, { corner(14), stroke(Theme.Accent, 1, 0.3) })
		
		padding(22, 20, 22, 20).Parent = Box
		new("UIListLayout", {
			Padding = UDim.new(0, 14),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = Box
		})

		new("TextLabel", {
			Size = UDim2.new(1, 0, 0, 22),
			BackgroundTransparency = 1,
			Text = title or "Confirm",
			TextColor3 = Theme.TextMain,
			Font = Fonts.Title,
			TextSize = 17,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Box,
		})
		
		new("TextLabel", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Text = message or "",
			TextColor3 = Theme.TextDim,
			Font = Fonts.Reg,
			TextSize = 13,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Box,
		})

		local BtnRow = new("Frame", {
			Size = UDim2.new(1, 0, 0, 38),
			BackgroundTransparency = 1,
			Parent = Box
		})
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0,10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = BtnRow
		})

		local CancelBtn = new("TextButton", {
			Size = UDim2.fromOffset(100, 36),
			BackgroundColor3 = Color3.fromRGB(30,28,38),
			Text = cancelText or "Cancel",
			TextColor3 = Theme.TextMain,
			Font = Fonts.Semi,
			TextSize = 13,
			AutoButtonColor = false,
			Parent = BtnRow,
		}, { corner(8) })
		
		local ConfirmBtn = new("TextButton", {
			Size = UDim2.fromOffset(120, 36),
			BackgroundColor3 = Theme.Accent,
			Text = confirmText or "Confirm",
			TextColor3 = Color3.new(1,1,1),
			Font = Fonts.Bold,
			TextSize = 13,
			AutoButtonColor = false,
			Parent = BtnRow,
		}, { corner(8) })

		CancelBtn.MouseEnter:Connect(function()
			tween(CancelBtn, EASE_OUT_S, { BackgroundColor3 = Color3.fromRGB(40,38,48) })
		end)
		CancelBtn.MouseLeave:Connect(function()
			tween(CancelBtn, EASE_OUT_S, { BackgroundColor3 = Color3.fromRGB(30,28,38) })
		end)
		
		ConfirmBtn.MouseEnter:Connect(function()
			tween(ConfirmBtn, EASE_OUT_S, { BackgroundColor3 = Theme.AccentBright })
		end)
		ConfirmBtn.MouseLeave:Connect(function()
			tween(ConfirmBtn, EASE_OUT_S, { BackgroundColor3 = Theme.Accent })
		end)

		local function closeDialog()
			tween(Box, EASE_OUT_S, { Size = UDim2.fromOffset(360, 0) })
			tween(DialogOverlay, EASE_OUT_S, { BackgroundTransparency = 1 })
			task.delay(0.2, function()
				DialogOverlay.Visible = false
				pcall(function() Box:Destroy() end)
			end)
		end

		CancelBtn.MouseButton1Click:Connect(function()
			playSound("Click", 0.25)
			if onCancel then pcall(function() onCancel() end) end
			closeDialog()
		end)
		
		ConfirmBtn.MouseButton1Click:Connect(function()
			playSound("Confirm", 0.35)
			if onConfirm then pcall(function() onConfirm() end) end
			closeDialog()
		end)

		Box.Size = UDim2.fromOffset(360, 0)
		Box.BackgroundTransparency = 1
		playSound("Notify", 0.3)
		tween(Box, EASE_SPRING, { BackgroundTransparency = 0 })
	end

	-- ═══ TAB SYSTEM (AURUM) ═══
	local Emloxa = {}
	Emloxa.Tabs = {}
	Emloxa.CurrentTab = nil
	Emloxa.Notify = notify
	Emloxa.Confirm = confirmDialog

	local function selectTab(tabId)
		if Emloxa.CurrentTab == tabId then return end
		playSound("Tab", 0.3)
		
		for id, data in pairs(Emloxa.Tabs) do
			local isActive = (id == tabId)
			local btn, page, indicator, icon = data.Button, data.Page, data.Indicator, data.Icon
			
			if isActive then
				tween(btn, EASE_OUT_S, { BackgroundColor3 = Theme.Card })
				tween(indicator, EASE_OUT_S, {
					BackgroundTransparency = 0,
					Size = UDim2.new(0, 3, 0.6, 0)
				})
				tween(icon, EASE_OUT_S, { TextColor3 = Theme.AccentBright })
				page.Visible = true
				page.Position = UDim2.fromOffset(24, 0)
				page.GroupTransparency = 1
				tween(page, EASE_OUT, {
					Position = UDim2.fromOffset(0,0),
					GroupTransparency = 0
				})
			else
				tween(btn, EASE_OUT_S, { BackgroundColor3 = Theme.Sidebar })
				tween(indicator, EASE_OUT_S, {
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 3, 0, 0)
				})
				tween(icon, EASE_OUT_S, { TextColor3 = Theme.TextDim })
				task.delay(0.15, function()
					if Emloxa.CurrentTab ~= id then
						page.Visible = false
					end
				end)
			end
		end
		
		Emloxa.CurrentTab = tabId
	end

	function Emloxa:AddSidebarSection(name)
		new("TextLabel", {
			Size = UDim2.new(1, 0, 0, 22),
			BackgroundTransparency = 1,
			Text = string.upper(name),
			TextColor3 = Theme.TextDim,
			Font = Fonts.Bold,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = SidebarScroll,
		})
	end

	function Emloxa:CreateTab(name, iconText, order)
		local id = name
		
		local Btn = new("TextButton", {
			Name = "Tab_" .. name,
			Size = UDim2.new(1, 0, 0, 38),
			BackgroundColor3 = Theme.Sidebar,
			AutoButtonColor = false,
			Text = "",
			LayoutOrder = order or 0,
			Parent = SidebarScroll,
		}, { corner(8) })

		local Indicator = new("Frame", {
			Size = UDim2.new(0, 3, 0, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 2, 0.5, 0),
			BackgroundColor3 = Theme.AccentBright,
			BackgroundTransparency = 1,
			Parent = Btn,
		}, { corner(2) })
		
		local indicatorGrad = gradient(ColorSequence.new({
			ColorSequenceKeypoint.new(0, Theme.AccentBright),
			ColorSequenceKeypoint.new(1, Theme.Gold),
		}))
		indicatorGrad.Rotation = 90
		indicatorGrad.Parent = Indicator

		local Icon = new("TextLabel", {
			Size = UDim2.fromOffset(24, 24),
			Position = UDim2.fromOffset(12, 7),
			BackgroundTransparency = 1,
			Text = iconText or "◆",
			TextColor3 = Theme.TextDim,
			Font = Fonts.Semi,
			TextSize = 15,
			Parent = Btn,
		})

		new("TextLabel", {
			Size = UDim2.new(1, -46, 1, 0),
			Position = UDim2.fromOffset(40, 0),
			BackgroundTransparency = 1,
			Text = name,
			TextColor3 = Theme.TextMain,
			Font = Fonts.Semi,
			TextSize = 13.5,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Btn,
		})

		Btn.MouseEnter:Connect(function()
			playSound("Hover", 0.15)
			if Emloxa.CurrentTab ~= id then
				tween(Btn, EASE_OUT_S, { BackgroundColor3 = Theme.CardHover })
			end
		end)
		
		Btn.MouseLeave:Connect(function()
			if Emloxa.CurrentTab ~= id then
				tween(Btn, EASE_OUT_S, { BackgroundColor3 = Theme.Sidebar })
			end
		end)

		local Page = new("CanvasGroup", {
			Name = "Page_" .. name,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Visible = false,
			Parent = ContentArea
		})
		
		local Scroll = new("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Theme.Accent,
			CanvasSize = UDim2.new(0,0,0,0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Parent = Page,
		})
		
		padding(20, 18, 16, 18).Parent = Scroll
		new("UIListLayout", {
			Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = Scroll
		})

		new("TextLabel", {
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundTransparency = 1,
			Text = name,
			TextColor3 = Theme.TextMain,
			Font = Fonts.Title,
			TextSize = 20,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = -1,
			Parent = Scroll,
		})

		Btn.MouseButton1Click:Connect(function()
			selectTab(id)
		end)
		
		Emloxa.Tabs[id] = {
			Button = Btn,
			Page = Page,
			Indicator = Indicator,
			Icon = Icon,
			Scroll = Scroll
		}
		
		if not Emloxa.CurrentTab then
			task.defer(function() selectTab(id) end)
		end

		-- ═══ ELEMENT BUILDERS (AURUM DESIGN) ═══
		local TabAPI = {}

		function TabAPI:AddButton(text, callback, tooltip)
			local Card = new("Frame", {
				Size = UDim2.new(1, 0, 0, 44),
				BackgroundColor3 = Theme.Card,
				ClipsDescendants = true,
				Parent = Scroll
			}, { corner(10), stroke(Theme.Stroke, 1) })
			
			local Btn2 = new("TextButton", {
				Size = UDim2.fromScale(1,1),
				BackgroundTransparency = 1,
				Text = "",
				Parent = Card,
				ZIndex = 2
			})
			
			new("TextLabel", {
				Size = UDim2.new(1, -20, 1, 0),
				Position = UDim2.fromOffset(16, 0),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Theme.TextMain,
				Font = Fonts.Semi,
				TextSize = 13.5,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = Card,
			})
			
			local Chevron = new("TextLabel", {
				Size = UDim2.fromOffset(20, 44),
				Position = UDim2.new(1, -30, 0, 0),
				BackgroundTransparency = 1,
				Text = "›",
				TextColor3 = Theme.TextDim,
				Font = Fonts.Bold,
				TextSize = 16,
				Parent = Card,
			})
			
			Btn2.MouseEnter:Connect(function()
				playSound("Hover", 0.15)
				tween(Card, EASE_OUT_S, { BackgroundColor3 = Theme.CardHover })
				tween(Card:FindFirstChildOfClass("UIStroke"), EASE_OUT_S, { Color = Theme.Accent })
				tween(Chevron, EASE_OUT_S, {
					TextColor3 = Theme.AccentBright,
					Position = UDim2.new(1,-26,0,0)
				})
			end)
			
			Btn2.MouseLeave:Connect(function()
				tween(Card, EASE_OUT_S, { BackgroundColor3 = Theme.Card })
				tween(Card:FindFirstChildOfClass("UIStroke"), EASE_OUT_S, { Color = Theme.Stroke })
				tween(Chevron, EASE_OUT_S, {
					TextColor3 = Theme.TextDim,
					Position = UDim2.new(1,-30,0,0)
				})
			end)
			
			Btn2.MouseButton1Click:Connect(function()
				playSound("Click", 0.3)
				ripple(Card, Card.AbsoluteSize.X/2, Card.AbsoluteSize.Y/2)
				if callback then pcall(function() callback() end) end
			end)
			
			return Card
		end

		function TabAPI:AddSwitch(text, default, callback, tooltip)
			local state = default or false
			
			local Card = new("Frame", {
				Size = UDim2.new(1, 0, 0, 44),
				BackgroundColor3 = Theme.Card,
				Parent = Scroll
			}, { corner(10), stroke(Theme.Stroke, 1) })
			
			new("TextLabel", {
				Size = UDim2.new(1, -80, 1, 0),
				Position = UDim2.fromOffset(16, 0),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Theme.TextMain,
				Font = Fonts.Semi,
				TextSize = 13.5,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = Card,
			})
			
			local Track = new("Frame", {
				Size = UDim2.fromOffset(44, 24),
				Position = UDim2.new(1, -60, 0.5, -12),
				BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(45,42,55),
				Parent = Card,
			}, { corner(12) })
			
			local TrackGlow = new("UIStroke", {
				Color = Theme.AccentBright,
				Thickness = 2,
				Transparency = state and 0.5 or 1,
				Parent = Track
			})
			
			local Knob = new("Frame", {
				Size = UDim2.fromOffset(18, 18),
				Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
				BackgroundColor3 = Color3.new(1,1,1),
				Parent = Track,
			}, { corner(9) })
			
			local Click = new("TextButton", {
				Size = UDim2.fromScale(1,1),
				BackgroundTransparency = 1,
				Text = "",
				Parent = Card
			})
			
			local function render()
				tween(Track, EASE_SPRING, {
					BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(45,42,55)
				})
				tween(TrackGlow, EASE_OUT_S, { Transparency = state and 0.5 or 1 })
				tween(Knob, EASE_SPRING, {
					Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
				})
			end
			
			Click.MouseButton1Click:Connect(function()
				state = not state
				playSound("Toggle", 0.3, state and 1.15 or 0.9)
				render()
				if callback then pcall(function() callback(state) end) end
			end)
			
			Card.MouseEnter:Connect(function()
				playSound("Hover", 0.15)
				tween(Card, EASE_OUT_S, {BackgroundColor3 = Theme.CardHover})
			end)
			
			Card.MouseLeave:Connect(function()
				tween(Card, EASE_OUT_S, {BackgroundColor3 = Theme.Card})
			end)
			
			if callback and default then
				pcall(function() callback(true) end)
			end
			
			return {
				Set = function(v) state = v render() end,
				Get = function() return state end
			}
		end

		function TabAPI:AddSlider(text, min, max, default, callback, tooltip)
			min, max = min or 0, max or 100
			local value = math.clamp(default or min, min, max)
			
			local Card = new("Frame", {
				Size = UDim2.new(1, 0, 0, 58),
				BackgroundColor3 = Theme.Card,
				Parent = Scroll
			}, { corner(10), stroke(Theme.Stroke, 1) })
			
			padding(16, 10, 16, 10).Parent = Card
			
			local Top = new("Frame", {
				Size = UDim2.new(1,0,0,18),
				BackgroundTransparency = 1,
				Parent = Card
			})
			
			new("TextLabel", {
				Size = UDim2.new(0.7,0,1,0),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Theme.TextMain,
				Font = Fonts.Semi,
				TextSize = 13.5,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = Top,
			})
			
			local ValueLbl = new("TextLabel", {
				Size = UDim2.new(0.3,0,1,0),
				Position = UDim2.new(0.7,0,0,0),
				BackgroundTransparency = 1,
				Text = tostring(value),
				TextColor3 = Theme.AccentBright,
				Font = Fonts.Bold,
				TextSize = 13.5,
				TextXAlignment = Enum.TextXAlignment.Right,
				Parent = Top,
			})
			
			local Bar = new("Frame", {
				Size = UDim2.new(1, 0, 0, 6),
				Position = UDim2.fromOffset(0, 32),
				BackgroundColor3 = Color3.fromRGB(45,42,55),
				Parent = Card
			}, { corner(3) })
			
			local pct = (value - min) / (max - min)
			
			local Fill = new("Frame", {
				Size = UDim2.new(pct, 0, 1, 0),
				BackgroundColor3 = Theme.Accent,
				Parent = Bar
			}, { corner(3) })
			
			gradient(ColorSequence.new({
				ColorSequenceKeypoint.new(0, Theme.Accent),
				ColorSequenceKeypoint.new(1, Theme.Gold)
			})).Parent = Fill
			
			local Knob = new("Frame", {
				Size = UDim2.fromOffset(14,14),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(pct, 0, 0.5, 0),
				BackgroundColor3 = Color3.new(1,1,1),
				Parent = Bar,
			}, { corner(7), stroke(Theme.Accent, 2) })
			
			local dragging = false
			local lastSoundTick = 0
			
			local function updateFromX(x)
				local rel = math.clamp((x - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
				value = math.floor(min + (max - min) * rel)
				ValueLbl.Text = tostring(value)
				tween(Fill, TweenInfo.new(0.05), { Size = UDim2.new(rel,0,1,0) })
				tween(Knob, TweenInfo.new(0.05), { Position = UDim2.new(rel,0,0.5,0) })
				
				local now = os.clock()
				if now - lastSoundTick > 0.06 then
					playSound("Slider", 0.12, 0.9 + rel * 0.4)
					lastSoundTick = now
				end
				
				if callback then pcall(function() callback(value) end) end
			end
			
			Bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					updateFromX(input.Position.X)
				end
			end)
			
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					updateFromX(input.Position.X)
				end
			end)
			
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
			
			return {
				Set = function(v)
					value = math.clamp(v,min,max)
					updateFromX(Bar.AbsolutePosition.X + (value-min)/(max-min)*Bar.AbsoluteSize.X)
				end,
				Get = function() return value end,
			}
		end

		function TabAPI:AddDropdown(text, options, default, callback, tooltip)
			options = options or {}
			local selected = default or options[1] or "Select..."
			local open = false
			
			local Card = new("Frame", {
				Size = UDim2.new(1, 0, 0, 44),
				BackgroundColor3 = Theme.Card,
				ClipsDescendants = false,
				ZIndex = 5,
				Parent = Scroll
			}, { corner(10), stroke(Theme.Stroke, 1) })
			
			new("TextLabel", {
				Size = UDim2.new(0.5, -10, 1, 0),
				Position = UDim2.fromOffset(16, 0),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Theme.TextMain,
				Font = Fonts.Semi,
				TextSize = 13.5,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = Card,
			})
			
			local SelBtn = new("TextButton", {
				Size = UDim2.new(0.5, -16, 0, 30),
				Position = UDim2.new(0.5, 0, 0.5, -15),
				BackgroundColor3 = Color3.fromRGB(30,28,38),
				Text = "",
				AutoButtonColor = false,
				ZIndex = 6,
				Parent = Card,
			}, { corner(8) })
			
			local SelLbl = new("TextLabel", {
				Size = UDim2.new(1, -30, 1, 0),
				Position = UDim2.fromOffset(10, 0),
				BackgroundTransparency = 1,
				Text = selected,
				TextColor3 = Theme.AccentBright,
				Font = Fonts.Semi,
				TextSize = 12.5,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 6,
				Parent = SelBtn,
			})
			
			local Arrow = new("TextLabel", {
				Size = UDim2.fromOffset(20,30),
				Position = UDim2.new(1,-24,0,0),
				BackgroundTransparency = 1,
				Text = "▾",
				TextColor3 = Theme.TextDim,
				Font = Fonts.Bold,
				TextSize = 12,
				ZIndex = 6,
				Parent = SelBtn,
			})
			
			local ListHolder = new("Frame", {
				Size = UDim2.new(0.5, -16, 0, 0),
				Position = UDim2.new(0.5, 0, 0, 48),
				BackgroundColor3 = Color3.fromRGB(24,22,32),
				ClipsDescendants = true,
				ZIndex = 10,
				Parent = Card,
			}, { corner(8), stroke(Theme.Accent, 1) })
			
			new("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = ListHolder
			})
			
			local function closeList()
				open = false
				tween(ListHolder, EASE_OUT_S, { Size = UDim2.new(0.5,-16,0,0) })
				tween(Arrow, EASE_OUT_S, { Rotation = 0 })
				task.delay(0.18, function()
					if not open then Card.ZIndex = 5 end
				end)
			end
			
			local function openList()
				open = true
				Card.ZIndex = 20
				local h = math.min(#options * 30, 150)
				tween(ListHolder, EASE_OUT, { Size = UDim2.new(0.5,-16,0,h) })
				tween(Arrow, EASE_OUT_S, { Rotation = 180 })
			end
			
			for _, opt in ipairs(options) do
				local OptBtn = new("TextButton", {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundColor3 = Color3.fromRGB(24,22,32),
					AutoButtonColor = false,
					Text = "",
					ZIndex = 11,
					Parent = ListHolder,
				})
				
				new("TextLabel", {
					Size = UDim2.new(1,-16,1,0),
					Position = UDim2.fromOffset(10,0),
					BackgroundTransparency = 1,
					Text = opt,
					TextColor3 = Theme.TextMain,
					Font = Fonts.Reg,
					TextSize = 12.5,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 11,
					Parent = OptBtn,
				})
				
				OptBtn.MouseEnter:Connect(function()
					playSound("Hover", 0.12)
					tween(OptBtn, EASE_OUT_S, {BackgroundColor3 = Theme.Accent})
				end)
				
				OptBtn.MouseLeave:Connect(function()
					tween(OptBtn, EASE_OUT_S, {BackgroundColor3 = Color3.fromRGB(24,22,32)})
				end)
				
				OptBtn.MouseButton1Click:Connect(function()
					selected = opt
					SelLbl.Text = opt
					playSound("Click", 0.25)
					closeList()
					if callback then pcall(function() callback(opt) end) end
				end)
			end
			
			SelBtn.MouseButton1Click:Connect(function()
				playSound("Click", 0.25)
				if open then closeList() else openList() end
			end)
			
			SelBtn.MouseEnter:Connect(function()
				tween(SelBtn, EASE_OUT_S, {BackgroundColor3 = Color3.fromRGB(38,35,48)})
			end)
			
			SelBtn.MouseLeave:Connect(function()
				tween(SelBtn, EASE_OUT_S, {BackgroundColor3 = Color3.fromRGB(30,28,38)})
			end)
			
			return {
				Set = function(v) selected = v SelLbl.Text = v end,
				Get = function() return selected end
			}
		end

		function TabAPI:AddTextbox(text, placeholder, callback, tooltip)
			local Card = new("Frame", {
				Size = UDim2.new(1, 0, 0, 44),
				BackgroundColor3 = Theme.Card,
				Parent = Scroll
			}, { corner(10), stroke(Theme.Stroke, 1) })
			
			new("TextLabel", {
				Size = UDim2.new(0.4, 0, 1, 0),
				Position = UDim2.fromOffset(16, 0),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Theme.TextMain,
				Font = Fonts.Semi,
				TextSize = 13.5,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = Card,
			})
			
			local InputWrap = new("Frame", {
				Size = UDim2.new(0.5, -16, 0, 30),
				Position = UDim2.new(0.5, 0, 0.5, -15),
				BackgroundColor3 = Color3.fromRGB(30,28,38),
				Parent = Card,
			}, { corner(8), stroke(Theme.Stroke, 1) })
			
			local Box = new("TextBox", {
				Size = UDim2.new(1, -16, 1, 0),
				Position = UDim2.fromOffset(8, 0),
				BackgroundTransparency = 1,
				Text = "",
				PlaceholderText = placeholder or "Type here...",
				ClearTextOnFocus = false,
				TextColor3 = Theme.TextMain,
				PlaceholderColor3 = Theme.TextDim,
				Font = Fonts.Reg,
				TextSize = 12.5,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = InputWrap,
			})
			
			Box.Focused:Connect(function()
				playSound("Type", 0.15)
				tween(InputWrap:FindFirstChildOfClass("UIStroke"), EASE_OUT_S, { Color = Theme.Accent })
			end)
			
			Box.FocusLost:Connect(function(enterPressed)
				tween(InputWrap:FindFirstChildOfClass("UIStroke"), EASE_OUT_S, { Color = Theme.Stroke })
				if callback then pcall(function() callback(Box.Text, enterPressed) end) end
			end)
			
			return {
				Set = function(v) Box.Text = v end,
				Get = function() return Box.Text end
			}
		end

		function TabAPI:AddLabel(text)
			return new("TextLabel", {
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Theme.TextDim,
				Font = Fonts.Semi,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = Scroll,
			})
		end

		function TabAPI:AddDivider()
			return new("Frame", {
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = Theme.Stroke,
				BackgroundTransparency = 0.4,
				Parent = Scroll
			})
		end

		function TabAPI:CreateNotification(title, message, duration)
			return notify(title, message, "Info", duration or 2)
		end

		return TabAPI
	end

	-- ═══ SETTINGS TAB (AURUM THEME SELECTOR) ═══
	Emloxa:AddSidebarSection("Main")
	local SettingsTab = Emloxa:CreateTab("Settings", "⚙", 100)
	local DScroll = Emloxa.Tabs["Settings"].Scroll

	SettingsTab:AddLabel("APPEARANCE")

	do
		local Card = new("Frame", {
			Size = UDim2.new(1, 0, 0, 112),
			BackgroundColor3 = Theme.Card,
			Parent = DScroll
		}, { corner(10), stroke(Theme.Stroke, 1) })
		
		padding(16, 12, 16, 12).Parent = Card
		
		new("TextLabel", {
			Size = UDim2.new(1, 0, 0, 18),
			BackgroundTransparency = 1,
			Text = "Theme",
			TextColor3 = Theme.TextMain,
			Font = Fonts.Semi,
			TextSize = 13.5,
			TextXAlignment = Enum.TextXAlignment.Left,
			Parent = Card,
		})
		
		local SwatchRow = new("Frame", {
			Size = UDim2.new(1, 0, 0, 60),
			Position = UDim2.fromOffset(0, 26),
			BackgroundTransparency = 1,
			Parent = Card
		})
		
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = SwatchRow
		})

		local swatchButtons = {}
		local themeOrder = {
			"Amethyst", "Crimson", "Emerald",
			"Sapphire", "Monochrome", "Sunset"
		}
		
		local function refreshSwatchSelection()
			for name, btn in pairs(swatchButtons) do
				tween(btn.Ring, EASE_OUT_S, {
					ImageTransparency = (Config.ThemeName == name) and 0 or 1
				})
			end
		end
		
		for _, name in ipairs(themeOrder) do
			local preset = ThemePresets[name]
			
			local SwatchBtn = new("TextButton", {
				Size = UDim2.fromOffset(40, 60),
				BackgroundTransparency = 1,
				Text = "",
				Parent = SwatchRow
			})
			
			local Circle = new("Frame", {
				Size = UDim2.fromOffset(32, 32),
				Position = UDim2.fromOffset(4, 0),
				BackgroundColor3 = preset.Accent,
				Parent = SwatchBtn
			}, { corner(16) })
			
			gradient(ColorSequence.new({
				ColorSequenceKeypoint.new(0, preset.Accent),
				ColorSequenceKeypoint.new(1, preset.Gold)
			}), 45).Parent = Circle
			
			local Ring = new("UIStroke", {
				Color = Theme.AccentBright,
				Thickness = 2,
				Transparency = 1,
				Parent = Circle
			})
			
			new("TextLabel", {
				Size = UDim2.new(1, 0, 0, 16),
				Position = UDim2.fromOffset(0, 38),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Theme.TextDim,
				Font = Fonts.Reg,
				TextSize = 9,
				Parent = SwatchBtn,
			})
			
			SwatchBtn.MouseEnter:Connect(function()
				playSound("Hover", 0.15)
				tween(Circle, EASE_OUT_S, { Size = UDim2.fromOffset(36,36) })
			end)
			
			SwatchBtn.MouseLeave:Connect(function()
				tween(Circle, EASE_OUT_S, { Size = UDim2.fromOffset(32,32) })
			end)
			
			SwatchBtn.MouseButton1Click:Connect(function()
				playSound("Click", 0.3)
				Config.ThemeName = name
				Theme = ThemePresets[name]
				applyThemeToAll()
				refreshSwatchSelection()
				notify("Theme Changed", "Applied the " .. name .. " theme.", "Success", 3)
			end)
			
			swatchButtons[name] = { Ring = Ring }
		end
		
		refreshSwatchSelection()
	end

	SettingsTab:AddLabel("BEHAVIOR & AUDIO")
	
	SettingsTab:AddSwitch("UI Sound Effects", true, function(state)
		SoundsEnabled = state
	end, "Toggle all interface sounds on or off")
	
	SettingsTab:AddSlider("Sound Volume", 0, 100, 40, function(v)
		SoundVolume = v / 100
	end, "Adjust the volume of UI sound effects")

	SettingsTab:AddLabel("WINDOW")
	
	SettingsTab:AddButton("Send Test Notification", function()
		notify("Test Notification", "This is what a notification looks like.", "Success", 4, {
			actionText = "Undo",
			actionCallback = function()
				notify("Undone", "You clicked the action button.", "Info", 2)
			end
		})
	end, "Fire a sample notification with an action button")
	
	SettingsTab:AddButton("Preview Confirm Dialog", function()
		confirmDialog("Are you sure?", "This is a preview of the confirm dialog system.", function()
			notify("Confirmed", "You clicked confirm.", "Success", 2)
		end, function()
			notify("Cancelled", "You clicked cancel.", "Warning", 2)
		end)
	end, "See how the confirmation dialog looks")

	SettingsTab:AddLabel("ABOUT")
	SettingsTab:AddLabel("Emloxa Admin Panel • v19.0 Aurum Edition")

	-- ═══ WINDOW CONTROLS ═══
	local visible = false
	local minimized = false

	local function openPanel()
		visible = true
		MainFrame.Visible = true
		local targetSize = UDim2.fromOffset(DEFAULT_W, DEFAULT_H)
		MainFrame.Size = UDim2.fromOffset(targetSize.X.Offset, 0)
		MainFrame.BackgroundTransparency = 1
		playSound("Open", 0.35)
		tween(MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = targetSize,
			BackgroundTransparency = 0,
		})
	end

	local function closePanel()
		visible = false
		playSound("Close", 0.3, 0.85)
		local t = tween(MainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			Size = UDim2.fromOffset(MainFrame.Size.X.Offset, 0),
			BackgroundTransparency = 1,
		})
		t.Completed:Connect(function()
			if not visible then MainFrame.Visible = false end
		end)
	end

	local function toggleMinimize()
		minimized = not minimized
		playSound("Click", 0.3)
		if minimized then
			tween(MainFrame, EASE_OUT, { Size = UDim2.new(0, DEFAULT_W, 0, 46) })
			Sidebar.Visible = false
			ContentArea.Visible = false
			BottomBar.Visible = false
			ResizeHandle.Visible = false
		else
			tween(MainFrame, EASE_OUT, { Size = UDim2.fromOffset(DEFAULT_W, DEFAULT_H) })
			task.delay(0.1, function()
				Sidebar.Visible = true
				ContentArea.Visible = true
				BottomBar.Visible = true
				ResizeHandle.Visible = true
			end)
		end
	end

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.KeyCode == Config.ToggleKey then
			if LoaderDone then
				if visible then closePanel() else openPanel() end
			end
		end
	end)

	CloseBtn.MouseButton1Click:Connect(function() closePanel() end)
	MinimizeBtn.MouseButton1Click:Connect(function() toggleMinimize() end)

	task.delay(2.6, function()
		MainFrame.Visible = false
	end)

	WindowSetup.Emloxa = Emloxa
	return WindowSetup
end

return EmloxaLibrary
