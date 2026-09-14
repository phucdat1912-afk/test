local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local old = Player.PlayerGui:FindFirstChild("ConveyorEventSpy")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "ConveyorEventSpy"
gui.ResetOnSpawn = false
gui.Parent = Player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 650, 0, 450)
frame.Position = UDim2.new(0.5, -325, 0.5, -225)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.Text = "CONVEYOR EVENT SPY"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 18
title.Parent = frame

local copyButton = Instance.new("TextButton")
copyButton.Position = UDim2.new(1, -95, 0, 5)
copyButton.Size = UDim2.new(0, 85, 0, 30)
copyButton.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
copyButton.Text = "COPY LOG"
copyButton.TextColor3 = Color3.new(1, 1, 1)
copyButton.TextSize = 13
copyButton.Parent = frame

local clearButton = Instance.new("TextButton")
clearButton.Position = UDim2.new(1, -190, 0, 5)
clearButton.Size = UDim2.new(0, 85, 0, 30)
clearButton.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
clearButton.Text = "CLEAR"
clearButton.TextColor3 = Color3.new(1, 1, 1)
clearButton.TextSize = 13
clearButton.Parent = frame

local logBox = Instance.new("TextBox")
logBox.Position = UDim2.new(0, 10, 0, 50)
logBox.Size = UDim2.new(1, -20, 1, -60)
logBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
logBox.BorderSizePixel = 0
logBox.TextColor3 = Color3.new(1, 1, 1)
logBox.TextSize = 14
logBox.Font = Enum.Font.Code
logBox.TextXAlignment = Enum.TextXAlignment.Left
logBox.TextYAlignment = Enum.TextYAlignment.Top
logBox.TextWrapped = false
logBox.MultiLine = true
logBox.ClearTextOnFocus = false
logBox.TextEditable = false
logBox.Text = "Đang chờ event...\n\nBấm Refresh trong game."
logBox.Parent = frame

local lines = {}

local function updateLog()
    logBox.Text = table.concat(lines, "\n")
    logBox.CursorPosition = -1
end

local function addLog(text)
    table.insert(lines, text)

    while #lines > 40 do
        table.remove(lines, 1)
    end

    updateLog()
end

local function dumpValue(value, indent)
    indent = indent or ""

    if typeof(value) ~= "table" then
        return tostring(value)
    end

    local result = {}

    for k, v in pairs(value) do
        if typeof(v) == "table" then
            table.insert(
                result,
                indent .. tostring(k) .. " = {table}"
            )
        else
            table.insert(
                result,
                indent .. tostring(k) .. " = " .. tostring(v)
            )
        end
    end

    return table.concat(result, "\n")
end

clearButton.MouseButton1Click:Connect(function()
    lines = {}
    updateLog()
end)

copyButton.MouseButton1Click:Connect(function()
    local text = logBox.Text

    local success = false

    if setclipboard then
        success = pcall(setclipboard, text)
    elseif toclipboard then
        success = pcall(toclipboard, text)
    elseif Clipboard and Clipboard.set then
        success = pcall(Clipboard.set, text)
    end

    if success then
        copyButton.Text = "COPIED!"
        task.delay(1.5, function()
            if copyButton then
                copyButton.Text = "COPY LOG"
            end
        end)
    else
        copyButton.Text = "Ctrl+A/C"
        logBox.TextEditable = true
        logBox:CaptureFocus()
        logBox.CursorPosition = #logBox.Text + 1
        logBox.SelectionStart = 1
    end
end)

local watchList = {
    "ConveyorCardEvent",
    "ConveyorVisuals",
    "ConveyorLevelChanged",
    "RecoverPackUpdated",
    "AutoRollAnnouncement",
    "StatsRollAnnouncement",
    "TraitRollAnnouncement"
}

for _, remoteName in ipairs(watchList) do
    local remote = Remotes:FindFirstChild(remoteName)

    if remote and remote:IsA("RemoteEvent") then
        addLog("[LISTENING] " .. remoteName)

        remote.OnClientEvent:Connect(function(...)
            local args = {...}

            addLog("")
            addLog("========== " .. remoteName .. " ==========")
            addLog("ARGS: " .. #args)

            for i, value in ipairs(args) do
                addLog(
                    "[" .. i .. "] TYPE="
                    .. typeof(value)
                    .. "\n"
                    .. dumpValue(value, "    ")
                )
            end
        end)
    end
end

addLog("")
addLog("READY - Bấm Refresh trong game.")
