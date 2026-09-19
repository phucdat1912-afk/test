--========================================================
-- PROJECT SLAYERS 2
-- FULL MAP NPC + PLAYER TELEPORT HUB
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

local Targets = {}
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
Main.Size = UDim2.new(0,450,0,600)
Main.Position = UDim2.new(0.5,-225,0.5,-300)
Main.BackgroundColor3 = Color3.fromRGB(18,18,24)
Main.BorderSizePixel = 0
Main.Parent = GUI

Instance.new("UICorner",Main).CornerRadius = UDim.new(0,12)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,55)
Header.BackgroundColor3 = Color3.fromRGB(27,27,36)
Header.BorderSizePixel = 0
Header.Parent = Main

Instance.new("UICorner",Header).CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-100,0,25)
Title.Position = UDim2.new(0,15,0,7)
Title.BackgroundTransparency = 1
Title.Text = "PROJECT SLAYERS 2"
Title.TextColor3 = Color3.new(1,1,1)
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
Close.Position = UDim2.new(1,-43,0,10)
Close.BackgroundColor3 = Color3.fromRGB(150,45,55)
Close.Text = "×"
Close.TextColor3 = Color3.new(1,1,1)
Close.TextSize = 20
Close.Font = Enum.Font.GothamBold
Close.BorderSizePixel = 0
Close.Parent = Header

Instance.new("UICorner",Close).CornerRadius = UDim.new(0,8)

--========================================================
-- LOAD
--========================================================

local LoadButton = Instance.new("TextButton")
LoadButton.Size = UDim2.new(1,-30,0,42)
LoadButton.Position = UDim2.new(0,15,0,70)
LoadButton.BackgroundColor3 = Color3.fromRGB(75,95,180)
LoadButton.Text = "LOAD NPC + PLAYER - FULL MAP"
LoadButton.TextColor3 = Color3.new(1,1,1)
LoadButton.TextSize = 13
LoadButton.Font = Enum.Font.GothamBold
LoadButton.BorderSizePixel = 0
LoadButton.Parent = Main

Instance.new("UICorner",LoadButton).CornerRadius = UDim.new(0,8)

--========================================================
-- SEARCH
--========================================================

local Search = Instance.new("TextBox")
Search.Size = UDim2.new(1,-30,0,38)
Search.Position = UDim2.new(0,15,0,122)
Search.BackgroundColor3 = Color3.fromRGB(30,30,40)
Search.BorderSizePixel = 0
Search.PlaceholderText = "Search NPC / Player..."
Search.PlaceholderColor3 = Color3.fromRGB(120,120,135)
Search.Text = ""
Search.TextColor3 = Color3.new(1,1,1)
Search.TextSize = 13
Search.Font = Enum.Font.Gotham
Search.ClearTextOnFocus = false
Search.Parent = Main

Instance.new("UICorner",Search).CornerRadius = UDim.new(0,8)

local SearchPadding = Instance.new("UIPadding")
SearchPadding.PaddingLeft = UDim.new(0,12)
SearchPadding.Parent = Search

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

local function createTab(text)

    local Button = Instance.new("TextButton")

    Button.Size = UDim2.new(0,95,1,0)
    Button.BackgroundColor3 = Color3.fromRGB(35,35,46)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(200,200,215)
    Button.TextSize = 12
    Button.Font = Enum.Font.GothamBold
    Button.BorderSizePixel = 0
    Button.Parent = Tabs

    Instance.new("UICorner",Button).CornerRadius = UDim.new(0,7)

    return Button
end

local AllTab = createTab("ALL")
local NPCtab = createTab("NPC")
local PlayerTab = createTab("PLAYER")
local MuzanTab = createTab("MUZAN")

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

Instance.new("UICorner",List).CornerRadius = UDim.new(0,8)

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0,6)
Layout.SortOrder = Enum.SortOrder.Name
Layout.Parent = List

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0,8)
Padding.PaddingBottom = UDim.new(0,8)
Padding.PaddingLeft = UDim.new(0,8)
Padding.PaddingRight = UDim.new(0,8)
Padding.Parent = List

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

local function GetRoot(model)

    if not model then
        return nil
    end

    local root = model:FindFirstChild("HumanoidRootPart")

    if root and root:IsA("BasePart") then
        return root
    end

    if model.PrimaryPart
        and model.PrimaryPart:IsA("BasePart") then

        return model.PrimaryPart

    end

    return nil
end

--========================================================
-- ADD TARGET
--========================================================

local function AddTarget(model, targetType)

    if not model or not model:IsA("Model") then
        return
    end

    local root = GetRoot(model)

    if not root then
        return
    end

    Targets[#Targets + 1] = {

        Model = model,
        Root = root,

        Name = model.Name,

        Path = model:GetFullName(),

        Type = targetType

    }
end

--========================================================
-- FULL MAP SCAN
--========================================================

local function ScanFullMap()

    Targets = {}
    Loaded = false

    LoadButton.Text = "SCANNING..."
    Status.Text = "Scanning Players + NPCs..."

    task.wait()

    local Seen = {}

    --====================================================
    -- PLAYERS
    --====================================================

    for _, player in ipairs(Players:GetPlayers()) do

        local character = player.Character

        if character then

            local root = GetRoot(character)

            if root then

                Seen[character] = true

                Targets[#Targets + 1] = {

                    Model = character,
                    Root = root,

                    Name = player.Name,

                    DisplayName = player.DisplayName,

                    Path = character:GetFullName(),

                    Type = "PLAYER",

                    Player = player

                }

            end

        end

    end

    --====================================================
    -- NPC / MODELS
    --====================================================

    for _, obj in ipairs(workspace:GetDescendants()) do

        if obj:IsA("Model")
            and not Seen[obj] then

            local root = GetRoot(obj)

            if root then

                local humanoid =
                    obj:FindFirstChildOfClass("Humanoid")

                local controller =
                    obj:FindFirstChildOfClass(
                        "AnimationController"
                    )

                local prompt =
                    root:FindFirstChildOfClass(
                        "ProximityPrompt"
                    )

                if humanoid
                    or controller
                    or prompt then

                    Seen[obj] = true

                    local Type = "NPC"

                    if obj.Name ==
                        "MuzanLairModel" then

                        Type = "MUZAN"

                    end

                    AddTarget(obj,Type)

                end

            end

        end

    end

    --====================================================
    -- FORCE MUZAN
    --====================================================

    local Debree =
        workspace:FindFirstChild("Debree")

    if Debree then

        local Muzan =
            Debree:FindFirstChild(
                "MuzanLairModel"
            )

        if Muzan
            and Muzan:IsA("Model")
            and GetRoot(Muzan) then

            local exists = false

            for _, target in ipairs(Targets) do

                if target.Model == Muzan then
                    exists = true
                    break
                end

            end

            if not exists then
                AddTarget(Muzan,"MUZAN")
            end

        end

    end

    --====================================================
    -- SORT
    --====================================================

    table.sort(Targets,function(a,b)

        if a.Type ~= b.Type then

            local order = {
                MUZAN = 1,
                NPC = 2,
                PLAYER = 3
            }

            return
                (order[a.Type] or 99)
                <
                (order[b.Type] or 99)

        end

        return string.lower(a.Name)
            < string.lower(b.Name)

    end)

    Loaded = true

    LoadButton.Text =
        "RELOAD NPC + PLAYER"

    Status.Text =
        "Loaded "
        .. tostring(#Targets)
        .. " targets"

    Refresh()

end

--========================================================
-- TELEPORT
--========================================================

local function Teleport(target)

    if not target then
        return
    end

    local character = LP.Character

    if not character then
        return
    end

    local root =
        character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not root then
        return
    end

    if not target.Model
        or not target.Model.Parent then

        Status.Text = "Target no longer exists"
        return

    end

    local targetRoot =
        GetRoot(target.Model)

    if not targetRoot then
        Status.Text = "Root not found"
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
-- CLEAR LIST
--========================================================

local function ClearList()

    for _, child in ipairs(List:GetChildren()) do

        if child:IsA("TextButton")
            or child:IsA("Frame") then

            child:Destroy()

        end

    end

end

--========================================================
-- CREATE ROW
--========================================================

local function CreateRow(target)

    local Button = Instance.new("TextButton")

    Button.Size = UDim2.new(1,-4,0,48)
    Button.BackgroundColor3 =
        Color3.fromRGB(31,31,42)

    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = List

    Instance.new("UICorner",Button)
        .CornerRadius = UDim.new(0,7)

    local Name = Instance.new("TextLabel")

    Name.Size = UDim2.new(1,-100,0,22)
    Name.Position = UDim2.new(0,10,0,4)
    Name.BackgroundTransparency = 1

    if target.Type == "PLAYER" then

        Name.Text =
            "PLAYER | "
            .. target.Name

        if target.DisplayName
            and target.DisplayName ~= target.Name then

            Name.Text =
                "PLAYER | "
                .. target.DisplayName
                .. " (@"
                .. target.Name
                .. ")"

        end

        Name.TextColor3 =
            Color3.fromRGB(100,180,255)

    elseif target.Type == "MUZAN" then

        Name.Text = "☠ MUZAN"

        Name.TextColor3 =
            Color3.fromRGB(255,90,90)

    else

        Name.Text = target.Name

        Name.TextColor3 =
            Color3.fromRGB(245,245,255)

    end

    Name.TextSize = 13
    Name.Font = Enum.Font.GothamBold
    Name.TextXAlignment = Enum.TextXAlignment.Left
    Name.TextTruncate = Enum.TextTruncate.AtEnd
    Name.Parent = Button

    local Path = Instance.new("TextLabel")

    Path.Size = UDim2.new(1,-100,0,17)
    Path.Position = UDim2.new(0,10,0,26)
    Path.BackgroundTransparency = 1
    Path.Text = target.Path
    Path.TextColor3 =
        Color3.fromRGB(110,110,130)
    Path.TextSize = 9
    Path.Font = Enum.Font.Gotham
    Path.TextXAlignment = Enum.TextXAlignment.Left
    Path.TextTruncate = Enum.TextTruncate.AtEnd
    Path.Parent = Button

    local TP = Instance.new("TextButton")

    TP.Size = UDim2.new(0,78,0,30)
    TP.Position = UDim2.new(1,-86,0.5,-15)

    if target.Type == "PLAYER" then

        TP.BackgroundColor3 =
            Color3.fromRGB(55,130,190)

    elseif target.Type == "MUZAN" then

        TP.BackgroundColor3 =
            Color3.fromRGB(170,55,65)

    else

        TP.BackgroundColor3 =
            Color3.fromRGB(75,95,180)

    end

    TP.Text = "TELEPORT"
    TP.TextColor3 = Color3.new(1,1,1)
    TP.TextSize = 10
    TP.Font = Enum.Font.GothamBold
    TP.BorderSizePixel = 0
    TP.Parent = Button

    Instance.new("UICorner",TP)
        .CornerRadius = UDim.new(0,6)

    TP.MouseButton1Click:Connect(function()
        Teleport(target)
    end)

end

--========================================================
-- REFRESH
--========================================================

function Refresh()

    ClearList()

    if not Loaded then
        return
    end

    local query =
        string.lower(Search.Text or "")

    local shown = 0

    for _, target in ipairs(Targets) do

        local show = true

        if CurrentTab == "NPC" then

            show =
                target.Type == "NPC"
                or target.Type == "MUZAN"

        elseif CurrentTab == "PLAYER" then

            show =
                target.Type == "PLAYER"

        elseif CurrentTab == "MUZAN" then

            show =
                target.Type == "MUZAN"

        end

        if show and query ~= "" then

            local name =
                string.lower(target.Name)

            local path =
                string.lower(target.Path)

            local display =
                string.lower(
                    target.DisplayName or ""
                )

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

                or

                string.find(
                    display,
                    query,
                    1,
                    true
                ) ~= nil

        end

        if show then

            CreateRow(target)

            shown += 1

        end

    end

    Status.Text =
        "Loaded: "
        .. tostring(#Targets)
        .. " | Showing: "
        .. tostring(shown)

end

--========================================================
-- EVENTS
--========================================================

LoadButton.MouseButton1Click:Connect(function()
    task.spawn(ScanFullMap)
end)

Search:GetPropertyChangedSignal("Text"):Connect(function()

    if Loaded then
        Refresh()
    end

end)

AllTab.MouseButton1Click:Connect(function()

    CurrentTab = "ALL"
    Refresh()

end)

NPCtab.MouseButton1Click:Connect(function()

    CurrentTab = "NPC"
    Refresh()

end)

PlayerTab.MouseButton1Click:Connect(function()

    CurrentTab = "PLAYER"
    Refresh()

end)

MuzanTab.MouseButton1Click:Connect(function()

    CurrentTab = "MUZAN"
    Refresh()

end)

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

    if input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or input.UserInputType ==
        Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()

            if input.UserInputState ==
                Enum.UserInputState.End then

                dragging = false

            end

        end)

    end

end)

UIS.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if input.UserInputType ==
        Enum.UserInputType.MouseMovement
        or input.UserInputType ==
        Enum.UserInputType.Touch then

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

CurrentTab = "ALL"
Status.Text = "Bấm LOAD NPC + PLAYER"
