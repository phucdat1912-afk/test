```lua
--==================================================
-- 1TAP PACK FARM
-- AUTHORIZED ROBLOX STUDIO / OWNED PROJECT
--
-- Features:
--   • Scan BoxesLibrary
--   • Scan NewVariants
--   • Pack/Box search + selection
--   • Mutation search + selection
--   • Auto Roll
--   • Delay
--   • Anti-AFK
--   • Logs
--==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer

--==================================================
-- CONFIG
--==================================================

local Delay = 0.5
local Running = false
local AntiAFK = true

local SelectedBoxes = {}
local SelectedMutations = {}

local Logs = {}
local MAX_LOGS = 100

--==================================================
-- LOG SYSTEM
--==================================================

local function AddLog(message)
    local time = os.date("%H:%M:%S")
    local line = "[" .. time .. "] " .. tostring(message)

    table.insert(Logs, line)

    if #Logs > MAX_LOGS then
        table.remove(Logs, 1)
    end

    print("[1TAP]", line)
end

--==================================================
-- SAFE PATH FINDER
--==================================================

local function GetPath(root, ...)
    local current = root

    for _, name in ipairs({...}) do
        current = current:FindFirstChild(name)

        if not current then
            return nil
        end
    end

    return current
end

--==================================================
-- BOX SCANNER
--==================================================

local function ScanBoxes()
    local result = {}

    local library = GetPath(
        ReplicatedStorage,
        "Shared",
        "Core",
        "Storage",
        "Game",
        "BoxesLibrary"
    )

    if not library then
        AddLog("ERROR: BoxesLibrary not found")
        return result
    end

    for _, obj in ipairs(library:GetDescendants()) do
        if not result[obj.Name] then
            result[obj.Name] = true
        end
    end

    AddLog("BoxesLibrary scanned")

    return result
end

--==================================================
-- MUTATION SCANNER
--==================================================

local function ScanMutations()
    local result = {}

    local variants = GetPath(
        ReplicatedStorage,
        "Assets",
        "NewVariants"
    )

    if not variants then
        AddLog("ERROR: NewVariants not found")
        return result
    end

    for _, obj in ipairs(variants:GetDescendants()) do
        if not result[obj.Name] then
            result[obj.Name] = true
        end
    end

    AddLog("NewVariants scanned")

    return result
end

--==================================================
-- ANTI AFK
--==================================================

Player.Idled:Connect(function()
    if not AntiAFK then
        return
    end

    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())

    AddLog("Anti-AFK activity")
end)

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "1tap_PackFarm"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- For an authorized Studio project, PlayerGui is preferred.
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(650, 430)
Main.Position = UDim2.new(0.5, -325, 0.5, -215)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Main

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 40)
Title.Position = UDim2.fromOffset(10, 5)
Title.BackgroundTransparency = 1
Title.Text = "1TAP PACK FARM"
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

--==================================================
-- DRAG
--==================================================

local dragging = false
local dragStart
local startPos

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

--==================================================
-- BUTTON FACTORY
--==================================================

local function CreateButton(text, position, size)
    local button = Instance.new("TextButton")

    button.Size = size or UDim2.fromOffset(130, 35)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Parent = Main

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button

    return button
end

--==================================================
-- SEARCH BOXES
--==================================================

local BoxSearch = Instance.new("TextBox")
BoxSearch.Size = UDim2.fromOffset(285, 32)
BoxSearch.Position = UDim2.fromOffset(20, 65)
BoxSearch.PlaceholderText = "Search Box / Pack..."
BoxSearch.Text = ""
BoxSearch.TextSize = 14
BoxSearch.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
BoxSearch.TextColor3 = Color3.new(1, 1, 1)
BoxSearch.Parent = Main

local MutationSearch = Instance.new("TextBox")
MutationSearch.Size = UDim2.fromOffset(285, 32)
MutationSearch.Position = UDim2.fromOffset(325, 65)
MutationSearch.PlaceholderText = "Search Mutation..."
MutationSearch.Text = ""
MutationSearch.TextSize = 14
MutationSearch.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
MutationSearch.TextColor3 = Color3.new(1, 1, 1)
MutationSearch.Parent = Main

--==================================================
-- LIST CONTAINERS
--==================================================

local BoxList = Instance.new("ScrollingFrame")
BoxList.Size = UDim2.fromOffset(285, 180)
BoxList.Position = UDim2.fromOffset(20, 105)
BoxList.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
BoxList.BorderSizePixel = 0
BoxList.ScrollBarThickness = 5
BoxList.CanvasSize = UDim2.new()
BoxList.Parent = Main

local MutationList = Instance.new("ScrollingFrame")
MutationList.Size = UDim2.fromOffset(285, 180)
MutationList.Position = UDim2.fromOffset(325, 105)
MutationList.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
MutationList.BorderSizePixel = 0
MutationList.ScrollBarThickness = 5
MutationList.CanvasSize = UDim2.new()
MutationList.Parent = Main

local BoxLayout = Instance.new("UIListLayout")
BoxLayout.Padding = UDim.new(0, 3)
BoxLayout.Parent = BoxList

local MutationLayout = Instance.new("UIListLayout")
MutationLayout.Padding = UDim.new(0, 3)
MutationLayout.Parent = MutationList

--==================================================
-- CLEAR LIST
--==================================================

local function ClearList(list)
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
end

--==================================================
-- BUILD BOX LIST
--==================================================

local AllBoxes = {}

local function BuildBoxList()
    ClearList(BoxList)

    local query = string.lower(BoxSearch.Text)

    for name in pairs(AllBoxes) do
        if query == "" or string.find(string.lower(name), query, 1, true) then

            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, -10, 0, 28)
            button.BackgroundColor3 = SelectedBoxes[name]
                and Color3.fromRGB(60, 100, 60)
                or Color3.fromRGB(45, 45, 55)

            button.Text = name
            button.TextSize = 13
            button.TextColor3 = Color3.new(1, 1, 1)
            button.BorderSizePixel = 0
            button.Parent = BoxList

            button.MouseButton1Click:Connect(function()
                SelectedBoxes[name] = not SelectedBoxes[name]
                BuildBoxList()

                AddLog(
                    "Box " ..
                    name ..
                    (SelectedBoxes[name] and " selected" or " deselected")
                )
            end)
        end
    end

    task.defer(function()
        BoxList.CanvasSize = UDim2.fromOffset(
            0,
            BoxLayout.AbsoluteContentSize.Y + 5
        )
    end)
end

--==================================================
-- BUILD MUTATION LIST
--==================================================

local AllMutations = {}

local function BuildMutationList()
    ClearList(MutationList)

    local query = string.lower(MutationSearch.Text)

    for name in pairs(AllMutations) do
        if query == "" or string.find(string.lower(name), query, 1, true) then

            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, -10, 0, 28)
            button.BackgroundColor3 = SelectedMutations[name]
                and Color3.fromRGB(60, 100, 60)
                or Color3.fromRGB(45, 45, 55)

            button.Text = name
            button.TextSize = 13
            button.TextColor3 = Color3.new(1, 1, 1)
            button.BorderSizePixel = 0
            button.Parent = MutationList

            button.MouseButton1Click:Connect(function()
                SelectedMutations[name] = not SelectedMutations[name]
                BuildMutationList()

                AddLog(
                    "Mutation " ..
                    name ..
                    (SelectedMutations[name]
                        and " selected"
                        or " deselected")
                )
            end)
        end
    end

    task.defer(function()
        MutationList.CanvasSize = UDim2.fromOffset(
            0,
            MutationLayout.AbsoluteContentSize.Y + 5
        )
    end)
end

--==================================================
-- SCAN
--==================================================

local ScanButton = CreateButton(
    "SCAN",
    UDim2.fromOffset(20, 295),
    UDim2.fromOffset(285, 35)
)

ScanButton.MouseButton1Click:Connect(function()

    AddLog("Starting scan...")

    AllBoxes = ScanBoxes()
    AllMutations = ScanMutations()

    BuildBoxList()
    BuildMutationList()

    local boxCount = 0
    local mutationCount = 0

    for _ in pairs(AllBoxes) do
        boxCount += 1
    end

    for _ in pairs(AllMutations) do
        mutationCount += 1
    end

    AddLog(
        "Scan complete | Boxes: " ..
        boxCount ..
        " | Mutations: " ..
        mutationCount
    )
end)

--==================================================
-- DELAY
--==================================================

local DelayBox = Instance.new("TextBox")
DelayBox.Size = UDim2.fromOffset(285, 35)
DelayBox.Position = UDim2.fromOffset(325, 295)
DelayBox.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
DelayBox.TextColor3 = Color3.new(1, 1, 1)
DelayBox.Text = tostring(Delay)
DelayBox.PlaceholderText = "Delay"
DelayBox.TextSize = 14
DelayBox.Parent = Main

DelayBox.FocusLost:Connect(function()
    local value = tonumber(DelayBox.Text)

    if value and value >= 0.05 then
        Delay = value
        AddLog("Delay set to " .. Delay)
    else
        DelayBox.Text = tostring(Delay)
        AddLog("ERROR: Invalid delay")
    end
end)

--==================================================
-- ANTI AFK BUTTON
--==================================================

local AntiAFKButton = CreateButton(
    "Anti-AFK: ON",
    UDim2.fromOffset(20, 340),
    UDim2.fromOffset(180, 35)
)

AntiAFKButton.MouseButton1Click:Connect(function()
    AntiAFK = not AntiAFK

    AntiAFKButton.Text =
        "Anti-AFK: " ..
        (AntiAFK and "ON" or "OFF")

    AddLog(
        "Anti-AFK " ..
        (AntiAFK and "enabled" or "disabled")
    )
end)

--==================================================
-- START / STOP
--==================================================

local StartButton = CreateButton(
    "START AUTO ROLL",
    UDim2.fromOffset(210, 340),
    UDim2.fromOffset(200, 35)
)

local StopButton = CreateButton(
    "STOP",
    UDim2.fromOffset(420, 340),
    UDim2.fromOffset(190, 35)
)

StartButton.MouseButton1Click:Connect(function()

    if Running then
        AddLog("Auto Roll already running")
        return
    end

    Running = true

    AddLog("Auto Roll started")

    task.spawn(function()

        while Running do

            --==================================================
            -- AUTHORIZED PROJECT ROLL HOOK
            --
            -- Connect your own game's roll function here.
            -- Example:
            --
            -- RollRemote:FireServer()
            --
            -- Do not use this GUI to automate a third-party
            -- game without authorization.
            --==================================================

            AddLog("Roll tick")

            task.wait(Delay)
        end

        AddLog("Auto Roll stopped")
    end)
end)

StopButton.MouseButton1Click:Connect(function()

    if not Running then
        AddLog("Auto Roll already stopped")
        return
    end

    Running = false
    AddLog("Auto Roll stopping...")
end)

--==================================================
-- LOG PANEL
--==================================================

local LogTitle = Instance.new("TextLabel")
LogTitle.Size = UDim2.fromOffset(180, 25)
LogTitle.Position = UDim2.fromOffset(20, 385)
LogTitle.BackgroundTransparency = 1
LogTitle.Text = "LOGS"
LogTitle.TextSize = 15
LogTitle.Font = Enum.Font.GothamBold
LogTitle.TextColor3 = Color3.new(1, 1, 1)
LogTitle.TextXAlignment = Enum.TextXAlignment.Left
LogTitle.Parent = Main

local LogOutput = Instance.new("TextLabel")
LogOutput.Size = UDim2.fromOffset(400, 25)
LogOutput.Position = UDim2.fromOffset(120, 385)
LogOutput.BackgroundTransparency = 1
LogOutput.Text = "Ready"
LogOutput.TextSize = 12
LogOutput.TextColor3 = Color3.new(0.8, 0.8, 0.8)
LogOutput.TextXAlignment = Enum.TextXAlignment.Left
LogOutput.Parent = Main

--==================================================
-- LIVE LOG REFRESH
--==================================================

task.spawn(function()

    while ScreenGui.Parent do

        if #Logs > 0 then
            LogOutput.Text = Logs[#Logs]
        else
            LogOutput.Text = "Ready"
        end

        task.wait(0.25)
    end
end)

--==================================================
-- SEARCH EVENTS
--==================================================

BoxSearch:GetPropertyChangedSignal("Text"):Connect(BuildBoxList)
MutationSearch:GetPropertyChangedSignal("Text"):Connect(BuildMutationList)

--==================================================
-- INITIAL SCAN
--==================================================

AddLog("GUI loaded")
AddLog("Press SCAN to scan BoxesLibrary + NewVariants")
```
