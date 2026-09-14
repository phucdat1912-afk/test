local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local GetConveyorInfo = ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("GetConveyorInfo")

-- Xóa GUI cũ
pcall(function()
    local old = game:GetService("CoreGui"):FindFirstChild("OuroborosRefresh")
    if old then
        old:Destroy()
    end
end)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "OuroborosRefresh"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- Main
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 180)
main.Position = UDim2.new(0.5, -150, 0.5, -90)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = main

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Ouroboros • Refresh"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Close
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 32, 0, 32)
close.Position = UDim2.new(1, -38, 0, 5)
close.BackgroundColor3 = Color3.fromRGB(180, 55, 55)
close.Text = "×"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 22
close.Font = Enum.Font.GothamBold
close.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = close

-- Refresh button
local refresh = Instance.new("TextButton")
refresh.Size = UDim2.new(1, -30, 0, 50)
refresh.Position = UDim2.new(0, 15, 0, 62)
refresh.BackgroundColor3 = Color3.fromRGB(55, 120, 210)
refresh.Text = "Refresh Cards"
refresh.TextColor3 = Color3.new(1, 1, 1)
refresh.TextSize = 16
refresh.Font = Enum.Font.GothamBold
refresh.Parent = main

local refreshCorner = Instance.new("UICorner")
refreshCorner.CornerRadius = UDim.new(0, 7)
refreshCorner.Parent = refresh

-- Status
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -30, 0, 30)
status.Position = UDim2.new(0, 15, 0, 120)
status.BackgroundTransparency = 1
status.Text = "Ready"
status.TextColor3 = Color3.fromRGB(170, 170, 170)
status.TextSize = 13
status.Font = Enum.Font.Gotham
status.Parent = main

-- Refresh
refresh.MouseButton1Click:Connect(function()

    refresh.Text = "Refreshing..."
    status.Text = "Getting conveyor info..."

    local success, result = pcall(function()
        return GetConveyorInfo:InvokeServer()
    end)

    if success then
        refresh.Text = "Cards Refreshed"
        status.Text = "Refresh completed"

        print("========== REFRESH ==========")
        print(result)
        print("=============================")

    else
        refresh.Text = "Refresh Failed"
        status.Text = tostring(result)

        warn("Refresh error:", result)
    end

    task.wait(1)

    refresh.Text = "Refresh Cards"
    status.Text = "Ready"
end)

-- Close
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Kéo menu
local dragging = false
local dragStart
local startPos

header.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = main.Position

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
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)
