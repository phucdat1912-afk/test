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

local AllowedPacks = {
    ["Titan Slayer Pack"] = true,
    ["Chain Devil Pack"] = true,
    ["Soccer Pack"] = true,
    ["Eternity Pack"] = true
}

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
local YELLOW = Color3.fromRGB(240, 200, 80)

--==================================================
-- GUI HELPERS
--==================================================

local function Create(Class, Properties, Parent)

    local Object = Instance.new(Class)

    for Property, Value in pairs(Properties or {}) do
        Object[Property] = Value
    end

    Object.Parent = Parent

    return Object
end

local function Corner(Object, Radius)

    local C = Instance.new("UICorner")

    C.CornerRadius =
        UDim.new(0, Radius or 8)

    C.Parent = Object

    return C
end

local function Stroke(Object, Color, Thickness)

    local S = Instance.new("UIStroke")

    S.Color =
        Color or Color3.fromRGB(55, 55, 65)

    S.Thickness =
        Thickness or 1

    S.Parent = Object

    return S
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

    Position = UDim2.new(
        0.5,
        -300,
        0.5,
        -200
    ),

    BackgroundColor3 = BG,
    BorderSizePixel = 0,

    Active = true,

    ZIndex = 1
}, ScreenGui)

Corner(Main, 12)
Stroke(Main)

--==================================================
-- TITLE
--==================================================

local Title = Create("TextLabel", {
    Size = UDim2.new(1, -70, 0, 45),

    Position = UDim2.new(
        0,
        15,
        0,
        0
    ),

    BackgroundTransparency = 1,

    Text = "1tap Pack Farm",

    TextColor3 = WHITE,
    TextSize = 18,
    Font = Enum.Font.GothamBold,

    TextXAlignment =
        Enum.TextXAlignment.Left,

    ZIndex = 5
}, Main)

--==================================================
-- HIDE BUTTON
--==================================================

local HideButton = Create("TextButton", {

    Name = "HideButton",

    Size = UDim2.new(
        0,
        42,
        0,
        32
    ),

    Position = UDim2.new(
        1,
        -52,
        0,
        7
    ),

    BackgroundColor3 = BUTTON,

    BorderSizePixel = 0,

    Text = "—",

    TextColor3 = WHITE,
    TextSize = 18,
    Font = Enum.Font.GothamBold,

    AutoButtonColor = false,

    ZIndex = 150

}, Main)

Corner(HideButton, 7)

HideButton.MouseEnter:Connect(function()
    HideButton.BackgroundColor3 = HOVER
end)

HideButton.MouseLeave:Connect(function()
    HideButton.BackgroundColor3 = BUTTON
end)

--==================================================
-- MAIN DRAG BAR
--==================================================

local DragBar = Create("TextButton", {

    Name = "DragBar",

    Size = UDim2.new(
        1,
        -65,
        0,
        45
    ),

    Position = UDim2.new(
        0,
        0,
        0,
        0
    ),

    BackgroundTransparency = 1,

    BorderSizePixel = 0,

    Text = "",

    AutoButtonColor = false,

    Active = true,

    Selectable = false,

    ZIndex = 100

}, Main)

--==================================================
-- MAIN DRAG
--==================================================

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

    if Input.UserInputType ~=
        Enum.UserInputType.MouseMovement then
        return
    end

    local MousePosition =
        UserInputService:GetMouseLocation()

    local Delta =
        MousePosition - MainDragStart

    Main.Position = UDim2.new(

        MainStartPosition.X.Scale,

        MainStartPosition.X.Offset
            + Delta.X,

        MainStartPosition.Y.Scale,

        MainStartPosition.Y.Offset
            + Delta.Y

    )

end)

UserInputService.InputEnded:Connect(function(Input)

    if Input.UserInputType ==
        Enum.UserInputType.MouseButton1 then

        MainDragging = false

    end

end)

--==================================================
-- SIDEBAR
--==================================================

local Sidebar = Create("Frame", {

    Name = "Sidebar",

    Size = UDim2.new(
        0,
        145,
        1,
        -55
    ),

    Position = UDim2.new(
        0,
        10,
        0,
        50
    ),

    BackgroundColor3 = SIDEBAR,

    BorderSizePixel = 0,

    Active = true,

    ZIndex = 2

}, Main)

Corner(Sidebar, 9)

--==================================================
-- CONTENT
--==================================================

local Content = Create("Frame", {

    Name = "Content",

    Size = UDim2.new(
        1,
        -170,
        1,
        -55
    ),

    Position = UDim2.new(
        0,
        160,
        0,
        50
    ),

    BackgroundColor3 = PANEL,

    BorderSizePixel = 0,

    ZIndex = 2

}, Main)

Corner(Content, 9)

--==================================================
-- TABS
--==================================================

local function CreateTab(Text, Y)

    local Button = Create("TextButton", {

        Size = UDim2.new(
            1,
            -16,
            0,
            42
        ),

        Position = UDim2.new(
            0,
            8,
            0,
            Y
        ),

        BackgroundColor3 = BUTTON,

        BorderSizePixel = 0,

        Text = Text,

        TextColor3 = GRAY,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,

        AutoButtonColor = false,

        ZIndex = 5

    }, Sidebar)

    Corner(Button, 7)

    return Button
end

local FarmTab =
    CreateTab("Farm", 12)

local SettingsTab =
    CreateTab("Settings", 62)

local LogsTab =
    CreateTab("Logs", 112)

--==================================================
-- PAGES
--==================================================

local FarmPage = Create("Frame", {

    Size = UDim2.new(
        1,
        -20,
        1,
        -20
    ),

    Position = UDim2.new(
        0,
        10,
        0,
        10
    ),

    BackgroundTransparency = 1,

    ZIndex = 3

}, Content)

local SettingsPage = Create("Frame", {

    Size = UDim2.new(
        1,
        -20,
        1,
        -20
    ),

    Position = UDim2.new(
        0,
        10,
        0,
        10
    ),

    BackgroundTransparency = 1,

    Visible = false,

    ZIndex = 3

}, Content)

local LogsPage = Create("Frame", {

    Size = UDim2.new(
        1,
        -20,
        1,
        -20
    ),

    Position = UDim2.new(
        0,
        10,
        0,
        10
    ),

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
-- FARM TITLE
--==================================================

Create("TextLabel", {

    Size = UDim2.new(
        1,
        0,
        0,
        30
    ),

    BackgroundTransparency = 1,

    Text = "Pack Farm",

    TextColor3 = WHITE,
    TextSize = 18,
    Font = Enum.Font.GothamBold,

    TextXAlignment =
        Enum.TextXAlignment.Left,

    ZIndex = 5

}, FarmPage)

--==================================================
-- START BUTTON
--==================================================

local StartButton = Create("TextButton", {

    Size = UDim2.new(
        1,
        0,
        0,
        45
    ),

    Position = UDim2.new(
        0,
        0,
        0,
        40
    ),

    BackgroundColor3 = GREEN,

    BorderSizePixel = 0,

    Text = "START FARM",

    TextColor3 =
        Color3.fromRGB(
            10,
            10,
            10
        ),

    TextSize = 14,

    Font = Enum.Font.GothamBold,

    AutoButtonColor = false,

    ZIndex = 5

}, FarmPage)

Corner(StartButton, 8)

--==================================================
-- TOGGLES
--==================================================

local ToggleStates = {}

local function CreateToggle(Text, Y)

    local Button = Create("TextButton", {

        Size = UDim2.new(
            1,
            0,
            0,
            38
        ),

        Position = UDim2.new(
            0,
            0,
            0,
            Y
        ),

        BackgroundColor3 = BUTTON,

        BorderSizePixel = 0,

        Text = "",

        AutoButtonColor = false,

        ZIndex = 5

    }, FarmPage)

    Corner(Button, 7)

    Create("TextLabel", {

        Size = UDim2.new(
            1,
            -65,
            1,
            0
        ),

        Position = UDim2.new(
            0,
            12,
            0,
            0
        ),

        BackgroundTransparency = 1,

        Text = Text,

        TextColor3 = WHITE,

        TextSize = 13,

        Font = Enum.Font.GothamMedium,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        ZIndex = 6

    }, Button)

    local Indicator = Create("TextLabel", {

        Size = UDim2.new(
            0,
            45,
            0,
            25
        ),

        Position = UDim2.new(
            1,
            -55,
            0.5,
            -12
        ),

        BackgroundColor3 =
            Color3.fromRGB(
                55,
                55,
                65
            ),

        BorderSizePixel = 0,

        Text = "OFF",

        TextColor3 = GRAY,

        TextSize = 11,

        Font = Enum.Font.GothamBold,

        ZIndex = 6

    }, Button)

    Corner(Indicator, 6)

    ToggleStates[Text] = false

    Button.MouseButton1Click:Connect(function()

        ToggleStates[Text] =
            not ToggleStates[Text]

        if ToggleStates[Text] then

            Indicator.Text = "ON"

            Indicator.TextColor3 =
                GREEN

            Indicator.BackgroundColor3 =
                Color3.fromRGB(
                    35,
                    75,
                    45
                )

        else

            Indicator.Text = "OFF"

            Indicator.TextColor3 =
                GRAY

            Indicator.BackgroundColor3 =
                Color3.fromRGB(
                    55,
                    55,
                    65
                )

        end

    end)

    return Button
end

CreateToggle(
    "Titan Slayer Pack",
    98
)

CreateToggle(
    "Chain Devil Pack",
    142
)

CreateToggle(
    "Soccer Pack",
    186
)

CreateToggle(
    "Eternity Pack",
    230
)

CreateToggle(
    "Event 2 Pack",
    274
)

--==================================================
-- LOGS
--==================================================

Create("TextLabel", {

    Size = UDim2.new(
        1,
        -100,
        0,
        30
    ),

    BackgroundTransparency = 1,

    Text = "Logs",

    TextColor3 = WHITE,

    TextSize = 18,

    Font = Enum.Font.GothamBold,

    TextXAlignment =
        Enum.TextXAlignment.Left,

    ZIndex = 5

}, LogsPage)

local ClearLogsButton = Create("TextButton", {

    Size = UDim2.new(
        0,
        85,
        0,
        30
    ),

    Position = UDim2.new(
        1,
        -85,
        0,
        0
    ),

    BackgroundColor3 = BUTTON,

    BorderSizePixel = 0,

    Text = "Clear",

    TextColor3 = WHITE,

    TextSize = 12,

    Font = Enum.Font.GothamMedium,

    AutoButtonColor = false,

    ZIndex = 5

}, LogsPage)

Corner(ClearLogsButton, 6)

local LogFrame = Create("ScrollingFrame", {

    Size = UDim2.new(
        1,
        0,
        1,
        -42
    ),

    Position = UDim2.new(
        0,
        0,
        0,
        42
    ),

    BackgroundColor3 = BG,

    BorderSizePixel = 0,

    CanvasSize =
        UDim2.new(
            0,
            0,
            0,
            0
        ),

    AutomaticCanvasSize =
        Enum.AutomaticSize.Y,

    ScrollBarThickness = 4,

    ZIndex = 5

}, LogsPage)

Corner(LogFrame, 7)

local LogLayout = Create("UIListLayout", {

    Padding =
        UDim.new(0, 5),

    SortOrder =
        Enum.SortOrder.LayoutOrder

}, LogFrame)

local LogCount = 0

local function ClearLogs()

    for _, Child in ipairs(
        LogFrame:GetChildren()
    ) do

        if Child:IsA("TextLabel") then
            Child:Destroy()
        end

    end

    LogCount = 0
end

local function AddLog(Text)

    LogCount += 1

    local Label = Create("TextLabel", {

        Size = UDim2.new(
            1,
            -5,
            0,
            24
        ),

        BackgroundTransparency = 1,

        Text =
            "[" ..
            os.date("%H:%M:%S") ..
            "] " ..
            tostring(Text),

        TextColor3 = WHITE,

        TextSize = 12,

        Font = Enum.Font.Code,

        TextXAlignment =
            Enum.TextXAlignment.Left,

        LayoutOrder = LogCount,

        ZIndex = 6

    }, LogFrame)

    if string.find(
        Text,
        "ERROR"
    ) then

        Label.TextColor3 = RED

    elseif string.find(
        Text,
        "Buying"
    ) then

        Label.TextColor3 = YELLOW

    elseif string.find(
        Text,
        "ROLLED"
    ) then

        Label.TextColor3 = GREEN

    elseif string.find(
        Text,
        "Skip"
    ) then

        Label.TextColor3 = GRAY

    end

    if LogCount >= 8 then

        task.delay(
            0.05,
            function()

                if LogCount >= 8 then
                    ClearLogs()
                end

            end
        )

    end

    task.defer(function()

        LogFrame.CanvasPosition =
            Vector2.new(
                0,
                math.max(
                    0,
                    LogFrame.AbsoluteCanvasSize.Y
                )
            )

    end)
end

ClearLogsButton.MouseButton1Click:Connect(
    ClearLogs
)

--==================================================
-- SETTINGS
--==================================================

Create("TextLabel", {

    Size = UDim2.new(
        1,
        0,
        0,
        30
    ),

    BackgroundTransparency = 1,

    Text = "Settings",

    TextColor3 = WHITE,

    TextSize = 18,

    Font = Enum.Font.GothamBold,

    TextXAlignment =
        Enum.TextXAlignment.Left,

    ZIndex = 5

}, SettingsPage)

--==================================================
-- DELAY
--==================================================

local DelayLabel = Create("TextLabel", {

    Size = UDim2.new(
        1,
        0,
        0,
        35
    ),

    Position = UDim2.new(
        0,
        0,
        0,
        45
    ),

    BackgroundTransparency = 1,

    Text = "Delay: 1.5s",

    TextColor3 = WHITE,

    TextSize = 14,

    Font = Enum.Font.GothamMedium,

    TextXAlignment =
        Enum.TextXAlignment.Left,

    ZIndex = 5

}, SettingsPage)

local MinusButton = Create("TextButton", {

    Size = UDim2.new(
        0,
        40,
        0,
        35
    ),

    Position = UDim2.new(
        1,
        -90,
        0,
        45
    ),

    BackgroundColor3 = BUTTON,

    BorderSizePixel = 0,

    Text = "-",

    TextColor3 = WHITE,

    TextSize = 18,

    Font = Enum.Font.GothamBold,

    AutoButtonColor = false,

    ZIndex = 5

}, SettingsPage)

Corner(MinusButton, 6)

local PlusButton = Create("TextButton", {

    Size = UDim2.new(
        0,
        40,
        0,
        35
    ),

    Position = UDim2.new(
        1,
        -45,
        0,
        45
    ),

    BackgroundColor3 = BUTTON,

    BorderSizePixel = 0,

    Text = "+",

    TextColor3 = WHITE,

    TextSize = 18,

    Font = Enum.Font.GothamBold,

    AutoButtonColor = false,

    ZIndex = 5

}, SettingsPage)

Corner(PlusButton, 6)

MinusButton.MouseButton1Click:Connect(function()

    Delay = math.max(
        0.1,
        Delay - 0.1
    )

    Delay =
        math.floor(
            Delay * 10 + 0.5
        ) / 10

    DelayLabel.Text =
        "Delay: " ..
        tostring(Delay) ..
        "s"

end)

PlusButton.MouseButton1Click:Connect(function()

    Delay += 0.1

    Delay =
        math.floor(
            Delay * 10 + 0.5
        ) / 10

    DelayLabel.Text =
        "Delay: " ..
        tostring(Delay) ..
        "s"

end)

--==================================================
-- ANTI AFK
--==================================================

local AntiAFKButton = Create("TextButton", {

    Size = UDim2.new(
        1,
        0,
        0,
        40
    ),

    Position = UDim2.new(
        0,
        0,
        0,
        100
    ),

    BackgroundColor3 = BUTTON,

    BorderSizePixel = 0,

    Text = "Anti-AFK: ON",

    TextColor3 = GREEN,

    TextSize = 13,

    Font = Enum.Font.GothamMedium,

    AutoButtonColor = false,

    ZIndex = 5

}, SettingsPage)

Corner(AntiAFKButton, 7)

AntiAFKButton.MouseButton1Click:Connect(function()

    AntiAFK = not AntiAFK

    if AntiAFK then

        AntiAFKButton.Text =
            "Anti-AFK: ON"

        AntiAFKButton.TextColor3 =
            GREEN

    else

        AntiAFKButton.Text =
            "Anti-AFK: OFF"

        AntiAFKButton.TextColor3 =
            GRAY

    end

end)

--==================================================
-- HIDE ICON
--==================================================

local ShowButton = Create("TextButton", {

    Name = "ShowButton",

    Size = UDim2.new(
        0,
        48,
        0,
        48
    ),

    -- giữa cạnh trái
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

Corner(ShowButton, 10)
Stroke(ShowButton)

--==================================================
-- SHOW ICON DRAG
--==================================================

local ShowDragging = false
local ShowDragStart
local ShowStartPosition

ShowButton.InputBegan:Connect(function(Input)

    if Input.UserInputType ==
        Enum.UserInputType.MouseButton1 then

        ShowDragging = true

        ShowDragStart =
            UserInputService:GetMouseLocation()

        ShowStartPosition =
            ShowButton.Position

    end

end)

UserInputService.InputChanged:Connect(function(Input)

    if not ShowDragging then
        return
    end

    if Input.UserInputType ~=
        Enum.UserInputType.MouseMovement then
        return
    end

    local MousePosition =
        UserInputService:GetMouseLocation()

    local Delta =
        MousePosition - ShowDragStart

    ShowButton.Position = UDim2.new(

        ShowStartPosition.X.Scale,

        ShowStartPosition.X.Offset
            + Delta.X,

        ShowStartPosition.Y.Scale,

        ShowStartPosition.Y.Offset
            + Delta.Y

    )

end)

UserInputService.InputEnded:Connect(function(Input)

    if Input.UserInputType ==
        Enum.UserInputType.MouseButton1 then

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
-- PACK CHECK
--==================================================

local function IsPackSelected(PackName)

    return ToggleStates[PackName] == true

end

--==================================================
-- BUY / ROLL
--==================================================

local function BuyAndRoll()

    local OfferCount =
        ToggleStates["Event 2 Pack"]
        and 2
        or 1

    local Success, Result = pcall(function()

        return RequestConveyorOffer:InvokeServer(
            OfferCount
        )

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

        local OfferId =
            Offer.OfferId

        local PackName =
            Offer.PackName

        local Mutation =
            Offer.Mutation

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

        PackName =
            tostring(PackName)

        --==================================================
        -- BUY SELECTED PACK
        --==================================================

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
-- FARM LOOP
--==================================================

local function StartFarm()

    if Running then
        return
    end

    Running = true

    StartButton.Text =
        "STOP FARM"

    StartButton.BackgroundColor3 =
        RED

    AddLog("Farm Started")

    task.spawn(function()

        while Running do

            local HasSelectedPack =

                IsPackSelected(
                    "Titan Slayer Pack"
                )

                or

                IsPackSelected(
                    "Chain Devil Pack"
                )

                or

                IsPackSelected(
                    "Soccer Pack"
                )

                or

                IsPackSelected(
                    "Eternity Pack"
                )

            if not HasSelectedPack then

                AddLog(
                    "ERROR: No Pack Selected"
                )

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

    StartButton.Text =
        "START FARM"

    StartButton.BackgroundColor3 =
        GREEN

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
-- ANTI AFK EVENT
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
-- DEFAULT PACK
--==================================================

ToggleStates["Titan Slayer Pack"] = true

do

    local Button =
        FarmPage:FindFirstChild(
            "Titan Slayer Pack",
            true
        )

    if Button then

        local Indicator =
            Button:FindFirstChildWhichIsA(
                "TextLabel"
            )

        if Indicator then

            Indicator.Text = "ON"

            Indicator.TextColor3 =
                GREEN

            Indicator.BackgroundColor3 =
                Color3.fromRGB(
                    35,
                    75,
                    45
                )

        end
    end
end

AddLog("Hub Loaded")
AddLog("Eternity Pack Added")
