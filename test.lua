--==================================================
-- 1TAP TAB TEST
--==================================================

local CoreGui = game:GetService("CoreGui")

-- Xóa GUI cũ
local Old = CoreGui:FindFirstChild("1tap_Test")

if Old then
    Old:Destroy()
end

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "1tap_Test"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
Gui.Parent = CoreGui

--==================================================
-- COLORS
--==================================================

local BG = Color3.fromRGB(18, 18, 22)
local SIDEBAR = Color3.fromRGB(14, 14, 18)
local PANEL = Color3.fromRGB(24, 24, 29)
local SELECTED = Color3.fromRGB(45, 45, 55)

local TEXT = Color3.fromRGB(235, 235, 240)
local SUBTEXT = Color3.fromRGB(145, 145, 155)

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
-- TITLE BAR
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
-- SIDEBAR
--==================================================

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
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
Content.Name = "Content"
Content.Size = UDim2.new(1, -150, 1, -50)
Content.Position = UDim2.new(0, 150, 0, 50)
Content.BackgroundColor3 = BG
Content.BorderSizePixel = 0
Content.ZIndex = 2
Content.Parent = Main

--==================================================
-- TAB / PAGE
--==================================================

local Tabs = {}
local Pages = {}
local CurrentTab = nil

local function CreateTab(Name, Text, Y)

    -- BUTTON
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


    -- PAGE
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

--==================================================
-- CREATE TABS
--==================================================

local FarmButton, FarmPage =
    CreateTab("Farm", "  FARM", 45)

local SettingsButton, SettingsPage =
    CreateTab("Settings", "  SETTINGS", 90)

local LogsButton, LogsPage =
    CreateTab("Logs", "  LOGS", 135)

--==================================================
-- PAGE CONTENT
--==================================================

local function CreatePageTitle(Page, Text)

    local Label = Instance.new("TextLabel")

    Label.Size = UDim2.new(1, 0, 0, 40)
    Label.Position = UDim2.new(0, 0, 0, 0)

    Label.BackgroundTransparency = 1

    Label.Text = Text
    Label.TextColor3 = TEXT
    Label.TextSize = 20
    Label.Font = Enum.Font.GothamBold

    Label.TextXAlignment = Enum.TextXAlignment.Left

    Label.ZIndex = 6

    Label.Parent = Page
end

CreatePageTitle(FarmPage, "Farm")

CreatePageTitle(SettingsPage, "Settings")

CreatePageTitle(LogsPage, "Logs")

--==================================================
-- TEST TEXT
--==================================================

local function CreateTestText(Page, Text)

    local Label = Instance.new("TextLabel")

    Label.Size = UDim2.new(1, -20, 0, 50)
    Label.Position = UDim2.new(0, 0, 0, 50)

    Label.BackgroundColor3 = PANEL
    Label.BorderSizePixel = 0

    Label.Text = Text
    Label.TextColor3 = TEXT
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham

    Label.ZIndex = 6

    Label.Parent = Page

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Label
end

CreateTestText(
    FarmPage,
    "FARM PAGE - TAB HOẠT ĐỘNG"
)

CreateTestText(
    SettingsPage,
    "SETTINGS PAGE - TAB HOẠT ĐỘNG"
)

CreateTestText(
    LogsPage,
    "LOGS PAGE - TAB HOẠT ĐỘNG"
)

--==================================================
-- SELECT TAB
--==================================================

local function SelectTab(Name)

    print("Selected tab:", Name)

    CurrentTab = Name

    -- BUTTON
    for TabName, Button in pairs(Tabs) do

        if TabName == Name then

            Button.BackgroundColor3 = SELECTED
            Button.TextColor3 = TEXT

        else

            Button.BackgroundColor3 = SIDEBAR
            Button.TextColor3 = SUBTEXT

        end

    end

    -- PAGE
    for PageName, Page in pairs(Pages) do

        Page.Visible = (PageName == Name)

    end
end

--==================================================
-- BUTTON EVENTS
--==================================================

FarmButton.Activated:Connect(function()

    SelectTab("Farm")

end)

SettingsButton.Activated:Connect(function()

    SelectTab("Settings")

end)

LogsButton.Activated:Connect(function()

    SelectTab("Logs")

end)

--==================================================
-- HOVER
--==================================================

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
-- DEFAULT
--==================================================

SelectTab("Farm")

print("1tap TEST loaded")
