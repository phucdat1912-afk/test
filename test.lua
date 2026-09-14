local ReplicatedStorage = game:GetService("ReplicatedStorage")

local gui = Instance.new("ScreenGui")
gui.Name = "RemoteScanner"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 500, 0, 500)
frame.Position = UDim2.new(0.5, -250, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,45)
title.Text = "REFRESH REMOTE SCANNER"
title.TextSize = 20
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Parent = frame

local result = Instance.new("ScrollingFrame")
result.Position = UDim2.new(0,10,0,50)
result.Size = UDim2.new(1,-20,1,-60)
result.BackgroundColor3 = Color3.fromRGB(10,10,10)
result.ScrollBarThickness = 6
result.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Parent = result

local function add(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-10,0,25)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = result

    result.CanvasSize = UDim2.new(
        0,0,0,
        layout.AbsoluteContentSize.Y + 10
    )
end

add("========== REMOTES ==========")

local count = 0

for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do

    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then

        count += 1

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
add("========== DONE ==========")
add("Total Remotes: " .. count)
