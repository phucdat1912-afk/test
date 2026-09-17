--// 1tap Pack Farm
--// Full rewritten version

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer

--==================================================
-- CONFIG
--==================================================

local SettingsFile = "1tap_PackFarm_Settings.json"

local Delay = 0.5
local Running = false

local ToggleStates = {
    ["Event 2 Pack"] = false,
    ["Anti-AFK"] = true
}

local AllowedPacks = {}
local PackButtons = {}
local Logs = {}

local LoadedSettings = {}

--==================================================
-- SAFE FILE FUNCTIONS
--==================================================

local function CanUseFileAPI()
    return type(readfile) == "function"
        and type(writefile) == "function"
        and type(isfile) == "function"
end

local function LoadSettings()
    if not CanUseFileAPI() then
        return
    end

    local success, result = pcall(function()
        if not isfile(SettingsFile) then
            return nil
        end

        return HttpService:JSONDecode(readfile(SettingsFile))
    end)

    if success and type(result) == "table" then
        LoadedSettings = result

        if type(result.Delay) == "number" then
            Delay = math.clamp(result.Delay, 0.1, 10)
        end

        if result.Event2Pack ~= nil then
            ToggleStates["Event 2 Pack"] = result.Event2Pack == true
        end

        if result.AntiAFK ~= nil then
            ToggleStates["Anti-AFK"] = result.AntiAFK == true
        end
    end
end

LoadSettings()

--==================================================
-- REMOTES
--==================================================

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local RequestConveyorOffer = Remotes:WaitForChild("RequestConveyorOffer")
local BuyPack = Remotes:WaitForChild("BuyPack")
local SetRecoverPack = Remotes:WaitForChild("SetRecoverPack")

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
-- CREATE HELPER
--==================================================

local function Create(ClassName, Properties, Parent)
    local Object = Instance.new(ClassName)

    for Property, Value in pairs(Properties) do
        pcall(function()
            Object[Property] = Value
        end)
    end

    Object.Parent = Parent

    return Object
end

--==================================================
-- GUI
--==================================================

local ScreenGui = Create("ScreenGui", {
    Name = "1tap_PackFarm",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, CoreGui)

local Main = Create("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(600, 400),
    Position = UDim2.new(0.5, -300, 0.5, -200),
    BackgroundColor3 = Color3.fromRGB(18, 18, 22),
    BorderSizePixel = 0
}, ScreenGui)

Create("UICorner", {
    CornerRadius = UDim.new(0, 8)
}, Main)

--==================================================
-- TOP BAR
--==================================================

local TopBar = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = Color3.fromRGB(27, 27, 33),
    BorderSizePixel = 0
}, Main)

Create("UICorner", {
    CornerRadius = UDim.new(0, 8)
}, TopBar)

local DragBar = Create("Frame", {
    Size = UDim2.new(1, -100, 1, 0),
    BackgroundTransparency = 1
}, TopBar)

local Title = Create("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "1tap Pack Farm",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    Position = UDim2.fromOffset(14, 0)
}, DragBar)

local HideButton = Create("TextButton", {
    Size = UDim2.fromOffset(36, 30),
    Position = UDim2.new(1, -42, 0, 6),
    BackgroundColor3 = Color3.fromRGB(40, 40, 48),
    BorderSizePixel = 0,
    Text = "—",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    AutoButtonColor = true
}, TopBar)

Create("UICorner", {
    CornerRadius = UDim.new(0, 6)
}, HideButton)

--==================================================
-- SIDEBAR
--==================================================

local Sidebar = Create("Frame", {
    Size = UDim2.fromOffset(125, 358),
    Position = UDim2.fromOffset(0, 42),
    BackgroundColor3 = Color3.fromRGB(22, 22, 27),
    BorderSizePixel = 0
}, Main)

local Content = Create("Frame", {
    Size = UDim2.new(1, -125, 1, -42),
    Position = UDim2.fromOffset(125, 42),
    BackgroundColor3 = Color3.fromRGB(18, 18, 22),
    BorderSizePixel = 0
}, Main)

--==================================================
-- PAGES
--==================================================

local FarmPage = Create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1
}, Content)

local EventsPage = Create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Visible = false
}, Content)

local SettingsPage = Create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Visible = false
}, Content)

local LogsPage = Create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Visible = false
}, Content)

--==================================================
-- TAB SYSTEM
--==================================================

local Pages = {
    Farm = FarmPage,
    Events = EventsPage,
    Settings = SettingsPage,
    Logs = LogsPage
}

local TabButtons = {}

local function ShowPage(Name)
    for PageName, Page in pairs(Pages) do
        Page.Visible = PageName == Name
    end

    for ButtonName, Button in pairs(TabButtons) do
        if ButtonName == Name then
            Button.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
        else
            Button.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
        end
    end
end

local function CreateTab(Name, Text, Y)
    local Button = Create("TextButton", {
        Size = UDim2.new(1, -16, 0, 40),
        Position = UDim2.fromOffset(8, Y),
        BackgroundColor3 = Color3.fromRGB(28, 28, 34),
        BorderSizePixel = 0,
        Text = Text,
        TextColor3 = Color3.fromRGB(230, 230, 235),
        Font = Enum.Font.GothamMedium,
        TextSize = 13
    }, Sidebar)

    Create("UICorner", {
        CornerRadius = UDim.new(0, 6)
    }, Button)

    Button.MouseButton1Click:Connect(function()
        ShowPage(Name)
    end)

    TabButtons[Name] = Button

    return Button
end

CreateTab("Farm", "Farm", 12)
CreateTab("Events", "Events", 58)
CreateTab("Settings", "Settings", 104)
CreateTab("Logs", "Logs", 150)

ShowPage("Farm")

--==================================================
-- FARM PAGE
--==================================================

local FarmTitle = Create("TextLabel", {
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.fromOffset(10, 8),
    BackgroundTransparency = 1,
    Text = "Pack Farm",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left
}, FarmPage)

local StartButton = Create("TextButton", {
    Size = UDim2.fromOffset(130, 34),
    Position = UDim2.fromOffset(10, 43),
    BackgroundColor3 = Color3.fromRGB(45, 145, 75),
    BorderSizePixel = 0,
    Text = "START FARM",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 13
}, FarmPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 6)
}, StartButton)

local SearchFrame = Create("Frame", {
    Size = UDim2.new(1, -160, 0, 34),
    Position = UDim2.fromOffset(150, 43),
    BackgroundColor3 = Color3.fromRGB(30, 30, 36),
    BorderSizePixel = 0
}, FarmPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 6)
}, SearchFrame)

local SearchIcon = Create("TextLabel", {
    Size = UDim2.fromOffset(30, 34),
    BackgroundTransparency = 1,
    Text = "🔍",
    TextColor3 = Color3.fromRGB(180, 180, 185),
    Font = Enum.Font.Gotham,
    TextSize = 14
}, SearchFrame)

local SearchBox = Create("TextBox", {
    Size = UDim2.new(1, -35, 1, 0),
    Position = UDim2.fromOffset(32, 0),
    BackgroundTransparency = 1,
    Text = "",
    PlaceholderText = "Search pack...",
    PlaceholderColor3 = Color3.fromRGB(130, 130, 135),
    TextColor3 = Color3.fromRGB(235, 235, 240),
    Font = Enum.Font.Gotham,
    TextSize = 13,
    ClearTextOnFocus = false
}, SearchFrame)

local ScanButton = Create("TextButton", {
    Size = UDim2.fromOffset(100, 30),
    Position = UDim2.fromOffset(10, 85),
    BackgroundColor3 = Color3.fromRGB(45, 45, 55),
    BorderSizePixel = 0,
    Text = "SCAN PACKS",
    TextColor3 = Color3.fromRGB(240, 240, 240),
    Font = Enum.Font.GothamBold,
    TextSize = 11
}, FarmPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 5)
}, ScanButton)

local PackCountLabel = Create("TextLabel", {
    Size = UDim2.fromOffset(250, 30),
    Position = UDim2.fromOffset(120, 85),
    BackgroundTransparency = 1,
    Text = "Packs: 0",
    TextColor3 = Color3.fromRGB(170, 170, 180),
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left
}, FarmPage)

local PackScroll = Create("ScrollingFrame", {
    Size = UDim2.new(1, -20, 1, -128),
    Position = UDim2.fromOffset(10, 118),
    BackgroundColor3 = Color3.fromRGB(23, 23, 28),
    BorderSizePixel = 0,
    ScrollBarThickness = 5,
    CanvasSize = UDim2.fromOffset(0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y
}, FarmPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 6)
}, PackScroll)

local Grid = Create("UIGridLayout", {
    CellSize = UDim2.fromOffset(145, 36),
    CellPadding = UDim2.fromOffset(7, 7),
    SortOrder = Enum.SortOrder.LayoutOrder
}, PackScroll)

--==================================================
-- PACK TOGGLE
--==================================================

local function CreatePackToggle(PackName)
    if PackButtons[PackName] then
        return
    end

    if ToggleStates[PackName] == nil then
        ToggleStates[PackName] = false
    end

    local Button = Create("TextButton", {
        Size = UDim2.fromOffset(145, 36),
        BackgroundColor3 = ToggleStates[PackName]
            and Color3.fromRGB(45, 125, 70)
            or Color3.fromRGB(38, 38, 46),
        BorderSizePixel = 0,
        Text = PackName,
        TextColor3 = Color3.fromRGB(235, 235, 240),
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextTruncate = Enum.TextTruncate.AtEnd
    }, PackScroll)

    Create("UICorner", {
        CornerRadius = UDim.new(0, 6)
    }, Button)

    Button.MouseButton1Click:Connect(function()
        ToggleStates[PackName] = not ToggleStates[PackName]

        if ToggleStates[PackName] then
            Button.BackgroundColor3 = Color3.fromRGB(45, 125, 70)
        else
            Button.BackgroundColor3 = Color3.fromRGB(38, 38, 46)
        end
    end)

    PackButtons[PackName] = Button
end

--==================================================
-- PACK SCAN
--==================================================

local function IsExcludedPack(Name)
    local Lower = string.lower(Name)

    local Excluded = {
        "scalingunits",
        "crafted",
        "light",
        "dark",
        "festival",
        "manga"
    }

    for _, Word in ipairs(Excluded) do
        if Lower == Word or string.find(Lower, Word, 1, true) then
            return true
        end
    end

    return false
end

local function ApplySavedPackStates()
    if type(LoadedSettings.SelectedPacks) ~= "table" then
        return
    end

    for PackName, State in pairs(LoadedSettings.SelectedPacks) do
        if type(PackName) == "string" then
            ToggleStates[PackName] = State == true
        end
    end
end

local function ScanPacks()
    local PotentialCards = ReplicatedStorage:FindFirstChild("PotentialCards")

    if not PotentialCards then
        PackCountLabel.Text = "Packs: 0 | PotentialCards missing"
        return
    end

    for PackName, Button in pairs(PackButtons) do
        if Button then
            Button:Destroy()
        end
    end

    PackButtons = {}
    AllowedPacks = {}

    local Count = 0

    for _, Object in ipairs(PotentialCards:GetChildren()) do
        local PackName = Object.Name

        if not IsExcludedPack(PackName) then
            AllowedPacks[PackName] = true

            if ToggleStates[PackName] == nil then
                ToggleStates[PackName] = false
            end

            Count = Count + 1
        end
    end

    ApplySavedPackStates()

    for PackName in pairs(AllowedPacks) do
        CreatePackToggle(PackName)
    end

    PackCountLabel.Text = "Packs: " .. tostring(Count)
end

--==================================================
-- SEARCH
--==================================================

local function UpdateSearch()
    local Query = string.lower(SearchBox.Text or "")

    for PackName, Button in pairs(PackButtons) do
        if Button then
            local Match = Query == ""
                or string.find(string.lower(PackName), Query, 1, true) ~= nil

            Button.Visible = Match
        end
    end
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(UpdateSearch)

ScanButton.MouseButton1Click:Connect(function()
    ScanPacks()
    UpdateSearch()
end)

--==================================================
-- EVENT PAGE
--==================================================

local EventTitle = Create("TextLabel", {
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.fromOffset(10, 8),
    BackgroundTransparency = 1,
    Text = "Events",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left
}, EventsPage)

local EventCard = Create("Frame", {
    Size = UDim2.new(1, -20, 0, 90),
    Position = UDim2.fromOffset(10, 48),
    BackgroundColor3 = Color3.fromRGB(28, 28, 34),
    BorderSizePixel = 0
}, EventsPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 7)
}, EventCard)

local EventName = Create("TextLabel", {
    Size = UDim2.new(1, -120, 0, 30),
    Position = UDim2.fromOffset(12, 10),
    BackgroundTransparency = 1,
    Text = "Event 2 Pack",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left
}, EventCard)

local EventDescription = Create("TextLabel", {
    Size = UDim2.new(1, -120, 0, 35),
    Position = UDim2.fromOffset(12, 40),
    BackgroundTransparency = 1,
    Text = "Request 2 conveyor offers instead of 1.",
    TextColor3 = Color3.fromRGB(150, 150, 160),
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left
}, EventCard)

local EventToggle = Create("TextButton", {
    Size = UDim2.fromOffset(80, 32),
    Position = UDim2.new(1, -92, 0.5, -16),
    BackgroundColor3 = ToggleStates["Event 2 Pack"]
        and Color3.fromRGB(45, 125, 70)
        or Color3.fromRGB(45, 45, 55),
    BorderSizePixel = 0,
    Text = ToggleStates["Event 2 Pack"] and "ON" or "OFF",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 12
}, EventCard)

Create("UICorner", {
    CornerRadius = UDim.new(0, 6)
}, EventToggle)

EventToggle.MouseButton1Click:Connect(function()
    ToggleStates["Event 2 Pack"] = not ToggleStates["Event 2 Pack"]

    EventToggle.Text = ToggleStates["Event 2 Pack"] and "ON" or "OFF"

    if ToggleStates["Event 2 Pack"] then
        EventToggle.BackgroundColor3 = Color3.fromRGB(45, 125, 70)
    else
        EventToggle.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    end
end)

--==================================================
-- SETTINGS PAGE
--==================================================

local SettingsTitle = Create("TextLabel", {
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.fromOffset(10, 8),
    BackgroundTransparency = 1,
    Text = "Settings",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left
}, SettingsPage)

local DelayLabel = Create("TextLabel", {
    Size = UDim2.fromOffset(200, 30),
    Position = UDim2.fromOffset(10, 50),
    BackgroundTransparency = 1,
    Text = "Farm Delay",
    TextColor3 = Color3.fromRGB(230, 230, 235),
    Font = Enum.Font.GothamMedium,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left
}, SettingsPage)

local DelayValue = Create("TextLabel", {
    Size = UDim2.fromOffset(80, 30),
    Position = UDim2.fromOffset(210, 50),
    BackgroundColor3 = Color3.fromRGB(30, 30, 36),
    BorderSizePixel = 0,
    Text = string.format("%.1f", Delay),
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 13
}, SettingsPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 5)
}, DelayValue)

local MinusButton = Create("TextButton", {
    Size = UDim2.fromOffset(35, 30),
    Position = UDim2.fromOffset(300, 50),
    BackgroundColor3 = Color3.fromRGB(45, 45, 55),
    BorderSizePixel = 0,
    Text = "-",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 16
}, SettingsPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 5)
}, MinusButton)

local PlusButton = Create("TextButton", {
    Size = UDim2.fromOffset(35, 30),
    Position = UDim2.fromOffset(340, 50),
    BackgroundColor3 = Color3.fromRGB(45, 45, 55),
    BorderSizePixel = 0,
    Text = "+",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 16
}, SettingsPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 5)
}, PlusButton)

local AntiAFKLabel = Create("TextLabel", {
    Size = UDim2.fromOffset(200, 30),
    Position = UDim2.fromOffset(10, 95),
    BackgroundTransparency = 1,
    Text = "Anti-AFK",
    TextColor3 = Color3.fromRGB(230, 230, 235),
    Font = Enum.Font.GothamMedium,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left
}, SettingsPage)

local AntiAFKButton = Create("TextButton", {
    Size = UDim2.fromOffset(80, 30),
    Position = UDim2.fromOffset(210, 95),
    BackgroundColor3 = ToggleStates["Anti-AFK"]
        and Color3.fromRGB(45, 125, 70)
        or Color3.fromRGB(45, 45, 55),
    BorderSizePixel = 0,
    Text = ToggleStates["Anti-AFK"] and "ON" or "OFF",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 12
}, SettingsPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 5)
}, AntiAFKButton)

--==================================================
-- SHOW BUTTON
--==================================================

local ShowButton = Create("TextButton", {
    Name = "ShowButton",
    Size = UDim2.fromOffset(48, 48),
    Position = UDim2.new(0, 10, 0.5, -24),
    BackgroundColor3 = Color3.fromRGB(35, 35, 43),
    BorderSizePixel = 0,
    Text = "1T",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    Visible = false
}, ScreenGui)

Create("UICorner", {
    CornerRadius = UDim.new(1, 0)
}, ShowButton)

--==================================================
-- SETTINGS CONTROLS
--==================================================

local function UpdateDelayDisplay()
    DelayValue.Text = string.format("%.1f", Delay)
end

MinusButton.MouseButton1Click:Connect(function()
    Delay = math.clamp(Delay - 0.1, 0.1, 10)
    UpdateDelayDisplay()
end)

PlusButton.MouseButton1Click:Connect(function()
    Delay = math.clamp(Delay + 0.1, 0.1, 10)
    UpdateDelayDisplay()
end)

AntiAFKButton.MouseButton1Click:Connect(function()
    ToggleStates["Anti-AFK"] = not ToggleStates["Anti-AFK"]

    AntiAFKButton.Text = ToggleStates["Anti-AFK"] and "ON" or "OFF"

    if ToggleStates["Anti-AFK"] then
        AntiAFKButton.BackgroundColor3 = Color3.fromRGB(45, 125, 70)
    else
        AntiAFKButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    end
end)

--==================================================
-- LOG PAGE
--==================================================

local LogsTitle = Create("TextLabel", {
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.fromOffset(10, 8),
    BackgroundTransparency = 1,
    Text = "Logs",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left
}, LogsPage)

local LogScroll = Create("ScrollingFrame", {
    Size = UDim2.new(1, -20, 1, -55),
    Position = UDim2.fromOffset(10, 45),
    BackgroundColor3 = Color3.fromRGB(23, 23, 28),
    BorderSizePixel = 0,
    ScrollBarThickness = 5,
    CanvasSize = UDim2.fromOffset(0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y
}, LogsPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 6)
}, LogScroll)

local LogLayout = Create("UIListLayout", {
    Padding = UDim.new(0, 3),
    SortOrder = Enum.SortOrder.LayoutOrder
}, LogScroll)

local function AddLog(Message)
    local Time = os.date("%H:%M:%S")

    table.insert(Logs, {
        Time = Time,
        Message = tostring(Message)
    })

    while #Logs > 100 do
        table.remove(Logs, 1)
    end

    for _, Child in ipairs(LogScroll:GetChildren()) do
        if Child:IsA("TextLabel") then
            Child:Destroy()
        end
    end

    for _, Entry in ipairs(Logs) do
        Create("TextLabel", {
            Size = UDim2.new(1, -10, 0, 22),
            BackgroundTransparency = 1,
            Text = "[" .. Entry.Time .. "] " .. Entry.Message,
            TextColor3 = Color3.fromRGB(200, 200, 210),
            Font = Enum.Font.Code,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        }, LogScroll)
    end

    task.defer(function()
        pcall(function()
            LogScroll.CanvasPosition = Vector2.new(
                0,
                math.max(0, LogLayout.AbsoluteContentSize.Y)
            )
        end)
    end)
end

--==================================================
-- SAVE SETTINGS
--==================================================

local SaveButton = Create("TextButton", {
    Size = UDim2.fromOffset(150, 34),
    Position = UDim2.fromOffset(10, 145),
    BackgroundColor3 = Color3.fromRGB(50, 105, 165),
    BorderSizePixel = 0,
    Text = "SAVE SETTINGS",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 12
}, SettingsPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 6)
}, SaveButton)

local SaveStatus = Create("TextLabel", {
    Size = UDim2.new(1, -175, 0, 34),
    Position = UDim2.fromOffset(170, 145),
    BackgroundTransparency = 1,
    Text = "Settings are not saved automatically.",
    TextColor3 = Color3.fromRGB(145, 145, 155),
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left
}, SettingsPage)

local function SaveSettings()
    if not CanUseFileAPI() then
        SaveStatus.Text = "File API not supported"
        SaveStatus.TextColor3 = Color3.fromRGB(220, 100, 100)
        AddLog("Save failed: file API unavailable")
        return
    end

    local SelectedPacks = {}

    for PackName, Enabled in pairs(ToggleStates) do
        if PackName ~= "Event 2 Pack"
            and PackName ~= "Anti-AFK" then

            SelectedPacks[PackName] = Enabled == true
        end
    end

    local MainPosition = {
        XScale = Main.Position.X.Scale,
        XOffset = Main.Position.X.Offset,
        YScale = Main.Position.Y.Scale,
        YOffset = Main.Position.Y.Offset
    }

    local ShowPosition = {
        XScale = ShowButton.Position.X.Scale,
        XOffset = ShowButton.Position.X.Offset,
        YScale = ShowButton.Position.Y.Scale,
        YOffset = ShowButton.Position.Y.Offset
    }

    local Data = {
        Delay = Delay,
        Event2Pack = ToggleStates["Event 2 Pack"] == true,
        AntiAFK = ToggleStates["Anti-AFK"] == true,
        SelectedPacks = SelectedPacks,
        MainPosition = MainPosition,
        ShowButtonPosition = ShowPosition
    }

    local Success, ErrorMessage = pcall(function()
        writefile(
            SettingsFile,
            HttpService:JSONEncode(Data)
        )
    end)

    if Success then
        SaveStatus.Text = "Saved!"
        SaveStatus.TextColor3 = Color3.fromRGB(90, 200, 120)
        AddLog("Settings saved")
    else
        SaveStatus.Text = "Save failed"
        SaveStatus.TextColor3 = Color3.fromRGB(220, 100, 100)
        AddLog("Save failed: " .. tostring(ErrorMessage))
    end
end

SaveButton.MouseButton1Click:Connect(SaveSettings)

--==================================================
-- LOAD GUI POSITIONS
--==================================================

local function ApplySavedPositions()
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

ApplySavedPositions()

--==================================================
-- DRAG MAIN
--==================================================

local DraggingMain = false
local DragStartMain
local StartPositionMain

DragBar.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        DraggingMain = true
        DragStartMain = Input.Position
        StartPositionMain = Main.Position

        Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                DraggingMain = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if DraggingMain and Input.UserInputType == Enum.UserInputType.MouseMovement then
        local Delta = Input.Position - DragStartMain

        Main.Position = UDim2.new(
            StartPositionMain.X.Scale,
            StartPositionMain.X.Offset + Delta.X,
            StartPositionMain.Y.Scale,
            StartPositionMain.Y.Offset + Delta.Y
        )
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
-- DRAG SHOW BUTTON
--==================================================

local DraggingShow = false
local DragStartShow
local StartPositionShow

ShowButton.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        DraggingShow = true
        DragStartShow = Input.Position
        StartPositionShow = ShowButton.Position

        Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                DraggingShow = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if DraggingShow and Input.UserInputType == Enum.UserInputType.MouseMovement then
        local Delta = Input.Position - DragStartShow

        ShowButton.Position = UDim2.new(
            StartPositionShow.X.Scale,
            StartPositionShow.X.Offset + Delta.X,
            StartPositionShow.Y.Scale,
            StartPositionShow.Y.Offset + Delta.Y
        )
    end
end)

--==================================================
-- ANTI AFK
--==================================================

Player.Idled:Connect(function()
    if not ToggleStates["Anti-AFK"] then
        return
    end

    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

--==================================================
-- FARM CHECK
--==================================================

local function HasSelectedPack()
    for PackName, Enabled in pairs(ToggleStates) do
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
-- BUY / ROLL
--==================================================

local function BuyAndRoll()
    local OfferCount = 1

    if ToggleStates["Event 2 Pack"] then
        OfferCount = 2
    end

    local Success, Offers = pcall(function()
        return RequestConveyorOffer:InvokeServer(OfferCount)
    end)

    if not Success then
        AddLog("RequestConveyorOffer error")
        return
    end

    if type(Offers) ~= "table" then
        AddLog("No offers returned")
        return
    end

    for _, Offer in ipairs(Offers) do
        if not Running then
            break
        end

        if type(Offer) == "table" then
            local OfferId = Offer.OfferId
                or Offer.Id
                or Offer.ID

            local PackName = Offer.PackName
                or Offer.Name
                or Offer.Pack

            local Mutation = Offer.Mutation
                or "Normal"

            if PackName
                and AllowedPacks[PackName]
                and ToggleStates[PackName] then

                AddLog(
                    "Buying: "
                    .. tostring(PackName)
                    .. " | "
                    .. tostring(Mutation)
                )

                local BuySuccess, BuyError = pcall(function()
                    BuyPack:FireServer(
                        OfferId,
                        PackName,
                        Mutation
                    )
                end)

                if not BuySuccess then
                    AddLog(
                        "BuyPack error: "
                        .. tostring(BuyError)
                    )
                else
                    task.wait(0.5)

                    pcall(function()
                        SetRecoverPack:FireServer(
                            PackName
                        )
                    end)

                    AddLog(
                        "ROLLED: "
                        .. tostring(PackName)
                    )
                end
            end
        end
    end
end

--==================================================
-- FARM LOOP
--==================================================

local function FarmLoop()
    while Running do
        if HasSelectedPack() then
            BuyAndRoll()
        else
            AddLog("No pack selected")
            task.wait(1)
        end

        task.wait(Delay)
    end
end

StartButton.MouseButton1Click:Connect(function()
    if Running then
        Running = false

        StartButton.Text = "START FARM"
        StartButton.BackgroundColor3 = Color3.fromRGB(45, 145, 75)

        AddLog("Farm stopped")
    else
        if not HasSelectedPack() then
            AddLog("Select at least 1 pack first")
            return
        end

        Running = true

        StartButton.Text = "STOP FARM"
        StartButton.BackgroundColor3 = Color3.fromRGB(170, 55, 55)

        AddLog("Farm started")

        task.spawn(FarmLoop)
    end
end)

--==================================================
-- INITIAL SCAN
--==================================================

task.defer(function()
    task.wait(0.2)

    ScanPacks()
    UpdateSearch()

    AddLog("Packs scanned")
    AddLog("Ready")
end)
