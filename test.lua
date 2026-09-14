local ReplicatedStorage = game:GetService("ReplicatedStorage")

local gui = Instance.new("ScreenGui")
gui.Name = "RemoteScanner"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 500, 0, 500)
frame.Position = UDim2.new(0.5, -250, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.Text = "REMOTE SCANNER"
title.TextSize = 20
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Parent = frame

local box = Instance.new("TextBox")
box.Position = UDim2.new(0, 10, 0, 50)
box.Size = UDim2.new(1, -20, 1, -110)
box.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
box.TextColor3 = Color3.new(1, 1, 1)
box.TextSize = 14
box.Font = Enum.Font.Code
box.TextXAlignment = Enum.TextXAlignment.Left
box.TextYAlignment = Enum.TextYAlignment.Top
box.MultiLine = true
box.ClearTextOnFocus = false
box.TextEditable = false
box.Text = "Đang quét..."
box.Parent = frame

local copy = Instance.new("TextButton")
copy.Position = UDim2.new(0, 10, 1, -50)
copy.Size = UDim2.new(0, 150, 0, 40)
copy.Text = "COPY ALL"
copy.TextSize = 16
copy.TextColor3 = Color3.new(1, 1, 1)
copy.BackgroundColor3 = Color3.fromRGB(50, 120, 255)
copy.Parent = frame

local close = Instance.new("TextButton")
close.Position = UDim2.new(1, -110, 1, -50)
close.Size = UDim2.new(0, 100, 0, 40)
close.Text = "CLOSE"
close.TextSize = 16
close.TextColor3 = Color3.new(1, 1, 1)
close.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
close.Parent = frame

local output = {}

local function add(text)
    table.insert(output, text)
end

add("========== REFRESH SCAN ==========")
add("")

for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then

        local name = obj.Name:lower()
        local path = obj:GetFullName():lower()

        if name:find("refresh")
        or name:find("card")
        or name:find("pack")
        or name:find("offer")
        or name:find("conveyor")
        or path:find("refresh")
        or path:find("card")
        or path:find("pack")
        or path:find("offer")
        or path:find("conveyor") then

            add(
                "[" .. obj.ClassName .. "] " ..
                obj:GetFullName()
            )
        end
    end
end

add("")
add("========== SCAN COMPLETE ==========")

local finalText = table.concat(output, "\n")
box.Text = finalText

copy.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(finalText)
        copy.Text = "COPIED!"
        task.wait(1)
        copy.Text = "COPY ALL"
    else
        box.Text = finalText .. "\n\n[Delta không hỗ trợ setclipboard]"
    end
end)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
