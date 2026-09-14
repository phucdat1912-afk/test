--==================================================
-- 1TAP PACK AUTO FARM
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local RequestConveyorOffer = Remotes:WaitForChild("RequestConveyorOffer")
local BuyPack = Remotes:WaitForChild("BuyPack")
local SetRecoverPack = Remotes:WaitForChild("SetRecoverPack")

--==================================================
-- SETTINGS
--==================================================

local Running = false
local Delay = 1.5
local AntiAFK = true

local AllowedPacks = {
    ["HSR Pack"] = true,
    ["Eternity Pack"] = true
}

local MAX_LOGS = 5

--==================================================
-- ANTI AFK
--==================================================

Player.Idled:Connect(function()
    if AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end
end)

--==================================================
-- GUI CLEANUP
--==================================================

local CoreGui = game:GetService("CoreGui")

local OldGui = CoreGui:FindFirstChild("1tap")

if OldGui then
    OldGui:Destroy()
end

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "1tap"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = CoreGui

--==================================================
-- COLORS
--==================================================

local BG = Color3.fromRGB(18, 18, 22)
local SIDEBAR = Color3.fromRGB(14, 14, 18)
local PANEL = Color3.fromRGB(24, 24, 29)
local PANEL2 = Color3.fromRGB(30, 30, 36)
local BUTTON = Color3.fromRGB(36, 36, 43)

local TEXT = Color3.fromRGB(235, 235, 240)
local SUBTEXT = Color3.fromRGB(145, 145, 155)

local ACCENT = Color3.fromRGB(120, 90, 255)
local GREEN = Color3.fromRGB(65, 190, 105)
local RED = Color3.fromRGB(210, 65, 75)

--==================================================
-- MAIN
--==================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 650, 0, 430)
Main.Position = UDim2.new(0.5, -325, 0.5, -215)
Main.BackgroundColor3 = BG
Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

--==================================================
-- TOP BAR
--==================================================

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundTransparency = 1
TopBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 100, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "1tap"
Title.TextColor3 = TEXT
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(0, 150, 1, 0)
SubTitle.Position = UDim2.new(0, 62, 0, 0)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "AUTO FARM"
SubTitle.TextColor3 = ACCENT
SubTitle.TextSize = 10
SubTitle.Font = Enum.Font.GothamBold
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = TopBar

--==================================================
-- MINIMIZE
--==================================================

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 35, 0, 35)
Minimize.Position = UDim2.new(1, -75, 0, 5)
Minimize.BackgroundColor3 = BUTTON
Minimize.Text = "—"
Minimize.TextColor3 = TEXT
Minimize.TextSize = 18
Minimize.Font = Enum.Font.GothamBold
Minimize.AutoButtonColor = false
Minimize.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 7)
MinCorner.Parent = Minimize

--==================================================
-- CLOSE
--==================================================

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 35, 0, 35)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.BackgroundColor3 = BUTTON
Close.Text = "×"
Close.TextColor3 = TEXT
Close.TextSize = 20
Close.Font = Enum.Font.GothamBold
Close.AutoButtonColor = false
Close.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 7)
CloseCorner.Parent = Close

--==================================================
-- SIDEBAR
--==================================================

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 145, 1, -45)
Sidebar.Position = UDim2.new(0, 0, 0, 45)
Sidebar.BackgroundColor3 = SIDEBAR
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 10)
SidebarCorner.Parent = Sidebar

local MenuTitle = Instance.new("TextLabel")
MenuTitle.Size = UDim2.new(1, -20, 0, 25)
MenuTitle.Position = UDim2.new(0, 10, 0, 15)
MenuTitle.BackgroundTransparency = 1
MenuTitle.Text = "MENU"
MenuTitle.TextColor3 = SUBTEXT
MenuTitle.TextSize = 10
MenuTitle.Font = Enum.Font.GothamBold
MenuTitle.TextXAlignment = Enum.TextXAlignment.Left
MenuTitle.Parent = Sidebar

--==================================================
-- CONTENT
--==================================================

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -145, 1, -45)
Content.Position = UDim2.new(0, 145, 0, 45)
Content.BackgroundTransparency = 1
Content.Parent = Main

--==================================================
-- TAB SYSTEM
--==================================================

local Tabs = {}
local Pages = {}
local CurrentTab

local function CreateTab(Name, Text, Y)

    local Button = Instance.new("TextButton")
    Button.Name = Name .. "Tab"
    Button.Size = UDim2.new(1, -20, 0, 38)
    Button.Position = UDim2.new(0, 10, 0, Y)
    Button.BackgroundColor3 = SIDEBAR
    Button.BorderSizePixel = 0
    Button.Text = Text
    Button.TextColor3 = SUBTEXT
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamMedium
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.AutoButtonColor = false
    Button.Parent = Sidebar

    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 12)
    Padding.Parent = Button

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Button

    local Page = Instance.new("Frame")
    Page.Name = Name .. "Page"
    Page.Size = UDim2.new(1, -30, 1, -25)
    Page.Position = UDim2.new(0, 15, 0, 15)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.Parent = Content

    Tabs[Name] = Button
    Pages[Name] = Page

    return Button, Page
end

local FarmTab, FarmPage =
    CreateTab("Farm", "  Farm", 50)

local SettingsTab, SettingsPage =
    CreateTab("Settings", "  Settings", 95)

local LogsTab, LogsPage =
    CreateTab("Logs", "  Logs", 140)

local function SelectTab(Name)

    if not Tabs[Name] then
        return
    end

    CurrentTab = Name

    for TabName, Button in pairs(Tabs) do

        if TabName == Name then
            Button.BackgroundColor3 = PANEL2
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

FarmTab.MouseButton1Click:Connect(function()
    SelectTab("Farm")
end)

SettingsTab.MouseButton1Click:Connect(function()
    SelectTab("Settings")
end)

LogsTab.MouseButton1Click:Connect(function()
    SelectTab("Logs")
end)

for Name, Button in pairs(Tabs) do

    Button.MouseEnter:Connect(function()

        if CurrentTab ~= Name then
            Button.BackgroundColor3 = BUTTON
        end

    end)

    Button.MouseLeave:Connect(function()

        if CurrentTab ~= Name then
            Button.BackgroundColor3 = SIDEBAR
        end

    end)

end

--==================================================
-- FARM PAGE
--==================================================

local FarmTitle = Instance.new("TextLabel")
FarmTitle.Size = UDim2.new(1, 0, 0, 30)
FarmTitle.BackgroundTransparency = 1
FarmTitle.Text = "Pack Farm"
FarmTitle.TextColor3 = TEXT
FarmTitle.TextSize = 20
FarmTitle.Font = Enum.Font.GothamBold
FarmTitle.TextXAlignment = Enum.TextXAlignment.Left
FarmTitle.Parent = FarmPage

local FarmDescription = Instance.new("TextLabel")
FarmDescription.Size = UDim2.new(1, 0, 0, 25)
FarmDescription.Position = UDim2.new(0, 0, 0, 30)
FarmDescription.BackgroundTransparency = 1
FarmDescription.Text = "Automatically buy and recover selected packs."
FarmDescription.TextColor3 = SUBTEXT
FarmDescription.TextSize = 12
FarmDescription.Font = Enum.Font.Gotham
FarmDescription.TextXAlignment = Enum.TextXAlignment.Left
FarmDescription.Parent = FarmPage

--==================================================
-- STATUS
--==================================================

local StatusCard = Instance.new("Frame")
StatusCard.Size = UDim2.new(1, 0, 0, 75)
StatusCard.Position = UDim2.new(0, 0, 0, 70)
StatusCard.BackgroundColor3 = PANEL
StatusCard.BorderSizePixel = 0
StatusCard.Parent = FarmPage

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusCard

local StatusTitle = Instance.new("TextLabel")
StatusTitle.Size = UDim2.new(0.5, 0, 0, 20)
StatusTitle.Position = UDim2.new(0, 15, 0, 9)
StatusTitle.BackgroundTransparency = 1
StatusTitle.Text = "STATUS"
StatusTitle.TextColor3 = SUBTEXT
StatusTitle.TextSize = 10
StatusTitle.Font = Enum.Font.GothamBold
StatusTitle.TextXAlignment = Enum.TextXAlignment.Left
StatusTitle.Parent = StatusCard

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0.5, 0, 0, 25)
Status.Position = UDim2.new(0, 15, 0, 31)
Status.BackgroundTransparency = 1
Status.Text = "●  OFF"
Status.TextColor3 = RED
Status.TextSize = 14
Status.Font = Enum.Font.GothamBold
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = StatusCard

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0, 125, 0, 42)
Toggle.Position = UDim2.new(1, -140, 0.5, -21)
Toggle.BackgroundColor3 = BUTTON
Toggle.Text = "START"
Toggle.TextColor3 = TEXT
Toggle.TextSize = 13
Toggle.Font = Enum.Font.GothamBold
Toggle.AutoButtonColor = false
Toggle.Parent = StatusCard

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 7)
ToggleCorner.Parent = Toggle

--==================================================
-- PACK FILTER
--==================================================

local PackTitle = Instance.new("TextLabel")
PackTitle.Size = UDim2.new(1, 0, 0, 25)
PackTitle.Position = UDim2.new(0, 0, 0, 160)
PackTitle.BackgroundTransparency = 1
PackTitle.Text = "PACK FILTER"
PackTitle.TextColor3 = SUBTEXT
PackTitle.TextSize = 11
PackTitle.Font = Enum.Font.GothamBold
PackTitle.TextXAlignment = Enum.TextXAlignment.Left
PackTitle.Parent = FarmPage

local function CreatePackButton(Text, PackName, X)

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.5, -7, 0, 55)
    Button.Position = UDim2.new(X, 0, 0, 190)
    Button.BackgroundColor3 = PANEL
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = FarmPage

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 25)
    Label.Position = UDim2.new(0, 10, 0, 7)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = TEXT
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Button

    local State = Instance.new("TextLabel")
    State.Size = UDim2.new(1, -20, 0, 18)
    State.Position = UDim2.new(0, 10, 0, 31)
    State.BackgroundTransparency = 1
    State.Text = "● ENABLED"
    State.TextColor3 = GREEN
    State.TextSize = 10
    State.Font = Enum.Font.GothamMedium
    State.TextXAlignment = Enum.TextXAlignment.Left
    State.Parent = Button

    Button.MouseButton1Click:Connect(function()

        AllowedPacks[PackName] =
            not AllowedPacks[PackName]

        if AllowedPacks[PackName] then

            State.Text = "● ENABLED"
            State.TextColor3 = GREEN

        else

            State.Text = "● DISABLED"
            State.TextColor3 = RED

        end

    end)

end

CreatePackButton("HSR Pack", "HSR Pack", 0)
CreatePackButton("Eternity Pack", "Eternity Pack", 0.5)

--==================================================
-- SETTINGS PAGE
--==================================================

local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Size = UDim2.new(1, 0, 0, 30)
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Text = "Settings"
SettingsTitle.TextColor3 = TEXT
SettingsTitle.TextSize = 20
SettingsTitle.Font = Enum.Font.GothamBold
SettingsTitle.TextXAlignment = Enum.TextXAlignment.Left
SettingsTitle.Parent = SettingsPage

local DelayLabel = Instance.new("TextLabel")
DelayLabel.Size = UDim2.new(1, 0, 0, 25)
DelayLabel.Position = UDim2.new(0, 0, 0, 55)
DelayLabel.BackgroundTransparency = 1
DelayLabel.Text = "Farm Delay"
DelayLabel.TextColor3 = TEXT
DelayLabel.TextSize = 13
DelayLabel.Font = Enum.Font.GothamBold
DelayLabel.TextXAlignment = Enum.TextXAlignment.Left
DelayLabel.Parent = SettingsPage

local DelayDescription = Instance.new("TextLabel")
DelayDescription.Size = UDim2.new(1, 0, 0, 20)
DelayDescription.Position = UDim2.new(0, 0, 0, 78)
DelayDescription.BackgroundTransparency = 1
DelayDescription.Text = "Time between each farm cycle."
DelayDescription.TextColor3 = SUBTEXT
DelayDescription.TextSize = 11
DelayDescription.Font = Enum.Font.Gotham
DelayDescription.TextXAlignment = Enum.TextXAlignment.Left
DelayDescription.Parent = SettingsPage

local DelayBox = Instance.new("TextBox")
DelayBox.Size = UDim2.new(0, 130, 0, 38)
DelayBox.Position = UDim2.new(0, 0, 0, 105)
DelayBox.BackgroundColor3 = PANEL
DelayBox.BorderSizePixel = 0
DelayBox.Text = tostring(Delay)
DelayBox.TextColor3 = TEXT
DelayBox.TextSize = 13
DelayBox.Font = Enum.Font.Gotham
DelayBox.ClearTextOnFocus = false
DelayBox.Parent = SettingsPage

local DelayCorner = Instance.new("UICorner")
DelayCorner.CornerRadius = UDim.new(0, 7)
DelayCorner.Parent = DelayBox

DelayBox.FocusLost:Connect(function()

    local Value = tonumber(DelayBox.Text)

    if Value and Value >= 0 then
        Delay = Value
    else
        DelayBox.Text = tostring(Delay)
    end

end)

--==================================================
-- ANTI AFK SETTING
--==================================================

local AFKButton = Instance.new("TextButton")
AFKButton.Size = UDim2.new(1, 0, 0, 55)
AFKButton.Position = UDim2.new(0, 0, 0, 165)
AFKButton.BackgroundColor3 = PANEL
AFKButton.BorderSizePixel = 0
AFKButton.Text = ""
AFKButton.AutoButtonColor = false
AFKButton.Parent = SettingsPage

local AFKCorner = Instance.new("UICorner")
AFKCorner.CornerRadius = UDim.new(0, 8)
AFKCorner.Parent = AFKButton

local AFKLabel = Instance.new("TextLabel")
AFKLabel.Size = UDim2.new(0.6, 0, 0, 25)
AFKLabel.Position = UDim2.new(0, 12, 0, 7)
AFKLabel.BackgroundTransparency = 1
AFKLabel.Text = "Anti-AFK"
AFKLabel.TextColor3 = TEXT
AFKLabel.TextSize = 13
AFKLabel.Font = Enum.Font.GothamBold
AFKLabel.TextXAlignment = Enum.TextXAlignment.Left
AFKLabel.Parent = AFKButton

local AFKState = Instance.new("TextLabel")
AFKState.Size = UDim2.new(0.6, 0, 0, 18)
AFKState.Position = UDim2.new(0, 12, 0, 31)
AFKState.BackgroundTransparency = 1
AFKState.Text = "● ENABLED"
AFKState.TextColor3 = GREEN
AFKState.TextSize = 10
AFKState.Font = Enum.Font.GothamMedium
AFKState.TextXAlignment = Enum.TextXAlignment.Left
AFKState.Parent = AFKButton

AFKButton.MouseButton1Click:Connect(function()

    AntiAFK = not AntiAFK

    if AntiAFK then

        AFKState.Text = "● ENABLED"
        AFKState.TextColor3 = GREEN

    else

        AFKState.Text = "● DISABLED"
        AFKState.TextColor3 = RED

    end

end)

--==================================================
-- LOG PAGE
--==================================================

local LogsTitle = Instance.new("TextLabel")
LogsTitle.Size = UDim2.new(1, 0, 0, 30)
LogsTitle.BackgroundTransparency = 1
LogsTitle.Text = "Activity Logs"
LogsTitle.TextColor3 = TEXT
LogsTitle.TextSize = 20
LogsTitle.Font = Enum.Font.GothamBold
LogsTitle.TextXAlignment = Enum.TextXAlignment.Left
LogsTitle.Parent = LogsPage

local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Size = UDim2.new(1, 0, 0, 275)
LogFrame.Position = UDim2.new(0, 0, 0, 45)
LogFrame.BackgroundColor3 = PANEL
LogFrame.BorderSizePixel = 0
LogFrame.ScrollBarThickness = 4
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogFrame.Parent = LogsPage

local LogCorner = Instance.new("UICorner")
LogCorner.CornerRadius = UDim.new(0, 8)
LogCorner.Parent = LogFrame

local LogText = Instance.new("TextLabel")
LogText.Size = UDim2.new(1, -20, 0, 0)
LogText.Position = UDim2.new(0, 10, 0, 10)
LogText.BackgroundTransparency = 1
LogText.Text = ""
LogText.TextColor3 = TEXT
LogText.TextSize = 11
LogText.Font = Enum.Font.Code
LogText.TextXAlignment = Enum.TextXAlignment.Left
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.TextWrapped = true
LogText.AutomaticSize = Enum.AutomaticSize.Y
LogText.Parent = LogFrame

local ClearButton = Instance.new("TextButton")
ClearButton.Size = UDim2.new(0, 120, 0, 35)
ClearButton.Position = UDim2.new(1, -120, 1, -40)
ClearButton.BackgroundColor3 = BUTTON
ClearButton.BorderSizePixel = 0
ClearButton.Text = "CLEAR LOG"
ClearButton.TextColor3 = TEXT
ClearButton.TextSize = 11
ClearButton.Font = Enum.Font.GothamBold
ClearButton.AutoButtonColor = false
ClearButton.Parent = LogsPage

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 7)
ClearCorner.Parent = ClearButton

--==================================================
-- LOG SYSTEM
--==================================================

local Logs = {}

local function RefreshLog()

    LogText.Text = table.concat(Logs, "\n")

    task.defer(function()

        local Height = LogText.AbsoluteSize.Y + 20

        LogFrame.CanvasSize = UDim2.new(
            0,
            0,
            0,
            Height
        )

        LogFrame.CanvasPosition = Vector2.new(
            0,
            math.max(
                0,
                Height - LogFrame.AbsoluteSize.Y
            )
        )

    end)

end

local function ClearLogs()

    table.clear(Logs)

    LogText.Text = ""

    LogFrame.CanvasSize =
        UDim2.new(0, 0, 0, 0)

    LogFrame.CanvasPosition =
        Vector2.new(0, 0)

end

local function AddLog(Message)

    if #Logs >= MAX_LOGS then
        ClearLogs()
    end

    local Time = os.date("%H:%M:%S")

    table.insert(
        Logs,
        "[" .. Time .. "] " .. tostring(Message)
    )

    RefreshLog()

end

ClearButton.MouseButton1Click:Connect(function()
    ClearLogs()
end)

--==================================================
-- BUY + ROLL
--==================================================

local function BuyAndRoll()

    local Success, Result = pcall(function()

        return RequestConveyorOffer:InvokeServer(1)

    end)

    if not Success or typeof(Result) ~= "table" then

        AddLog("ERROR: Cannot get offer")

        return

    end

    for _, Offer in pairs(Result) do

        if typeof(Offer) ~= "table" then
            continue
        end

        local OfferId = Offer.OfferId
        local PackName = Offer.PackName
        local Mutation = Offer.Mutation

        AddLog(
            "Offer: "
            .. tostring(PackName)
            .. " | "
            .. tostring(Mutation)
        )

        if AllowedPacks[PackName] then

            AddLog(
                "Buying: "
                .. tostring(PackName)
            )

            local BuySuccess = pcall(function()

                BuyPack:FireServer(
                    PackName,
                    Mutation,
                    OfferId
                )

            end)

            if not BuySuccess then

                AddLog("ERROR: BuyPack")

                return

            end

            AddLog(
                "Bought: "
                .. tostring(PackName)
            )

            task.wait(0.5)

            local RollSuccess = pcall(function()

                SetRecoverPack:FireServer(
                    OfferId
                )

            end)

            if RollSuccess then

                AddLog(
                    "ROLLED: "
                    .. tostring(PackName)
                    .. " | "
                    .. tostring(Mutation)
                )

            else

                AddLog(
                    "ERROR: SetRecoverPack"
                )

            end

            return

        end

    end

    AddLog(
        "Skipped: No selected pack"
    )

end

--==================================================
-- FARM LOOP
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
-- START / STOP
--==================================================

Toggle.MouseButton1Click:Connect(function()

    Running = not Running

    if Running then

        Toggle.Text = "STOP"
        Toggle.BackgroundColor3 = RED

        Status.Text = "●  RUNNING"
        Status.TextColor3 = GREEN

        AddLog("Auto Farm STARTED")

    else

        Toggle.Text = "START"
        Toggle.BackgroundColor3 = BUTTON

        Status.Text = "●  OFF"
        Status.TextColor3 = RED

        AddLog("Auto Farm STOPPED")

    end

end)

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

--==================================================
-- MINIMIZE
--==================================================

local Minimized = false

Minimize.MouseButton1Click:Connect(function()

    Minimized = not Minimized

    Sidebar.Visible = not Minimized
    Content.Visible = not Minimized

    if Minimized then

        Main.Size = UDim2.new(
            0,
            650,
            0,
            45
        )

    else

        Main.Size = UDim2.new(
            0,
            650,
            0,
            430
        )

    end

end)

--==================================================
-- CLOSE
--==================================================

Close.MouseButton1Click:Connect(function()

    Running = false
    Gui:Destroy()

end)

--==================================================
-- STARTUP
--==================================================

SelectTab("Farm")

AddLog("1tap loaded")
AddLog("Anti-AFK: Enabled")
