local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GetConveyorInfo = Remotes:WaitForChild("GetConveyorInfo")

--==================================================
-- XÓA GUI CŨ
--==================================================

pcall(function()
    local old = game:GetService("CoreGui"):FindFirstChild("ACM_Refresh")
    if old then
        old:Destroy()
    end
end)

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "ACM_Refresh"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 420, 0, 360)
main.Position = UDim2.new(0.5, -210, 0.5, -180)
main.BackgroundColor3 = Color3.fromRGB(24,24,24)
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0,8)
mainCorner.Parent = main

--==================================================
-- HEADER
--==================================================

local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,42)
header.BackgroundColor3 = Color3.fromRGB(35,35,35)
header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0,8)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-50,1,0)
title.Position = UDim2.new(0,14,0,0)
title.BackgroundTransparency = 1
title.Text = "Anime Card Multiverse"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local close = Instance.new("TextButton")
close.Size = UDim2.new(0,32,0,32)
close.Position = UDim2.new(1,-38,0,5)
close.BackgroundColor3 = Color3.fromRGB(175,50,50)
close.Text = "×"
close.TextColor3 = Color3.new(1,1,1)
close.TextSize = 22
close.Font = Enum.Font.GothamBold
close.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0,6)
closeCorner.Parent = close

--==================================================
-- REFRESH BUTTON
--==================================================

local refresh = Instance.new("TextButton")
refresh.Size = UDim2.new(1,-30,0,48)
refresh.Position = UDim2.new(0,15,0,57)
refresh.BackgroundColor3 = Color3.fromRGB(55,115,205)
refresh.Text = "Refresh Cards"
refresh.TextColor3 = Color3.new(1,1,1)
refresh.TextSize = 16
refresh.Font = Enum.Font.GothamBold
refresh.Parent = main

local refreshCorner = Instance.new("UICorner")
refreshCorner.CornerRadius = UDim.new(0,7)
refreshCorner.Parent = refresh

--==================================================
-- STATUS
--==================================================

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-30,0,25)
status.Position = UDim2.new(0,15,0,108)
status.BackgroundTransparency = 1
status.Text = "Status: Ready"
status.TextColor3 = Color3.fromRGB(180,180,180)
status.TextSize = 13
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main

--==================================================
-- LOG
--==================================================

local logBox = Instance.new("TextBox")
logBox.Size = UDim2.new(1,-30,0,180)
logBox.Position = UDim2.new(0,15,0,140)
logBox.BackgroundColor3 = Color3.fromRGB(10,10,10)
logBox.TextColor3 = Color3.fromRGB(220,220,220)
logBox.TextSize = 12
logBox.Font = Enum.Font.Code
logBox.TextXAlignment = Enum.TextXAlignment.Left
logBox.TextYAlignment = Enum.TextYAlignment.Top
logBox.MultiLine = true
logBox.ClearTextOnFocus = false
logBox.TextEditable = false
logBox.TextWrapped = false
logBox.Text = "Click Refresh Cards để test..."
logBox.Parent = main

local logCorner = Instance.new("UICorner")
logCorner.CornerRadius = UDim.new(0,6)
logCorner.Parent = logBox

--==================================================
-- LOG SYSTEM
--==================================================

local logs = {}

local function addLog(text)

    table.insert(logs,text)

    -- tối đa 5 log
    while #logs > 5 do
        table.remove(logs,1)
    end

    logBox.Text = table.concat(logs,"\n")
end

--==================================================
-- FORMAT RESULT
--==================================================

local function formatValue(value, depth)

    depth = depth or 0

    if depth > 4 then
        return "..."
    end

    local valueType = typeof(value)

    if valueType == "string" then
        return '"' .. value .. '"'

    elseif valueType == "number"
    or valueType == "boolean"
    or valueType == "nil" then

        return tostring(value)

    elseif valueType == "Instance" then

        return value:GetFullName()

    elseif valueType == "table" then

        local output = "{"

        for key, val in pairs(value) do

            output = output ..
                "\n" ..
                string.rep("  ",depth + 1) ..
                "[" .. tostring(key) .. "] = " ..
                formatValue(val,depth + 1)

        end

        return output ..
            "\n" ..
            string.rep("  ",depth) ..
            "}"

    else

        return tostring(value)

    end
end

--==================================================
-- REFRESH
--==================================================

local refreshing = false

refresh.MouseButton1Click:Connect(function()

    if refreshing then
        return
    end

    refreshing = true

    refresh.Text = "Refreshing..."
    status.Text = "Status: Getting conveyor info..."

    local success, result = pcall(function()

        return GetConveyorInfo:InvokeServer()

    end)

    if success then

        refresh.Text = "Cards Refreshed"
        status.Text = "Status: Success"

        addLog("========== REFRESH ==========")

        print("========== GetConveyorInfo ==========")
        print(formatValue(result))
        print("=====================================")

        -- Hiển thị kết quả trong log
        local formatted = formatValue(result)

        for line in formatted:gmatch("[^\n]+") do
            addLog(line)
        end

    else

        refresh.Text = "Refresh Failed"
        status.Text = "Status: Failed"

        addLog("ERROR: " .. tostring(result))

        warn("GetConveyorInfo error:",result)

    end

    task.wait(1)

    refresh.Text = "Refresh Cards"
    status.Text = "Status: Ready"

    refreshing = false
end)

--==================================================
-- CLOSE
--==================================================

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

--==================================================
-- DRAG MENU
--==================================================

local dragging = false
local dragStart
local startPosition

header.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = main.Position

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

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )

    end
end)
