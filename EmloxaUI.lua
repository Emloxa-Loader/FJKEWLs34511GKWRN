-- EMLOXA WARE UI LIBRARY (GitHub'a Yüklenecek Kısım)
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
    HubGui.IgnoreGuiInset = true -- Roblox'un üst barını kaplar (Tam Ekran)
    
    local success, _ = pcall(function() HubGui.Parent = game:GetService("CoreGui") end)
    if not success then HubGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- Loading Screen
    local LoadingFrame = Instance.new("Frame")
    LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
    LoadingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    LoadingFrame.Parent = HubGui

    local LoadText = Instance.new("TextLabel")
    LoadText.Text = "EMLOXA WARE INITIALIZING..."
    LoadText.Font = Enum.Font.GothamBold
    LoadText.TextSize = 30
    LoadText.BackgroundTransparency = 1
    LoadText.Size = UDim2.new(1, 0, 1, 0)
    LoadText.Parent = LoadingFrame

    -- RGB Animation for Loading Text
    local loadingRGB = RunService.RenderStepped:Connect(function()
        LoadText.TextColor3 = Color3.fromHSV(tick() % 4 / 4, 1, 1)
    end)

    task.wait(2.5) -- Yükleme süresi
    loadingRGB:Disconnect()
    TweenService:Create(LoadingFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoadText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    task.wait(0.5)
    LoadingFrame:Destroy()

    -- Main UI Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = HubGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8) -- Daha yumuşak köşeler

    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Text = " " .. hubName
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1 -- Keskin köşe hatası düzeltildi
    Title.Parent = TopBar

    -- RGB Title Animation
    RunService.RenderStepped:Connect(function()
        Title.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    end)

    -- Sürükleme (Dragging)
    local dragging, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        end
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
    TabContainer.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
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
        Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.Parent = PageScroll
        Instance.new("UIPadding", PageScroll).PaddingTop = UDim.new(0, 10)
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
