--========================================================
-- PROJECT SLAYERS 2
-- NPC TELEPORT HUB
-- FULL MAP SCAN + DIRECT MUZAN SUPPORT
--========================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer

--========================================================
-- CLEAN
--========================================================

for _, name in ipairs({
    "ProjectSlayers2Hub",
    "NPCTeleportUI",
    "TeleportUI"
}) do
    local old = CoreGui:FindFirstChild(name)
    if old then
        old:Destroy()
    end
end

--========================================================
-- DATA
--========================================================

local LoadedNPCs = {}
local Seen = {}

local Loaded = false
local CurrentTab = "ALL"

--========================================================
-- GUI
--========================================================

local GUI = Instance.new("ScreenGui")
GUI.Name = "ProjectSlayers2Hub"
GUI.ResetOnSpawn = false
GUI.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 440, 0, 600)
Main.Position = UDim2.new(0.5, -220, 0.5, -300)
Main.BackgroundColor3 = Color3.fromRGB(18,18,24)
Main.BorderSizePixel = 0
Main.Parent = GUI

Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(60,60,75)
Stroke.Parent = Main

--========================================================
-- HEADER
--========================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,55)
Header.BackgroundColor3 = Color3.fromRGB(25,25,34)
Header.BorderSizePixel = 0
Header.Parent = Main

Instance.new("UICorner", Header).CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-100,0,28)
Title.Position = UDim2.new(0,15,0,6)
Title.BackgroundTransparency = 1
Title.Text = "PROJECT SLAYERS 2"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1,-100,0,18)
Status.Position = UDim2.new(0,15,0,32)
Status.BackgroundTransparency = 1
Status.Text = "Ready"
Status.TextColor3 = Color3.fromRGB(150,150,165)
Status.TextSize = 11
Status.Font = Enum.Font.Gotham
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0,35,0,35)
Close.Position = UDim2.new(1,-42,0,10)
Close.BackgroundColor3 = Color3.fromRGB(150,45,55)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255,255,255)
Close.TextSize = 20
Close.Font = Enum.Font.GothamBold
Close.BorderSizePixel = 0
Close.Parent = Header

Instance.new("UICorner", Close).CornerRadius = UDim.new(0,8)

--========================================================
-- LOAD
--========================================================

local Load = Instance.new("TextButton")
Load.Size = UDim2.new(1,-30,0,42)
Load.Position = UDim2.new(0,15,0,70)
Load.BackgroundColor3 = Color3.fromRGB(75,95,180)
Load.Text = "LOAD NPC"
Load.TextColor3 = Color3.fromRGB(255,255,255)
Load.TextSize = 14
Load.Font = Enum.Font.GothamBold
Load.BorderSizePixel = 0
Load.Parent = Main

Instance.new("UICorner", Load).CornerRadius = UDim.new(0,8)

--========================================================
-- SEARCH
--========================================================

local Search = Instance.new("TextBox")
Search.Size = UDim2.new(1,-30,0,38)
Search.Position = UDim2.new(0,15,0,122)
Search.BackgroundColor3 = Color3.fromRGB(30,30,40)
Search.BorderSizePixel = 0
Search.PlaceholderText = "Search NPC..."
Search.PlaceholderColor3 = Color3.fromRGB(120,120,135)
Search.Text = ""
Search.TextColor3 = Color3.fromRGB(255,255,255)
Search.TextSize = 13
Search.Font = Enum.Font.Gotham
Search.ClearTextOnFocus = false
Search.Parent = Main

Instance.new("UICorner", Search).CornerRadius = UDim.new(0,8)

local Pad = Instance.new("UIPadding")
Pad.PaddingLeft = UDim.new(0,12)
Pad.Parent = Search

--========================================================
-- TABS
--========================================================

local Tabs = Instance.new("Frame")
Tabs.Size = UDim2.new(1,-30,0,38)
Tabs.Position = UDim2.new(0,15,0,172)
Tabs.BackgroundTransparency = 1
Tabs.Parent = Main

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0,6)
TabLayout.Parent = Tabs

local function makeTab(text)

    local b = Instance.new("TextButton")

    b.Size = UDim2.new(0,95,1,0)
    b.BackgroundColor3 = Color3.fromRGB(35,35,46)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(200,200,215)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.Parent = Tabs

    Instance.new("UICorner", b).CornerRadius = UDim.new(0,7)

    return b
end

local AllTab = makeTab("ALL")
local MuzanTab = makeTab("MUZAN")
local NpcTab = makeTab("NPC")

--========================================================
-- LIST
--========================================================

local List = Instance.new("ScrollingFrame")
List.Size = UDim2.new(1,-30,1,-270)
List.Position = UDim2.new(0,15,0,220)
List.BackgroundColor3 = Color3.fromRGB(22,22,30)
List.BorderSizePixel = 0
List.ScrollBarThickness = 5
List.Parent = Main

Instance.new("UICorner", List).CornerRadius = UDim.new(0,8)

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0,6)
Layout.SortOrder = Enum.SortOrder.Name
Layout.Parent = List

local ListPad = Instance.new("UIPadding")
ListPad.PaddingTop = UDim.new(0,8)
ListPad.PaddingBottom = UDim.new(0,8)
ListPad.PaddingLeft = UDim.new(0,8)
ListPad.PaddingRight = UDim.new(0,8)
ListPad.Parent = List

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    List.CanvasSize = UDim2.new(
        0,
        0,
        0,
        Layout.AbsoluteContentSize.Y + 16
    )
end)

--========================================================
-- ROOT
--========================================================

local function getRoot(model)

    if not model then
        return nil
    end

    local root = model:FindFirstChild("HumanoidRootPart")

    if root and root:IsA("BasePart") then
        return root
    end

    if model.PrimaryPart and model.PrimaryPart:IsA("BasePart") then
        return model.PrimaryPart
    end

    return nil
end

--========================================================
-- ADD NPC
--========================================================

local function addNPC(model, forceMuzan)

    if not model or not model:IsA("Model") then
        return
    end

    if Seen[model] then
        return
    end

    local root = getRoot(model)

    if not root then
        return
    end

    Seen[model] = true

    table.insert(LoadedNPCs, {
        Model = model,
        Root = root,
        Name = model.Name,
        Path = model:GetFullName(),
        IsMuzan = forceMuzan == true
    })
end

--========================================================
-- DIRECT MUZAN
--========================================================

local function loadMuzan()

    local Debree = workspace:FindFirstChild("Debree")

    if not Debree then
        return false
    end

    local Muzan = Debree:FindFirstChild("MuzanLairModel")

    if not Muzan then
        return false
    end

    if not Muzan:IsA("Model") then
        return false
    end

    local root = Muzan:FindFirstChild("HumanoidRootPart")

    if not root then
        return false
    end

    addNPC(Muzan, true)

    return true
end

--========================================================
-- NPC CHECK
--========================================================

local function isNPC(model)

    if not model:IsA("Model") then
        return false
    end

    if not getRoot(model) then
        return false
    end

    -- NPC thường
    if model:FindFirstChildOfClass("Humanoid") then
        return true
    end

    -- NPC/Boss dùng AnimationController
    if model:FindFirstChildOfClass("AnimationController") then
        return true
    end

    return false
end

--========================================================
-- PLAYER CHARACTER CHECK
--========================================================

local function isPlayerCharacter(model)

    for _, player in ipairs(Players:GetPlayers()) do

        if player.Character == model then
            return true
        end

    end

    return false
end

--========================================================
-- LOAD ALL NPC
--========================================================

local function loadAllNPC()

    LoadedNPCs = {}
    Seen = {}

    Loaded = false

    Load.Text = "SCANNING..."
    Status.Text = "Scanning toàn Workspace..."

    task.wait()

    --====================================================
    -- 1. LOAD MUZAN TRƯỚC
    --====================================================

    local muzFound = loadMuzan()

    --====================================================
    -- 2. SCAN TOÀN WORKSPACE
    --====================================================

    for _, obj in ipairs(workspace:GetDescendants()) do

        if obj:IsA("Model") then

            if not Seen[obj]
                and not isPlayerCharacter(obj)
                and isNPC(obj)
            then

                addNPC(obj, false)

            end

        end

    end

    --====================================================
    -- 3. SORT
    --====================================================

    table.sort(LoadedNPCs, function(a,b)

        if a.IsMuzan ~= b.IsMuzan then
            return a.IsMuzan
        end

        return string.lower(a.Name) < string.lower(b.Name)

    end)

    Loaded = true

    Load.Text = "RELOAD NPC"

    if muzFound then
        Status.Text =
            "Loaded "
            .. #LoadedNPCs
            .. " NPC | Muzan FOUND"
    else
        Status.Text =
            "Loaded "
            .. #LoadedNPCs
            .. " NPC | Muzan NOT FOUND"
    end

    refreshList()
end

--========================================================
-- CLEAR
--========================================================

local function clearList()

    for _, child in ipairs(List:GetChildren()) do

        if child:IsA("TextButton")
            or child:IsA("Frame") then

            child:Destroy()

        end

    end
end

--========================================================
-- TELEPORT
--========================================================

local function teleport(target)

    if not target then
        return
    end

    local character = LP.Character

    if not character then
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")

    if not root then
        return
    end

    if not target.Model
        or not target.Model.Parent then

        Status.Text = "NPC không còn tồn tại"
        return
    end

    local targetRoot = getRoot(target.Model)

    if not targetRoot then
        Status.Text = "Không có Root"
        return
    end

    root.CFrame =
        targetRoot.CFrame
        + Vector3.new(0,3,0)

    Status.Text =
        "Teleport → "
        .. target.Name
end

--========================================================
-- CREATE BUTTON
--========================================================

local function createButton(target)

    local Button = Instance.new("TextButton")

    Button.Size = UDim2.new(1,-4,0,48)
    Button.BackgroundColor3 = Color3.fromRGB(31,31,42)
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = List

    Instance.new("UICorner", Button).CornerRadius = UDim.new(0,7)

    local Name = Instance.new("TextLabel")
    Name.Size = UDim2.new(1,-100,0,22)
    Name.Position = UDim2.new(0,10,0,4)
    Name.BackgroundTransparency = 1
    Name.Text =
        target.IsMuzan
        and "☠ MUZAN"
        or target.Name
    Name.TextColor3 = target.IsMuzan
        and Color3.fromRGB(255,100,100)
        or Color3.fromRGB(245,245,255)
    Name.TextSize = 13
    Name.Font = Enum.Font.GothamBold
    Name.TextXAlignment = Enum.TextXAlignment.Left
    Name.Parent = Button

    local Path = Instance.new("TextLabel")
    Path.Size = UDim2.new(1,-100,0,17)
    Path.Position = UDim2.new(0,10,0,26)
    Path.BackgroundTransparency = 1
    Path.Text = target.Path
    Path.TextColor3 = Color3.fromRGB(115,115,135)
    Path.TextSize = 9
    Path.Font = Enum.Font.Gotham
    Path.TextXAlignment = Enum.TextXAlignment.Left
    Path.TextTruncate = Enum.TextTruncate.AtEnd
    Path.Parent = Button

    local TP = Instance.new("TextButton")
    TP.Size = UDim2.new(0,78,0,30)
    TP.Position = UDim2.new(1,-86,0.5,-15)
    TP.BackgroundColor3 = target.IsMuzan
        and Color3.fromRGB(170,55,65)
        or Color3.fromRGB(75,95,180)
    TP.Text = "TELEPORT"
    TP.TextColor3 = Color3.fromRGB(255,255,255)
    TP.TextSize = 10
    TP.Font = Enum.Font.GothamBold
    TP.BorderSizePixel = 0
    TP.Parent = Button

    Instance.new("UICorner", TP).CornerRadius = UDim.new(0,6)

    TP.MouseButton1Click:Connect(function()
        teleport(target)
    end)

    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(43,43,56)
    end)

    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(31,31,42)
    end)
end

--========================================================
-- FILTER
--========================================================

function refreshList()

    clearList()

    if not Loaded then
        return
    end

    local query = string.lower(Search.Text or "")
    local shown = 0

    for _, target in ipairs(LoadedNPCs) do

        local show = true

        if CurrentTab == "MUZAN" then
            show = target.IsMuzan

        elseif CurrentTab == "NPC" then
            show = not target.IsMuzan
        end

        if show and query ~= "" then

            local name =
                string.lower(target.Name)

            local path =
                string.lower(target.Path)

            show =
                string.find(
                    name,
                    query,
                    1,
                    true
                ) ~= nil

                or

                string.find(
                    path,
                    query,
                    1,
                    true
                ) ~= nil
        end

        if show then
            createButton(target)
            shown += 1
        end
    end

    Status.Text =
        "Loaded: "
        .. #LoadedNPCs
        .. " | Showing: "
        .. shown
end

--========================================================
-- SEARCH
--========================================================

Search:GetPropertyChangedSignal("Text"):Connect(function()

    if Loaded then
        refreshList()
    end

end)

--========================================================
-- TAB
--========================================================

local function selectTab(tab)

    CurrentTab = tab

    AllTab.BackgroundColor3 =
        Color3.fromRGB(35,35,46)

    MuzanTab.BackgroundColor3 =
        Color3.fromRGB(35,35,46)

    NpcTab.BackgroundColor3 =
        Color3.fromRGB(35,35,46)

    if tab == "ALL" then

        AllTab.BackgroundColor3 =
            Color3.fromRGB(75,95,180)

    elseif tab == "MUZAN" then

        MuzanTab.BackgroundColor3 =
            Color3.fromRGB(170,55,65)

    elseif tab == "NPC" then

        NpcTab.BackgroundColor3 =
            Color3.fromRGB(75,95,180)

    end

    refreshList()
end

AllTab.MouseButton1Click:Connect(function()
    selectTab("ALL")
end)

MuzanTab.MouseButton1Click:Connect(function()
    selectTab("MUZAN")
end)

NpcTab.MouseButton1Click:Connect(function()
    selectTab("NPC")
end)

--========================================================
-- LOAD BUTTON
--========================================================

Load.MouseButton1Click:Connect(function()
    task.spawn(loadAllNPC)
end)

--========================================================
-- CLOSE
--========================================================

Close.MouseButton1Click:Connect(function()
    GUI:Destroy()
end)

--========================================================
-- DRAG
--========================================================

local dragging = false
local dragStart
local startPos

Header.InputBegan:Connect(function(input)

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

UIS.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta =
            input.Position - dragStart

        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )

    end

end)

--========================================================
-- START
--========================================================

selectTab("ALL")

Status.Text =
    "Nhấn LOAD NPC để scan toàn map"
