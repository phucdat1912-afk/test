--==================================================
-- 1TAP PACK AUTO FARM
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
-- REMOVE OLD GUI
--==================================================

local Old = CoreGui:FindFirstChild("1tap_PackFarm")

if Old then
    Old:Destroy()
end

--==================================================
-- SETTINGS
--==================================================

local Running = false
local AntiAFK = true
local Delay = 1.5

local AllowedPacks = {
    ["HSR Pack"] = true,
    ["Eternity Pack"] = true
}

local Logs = {}

--==================================================
-- COLORS
--==================================================

local BG = Color3.fromRGB(18, 18, 22)
local SIDEBAR = Color3.fromRGB(14, 14, 18)
local PANEL = Color3.fromRGB(24, 24, 29)
local SELECTED = Color3.fromRGB(45, 45, 55)

local TEXT = Color3.fromRGB(235, 235, 240)
local SUBTEXT = Color3.fromRGB(145, 145, 155)
local GREEN = Color3.fromRGB(100, 220, 130)
local RED = Color3.fromRGB(230, 90, 90)

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "1tap_PackFarm"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
Gui.Parent = CoreGui

--==================================================
-- MAIN
--==================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 600, 0, 380)
Main.Position = UDim2.new(0.5, -300, 0.5, -190)
Main.BackgroundColor3 = BG
Main.BorderSizePixel = 0
Main.ZIndex = 1
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

--==================================================
-- SHOW HUB BUTTON
--==================================================

local ShowHubButton = Instance.new("TextButton")
ShowHubButton.Name = "ShowHubButton"
ShowHubButton.Size = UDim2.new(0, 75, 0, 35)
ShowHubButton.Position = UDim2.new(0, 15, 0.5, -18)
ShowHubButton.BackgroundColor3 = BG
ShowHubButton.BorderSizePixel = 0
ShowHubButton.Text = "1tap"
ShowHubButton.TextColor3 = TEXT
ShowHubButton.TextSize = 13
ShowHubButton.Font = Enum.Font.GothamBold
ShowHubButton.AutoButtonColor = false
ShowHubButton.Visible = false
ShowHubButton.ZIndex = 100
ShowHubButton.Parent = Gui

local ShowHubCorner = Instance.new("UICorner")
ShowHubCorner.CornerRadius = UDim.new(0, 8)
ShowHubCorner.Parent = ShowHubButton

--==================================================
-- HIDE / SHOW HUB
--==================================================

local HideHubButton = Instance.new("TextButton")
HideHubButton.Name = "HideHubButton"
HideHubButton.Size = UDim2.new(0, 32, 0, 32)
HideHubButton.Position = UDim2.new(1, -42, 0, 9)
HideHubButton.BackgroundColor3 = PANEL
HideHubButton.BorderSizePixel = 0
HideHubButton.Text = "—"
HideHubButton.TextColor3 = TEXT
HideHubButton.TextSize = 16
HideHubButton.Font = Enum.Font.GothamBold
HideHubButton.AutoButtonColor = false
HideHubButton.ZIndex = 20
HideHubButton.Parent = Main

local HideCorner = Instance.new("UICorner")
HideCorner.CornerRadius = UDim.new(0, 7)
HideCorner.Parent = HideHubButton

HideHubButton.MouseEnter:Connect(function()
    HideHubButton.BackgroundColor3 = SELECTED
end)

HideHubButton.MouseLeave:Connect(function()
    HideHubButton.BackgroundColor3 = PANEL
end)

HideHubButton.Activated:Connect(function()
    Main.Visible = false
    ShowHubButton.Visible = true
end)

ShowHubButton.MouseEnter:Connect(function()
    ShowHubButton.BackgroundColor3 = SELECTED
end)

ShowHubButton.MouseLeave:Connect(function()
    ShowHubButton.BackgroundColor3 = BG
end)

ShowHubButton.Activated:Connect(function()
    Main.Visible = true
    ShowHubButton.Visible = false
end)

--==================================================
-- SHOW BUTTON DRAG
--==================================================

local ShowDragging = false
local ShowDragStart
local ShowStartPosition

ShowHubButton.InputBegan:Connect(function(Input)

    if Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch then

        ShowDragging = true
        ShowDragStart = Input.Position
        ShowStartPosition = ShowHubButton.Position

    end

end)

UserInputService.InputChanged:Connect(function(Input)

    if not ShowDragging then
        return
    end

    if Input.UserInputType == Enum.UserInputType.MouseMovement
        or Input.UserInputType == Enum.UserInputType.Touch then

        local Delta = Input.Position - ShowDragStart

        ShowHubButton.Position = UDim2.new(
            ShowStartPosition.X.Scale,
            ShowStartPosition.X.Offset + Delta.X,
            ShowStartPosition.Y.Scale,
            ShowStartPosition.Y.Offset + Delta.Y
        )

    end

end)

UserInputService.InputEnded:Connect(function(Input)

    if Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch then

        ShowDragging = false

    end

end)

--==================================================
-- TOP BAR
--==================================================

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundTransparency = 1
TopBar.ZIndex = 5
TopBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "1tap"
Title.TextColor3 = TEXT
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 6
Title.Parent = TopBar

--==================================================
-- DRAG
--==================================================

local Dragging = false
local DragStart
local StartPosition

TopBar.InputBegan:Connect(function(Input)

    if Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch then

        Dragging = true
        DragStart = Input.Position
        StartPosition = Main.Position

    end

end)

UserInputService.InputChanged:Connect(function(Input)

    if not Dragging then
        return
    end

    if Input.UserInputType == Enum.UserInputType.MouseMovement
        or Input.UserInputType == Enum.UserInputType.Touch then

        local Delta = Input.Position - DragStart

        Main.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )

    end

end)

UserInputService.InputEnded:Connect(function(Input)

    if Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch then

        Dragging = false

    end

end)

--==================================================
-- SIDEBAR
--==================================================

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, -50)
Sidebar.Position = UDim2.new(0, 0, 0, 50)
Sidebar.BackgroundColor3 = SIDEBAR
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 10
Sidebar.Parent = Main

local Menu = Instance.new("TextLabel")
Menu.Size = UDim2.new(1, -20, 0, 25)
Menu.Position = UDim2.new(0, 10, 0, 12)
Menu.BackgroundTransparency = 1
Menu.Text = "MENU"
Menu.TextColor3 = SUBTEXT
Menu.TextSize = 10
Menu.Font = Enum.Font.GothamBold
Menu.TextXAlignment = Enum.TextXAlignment.Left
Menu.ZIndex = 11
Menu.Parent = Sidebar

--==================================================
-- CONTENT
--==================================================

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -150, 1, -50)
Content.Position = UDim2.new(0, 150, 0, 50)
Content.BackgroundColor3 = BG
Content.BorderSizePixel = 0
Content.ZIndex = 2
Content.Parent = Main

--==================================================
-- TAB SYSTEM
--==================================================

local Tabs = {}
local Pages = {}
local CurrentTab = nil

local function CreateTab(Name, Text, Y)

    local Button = Instance.new("TextButton")

    Button.Name = Name .. "Button"
    Button.Size = UDim2.new(1, -20, 0, 40)
    Button.Position = UDim2.new(0, 10, 0, Y)

    Button.BackgroundColor3 = SIDEBAR
    Button.BorderSizePixel = 0

    Button.Text = Text
    Button.TextColor3 = SUBTEXT
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamMedium
    Button.TextXAlignment = Enum.TextXAlignment.Left

    Button.AutoButtonColor = false
    Button.Active = true
    Button.Selectable = true
    Button.ZIndex = 20

    Button.Parent = Sidebar

    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 12)
    Padding.Parent = Button

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Button

    local Page = Instance.new("Frame")

    Page.Name = Name .. "Page"
    Page.Size = UDim2.new(1, -30, 1, -30)
    Page.Position = UDim2.new(0, 15, 0, 15)

    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.Visible = false
    Page.ZIndex = 5

    Page.Parent = Content

    Tabs[Name] = Button
    Pages[Name] = Page

    return Button, Page
end

local FarmButton, FarmPage =
    CreateTab("Farm", "  FARM", 45)

local SettingsButton, SettingsPage =
    CreateTab("Settings", "  SETTINGS", 90)

local LogsButton, LogsPage =
    CreateTab("Logs", "  LOGS", 135)

--==================================================
-- HELPERS
--==================================================

local function CreateLabel(Parent, Text, Position, Size)

    local Label = Instance.new("TextLabel")

    Label.Size = Size or UDim2.new(1, 0, 0, 30)
    Label.Position = Position or UDim2.new(0, 0, 0, 0)

    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = TEXT
    Label.TextSize = 16
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 6

    Label.Parent = Parent

    return Label
end

local function CreateButton(Parent, Text, Position, Size)

    local Button = Instance.new("TextButton")

    Button.Size = Size
    Button.Position = Position

    Button.BackgroundColor3 = PANEL
    Button.BorderSizePixel = 0

    Button.Text = Text
    Button.TextColor3 = TEXT
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamMedium

    Button.AutoButtonColor = false
    Button.Active = true
    Button.Selectable = true
    Button.ZIndex = 10

    Button.Parent = Parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Button

    return Button
end

--==================================================
-- FARM PAGE
--==================================================

CreateLabel(
    FarmPage,
    "Pack Auto Farm",
    UDim2.new(0, 0, 0, 0),
    UDim2.new(1, 0, 0, 35)
)

local FarmStatus = CreateLabel(
    FarmPage,
    "Status: STOPPED",
    UDim2.new(0, 0, 0, 45),
    UDim2.new(1, 0, 0, 30)
)

FarmStatus.TextColor3 = RED

local StartButton = CreateButton(
    FarmPage,
    "START",
    UDim2.new(0, 0, 0, 85),
    UDim2.new(0, 125, 0, 38)
)

local StopButton = CreateButton(
    FarmPage,
    "STOP",
    UDim2.new(0, 135, 0, 85),
    UDim2.new(0, 125, 0, 38)
)

CreateLabel(
    FarmPage,
    "Allowed Packs",
    UDim2.new(0, 0, 0, 140),
    UDim2.new(1, 0, 0, 25)
)

local HSRButton = CreateButton(
    FarmPage,
    "HSR Pack: ON",
    UDim2.new(0, 0, 0, 170),
    UDim2.new(0, 180, 0, 38)
)

local EternityButton = CreateButton(
    FarmPage,
    "Eternity Pack: ON",
    UDim2.new(0, 190, 0, 170),
    UDim2.new(0, 180, 0, 38)
)

--==================================================
-- SETTINGS PAGE
--==================================================

CreateLabel(
    SettingsPage,
    "Settings",
    UDim2.new(0, 0, 0, 0),
    UDim2.new(1, 0, 0, 35)
)

local DelayLabel = CreateLabel(
    SettingsPage,
    "Delay: 1.5",
    UDim2.new(0, 0, 0, 50),
    UDim2.new(1, 0, 0, 30)
)

local DelayMinus = CreateButton(
    SettingsPage,
    "-",
    UDim2.new(0, 0, 0, 90),
    UDim2.new(0, 50, 0, 35)
)

local DelayPlus = CreateButton(
    SettingsPage,
    "+",
    UDim2.new(0, 60, 0, 90),
    UDim2.new(0, 50, 0, 35)
)

local AFKButton = CreateButton(
    SettingsPage,
    "Anti-AFK: ON",
    UDim2.new(0, 0, 0, 140),
    UDim2.new(0, 180, 0, 38)
)

--==================================================
-- LOG PAGE
--==================================================

CreateLabel(
    LogsPage,
    "Logs",
    UDim2.new(0, 0, 0, 0),
    UDim2.new(1, 0, 0, 35)
)

local ClearLogsButton = CreateButton(
    LogsPage,
    "Clear Logs",
    UDim2.new(0, 350, 0, 0),
    UDim2.new(0, 100, 0, 32)
)

local LogContainer = Instance.new("Frame")
LogContainer.Size = UDim2.new(1, 0, 1, -50)
LogContainer.Position = UDim2.new(0, 0, 0, 45)
LogContainer.BackgroundColor3 = PANEL
LogContainer.BorderSizePixel = 0
LogContainer.ZIndex = 5
LogContainer.Parent = LogsPage

local LogCorner = Instance.new("UICorner")
LogCorner.CornerRadius = UDim.new(0, 8)
LogCorner.Parent = LogContainer

local LogLabels = {}

--==================================================
-- LOG FUNCTION
--==================================================

local function ClearLogs()

    Logs = {}

    for _, Label in ipairs(LogLabels) do

        if Label then
            Label:Destroy()
        end

    end

    LogLabels = {}

end

local function AddLog(Text)

    table.insert(Logs, Text)

    while #Logs > 5 do
        table.remove(Logs, 1)
    end

    for _, Label in ipairs(LogLabels) do

        if Label then
            Label:Destroy()
        end

    end

    LogLabels = {}

    for Index, Message in ipairs(Logs) do

        local Label = Instance.new("TextLabel")

        Label.Size = UDim2.new(1, -20, 0, 30)
        Label.Position = UDim2.new(0, 10, 0, (Index - 1) * 30)

        Label.BackgroundTransparency = 1
        Label.Text = Message
        Label.TextColor3 = TEXT
        Label.TextSize = 12
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.ZIndex = 6

        Label.Parent = LogContainer

        table.insert(LogLabels, Label)

    end
end

ClearLogsButton.Activated:Connect(function()
    ClearLogs()
end)

--==================================================
-- TAB SELECT
--==================================================

local function SelectTab(Name)

    if not Tabs[Name] then
        return
    end

    CurrentTab = Name

    for TabName, Button in pairs(Tabs) do

        if TabName == Name then

            Button.BackgroundColor3 = SELECTED
            Button.TextColor3 = TEXT

        else

            Button.BackgroundColor3 = SIDEBAR
            Button.TextColor3 = SUBTEXT

        end

    end

    for PageName, Page in pairs(Pages) do

        Page.Visible = PageName == Name

    end

end

FarmButton.Activated:Connect(function()
    SelectTab("Farm")
end)

SettingsButton.Activated:Connect(function()
    SelectTab("Settings")
end)

LogsButton.Activated:Connect(function()
    SelectTab("Logs")
end)

for Name, Button in pairs(Tabs) do

    Button.MouseEnter:Connect(function()

        if CurrentTab ~= Name then
            Button.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
        end

    end)

    Button.MouseLeave:Connect(function()

        if CurrentTab ~= Name then
            Button.BackgroundColor3 = SIDEBAR
        end

    end)

end

--==================================================
-- PACK TOGGLE
--==================================================

local function UpdatePackButtons()

    if AllowedPacks["HSR Pack"] then
        HSRButton.Text = "HSR Pack: ON"
    else
        HSRButton.Text = "HSR Pack: OFF"
    end

    if AllowedPacks["Eternity Pack"] then
        EternityButton.Text = "Eternity Pack: ON"
    else
        EternityButton.Text = "Eternity Pack: OFF"
    end

end

HSRButton.Activated:Connect(function()

    AllowedPacks["HSR Pack"] = not AllowedPacks["HSR Pack"]

    UpdatePackButtons()

    AddLog(
        "HSR Pack " ..
        (AllowedPacks["HSR Pack"] and "enabled" or "disabled")
    )

end)

EternityButton.Activated:Connect(function()

    AllowedPacks["Eternity Pack"] =
        not AllowedPacks["Eternity Pack"]

    UpdatePackButtons()

    AddLog(
        "Eternity Pack " ..
        (AllowedPacks["Eternity Pack"] and "enabled" or "disabled")
    )

end)

--==================================================
-- DELAY
--==================================================

DelayMinus.Activated:Connect(function()

    Delay = math.max(0.2, Delay - 0.1)

    Delay = math.floor(Delay * 10 + 0.5) / 10

    DelayLabel.Text = "Delay: " .. tostring(Delay)

end)

DelayPlus.Activated:Connect(function()

    Delay = Delay + 0.1

    Delay = math.floor(Delay * 10 + 0.5) / 10

    DelayLabel.Text = "Delay: " .. tostring(Delay)

end)

--==================================================
-- ANTI AFK
--==================================================

AFKButton.Activated:Connect(function()

    AntiAFK = not AntiAFK

    if AntiAFK then
        AFKButton.Text = "Anti-AFK: ON"
    else
        AFKButton.Text = "Anti-AFK: OFF"
    end

    AddLog(
        "Anti-AFK " ..
        (AntiAFK and "enabled" or "disabled")
    )

end)

Player.Idled:Connect(function()

    if AntiAFK then

        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))

    end

end)

--==================================================
-- BUY / ROLL
--==================================================

local function BuyAndRoll()

    local Success, Offers = pcall(function()

        return RequestConveyorOffer:InvokeServer(1)

    end)

    if not Success then

        AddLog("Request offer failed")
        return

    end

    if type(Offers) ~= "table" then

        AddLog("No offers returned")
        return

    end

    local Bought = false

    for _, Offer in pairs(Offers) do

        if type(Offer) == "table" then

            local PackName = Offer.PackName
            local Mutation = Offer.Mutation
            local OfferId = Offer.OfferId

            if PackName
                and Mutation
                and OfferId
                and AllowedPacks[PackName] then

                local BuySuccess = pcall(function()

                    BuyPack:FireServer(
                        PackName,
                        Mutation,
                        OfferId
                    )

                end)

                if BuySuccess then

                    AddLog(
                        "Bought: " ..
                        tostring(PackName)
                    )

                    task.wait(0.5)

                    pcall(function()

                        SetRecoverPack:FireServer(
                            OfferId
                        )

                    end)

                    AddLog(
                        "Recover: " ..
                        tostring(PackName)
                    )

                    Bought = true

                    break

                else

                    AddLog(
                        "Buy failed: " ..
                        tostring(PackName)
                    )

                end

            end

        end

    end

    if not Bought then
        AddLog("No selected pack found")
    end

end

--==================================================
-- START / STOP
--==================================================

StartButton.Activated:Connect(function()

    if Running then
        return
    end

    Running = true

    FarmStatus.Text = "Status: RUNNING"
    FarmStatus.TextColor3 = GREEN

    AddLog("Auto Farm started")

end)

StopButton.Activated:Connect(function()

    if not Running then
        return
    end

    Running = false

    FarmStatus.Text = "Status: STOPPED"
    FarmStatus.TextColor3 = RED

    AddLog("Auto Farm stopped")

end)

--==================================================
-- AUTO FARM LOOP
--==================================================

task.spawn(function()

    while Gui.Parent do

        if Running then

            BuyAndRoll()

            task.wait(Delay)

        else

            task.wait(0.2)

        end

    end

end)

--==================================================
-- DEFAULT
--==================================================

UpdatePackButtons()
SelectTab("Farm")

AddLog("1tap Pack Farm loaded")
