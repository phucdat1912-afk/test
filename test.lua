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
-- CREATE
--==================================================

local function Create(Class, Properties, Parent)

    local Object = Instance.new(Class)

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
    Size = UDim2.new(1, 0, 0, 45),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    ZIndex = 20
}, Main)

Create("UICorner", {
    CornerRadius = UDim.new(0, 10)
}, TopBar)

Create("TextLabel", {
    Size = UDim2.new(0, 250, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    Text = "1tap Pack Farm",
    TextColor3 = WHITE,
    TextSize = 17,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 25
}, TopBar)

--==================================================
-- DRAG
--==================================================

local DragBar = Create("TextButton", {
    Size = UDim2.new(1, -55, 0, 45),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1,
    Text = "",
    AutoButtonColor = false,
    ZIndex = 100
}, Main)

local Dragging = false
local DragStart
local StartPosition

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
-- HIDE
--==================================================

local HideButton = Create("TextButton", {
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

    return Button
end

local FarmTab = CreateSideButton("Farm", 15)
local EventsTab = CreateSideButton("Events", 65)
local SettingsTab = CreateSideButton("Settings", 115)
local LogsTab = CreateSideButton("Logs", 165)

--==================================================
-- CONTENT
--==================================================

local Content = Create("Frame", {
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
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    Visible = true,
    ZIndex = 20
}, Content)

local EventsPage = Create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 20
}, Content)

local SettingsPage = Create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 20
}, Content)

local LogsPage = Create("Frame", {
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
-- FARM PAGE
--==================================================

local StartButton = Create("TextButton", {
    Size = UDim2.new(1, -20, 0, 42),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = GREEN,
    BorderSizePixel = 0,
    Text = "START FARM",
    TextColor3 = WHITE,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    ZIndex = 50
}, FarmPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 7)
}, StartButton)

--==================================================
-- SEARCH BOX
--==================================================

local SearchBox = Create("TextBox", {
    Name = "SearchBox",

    Size = UDim2.new(1, -20, 0, 38),

    Position = UDim2.new(0, 10, 0, 62),

    BackgroundColor3 = Color3.fromRGB(40, 40, 48),

    BorderSizePixel = 1,
    BorderColor3 = Color3.fromRGB(70, 70, 80),

    Text = "",
    PlaceholderText = "🔍  Search pack...",
    PlaceholderColor3 = Color3.fromRGB(160, 160, 170),

    TextColor3 = WHITE,
    TextSize = 13,
    Font = Enum.Font.GothamMedium,

    ClearTextOnFocus = false,

    TextXAlignment = Enum.TextXAlignment.Left,

    ZIndex = 100
}, FarmPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 8)
}, SearchBox)

Create("UIPadding", {
    PaddingLeft = UDim.new(0, 12),
    PaddingRight = UDim.new(0, 12)
}, SearchBox)

--==================================================
-- SCAN BUTTON
--==================================================

local ScanButton = Create("TextButton", {
    Size = UDim2.new(0, 115, 0, 32),
    Position = UDim2.new(0, 10, 0, 108),
    BackgroundColor3 = BUTTON,
    BorderSizePixel = 0,
    Text = "SCAN PACKS",
    TextColor3 = WHITE,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    ZIndex = 50
}, FarmPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 7)
}, ScanButton)

local PackCountLabel = Create("TextLabel", {
    Size = UDim2.new(1, -135, 0, 32),
    Position = UDim2.new(0, 130, 0, 108),
    BackgroundTransparency = 1,
    Text = "0 packs found",
    TextColor3 = GRAY,
    TextSize = 12,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 50
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

    ZIndex = 40
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
    SortOrder = Enum.SortOrder.Name
}, PackScroll)

--==================================================
-- UPDATE SEARCH
--==================================================

local function UpdateSearch()

    local SearchText = string.lower(SearchBox.Text)

    for PackName, Button in pairs(PackButtons) do

        local PackLower = string.lower(PackName)

        if SearchText == "" then

            Button.Visible = true

        elseif string.find(
            PackLower,
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

SearchBox:GetPropertyChangedSignal("Text"):Connect(UpdateSearch)

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

        BackgroundColor3 = BUTTON,

        BorderSizePixel = 0,

        Text = "",

        AutoButtonColor = false,

        ZIndex = 60
    }, PackScroll)

    Create("UICorner", {
        CornerRadius = UDim.new(0, 7)
    }, Button)

    local NameLabel = Create("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),

        Position = UDim2.new(0, 8, 0, 0),

        BackgroundTransparency = 1,

        Text = PackName,

        TextColor3 = WHITE,

        TextSize = 11,

        Font = Enum.Font.GothamMedium,

        TextXAlignment = Enum.TextXAlignment.Left,

        TextTruncate = Enum.TextTruncate.AtEnd,

        ZIndex = 61
    }, Button)

    local Status = Create("TextLabel", {
        Size = UDim2.new(0, 40, 1, 0),

        Position = UDim2.new(1, -45, 0, 0),

        BackgroundTransparency = 1,

        TextSize = 10,

        Font = Enum.Font.GothamBold,

        ZIndex = 61
    }, Button)

    local function Update()

        if ToggleStates[PackName] then

            Status.Text = "ON"
            Status.TextColor3 = GREEN

        else

            Status.Text = "OFF"
            Status.TextColor3 = RED

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

        ToggleStates[PackName] =
            not ToggleStates[PackName]

        Update()

        AddLog(
            PackName ..
            ": " ..
            (ToggleStates[PackName] and "ON" or "OFF")
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
        ReplicatedStorage:FindFirstChild("PotentialCards")

    if not PotentialCards then

        PackCountLabel.Text =
            "PotentialCards not found"

        AddLog("ERROR: PotentialCards not found")

        return
    end

    local Count = 0

    for _, Object in ipairs(
        PotentialCards:GetChildren()
    ) do

        if Object:IsA("Folder") then

            local PackName = Object.Name

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
-- LOG
--==================================================

local LogScroll = Create("ScrollingFrame", {
    Size = UDim2.new(1, -20, 1, -65),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = PANEL2,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ZIndex = 30,
    Visible = true
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
    PaddingLeft = UDim.new(0, 7),
    PaddingRight = UDim.new(0, 7)
}, LogScroll)

function AddLog(Text)

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
            TextColor3 = WHITE,
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
-- EVENTS PAGE
--==================================================

Create("TextLabel", {
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

local function UpdateEvent()

    if ToggleStates["Event 2 Pack"] then

        EventStatus.Text = "ON"
        EventStatus.TextColor3 = GREEN

    else

        EventStatus.Text = "OFF"
        EventStatus.TextColor3 = RED

    end

end

UpdateEvent()

EventFrame.MouseButton1Click:Connect(function()

    ToggleStates["Event 2 Pack"] =
        not ToggleStates["Event 2 Pack"]

    UpdateEvent()

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
    Text = string.format("%.1f", Delay) .. "s",
    TextColor3 = WHITE,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    ZIndex = 30
}, SettingsPage)

Create("UICorner", {
    CornerRadius = UDim.new(0, 7)
}, DelayValue)

local Minus = Create("TextButton", {
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
}, Minus)

local Plus = Create("TextButton", {
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
}, Plus)

local function UpdateDelay()

    Delay = math.clamp(
        math.round(Delay * 10) / 10,
        0.1,
        10
    )

    DelayValue.Text =
        string.format("%.1f", Delay) ..
        "s"

end

Minus.MouseButton1Click:Connect(function()

    Delay -= 0.1
    UpdateDelay()

end)

Plus.MouseButton1Click:Connect(function()

    Delay += 0.1
    UpdateDelay()

end)

--==================================================
-- ANTI AFK
--==================================================

local AntiAFK = Create("TextButton", {
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
}, AntiAFK)

AntiAFK.MouseButton1Click:Connect(function()

    ToggleStates["Anti-AFK"] =
        not ToggleStates["Anti-AFK"]

    if ToggleStates["Anti-AFK"] then

        AntiAFK.Text = "Anti-AFK: ON"
        AntiAFK.TextColor3 = GREEN

    else

        AntiAFK.Text = "Anti-AFK: OFF"
        AntiAFK.TextColor3 = RED

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
-- BUY / ROLL
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

local function BuyAndRoll()

    local OfferCount = 1

    if ToggleStates["Event 2 Pack"] then
        OfferCount = 2
    end

    local Success, Result = pcall(function()

        return RequestConveyorOffer:InvokeServer(
            OfferCount
        )

    end)

    if not Success then

        AddLog("ERROR: RequestConveyorOffer")

        return
    end

    if typeof(Result) ~= "table" then
        return
    end

    for _, Offer in pairs(Result) do

        if typeof(Offer) ~= "table" then
            continue
        end

        local OfferId = Offer.OfferId
        local PackName = Offer.PackName
        local Mutation = Offer.Mutation

        if PackName
            and AllowedPacks[PackName]
            and ToggleStates[PackName] then

            AddLog(
                "Buying: " ..
                tostring(PackName)
            )

            pcall(function()

                BuyPack:FireServer(
                    PackName,
                    Mutation,
                    OfferId
                )

            end)

            task.wait(0.5)

            pcall(function()

                SetRecoverPack:FireServer(
                    OfferId
                )

            end)

            AddLog(
                "ROLLED: " ..
                tostring(PackName)
            )

        end

    end

end

--==================================================
-- START FARM
--==================================================

StartButton.MouseButton1Click:Connect(function()

    if Running then

        Running = false

        StartButton.Text = "START FARM"
        StartButton.BackgroundColor3 = GREEN

        AddLog("Farm Stopped")

        return
    end

    if not HasSelectedPack() then

        AddLog("ERROR: No pack selected")

        return
    end

    Running = true

    StartButton.Text = "STOP FARM"
    StartButton.BackgroundColor3 = RED

    AddLog("Farm Started")

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

    ZIndex = 999
}, ScreenGui)

Create("UICorner", {
    CornerRadius = UDim.new(0, 10)
}, ShowButton)

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

AddLog("Ready")
