--==================================================
-- NPC + PLAYER HUB
-- FULL MAP SCANNER
--==================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

--==================================================
-- CLEAN OLD GUI
--==================================================

for _, name in ipairs({
    "NPCPlayerHub",
    "NPCPlayerHub_V2",
    "NPCPlayerHub_FULLMAP"
}) do
    local old = PG:FindFirstChild(name)
    if old then
        old:Destroy()
    end
end

--==================================================
-- DATA
--==================================================

local NPCs = {}
local PlayerData = {}
local ESPObjects = {}

local CurrentTab = "ALL"
local ESPEnabled = false

--==================================================
-- GUI
--==================================================

local GUI = Instance.new("ScreenGui")
GUI.Name = "NPCPlayerHub_FULLMAP"
GUI.ResetOnSpawn = false
GUI.Parent = PG

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(430, 600)
Main.Position = UDim2.new(0.5, -215, 0.5, -300)
Main.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
Main.BorderSizePixel = 0
Main.Parent = GUI

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -55, 0, 45)
Title.Position = UDim2.fromOffset(15, 0)
Title.BackgroundTransparency = 1
Title.Text = "NPC + PLAYER HUB"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

--==================================================
-- CLOSE
--==================================================

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(38, 32)
Close.Position = UDim2.new(1, -45, 0, 7)
Close.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
Close.Text = "X"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.TextSize = 16
Close.Font = Enum.Font.GothamBold
Close.Parent = Main

Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 7)

--==================================================
-- LOAD
--==================================================

local Load = Instance.new("TextButton")
Load.Size = UDim2.new(1, -30, 0, 42)
Load.Position = UDim2.fromOffset(15, 50)
Load.BackgroundColor3 = Color3.fromRGB(55, 120, 210)
Load.Text = "LOAD NPC + PLAYER"
Load.TextColor3 = Color3.new(1, 1, 1)
Load.TextSize = 14
Load.Font = Enum.Font.GothamBold
Load.Parent = Main

Instance.new("UICorner", Load).CornerRadius = UDim.new(0, 7)

--==================================================
-- ESP
--==================================================

local ESPButton = Instance.new("TextButton")
ESPButton.Size = UDim2.new(1, -30, 0, 38)
ESPButton.Position = UDim2.fromOffset(15, 100)
ESPButton.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
ESPButton.Text = "ESP: OFF"
ESPButton.TextColor3 = Color3.new(1, 1, 1)
ESPButton.TextSize = 14
ESPButton.Font = Enum.Font.GothamBold
ESPButton.Parent = Main

Instance.new("UICorner", ESPButton).CornerRadius = UDim.new(0, 7)

--==================================================
-- TABS
--==================================================

local Tabs = Instance.new("Frame")
Tabs.Size = UDim2.new(1, -30, 0, 38)
Tabs.Position = UDim2.fromOffset(15, 148)
Tabs.BackgroundTransparency = 1
Tabs.Parent = Main

local function MakeTab(Text, X)
    local Button = Instance.new("TextButton")

    Button.Size = UDim2.new(0.333, -4, 1, 0)
    Button.Position = UDim2.new(X, 0, 0, 0)

    Button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Button.Text = Text
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamBold

    Button.Parent = Tabs

    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

    return Button
end

local AllTab = MakeTab("ALL", 0)
local NPCTab = MakeTab("NPC", 0.333)
local PlayerTab = MakeTab("PLAYER", 0.666)

--==================================================
-- SEARCH
--==================================================

local Search = Instance.new("TextBox")
Search.Size = UDim2.new(1, -30, 0, 38)
Search.Position = UDim2.fromOffset(15, 195)

Search.BackgroundColor3 = Color3.fromRGB(35, 35, 43)

Search.PlaceholderText = "Search loaded NPC / Player..."
Search.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)

Search.Text = ""
Search.TextColor3 = Color3.new(1, 1, 1)

Search.TextSize = 13
Search.Font = Enum.Font.Gotham

Search.ClearTextOnFocus = false
Search.Parent = Main

Instance.new("UICorner", Search).CornerRadius = UDim.new(0, 7)

--==================================================
-- LIST
--==================================================

local List = Instance.new("ScrollingFrame")
List.Size = UDim2.new(1, -30, 1, -250)
List.Position = UDim2.fromOffset(15, 242)

List.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
List.BorderSizePixel = 0

List.ScrollBarThickness = 5
List.CanvasSize = UDim2.new()

List.Parent = Main

Instance.new("UICorner", List).CornerRadius = UDim.new(0, 7)

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 5)
Layout.SortOrder = Enum.SortOrder.Name
Layout.Parent = List

--==================================================
-- ROOT FINDER
--==================================================

local function GetRoot(Object)

    if not Object then
        return nil
    end

    if Object:IsA("BasePart") then
        return Object
    end

    if Object:IsA("Model") then

        if Object.PrimaryPart then
            return Object.PrimaryPart
        end

        local HRP = Object:FindFirstChild("HumanoidRootPart", true)

        if HRP and HRP:IsA("BasePart") then
            return HRP
        end
    end

    return Object:FindFirstChildWhichIsA("BasePart", true)
end

--==================================================
-- SCAN ALL NPC IN WHOLE WORKSPACE
--==================================================

local function ScanNPC()

    table.clear(NPCs)

    local Found = {}

    for _, Object in ipairs(workspace:GetDescendants()) do

        if Object:IsA("Model") then

            local Humanoid = Object:FindFirstChildOfClass("Humanoid")

            if Humanoid then

                local Player = Players:GetPlayerFromCharacter(Object)

                -- Không lấy Player Character
                if not Player then

                    -- Có root mới thêm vào danh sách
                    local Root = GetRoot(Object)

                    if Root and not Found[Object] then

                        Found[Object] = true

                        table.insert(NPCs, Object)
                    end
                end
            end
        end
    end
end

--==================================================
-- SCAN ALL PLAYERS
--==================================================

local function ScanPlayers()

    table.clear(PlayerData)

    for _, Player in ipairs(Players:GetPlayers()) do

        if Player ~= LP then
            table.insert(PlayerData, Player)
        end
    end
end

--==================================================
-- ESP REMOVE
--==================================================

local function RemoveESP(Object)

    local Data = ESPObjects[Object]

    if not Data then
        return
    end

    if Data.Highlight then
        Data.Highlight:Destroy()
    end

    if Data.Billboard then
        Data.Billboard:Destroy()
    end

    ESPObjects[Object] = nil
end

--==================================================
-- ESP ADD
--==================================================

local function AddESP(Object, Text)

    if not Object or not Object.Parent then
        return
    end

    local Root = GetRoot(Object)

    if not Root then
        return
    end

    RemoveESP(Object)

    local Highlight = Instance.new("Highlight")

    Highlight.Name = "HubESP"
    Highlight.Adornee = Object

    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Highlight.FillTransparency = 0.75
    Highlight.OutlineTransparency = 0

    Highlight.Parent = Object

    local Billboard = Instance.new("BillboardGui")

    Billboard.Name = "HubName"
    Billboard.Adornee = Root

    Billboard.Size = UDim2.fromOffset(220, 35)
    Billboard.StudsOffset = Vector3.new(0, 3, 0)

    Billboard.AlwaysOnTop = true

    Billboard.Parent = Object

    local Label = Instance.new("TextLabel")

    Label.Size = UDim2.fromScale(1, 1)
    Label.BackgroundTransparency = 1

    Label.Text = Text
    Label.TextColor3 = Color3.new(1, 1, 1)

    Label.TextStrokeTransparency = 0

    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold

    Label.Parent = Billboard

    ESPObjects[Object] = {
        Highlight = Highlight,
        Billboard = Billboard
    }
end

--==================================================
-- UPDATE ESP
--==================================================

local function UpdateESP()

    for Object in pairs(ESPObjects) do
        RemoveESP(Object)
    end

    if not ESPEnabled then
        return
    end

    for _, NPC in ipairs(NPCs) do

        if NPC and NPC.Parent then
            AddESP(
                NPC,
                "NPC: " .. NPC.Name
            )
        end
    end

    for _, Player in ipairs(PlayerData) do

        if Player and Player.Character then

            AddESP(
                Player.Character,
                "PLAYER: " .. Player.Name
            )
        end
    end
end

--==================================================
-- TELEPORT
--==================================================

local function TeleportTo(Object)

    local Character = LP.Character

    if not Character then
        return
    end

    local Target

    if typeof(Object) == "Instance" then

        if Object:IsA("Model") then
            Target = Object
        end

    elseif typeof(Object) == "table" then

        Target = Object.Character
    end

    if not Target then
        return
    end

    local TargetRoot = GetRoot(Target)

    if not TargetRoot then
        return
    end

    Character:PivotTo(
        TargetRoot.CFrame * CFrame.new(0, 3, 0)
    )
end

--==================================================
-- CLEAR LIST
--==================================================

local function ClearList()

    for _, Child in ipairs(List:GetChildren()) do

        if Child:IsA("GuiObject") then
            Child:Destroy()
        end
    end
end

--==================================================
-- ADD LIST ENTRY
--==================================================

local function AddEntry(Name, Object, Type)

    local Row = Instance.new("Frame")

    Row.Size = UDim2.new(1, -10, 0, 42)

    Row.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    Row.BorderSizePixel = 0

    Row.Parent = List

    Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")

    Label.Size = UDim2.new(1, -95, 1, 0)
    Label.Position = UDim2.fromOffset(10, 0)

    Label.BackgroundTransparency = 1

    Label.Text = Type .. ": " .. Name

    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.TextSize = 12

    Label.Font = Enum.Font.Gotham

    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextTruncate = Enum.TextTruncate.AtEnd

    Label.Parent = Row

    local TP = Instance.new("TextButton")

    TP.Size = UDim2.fromOffset(75, 30)
    TP.Position = UDim2.new(1, -82, 0.5, -15)

    TP.BackgroundColor3 = Color3.fromRGB(55, 120, 210)

    TP.Text = "TELEPORT"

    TP.TextColor3 = Color3.new(1, 1, 1)

    TP.TextSize = 10
    TP.Font = Enum.Font.GothamBold

    TP.Parent = Row

    Instance.new("UICorner", TP).CornerRadius = UDim.new(0, 5)

    TP.Activated:Connect(function()
        TeleportTo(Object)
    end)
end

--==================================================
-- REFRESH
--==================================================

local function Refresh()

    ClearList()

    local Query = string.lower(Search.Text)

    if CurrentTab == "ALL"
        or CurrentTab == "NPC" then

        for _, NPC in ipairs(NPCs) do

            if NPC and NPC.Parent then

                if Query == ""
                    or string.find(
                        string.lower(NPC.Name),
                        Query,
                        1,
                        true
                    ) then

                    AddEntry(
                        NPC.Name,
                        NPC,
                        "NPC"
                    )
                end
            end
        end
    end

    if CurrentTab == "ALL"
        or CurrentTab == "PLAYER" then

        for _, Player in ipairs(PlayerData) do

            if Player and Player.Parent then

                if Query == ""
                    or string.find(
                        string.lower(Player.Name),
                        Query,
                        1,
                        true
                    ) then

                    AddEntry(
                        Player.Name,
                        Player,
                        "PLAYER"
                    )
                end
            end
        end
    end

    task.defer(function()

        List.CanvasSize = UDim2.fromOffset(
            0,
            Layout.AbsoluteContentSize.Y + 10
        )
    end)
end

--==================================================
-- LOAD
--==================================================

Load.Activated:Connect(function()

    Load.Text = "SCANNING WHOLE MAP..."

    task.wait()

    ScanNPC()
    ScanPlayers()

    Load.Text =
        "LOADED "
        .. #NPCs
        .. " NPC / "
        .. #PlayerData
        .. " PLAYER"

    Refresh()

    if ESPEnabled then
        UpdateESP()
    end
end)

--==================================================
-- ESP BUTTON
--==================================================

ESPButton.Activated:Connect(function()

    ESPEnabled = not ESPEnabled

    if ESPEnabled then

        ESPButton.Text = "ESP: ON"

        UpdateESP()

    else

        ESPButton.Text = "ESP: OFF"

        for Object in pairs(ESPObjects) do
            RemoveESP(Object)
        end
    end
end)

--==================================================
-- TABS
--==================================================

AllTab.Activated:Connect(function()

    CurrentTab = "ALL"

    Refresh()
end)

NPCTab.Activated:Connect(function()

    CurrentTab = "NPC"

    Refresh()
end)

PlayerTab.Activated:Connect(function()

    CurrentTab = "PLAYER"

    Refresh()
end)

--==================================================
-- SEARCH
--==================================================

Search:GetPropertyChangedSignal("Text"):Connect(function()
    Refresh()
end)

--==================================================
-- CLOSE SCRIPT
--==================================================

Close.Activated:Connect(function()

    ESPEnabled = false

    for Object in pairs(ESPObjects) do
        RemoveESP(Object)
    end

    table.clear(NPCs)
    table.clear(PlayerData)

    GUI:Destroy()
end)

--==================================================
-- DRAG
--==================================================

local Dragging = false
local DragStart
local StartPosition

Title.InputBegan:Connect(function(Input)

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

UIS.InputChanged:Connect(function(Input)

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

print("================================")
print(" NPC + PLAYER HUB")
print(" FULL MAP SCANNER")
print(" NPC SOURCE: WORKSPACE")
print("================================")
