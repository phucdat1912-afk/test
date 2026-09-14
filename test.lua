local RS = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

pcall(function()
    local old = CoreGui:FindFirstChild("RemoteFinder")
    if old then old:Destroy() end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "RemoteFinder"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,420,0,450)
frame.Position = UDim2.new(0.5,-210,0.5,-225)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-20,0,40)
title.Position = UDim2.new(0,10,0,5)
title.BackgroundTransparency = 1
title.Text = "REMOTE FINDER"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = frame

local box = Instance.new("TextBox")
box.Size = UDim2.new(1,-20,1,-100)
box.Position = UDim2.new(0,10,0,50)
box.BackgroundColor3 = Color3.fromRGB(10,10,10)
box.TextColor3 = Color3.new(1,1,1)
box.TextSize = 13
box.Font = Enum.Font.Code
box.TextXAlignment = Enum.TextXAlignment.Left
box.TextYAlignment = Enum.TextYAlignment.Top
box.MultiLine = true
box.ClearTextOnFocus = false
box.TextEditable = true
box.TextWrapped = false
box.Text = "Đang quét..."
box.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.new(0,100,0,35)
close.Position = UDim2.new(0.5,-50,1,-45)
close.BackgroundColor3 = Color3.fromRGB(180,50,50)
close.Text = "CLOSE"
close.TextColor3 = Color3.new(1,1,1)
close.TextSize = 15
close.Font = Enum.Font.GothamBold
close.Parent = frame

local output = {}

local function add(text)
    table.insert(output,text)
end

add("========== REMOTE FINDER ==========")
add("")

local keywords = {
    "refresh",
    "pack",
    "card",
    "roll",
    "buy",
    "offer",
    "conveyor"
}

local found = 0

for _,obj in ipairs(RS:GetDescendants()) do

    if obj:IsA("RemoteEvent")
    or obj:IsA("RemoteFunction") then

        local name = obj.Name:lower()
        local path = obj:GetFullName():lower()

        for _,keyword in ipairs(keywords) do

            if name:find(keyword,1,true)
            or path:find(keyword,1,true) then

                found += 1

                add(
                    "[" .. obj.ClassName .. "] " ..
                    obj:GetFullName()
                )

                break
            end
        end
    end
end

add("")
add("========== DONE ==========")
add("Found: "..found)

local result = table.concat(output,"\n")
box.Text = result

-- THỬ TỰ COPY
task.wait(0.5)

local copied = false

local clipboardFunctions = {
    function()
        if setclipboard then
            setclipboard(result)
            return true
        end
    end,

    function()
        if toclipboard then
            toclipboard(result)
            return true
        end
    end,

    function()
        if set_clipboard then
            set_clipboard(result)
            return true
        end
    end,

    function()
        if Clipboard then
            Clipboard.set(result)
            return true
        end
    end
}

for _,func in ipairs(clipboardFunctions) do
    local success, value = pcall(func)

    if success and value == true then
        copied = true
        break
    end
end

if copied then
    title.Text = "REMOTE FINDER - COPIED!"
else
    title.Text = "REMOTE FINDER - COPY FAILED"
end

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
