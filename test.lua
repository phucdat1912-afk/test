--==================================================
-- PROJECT SLAYERS 2 HUB
-- MANUAL LOAD ONLY
-- NPC + PLAYER + MUZAN
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- REMOVE OLD UI
--==================================================

for _, name in ipairs({
    "TeleportUI",
    "NPCTeleportUI",
    "ProjectSlayers2Hub"
}) do
    local old = PlayerGui:FindFirstChild(name)
    if old then
        old:Destroy()
    end
end

--==================================================
-- CONFIG
--==================================================

local COLORS = {
    Background = Color3.fromRGB(17, 17, 23),
    Header = Color3.fromRGB(24, 24, 32),
    Item = Color3.fromRGB(28, 28, 38),
    ItemHover = Color3.fromRGB(37, 37, 49),
    Button = Color3.fromRGB(55, 105, 220),
    ButtonHover = Color3.fromRGB(70, 120, 235),
    Text = Color3.fromRGB(240, 240, 245),
    SubText = Color3.fromRGB(135, 135, 150),
    Border = Color3.fromRGB(60, 60, 75),
}

--==================================================
-- STATE
--==================================================

local LoadedTargets = {}
local Loaded = false
local CurrentTab = "ALL"
local SearchText = ""

--==================================================
-- HELPERS
--==================================================

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or COLORS.Border
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

local function getRoot(model)
    if not model then
        return nil
    end

    return model:FindFirstChild("HumanoidRootPart")
        or model.PrimaryPart
end

local function isPlayerCharacter(model)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character == model then
            return true
        end
    end

    return false
end

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "ProjectSlayers2Hub"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

--==================================================
-- MAIN
--==================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(410, 570)
Main.Position = UDim2.new(0.5, -205, 0.5, -285)
Main.BackgroundColor3 = COLORS.Background
Main.BorderSizePixel = 0
Main.Parent = Gui

corner(Main, 14)
stroke(Main, COLORS.Border, 1, 0.2)

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 70)
Header.BackgroundColor3 = COLORS.Header
Header.BorderSizePixel = 0
Header.Parent = Main

corner(Header, 14)

local Title = Instance.new("TextLabel")
Title.Position = UDim2.fromOffset(18, 9)
Title.Size = UDim2.new(1, -100, 0, 27)
Title.BackgroundTransparency = 1
Title.Text = "PROJECT SLAYERS 2"
Title.TextColor3 = COLORS.Text
Title.TextSize = 19
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Status = Instance.new("TextLabel")
Status.Position = UDim2.fromOffset(19, 38)
Status.Size = UDim2.new(1, -110, 0, 18)
Status.BackgroundTransparency = 1
Status.Text = "Not loaded"
Status.TextColor3 = COLORS.SubText
Status.TextSize = 11
Status.Font = Enum.Font.Gotham
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Header

--==================================================
-- MINIMIZE
--==================================================

local Minimize = Instance.new("TextButton")
Minimize.Position = UDim2.new(1, -75, 0, 15)
Minimize.Size = UDim2.fromOffset(26, 26)
Minimize.BackgroundColor3 = COLORS.Item
Minimize.BorderSizePixel = 0
Minimize.Text = "—"
Minimize.TextColor3 = COLORS.Text
Minimize.TextSize = 15
Minimize.Font = Enum.Font.GothamBold
Minimize.Parent = Header

corner(Minimize, 7)

--==================================================
-- CLOSE
--==================================================

local Close = Instance.new("TextButton")
Close.Position = UDim2.new(1, -42, 0, 15)
Close.Size = UDim2.fromOffset(26, 26)
Close.BackgroundColor3 = Color3.fromRGB(170, 55, 65)
Close.BorderSizePixel = 0
Close.Text = "×"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.TextSize = 17
Close.Font = Enum.Font.GothamBold
Close.Parent = Header

corner(Close, 7)

--==================================================
-- LOAD
--==================================================

local LoadButton = Instance.new("TextButton")
LoadButton.Position = UDim2.fromOffset(15, 82)
LoadButton.Size = UDim2.new(1, -30, 0, 42)
LoadButton.BackgroundColor3 = COLORS.Button
LoadButton.BorderSizePixel = 0
LoadButton.Text = "LOAD NPC + PLAYER"
LoadButton.TextColor3 = Color3.new(1, 1, 1)
LoadButton.TextSize = 13
LoadButton.Font = Enum.Font.GothamBold
LoadButton.Parent = Main

corner(LoadButton, 9)

--==================================================
-- SEARCH
--==================================================

local Search = Instance.new("TextBox")
Search.Position = UDim2.fromOffset(15, 135)
Search.Size = UDim2.new(1, -30, 0, 40)
Search.BackgroundColor3 = COLORS.Item
Search.BorderSizePixel = 0
Search.PlaceholderText = "Search NPC / Player..."
Search.PlaceholderColor3 = COLORS.SubText
Search.Text = ""
Search.TextColor3 = COLORS.Text
Search.TextSize = 13
Search.Font = Enum.Font.Gotham
Search.ClearTextOnFocus = false
Search.Parent = Main

corner(Search, 9)
stroke(Search, COLORS.Border, 1, 0.3)

--==================================================
-- TABS
--==================================================

local TabFrame = Instance.new("Frame")
TabFrame.Position = UDim2.fromOffset(15, 185)
TabFrame.Size = UDim2.new(1, -30, 0, 36)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = Main

local function createTab(text, x, width)
    local button = Instance.new("TextButton")
    button.Position = UDim2.fromOffset(x, 0)
    button.Size = UDim2.fromOffset(width, 36)
    button.BackgroundColor3 = COLORS.Item
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = COLORS.Text
    button.TextSize = 11
    button.Font = Enum.Font.GothamBold
    button.Parent = TabFrame

    corner(button, 8)

    return button
end

local AllTab = createTab("ALL", 0, 65)
local MuzanTab = createTab("MUZAN", 72, 80)
local NPCTab = createTab("NPC", 159, 65)
local PlayerTab = createTab("PLAYER", 231, 80)

--==================================================
-- LIST
--==================================================

local List = Instance.new("ScrollingFrame")
List.Position = UDim2.fromOffset(15, 232)
List.Size = UDim2.new(1, -30, 1, -247)
List.BackgroundTransparency = 1
List.BorderSizePixel = 0
List.ScrollBarThickness = 4
List.ScrollBarImageColor3 = Color3.fromRGB(90, 90, 105)
List.CanvasSize = UDim2.new()
List.AutomaticCanvasSize = Enum.AutomaticSize.Y
List.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 7)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = List

local ListPadding = Instance.new("UIPadding")
ListPadding.PaddingBottom = UDim.new(0, 5)
ListPadding.Parent = List

--==================================================
-- TELEPORT
--==================================================

local function teleportTo(target)
    local character = LocalPlayer.Character
    if not character then
        return
    end

    local playerRoot = getRoot(character)
    local targetRoot = getRoot(target)

    if not playerRoot or not targetRoot then
        return
    end

    playerRoot.CFrame =
        targetRoot.CFrame + Vector3.new(0, 3, 0)
end

--==================================================
-- CREATE TARGET BUTTON
--==================================================

local function createTargetButton(data)
    local target = data.Target

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -8, 0, 52)
    Button.BackgroundColor3 = COLORS.Item
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = List

    corner(Button, 9)

    local Name = Instance.new("TextLabel")
    Name.Position = UDim2.fromOffset(14, 5)
    Name.Size = UDim2.new(1, -125, 0, 24)
    Name.BackgroundTransparency = 1
    Name.Text = target.Name
    Name.TextColor3 = COLORS.Text
    Name.TextSize = 14
    Name.Font = Enum.Font.GothamMedium
    Name.TextXAlignment = Enum.TextXAlignment.Left
    Name.TextTruncate = Enum.TextTruncate.AtEnd
    Name.Parent = Button

    local Type = Instance.new("TextLabel")
    Type.Position = UDim2.fromOffset(14, 29)
    Type.Size = UDim2.new(1, -125, 0, 15)
    Type.BackgroundTransparency = 1
    Type.Text = data.Type
    Type.TextColor3 = COLORS.SubText
    Type.TextSize = 10
    Type.Font = Enum.Font.Gotham
    Type.TextXAlignment = Enum.TextXAlignment.Left
    Type.Parent = Button

    local TP = Instance.new("TextButton")
    TP.AnchorPoint = Vector2.new(1, 0.5)
    TP.Position = UDim2.new(1, -9, 0.5, 0)
    TP.Size = UDim2.fromOffset(82, 30)
    TP.BackgroundColor3 = COLORS.Button
    TP.BorderSizePixel = 0
    TP.Text = "TELEPORT"
    TP.TextColor3 = Color3.new(1, 1, 1)
    TP.TextSize = 10
    TP.Font = Enum.Font.GothamBold
    TP.Parent = Button

    corner(TP, 7)

    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = COLORS.ItemHover
        TP.BackgroundColor3 = COLORS.ButtonHover
    end)

    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = COLORS.Item
        TP.BackgroundColor3 = COLORS.Button
    end)

    Button.MouseButton1Click:Connect(function()
        teleportTo(target)
    end)
end

--==================================================
-- RENDER
--==================================================

local function render()
    if not Loaded then
        return
    end

    for _, child in ipairs(List:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local shown = 0
    local searchText = Search.Text:lower()

    for _, data in ipairs(LoadedTargets) do
        local target = data.Target

        if target
            and target.Parent
            and getRoot(target) then

            local filterMatch = false

            if CurrentTab == "ALL" then
                filterMatch = true

            elseif CurrentTab == "NPC" then
                filterMatch = data.Type == "NPC"

            elseif CurrentTab == "PLAYER" then
                filterMatch = data.Type == "PLAYER"

            elseif CurrentTab == "MUZAN" then
                filterMatch =
                    data.Type == "NPC"
                    and target.Name:lower():find(
                        "muzan",
                        1,
                        true
                    ) ~= nil
            end

            local searchMatch =
                searchText == ""
                or target.Name:lower():find(
                    searchText,
                    1,
                    true
                ) ~= nil

            if filterMatch and searchMatch then
                createTargetButton(data)
                shown += 1
            end
        end
    end

    Status.Text =
        string.format(
            "%d loaded • %d shown",
            #LoadedTargets,
            shown
        )
end

--==================================================
-- MANUAL LOAD
--==================================================

local function loadTargets()
    LoadedTargets = {}

    -- PLAYER
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer
            and player.Character
            and getRoot(player.Character) then

            table.insert(LoadedTargets, {
                Target = player.Character,
                Type = "PLAYER"
            })
        end
    end

    -- NPC
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model")
            and obj ~= LocalPlayer.Character
            and not isPlayerCharacter(obj)
            and obj:FindFirstChildOfClass("Humanoid")
            and getRoot(obj) then

            table.insert(LoadedTargets, {
                Target = obj,
                Type = "NPC"
            })
        end
    end

    Loaded = true
    render()
end

--==================================================
-- LOAD BUTTON
--==================================================

LoadButton.MouseButton1Click:Connect(function()
    LoadButton.Text = "LOADING..."
    LoadButton.Active = false

    task.wait()

    loadTargets()

    LoadButton.Text = "RELOAD"
    LoadButton.Active = true
end)

--==================================================
-- SEARCH
--==================================================

Search:GetPropertyChangedSignal("Text"):Connect(function()
    if Loaded then
        render()
    end
end)

--==================================================
-- TABS
--==================================================

local function setTab(tab)
    CurrentTab = tab

    AllTab.BackgroundColor3 =
        tab == "ALL" and COLORS.Button or COLORS.Item

    MuzanTab.BackgroundColor3 =
        tab == "MUZAN" and COLORS.Button or COLORS.Item

    NPCTab.BackgroundColor3 =
        tab == "NPC" and COLORS.Button or COLORS.Item

    PlayerTab.BackgroundColor3 =
        tab == "PLAYER" and COLORS.Button or COLORS.Item

    render()
end

AllTab.MouseButton1Click:Connect(function()
    setTab("ALL")
end)

MuzanTab.MouseButton1Click:Connect(function()
    setTab("MUZAN")
end)

NPCTab.MouseButton1Click:Connect(function()
    setTab("NPC")
end)

PlayerTab.MouseButton1Click:Connect(function()
    setTab("PLAYER")
end)

setTab("ALL")

--==================================================
-- MINIMIZE
--==================================================

local minimized = false
local normalSize = Main.Size

Minimize.MouseButton1Click:Connect(function()
    minimized = not minimized

    if minimized then
        Main.Size = UDim2.fromOffset(410, 70)
        Search.Visible = false
        TabFrame.Visible = false
        List.Visible = false
        LoadButton.Visible = false
    else
        Main.Size = normalSize
        Search.Visible = true
        TabFrame.Visible = true
        List.Visible = true
        LoadButton.Visible = true
    end
end)

--==================================================
-- CLOSE
--==================================================

Close.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)

--==================================================
-- DRAG
--==================================================

local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = Main.Position

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

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)
