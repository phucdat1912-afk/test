local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

-- Xóa GUI cũ
pcall(function()
    local old = game:GetService("CoreGui"):FindFirstChild("RemoteScanner")
    if old then
        old:Destroy()
    end
end)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "RemoteScanner"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 500, 0, 500)
frame.Position = UDim2.new(0.5, -250, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 45)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "REMOTE SCANNER"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 21
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- Status
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 35)
status.Position = UDim2.new(0, 10, 0, 48)
status.BackgroundTransparency = 1
status.Text = "🔍 Đang chuẩn bị..."
status.TextColor3 = Color3.fromRGB(255, 220, 80)
status.TextSize = 16
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame

-- Kết quả
local box = Instance.new("TextBox")
box.Position = UDim2.new(0, 10, 0, 90)
box.Size = UDim2.new(1, -20, 1, -150)
box.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
box.BorderSizePixel = 0
box.TextColor3 = Color3.new(1, 1, 1)
box.TextSize = 13
box.Font = Enum.Font.Code
box.TextXAlignment = Enum.TextXAlignment.Left
box.TextYAlignment = Enum.TextYAlignment.Top
box.MultiLine = true
box.ClearTextOnFocus = false
box.TextEditable = false
box.TextWrapped = false
box.Text = ""
box.Parent = frame

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 6)
boxCorner.Parent = box

-- Copy button
local copyButton = Instance.new("TextButton")
copyButton.Position = UDim2.new(0, 10, 1, -50)
copyButton.Size = UDim2.new(0, 150, 0, 40)
copyButton.BackgroundColor3 = Color3.fromRGB(50, 120, 255)
copyButton.Text = "COPY ALL"
copyButton.TextColor3 = Color3.new(1, 1, 1)
copyButton.TextSize = 15
copyButton.Font = Enum.Font.GothamBold
copyButton.Parent = frame

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 6)
copyCorner.Parent = copyButton

-- Close
local closeButton = Instance.new("TextButton")
closeButton.Position = UDim2.new(1, -110, 1, -50)
closeButton.Size = UDim2.new(0, 100, 0, 40)
closeButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeButton.Text = "CLOSE"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextSize = 15
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

-- Kéo GUI
local UserInputService = game:GetService("UserInputService")

local dragging = false
local dragStart
local startPosition

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = true
        dragStart = input.Position
        startPosition = frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseMovement then

        local delta = input.Position - dragStart

        frame.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = false
    end
end)

-- Kết quả scan
local output = {}

local function add(text)
    table.insert(output, text)
end

-- Bắt đầu scan
task.spawn(function()

    status.Text = "🔍 Đang quét ReplicatedStorage..."
    
    add("========== REMOTE SCANNER ==========")
    add("")
    add("Game: " .. game.Name)
    add("PlaceId: " .. tostring(game.PlaceId))
    add("")
    add("========== MATCHING REMOTES ==========")
    add("")

    local objects = ReplicatedStorage:GetDescendants()
    local total = #objects
    local scanned = 0
    local found = 0

    for _, obj in ipairs(objects) do

        scanned += 1

        if scanned % 25 == 0 then
            status.Text =
                "🔍 Đang quét: " ..
                scanned ..
                "/" ..
                total

            -- Cho UI cập nhật
            task.wait()
        end

        if obj:IsA("RemoteEvent")
        or obj:IsA("RemoteFunction") then

            local lowerName = obj.Name:lower()
            local lowerPath = obj:GetFullName():lower()

            local match =
                lowerName:find("refresh")
                or lowerName:find("card")
                or lowerName:find("pack")
                or lowerName:find("offer")
                or lowerName:find("conveyor")
                or lowerPath:find("refresh")
                or lowerPath:find("card")
                or lowerPath:find("pack")
                or lowerPath:find("offer")
                or lowerPath:find("conveyor")

            if match then

                found += 1

                add(
                    "[" ..
                    obj.ClassName ..
                    "] " ..
                    obj:GetFullName()
                )

            end
        end
    end

    add("")
    add("========== SCAN COMPLETE ==========")
    add("Scanned: " .. scanned)
    add("Matching remotes: " .. found)

    local finalText = table.concat(output, "\n")

    box.Text = finalText

    status.Text =
        "✅ QUÉT XONG — " ..
        found ..
        " remote"

    status.TextColor3 =
        Color3.fromRGB(0, 255, 100)

    -- TỰ COPY
    if setclipboard then

        local success = pcall(function()
            setclipboard(finalText)
        end)

        if success then
            copyButton.Text = "✅ AUTO COPIED"
        else
            copyButton.Text = "COPY ALL"
        end

    else
        copyButton.Text = "COPY ALL"
    end

    -- Copy thủ công
    copyButton.MouseButton1Click:Connect(function()

        if setclipboard then

            local success = pcall(function()
                setclipboard(finalText)
            end)

            if success then
                copyButton.Text = "✅ COPIED!"

                task.wait(1)

                copyButton.Text = "COPY ALL"
            end

        end

    end)

end)

-- Close
closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
