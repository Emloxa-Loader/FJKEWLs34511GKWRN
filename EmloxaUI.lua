-- ==========================================
-- EMLOXA WARE UI LIBRARY v4 (Discord Prompt & Credits)
-- ==========================================
local EmloxaLibrary = {}

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

function EmloxaLibrary:CreateWindow(hubName)
    local WindowSetup = {}
    
    local HubGui = Instance.new("ScreenGui")
    HubGui.Name = "EmloxaWareUI"
    HubGui.ResetOnSpawn = false
    HubGui.IgnoreGuiInset = true
    
    local success, _ = pcall(function() HubGui.Parent = game:GetService("CoreGui") end)
    if not success then HubGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- Sol Üstteki E Logosu
    local OpenIcon = Instance.new("TextButton")
    OpenIcon.Size = UDim2.new(0, 50, 0, 50)
    OpenIcon.Position = UDim2.new(0, 15, 0, 75)
    OpenIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    OpenIcon.Text = "E"
    OpenIcon.Font = Enum.Font.GothamBold
    OpenIcon.TextSize = 28
    OpenIcon.Visible = false
    OpenIcon.Parent = HubGui
    Instance.new("UICorner", OpenIcon).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", OpenIcon).Color = Color3.fromRGB(102, 85, 255)
    Instance.new("UIStroke", OpenIcon).Thickness = 2

    RunService.RenderStepped:Connect(function()
        OpenIcon.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        OpenIcon.UIStroke.Color = Color3.fromHSV(tick() % 5 / 5, 0.8, 1)
    end)

    -- Loading Screen
    local LoadingFrame = Instance.new("Frame")
    LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
    LoadingFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    LoadingFrame.Parent = HubGui

    local LoadText = Instance.new("TextLabel")
    LoadText.Text = "EMLOXA WARE INITIALIZING..."
    LoadText.Font = Enum.Font.GothamBold
    LoadText.TextSize = 32
    LoadText.BackgroundTransparency = 1
    LoadText.Size = UDim2.new(1, 0, 1, 0)
    LoadText.Parent = LoadingFrame

    local loadingRGB = RunService.RenderStepped:Connect(function()
        LoadText.TextColor3 = Color3.fromHSV(tick() % 4 / 4, 1, 1)
    end)

    task.wait(2)
    loadingRGB:Disconnect()
    TweenService:Create(LoadingFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoadText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    task.wait(0.5)
    LoadingFrame:Destroy()

    -- Main UI Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = HubGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Color3.fromRGB(40, 40, 45)
    MainStroke.Thickness = 1

    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Text = " " .. hubName
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Size = UDim2.new(1, -250, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Parent = TopBar
    
    RunService.RenderStepped:Connect(function()
        Title.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    end)

    -- CREDITS: Made By Emloxa
    local CreditsText = Instance.new("TextLabel")
    CreditsText.Text = "Made By Emloxa"
    CreditsText.Font = Enum.Font.GothamSemibold
    CreditsText.TextSize = 12
    CreditsText.TextColor3 = Color3.fromRGB(100, 100, 110)
    CreditsText.TextXAlignment = Enum.TextXAlignment.Right
    CreditsText.Size = UDim2.new(0, 120, 1, 0)
    CreditsText.Position = UDim2.new(1, -215, 0, 0)
    CreditsText.BackgroundTransparency = 1
    CreditsText.Parent = TopBar

    -- Controls
    local Controls = Instance.new("Frame")
    Controls.Size = UDim2.new(0, 80, 1, 0)
    Controls.Position = UDim2.new(1, -90, 0, 0)
    Controls.BackgroundTransparency = 1
    Controls.Parent = TopBar

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(0, 0, 0.5, -15)
    MinBtn.Text = "-"
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 20
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MinBtn.Parent = Controls
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(0, 40, 0.5, -15)
    CloseBtn.Text = "X"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    CloseBtn.Parent = Controls
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    local isMinimized = false
    MinBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local targetSize = isMinimized and UDim2.new(0, 600, 0, 45) or UDim2.new(0, 600, 0, 420)
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(0.3)
        MainFrame.Visible = false
        OpenIcon.Visible = true
        OpenIcon.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(OpenIcon, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 50, 0, 50)}):Play()
    end)

    OpenIcon.MouseButton1Click:Connect(function()
        TweenService:Create(OpenIcon, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(0.2)
        OpenIcon.Visible = false
        MainFrame.Visible = true
        local targetSize = isMinimized and UDim2.new(0, 600, 0, 45) or UDim2.new(0, 600, 0, 420)
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = targetSize}):Play()
    end)

    -- Sürükleme
    local dragging, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = MainFrame.Position end
    end)
    TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, 0, 0, 40)
    TabContainer.Position = UDim2.new(0, 0, 0, 45)
    TabContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame

    local TabList = Instance.new("UIListLayout")
    TabList.FillDirection = Enum.FillDirection.Horizontal
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Parent = TabContainer

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, 0, 1, -85)
    PageContainer.Position = UDim2.new(0, 0, 0, 85)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = MainFrame

    local Pages = {}
    local Tabs = {}

    -- DİSCORD BİLDİRİM FONKSİYONU
    function WindowSetup:ShowDiscordPrompt()
        local PromptFrame = Instance.new("Frame")
        PromptFrame.Size = UDim2.new(0, 320, 0, 120)
        PromptFrame.Position = UDim2.new(1, 20, 1, -140) -- Sağ alt köşe (Ekran dışı başlangıç)
        PromptFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        PromptFrame.Parent = HubGui
        Instance.new("UICorner", PromptFrame).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", PromptFrame).Color = Color3.fromRGB(102, 85, 255)

        local PTitle = Instance.new("TextLabel")
        PTitle.Text = "Discord Server"
        PTitle.Font = Enum.Font.GothamBold
        PTitle.TextSize = 16
        PTitle.TextColor3 = Color3.fromRGB(102, 85, 255)
        PTitle.Size = UDim2.new(1, -20, 0, 30)
        PTitle.Position = UDim2.new(0, 10, 0, 5)
        PTitle.BackgroundTransparency = 1
        PTitle.TextXAlignment = Enum.TextXAlignment.Left
        PTitle.Parent = PromptFrame

        local PDesc = Instance.new("TextLabel")
        PDesc.Text = "Would you like to join our Discord server for the latest updates and scripts?"
        PDesc.Font = Enum.Font.Gotham
        PDesc.TextSize = 13
        PDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
        PDesc.Size = UDim2.new(1, -20, 0, 40)
        PDesc.Position = UDim2.new(0, 10, 0, 35)
        PDesc.BackgroundTransparency = 1
        PDesc.TextXAlignment = Enum.TextXAlignment.Left
        PDesc.TextWrapped = true
        PDesc.Parent = PromptFrame

        local BtnYes = Instance.new("TextButton")
        BtnYes.Size = UDim2.new(0, 140, 0, 30)
        BtnYes.Position = UDim2.new(0, 10, 1, -40)
        BtnYes.BackgroundColor3 = Color3.fromRGB(102, 85, 255)
        BtnYes.Text = "Copy Link"
        BtnYes.Font = Enum.Font.GothamBold
        BtnYes.TextColor3 = Color3.fromRGB(255, 255, 255)
        BtnYes.TextSize = 12
        BtnYes.Parent = PromptFrame
        Instance.new("UICorner", BtnYes).CornerRadius = UDim.new(0, 6)

        local BtnNo = Instance.new("TextButton")
        BtnNo.Size = UDim2.new(0, 140, 0, 30)
        BtnNo.Position = UDim2.new(1, -150, 1, -40)
        BtnNo.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        BtnNo.Text = "No Thanks"
        BtnNo.Font = Enum.Font.Gotham
        BtnNo.TextColor3 = Color3.fromRGB(150, 150, 150)
        BtnNo.TextSize = 12
        BtnNo.Parent = PromptFrame
        Instance.new("UICorner", BtnNo).CornerRadius = UDim.new(0, 6)

        -- İçeri Kayma Animasyonu
        TweenService:Create(PromptFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -340, 1, -140)}):Play()

        local function ClosePrompt()
            TweenService:Create(PromptFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, 1, -140)}):Play()
            task.wait(0.5)
            PromptFrame:Destroy()
        end

        BtnYes.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard("https://discord.gg/XjfW7N84jT")
                BtnYes.Text = "Copied!"
                BtnYes.BackgroundColor3 = Color3.fromRGB(40, 200, 100)
            else
                BtnYes.Text = "Error"
            end
            task.wait(1)
            ClosePrompt()
        end)
        
        BtnNo.MouseButton1Click:Connect(ClosePrompt)
    end

    function WindowSetup:CreateTab(tabName)
        local TabSetup = {}
        
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 120, 1, 0)
        TabBtn.Text = tabName
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.TextSize = 14
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Parent = TabContainer

        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 0, 0, 2)
        Indicator.Position = UDim2.new(0.5, 0, 1, -2)
        Indicator.BackgroundColor3 = Color3.fromRGB(102, 85, 255)
        Indicator.BorderSizePixel = 0
        Indicator.Parent = TabBtn

        local PageScroll = Instance.new("ScrollingFrame")
        PageScroll.Size = UDim2.new(1, 0, 1, 0)
        PageScroll.BackgroundTransparency = 1
        PageScroll.BorderSizePixel = 0
        PageScroll.ScrollBarThickness = 3
        PageScroll.Visible = false
        PageScroll.Parent = PageContainer

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 10)
        PageLayout.Parent = PageScroll
        Instance.new("UIPadding", PageScroll).PaddingTop = UDim.new(0, 12)
        Instance.new("UIPadding", PageScroll).PaddingLeft = UDim.new(0, 15)
        Instance.new("UIPadding", PageScroll).PaddingRight = UDim.new(0, 15)

        TabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(Pages) do p.Visible = false end
            for _, t in pairs(Tabs) do
                TweenService:Create(t.Indicator, TweenInfo.new(0.3), {Size = UDim2.new(0,0,0,2), Position = UDim2.new(0.5,0,1,-2)}):Play()
                TweenService:Create(t.Btn, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
            end
            PageScroll.Visible = true
            TweenService:Create(Indicator, TweenInfo.new(0.3), {Size = UDim2.new(1,0,0,2), Position = UDim2.new(0,0,1,-2)}):Play()
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end)

        table.insert(Pages, PageScroll)
        table.insert(Tabs, {Btn = TabBtn, Indicator = Indicator})

        if #Pages == 1 then
            PageScroll.Visible = true
            Indicator.Size = UDim2.new(1,0,0,2); Indicator.Position = UDim2.new(0,0,1,-2)
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        function TabSetup:CreateToggle(name, callback)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, -10, 0, 45)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            ToggleFrame.Parent = PageScroll
            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", ToggleFrame).Color = Color3.fromRGB(45, 45, 50)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -70, 1, 0)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.Text = name
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = ToggleFrame

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(0, 46, 0, 24)
            Btn.Position = UDim2.new(1, -60, 0.5, -12)
            Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            Btn.Text = ""
            Btn.Parent = ToggleFrame
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)

            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0, 18, 0, 18)
            Circle.Position = UDim2.new(0, 3, 0.5, -9)
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Circle.Parent = Btn
            Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

            local state = false
            Btn.MouseButton1Click:Connect(function()
                state = not state
                local gPos = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
                local gCol = state and Color3.fromRGB(102, 85, 255) or Color3.fromRGB(50, 50, 55)
                TweenService:Create(Circle, TweenInfo.new(0.2), {Position = gPos}):Play()
                TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = gCol}):Play()
                callback(state)
            end)
        end

        function TabSetup:CreateSlider(name, min, max, default, callback)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, -10, 0, 60)
            SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            SliderFrame.Parent = PageScroll
            Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", SliderFrame).Color = Color3.fromRGB(45, 45, 50)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -30, 0, 25)
            Label.Position = UDim2.new(0, 15, 0, 5)
            Label.Text = name
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = SliderFrame

            local ValueText = Instance.new("TextLabel")
            ValueText.Size = UDim2.new(0, 40, 0, 25)
            ValueText.Position = UDim2.new(1, -55, 0, 5)
            ValueText.Text = tostring(default)
            ValueText.Font = Enum.Font.GothamBold
            ValueText.TextSize = 14
            ValueText.TextColor3 = Color3.fromRGB(102, 85, 255)
            ValueText.TextXAlignment = Enum.TextXAlignment.Right
            ValueText.BackgroundTransparency = 1
            ValueText.Parent = SliderFrame

            local Bar = Instance.new("TextButton")
            Bar.Size = UDim2.new(1, -30, 0, 6)
            Bar.Position = UDim2.new(0, 15, 0, 40)
            Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            Bar.Text = ""
            Bar.Parent = SliderFrame
            Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

            local Fill = Instance.new("Frame")
            local defaultPercent = (default - min) / (max - min)
            Fill.Size = UDim2.new(defaultPercent, 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(102, 85, 255)
            Fill.Parent = Bar
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

            local dragging = false
            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = input.Position.X
                    local barPos = Bar.AbsolutePosition.X
                    local barSize = Bar.AbsoluteSize.X
                    local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
                    
                    Fill.Size = UDim2.new(percent, 0, 1, 0)
                    local value = math.floor(min + ((max - min) * percent))
                    ValueText.Text = tostring(value)
                    callback(value)
                end
            end)
        end

        function TabSetup:CreateButton(name, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, -10, 0, 40)
            Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            Btn.Text = name
            Btn.Font = Enum.Font.Gotham
            Btn.TextSize = 14
            Btn.TextColor3 = Color3.fromRGB(220, 220, 220)
            Btn.Parent = PageScroll
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
            Instance.new("UIStroke", Btn).Color = Color3.fromRGB(45, 45, 50)

            Btn.MouseButton1Click:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(102, 85, 255)}):Play()
                task.wait(0.1)
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}):Play()
                callback()
            end)
        end

        return TabSetup
    end

    return WindowSetup
end

return EmloxaLibrary
