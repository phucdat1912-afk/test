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
local Event2Pack = false

local AllowedPacks = {
    ["Titan Slayer Pack"] = true,
    ["Chain Devil Pack"] = true,
    ["Soccer Pack"] = true
}

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

pcall(function()
    local old = CoreGui:FindFirstChild("1tap_PackFarm")
    if old then
        old:Destroy()
    end
end)

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "1tap_PackFarm"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 600, 0, 380)
Main.Position = UDim2.new(0.5, -300, 0.5, -190)
Main.BackgroundColor3 = BG
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

--==================================================
-- DRAG
--==================================================

local Dragging = false
local DragStart
local StartPos

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = input.Position
        StartPos = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local Delta = input.Position - DragStart

        Main.Position = UDim2.new(
            StartPos.X.Scale,
            StartPos.X.Offset + Delta.X,
            StartPos.Y.Scale,
            StartPos.Y.Offset + Delta.Y
        )
    end
end)

--==================================================
-- SIDEBAR
--==================================================

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, 0)
Sidebar.BackgroundColor3 = SIDEBAR
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 10)
SideCorner.Parent = Sidebar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 55)
Title.BackgroundTransparency = 1
Title.Text = "1tap"
Title.TextColor3 = TEXT
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.Parent = Sidebar

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, 0, 0, 25)
Subtitle.Position = UDim2.new(0, 0, 0, 45)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Pack Farm"
Subtitle.TextColor3 = SUBTEXT
Subtitle.TextSize = 13
Subtitle.Font = Enum.Font.Gotham
Subtitle.Parent = Sidebar

--==================================================
-- CONTENT
--==================================================

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -150, 1, 0)
Content.Position = UDim2.new(0, 150, 0, 0)
Content.BackgroundTransparency = 1
Content.Parent = Main

--==================================================
-- PAGE CREATION
--==================================================

local FarmPage = Instance.new("Frame")
FarmPage.Size = UDim2.new(1, 0, 1, 0)
FarmPage.BackgroundTransparency = 1
FarmPage.Visible = true
FarmPage.Parent = Content

local SettingsPage = Instance.new("Frame")
SettingsPage.Size = UDim2.new(1, 0, 1, 0)
SettingsPage.BackgroundTransparency = 1
SettingsPage.Visible = false
SettingsPage.Parent = Content

local LogsPage = Instance.new("Frame")
LogsPage.Size = UDim2.new(1, 0, 1, 0)
LogsPage.BackgroundTransparency = 1
LogsPage.Visible = false
LogsPage.Parent = Content

--==================================================
-- BUTTON FUNCTION
--==================================================

local function MakeButton(parent, text, size, position)
    local Button = Instance.new("TextButton")

    Button.Size = size
    Button.Position = position
    Button.BackgroundColor3 = PANEL
    Button.BorderSizePixel = 0

    Button.Text = text
    Button.TextColor3 = TEXT
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamMedium

    Button.AutoButtonColor = false
    Button.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Button

    return Button
end

--==================================================
-- FARM PAGE
--==================================================

local FarmTitle = Instance.new("TextLabel")
FarmTitle.Size = UDim2.new(1, -40, 0, 40)
FarmTitle.Position = UDim2.new(0, 20, 0, 15)
FarmTitle.BackgroundTransparency = 1
FarmTitle.Text = "Pack Farm"
FarmTitle.TextColor3 = TEXT
FarmTitle.TextSize = 20
FarmTitle.TextXAlignment = Enum.TextXAlignment.Left
FarmTitle.Font = Enum.Font.GothamBold
FarmTitle.Parent = FarmPage

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -40, 0, 25)
StatusLabel.Position = UDim2.new(0, 20, 0, 55)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: OFF"
StatusLabel.TextColor3 = RED
StatusLabel.TextSize = 13
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = FarmPage

local FarmButton = MakeButton(
    FarmPage,
    "Start Farm",
    UDim2.new(0, 220, 0, 40),
    UDim2.new(0, 20, 0, 95)
)

local TitanButton = MakeButton(
    FarmPage,
    "Titan Slayer: ON",
    UDim2.new(0, 220, 0, 40),
    UDim2.new(0, 20, 0, 145)
)

local ChainButton = MakeButton(
    FarmPage,
    "Chain Devil: ON",
    UDim2.new(0, 220, 0, 40),
    UDim2.new(0, 20, 0, 195)
)

local SoccerButton = MakeButton(
    FarmPage,
    "Soccer Pack: ON",
    UDim2.new(0, 220, 0, 40),
    UDim2.new(0, 20, 0, 245)
)

local EventButton = MakeButton(
    FarmPage,
    "Event 2 Pack: OFF",
    UDim2.new(0, 220, 0, 40),
    UDim2.new(0, 20, 0, 295)
)

--==================================================
-- PACK BUTTON UPDATE
--==================================================

local function UpdatePackButtons()

    if AllowedPacks["Titan Slayer Pack"] then
        TitanButton.Text = "Titan Slayer: ON"
        TitanButton.BackgroundColor3 = SELECTED
    else
        TitanButton.Text = "Titan Slayer: OFF"
        TitanButton.BackgroundColor3 = PANEL
    end

    if AllowedPacks["Chain Devil Pack"] then
        ChainButton.Text = "Chain Devil: ON"
        ChainButton.BackgroundColor3 = SELECTED
    else
        ChainButton.Text = "Chain Devil: OFF"
        ChainButton.BackgroundColor3 = PANEL
    end

    if AllowedPacks["Soccer Pack"] then
        SoccerButton.Text = "Soccer Pack: ON"
        SoccerButton.BackgroundColor3 = SELECTED
    else
        SoccerButton.Text = "Soccer Pack: OFF"
        SoccerButton.BackgroundColor3 = PANEL
    end
end

TitanButton.MouseButton1Click:Connect(function()
    AllowedPacks["Titan Slayer Pack"] =
        not AllowedPacks["Titan Slayer Pack"]

    UpdatePackButtons()
end)

ChainButton.MouseButton1Click:Connect(function()
    AllowedPacks["Chain Devil Pack"] =
        not AllowedPacks["Chain Devil Pack"]

    UpdatePackButtons()
end)

SoccerButton.MouseButton1Click:Connect(function()
    AllowedPacks["Soccer Pack"] =
        not AllowedPacks["Soccer Pack"]

    UpdatePackButtons()
end)

--==================================================
-- EVENT 2 PACK
--==================================================

local function UpdateEventButton()

    if Event2Pack then
        EventButton.Text = "Event 2 Pack: ON"
        EventButton.BackgroundColor3 = SELECTED
    else
        EventButton.Text = "Event 2 Pack: OFF"
        EventButton.BackgroundColor3 = PANEL
    end
end

EventButton.MouseButton1Click:Connect(function()

    Event2Pack = not Event2Pack

    UpdateEventButton()

    if Event2Pack then
        AddLog("Event 2 Pack: ON")
    else
        AddLog("Event 2 Pack: OFF")
    end
end)

--==================================================
-- SETTINGS PAGE
--==================================================

local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Size = UDim2.new(1, -40, 0, 40)
SettingsTitle.Position = UDim2.new(0, 20, 0, 15)
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Text = "Settings"
SettingsTitle.TextColor3 = TEXT
SettingsTitle.TextSize = 20
SettingsTitle.TextXAlignment = Enum.TextXAlignment.Left
SettingsTitle.Font = Enum.Font.GothamBold
SettingsTitle.Parent = SettingsPage

local DelayLabel = Instance.new("TextLabel")
DelayLabel.Size = UDim2.new(0, 220, 0, 40)
DelayLabel.Position = UDim2.new(0, 20, 0, 80)
DelayLabel.BackgroundColor3 = PANEL
DelayLabel.BorderSizePixel = 0
DelayLabel.TextColor3 = TEXT
DelayLabel.TextSize = 14
DelayLabel.Font = Enum.Font.GothamMedium
DelayLabel.Parent = SettingsPage

local DelayCorner = Instance.new("UICorner")
DelayCorner.CornerRadius = UDim.new(0, 7)
DelayCorner.Parent = DelayLabel

local MinusButton = MakeButton(
    SettingsPage,
    "-",
    UDim2.new(0, 45, 0, 40),
    UDim2.new(0, 250, 0, 80)
)

local PlusButton = MakeButton(
    SettingsPage,
    "+",
    UDim2.new(0, 45, 0, 40),
    UDim2.new(0, 305, 0, 80)
)

local AntiAFKButton = MakeButton(
    SettingsPage,
    "Anti-AFK: ON",
    UDim2.new(0, 220, 0, 40),
    UDim2.new(0, 20, 0, 140)
)

local function UpdateDelay()
    DelayLabel.Text = "Delay: " .. string.format("%.1f", Delay) .. "s"
end

MinusButton.MouseButton1Click:Connect(function()

    Delay = math.max(0.1, Delay - 0.1)
    UpdateDelay()

end)

PlusButton.MouseButton1Click:Connect(function()

    Delay = Delay + 0.1
    UpdateDelay()

end)

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

--==================================================
-- LOG PAGE
--==================================================

local LogsTitle = Instance.new("TextLabel")
LogsTitle.Size = UDim2.new(1, -40, 0, 40)
LogsTitle.Position = UDim2.new(0, 20, 0, 15)
LogsTitle.BackgroundTransparency = 1
LogsTitle.Text = "Logs"
LogsTitle.TextColor3 = TEXT
LogsTitle.TextSize = 20
LogsTitle.TextXAlignment = Enum.TextXAlignment.Left
LogsTitle.Font = Enum.Font.GothamBold
LogsTitle.Parent = LogsPage

local LogsFrame = Instance.new("ScrollingFrame")
LogsFrame.Size = UDim2.new(1, -40, 0, 250)
LogsFrame.Position = UDim2.new(0, 20, 0, 60)
LogsFrame.BackgroundColor3 = PANEL
LogsFrame.BorderSizePixel = 0
LogsFrame.ScrollBarThickness = 4
LogsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogsFrame.Parent = LogsPage

local LogsCorner = Instance.new("UICorner")
LogsCorner.CornerRadius = UDim.new(0, 7)
LogsCorner.Parent = LogsFrame

local LogsLayout = Instance.new("UIListLayout")
LogsLayout.Padding = UDim.new(0, 4)
LogsLayout.Parent = LogsFrame

local ClearLogsButton = MakeButton(
    LogsPage,
    "Clear Logs",
    UDim2.new(0, 140, 0, 40),
    UDim2.new(0, 20, 0, 325)
)

local LogCount = 0

function AddLog(Text)

    LogCount += 1

    local Label = Instance.new("TextLabel")

    Label.Size = UDim2.new(1, -10, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Text = "[" .. os.date("%H:%M:%S") .. "] " .. tostring(Text)
    Label.TextColor3 = TEXT
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Code
    Label.Parent = LogsFrame

    LogsFrame.CanvasSize = UDim2.new(
        0,
        0,
        0,
        LogsLayout.AbsoluteContentSize.Y + 10
    )

    if LogCount >= 8 then

        task.delay(0.2, function()

            for _, child in ipairs(LogsFrame:GetChildren()) do

                if child:IsA("TextLabel") then
                    child:Destroy()
                end

            end

            LogCount = 0

            LogsFrame.CanvasPosition = Vector2.new(0, 0)

        end)

    end
end

ClearLogsButton.MouseButton1Click:Connect(function()

    for _, child in ipairs(LogsFrame:GetChildren()) do

        if child:IsA("TextLabel") then
            child:Destroy()
        end

    end

    LogCount = 0
    LogsFrame.CanvasPosition = Vector2.new(0, 0)

end)

--==================================================
-- SIDEBAR TABS
--==================================================

local FarmTab = MakeButton(
    Sidebar,
    "Farm",
    UDim2.new(0, 120, 0, 40),
    UDim2.new(0, 15, 0, 100)
)

local SettingsTab = MakeButton(
    Sidebar,
    "Settings",
    UDim2.new(0, 120, 0, 40),
    UDim2.new(0, 15, 0, 150)
)

local LogsTab = MakeButton(
    Sidebar,
    "Logs",
    UDim2.new(0, 120, 0, 40),
    UDim2.new(0, 15, 0, 200)
)

local function SelectTab(Tab)

    FarmPage.Visible = false
    SettingsPage.Visible = false
    LogsPage.Visible = false

    FarmTab.BackgroundColor3 = PANEL
    SettingsTab.BackgroundColor3 = PANEL
    LogsTab.BackgroundColor3 = PANEL

    if Tab == "Farm" then

        FarmPage.Visible = true
        FarmTab.BackgroundColor3 = SELECTED

    elseif Tab == "Settings" then

        SettingsPage.Visible = true
        SettingsTab.BackgroundColor3 = SELECTED

    elseif Tab == "Logs" then

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
-- BUY / ROLL
--==================================================

local function BuyAndRoll()

    local OfferCount = Event2Pack and 2 or 1

    AddLog(
        "Requesting "
        .. tostring(OfferCount)
        .. " offer(s)"
    )

    local Success, Result = pcall(function()
        return RequestConveyorOffer:InvokeServer(OfferCount)
    end)

    if not Success then
        AddLog("ERROR: RequestConveyorOffer")
        return
    end

    if typeof(Result) ~= "table" then
        AddLog("ERROR: Invalid offer")
        return
    end

    local Found = 0

    for _, Offer in pairs(Result) do

        if typeof(Offer) ~= "table" then
            continue
        end

        local OfferId = Offer.OfferId
        local PackName = Offer.PackName
        local Mutation = Offer.Mutation

        print(
            "Offer:",
            PackName,
            Mutation,
            OfferId
        )

        AddLog(
            "Offer: "
            .. tostring(PackName)
            .. " | "
            .. tostring(Mutation)
        )

        if AllowedPacks[PackName] then

            Found += 1

            AddLog(
                "Buying: "
                .. tostring(PackName)
                .. " | "
                .. tostring(Mutation)
            )

            local BuySuccess, BuyError = pcall(function()

                BuyPack:FireServer(
                    PackName,
                    Mutation,
                    OfferId
                )

            end)

            if not BuySuccess then

                warn("BuyPack error:", BuyError)
                AddLog("ERROR: BuyPack")

                continue
            end

            AddLog(
                "Bought: "
                .. tostring(PackName)
            )

            task.wait(0.5)

            local RollSuccess, RollError = pcall(function()

                SetRecoverPack:FireServer(
                    OfferId
                )

            end)

            if not RollSuccess then

                warn(
                    "SetRecoverPack error:",
                    RollError
                )

                AddLog("ERROR: SetRecoverPack")

            else

                print(
                    "Rolled:",
                    PackName,
                    OfferId
                )

                AddLog(
                    "ROLLED: "
                    .. tostring(PackName)
                    .. " | "
                    .. tostring(Mutation)
                )

            end

            task.wait(0.2)

        end
    end

    if Found == 0 then
        AddLog("Skip")
    else
        AddLog(
            "Processed: "
            .. tostring(Found)
            .. " pack(s)"
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

    FarmButton.Text = "Stop Farm"
    FarmButton.BackgroundColor3 = SELECTED

    StatusLabel.Text = "Status: ON"
    StatusLabel.TextColor3 = GREEN

    AddLog("Farm started")

    task.spawn(function()

        while Running do

            pcall(function()
                BuyAndRoll()
            end)

            task.wait(Delay)

        end

    end)
end

local function StopFarm()

    Running = false

    FarmButton.Text = "Start Farm"
    FarmButton.BackgroundColor3 = PANEL

    StatusLabel.Text = "Status: OFF"
    StatusLabel.TextColor3 = RED

    AddLog("Farm stopped")
end

FarmButton.MouseButton1Click:Connect(function()

    if Running then
        StopFarm()
    else
        StartFarm()
    end

end)

--==================================================
-- ANTI AFK
--==================================================

Player.Idled:Connect(function()

    if not AntiAFK then
        return
    end

    pcall(function()

        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(
            Vector2.new(0, 0)
        )

    end)

end)

--==================================================
-- HIDE / SHOW
--==================================================

local Hidden = false

local HideButton = Instance.new("TextButton")
HideButton.Size = UDim2.new(0, 35, 0, 35)
HideButton.Position = UDim2.new(1, -45, 0, 10)
HideButton.BackgroundColor3 = PANEL
HideButton.BorderSizePixel = 0
HideButton.Text = "-"
HideButton.TextColor3 = TEXT
HideButton.TextSize = 18
HideButton.Font = Enum.Font.GothamBold
HideButton.Parent = Main

local HideCorner = Instance.new("UICorner")
HideCorner.CornerRadius = UDim.new(0, 7)
HideCorner.Parent = HideButton

HideButton.MouseButton1Click:Connect(function()

    Hidden = not Hidden

    Sidebar.Visible = not Hidden
    Content.Visible = not Hidden

    if Hidden then
        Main.Size = UDim2.new(0, 60, 0, 55)
        HideButton.Position = UDim2.new(0, 12, 0, 10)
        HideButton.Text = "+"
    else
        Main.Size = UDim2.new(0, 600, 0, 380)
        HideButton.Position = UDim2.new(1, -45, 0, 10)
        HideButton.Text = "-"
    end

end)

--==================================================
-- INITIALIZE
--==================================================

UpdatePackButtons()
UpdateEventButton()
UpdateDelay()
SelectTab("Farm")

AddLog("1tap Pack Farm loaded")
AddLog("Titan Slayer Pack enabled")
AddLog("Chain Devil Pack enabled")
AddLog("Soccer Pack enabled")
