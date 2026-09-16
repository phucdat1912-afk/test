--// Anime Card Farm - Pack Farm Hub
--// Full version
--// Drag GUI bằng DragBar riêng

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local RequestConveyorOffer = Remotes:WaitForChild("RequestConveyorOffer")
local BuyPack = Remotes:WaitForChild("BuyPack")
local SetRecoverPack = Remotes:WaitForChild("SetRecoverPack")

--==================================================
-- SETTINGS
--==================================================

local Running = false
local AntiAFK = true
local Delay = 1.5
local Event2Pack = false

local AllowedPacks = {
    ["Titan Slayer Pack"] = true,
    ["Chain Devil Pack"] = true,
    ["Soccer Pack"] = true
}

--==================================================
-- REMOVE OLD GUI
--==================================================

pcall(function()
    local OldGui = CoreGui:FindFirstChild("1tap_PackFarm")
    if OldGui then
        OldGui:Destroy()
    end
end)

--==================================================
-- COLORS
--==================================================

local BG = Color3.fromRGB(18, 18, 22)
local SIDEBAR = Color3.fromRGB(24, 24, 29)
local PANEL = Color3.fromRGB(29, 29, 35)
local BUTTON = Color3.fromRGB(38, 38, 46)
local HOVER = Color3.fromRGB(48, 48, 58)

local WHITE = Color3.fromRGB(235, 235, 240)
local GRAY = Color3.fromRGB(155, 155, 165)
local GREEN = Color3.fromRGB(80, 220, 120)
local RED = Color3.fromRGB(240, 80, 80)
local BLUE = Color3.fromRGB(80, 150, 255)
local YELLOW = Color3.fromRGB(240, 200, 80)

--==================================================
-- GUI HELPERS
--==================================================

local function Create(className, properties, parent)
    local Object = Instance.new(className)

    for Property, Value in pairs(properties or {}) do
        Object[Property] = Value
    end

    Object.Parent = parent

    return Object
end

local function AddCorner(Object, Radius)
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, Radius or 8)
    Corner.Parent = Object
    return Corner
end

local function AddStroke(Object, Color, Thickness)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color or Color3.fromRGB(55, 55, 65)
    Stroke.Thickness = Thickness or 1
    Stroke.Parent = Object
    return Stroke
end

local function AddPadding(Object, Left, Right, Top, Bottom)
    local Padding = Instance.new("UIPadding")

    Padding.PaddingLeft = UDim.new(0, Left or 0)
    Padding.PaddingRight = UDim.new(0, Right or 0)
    Padding.PaddingTop = UDim.new(0, Top or 0)
    Padding.PaddingBottom = UDim.new(0, Bottom or 0)

    Padding.Parent = Object

    return Padding
end

--==================================================
-- SCREEN GUI
--==================================================

local ScreenGui = Create("ScreenGui", {
    Name = "1tap_PackFarm",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, CoreGui)

--==================================================
-- MAIN
--==================================================

local Main = Create("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 600, 0, 380),
    Position = UDim2.new(0.5, -300, 0.5, -190),
    BackgroundColor3 = BG,
    BorderSizePixel = 0,
    Active = true,
    ZIndex = 1
}, ScreenGui)

AddCorner(Main, 12)
AddStroke(Main, Color3.fromRGB(55, 55, 65), 1)

--==================================================
-- TITLE
--==================================================

local Title = Create("TextLabel", {
    Name = "Title",
    Size = UDim2.new(1, -70, 0, 45),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    Text = "1tap Pack Farm",
    TextColor3 = WHITE,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5
}, Main)

--==================================================
-- HIDE BUTTON
--==================================================

local HideButton = Create("TextButton", {
    Name = "HideButton",
    Size = UDim2.new(0, 42, 0, 32),
    Position = UDim2.new(1, -52, 0, 7),
    BackgroundColor3 = BUTTON,
    BorderSizePixel = 0,
    Text = "—",
    TextColor3 = WHITE,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    ZIndex = 150
}, Main)

AddCorner(HideButton, 7)

HideButton.MouseEnter:Connect(function()
    HideButton.BackgroundColor3 = HOVER
end)

HideButton.MouseLeave:Connect(function()
    HideButton.BackgroundColor3 = BUTTON
end)

--==================================================
-- DRAG BAR
--==================================================

-- Không che HideButton
local DragBar = Create("TextButton", {
    Name = "DragBar",
    Size = UDim2.new(1, -65, 0, 45),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Text = "",
    AutoButtonColor = false,
    Active = true,
    Selectable = false,
    ZIndex = 100
}, Main)

--==================================================
-- DRAG SYSTEM
--==================================================

local Dragging = false
local DragStart = nil
local StartPosition = nil

DragBar.MouseButton1Down:Connect(function()
    Dragging = true

    DragStart = UserInputService:GetMouseLocation()
    StartPosition = Main.Position
end)

UserInputService.InputChanged:Connect(function(Input)
    if not Dragging then
        return
    end

    if Input.UserInputType ~= Enum.UserInputType.MouseMovement then
        return
    end

    local MousePosition = UserInputService:GetMouseLocation()
    local Delta = MousePosition - DragStart

    Main.Position = UDim2.new(
        StartPosition.X.Scale,
        StartPosition.X.Offset + Delta.X,
        StartPosition.Y.Scale,
        StartPosition.Y.Offset + Delta.Y
    )
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = false
    end
end)

--==================================================
-- SIDEBAR
--==================================================

local Sidebar = Create("Frame", {
    Name = "Sidebar",
    Size = UDim2.new(0, 145, 1, -55),
    Position = UDim2.new(0, 10, 0, 50),
    BackgroundColor3 = SIDEBAR,
    BorderSizePixel = 0,
    Active = true,
    ZIndex = 2
}, Main)

AddCorner(Sidebar, 9)

--==================================================
-- CONTENT
--==================================================

local Content = Create("Frame", {
    Name = "Content",
    Size = UDim2.new(1, -170, 1, -55),
    Position = UDim2.new(0, 160, 0, 50),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    ZIndex = 2
}, Main)

AddCorner(Content, 9)

--==================================================
-- SIDEBAR BUTTON
--==================================================

local function CreateTabButton(Text, Y)
    local Button = Create("TextButton", {
        Size = UDim2.new(1, -16, 0, 42),
        Position = UDim2.new(0, 8, 0, Y),
        BackgroundColor3 = BUTTON,
        BorderSizePixel = 0,
        Text = Text,
        TextColor3 = GRAY,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = false,
        ZIndex = 5
    }, Sidebar)

    AddCorner(Button, 7)

    Button.MouseEnter:Connect(function()
        if Button.TextColor3 ~= WHITE then
            Button.BackgroundColor3 = HOVER
        end
    end)

    Button.MouseLeave:Connect(function()
        if Button.TextColor3 ~= WHITE then
            Button.BackgroundColor3 = BUTTON
        end
    end)

    return Button
end

local FarmTab = CreateTabButton("Farm", 12)
local SettingsTab = CreateTabButton("Settings", 62)
local LogsTab = CreateTabButton("Logs", 112)

--==================================================
-- PAGES
--==================================================

local FarmPage = Create("Frame", {
    Name = "FarmPage",
    Size = UDim2.new(1, -20, 1, -20),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 1,
    ZIndex = 3
}, Content)

local SettingsPage = Create("Frame", {
    Name = "SettingsPage",
    Size = UDim2.new(1, -20, 1, -20),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 1,
    Visible = false,
    ZIndex = 3
}, Content)

local LogsPage = Create("Frame", {
    Name = "LogsPage",
    Size = UDim2.new(1, -20, 1, -20),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 1,
    Visible = false,
    ZIndex = 3
}, Content)

--==================================================
-- PAGE SWITCH
--==================================================

local function SetPage(Page)
    FarmPage.Visible = false
    SettingsPage.Visible = false
    LogsPage.Visible = false

    FarmTab.BackgroundColor3 = BUTTON
    SettingsTab.BackgroundColor3 = BUTTON
    LogsTab.BackgroundColor3 = BUTTON

    FarmTab.TextColor3 = GRAY
    SettingsTab.TextColor3 = GRAY
    LogsTab.TextColor3 = GRAY

    Page.Visible = true

    if Page == FarmPage then
        FarmTab.BackgroundColor3 = HOVER
        FarmTab.TextColor3 = WHITE

    elseif Page == SettingsPage then
        SettingsTab.BackgroundColor3 = HOVER
        SettingsTab.TextColor3 = WHITE

    elseif Page == LogsPage then
        LogsTab.BackgroundColor3 = HOVER
        LogsTab.TextColor3 = WHITE
    end
end

FarmTab.MouseButton1Click:Connect(function()
    SetPage(FarmPage)
end)

SettingsTab.MouseButton1Click:Connect(function()
    SetPage(SettingsPage)
end)

LogsTab.MouseButton1Click:Connect(function()
    SetPage(LogsPage)
end)

SetPage(FarmPage)

--==================================================
-- FARM PAGE
--==================================================

local FarmTitle = Create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    Text = "Pack Farm",
    TextColor3 = WHITE,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5
}, FarmPage)

--==================================================
-- START BUTTON
--==================================================

local StartButton = Create("TextButton", {
    Size = UDim2.new(1, 0, 0, 45),
    Position = UDim2.new(0, 0, 0, 40),
    BackgroundColor3 = GREEN,
    BorderSizePixel = 0,
    Text = "START FARM",
    TextColor3 = Color3.fromRGB(10, 10, 10),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    ZIndex = 5
}, FarmPage)

AddCorner(StartButton, 8)

--==================================================
-- TOGGLE HELPER
--==================================================

local ToggleStates = {}

local function CreateToggle(Text, Y)
    local Button = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 38),
        Position = UDim2.new(0, 0, 0, Y),
        BackgroundColor3 = BUTTON,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 5
    }, FarmPage)

    AddCorner(Button, 7)

    local Label = Create("TextLabel", {
        Size = UDim2.new(1, -65, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = Text,
        TextColor3 = WHITE,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6
    }, Button)

    local Indicator = Create("TextLabel", {
        Size = UDim2.new(0, 45, 0, 25),
        Position = UDim2.new(1, -55, 0.5, -12),
        BackgroundColor3 = Color3.fromRGB(55, 55, 65),
        BorderSizePixel = 0,
        Text = "OFF",
        TextColor3 = GRAY,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        ZIndex = 6
    }, Button)

    AddCorner(Indicator, 6)

    ToggleStates[Text] = false

    Button.MouseButton1Click:Connect(function()
        ToggleStates[Text] = not ToggleStates[Text]

        if ToggleStates[Text] then
            Indicator.Text = "ON"
            Indicator.TextColor3 = GREEN
            Indicator.BackgroundColor3 = Color3.fromRGB(35, 75, 45)
        else
            Indicator.Text = "OFF"
            Indicator.TextColor3 = GRAY
            Indicator.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
        end
    end)

    return Button
end

CreateToggle("Titan Slayer Pack", 98)
CreateToggle("Chain Devil Pack", 142)
CreateToggle("Soccer Pack", 186)
CreateToggle("Event 2 Pack", 230)

--==================================================
-- SELECTED PACK CHECK
--==================================================

local function IsPackSelected(PackName)
    return ToggleStates[PackName] == true
end

--==================================================
-- LOG PAGE
--==================================================

local LogTitle = Create("TextLabel", {
    Size = UDim2.new(1, -100, 0, 30),
    BackgroundTransparency = 1,
    Text = "Logs",
    TextColor3 = WHITE,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5
}, LogsPage)

local ClearLogsButton = Create("TextButton", {
    Size = UDim2.new(0, 85, 0, 30),
    Position = UDim2.new(1, -85, 0, 0),
    BackgroundColor3 = BUTTON,
    BorderSizePixel = 0,
    Text = "Clear",
    TextColor3 = WHITE,
    TextSize = 12,
    Font = Enum.Font.GothamMedium,
    AutoButtonColor = false,
    ZIndex = 5
}, LogsPage)

AddCorner(ClearLogsButton, 6)

local LogFrame = Create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, -42),
    Position = UDim2.new(0, 0, 0, 42),
    BackgroundColor3 = BG,
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90),
    ZIndex = 5
}, LogsPage)

AddCorner(LogFrame, 7)
AddPadding(LogFrame, 8, 8, 8, 8)

local LogLayout = Create("UIListLayout", {
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder
}, LogFrame)

local LogCount = 0

local function ClearLogs()
    for _, Child in ipairs(LogFrame:GetChildren()) do
        if Child:IsA("TextLabel") then
            Child:Destroy()
        end
    end

    LogCount = 0
end

local function AddLog(Text)
    LogCount += 1

    local Label = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        Text = "[" .. os.date("%H:%M:%S") .. "] " .. tostring(Text),
        TextColor3 = WHITE,
        TextSize = 12,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = false,
        LayoutOrder = LogCount,
        ZIndex = 6
    }, LogFrame)

    if string.find(Text, "ERROR") then
        Label.TextColor3 = RED

    elseif string.find(Text, "Buying") then
        Label.TextColor3 = YELLOW

    elseif string.find(Text, "ROLLED") then
        Label.TextColor3 = GREEN

    elseif string.find(Text, "Skip") then
        Label.TextColor3 = GRAY
    end

    -- Auto clear sau 8 log
    if LogCount >= 8 then
        task.delay(0.05, function()
            if LogCount >= 8 then
                ClearLogs()
            end
        end)
    end

    task.defer(function()
        LogFrame.CanvasPosition = Vector2.new(
            0,
            math.max(
                0,
                LogFrame.AbsoluteCanvasSize.Y
            )
        )
    end)
end

ClearLogsButton.MouseButton1Click:Connect(ClearLogs)

--==================================================
-- SETTINGS PAGE
--==================================================

local SettingsTitle = Create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    Text = "Settings",
    TextColor3 = WHITE,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5
}, SettingsPage)

--==================================================
-- DELAY
--==================================================

local DelayLabel = Create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 35),
    Position = UDim2.new(0, 0, 0, 45),
    BackgroundTransparency = 1,
    Text = "Delay: 1.5s",
    TextColor3 = WHITE,
    TextSize = 14,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5
}, SettingsPage)

local MinusButton = Create("TextButton", {
    Size = UDim2.new(0, 40, 0, 35),
    Position = UDim2.new(1, -90, 0, 45),
    BackgroundColor3 = BUTTON,
    BorderSizePixel = 0,
    Text = "-",
    TextColor3 = WHITE,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    ZIndex = 5
}, SettingsPage)

AddCorner(MinusButton, 6)

local PlusButton = Create("TextButton", {
    Size = UDim2.new(0, 40, 0, 35),
    Position = UDim2.new(1, -45, 0, 45),
    BackgroundColor3 = BUTTON,
    BorderSizePixel = 0,
    Text = "+",
    TextColor3 = WHITE,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    ZIndex = 5
}, SettingsPage)

AddCorner(PlusButton, 6)

MinusButton.MouseButton1Click:Connect(function()
    Delay = math.max(0.1, Delay - 0.1)
    Delay = math.floor(Delay * 10 + 0.5) / 10

    DelayLabel.Text = "Delay: " .. tostring(Delay) .. "s"
end)

PlusButton.MouseButton1Click:Connect(function()
    Delay += 0.1
    Delay = math.floor(Delay * 10 + 0.5) / 10

    DelayLabel.Text = "Delay: " .. tostring(Delay) .. "s"
end)

--==================================================
-- ANTI AFK
--==================================================

local AntiAFKButton = Create("TextButton", {
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 100),
    BackgroundColor3 = BUTTON,
    BorderSizePixel = 0,
    Text = "Anti-AFK: ON",
    TextColor3 = GREEN,
    TextSize = 13,
    Font = Enum.Font.GothamMedium,
    AutoButtonColor = false,
    ZIndex = 5
}, SettingsPage)

AddCorner(AntiAFKButton, 7)

AntiAFKButton.MouseButton1Click:Connect(function()
    AntiAFK = not AntiAFK

    if AntiAFK then
        AntiAFKButton.Text = "Anti-AFK: ON"
        AntiAFKButton.TextColor3 = GREEN
    else
        AntiAFKButton.Text = "Anti-AFK: OFF"
        AntiAFKButton.TextColor3 = GRAY
    end
end)

--==================================================
-- HIDE / SHOW
--==================================================

local Hidden = false

local ShowButton = Create("TextButton", {
    Name = "ShowButton",
    Size = UDim2.new(0, 45, 0, 35),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    Text = "☰",
    TextColor3 = WHITE,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    Visible = false,
    AutoButtonColor = false,
    ZIndex = 999
}, ScreenGui)

AddCorner(ShowButton, 8)
AddStroke(ShowButton, Color3.fromRGB(55, 55, 65), 1)

HideButton.MouseButton1Click:Connect(function()
    Hidden = true
    Main.Visible = false
    ShowButton.Visible = true
end)

ShowButton.MouseButton1Click:Connect(function()
    Hidden = false
    Main.Visible = true
    ShowButton.Visible = false
end)

--==================================================
-- BUY / ROLL
--==================================================

local function BuyAndRoll()

    local OfferCount = Event2Pack and 2 or 1

    local Success, Result = pcall(function()
        return RequestConveyorOffer:InvokeServer(OfferCount)
    end)

    if not Success then
        AddLog("ERROR: Request")
        return
    end

    if typeof(Result) ~= "table" then
        AddLog("ERROR: Invalid")
        return
    end

    local SkippedPacks = {}

    for _, Offer in pairs(Result) do

        if typeof(Offer) ~= "table" then
            continue
        end

        local OfferId = Offer.OfferId
        local PackName = Offer.PackName
        local Mutation = Offer.Mutation

        -- Fallback nếu game dùng field khác
        if not PackName then
            PackName =
                Offer.Name
                or Offer.Pack
                or Offer.DisplayName
        end

        if not PackName then
            table.insert(
                SkippedPacks,
                "Unknown Pack"
            )

            continue
        end

        PackName = tostring(PackName)

        -- Chỉ mua pack được bật
        if AllowedPacks[PackName]
            and IsPackSelected(PackName) then

            AddLog(
                "Buying: "
                .. PackName
            )

            local BuySuccess = pcall(function()

                BuyPack:FireServer(
                    PackName,
                    Mutation,
                    OfferId
                )

            end)

            if not BuySuccess then
                AddLog("ERROR: Buy")
                continue
            end

            task.wait(0.5)

            local RollSuccess = pcall(function()

                SetRecoverPack:FireServer(
                    OfferId
                )

            end)

            if RollSuccess then

                AddLog(
                    "ROLLED: "
                    .. PackName
                )

            else
                AddLog("ERROR: Roll")
            end

            task.wait(0.2)

        else

            table.insert(
                SkippedPacks,
                PackName
            )

        end
    end

    if #SkippedPacks > 0 then
        AddLog(
            "Skip: "
            .. table.concat(
                SkippedPacks,
                ", "
            )
        )
    end
end

--==================================================
-- FARM LOOP
--==================================================

local FarmThread = nil

local function StartFarm()

    if Running then
        return
    end

    Running = true

    StartButton.Text = "STOP FARM"
    StartButton.BackgroundColor3 = RED

    AddLog("Farm Started")

    FarmThread = task.spawn(function()

        while Running do

            local HasSelectedPack =
                IsPackSelected("Titan Slayer Pack")
                or IsPackSelected("Chain Devil Pack")
                or IsPackSelected("Soccer Pack")

            Event2Pack =
                ToggleStates["Event 2 Pack"] == true

            if not HasSelectedPack then

                AddLog("ERROR: No Pack Selected")

                task.wait(1)

            else

                BuyAndRoll()

                task.wait(Delay)

            end
        end

    end)
end

local function StopFarm()

    Running = false

    StartButton.Text = "START FARM"
    StartButton.BackgroundColor3 = GREEN

    AddLog("Farm Stopped")
end

StartButton.MouseButton1Click:Connect(function()

    if Running then
        StopFarm()
    else
        StartFarm()
    end

end)

--==================================================
-- ANTI AFK
--==================================================

Player.Idled:Connect(function()

    if not AntiAFK then
        return
    end

    pcall(function()

        VirtualUser:CaptureController()

        VirtualUser:ClickButton2(
            Vector2.new(
                math.random(0, 500),
                math.random(0, 500)
            )
        )

    end)

end)

--==================================================
-- DEFAULT STATE
--==================================================

ToggleStates["Titan Slayer Pack"] = true

-- cập nhật indicator của Titan
do
    local Button = FarmPage:FindFirstChild(
        "Titan Slayer Pack",
        true
    )

    if Button then
        local Indicator = Button:FindFirstChildWhichIsA(
            "TextLabel"
        )

        if Indicator then
            Indicator.Text = "ON"
            Indicator.TextColor3 = GREEN
            Indicator.BackgroundColor3 =
                Color3.fromRGB(35, 75, 45)
        end
    end
end

AddLog("Hub Loaded")
AddLog("Drag the top bar to move GUI")

--==================================================
-- FINISHED
--==================================================
