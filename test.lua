```lua
--==================================================
-- 1TAP PACK FARM - DEBUG GUI
-- Roblox Studio / Authorized Project
--==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer

if not Player then
    warn("[1TAP] LocalPlayer not found")
    return
end

--==================================================
-- CONFIG
--==================================================

local Running = false
local AntiAFK = true
local Delay = 0.5

local Logs = {}
local MAX_LOGS = 100

--==================================================
-- LOG
--==================================================

local function Log(message)
    local line = os.date("[%H:%M:%S] ") .. tostring(message)

    table.insert(Logs, line)

    if #Logs > MAX_LOGS then
        table.remove(Logs, 1)
    end

    print("[1TAP] " .. line)
end

--==================================================
-- REMOVE OLD GUI
--==================================================

local PlayerGui = Player:WaitForChild("PlayerGui")

local Old = PlayerGui:FindFirstChild("1tap_PackFarm")

if Old then
    Old:Destroy()
end

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "1tap_PackFarm"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(560, 360)
Main.Position = UDim2.new(0.5, -280, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(25,25,30)
Main.BorderSizePixel = 0
Main.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0,10)
Corner.Parent = Main

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-20,0,40)
Title.Position = UDim2.fromOffset(10,5)
Title.BackgroundTransparency = 1
Title.Text = "1TAP PACK FARM"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

--==================================================
-- STATUS
--==================================================

local Status = Instance.new("TextLabel")
Status.Size = UDim2.fromOffset(520,30)
Status.Position = UDim2.fromOffset(20,50)
Status.BackgroundColor3 = Color3.fromRGB(35,35,42)
Status.Text = "Status: Ready"
Status.TextColor3 = Color3.new(1,1,1)
Status.TextSize = 14
Status.Font = Enum.Font.Gotham
Status.Parent = Main

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0,6)
StatusCorner.Parent = Status

--==================================================
-- BUTTON FACTORY
--==================================================

local function Button(text,x,y,w)
    local b = Instance.new("TextButton")

    b.Size = UDim2.fromOffset(w or 160,38)
    b.Position = UDim2.fromOffset(x,y)
    b.BackgroundColor3 = Color3.fromRGB(45,45,55)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 14
    b.Font = Enum.Font.Gotham
    b.Parent = Main

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,6)
    c.Parent = b

    return b
end

--==================================================
-- CONTROLS
--==================================================

local Start = Button(
    "START AUTO ROLL",
    20,
    95,
    165
)

local Stop = Button(
    "STOP",
    195,
    95,
    165
)

local Scan = Button(
    "SCAN PACKS / BOXES",
    370,
    95,
    170
)

local AntiButton = Button(
    "ANTI-AFK: ON",
    20,
    140,
    165
)

local DelayBox = Instance.new("TextBox")
DelayBox.Size = UDim2.fromOffset(165,38)
DelayBox.Position = UDim2.fromOffset(195,140)
DelayBox.BackgroundColor3 = Color3.fromRGB(40,40,48)
DelayBox.TextColor3 = Color3.new(1,1,1)
DelayBox.Text = "0.5"
DelayBox.PlaceholderText = "Delay"
DelayBox.TextSize = 14
DelayBox.Font = Enum.Font.Gotham
DelayBox.Parent = Main

local DelayCorner = Instance.new("UICorner")
DelayCorner.CornerRadius = UDim.new(0,6)
DelayCorner.Parent = DelayBox

--==================================================
-- LOG WINDOW
--==================================================

local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Size = UDim2.fromOffset(520,145)
LogFrame.Position = UDim2.fromOffset(20,190)
LogFrame.BackgroundColor3 = Color3.fromRGB(18,18,22)
LogFrame.BorderSizePixel = 0
LogFrame.ScrollBarThickness = 5
LogFrame.CanvasSize = UDim2.new()
LogFrame.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0,2)
Layout.Parent = LogFrame

local function RefreshLogs()

    for _,v in ipairs(LogFrame:GetChildren()) do
        if v:IsA("TextLabel") then
            v:Destroy()
        end
    end

    for _,message in ipairs(Logs) do

        local label = Instance.new("TextLabel")

        label.Size = UDim2.new(1,-10,0,20)
        label.BackgroundTransparency = 1
        label.Text = message
        label.TextColor3 = Color3.fromRGB(220,220,220)
        label.TextSize = 12
        label.Font = Enum.Font.Code
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = LogFrame
    end

    task.defer(function()
        LogFrame.CanvasSize = UDim2.fromOffset(
            0,
            Layout.AbsoluteContentSize.Y + 5
        )

        LogFrame.CanvasPosition = Vector2.new(
            0,
            math.max(0,Layout.AbsoluteContentSize.Y)
        )
    end)
end

--==================================================
-- SCAN
--==================================================

local function FindPath(root,...)

    local current = root

    for _,name in ipairs({...}) do

        current = current:FindFirstChild(name)

        if not current then
            return nil
        end

    end

    return current
end

local function ScanEverything()

    Log("Starting scan...")

    local boxes = FindPath(
        ReplicatedStorage,
        "Shared",
        "Core",
        "Storage",
        "Game",
        "BoxesLibrary"
    )

    if boxes then

        local count = 0

        for _,obj in ipairs(boxes:GetDescendants()) do
            count += 1
            Log("BOX: "..obj.Name)
        end

        Log("BoxesLibrary objects: "..count)

    else
        Log("ERROR: BoxesLibrary not found")
    end

    local variants = FindPath(
        ReplicatedStorage,
        "Assets",
        "NewVariants"
    )

    if variants then

        local count = 0

        for _,obj in ipairs(variants:GetDescendants()) do
            count += 1
            Log("MUTATION: "..obj.Name)
        end

        Log("NewVariants objects: "..count)

    else
        Log("ERROR: NewVariants not found")
    end

    Status.Text = "Status: Scan complete"

    RefreshLogs()
end

--==================================================
-- ANTI AFK
--==================================================

Player.Idled:Connect(function()

    if not AntiAFK then
        return
    end

    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)

    Log("Anti-AFK triggered")
    RefreshLogs()
end)

--==================================================
-- DELAY
--==================================================

DelayBox.FocusLost:Connect(function()

    local value = tonumber(DelayBox.Text)

    if value and value >= 0.05 then

        Delay = value

        Log("Delay = "..Delay)

    else

        DelayBox.Text = tostring(Delay)

        Log("Invalid delay")
    end

    RefreshLogs()
end)

--==================================================
-- ANTI AFK BUTTON
--==================================================

AntiButton.MouseButton1Click:Connect(function()

    AntiAFK = not AntiAFK

    AntiButton.Text =
        "ANTI-AFK: " ..
        (AntiAFK and "ON" or "OFF")

    Log(
        "Anti-AFK " ..
        (AntiAFK and "enabled" or "disabled")
    )

    RefreshLogs()
end)

--==================================================
-- SCAN BUTTON
--==================================================

Scan.MouseButton1Click:Connect(function()

    ScanEverything()

end)

--==================================================
-- START
--==================================================

Start.MouseButton1Click:Connect(function()

    if Running then
        Log("Auto Roll already running")
        RefreshLogs()
        return
    end

    Running = true

    Status.Text = "Status: Running"

    Log("Auto Roll started")
    RefreshLogs()

    task.spawn(function()

        while Running do

            -- Authorized-project roll hook:
            --
            -- Call your own project's roll function here.
            --
            -- Example:
            -- RollRemote:FireServer()

            Log("Roll tick")
            RefreshLogs()

            task.wait(Delay)
        end

    end)

end)

--==================================================
-- STOP
--==================================================

Stop.MouseButton1Click:Connect(function()

    Running = false

    Status.Text = "Status: Stopped"

    Log("Auto Roll stopped")
    RefreshLogs()

end)

--==================================================
-- INITIAL
--==================================================

Log("GUI loaded successfully")
Log("Ready")

RefreshLogs()

print("[1TAP] GUI loaded")
```
