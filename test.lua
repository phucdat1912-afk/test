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

local Delay = 1.5
local Running = false

local ToggleStates = {
    ["Titan Slayer Pack"] = true,
    ["Chain Devil Pack"] = false,
    ["Soccer Pack"] = false,
    ["Eternity Pack"] = false,
    ["Event 2 Pack"] = false,
    ["Anti-AFK"] = true
}

local AllowedPacks = {
    ["Titan Slayer Pack"] = true,
    ["Chain Devil Pack"] = true,
    ["Soccer Pack"] = true,
    ["Eternity Pack"] = true
}

--==================================================
-- COLORS
--==================================================

local BG = Color3.fromRGB(18, 18, 22)
local PANEL = Color3.fromRGB(25, 25, 30)
local PANEL2 = Color3.fromRGB(31, 31, 38)
local BUTTON = Color3.fromRGB(38, 38, 46)
local HOVER = Color3.fromRGB(48, 48, 58)

local WHITE = Color3.fromRGB(235, 235, 240)
local GRAY = Color3.fromRGB(150, 150, 160)
local GREEN = Color3.fromRGB(70, 200, 110)
local RED = Color3.fromRGB(220, 70, 70)
local YELLOW = Color3.fromRGB(235, 190, 70)

--==================================================
-- GUI
--==================================================

pcall(function()
    CoreGui:FindFirstChild("1tap_PackFarm"):Destroy()
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "1tap_PackFarm"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local function Create(Class, Properties, Parent)
    local Object = Instance.new(Class)

    for Property, Value in pairs(Properties) do
        Object[Property] = Value
    end

    Object.Parent = Parent
    return Object
end

--==================================================
-- MAIN
--==================================================

local Main = Create("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 600, 0, 400),
    Position = UDim2.new(0.5, -300, 0.5, -200),
    BackgroundColor3 = BG,
    BorderSizePixel = 0,
    Active = true,
    ZIndex = 10
}, ScreenGui)

Create("UICorner", {
    CornerRadius = UDim.new(0, 10)
}, Main)

--==================================================
-- TOP BAR
--==================================================

local TopBar = Create("Frame", {
    Name = "TopBar",
    Size = UDim2.new(1, 0, 0, 45),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    ZIndex = 20
}, Main)

Create("UICorner", {
    CornerRadius = UDim.new(0, 10)
}, TopBar)

local Title = Create("TextLabel", {
    Size = UDim2.new(0, 250, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    Text = "1tap Pack Farm",
    TextColor3 = WHITE,
    TextSize = 17,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 101
}, TopBar)

--==================================================
-- DRAG BAR
--==================================================

local DragBar = Create("TextButton", {
    Name = "DragBar",
    Size = UDim2.new(1, -65, 0, 45),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "",
    AutoButtonColor = false,
    Active = true,
    ZIndex = 100
}, Main)

--==================================================
-- HIDE BUTTON
--==================================================

local HideButton = Create("TextButton", {
    Name = "HideButton",
    Size = UDim2.new(0, 45, 0, 35),
    Position = UDim2.new(1, -50, 0, 5),
    BackgroundColor3 = BUTTON,
    BorderSizePixel = 0,
    Text = "—",
    TextColor3 = WHITE,
    TextSize = 20,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    ZIndex = 150
}, Main)

Create("UICorner", {
    CornerRadius = UDim.new(0, 7)
}, HideButton)

--==================================================
-- MAIN DRAG
--==================================================

local MainDragging = false
local MainDragStart
local MainStartPosition

DragBar.MouseButton1Down:Connect(function()
    MainDragging = true
    MainDragStart = UserInputService:GetMouseLocation()
    MainStartPosition = Main.Position
end)

UserInputService.InputChanged:Connect(function(Input)
    if not MainDragging then
        return
    end

    if Input.UserInputType ~= Enum.UserInputType.MouseMovement then
        return
    end

    local MousePosition = UserInputService:GetMouseLocation()
    local Delta = MousePosition - MainDragStart

    Main.Position = UDim2.new(
        MainStartPosition.X.Scale,
        MainStartPosition.X.Offset + Delta.X,
        MainStartPosition.Y.Scale,
        MainStartPosition.Y.Offset + Delta.Y
    )
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        MainDragging = false
    end
end)

--==================================================
-- SIDEBAR
--==================================================

local Sidebar = Create("Frame", {
    Name = "Sidebar",
    Size = UDim2.new(0, 145, 1, -55),
    Position = UDim2.new(0, 10, 0, 50),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    ZIndex = 20
}, Main)

Create("UICorner", {
    CornerRadius = UDim.new(0, 8)
}, Sidebar)

local function CreateSideButton(Text, Y)
    local Button = Create("TextButton", {
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, Y),
        BackgroundColor3 = BUTTON,
        BorderSizePixel = 0,
        Text = Text,
        TextColor3 = WHITE,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = false,
        ZIndex = 30
    }, Sidebar)

    Create("UICorner", {
        CornerRadius = UDim.new(0, 7)
    }, Button)

    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = HOVER
    end)

    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = BUTTON
    end)

    return Button
end

local FarmTab = CreateSideButton("Farm", 15)
local SettingsTab = CreateSideButton("Settings", 65)
local LogsTab = CreateSideButton("Logs", 115)

--==================================================
-- CONTENT
--==================================================

local Content = Create("Frame", {
    Name = "Content",
    Size = UDim2.new(1, -165, 1, -55),
    Position = UDim2.new(0, 155, 0, 50),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 20
}, Main)

--==================================================
-- PAGES
--==================================================

local FarmPage = Create("Frame", {
    Name = "FarmPage",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    Visible = true,
    ZIndex = 20
}, Content)

local SettingsPage = Create("Frame", {
    Name = "SettingsPage",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 20
}, Content)

local LogsPage = Create("Frame", {
    Name = "LogsPage",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 20
}, Content)

for _, Page in ipairs({
    FarmPage,
    SettingsPage,
    LogsPage
}) do
    Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, Page)
end

--==================================================
-- TAB SYSTEM
--==================================================

local function ShowPage(Page)
    FarmPage.Visible = false
    SettingsPage.Visible = false
    LogsPage.Visible = false

    Page.Visible = true
end

FarmTab.MouseButton1Click:Connect(function()
    ShowPage(FarmPage)
end)

SettingsTab.MouseButton1Click:Connect(function()
    ShowPage(SettingsPage)
end)

LogsTab.MouseButton1Click:Connect(function()
    ShowPage(LogsPage)
end)

--==================================================
-- LOG SYSTEM
--==================================================

local Logs = {}

local LogScroll = Create("ScrollingFrame", {
    Size = UDim2.new(1, -20, 1, -65),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = PANEL2,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ZIndex = 25
}, LogsPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 7)
}, LogScroll)

local LogLayout = Create("UIListLayout", {
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder
}, LogScroll)

Create("UIPadding", {
    PaddingTop = UDim.new(0, 7),
    PaddingBottom = UDim.new(0, 7),
    PaddingLeft = UDim.new(0, 7),
    PaddingRight = UDim.new(0, 7)
}, LogScroll)

local ClearLogsButton = Create("TextButton", {
    Size = UDim2.new(0, 110, 0, 35),
    Position = UDim2.new(1, -120, 1, -45),
    BackgroundColor3 = BUTTON,
    BorderSizePixel = 0,
    Text = "Clear Logs",
    TextColor3 = WHITE,
    TextSize = 13,
    Font = Enum.Font.GothamMedium,
    AutoButtonColor = false,
    ZIndex = 30
}, LogsPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 7)
}, ClearLogsButton)

local function ClearLogs()
    Logs = {}

    for _, Child in ipairs(LogScroll:GetChildren()) do
        if Child:IsA("TextLabel") then
            Child:Destroy()
        end
    end
end

local function GetLogColor(Text)
    if string.find(Text, "Buying:") then
        return YELLOW
    elseif string.find(Text, "ROLLED:") then
        return GREEN
    elseif string.find(Text, "ERROR:") then
        return RED
    elseif string.find(Text, "Skip:") then
        return GRAY
    elseif string.find(Text, "Farm Started") then
        return GREEN
    elseif string.find(Text, "Farm Stopped") then
        return RED
    end

    return WHITE
end

local function AddLog(Text)
    table.insert(Logs, Text)

    while #Logs > 8 do
        table.remove(Logs, 1)
    end

    for _, Child in ipairs(LogScroll:GetChildren()) do
        if Child:IsA("TextLabel") then
            Child:Destroy()
        end
    end

    for Index, LogText in ipairs(Logs) do
        Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 25),
            BackgroundTransparency = 1,
            Text = "[" .. Index .. "] " .. LogText,
            TextColor3 = GetLogColor(LogText),
            TextSize = 13,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = Index,
            ZIndex = 30
        }, LogScroll)
    end

    task.defer(function()
        LogScroll.CanvasPosition = Vector2.new(
            0,
            math.max(
                0,
                LogScroll.AbsoluteCanvasSize.Y -
                LogScroll.AbsoluteWindowSize.Y
            )
        )
    end)
end

ClearLogsButton.MouseButton1Click:Connect(ClearLogs)

--==================================================
-- TOGGLE CREATOR
--==================================================

local function CreateToggle(Parent, Text, Y, Key)
    local Button = Create("TextButton", {
        Size = UDim2.new(1, -20, 0, 38),
        Position = UDim2.new(0, 10, 0, Y),
        BackgroundColor3 = BUTTON,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 30
    }, Parent)

    Create("UICorner", {
        CornerRadius = UDim.new(0, 7)
    }, Button)

    local Label = Create("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = Text,
        TextColor3 = WHITE,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 31
    }, Button)

    local Indicator = Create("TextLabel", {
        Size = UDim2.new(0, 45, 1, 0),
        Position = UDim2.new(1, -50, 0, 0),
        BackgroundTransparency = 1,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        ZIndex = 31
    }, Button)

    local function Update()
        if ToggleStates[Key] then
            Indicator.Text = "ON"
            Indicator.TextColor3 = GREEN
        else
            Indicator.Text = "OFF"
            Indicator.TextColor3 = RED
        end
    end

    Update()

    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = HOVER
    end)

    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = BUTTON
    end)

    Button.MouseButton1Click:Connect(function()
        ToggleStates[Key] = not ToggleStates[Key]
        Update()
    end)

    return Button
end

--==================================================
-- FARM PAGE
--==================================================

local StartButton = Create("TextButton", {
    Size = UDim2.new(1, -20, 0, 42),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = GREEN,
    BorderSizePixel = 0,
    Text = "START FARM",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    ZIndex = 30
}, FarmPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 7)
}, StartButton)

CreateToggle(
    FarmPage,
    "Titan Slayer Pack",
    62,
    "Titan Slayer Pack"
)

CreateToggle(
    FarmPage,
    "Chain Devil Pack",
    106,
    "Chain Devil Pack"
)

CreateToggle(
    FarmPage,
    "Soccer Pack",
    150,
    "Soccer Pack"
)

-- ETERNITY PACK
CreateToggle(
    FarmPage,
    "Eternity Pack",
    194,
    "Eternity Pack"
)

CreateToggle(
    FarmPage,
    "Event 2 Pack",
    238,
    "Event 2 Pack"
)

--==================================================
-- SETTINGS PAGE
--==================================================

local DelayTitle = Create("TextLabel", {
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 15),
    BackgroundTransparency = 1,
    Text = "Farm Delay",
    TextColor3 = WHITE,
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 30
}, SettingsPage)

local DelayValue = Create("TextLabel", {
    Size = UDim2.new(0, 100, 0, 35),
    Position = UDim2.new(0, 10, 0, 55),
    BackgroundColor3 = PANEL2,
    BorderSizePixel = 0,
    Text = string.format("%.1f", Delay) .. "s",
    TextColor3 = WHITE,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    ZIndex = 30
}, SettingsPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 7)
}, DelayValue)

local MinusButton = Create("TextButton", {
    Size = UDim2.new(0, 40, 0, 35),
    Position = UDim2.new(0, 120, 0, 55),
    BackgroundColor3 = BUTTON,
    BorderSizePixel = 0,
    Text = "-",
    TextColor3 = WHITE,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    ZIndex = 30
}, SettingsPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 7)
}, MinusButton)

local PlusButton = Create("TextButton", {
    Size = UDim2.new(0, 40, 0, 35),
    Position = UDim2.new(0, 165, 0, 55),
    BackgroundColor3 = BUTTON,
    BorderSizePixel = 0,
    Text = "+",
    TextColor3 = WHITE,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    ZIndex = 30
}, SettingsPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 7)
}, PlusButton)

local function UpdateDelay()
    Delay = math.clamp(
        math.round(Delay * 10) / 10,
        0.1,
        10
    )

    DelayValue.Text = string.format("%.1f", Delay) .. "s"
end

MinusButton.MouseButton1Click:Connect(function()
    Delay -= 0.1
    UpdateDelay()
end)

PlusButton.MouseButton1Click:Connect(function()
    Delay += 0.1
    UpdateDelay()
end)

CreateToggle(
    SettingsPage,
    "Anti-AFK",
    110,
    "Anti-AFK"
)

--==================================================
-- ANTI AFK
--==================================================

Player.Idled:Connect(function()
    if ToggleStates["Anti-AFK"] then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

--==================================================
-- PACK CHECK
--==================================================

local function IsPackSelected(PackName)
    return ToggleStates[PackName] == true
end

--==================================================
-- BUY + ROLL
--==================================================

local function BuyAndRoll()
    local OfferCount

    if ToggleStates["Event 2 Pack"] then
        OfferCount = 2
    else
        OfferCount = 1
    end

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

        if AllowedPacks[PackName]
            and IsPackSelected(PackName) then

            AddLog(
                "Buying: " ..
                PackName
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
                    "ROLLED: " ..
                    PackName
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
            "Skip: " ..
            table.concat(
                SkippedPacks,
                ", "
            )
        )
    end
end

--==================================================
-- FARM
--==================================================

local function HasSelectedPack()
    return
        IsPackSelected("Titan Slayer Pack")
        or IsPackSelected("Chain Devil Pack")
        or IsPackSelected("Soccer Pack")
        or IsPackSelected("Eternity Pack")
end

local function StartFarm()
    if Running then
        return
    end

    Running = true

    StartButton.Text = "STOP FARM"
    StartButton.BackgroundColor3 = RED

    AddLog("Farm Started")

    task.spawn(function()
        while Running do

            if not HasSelectedPack() then
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
    if not Running then
        return
    end

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
-- SHOW / HIDE BUTTON
--==================================================

local ShowButton = Create("TextButton", {
    Name = "ShowButton",

    -- KÍCH THƯỚC ICON
    Size = UDim2.new(0, 48, 0, 48),

    -- GIỮA MÉP TRÁI MÀN HÌNH
    Position = UDim2.new(
        0,
        10,
        0.5,
        -24
    ),

    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,

    Text = "☰",
    TextColor3 = WHITE,
    TextSize = 20,
    Font = Enum.Font.GothamBold,

    Visible = false,
    AutoButtonColor = false,
    Active = true,
    ZIndex = 999
}, ScreenGui)

Create("UICorner", {
    CornerRadius = UDim.new(0, 10)
}, ShowButton)

--==================================================
-- SHOW BUTTON DRAG
--==================================================

local ShowDragging = false
local ShowDragStart
local ShowStartPosition

ShowButton.MouseButton1Down:Connect(function()
    ShowDragging = true

    ShowDragStart =
        UserInputService:GetMouseLocation()

    ShowStartPosition =
        ShowButton.Position
end)

UserInputService.InputChanged:Connect(function(Input)
    if not ShowDragging then
        return
    end

    if Input.UserInputType ~= Enum.UserInputType.MouseMovement then
        return
    end

    local MousePosition =
        UserInputService:GetMouseLocation()

    local Delta =
        MousePosition - ShowDragStart

    ShowButton.Position = UDim2.new(
        ShowStartPosition.X.Scale,
        ShowStartPosition.X.Offset + Delta.X,

        ShowStartPosition.Y.Scale,
        ShowStartPosition.Y.Offset + Delta.Y
    )
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        ShowDragging = false
    end
end)

--==================================================
-- HIDE / SHOW
--==================================================

HideButton.MouseButton1Click:Connect(function()
    Main.Visible = false
    ShowButton.Visible = true
end)

ShowButton.MouseButton1Click:Connect(function()
    Main.Visible = true
    ShowButton.Visible = false
end)

--==================================================
-- START
--==================================================

Main.Visible = true
ShowButton.Visible = false

AddLog("Ready")
