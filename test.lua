--==================================================
-- PACK AUTO FARM - OUROBOROS STYLE UI
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

local AllowedPacks = {
    ["HSR Pack"] = true,
    ["Eternity Pack"] = true
}

local AntiAFK = true

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
-- GUI
--==================================================

local CoreGui = game:GetService("CoreGui")

local OldGui = CoreGui:FindFirstChild("OuroborosPackFarm")
if OldGui then
    OldGui:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "OuroborosPackFarm"
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
Title.Size = UDim2.new(0, 220, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "OUROBOROS"
Title.TextColor3 = TEXT
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(0, 200, 1, 0)
SubTitle.Position = UDim2.new(0, 125, 0, 0)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "PACK FARM"
SubTitle.TextColor3 = ACCENT
SubTitle.TextSize = 11
SubTitle.Font = Enum.Font.GothamBold
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = TopBar

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 35, 0, 35)
Minimize.Position = UDim2.new(1, -75, 0, 5)
Minimize.BackgroundColor3 = BUTTON
Minimize.Text = "—"
Minimize.TextColor3 = TEXT
Minimize.TextSize = 18
Minimize.Font = Enum.Font.GothamBold
Minimize.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 7)
MinCorner.Parent = Minimize

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 35, 0, 35)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.BackgroundColor3 = BUTTON
Close.Text = "×"
Close.TextColor3 = TEXT
Close.TextSize = 20
Close.Font = Enum.Font.GothamBold
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

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 10)
SideCorner.Parent = Sidebar

local SideTitle = Instance.new("TextLabel")
SideTitle.Size = UDim2.new(1, -20, 0, 25)
SideTitle.Position = UDim2.new(0, 10, 0, 15)
SideTitle.BackgroundTransparency = 1
SideTitle.Text = "MENU"
SideTitle.TextColor3 = SUBTEXT
SideTitle.TextSize = 10
SideTitle.Font = Enum.Font.GothamBold
SideTitle.TextXAlignment = Enum.TextXAlignment.Left
SideTitle.Parent = Sidebar

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

local function CreateTab(name, text, y)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 38)
    Button.Position = UDim2.new(0, 10, 0, y)
    Button.BackgroundColor3 = SIDEBAR
    Button.Text = text
    Button.TextColor3 = SUBTEXT
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamMedium
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.Parent = Sidebar

    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 12)
    Padding.Parent = Button

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Button

    local Page = Instance.new("Frame")
    Page.Size = UDim2.new(1, -30, 1, -25)
    Page.Position = UDim2.new(0, 15, 0, 15)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.Parent = Content

    Tabs[name] = Button
    Pages[name] = Page

    return Button, Page
end

local FarmTab, FarmPage = CreateTab("Farm", "  Farm", 50)
local SettingsTab, SettingsPage = CreateTab("Settings", "  Settings", 95)
local LogsTab, LogsPage = CreateTab("Logs", "  Logs", 140)

local function SelectTab(name)
    for tabName, button in pairs(Tabs) do
        if tabName == name then
            button.BackgroundColor3 = PANEL2
            button.TextColor3 = TEXT
        else
            button.BackgroundColor3 = SIDEBAR
            button.TextColor3 = SUBTEXT
        end
    end

    for pageName, page in pairs(Pages) do
        page.Visible = pageName == name
    end
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

local FarmDesc = Instance.new("TextLabel")
FarmDesc.Size = UDim2.new(1, 0, 0, 25)
FarmDesc.Position = UDim2.new(0, 0, 0, 30)
FarmDesc.BackgroundTransparency = 1
FarmDesc.Text = "Automatically buy and recover selected packs."
FarmDesc.TextColor3 = SUBTEXT
FarmDesc.TextSize = 12
FarmDesc.Font = Enum.Font.Gotham
FarmDesc.TextXAlignment = Enum.TextXAlignment.Left
FarmDesc.Parent = FarmPage

-- STATUS CARD

local StatusCard = Instance.new("Frame")
StatusCard.Size = UDim2.new(1, 0, 0, 75)
StatusCard.Position = UDim2.new(0, 0, 0, 70)
StatusCard.BackgroundColor3 = PANEL
StatusCard.BorderSizePixel = 0
StatusCard.Parent = FarmPage

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusCard

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.5, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 15, 0, 10)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "STATUS"
StatusLabel.TextColor3 = SUBTEXT
StatusLabel.TextSize = 10
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusCard

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0.5, 0, 0, 25)
Status.Position = UDim2.new(0, 15, 0, 32)
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
Toggle.Parent = StatusCard

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 7)
ToggleCorner.Parent = Toggle

-- PACK CARDS

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

local function CreatePackButton(text, packName, x)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.5, -7, 0, 55)
    Button.Position = UDim2.new(x, 0, 0, 190)
    Button.BackgroundColor3 = PANEL
    Button.Text = ""
    Button.Parent = FarmPage

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 25)
    Label.Position = UDim2.new(0, 10, 0, 7)
    Label.BackgroundTransparency = 1
    Label.Text = text
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
        AllowedPacks[packName] = not AllowedPacks[packName]

        if AllowedPacks[packName] then
            State.Text = "● ENABLED"
            State.TextColor3 = GREEN
        else
            State.Text = "● DISABLED"
            State.TextColor3 = RED
        end
    end)

    return Button
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

local DelayDesc = Instance.new("TextLabel")
DelayDesc.Size = UDim2.new(1, 0, 0, 20)
DelayDesc.Position = UDim2.new(0, 0, 0, 78)
DelayDesc.BackgroundTransparency = 1
DelayDesc.Text = "Time between each farm cycle."
DelayDesc.TextColor3 = SUBTEXT
DelayDesc.TextSize = 11
DelayDesc.Font = Enum.Font.Gotham
DelayDesc.TextXAlignment = Enum.TextXAlignment.Left
DelayDesc.Parent = SettingsPage

local DelayBox = Instance.new("TextBox")
DelayBox.Size = UDim2.new(0, 130, 0, 38)
DelayBox.Position = UDim2.new(0, 0, 0, 105)
DelayBox.BackgroundColor3 = PANEL
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
    local value = tonumber(DelayBox.Text)

    if value and value >= 0 then
        Delay = value
    else
        DelayBox.Text = tostring(Delay)
    end
end)

-- ANTI AFK

local AFKButton = Instance.new("TextButton")
AFKButton.Size = UDim2.new(1, 0, 0, 55)
AFKButton.Position = UDim2.new(0, 0, 0, 165)
AFKButton.BackgroundColor3 = PANEL
AFKButton.Text = ""
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
ClearButton.Text = "CLEAR LOG"
ClearButton.TextColor3 = TEXT
ClearButton.TextSize = 11
ClearButton.Font = Enum.Font.GothamBold
ClearButton.Parent = LogsPage

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 7)
ClearCorner.Parent = ClearButton

--==================================================
-- LOG SYSTEM
--==================================================

local Logs = {}
local MAX_LOGS = 5

local function RefreshLog()
    LogText.Text = table.concat(Logs, "\n")

    task.defer(function()
        local height = LogText.AbsoluteSize.Y + 20

        LogFrame.CanvasSize = UDim2.new(
            0,
            0,
            0,
            height
        )

        LogFrame.CanvasPosition = Vector2.new(
            0,
            math.max(
                0,
                height - LogFrame.AbsoluteSize.Y
            )
        )
    end)
end

local function ClearLogs()
    table.clear(Logs)
    LogText.Text = ""
    LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    LogFrame.CanvasPosition = Vector2.new(0, 0)
end

local function AddLog(message)
    local time = os.date("%H:%M:%S")

    if #Logs >= MAX_LOGS then
        ClearLogs()
    end

    table.insert(
        Logs,
        "[" .. time .. "] " .. tostring(message)
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

    local success, result = pcall(function()
        return RequestConveyorOffer:InvokeServer(1)
    end)

    if not success or typeof(result) ~= "table" then
        AddLog("ERROR: Cannot get offer")
        return
    end

    for _, offer in pairs(result) do

        if typeof(offer) ~= "table" then
            continue
        end

        local offerId = offer.OfferId
        local packName = offer.PackName
        local mutation = offer.Mutation

        AddLog(
            "Offer: "
            .. tostring(packName)
            .. " | "
            .. tostring(mutation)
        )

        if AllowedPacks[packName] then

            AddLog(
                "Buying: "
                .. tostring(packName)
            )

            local buySuccess = pcall(function()
                BuyPack:FireServer(
                    packName,
                    mutation,
                    offerId
                )
            end)

            if not buySuccess then
                AddLog("ERROR: BuyPack")
                return
            end

            AddLog(
                "Bought: "
                .. tostring(packName)
            )

            task.wait(0.5)

            local rollSuccess = pcall(function()
                SetRecoverPack:FireServer(offerId)
            end)

            if rollSuccess then
                AddLog(
                    "ROLLED: "
                    .. tostring(packName)
                    .. " | "
                    .. tostring(mutation)
                )
            else
                AddLog("ERROR: SetRecoverPack")
            end

            return
        end
    end

    AddLog("Skipped: No selected pack")
end

--==================================================
-- FARM LOOP
--==================================================

task.spawn(function()

    while true do

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

TopBar.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        Dragging = true
        DragStart = input.Position
        StartPosition = Main.Position

        input.Changed:Connect(function()

            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end

        end)

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if Dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then

        local Delta = input.Position - DragStart

        Main.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )

    end

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
        Main.Size = UDim2.new(0, 650, 0, 45)
    else
        Main.Size = UDim2.new(0, 650, 0, 430)
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
-- DEFAULT TAB
--==================================================

SelectTab("Farm")
AddLog("UI Loaded")
AddLog("Anti-AFK: Enabled")
