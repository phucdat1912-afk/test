local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CoreGui = game:GetService("CoreGui")

pcall(function()
    local old = CoreGui:FindFirstChild("RemoteScanner")
    if old then
        old:Destroy()
    end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "RemoteScanner"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 430)
frame.Position = UDim2.new(0.5, -180, 0.5, -215)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

-- TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 40)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "REMOTE SCANNER"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- STATUS
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 30)
status.Position = UDim2.new(0, 10, 0, 45)
status.BackgroundTransparency = 1
status.Text = "Đang chuẩn bị..."
status.TextColor3 = Color3.fromRGB(255, 220, 80)
status.TextSize = 15
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = frame

-- COPY BUTTON
local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.new(0, 110, 0, 35)
copyButton.Position = UDim2.new(0, 10, 0, 80)
copyButton.BackgroundColor3 = Color3.fromRGB(45, 120, 255)
copyButton.Text = "COPY"
copyButton.TextColor3 = Color3.new(1, 1, 1)
copyButton.TextSize = 15
copyButton.Font = Enum.Font.GothamBold
copyButton.Parent = frame

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 6)
copyCorner.Parent = copyButton

-- CLOSE BUTTON
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 80, 0, 35)
closeButton.Position = UDim2.new(1, -90, 0, 80)
closeButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeButton.Text = "CLOSE"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextSize = 14
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

-- RESULT BOX
local box = Instance.new("TextBox")
box.Size = UDim2.new(1, -20, 0, 300)
box.Position = UDim2.new(0, 10, 0, 125)
box.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
box.BorderSizePixel = 0
box.TextColor3 = Color3.new(1, 1, 1)
box.TextSize = 12
box.Font = Enum.Font.Code
box.TextXAlignment = Enum.TextXAlignment.Left
box.TextYAlignment = Enum.TextYAlignment.Top
box.MultiLine = true
box.ClearTextOnFocus = false
box.TextEditable = true
box.TextWrapped = false
box.Text = "Đang quét..."
box.Parent = frame

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 6)
boxCorner.Parent = box

-- KẾT QUẢ
local output = {}

local function add(text)
    table.insert(output, text)
end

task.spawn(function()

    add("========== REMOTE SCANNER ==========")
    add("")

    local objects = ReplicatedStorage:GetDescendants()
    local total = #objects
    local scanned = 0
    local found = 0

    for _, obj in ipairs(objects) do

        scanned += 1

        if scanned % 50 == 0 then
            status.Text =
                "🔍 Scanning " ..
                scanned ..
                "/" ..
                total

            box.Text = table.concat(output, "\n")
            task.wait()
        end

        if obj:IsA("RemoteEvent")
        or obj:IsA("RemoteFunction") then

            local name = obj.Name:lower()
            local path = obj:GetFullName():lower()

            if name:find("refresh")
            or name:find("pack")
            or name:find("card")
            or name:find("offer")
            or name:find("conveyor")
            or path:find("refresh")
            or path:find("pack")
            or path:find("card")
            or path:find("offer")
            or path:find("conveyor") then

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
    add("========== DONE ==========")
    add("Scanned: " .. scanned)
    add("Found: " .. found)

    local finalText = table.concat(output, "\n")

    box.Text = finalText
    status.Text = "✅ QUÉT XONG: " .. found
    status.TextColor3 = Color3.fromRGB(0, 255, 100)

    -- Tự copy nếu executor hỗ trợ
    if setclipboard then
        pcall(function()
            setclipboard(finalText)
        end)
    end

end)

-- COPY
copyButton.MouseButton1Click:Connect(function()

    local text = box.Text

    if setclipboard then
        local success = pcall(function()
            setclipboard(text)
        end)

        if success then
            copyButton.Text = "COPIED!"
            task.wait(1)
            copyButton.Text = "COPY"
        end
    else
        -- Không có clipboard thì chọn toàn bộ text
        box:CaptureFocus()
        box.CursorPosition = 1
        box.SelectionStart = #box.Text + 1

        copyButton.Text = "SELECTED"
        task.wait(1)
        copyButton.Text = "COPY"
    end

end)

-- CLOSE
closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- DRAG
local UserInputService = game:GetService("UserInputService")

local dragging = false
local dragStart
local startPos

title.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = true
        dragStart = input.Position
        startPos = frame.Position

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
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )

    end
end)

UserInputService.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = false

    end
end)
