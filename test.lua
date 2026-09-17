--==================================================
-- 1TAP PACK FARM
-- FULL VERSION WITH SEARCH BOX
--==================================================

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

local Delay = 0.5
local Running = false

local ToggleStates = {
    ["Event 2 Pack"] = false,
    ["Anti-AFK"] = true
}

local AllowedPacks = {}
local PackButtons = {}
local Logs = {}

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
-- REMOVE OLD GUI
--==================================================

pcall(function()

    local Old = CoreGui:FindFirstChild("1tap_PackFarm")

    if Old then
        Old:Destroy()
    end

end)

--==================================================
-- CREATE FUNCTION
--==================================================

local function Create(ClassName, Properties, Parent)

    local Object = Instance.new(ClassName)

    for Property, Value in pairs(Properties) do
        Object[Property] = Value
    end

    Object.Parent = Parent

    return Object
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

    Position = UDim2.new(0, 0, 0, 0),

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

    ZIndex = 30
}, TopBar)

--==================================================
-- MAIN DRAG
--==================================================

local DragBar = Create("TextButton", {
    Name = "DragBar",

    Size = UDim2.new(1, -55, 0, 45),

    Position = UDim2.new(0, 0, 0, 0),

    BackgroundTransparency = 1,

    Text = "",

    AutoButtonColor = false,

    Active = true,

    ZIndex = 100
}, Main)

local MainDragging = false
local MainDragStart
local MainStartPosition

DragBar.MouseButton1Down:Connect(function()

    MainDragging = true

    MainDragStart =
        UserInputService:GetMouseLocation()

    MainStartPosition =
        Main.Position

end)

UserInputService.InputChanged:Connect(function(Input)

    if not MainDragging then
        return
    end

    if Input.UserInputType ~= Enum.UserInputType.MouseMovement then
        return
    end

    local MousePosition =
        UserInputService:GetMouseLocation()

    local Delta =
        MousePosition - MainDragStart

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
-- HIDE BUTTON
--==================================================

local HideButton = Create("TextButton", {
    Name = "HideButton",

    Size = UDim2.new(0, 40, 0, 35),

    Position = UDim2.new(1, -45, 0, 5),

    BackgroundColor3 = BUTTON,

    BorderSizePixel = 0,

    Text = "—",

    TextColor3 = WHITE,

    TextSize = 20,

    Font = Enum.Font.GothamBold,

    AutoButtonColor = false,

    ZIndex = 200
}, Main)

Create("UICorner", {
    CornerRadius = UDim.new(0, 7)
}, HideButton)

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

local FarmTab =
    CreateSideButton("Farm", 15)

local EventsTab =
    CreateSideButton("Events", 65)

local SettingsTab =
    CreateSideButton("Settings", 115)

local LogsTab =
    CreateSideButton("Logs", 165)

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

local EventsPage = Create("Frame", {
    Name = "EventsPage",

    Size = UDim2.new(1, 0, 1, 0),

    BackgroundColor3 = PANEL,

    BorderSizePixel = 0,

    Visible = false,

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
    EventsPage,
    SettingsPage,
    LogsPage
}) do

    Create("UICorner", {
        CornerRadius = UDim.new(0, 8)
    }, Page)

end

--==================================================
-- PAGE SWITCH
--==================================================

local function ShowPage(Page)

    FarmPage.Visible = false
    EventsPage.Visible = false
    SettingsPage.Visible = false
    LogsPage.Visible = false

    Page.Visible = true

end

FarmTab.MouseButton1Click:Connect(function()
    ShowPage(FarmPage)
end)

EventsTab.MouseButton1Click:Connect(function()
    ShowPage(EventsPage)
end)

SettingsTab.MouseButton1Click:Connect(function()
    ShowPage(SettingsPage)
end)

LogsTab.MouseButton1Click:Connect(function()
    ShowPage(LogsPage)
end)

--==================================================
-- LOG PAGE
--==================================================

local LogScroll = Create("ScrollingFrame", {
    Name = "LogScroll",

    Size = UDim2.new(1, -20, 1, -65),

    Position = UDim2.new(0, 10, 0, 10),

    BackgroundColor3 = PANEL2,

    BorderSizePixel = 0,

    ScrollBarThickness = 4,

    CanvasSize = UDim2.new(0, 0, 0, 0),

    AutomaticCanvasSize = Enum.AutomaticSize.Y,

    ZIndex = 30
}, LogsPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 7)
}, LogScroll)

Create("UIListLayout", {
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder
}, LogScroll)

Create("UIPadding", {
    PaddingTop = UDim.new(0, 7),
    PaddingBottom = UDim.new(0, 7),
    PaddingLeft = UDim.new(0, 7),
    PaddingRight = UDim.new(0, 7)
}, LogScroll)

local function GetLogColor(Text)

    if string.find(Text, "ERROR") then
        return RED
    end

    if string.find(Text, "Buying") then
        return YELLOW
    end

    if string.find(Text, "ROLLED") then
        return GREEN
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

            Text = "[" ..
                tostring(Index) ..
                "] " ..
                tostring(LogText),

            TextColor3 = GetLogColor(LogText),

            TextSize = 12,

            Font = Enum.Font.GothamMedium,

            TextXAlignment = Enum.TextXAlignment.Left,

            LayoutOrder = Index,

            ZIndex = 35
        }, LogScroll)

    end

end

local ClearLogsButton = Create("TextButton", {
    Size = UDim2.new(0, 110, 0, 35),

    Position = UDim2.new(1, -120, 1, -45),

    BackgroundColor3 = BUTTON,

    BorderSizePixel = 0,

    Text = "Clear Logs",

    TextColor3 = WHITE,

    TextSize = 12,

    Font = Enum.Font.GothamMedium,

    AutoButtonColor = false,

    ZIndex = 40
}, LogsPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 7)
}, ClearLogsButton)

ClearLogsButton.MouseButton1Click:Connect(function()

    Logs = {}

    for _, Child in ipairs(LogScroll:GetChildren()) do

        if Child:IsA("TextLabel") then
            Child:Destroy()
        end

    end

end)

--==================================================
-- FARM PAGE
--==================================================

-- START FARM

local StartButton = Create("TextButton", {
    Name = "StartButton",

    Size = UDim2.new(1, -20, 0, 42),

    Position = UDim2.new(0, 10, 0, 10),

    BackgroundColor3 = GREEN,

    BorderSizePixel = 0,

    Text = "START FARM",

    TextColor3 = WHITE,

    TextSize = 14,

    Font = Enum.Font.GothamBold,

    AutoButtonColor = false,

    ZIndex = 300
}, FarmPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 7)
}, StartButton)

--==================================================
-- SEARCH AREA
--==================================================

local SearchFrame = Create("Frame", {
    Name = "SearchFrame",

    Size = UDim2.new(1, -20, 0, 36),

    Position = UDim2.new(0, 10, 0, 60),

    BackgroundColor3 = Color3.fromRGB(40, 40, 48),

    BorderSizePixel = 1,

    BorderColor3 = Color3.fromRGB(70, 70, 80),

    Visible = true,

    Active = true,

    ZIndex = 500
}, FarmPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 8)
}, SearchFrame)

-- Search icon

local SearchIcon = Create("TextLabel", {
    Name = "SearchIcon",

    Size = UDim2.new(0, 32, 1, 0),

    Position = UDim2.new(0, 4, 0, 0),

    BackgroundTransparency = 1,

    Text = "🔍",

    TextColor3 = WHITE,

    TextSize = 14,

    Font = Enum.Font.GothamBold,

    TextXAlignment = Enum.TextXAlignment.Center,

    TextYAlignment = Enum.TextYAlignment.Center,

    ZIndex = 501
}, SearchFrame)

-- Search textbox

local SearchBox = Create("TextBox", {
    Name = "SearchBox",

    Size = UDim2.new(1, -42, 1, 0),

    Position = UDim2.new(0, 38, 0, 0),

    BackgroundTransparency = 1,

    BorderSizePixel = 0,

    Text = "",

    PlaceholderText = "Search pack...",

    PlaceholderColor3 = Color3.fromRGB(155, 155, 165),

    TextColor3 = WHITE,

    TextSize = 13,

    Font = Enum.Font.GothamMedium,

    ClearTextOnFocus = false,

    TextEditable = true,

    TextXAlignment = Enum.TextXAlignment.Left,

    TextYAlignment = Enum.TextYAlignment.Center,

    ZIndex = 502
}, SearchFrame)

--==================================================
-- SCAN
--==================================================

local ScanButton = Create("TextButton", {
    Name = "ScanButton",

    Size = UDim2.new(0, 115, 0, 32),

    Position = UDim2.new(0, 10, 0, 105),

    BackgroundColor3 = BUTTON,

    BorderSizePixel = 0,

    Text = "SCAN PACKS",

    TextColor3 = WHITE,

    TextSize = 12,

    Font = Enum.Font.GothamBold,

    AutoButtonColor = false,

    ZIndex = 400
}, FarmPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 7)
}, ScanButton)

ScanButton.MouseEnter:Connect(function()
    ScanButton.BackgroundColor3 = HOVER
end)

ScanButton.MouseLeave:Connect(function()
    ScanButton.BackgroundColor3 = BUTTON
end)

local PackCountLabel = Create("TextLabel", {
    Name = "PackCountLabel",

    Size = UDim2.new(1, -135, 0, 32),

    Position = UDim2.new(0, 130, 0, 105),

    BackgroundTransparency = 1,

    Text = "0 packs found",

    TextColor3 = GRAY,

    TextSize = 12,

    Font = Enum.Font.GothamMedium,

    TextXAlignment = Enum.TextXAlignment.Left,

    ZIndex = 400
}, FarmPage)

--==================================================
-- PACK SCROLL
--==================================================

local PackScroll = Create("ScrollingFrame", {
    Name = "PackScroll",

    Size = UDim2.new(1, -20, 1, -150),

    Position = UDim2.new(0, 10, 0, 145),

    BackgroundColor3 = PANEL2,

    BorderSizePixel = 0,

    ScrollBarThickness = 5,

    CanvasSize = UDim2.new(0, 0, 0, 0),

    AutomaticCanvasSize = Enum.AutomaticSize.Y,

    ZIndex = 100
}, FarmPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 8)
}, PackScroll)

Create("UIPadding", {
    PaddingTop = UDim.new(0, 8),
    PaddingBottom = UDim.new(0, 8),
    PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8)
}, PackScroll)

local PackGrid = Create("UIGridLayout", {
    CellSize = UDim2.new(0.31, 0, 0, 40),

    CellPadding = UDim2.new(0.025, 0, 0, 7),

    SortOrder = Enum.SortOrder.Name,

    HorizontalAlignment = Enum.HorizontalAlignment.Left,

    VerticalAlignment = Enum.VerticalAlignment.Top
}, PackScroll)

--==================================================
-- SEARCH FILTER
--==================================================

local function UpdateSearch()

    local SearchText =
        string.lower(
            tostring(SearchBox.Text or "")
        )

    for PackName, Button in pairs(PackButtons) do

        local LowerName =
            string.lower(PackName)

        if SearchText == "" then

            Button.Visible = true

        elseif string.find(
            LowerName,
            SearchText,
            1,
            true
        ) then

            Button.Visible = true

        else

            Button.Visible = false

        end

    end

end

SearchBox:GetPropertyChangedSignal(
    "Text"
):Connect(function()

    UpdateSearch()

end)

--==================================================
-- CREATE PACK BUTTON
--==================================================

local function CreatePackToggle(PackName)

    if PackButtons[PackName] then
        return
    end

    if ToggleStates[PackName] == nil then
        ToggleStates[PackName] = false
    end

    local Button = Create("TextButton", {
        Name = PackName,

        Size = UDim2.new(0, 0, 0, 40),

        BackgroundColor3 = BUTTON,

        BorderSizePixel = 0,

        Text = "",

        AutoButtonColor = false,

        ZIndex = 150
    }, PackScroll)

    Create("UICorner", {
        CornerRadius = UDim.new(0, 7)
    }, Button)

    local NameLabel = Create("TextLabel", {
        Size = UDim2.new(1, -55, 1, 0),

        Position = UDim2.new(0, 8, 0, 0),

        BackgroundTransparency = 1,

        Text = PackName,

        TextColor3 = WHITE,

        TextSize = 11,

        Font = Enum.Font.GothamMedium,

        TextXAlignment = Enum.TextXAlignment.Left,

        TextTruncate = Enum.TextTruncate.AtEnd,

        ZIndex = 151
    }, Button)

    local Status = Create("TextLabel", {
        Size = UDim2.new(0, 42, 1, 0),

        Position = UDim2.new(1, -47, 0, 0),

        BackgroundTransparency = 1,

        TextSize = 10,

        Font = Enum.Font.GothamBold,

        TextXAlignment = Enum.TextXAlignment.Center,

        ZIndex = 151
    }, Button)

    local function UpdateStatus()

        if ToggleStates[PackName] then

            Status.Text = "ON"
            Status.TextColor3 = GREEN

        else

            Status.Text = "OFF"
            Status.TextColor3 = RED

        end

    end

    UpdateStatus()

    Button.MouseEnter:Connect(function()

        Button.BackgroundColor3 = HOVER

    end)

    Button.MouseLeave:Connect(function()

        Button.BackgroundColor3 = BUTTON

    end)

    Button.MouseButton1Click:Connect(function()

        ToggleStates[PackName] =
            not ToggleStates[PackName]

        UpdateStatus()

        AddLog(
            PackName ..
            ": " ..
            (
                ToggleStates[PackName]
                and "ON"
                or "OFF"
            )
        )

    end)

    PackButtons[PackName] = Button

    UpdateSearch()

end

--==================================================
-- SCAN PACKS
--==================================================

local function ScanPacks()

    local PotentialCards =
        ReplicatedStorage:FindFirstChild(
            "PotentialCards"
        )

    if not PotentialCards then

        PackCountLabel.Text =
            "PotentialCards not found"

        AddLog(
            "ERROR: PotentialCards not found"
        )

        return
    end

    local Count = 0

    for _, Object in ipairs(
        PotentialCards:GetChildren()
    ) do

        if Object:IsA("Folder") then

            local PackName =
                Object.Name

            if PackName ~= "ScalingUnits"
                and PackName ~= "Crafted"
                and PackName ~= "Light"
                and PackName ~= "Dark"
                and PackName ~= "Festival"
                and PackName ~= "Manga" then

                AllowedPacks[PackName] = true

                if ToggleStates[PackName] == nil then

                    ToggleStates[PackName] = false

                end

                CreatePackToggle(PackName)

                Count += 1

            end

        end

    end

    PackCountLabel.Text =
        tostring(Count) ..
        " packs found"

    UpdateSearch()

    AddLog(
        "Scanned " ..
        tostring(Count) ..
        " packs"
    )

end

ScanButton.MouseButton1Click:Connect(function()

    ScanPacks()

end)

--==================================================
-- EVENTS PAGE
--==================================================

local EventsTitle = Create("TextLabel", {
    Size = UDim2.new(1, -20, 0, 35),

    Position = UDim2.new(0, 10, 0, 15),

    BackgroundTransparency = 1,

    Text = "Events",

    TextColor3 = WHITE,

    TextSize = 17,

    Font = Enum.Font.GothamBold,

    TextXAlignment = Enum.TextXAlignment.Left,

    ZIndex = 30
}, EventsPage)

local EventFrame = Create("TextButton", {
    Size = UDim2.new(1, -20, 0, 70),

    Position = UDim2.new(0, 10, 0, 60),

    BackgroundColor3 = PANEL2,

    BorderSizePixel = 0,

    Text = "",

    AutoButtonColor = false,

    ZIndex = 30
}, EventsPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 8)
}, EventFrame)

Create("TextLabel", {
    Size = UDim2.new(1, -100, 0, 30),

    Position = UDim2.new(0, 12, 0, 8),

    BackgroundTransparency = 1,

    Text = "Event 2 Pack",

    TextColor3 = WHITE,

    TextSize = 14,

    Font = Enum.Font.GothamBold,

    TextXAlignment = Enum.TextXAlignment.Left,

    ZIndex = 31
}, EventFrame)

Create("TextLabel", {
    Size = UDim2.new(1, -100, 0, 20),

    Position = UDim2.new(0, 12, 0, 38),

    BackgroundTransparency = 1,

    Text = "Request 2 offers at once",

    TextColor3 = GRAY,

    TextSize = 11,

    Font = Enum.Font.GothamMedium,

    TextXAlignment = Enum.TextXAlignment.Left,

    ZIndex = 31
}, EventFrame)

local EventStatus = Create("TextLabel", {
    Size = UDim2.new(0, 60, 0, 25),

    Position = UDim2.new(1, -70, 0, 23),

    BackgroundTransparency = 1,

    TextSize = 12,

    Font = Enum.Font.GothamBold,

    ZIndex = 31
}, EventFrame)

local function UpdateEventStatus()

    if ToggleStates["Event 2 Pack"] then

        EventStatus.Text = "ON"
        EventStatus.TextColor3 = GREEN

    else

        EventStatus.Text = "OFF"
        EventStatus.TextColor3 = RED

    end

end

UpdateEventStatus()

EventFrame.MouseEnter:Connect(function()

    EventFrame.BackgroundColor3 = HOVER

end)

EventFrame.MouseLeave:Connect(function()

    EventFrame.BackgroundColor3 = PANEL2

end)

EventFrame.MouseButton1Click:Connect(function()

    ToggleStates["Event 2 Pack"] =
        not ToggleStates["Event 2 Pack"]

    UpdateEventStatus()

end)

--==================================================
-- SETTINGS PAGE
--==================================================

Create("TextLabel", {
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
    Size = UDim2.new(0, 90, 0, 35),

    Position = UDim2.new(0, 10, 0, 55),

    BackgroundColor3 = PANEL2,

    BorderSizePixel = 0,

    Text = string.format(
        "%.1f",
        Delay
    ) .. "s",

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

    Position = UDim2.new(0, 110, 0, 55),

    BackgroundColor3 = BUTTON,

    BorderSizePixel = 0,

    Text = "-",

    TextColor3 = WHITE,

    TextSize = 18,

    Font = Enum.Font.GothamBold,

    ZIndex = 30
}, SettingsPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 7)
}, MinusButton)

local PlusButton = Create("TextButton", {
    Size = UDim2.new(0, 40, 0, 35),

    Position = UDim2.new(0, 155, 0, 55),

    BackgroundColor3 = BUTTON,

    BorderSizePixel = 0,

    Text = "+",

    TextColor3 = WHITE,

    TextSize = 18,

    Font = Enum.Font.GothamBold,

    ZIndex = 30
}, SettingsPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 7)
}, PlusButton)

local function UpdateDelay()

    Delay =
        math.clamp(
            math.round(Delay * 10) / 10,
            0.1,
            10
        )

    DelayValue.Text =
        string.format(
            "%.1f",
            Delay
        ) .. "s"

end

MinusButton.MouseButton1Click:Connect(function()

    Delay -= 0.1

    UpdateDelay()

end)

PlusButton.MouseButton1Click:Connect(function()

    Delay += 0.1

    UpdateDelay()

end)

--==================================================
-- ANTI AFK
--==================================================

local AntiAFKButton = Create("TextButton", {
    Size = UDim2.new(1, -20, 0, 40),

    Position = UDim2.new(0, 10, 0, 105),

    BackgroundColor3 = BUTTON,

    BorderSizePixel = 0,

    Text = "Anti-AFK: ON",

    TextColor3 = GREEN,

    TextSize = 13,

    Font = Enum.Font.GothamMedium,

    ZIndex = 30
}, SettingsPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 7)
}, AntiAFKButton)

AntiAFKButton.MouseButton1Click:Connect(function()

    ToggleStates["Anti-AFK"] =
        not ToggleStates["Anti-AFK"]

    if ToggleStates["Anti-AFK"] then

        AntiAFKButton.Text =
            "Anti-AFK: ON"

        AntiAFKButton.TextColor3 =
            GREEN

    else

        AntiAFKButton.Text =
            "Anti-AFK: OFF"

        AntiAFKButton.TextColor3 =
            RED

    end

end)

Player.Idled:Connect(function()

    if ToggleStates["Anti-AFK"] then

        VirtualUser:CaptureController()

        VirtualUser:ClickButton2(
            Vector2.new()
        )

    end

end)

--==================================================
-- CHECK SELECTED PACK
--==================================================

local function HasSelectedPack()

    for PackName, Enabled in pairs(
        ToggleStates
    ) do

        if Enabled
            and PackName ~= "Event 2 Pack"
            and PackName ~= "Anti-AFK"
            and AllowedPacks[PackName] then

            return true

        end

    end

    return false

end

--==================================================
-- BUY AND ROLL
--==================================================

local function BuyAndRoll()

    local OfferCount = 1

    if ToggleStates["Event 2 Pack"] then

        OfferCount = 2

    end

    local Success, Result =
        pcall(function()

            return RequestConveyorOffer:
                InvokeServer(
                    OfferCount
                )

        end)

    if not Success then

        AddLog(
            "ERROR: RequestConveyorOffer"
        )

        return

    end

    if typeof(Result) ~= "table" then
        return
    end

    for _, Offer in pairs(Result) do

        if typeof(Offer) ~= "table" then
            continue
        end

        local OfferId =
            Offer.OfferId

        local PackName =
            Offer.PackName

        local Mutation =
            Offer.Mutation

        if not PackName then
            continue
        end

        if AllowedPacks[PackName]
            and ToggleStates[PackName] then

            AddLog(
                "Buying: " ..
                tostring(PackName)
            )

            local BuySuccess =
                pcall(function()

                    BuyPack:FireServer(
                        PackName,
                        Mutation,
                        OfferId
                    )

                end)

            if BuySuccess then

                task.wait(0.5)

                pcall(function()

                    SetRecoverPack:
                        FireServer(
                            OfferId
                        )

                end)

                AddLog(
                    "ROLLED: " ..
                    tostring(PackName)
                )

            else

                AddLog(
                    "ERROR: BuyPack"
                )

            end

        end

    end

end

--==================================================
-- START / STOP FARM
--==================================================

StartButton.MouseButton1Click:Connect(function()

    if Running then

        Running = false

        StartButton.Text =
            "START FARM"

        StartButton.BackgroundColor3 =
            GREEN

        AddLog(
            "Farm Stopped"
        )

        return
    end

    if not HasSelectedPack() then

        AddLog(
            "ERROR: No pack selected"
        )

        return
    end

    Running = true

    StartButton.Text =
        "STOP FARM"

    StartButton.BackgroundColor3 =
        RED

    AddLog(
        "Farm Started"
    )

    task.spawn(function()

        while Running do

            BuyAndRoll()

            task.wait(Delay)

        end

    end)

end)

--==================================================
-- SHOW / HIDE ICON
--==================================================

local ShowButton = Create("TextButton", {
    Name = "ShowButton",

    Size = UDim2.new(0, 48, 0, 48),

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

    Active = true,

    AutoButtonColor = false,

    ZIndex = 999
}, ScreenGui)

Create("UICorner", {
    CornerRadius = UDim.new(0, 10)
}, ShowButton)

--==================================================
-- SHOW ICON DRAG
--==================================================

local IconDragging = false
local IconDragStart
local IconStartPosition

ShowButton.MouseButton1Down:Connect(function()

    IconDragging = true

    IconDragStart =
        UserInputService:GetMouseLocation()

    IconStartPosition =
        ShowButton.Position

end)

UserInputService.InputChanged:Connect(function(Input)

    if not IconDragging then
        return
    end

    if Input.UserInputType ~= Enum.UserInputType.MouseMovement then
        return
    end

    local MousePosition =
        UserInputService:GetMouseLocation()

    local Delta =
        MousePosition - IconDragStart

    ShowButton.Position = UDim2.new(
        IconStartPosition.X.Scale,
        IconStartPosition.X.Offset + Delta.X,

        IconStartPosition.Y.Scale,
        IconStartPosition.Y.Offset + Delta.Y
    )

end)

UserInputService.InputEnded:Connect(function(Input)

    if Input.UserInputType ==
        Enum.UserInputType.MouseButton1 then

        IconDragging = false

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
-- AUTO SCAN
--==================================================

task.defer(function()

    ScanPacks()

end)

--==================================================
-- READY
--==================================================

AddLog("Ready")
