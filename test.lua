local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Xóa UI cũ
pcall(function()
    local old = playerGui:FindFirstChild("RefreshTest")
    if old then
        old:Destroy()
    end
end)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "RefreshTest"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 120)
frame.Position = UDim2.new(0.5, -125, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "Refresh Test"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 16
title.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(1, -20, 0, 45)
button.Position = UDim2.new(0, 10, 0, 55)
button.BackgroundColor3 = Color3.fromRGB(50, 120, 210)
button.Text = "REFRESH CARDS"
button.TextColor3 = Color3.new(1,1,1)
button.TextSize = 16
button.Parent = frame

button.MouseButton1Click:Connect(function()

    button.Text = "Refreshing..."

    local remote = ReplicatedStorage
        :WaitForChild("Remotes")
        :WaitForChild("GetConveyorInfo")

    local success, result = pcall(function()
        return remote:InvokeServer()
    end)

    if success then
        button.Text = "SUCCESS"
        print("GetConveyorInfo:", result)
    else
        button.Text = "FAILED"
        warn("GetConveyorInfo:", result)
    end

    task.wait(1)

    button.Text = "REFRESH CARDS"
end)
