local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- Xóa UI cũ
local old = Player.PlayerGui:FindFirstChild("ConveyorEventSpy")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "ConveyorEventSpy"
gui.ResetOnSpawn = false
gui.Parent = Player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 600, 0, 400)
frame.Position = UDim2.new(0.5, -300, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.Text = "CONVEYOR EVENT SPY"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 18
title.Parent = frame

local log = Instance.new("TextLabel")
log.Position = UDim2.new(0, 10, 0, 50)
log.Size = UDim2.new(1, -20, 1, -60)
log.BackgroundTransparency = 1
log.TextColor3 = Color3.new(1, 1, 1)
log.TextSize = 14
log.Font = Enum.Font.Code
log.TextXAlignment = Enum.TextXAlignment.Left
log.TextYAlignment = Enum.TextYAlignment.Top
log.TextWrapped = false
log.Text = "Đang chờ event...\n\nBấm Refresh trong game."
log.Parent = frame

local lines = {}

local function addLog(text)
    table.insert(lines, text)

    while #lines > 25 do
        table.remove(lines, 1)
    end

    log.Text = table.concat(lines, "\n")
end

local function dumpValue(value, indent)
    indent = indent or ""

    local result = {}

    if typeof(value) == "table" then
        for k, v in pairs(value) do
            local valueText

            if typeof(v) == "table" then
                valueText = "{table}"
            else
                valueText = tostring(v)
            end

            table.insert(
                result,
                indent .. tostring(k) .. " = " .. valueText
            )
        end
    else
        table.insert(result, indent .. tostring(value))
    end

    return table.concat(result, "\n")
end

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
                    "[" .. i .. "] "
                    .. "TYPE=" .. typeof(value)
                    .. " VALUE=" .. dumpValue(value, "    ")
                )
            end
        end)
    end
end

addLog("")
addLog("READY - Bấm Refresh trong game.")
