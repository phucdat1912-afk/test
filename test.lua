local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- Xóa UI cũ
local old = Player.PlayerGui:FindFirstChild("ConveyorEventSpy")
if old then
    old:Destroy()
end

-- =========================
-- GUI
-- =========================

local Gui = Instance.new("ScreenGui")
Gui.Name = "ConveyorEventSpy"
Gui.ResetOnSpawn = false
Gui.Parent = Player.PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 650, 0, 450)
Main.Position = UDim2.new(0.5, -325, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Parent = Gui

-- =========================
-- DRAG
-- =========================

local dragging = false
local dragStart
local startPos

local function updateDrag(input)
    local delta = input.Position - dragStart

    Main.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

local function startDrag(input)
    dragging = true
    dragStart = input.Position
    startPos = Main.Position

    input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            dragging = false
        end
    end)
end

-- =========================
-- TITLE
-- =========================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -200, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "CONVEYOR EVENT SPY"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Main

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        startDrag(input)
    end
end)

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        if dragging then
            updateDrag(input)
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        updateDrag(input)
    end
end)

-- =========================
-- CLOSE
-- =========================

local Close = Instance.new("TextButton")
Close.Position = UDim2.new(1, -40, 0, 5)
Close.Size = UDim2.new(0, 30, 0, 30)
Close.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
Close.Text = "X"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.TextSize = 16
Close.Parent = Main

Close.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)

-- =========================
-- COPY
-- =========================

local Copy = Instance.new("TextButton")
Copy.Position = UDim2.new(1, -145, 0, 5)
Copy.Size = UDim2.new(0, 95, 0, 30)
Copy.BackgroundColor3 = Color3.fromRGB(55, 120, 65)
Copy.Text = "COPY LOG"
Copy.TextColor3 = Color3.new(1, 1, 1)
Copy.TextSize = 13
Copy.Parent = Main

-- =========================
-- CLEAR
-- =========================

local Clear = Instance.new("TextButton")
Clear.Position = UDim2.new(1, -245, 0, 5)
Clear.Size = UDim2.new(0, 90, 0, 30)
Clear.BackgroundColor3 = Color3.fromRGB(120, 65, 65)
Clear.Text = "CLEAR"
Clear.TextColor3 = Color3.new(1, 1, 1)
Clear.TextSize = 13
Clear.Parent = Main

-- =========================
-- REFRESH
-- =========================

local Refresh = Instance.new("TextButton")
Refresh.Position = UDim2.new(0, 10, 0, 45)
Refresh.Size = UDim2.new(0, 100, 0, 32)
Refresh.BackgroundColor3 = Color3.fromRGB(55, 90, 150)
Refresh.Text = "REFRESH"
Refresh.TextColor3 = Color3.new(1, 1, 1)
Refresh.TextSize = 14
Refresh.Parent = Main

-- =========================
-- LOG BOX
-- =========================

local LogBox = Instance.new("TextBox")
LogBox.Position = UDim2.new(0, 10, 0, 85)
LogBox.Size = UDim2.new(1, -20, 1, -95)
LogBox.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
LogBox.BorderSizePixel = 0
LogBox.TextColor3 = Color3.new(1, 1, 1)
LogBox.TextSize = 14
LogBox.Font = Enum.Font.Code
LogBox.TextXAlignment = Enum.TextXAlignment.Left
LogBox.TextYAlignment = Enum.TextYAlignment.Top
LogBox.TextWrapped = false
LogBox.MultiLine = true
LogBox.ClearTextOnFocus = false
LogBox.TextEditable = false
LogBox.Text = "READY\nBấm REFRESH trong game."
LogBox.Parent = Main

-- =========================
-- LOG SYSTEM
-- =========================

local Logs = {}

local function updateLog()
    LogBox.Text = table.concat(Logs, "\n")
end

local function addLog(text)
    table.insert(Logs, tostring(text))

    while #Logs > 50 do
        table.remove(Logs, 1)
    end

    updateLog()
end

Clear.MouseButton1Click:Connect(function()
    Logs = {}
    updateLog()
end)

Copy.MouseButton1Click:Connect(function()
    local text = table.concat(Logs, "\n")

    local success = pcall(function()
        setclipboard(text)
    end)

    if success then
        Copy.Text = "COPIED!"

        task.delay(1.5, function()
            if Copy and Copy.Parent then
                Copy.Text = "COPY LOG"
            end
        end)
    else
        Copy.Text = "FAILED"

        task.delay(1.5, function()
            if Copy and Copy.Parent then
                Copy.Text = "COPY LOG"
            end
        end)
    end
end)

-- =========================
-- WATCH EVENTS
-- =========================

local WatchList = {
    "ConveyorCardEvent",
    "ConveyorVisuals",
    "ConveyorLevelChanged",
    "RecoverPackUpdated",
    "AutoRollAnnouncement",
    "StatsRollAnnouncement",
    "TraitRollAnnouncement"
}

local function dump(value, indent)
    indent = indent or ""

    if typeof(value) ~= "table" then
        return tostring(value)
    end

    local result = {}

    for key, val in pairs(value) do

        if typeof(val) == "table" then
            table.insert(
                result,
                indent .. tostring(key) .. " = {table}"
            )

            local nested = dump(val, indent .. "    ")

            if nested ~= "" then
                table.insert(result, nested)
            end
        else
            table.insert(
                result,
                indent
                .. tostring(key)
                .. " = "
                .. tostring(val)
            )
        end
    end

    return table.concat(result, "\n")
end

for _, remoteName in ipairs(WatchList) do

    local Remote = Remotes:FindFirstChild(remoteName)

    if Remote and Remote:IsA("RemoteEvent") then

        addLog("[LISTENING] " .. remoteName)

        Remote.OnClientEvent:Connect(function(...)

            local args = {...}

            addLog("")
            addLog("========== " .. remoteName .. " ==========")
            addLog("ARGS: " .. #args)

            for i, value in ipairs(args) do

                addLog(
                    "[" .. i .. "] TYPE = "
                    .. typeof(value)
                )

                addLog(
                    dump(value, "    ")
                )
            end
        end)
    end
end

-- =========================
-- REFRESH
-- =========================

local GetConveyorInfo = Remotes:WaitForChild("GetConveyorInfo")

Refresh.MouseButton1Click:Connect(function()

    addLog("")
    addLog(">>> MANUAL REFRESH")

    local success, result = pcall(function()
        return GetConveyorInfo:InvokeServer()
    end)

    if success then
        addLog(
            "GetConveyorInfo RETURN: "
            .. typeof(result)
            .. " = "
            .. tostring(result)
        )
    else
        addLog(
            "GetConveyorInfo ERROR: "
            .. tostring(result)
        )
    end

    addLog(">>> WAITING FOR SERVER EVENTS...")
end)

addLog("")
addLog("READY")
addLog("Bấm REFRESH rồi bấm COPY LOG.")
