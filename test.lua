--==================================================
-- PACK AUTO FARM
-- Ouroboros-style standalone UI
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
local Delay = 1.5

local DetectedPacks = {}
local SelectedPacks = {}

local Logs = {}
local MAX_LOGS = 5

--==================================================
-- REMOVE OLD GUI
--==================================================

pcall(function()
    local old = CoreGui:FindFirstChild("OuroborosPackAutoFarm")
    if old then
        old:Destroy()
    end
end)

--==================================================
-- COLORS
--==================================================

local Colors = {
    Background = Color3.fromRGB(18, 18, 21),
    Sidebar = Color3.fromRGB(22, 22, 26),
    Group = Color3.fromRGB(25, 25, 29),
    Element = Color3.fromRGB(31, 31, 36),
    ElementHover = Color3.fromRGB(38, 38, 44),

    Text = Color3.fromRGB(235, 235, 235),
    SubText = Color3.fromRGB(155, 155, 165),

    Accent = Color3.fromRGB(120, 95, 220),
    AccentDark = Color3.fromRGB(88, 67, 170),

    Green = Color3.fromRGB(70, 190, 105),
    Red = Color3.fromRGB(205, 75, 75),
    Yellow = Color3.fromRGB(225, 180, 70),

    Border = Color3.fromRGB(42, 42, 48)
}

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "OuroborosPackAutoFarm"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = CoreGui

--==================================================
-- MAIN
--==================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 720, 0, 500)
Main.Position = UDim2.new(0.5, -360, 0.5, -250)
Main.BackgroundColor3 = Colors.Background
Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Colors.Border
MainStroke.Thickness = 1
MainStroke.Transparency = 0.2
MainStroke.Parent = Main

--==================================================
-- DRAG
--==================================================

local Dragging = false
local DragStart
local StartPosition

local function MakeDraggable(handle, target)
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

            Dragging = true
            DragStart = input.Position
            StartPosition = target.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)
end

MakeDraggable(Main, Main)

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
-- TOP BAR
--==================================================

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Colors.Sidebar
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1, 0, 0, 12)
TopFix.Position = UDim2.new(0, 0, 1, -12)
TopFix.BackgroundColor3 = Colors.Sidebar
TopFix.BorderSizePixel = 0
TopFix.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 14, 0, 0)
Title.Size = UDim2.new(0, 250, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "Ouroboros Hub"
Title.TextColor3 = Colors.Text
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.new(0, 150, 0, 0)
Subtitle.Size = UDim2.new(0, 250, 1, 0)
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "Anime Card Farm"
Subtitle.TextColor3 = Colors.SubText
Subtitle.TextSize = 12
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = TopBar

--==================================================
-- SIDEBAR
--==================================================

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.Size = UDim2.new(0, 145, 1, -42)
Sidebar.BackgroundColor3 = Colors.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 5)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 12)
SidebarPadding.PaddingLeft = UDim.new(0, 8)
SidebarPadding.PaddingRight = UDim.new(0, 8)
SidebarPadding.Parent = Sidebar

--==================================================
-- CONTENT
--==================================================

local Content = Instance.new("Frame")
Content.Position = UDim2.new(0, 145, 0, 42)
Content.Size = UDim2.new(1, -145, 1, -42)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Pages = {}

local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 3
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.Visible = false
    Page.Parent = Content

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.Parent = Page

    local Padding = Instance.new("UIPadding")
    Padding.PaddingTop = UDim.new(0, 10)
    Padding.PaddingBottom = UDim.new(0, 10)
    Padding.PaddingLeft = UDim.new(0, 10)
    Padding.PaddingRight = UDim.new(0, 10)
    Padding.Parent = Page

    Pages[name] = Page

    return Page
end

local MainPage = CreatePage("Main")
local LogsPage = CreatePage("Logs")

--==================================================
-- SIDEBAR BUTTON
--==================================================

local CurrentPage

local function CreateTab(name, iconText, page)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(1, 0, 0, 34)
    Button.BackgroundColor3 = Colors.Sidebar
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = Sidebar

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Button

    local Icon = Instance.new("TextLabel")
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.new(0, 9, 0, 0)
    Icon.Size = UDim2.new(0, 22, 1, 0)
    Icon.Font = Enum.Font.GothamBold
    Icon.Text = iconText
    Icon.TextColor3 = Colors.SubText
    Icon.TextSize = 13
    Icon.Parent = Button

    local Text = Instance.new("TextLabel")
    Text.BackgroundTransparency = 1
    Text.Position = UDim2.new(0, 35, 0, 0)
    Text.Size = UDim2.new(1, -40, 1, 0)
    Text.Font = Enum.Font.GothamMedium
    Text.Text = name
    Text.TextColor3 = Colors.SubText
    Text.TextSize = 12
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Parent = Button

    Button.MouseButton1Click:Connect(function()
        for _, data in pairs(Pages) do
            data.Visible = false
        end

        for _, child in ipairs(Sidebar:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Colors.Sidebar

                for _, sub in ipairs(child:GetChildren()) do
                    if sub:IsA("TextLabel") then
                        sub.TextColor3 = Colors.SubText
                    end
                end
            end
        end

        page.Visible = true
        Button.BackgroundColor3 = Colors.Element

        Icon.TextColor3 = Colors.Accent
        Text.TextColor3 = Colors.Text

        CurrentPage = page
    end)

    return Button
end

CreateTab("Auto Farm", "◆", MainPage)
CreateTab("Logs", "≡", LogsPage)

--==================================================
-- GROUPBOX
--==================================================

local function CreateGroupbox(parent, title, width)
    local Box = Instance.new("Frame")
    Box.Size = UDim2.new(width or 1, -5, 0, 100)
    Box.BackgroundColor3 = Colors.Group
    Box.BorderSizePixel = 0
    Box.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Box

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Colors.Border
    Stroke.Thickness = 1
    Stroke.Transparency = 0.35
    Stroke.Parent = Box

    local Header = Instance.new("TextLabel")
    Header.BackgroundTransparency = 1
    Header.Position = UDim2.new(0, 12, 0, 8)
    Header.Size = UDim2.new(1, -24, 0, 20)
    Header.Font = Enum.Font.GothamBold
    Header.Text = title
    Header.TextColor3 = Colors.Text
    Header.TextSize = 12
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Parent = Box

    local Container = Instance.new("Frame")
    Container.BackgroundTransparency = 1
    Container.Position = UDim2.new(0, 10, 0, 34)
    Container.Size = UDim2.new(1, -20, 1, -42)
    Container.Parent = Box

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 7)
    Layout.Parent = Container

    return Box, Container
end

--==================================================
-- TWO COLUMN HOLDER
--==================================================

local Columns = Instance.new("Frame")
Columns.BackgroundTransparency = 1
Columns.Size = UDim2.new(1, 0, 0, 430)
Columns.Parent = MainPage

local LeftColumn = Instance.new("Frame")
LeftColumn.BackgroundTransparency = 1
LeftColumn.Size = UDim2.new(0.5, -4, 1, 0)
LeftColumn.Parent = Columns

local LeftLayout = Instance.new("UIListLayout")
LeftLayout.Padding = UDim.new(0, 8)
LeftLayout.Parent = LeftColumn

local RightColumn = Instance.new("Frame")
RightColumn.BackgroundTransparency = 1
RightColumn.Position = UDim2.new(0.5, 4, 0, 0)
RightColumn.Size = UDim2.new(0.5, -4, 1, 0)
RightColumn.Parent = Columns

local RightLayout = Instance.new("UIListLayout")
RightLayout.Padding = UDim.new(0, 8)
RightLayout.Parent = RightColumn

--==================================================
-- TOGGLE
--==================================================

local function AddToggle(parent, text, default, callback)
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, 0, 0, 30)
    Holder.BackgroundTransparency = 1
    Holder.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Colors.Text
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Holder

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0, 38, 0, 20)
    Toggle.Position = UDim2.new(1, -38, 0.5, -10)
    Toggle.BackgroundColor3 = Colors.Element
    Toggle.BorderSizePixel = 0
    Toggle.Text = ""
    Toggle.AutoButtonColor = false
    Toggle.Parent = Holder

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = Toggle

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = UDim2.new(0, 2, 0.5, -8)
    Circle.BackgroundColor3 = Colors.SubText
    Circle.BorderSizePixel = 0
    Circle.Parent = Toggle

    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle

    local State = default == true

    local function Refresh()
        if State then
            Toggle.BackgroundColor3 = Colors.Accent
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Circle.Position = UDim2.new(1, -18, 0.5, -8)
        else
            Toggle.BackgroundColor3 = Colors.Element
            Circle.BackgroundColor3 = Colors.SubText
            Circle.Position = UDim2.new(0, 2, 0.5, -8)
        end

        if callback then
            callback(State)
        end
    end

    Toggle.MouseButton1Click:Connect(function()
        State = not State
        Refresh()
    end)

    Refresh()

    return {
        SetValue = function(value)
            State = value
            Refresh()
        end,

        GetValue = function()
            return State
        end
    }
end

--==================================================
-- BUTTON
--==================================================

local function AddButton(parent, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 31)
    Button.BackgroundColor3 = Colors.Element
    Button.BorderSizePixel = 0
    Button.Text = text
    Button.TextColor3 = Colors.Text
    Button.TextSize = 11
    Button.Font = Enum.Font.GothamMedium
    Button.AutoButtonColor = false
    Button.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Button

    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = Colors.ElementHover
    end)

    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = Colors.Element
    end)

    Button.MouseButton1Click:Connect(function()
        if callback then
            callback(Button)
        end
    end)

    return Button
end

--==================================================
-- LABEL
--==================================================

local function AddLabel(parent, text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 24)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Colors.SubText
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parent

    return Label
end

--==================================================
-- SLIDER
--==================================================

local function AddSlider(parent, text, min, max, default, callback)
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, 0, 0, 47)
    Holder.BackgroundTransparency = 1
    Holder.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(0.7, 0, 0, 20)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Colors.Text
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Holder

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    ValueLabel.Size = UDim2.new(0.3, 0, 0, 20)
    ValueLabel.Font = Enum.Font.Gotham
    ValueLabel.TextColor3 = Colors.SubText
    ValueLabel.TextSize = 11
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Holder

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 0, 5)
    Bar.Position = UDim2.new(0, 0, 0, 28)
    Bar.BackgroundColor3 = Colors.Element
    Bar.BorderSizePixel = 0
    Bar.Parent = Holder

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = Bar

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Fill.BackgroundColor3 = Colors.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 12, 0, 12)
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.Position = UDim2.new(0, 0, 0.5, 0)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.BorderSizePixel = 0
    Knob.Parent = Bar

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local Value = default

    local function SetValue(value)
        Value = math.clamp(value, min, max)

        local Percent = (Value - min) / (max - min)

        Fill.Size = UDim2.new(Percent, 0, 1, 0)
        Knob.Position = UDim2.new(Percent, 0, 0.5, 0)

        ValueLabel.Text = string.format("%.1f", Value)

        if callback then
            callback(Value)
        end
    end

    local Sliding = false

    local function UpdateFromMouse(input)
        local X = input.Position.X
        local Start = Bar.AbsolutePosition.X
        local Width = Bar.AbsoluteSize.X

        local Percent = math.clamp((X - Start) / Width, 0, 1)
        SetValue(min + ((max - min) * Percent))
    end

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

            Sliding = true
            UpdateFromMouse(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if Sliding and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            UpdateFromMouse(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            Sliding = false
        end
    end)

    SetValue(default)

    return {
        SetValue = SetValue,
        GetValue = function()
            return Value
        end
    }
end

--==================================================
-- MULTI DROPDOWN
--==================================================

local function AddMultiDropdown(parent, text)
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, 0, 0, 36)
    Holder.BackgroundTransparency = 1
    Holder.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 0, 0, -2)
    Label.Size = UDim2.new(1, 0, 0, 15)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Colors.Text
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Holder

    local Drop = Instance.new("TextButton")
    Drop.Position = UDim2.new(0, 0, 0, 17)
    Drop.Size = UDim2.new(1, 0, 0, 31)
    Drop.BackgroundColor3 = Colors.Element
    Drop.BorderSizePixel = 0
    Drop.Text = "None"
    Drop.TextColor3 = Colors.SubText
    Drop.TextSize = 11
    Drop.Font = Enum.Font.Gotham
    Drop.TextXAlignment = Enum.TextXAlignment.Left
    Drop.AutoButtonColor = false
    Drop.Parent = Holder

    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 9)
    Padding.PaddingRight = UDim.new(0, 9)
    Padding.Parent = Drop

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Drop

    local Arrow = Instance.new("TextLabel")
    Arrow.BackgroundTransparency = 1
    Arrow.AnchorPoint = Vector2.new(1, 0.5)
    Arrow.Position = UDim2.new(1, -8, 0.5, 0)
    Arrow.Size = UDim2.new(0, 20, 0, 20)
    Arrow.Font = Enum.Font.GothamBold
    Arrow.Text = "▼"
    Arrow.TextColor3 = Colors.SubText
    Arrow.TextSize = 8
    Arrow.Parent = Drop

    local List = Instance.new("ScrollingFrame")
    List.Position = UDim2.new(0, 0, 1, 3)
    List.Size = UDim2.new(1, 0, 0, 130)
    List.BackgroundColor3 = Colors.Element
    List.BorderSizePixel = 0
    List.ScrollBarThickness = 3
    List.Visible = false
    List.ZIndex = 50
    List.CanvasSize = UDim2.new(0, 0, 0, 0)
    List.AutomaticCanvasSize = Enum.AutomaticSize.Y
    List.Parent = Holder

    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 5)
    ListCorner.Parent = List

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 2)
    ListLayout.Parent = List

    local ListPadding = Instance.new("UIPadding")
    ListPadding.PaddingTop = UDim.new(0, 4)
    ListPadding.PaddingBottom = UDim.new(0, 4)
    ListPadding.PaddingLeft = UDim.new(0, 4)
    ListPadding.PaddingRight = UDim.new(0, 4)
    ListPadding.Parent = List

    local function RefreshText()
        local Selected = {}

        for Name in pairs(SelectedPacks) do
            table.insert(Selected, Name)
        end

        table.sort(Selected)

        if #Selected == 0 then
            Drop.Text = "None"
        elseif #Selected <= 2 then
            Drop.Text = table.concat(Selected, ", ")
        else
            Drop.Text = tostring(#Selected) .. " packs selected"
        end
    end

    local function Clear()
        for _, Child in ipairs(List:GetChildren()) do
            if Child:IsA("TextButton") then
                Child:Destroy()
            end
        end
    end

    local function AddPack(Name)
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -8, 0, 27)
        Button.BackgroundColor3 = Colors.Group
        Button.BorderSizePixel = 0
        Button.Text = ""
        Button.AutoButtonColor = false
        Button.ZIndex = 51
        Button.Parent = List

        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 4)
        ButtonCorner.Parent = Button

        local Text = Instance.new("TextLabel")
        Text.BackgroundTransparency = 1
        Text.Position = UDim2.new(0, 8, 0, 0)
        Text.Size = UDim2.new(1, -16, 1, 0)
        Text.Font = Enum.Font.Gotham
        Text.TextSize = 11
        Text.TextXAlignment = Enum.TextXAlignment.Left
        Text.ZIndex = 52
        Text.Parent = Button

        local function Refresh()
            if SelectedPacks[Name] then
                Text.Text = "✓  " .. Name
                Text.TextColor3 = Colors.Accent
                Button.BackgroundColor3 = Color3.fromRGB(40, 35, 55)
            else
                Text.Text = Name
                Text.TextColor3 = Colors.Text
                Button.BackgroundColor3 = Colors.Group
            end
        end

        Refresh()

        Button.MouseButton1Click:Connect(function()
            if SelectedPacks[Name] then
                SelectedPacks[Name] = nil
            else
                SelectedPacks[Name] = true
            end

            Refresh()
            RefreshText()
        end)
    end

    local function RefreshList()
        Clear()

        local Names = {}

        for Name in pairs(DetectedPacks) do
            table.insert(Names, Name)
        end

        table.sort(Names)

        for _, Name in ipairs(Names) do
            AddPack(Name)
        end

        RefreshText()
    end

    Drop.MouseButton1Click:Connect(function()
        List.Visible = not List.Visible
        Arrow.Text = List.Visible and "▲" or "▼"
    end)

    return {
        Refresh = RefreshList,

        Clear = Clear,

        SetList = function(ListData)
            Clear()

            for _, Name in ipairs(ListData) do
                DetectedPacks[Name] = true
                AddPack(Name)
            end

            RefreshText()
        end,

        RefreshText = RefreshText
    }
end

--==================================================
-- LOG SYSTEM
--==================================================

local LogContainer

local function ClearLogs()
    table.clear(Logs)

    if LogContainer then
        for _, Child in ipairs(LogContainer:GetChildren()) do
            if Child:IsA("TextLabel") then
                Child:Destroy()
            end
        end
    end
end

local function AddLog(Message)
    if #Logs >= MAX_LOGS then
        ClearLogs()
    end

    table.insert(
        Logs,
        "[" .. os.date("%H:%M:%S") .. "] " .. tostring(Message)
    )

    if LogContainer then
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, 0, 0, 22)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.Code
        Label.Text = Logs[#Logs]
        Label.TextColor3 = Colors.Text
        Label.TextSize = 10
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = LogContainer
    end
end

--==================================================
-- MAIN GROUPBOXES
--==================================================

local FarmBox, FarmContainer = CreateGroupbox(LeftColumn, "Auto Farm", 1)

local SelectedPackDropdown = AddMultiDropdown(
    FarmContainer,
    "Pack Filter"
)

local DelaySlider = AddSlider(
    FarmContainer,
    "Roll Delay",
    0.2,
    10,
    1.5,
    function(Value)
        Delay = Value
    end
)

local StartButton

StartButton = AddButton(
    FarmContainer,
    "START",
    function(Button)
        Running = not Running

        if Running then
            Button.Text = "STOP"
            Button.BackgroundColor3 = Colors.Red
            AddLog("Auto Farm STARTED")
        else
            Button.Text = "START"
            Button.BackgroundColor3 = Colors.Element
            AddLog("Auto Farm STOPPED")
        end
    end
)

local ScanBox, ScanContainer = CreateGroupbox(
    LeftColumn,
    "Pack Scanner",
    1
)

local ScanStatus = AddLabel(
    ScanContainer,
    "Detected: 0 pack(s)"
)

local ScanButton = AddButton(
    ScanContainer,
    "SCAN PACKS",
    function(Button)
        Button.Text = "SCANNING..."

        task.spawn(function()
            local Success, Result = pcall(function()
                return RequestConveyorOffer:InvokeServer(1)
            end)

            if not Success then
                AddLog("ERROR: Scan failed")
                Button.Text = "SCAN PACKS"
                return
            end

            if typeof(Result) ~= "table" then
                AddLog("ERROR: Invalid scan result")
                Button.Text = "SCAN PACKS"
                return
            end

            table.clear(DetectedPacks)

            for _, Offer in pairs(Result) do
                if typeof(Offer) == "table" then
                    local PackName = Offer.PackName

                    if PackName then
                        DetectedPacks[PackName] = true
                    end
                end
            end

            for Name in pairs(SelectedPacks) do
                if not DetectedPacks[Name] then
                    SelectedPacks[Name] = nil
                end
            end

            local Count = 0

            for _ in pairs(DetectedPacks) do
                Count += 1
            end

            ScanStatus.Text =
                "Detected: " .. tostring(Count) .. " pack(s)"

            SelectedPackDropdown.Refresh()

            AddLog(
                "Found " ..
                tostring(Count) ..
                " pack(s)"
            )

            Button.Text = "SCAN PACKS"
        end)
    end
)

--==================================================
-- STATUS GROUP
--==================================================

local StatusBox, StatusContainer = CreateGroupbox(
    RightColumn,
    "Status",
    1
)

local StatusLabel = AddLabel(
    StatusContainer,
    "Status: OFF"
)

local SelectionLabel = AddLabel(
    StatusContainer,
    "Selected: None"
)

local StatusUpdate = AddLabel(
    StatusContainer,
    "Ready"
)

--==================================================
-- ACTIONS
--==================================================

local ActionBox, ActionContainer = CreateGroupbox(
    RightColumn,
    "Actions",
    1
)

AddButton(
    ActionContainer,
    "CLEAR LOG",
    function()
        ClearLogs()
        AddLog("Log cleared")
    end
)

AddButton(
    ActionContainer,
    "RESCAN PACKS",
    function()
        ScanButton:Activate()
    end
)

--==================================================
-- LOG PAGE
--==================================================

local LogBox, LogBoxContainer = CreateGroupbox(
    LogsPage,
    "Roll Log",
    1
)

LogContainer = Instance.new("Frame")
LogContainer.Size = UDim2.new(1, 0, 0, 160)
LogContainer.BackgroundColor3 = Colors.Element
LogContainer.BorderSizePixel = 0
LogContainer.Parent = LogBoxContainer

local LogCorner = Instance.new("UICorner")
LogCorner.CornerRadius = UDim.new(0, 5)
LogCorner.Parent = LogContainer

local LogPadding = Instance.new("UIPadding")
LogPadding.PaddingLeft = UDim.new(0, 8)
LogPadding.PaddingRight = UDim.new(0, 8)
LogPadding.PaddingTop = UDim.new(0, 7)
LogPadding.Parent = LogContainer

local LogLayout = Instance.new("UIListLayout")
LogLayout.Padding = UDim.new(0, 2)
LogLayout.Parent = LogContainer

AddButton(
    LogBoxContainer,
    "CLEAR LOG",
    function()
        ClearLogs()
    end
)

--==================================================
-- UPDATE STATUS
--==================================================

task.spawn(function()
    while Gui.Parent do
        task.wait(0.15)

        if Running then
            StatusLabel.Text = "Status: RUNNING"
            StatusLabel.TextColor3 = Colors.Green

            StatusUpdate.Text =
                "Auto Buy / Roll is active"
        else
            StatusLabel.Text = "Status: OFF"
            StatusLabel.TextColor3 = Colors.Red

            StatusUpdate.Text =
                "Auto Farm is stopped"
        end

        local Selected = {}

        for Name in pairs(SelectedPacks) do
            table.insert(Selected, Name)
        end

        table.sort(Selected)

        if #Selected == 0 then
            SelectionLabel.Text = "Selected: None"
        else
            SelectionLabel.Text =
                "Selected: " .. table.concat(Selected, ", ")
        end
    end
end)

--==================================================
-- CHECK SELECTED
--==================================================

local function HasSelectedPack()
    for _ in pairs(SelectedPacks) do
        return true
    end

    return false
end

--==================================================
-- BUY + ROLL
--==================================================

local function BuyAndRoll()
    if not HasSelectedPack() then
        AddLog("No pack selected")
        return
    end

    local Success, Result = pcall(function()
        return RequestConveyorOffer:InvokeServer(1)
    end)

    if not Success or typeof(Result) ~= "table" then
        AddLog("ERROR: Cannot get offer")
        return
    end

    local Found = false

    for _, Offer in pairs(Result) do
        if typeof(Offer) ~= "table" then
            continue
        end

        local PackName = Offer.PackName
        local Mutation = Offer.Mutation
        local OfferId = Offer.OfferId

        if not PackName or not OfferId then
            continue
        end

        if SelectedPacks[PackName] then
            Found = true

            AddLog(
                "Buying: " ..
                tostring(PackName) ..
                " | " ..
                tostring(Mutation)
            )

            local BuySuccess, BuyError = pcall(function()
                BuyPack:FireServer(
                    PackName,
                    Mutation,
                    OfferId
                )
            end)

            if not BuySuccess then
                warn("BuyPack:", BuyError)
                AddLog("ERROR: BuyPack")
                return
            end

            AddLog(
                "Bought: " ..
                tostring(PackName)
            )

            task.wait(0.5)

            local RollSuccess, RollError = pcall(function()
                SetRecoverPack:FireServer(
                    OfferId
                )
            end)

            if not RollSuccess then
                warn(
                    "SetRecoverPack:",
                    RollError
                )

                AddLog(
                    "ERROR: SetRecoverPack"
                )
            else
                AddLog(
                    "ROLLED: " ..
                    tostring(PackName) ..
                    " | " ..
                    tostring(Mutation)
                )
            end

            break
        end
    end

    if not Found then
        AddLog("No selected pack in offer")
    end
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
-- INITIAL PAGE
--==================================================

MainPage.Visible = true

for _, Button in ipairs(Sidebar:GetChildren()) do
    if Button:IsA("TextButton") then
        Button.BackgroundColor3 = Colors.Sidebar
    end
end

local FirstTab = Sidebar:FindFirstChild("Auto Farm")

if FirstTab then
    FirstTab.BackgroundColor3 = Colors.Element

    for _, Child in ipairs(FirstTab:GetChildren()) do
        if Child:IsA("TextLabel") then
            Child.TextColor3 = Colors.Text
        end
    end
end

--==================================================
-- INITIAL SCAN
--==================================================

task.spawn(function()
    task.wait(1)

    local Success, Result = pcall(function()
        return RequestConveyorOffer:InvokeServer(1)
    end)

    if not Success or typeof(Result) ~= "table" then
        AddLog("Initial scan failed")
        return
    end

    table.clear(DetectedPacks)

    for _, Offer in pairs(Result) do
        if typeof(Offer) == "table" then
            local PackName = Offer.PackName

            if PackName then
                DetectedPacks[PackName] = true
            end
        end
    end

    local Count = 0

    for _ in pairs(DetectedPacks) do
        Count += 1
    end

    ScanStatus.Text =
        "Detected: " .. tostring(Count) .. " pack(s)"

    SelectedPackDropdown.Refresh()

    AddLog(
        "Found " ..
        tostring(Count) ..
        " pack(s)"
    )
end)

--==================================================
-- INITIAL LOG
--==================================================

AddLog("Ouroboros-style Pack Auto Farm loaded")
