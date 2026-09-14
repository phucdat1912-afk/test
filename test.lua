local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

-- Xóa GUI cũ
pcall(function()
    game:GetService("CoreGui"):FindFirstChild("PackScanner"):Destroy()
end)

local gui = Instance.new("ScreenGui")
gui.Name = "PackScanner"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 500)
frame.Position = UDim2.new(0.5, -200, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-20,0,45)
title.Position = UDim2.new(0,10,0,5)
title.BackgroundTransparency = 1
title.Text = "PACK SCANNER"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-20,0,35)
status.Position = UDim2.new(0,10,0,50)
status.BackgroundTransparency = 1
status.Text = "Sẵn sàng"
status.TextColor3 = Color3.new(1,1,1)
status.TextSize = 17
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame

local scanButton = Instance.new("TextButton")
scanButton.Size = UDim2.new(0,120,0,40)
scanButton.Position = UDim2.new(1,-130,0,50)
scanButton.BackgroundColor3 = Color3.fromRGB(50,120,255)
scanButton.Text = "SCAN"
scanButton.TextColor3 = Color3.new(1,1,1)
scanButton.TextSize = 16
scanButton.Font = Enum.Font.GothamBold
scanButton.Parent = frame

Instance.new("UICorner", scanButton).CornerRadius = UDim.new(0,6)

local results = Instance.new("ScrollingFrame")
results.Size = UDim2.new(1,-20,1,-140)
results.Position = UDim2.new(0,10,0,100)
results.BackgroundColor3 = Color3.fromRGB(15,15,15)
results.BorderSizePixel = 0
results.ScrollBarThickness = 6
results.CanvasSize = UDim2.new(0,0,0,0)
results.Parent = frame

Instance.new("UICorner", results).CornerRadius = UDim.new(0,6)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,3)
layout.Parent = results

local function clearResults()
    for _, child in ipairs(results:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    results.CanvasSize = UDim2.new(0,0,0,0)
end

local function addResult(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-10,0,24)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.TextSize = 13
    label.Font = Enum.Font.Code
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = false
    label.Parent = results

    task.wait()

    results.CanvasSize = UDim2.new(
        0,
        0,
        0,
        layout.AbsoluteContentSize.Y + 10
    )
end

local scanning = false

local function scan()
    if scanning then
        return
    end

    scanning = true
    scanButton.Text = "SCANNING..."
    scanButton.Active = false

    clearResults()

    status.Text = "🔍 Đang quét ReplicatedStorage..."
    status.TextColor3 = Color3.new(1,1,0)

    local found = 0
    local scanned = 0

    local objects = ReplicatedStorage:GetDescendants()
    local total = #objects

    addResult("========== SCAN START ==========")
    addResult("Tổng object: " .. total)
    addResult("")

    for _, obj in ipairs(objects) do
        scanned += 1

        if scanned % 25 == 0 then
            status.Text = "🔍 Đang quét: " .. scanned .. "/" .. total
            task.wait()
        end

        local name = obj.Name:lower()

        if name:find("pack")
        or name:find("offer")
        or name:find("conveyor")
        or name:find("card") then

            found += 1

            addResult(
                "[" .. obj.ClassName .. "] " ..
                obj:GetFullName()
            )
        end
    end

    addResult("")
    addResult("========== SCAN COMPLETE ==========")
    addResult("Tìm thấy: " .. found .. " object")

    status.Text = "✅ QUÉT XONG — tìm thấy " .. found
    status.TextColor3 = Color3.fromRGB(0,255,100)

    scanButton.Text = "SCAN"
    scanButton.Active = true

    scanning = false
end

scanButton.MouseButton1Click:Connect(scan)

-- Kéo cửa sổ
local dragging = false
local dragStart
local startPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then

        dragStart = dragStart
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false
    end
end)
