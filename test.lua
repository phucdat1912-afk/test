local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local RequestConveyorOffer = Remotes:WaitForChild("RequestConveyorOffer")
local BuyPack = Remotes:WaitForChild("BuyPack")
local SetRecoverPack = Remotes:WaitForChild("SetRecoverPack")

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local Delay = 0.5
local Running = false

local ToggleStates = {
    ["Event 2 Pack"] = false,
    ["Anti-AFK"] = true
}

local AllowedPacks = {}
local PackButtons = {}
local Logs = {}

local SettingsFile = "1tap_PackFarm_Settings.json"
local LoadedSettings = nil

--------------------------------------------------
-- COLORS
--------------------------------------------------

local BG = Color3.fromRGB(18, 18, 22)
local PANEL = Color3.fromRGB(25, 25, 30)
local PANEL2 = Color3.fromRGB(31, 31, 37)
local BUTTON = Color3.fromRGB(38, 38, 45)
local HOVER = Color3.fromRGB(48, 48, 57)

local WHITE = Color3.fromRGB(235, 235, 240)
local GRAY = Color3.fromRGB(150, 150, 160)

local GREEN = Color3.fromRGB(80, 220, 120)
local RED = Color3.fromRGB(240, 80, 80)
local YELLOW = Color3.fromRGB(240, 200, 80)

--------------------------------------------------
-- FILE SUPPORT
--------------------------------------------------

local function CanReadFile()
    return type(isfile) == "function"
        and type(readfile) == "function"
end

local function CanWriteFile()
    return type(writefile) == "function"
end

local function LoadSettingsData()
    if not CanReadFile() then
        return false
    end

    local exists = false

    local okExists, resultExists = pcall(function()
        return isfile(SettingsFile)
    end)

    if okExists then
        exists = resultExists
    end

    if not exists then
        return false
    end

    local ok, result = pcall(function()
        local Content = readfile(SettingsFile)
        return HttpService:JSONDecode(Content)
    end)

    if not ok or type(result) ~= "table" then
        return false
    end

    LoadedSettings = result

    --------------------------------------------------
    -- DELAY
    --------------------------------------------------

    if type(result.Delay) == "number" then
        Delay = math.clamp(result.Delay, 0.1, 10)
    end

    --------------------------------------------------
    -- TOGGLES
    --------------------------------------------------

    if type(result.Event2Pack) == "boolean" then
        ToggleStates["Event 2 Pack"] = result.Event2Pack
    end

    if type(result.AntiAFK) == "boolean" then
        ToggleStates["Anti-AFK"] = result.AntiAFK
    end

    --------------------------------------------------
    -- PACKS
    --------------------------------------------------

    if type(result.AllowedPacks) == "table" then
        AllowedPacks = {}

        for PackName, Enabled in pairs(result.AllowedPacks) do
            if Enabled == true then
                AllowedPacks[PackName] = true
            end
        end
    end

    return true
end

local SettingsLoaded = LoadSettingsData()

--------------------------------------------------
-- REMOVE OLD GUI
--------------------------------------------------

local OldGui = CoreGui:FindFirstChild("1tap_PackFarm")

if OldGui then
    OldGui:Destroy()
end

--------------------------------------------------
-- CREATE HELPER
--------------------------------------------------

local function Create(ClassName, Properties)
    local Object = Instance.new(ClassName)

    for Property, Value in pairs(Properties) do
        Object[Property] = Value
    end

    return Object
end

--------------------------------------------------
-- SCREEN GUI
--------------------------------------------------

local ScreenGui = Create("ScreenGui", {
    Name = "1tap_PackFarm",
    Parent = CoreGui,
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

--------------------------------------------------
-- MAIN
--------------------------------------------------

local Main = Create("Frame", {
    Parent = ScreenGui,
    Name = "Main",
    Size = UDim2.fromOffset(600, 400),
    Position = UDim2.new(0.5, -300, 0.5, -200),
    BackgroundColor3 = BG,
    BorderSizePixel = 0
})

Create("UICorner", {
    Parent = Main,
    CornerRadius = UDim.new(0, 8)
})

--------------------------------------------------
-- TOP BAR
--------------------------------------------------

local TopBar = Create("Frame", {
    Parent = Main,
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0
})

Create("UICorner", {
    Parent = TopBar,
    CornerRadius = UDim.new(0, 8)
})

local DragBar = Create("Frame", {
    Parent = TopBar,
    Size = UDim2.new(1, -50, 1, 0),
    BackgroundTransparency = 1
})

local Title = Create("TextLabel", {
    Parent = DragBar,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.fromOffset(14, 0),
    Text = "1tap Pack Farm",
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextColor3 = WHITE,
    TextXAlignment = Enum.TextXAlignment.Left
})

--------------------------------------------------
-- DRAG MAIN
--------------------------------------------------

local Dragging = false
local DragStart
local StartPosition

DragBar.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch then

        Dragging = true
        DragStart = Input.Position
        StartPosition = Main.Position

        Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if not Dragging then
        return
    end

    if Input.UserInputType ~= Enum.UserInputType.MouseMovement
        and Input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local Delta = Input.Position - DragStart

    Main.Position = UDim2.new(
        StartPosition.X.Scale,
        StartPosition.X.Offset + Delta.X,
        StartPosition.Y.Scale,
        StartPosition.Y.Offset + Delta.Y
    )
end)

--------------------------------------------------
-- HIDE BUTTON
--------------------------------------------------

local HideButton = Create("TextButton", {
    Parent = TopBar,
    Size = UDim2.fromOffset(38, 30),
    Position = UDim2.new(1, -43, 0, 6),
    BackgroundColor3 = BUTTON,
    Text = "—",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = WHITE,
    BorderSizePixel = 0,
    AutoButtonColor = false
})

Create("UICorner", {
    Parent = HideButton,
    CornerRadius = UDim.new(0, 6)
})

HideButton.MouseEnter:Connect(function()
    HideButton.BackgroundColor3 = HOVER
end)

HideButton.MouseLeave:Connect(function()
    HideButton.BackgroundColor3 = BUTTON
end)

--------------------------------------------------
-- SHOW BUTTON
--------------------------------------------------

local ShowButton = Create("TextButton", {
    Parent = ScreenGui,
    Name = "ShowButton",
    Size = UDim2.fromOffset(44, 44),
    Position = UDim2.new(0, 10, 0.5, -22),
    BackgroundColor3 = PANEL,
    Text = "1T",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = WHITE,
    BorderSizePixel = 0,
    Visible = false,
    AutoButtonColor = false
})

Create("UICorner", {
    Parent = ShowButton,
    CornerRadius = UDim.new(1, 0)
})

--------------------------------------------------
-- LOAD GUI POSITIONS
--------------------------------------------------

if LoadedSettings then

    if type(LoadedSettings.MainPosition) == "table" then
        local P = LoadedSettings.MainPosition

        if type(P.XScale) == "number"
            and type(P.XOffset) == "number"
            and type(P.YScale) == "number"
            and type(P.YOffset) == "number" then

            Main.Position = UDim2.new(
                P.XScale,
                P.XOffset,
                P.YScale,
                P.YOffset
            )
        end
    end

    if type(LoadedSettings.ShowButtonPosition) == "table" then
        local P = LoadedSettings.ShowButtonPosition

        if type(P.XScale) == "number"
            and type(P.XOffset) == "number"
            and type(P.YScale) == "number"
            and type(P.YOffset) == "number" then

            ShowButton.Position = UDim2.new(
                P.XScale,
                P.XOffset,
                P.YScale,
                P.YOffset
            )
        end
    end
end

--------------------------------------------------
-- DRAG SHOW BUTTON
--------------------------------------------------

local ShowDragging = false
local ShowDragStart
local ShowStartPosition

ShowButton.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch then

        ShowDragging = true
        ShowDragStart = Input.Position
        ShowStartPosition = ShowButton.Position

        Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                ShowDragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if not ShowDragging then
        return
    end

    if Input.UserInputType ~= Enum.UserInputType.MouseMovement
        and Input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local Delta = Input.Position - ShowDragStart

    ShowButton.Position = UDim2.new(
        ShowStartPosition.X.Scale,
        ShowStartPosition.X.Offset + Delta.X,
        ShowStartPosition.Y.Scale,
        ShowStartPosition.Y.Offset + Delta.Y
    )
end)

--------------------------------------------------
-- SIDEBAR
--------------------------------------------------

local Sidebar = Create("Frame", {
    Parent = Main,
    Size = UDim2.fromOffset(125, 358),
    Position = UDim2.fromOffset(0, 42),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0
})

--------------------------------------------------
-- CONTENT
--------------------------------------------------

local Content = Create("Frame", {
    Parent = Main,
    Size = UDim2.new(1, -125, 1, -42),
    Position = UDim2.fromOffset(125, 42),
    BackgroundColor3 = BG,
    BorderSizePixel = 0
})

--------------------------------------------------
-- PAGES
--------------------------------------------------

local FarmPage = Create("Frame", {
    Parent = Content,
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1
})

local EventsPage = Create("Frame", {
    Parent = Content,
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Visible = false
})

local SettingsPage = Create("Frame", {
    Parent = Content,
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Visible = false
})

local LogsPage = Create("Frame", {
    Parent = Content,
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Visible = false
})

--------------------------------------------------
-- PAGE SWITCH
--------------------------------------------------

local Pages = {
    Farm = FarmPage,
    Events = EventsPage,
    Settings = SettingsPage,
    Logs = LogsPage
}

local function ShowPage(Name)
    for PageName, Page in pairs(Pages) do
        Page.Visible = PageName == Name
    end
end

--------------------------------------------------
-- SIDEBAR BUTTON
--------------------------------------------------

local function CreateSideButton(Text, Y, PageName)
    local Button = Create("TextButton", {
        Parent = Sidebar,
        Size = UDim2.new(1, -12, 0, 38),
        Position = UDim2.fromOffset(6, Y),
        BackgroundColor3 = BUTTON,
        Text = Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextColor3 = WHITE,
        BorderSizePixel = 0,
        AutoButtonColor = false
    })

    Create("UICorner", {
        Parent = Button,
        CornerRadius = UDim.new(0, 6)
    })

    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = HOVER
    end)

    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = BUTTON
    end)

    Button.MouseButton1Click:Connect(function()
        ShowPage(PageName)
    end)

    return Button
end

CreateSideButton("Farm", 10, "Farm")
CreateSideButton("Events", 54, "Events")
CreateSideButton("Settings", 98, "Settings")
CreateSideButton("Logs", 142, "Logs")

--------------------------------------------------
-- LOG PAGE
--------------------------------------------------

local LogScroll = Create("ScrollingFrame", {
    Parent = LogsPage,
    Size = UDim2.new(1, -20, 1, -55),
    Position = UDim2.fromOffset(10, 10),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    CanvasSize = UDim2.new()
})

Create("UICorner", {
    Parent = LogScroll,
    CornerRadius = UDim.new(0, 6)
})

local LogLayout = Create("UIListLayout", {
    Parent = LogScroll,
    Padding = UDim.new(0, 3),
    SortOrder = Enum.SortOrder.LayoutOrder
})

Create("UIPadding", {
    Parent = LogScroll,
    PaddingTop = UDim.new(0, 8),
    PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8)
})

LogLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    LogScroll.CanvasSize = UDim2.fromOffset(
        0,
        LogLayout.AbsoluteContentSize.Y + 15
    )
end)

local function GetLogColor(Text)
    if string.find(Text, "ERROR") then
        return RED
    elseif string.find(Text, "Buying") then
        return YELLOW
    elseif string.find(Text, "ROLLED") then
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
            Parent = LogScroll,
            Size = UDim2.new(1, -4, 0, 25),
            BackgroundTransparency = 1,
            Text = LogText,
            Font = Enum.Font.Code,
            TextSize = 12,
            TextColor3 = GetLogColor(LogText),
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = Index
        })
    end

    task.defer(function()
        LogScroll.CanvasPosition = Vector2.new(
            0,
            math.max(0, LogLayout.AbsoluteContentSize.Y)
        )
    end)
end

local ClearLogs = Create("TextButton", {
    Parent = LogsPage,
    Size = UDim2.fromOffset(100, 32),
    Position = UDim2.new(1, -110, 1, -42),
    BackgroundColor3 = BUTTON,
    Text = "Clear Logs",
    Font = Enum.Font.GothamSemibold,
    TextSize = 12,
    TextColor3 = WHITE,
    BorderSizePixel = 0
})

Create("UICorner", {
    Parent = ClearLogs,
    CornerRadius = UDim.new(0, 6)
})

ClearLogs.MouseButton1Click:Connect(function()
    Logs = {}
    AddLog("Logs cleared")
end)

--------------------------------------------------
-- FARM PAGE
--------------------------------------------------

local StartButton = Create("TextButton", {
    Parent = FarmPage,
    Size = UDim2.fromOffset(100, 34),
    Position = UDim2.fromOffset(10, 10),
    BackgroundColor3 = RED,
    Text = "START",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = WHITE,
    BorderSizePixel = 0
})

Create("UICorner", {
    Parent = StartButton,
    CornerRadius = UDim.new(0, 6)
})

local SearchFrame = Create("Frame", {
    Parent = FarmPage,
    Size = UDim2.new(1, -130, 0, 34),
    Position = UDim2.fromOffset(120, 10),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0
})

Create("UICorner", {
    Parent = SearchFrame,
    CornerRadius = UDim.new(0, 6)
})

Create("TextLabel", {
    Parent = SearchFrame,
    Size = UDim2.fromOffset(30, 34),
    BackgroundTransparency = 1,
    Text = "⌕",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = GRAY
})

local SearchBox = Create("TextBox", {
    Parent = SearchFrame,
    Size = UDim2.new(1, -35, 1, 0),
    Position = UDim2.fromOffset(32, 0),
    BackgroundTransparency = 1,
    PlaceholderText = "Search pack...",
    PlaceholderColor3 = GRAY,
    Text = "",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = WHITE,
    ClearTextOnFocus = false
})

local ScanButton = Create("TextButton", {
    Parent = FarmPage,
    Size = UDim2.fromOffset(100, 30),
    Position = UDim2.fromOffset(10, 52),
    BackgroundColor3 = BUTTON,
    Text = "Scan Packs",
    Font = Enum.Font.GothamSemibold,
    TextSize = 12,
    TextColor3 = WHITE,
    BorderSizePixel = 0
})

Create("UICorner", {
    Parent = ScanButton,
    CornerRadius = UDim.new(0, 6)
})

local PackCount = Create("TextLabel", {
    Parent = FarmPage,
    Size = UDim2.fromOffset(150, 30),
    Position = UDim2.fromOffset(120, 52),
    BackgroundTransparency = 1,
    Text = "Packs: 0",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = GRAY,
    TextXAlignment = Enum.TextXAlignment.Left
})

local PackScroll = Create("ScrollingFrame", {
    Parent = FarmPage,
    Size = UDim2.new(1, -20, 1, -95),
    Position = UDim2.fromOffset(10, 90),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    CanvasSize = UDim2.new()
})

Create("UICorner", {
    Parent = PackScroll,
    CornerRadius = UDim.new(0, 6)
})

local PackLayout = Create("UIGridLayout", {
    Parent = PackScroll,
    CellSize = UDim2.fromOffset(145, 35),
    CellPadding = UDim2.fromOffset(6, 6),
    SortOrder = Enum.SortOrder.LayoutOrder
})

PackLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    PackScroll.CanvasSize = UDim2.fromOffset(
        0,
        PackLayout.AbsoluteContentSize.Y + 10
    )
end)

--------------------------------------------------
-- SEARCH
--------------------------------------------------

local function UpdateSearch()
    local SearchText = string.lower(SearchBox.Text)

    for PackName, Button in pairs(PackButtons) do
        if SearchText == "" then
            Button.Visible = true
        else
            Button.Visible = string.find(
                string.lower(PackName),
                SearchText,
                1,
                true
            ) ~= nil
        end
    end
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(UpdateSearch)

--------------------------------------------------
-- PACK TOGGLE
--------------------------------------------------

local function UpdatePackButton(PackName)
    local Button = PackButtons[PackName]

    if not Button then
        return
    end

    local Enabled = AllowedPacks[PackName] == true

    if Enabled then
        Button.Text = PackName .. "  [ON]"
        Button.BackgroundColor3 = Color3.fromRGB(40, 90, 55)
    else
        Button.Text = PackName .. "  [OFF]"
        Button.BackgroundColor3 = BUTTON
    end
end

local function CreatePackToggle(PackName)
    if PackButtons[PackName] then
        return
    end

    if AllowedPacks[PackName] == nil then
        AllowedPacks[PackName] = false
    end

    local Button = Create("TextButton", {
        Parent = PackScroll,
        Size = UDim2.fromOffset(145, 35),
        BackgroundColor3 = BUTTON,
        Text = "",
        Font = Enum.Font.GothamSemibold,
        TextSize = 11,
        TextColor3 = WHITE,
        BorderSizePixel = 0,
        AutoButtonColor = false
    })

    Create("UICorner", {
        Parent = Button,
        CornerRadius = UDim.new(0, 6)
    })

    PackButtons[PackName] = Button

    UpdatePackButton(PackName)

    Button.MouseButton1Click:Connect(function()
        AllowedPacks[PackName] = not AllowedPacks[PackName]
        UpdatePackButton(PackName)
    end)

    Button.MouseEnter:Connect(function()
        if not AllowedPacks[PackName] then
            Button.BackgroundColor3 = HOVER
        end
    end)

    Button.MouseLeave:Connect(function()
        UpdatePackButton(PackName)
    end)
end

--------------------------------------------------
-- SCAN PACKS
--------------------------------------------------

local function ScanPacks()
    local PotentialCards = ReplicatedStorage:FindFirstChild("PotentialCards")

    if not PotentialCards then
        AddLog("ERROR: PotentialCards not found")
        return
    end

    local Excluded = {
        ScalingUnits = true,
        Crafted = true,
        Light = true,
        Dark = true,
        Festival = true,
        Manga = true
    }

    local Found = 0

    for _, Object in ipairs(PotentialCards:GetChildren()) do
        if Object:IsA("Folder")
            and not Excluded[Object.Name] then

            CreatePackToggle(Object.Name)
            Found += 1
        end
    end

    PackCount.Text = "Packs: " .. tostring(Found)

    UpdateSearch()

    AddLog("Scanned " .. tostring(Found) .. " packs")
end

ScanButton.MouseButton1Click:Connect(ScanPacks)

--------------------------------------------------
-- EVENTS PAGE
--------------------------------------------------

local EventTitle = Create("TextLabel", {
    Parent = EventsPage,
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.fromOffset(10, 10),
    BackgroundTransparency = 1,
    Text = "Event Packs",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = WHITE,
    TextXAlignment = Enum.TextXAlignment.Left
})

local Event2Button = Create("TextButton", {
    Parent = EventsPage,
    Size = UDim2.new(1, -20, 0, 40),
    Position = UDim2.fromOffset(10, 50),
    BackgroundColor3 = BUTTON,
    Text = "",
    Font = Enum.Font.GothamSemibold,
    TextSize = 12,
    TextColor3 = WHITE,
    BorderSizePixel = 0
})

Create("UICorner", {
    Parent = Event2Button,
    CornerRadius = UDim.new(0, 6)
})

local function UpdateEventButton()
    if ToggleStates["Event 2 Pack"] then
        Event2Button.Text = "Event 2 Pack   [ON]"
        Event2Button.BackgroundColor3 = Color3.fromRGB(40, 90, 55)
    else
        Event2Button.Text = "Event 2 Pack   [OFF]"
        Event2Button.BackgroundColor3 = BUTTON
    end
end

Event2Button.MouseButton1Click:Connect(function()
    ToggleStates["Event 2 Pack"] = not ToggleStates["Event 2 Pack"]
    UpdateEventButton()
end)

UpdateEventButton()

--------------------------------------------------
-- SETTINGS PAGE
--------------------------------------------------

local DelayTitle = Create("TextLabel", {
    Parent = SettingsPage,
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.fromOffset(10, 10),
    BackgroundTransparency = 1,
    Text = "Farm Delay",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = WHITE,
    TextXAlignment = Enum.TextXAlignment.Left
})

local DelayValue = Create("TextLabel", {
    Parent = SettingsPage,
    Size = UDim2.fromOffset(80, 35),
    Position = UDim2.fromOffset(10, 45),
    BackgroundColor3 = PANEL,
    Text = string.format("%.1f", Delay),
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = WHITE,
    BorderSizePixel = 0
})

Create("UICorner", {
    Parent = DelayValue,
    CornerRadius = UDim.new(0, 6)
})

local MinusButton = Create("TextButton", {
    Parent = SettingsPage,
    Size = UDim2.fromOffset(40, 35),
    Position = UDim2.fromOffset(95, 45),
    BackgroundColor3 = BUTTON,
    Text = "-",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = WHITE,
    BorderSizePixel = 0
})

Create("UICorner", {
    Parent = MinusButton,
    CornerRadius = UDim.new(0, 6)
})

local PlusButton = Create("TextButton", {
    Parent = SettingsPage,
    Size = UDim2.fromOffset(40, 35),
    Position = UDim2.fromOffset(140, 45),
    BackgroundColor3 = BUTTON,
    Text = "+",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = WHITE,
    BorderSizePixel = 0
})

Create("UICorner", {
    Parent = PlusButton,
    CornerRadius = UDim.new(0, 6)
})

local function UpdateDelay()
    DelayValue.Text = string.format("%.1f", Delay)
end

MinusButton.MouseButton1Click:Connect(function()
    Delay = math.clamp(
        math.round((Delay - 0.1) * 10) / 10,
        0.1,
        10
    )

    UpdateDelay()
end)

PlusButton.MouseButton1Click:Connect(function()
    Delay = math.clamp(
        math.round((Delay + 0.1) * 10) / 10,
        0.1,
        10
    )

    UpdateDelay()
end)

--------------------------------------------------
-- ANTI AFK
--------------------------------------------------

local AntiAFKButton = Create("TextButton", {
    Parent = SettingsPage,
    Size = UDim2.new(1, -20, 0, 38),
    Position = UDim2.fromOffset(10, 95),
    BackgroundColor3 = BUTTON,
    Text = "",
    Font = Enum.Font.GothamSemibold,
    TextSize = 12,
    TextColor3 = WHITE,
    BorderSizePixel = 0
})

Create("UICorner", {
    Parent = AntiAFKButton,
    CornerRadius = UDim.new(0, 6)
})

local function UpdateAntiAFKButton()
    if ToggleStates["Anti-AFK"] then
        AntiAFKButton.Text = "Anti-AFK   [ON]"
        AntiAFKButton.BackgroundColor3 = Color3.fromRGB(40, 90, 55)
    else
        AntiAFKButton.Text = "Anti-AFK   [OFF]"
        AntiAFKButton.BackgroundColor3 = BUTTON
    end
end

AntiAFKButton.MouseButton1Click:Connect(function()
    ToggleStates["Anti-AFK"] = not ToggleStates["Anti-AFK"]
    UpdateAntiAFKButton()
end)

UpdateAntiAFKButton()

--------------------------------------------------
-- SAVE SETTINGS BUTTON
--------------------------------------------------

local SaveButton = Create("TextButton", {
    Parent = SettingsPage,
    Size = UDim2.new(1, -20, 0, 42),
    Position = UDim2.fromOffset(10, 150),
    BackgroundColor3 = BUTTON,
    Text = "Save Settings",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = WHITE,
    BorderSizePixel = 0,
    AutoButtonColor = false
})

Create("UICorner", {
    Parent = SaveButton,
    CornerRadius = UDim.new(0, 6)
})

--------------------------------------------------
-- SAVE FUNCTION
-- IMPORTANT: defined AFTER ShowButton/Main exist
--------------------------------------------------

local function SaveSettings()
    if not CanWriteFile() then
        AddLog("ERROR: writefile is not supported")
        return false
    end

    local Data = {
        Delay = Delay,

        Event2Pack = ToggleStates["Event 2 Pack"],
        AntiAFK = ToggleStates["Anti-AFK"],

        AllowedPacks = {},

        MainPosition = {
            XScale = Main.Position.X.Scale,
            XOffset = Main.Position.X.Offset,
            YScale = Main.Position.Y.Scale,
            YOffset = Main.Position.Y.Offset
        },

        ShowButtonPosition = {
            XScale = ShowButton.Position.X.Scale,
            XOffset = ShowButton.Position.X.Offset,
            YScale = ShowButton.Position.Y.Scale,
            YOffset = ShowButton.Position.Y.Offset
        }
    }

    for PackName, Enabled in pairs(AllowedPacks) do
        if Enabled == true then
            Data.AllowedPacks[PackName] = true
        end
    end

    local Success, ErrorMessage = pcall(function()
        local Json = HttpService:JSONEncode(Data)
        writefile(SettingsFile, Json)
    end)

    if not Success then
        AddLog("ERROR: Save failed")
        warn("[1tap Pack Farm] Save error:", ErrorMessage)
        return false
    end

    AddLog("Settings saved")

    SaveButton.Text = "Saved!"

    task.delay(1.2, function()
        if SaveButton and SaveButton.Parent then
            SaveButton.Text = "Save Settings"
        end
    end)

    return true
end

SaveButton.MouseButton1Click:Connect(SaveSettings)

--------------------------------------------------
-- FARM CHECK
--------------------------------------------------

local function HasSelectedPack()
    for PackName, Enabled in pairs(AllowedPacks) do
        if Enabled == true then
            return true
        end
    end

    return false
end

--------------------------------------------------
-- BUY AND ROLL
--------------------------------------------------

local function BuyAndRoll()
    if not HasSelectedPack() then
        AddLog("ERROR: No pack selected")
        return
    end

    local OfferCount = 1

    if ToggleStates["Event 2 Pack"] then
        OfferCount = 2
    end

    local Success, Offers = pcall(function()
        return RequestConveyorOffer:InvokeServer(OfferCount)
    end)

    if not Success then
        AddLog("ERROR: RequestConveyorOffer failed")
        return
    end

    if type(Offers) ~= "table" then
        AddLog("ERROR: Invalid offer")
        return
    end

    for _, Offer in ipairs(Offers) do

        if type(Offer) ~= "table" then
            continue
        end

        local PackName = Offer.PackName
        local Mutation = Offer.Mutation
        local OfferId = Offer.OfferId

        if PackName
            and AllowedPacks[PackName]
            and OfferId then

            AddLog("Buying " .. tostring(PackName))

            local BuySuccess = pcall(function()
                BuyPack:FireServer(
                    PackName,
                    Mutation,
                    OfferId
                )
            end)

            if not BuySuccess then
                AddLog("ERROR: BuyPack failed")
                continue
            end

            task.wait(0.5)

            pcall(function()
                SetRecoverPack:FireServer(OfferId)
            end)

            AddLog("ROLLED " .. tostring(PackName))
        end
    end
end

--------------------------------------------------
-- START / STOP
--------------------------------------------------

local function UpdateStartButton()
    if Running then
        StartButton.Text = "STOP"
        StartButton.BackgroundColor3 = RED
    else
        StartButton.Text = "START"
        StartButton.BackgroundColor3 = GREEN
    end
end

local function StopFarm()
    Running = false
    UpdateStartButton()
    AddLog("Farm stopped")
end

local function StartFarm()
    if Running then
        return
    end

    if not HasSelectedPack() then
        AddLog("ERROR: Select at least 1 pack")
        return
    end

    Running = true
    UpdateStartButton()
    AddLog("Farm started")

    task.spawn(function()
        while Running do
            BuyAndRoll()
            task.wait(Delay)
        end
    end)
end

StartButton.MouseButton1Click:Connect(function()
    if Running then
        StopFarm()
    else
        StartFarm()
    end
end)

UpdateStartButton()

--------------------------------------------------
-- ANTI AFK
--------------------------------------------------

Player.Idled:Connect(function()
    if not ToggleStates["Anti-AFK"] then
        return
    end

    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

--------------------------------------------------
-- HIDE / SHOW
--------------------------------------------------

HideButton.MouseButton1Click:Connect(function()
    Main.Visible = false
    ShowButton.Visible = true
end)

ShowButton.MouseButton1Click:Connect(function()
    if ShowDragging then
        return
    end

    Main.Visible = true
    ShowButton.Visible = false
end)

--------------------------------------------------
-- INITIAL SCAN
--------------------------------------------------

task.defer(function()

    ScanPacks()

    if SettingsLoaded then
        AddLog("Settings loaded")
    end

    AddLog("Ready")
end)
