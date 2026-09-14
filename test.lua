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
-- REMOVE OLD GUI
--==================================================

local Old = CoreGui:FindFirstChild("1tap_PackFarm")

if Old then
    Old:Destroy()
end

--==================================================
-- HELPERS
--==================================================

local function Corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
    return c
end

local function MakeButton(parent, text, size, pos)
    local button = Instance.new("TextButton")

    button.Size = size
    button.Position = pos
    button.BackgroundColor3 = PANEL
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = TEXT
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = false
    button.Parent = parent

    Corner(button, 6)

    return button
end

local function MakeLabel(parent, text, size, pos, textSize)
    local label = Instance.new("TextLabel")

    label.Size = size
    label.Position = pos
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = TEXT
    label.TextSize = textSize or 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent

    return label
end

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "1tap_PackFarm"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 600, 0, 380)
Main.Position = UDim2.new(0.5, -300, 0.5, -190)
Main.BackgroundColor3 = BG
Main.BorderSizePixel = 0
Main.Parent = Gui

Corner(Main, 10)

--==================================================
-- SHOW HUB
--==================================================

local ShowHubButton = Instance.new("TextButton")
ShowHubButton.Size = UDim2.new(0, 75, 0, 35)
ShowHubButton.Position = UDim2.new(0, 10, 0.5, -17)
ShowHubButton.BackgroundColor3 = PANEL
ShowHubButton.BorderSizePixel = 0
ShowHubButton.Text = "1tap"
ShowHubButton.TextColor3 = TEXT
ShowHubButton.TextSize = 14
ShowHubButton.Font = Enum.Font.GothamBold
ShowHubButton.Visible = false
ShowHubButton.Parent = Gui

Corner(ShowHubButton, 7)

--==================================================
-- TOP BAR
--==================================================

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = BG
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local Title = MakeLabel(
    TopBar,
    "1tap",
    UDim2.new(0, 100, 1, 0),
    UDim2.new(0, 18, 0, 0),
    17
)

Title.Font = Enum.Font.GothamBold

local HideHubButton = Instance.new("TextButton")
HideHubButton.Size = UDim2.new(0, 32, 0, 32)
HideHubButton.Position = UDim2.new(1, -42, 0, 9)
HideHubButton.BackgroundColor3 = PANEL
HideHubButton.BorderSizePixel = 0
HideHubButton.Text = "—"
HideHubButton.TextColor3 = TEXT
HideHubButton.TextSize = 16
HideHubButton.Font = Enum.Font.GothamBold
HideHubButton.Parent = TopBar

Corner(HideHubButton, 6)

--==================================================
-- DRAG MAIN
--==================================================

local dragging = false
local dragStart
local startPos

TopBar.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()

            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end

        end)
    end

end)

UserInputService.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - dragStart

    Main.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )

end)

--==================================================
-- DRAG SHOW BUTTON
--==================================================

local draggingShow = false
local showDragStart
local showStartPos

ShowHubButton.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        draggingShow = true
        showDragStart = input.Position
        showStartPos = ShowHubButton.Position

        input.Changed:Connect(function()

            if input.UserInputState == Enum.UserInputState.End then
                draggingShow = false
            end

        end)
    end

end)

UserInputService.InputChanged:Connect(function(input)

    if not draggingShow then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - showDragStart

    ShowHubButton.Position = UDim2.new(
        showStartPos.X.Scale,
        showStartPos.X.Offset + delta.X,
        showStartPos.Y.Scale,
        showStartPos.Y.Offset + delta.Y
    )

end)

--==================================================
-- SIDEBAR
--==================================================

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, -50)
Sidebar.Position = UDim2.new(0, 0, 0, 50)
Sidebar.BackgroundColor3 = SIDEBAR
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local MenuLabel = MakeLabel(
    Sidebar,
    "MENU",
    UDim2.new(1, -30, 0, 30),
    UDim2.new(0, 15, 0, 15),
    11
)

MenuLabel.TextColor3 = SUBTEXT
MenuLabel.Font = Enum.Font.GothamBold

local FarmTab = MakeButton(
    Sidebar,
    "FARM",
    UDim2.new(1, -20, 0, 38),
    UDim2.new(0, 10, 0, 50)
)

local SettingsTab = MakeButton(
    Sidebar,
    "SETTINGS",
    UDim2.new(1, -20, 0, 38),
    UDim2.new(0, 10, 0, 94)
)

local LogsTab = MakeButton(
    Sidebar,
    "LOGS",
    UDim2.new(1, -20, 0, 38),
    UDim2.new(0, 10, 0, 138)
)

--==================================================
-- CONTENT
--==================================================

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -150, 1, -50)
Content.Position = UDim2.new(0, 150, 0, 50)
Content.BackgroundColor3 = BG
Content.BorderSizePixel = 0
Content.Parent = Main

--==================================================
-- FARM PAGE
--==================================================

local FarmPage = Instance.new("Frame")
FarmPage.Size = UDim2.new(1, 0, 1, 0)
FarmPage.BackgroundTransparency = 1
FarmPage.Parent = Content

local FarmTitle = MakeLabel(
    FarmPage,
    "Pack Auto Farm",
    UDim2.new(1, -40, 0, 35),
    UDim2.new(0, 20, 0, 20),
    18
)

FarmTitle.Font = Enum.Font.GothamBold

local FarmStatus = MakeLabel(
    FarmPage,
    "Status: STOPPED",
    UDim2.new(1, -40, 0, 25),
    UDim2.new(0, 20, 0, 58),
    13
)

FarmStatus.TextColor3 = RED

local StartButton = MakeButton(
    FarmPage,
    "START",
    UDim2.new(0, 120, 0, 38),
    UDim2.new(0, 20, 0, 95)
)

StartButton.BackgroundColor3 = GREEN
StartButton.TextColor3 = Color3.fromRGB(15, 15, 15)

local StopButton = MakeButton(
    FarmPage,
    "STOP",
    UDim2.new(0, 120, 0, 38),
    UDim2.new(0, 150, 0, 95)
)

StopButton.BackgroundColor3 = RED
StopButton.TextColor3 = Color3.fromRGB(15, 15, 15)

local HSRButton = MakeButton(
    FarmPage,
    "HSR Pack: OFF",
    UDim2.new(0, 220, 0, 40),
    UDim2.new(0, 20, 0, 155)
)

local EternityButton = MakeButton(
    FarmPage,
    "Eternity Pack: OFF",
    UDim2.new(0, 220, 0, 40),
    UDim2.new(0, 20, 0, 205)
)

--==================================================
-- SETTINGS PAGE
--==================================================

local SettingsPage = Instance.new("Frame")
SettingsPage.Size = UDim2.new(1, 0, 1, 0)
SettingsPage.BackgroundTransparency = 1
SettingsPage.Visible = false
SettingsPage.Parent = Content

local SettingsTitle = MakeLabel(
    SettingsPage,
    "Settings",
    UDim2.new(1, -40, 0, 35),
    UDim2.new(0, 20, 0, 20),
    18
)

SettingsTitle.Font = Enum.Font.GothamBold

local DelayLabel = MakeLabel(
    SettingsPage,
    "Delay: 1.5",
    UDim2.new(0, 200, 0, 30),
    UDim2.new(0, 20, 0, 70),
    14
)

local MinusButton = MakeButton(
    SettingsPage,
    "-",
    UDim2.new(0, 40, 0, 35),
    UDim2.new(0, 20, 0, 110)
)

local PlusButton = MakeButton(
    SettingsPage,
    "+",
    UDim2.new(0, 40, 0, 35),
    UDim2.new(0, 70, 0, 110)
)

local AntiAFKButton = MakeButton(
    SettingsPage,
    "Anti-AFK: ON",
    UDim2.new(0, 180, 0, 38),
    UDim2.new(0, 20, 0, 165)
)

--==================================================
-- LOGS PAGE
--==================================================

local LogsPage = Instance.new("Frame")
LogsPage.Size = UDim2.new(1, 0, 1, 0)
LogsPage.BackgroundTransparency = 1
LogsPage.Visible = false
LogsPage.Parent = Content

local LogsTitle = MakeLabel(
    LogsPage,
    "Logs",
    UDim2.new(0, 200, 0, 35),
    UDim2.new(0, 20, 0, 20),
    18
)

LogsTitle.Font = Enum.Font.GothamBold

local ClearLogsButton = MakeButton(
    LogsPage,
    "Clear Logs",
    UDim2.new(0, 100, 0, 32),
    UDim2.new(0, 350, 0, 0)
)

local LogContainer = Instance.new("Frame")
LogContainer.Size = UDim2.new(1, -40, 0, 235)
LogContainer.Position = UDim2.new(0, 20, 0, 60)
LogContainer.BackgroundColor3 = PANEL
LogContainer.BorderSizePixel = 0
LogContainer.Parent = LogsPage

Corner(LogContainer, 7)

--==================================================
-- LOG FUNCTION
--==================================================

local function RefreshLogs()

    for _, child in ipairs(LogContainer:GetChildren()) do

        if child:IsA("TextLabel") then
            child:Destroy()
        end

    end

    for i, log in ipairs(Logs) do

        local label = Instance.new("TextLabel")

        label.Size = UDim2.new(1, -20, 0, 30)
        label.Position = UDim2.new(
            0,
            10,
            0,
            (i - 1) * 30 + 5
        )

        label.BackgroundTransparency = 1
        label.Text = tostring(log)
        label.TextColor3 = TEXT
        label.TextSize = 12
        label.Font = Enum.Font.Code
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = LogContainer

    end

end

--==================================================
-- AUTO CLEAR AFTER 8 LOGS
--==================================================

local function AddLog(text)

    if #Logs >= 8 then
        table.clear(Logs)
    end

    table.insert(
        Logs,
        os.date("%H:%M:%S") .. " | " .. tostring(text)
    )

    RefreshLogs()

end

--==================================================
-- PACK BUTTONS
--==================================================

local function UpdatePackButtons()

    if AllowedPacks["HSR Pack"] then
        HSRButton.Text = "HSR Pack: ON"
        HSRButton.BackgroundColor3 = SELECTED
    else
        HSRButton.Text = "HSR Pack: OFF"
        HSRButton.BackgroundColor3 = PANEL
    end

    if AllowedPacks["Eternity Pack"] then
        EternityButton.Text = "Eternity Pack: ON"
        EternityButton.BackgroundColor3 = SELECTED
    else
        EternityButton.Text = "Eternity Pack: OFF"
        EternityButton.BackgroundColor3 = PANEL
    end

end

--==================================================
-- AUTO BUY + AUTO ROLL
--==================================================

local function BuyAndRoll()

    local success, result = pcall(function()
        return RequestConveyorOffer:InvokeServer(1)
    end)

    if not success or typeof(result) ~= "table" then
        AddLog("ERROR: Không lấy được offer")
        return
    end

    for _, offer in pairs(result) do

        if typeof(offer) ~= "table" then
            continue
        end

        local offerId = offer.OfferId
        local packName = offer.PackName
        local mutation = offer.Mutation

        print(
            "Offer:",
            packName,
            mutation,
            offerId
        )

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
                .. " | "
                .. tostring(mutation)
            )

            local buySuccess, buyError = pcall(function()

                BuyPack:FireServer(
                    packName,
                    mutation,
                    offerId
                )

            end)

            if not buySuccess then

                warn(
                    "BuyPack lỗi:",
                    buyError
                )

                AddLog("ERROR: BuyPack")
                return

            end

            AddLog(
                "Bought: "
                .. tostring(packName)
            )

            task.wait(0.5)

            local rollSuccess, rollError = pcall(function()

                SetRecoverPack:FireServer(
                    offerId
                )

            end)

            if not rollSuccess then

                warn(
                    "SetRecoverPack lỗi:",
                    rollError
                )

                AddLog("ERROR: SetRecoverPack")

            else

                print(
                    "Đã Roll:",
                    packName,
                    offerId
                )

                AddLog(
                    "ROLLED: "
                    .. tostring(packName)
                    .. " | "
                    .. tostring(mutation)
                )

            end

            return
        end
    end

    AddLog("Skip")

end

--==================================================
-- AUTO LOOP
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

StartButton.MouseButton1Click:Connect(function()

    if Running then
        return
    end

    Running = true

    FarmStatus.Text = "Status: RUNNING"
    FarmStatus.TextColor3 = GREEN

    AddLog("Auto Farm STARTED")

end)

StopButton.MouseButton1Click:Connect(function()

    if not Running then
        return
    end

    Running = false

    FarmStatus.Text = "Status: STOPPED"
    FarmStatus.TextColor3 = RED

    AddLog("Auto Farm STOPPED")

end)

--==================================================
-- PACK TOGGLES
--==================================================

HSRButton.MouseButton1Click:Connect(function()

    AllowedPacks["HSR Pack"] =
        not AllowedPacks["HSR Pack"]

    UpdatePackButtons()

    AddLog(
        "HSR Pack: "
        .. tostring(AllowedPacks["HSR Pack"])
    )

end)

EternityButton.MouseButton1Click:Connect(function()

    AllowedPacks["Eternity Pack"] =
        not AllowedPacks["Eternity Pack"]

    UpdatePackButtons()

    AddLog(
        "Eternity Pack: "
        .. tostring(AllowedPacks["Eternity Pack"])
    )

end)

--==================================================
-- DELAY
--==================================================

local function UpdateDelay()

    DelayLabel.Text =
        "Delay: "
        .. string.format("%.1f", Delay)

end

MinusButton.MouseButton1Click:Connect(function()

    Delay = math.max(
        0.2,
        math.round((Delay - 0.1) * 10) / 10
    )

    UpdateDelay()

end)

PlusButton.MouseButton1Click:Connect(function()

    Delay =
        math.round((Delay + 0.1) * 10) / 10

    UpdateDelay()

end)

--==================================================
-- ANTI AFK
--==================================================

AntiAFKButton.MouseButton1Click:Connect(function()

    AntiAFK = not AntiAFK

    if AntiAFK then

        AntiAFKButton.Text = "Anti-AFK: ON"
        AntiAFKButton.BackgroundColor3 = SELECTED

    else

        AntiAFKButton.Text = "Anti-AFK: OFF"
        AntiAFKButton.BackgroundColor3 = PANEL

    end

end)

Player.Idled:Connect(function()

    if not AntiAFK then
        return
    end

    VirtualUser:CaptureController()

    VirtualUser:ClickButton2(
        Vector2.new(0, 0)
    )

end)

--==================================================
-- CLEAR LOGS BUTTON
--==================================================

ClearLogsButton.MouseButton1Click:Connect(function()

    table.clear(Logs)
    RefreshLogs()

end)

--==================================================
-- HIDE / SHOW HUB
--==================================================

HideHubButton.MouseButton1Click:Connect(function()

    Main.Visible = false
    ShowHubButton.Visible = true

end)

ShowHubButton.MouseButton1Click:Connect(function()

    Main.Visible = true
    ShowHubButton.Visible = false

end)

--==================================================
-- TABS
--==================================================

local function SelectTab(tab)

    FarmPage.Visible = false
    SettingsPage.Visible = false
    LogsPage.Visible = false

    FarmTab.BackgroundColor3 = PANEL
    SettingsTab.BackgroundColor3 = PANEL
    LogsTab.BackgroundColor3 = PANEL

    if tab == "Farm" then

        FarmPage.Visible = true
        FarmTab.BackgroundColor3 = SELECTED

    elseif tab == "Settings" then

        SettingsPage.Visible = true
        SettingsTab.BackgroundColor3 = SELECTED

    elseif tab == "Logs" then

        LogsPage.Visible = true
        LogsTab.BackgroundColor3 = SELECTED

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

--==================================================
-- INIT
--==================================================

UpdatePackButtons()
UpdateDelay()
SelectTab("Farm")
AddLog("1tap Pack Farm loaded")
