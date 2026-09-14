local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

pcall(function()
    local old = CoreGui:FindFirstChild("RefreshRemoteSpy")
    if old then
        old:Destroy()
    end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "RefreshRemoteSpy"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 500, 0, 420)
frame.Position = UDim2.new(0.5, -250, 0.5, -210)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-20,0,40)
title.Position = UDim2.new(0,10,0,5)
title.BackgroundTransparency = 1
title.Text = "REFRESH REMOTE SPY"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = frame

local box = Instance.new("TextBox")
box.Size = UDim2.new(1,-20,1,-105)
box.Position = UDim2.new(0,10,0,50)
box.BackgroundColor3 = Color3.fromRGB(10,10,10)
box.TextColor3 = Color3.new(1,1,1)
box.TextSize = 13
box.Font = Enum.Font.Code
box.TextXAlignment = Enum.TextXAlignment.Left
box.TextYAlignment = Enum.TextYAlignment.Top
box.TextWrapped = false
box.MultiLine = true
box.ClearTextOnFocus = false
box.TextEditable = false
box.Text = "Nhấn START SPY rồi click Refresh trong game..."
box.Parent = frame

local start = Instance.new("TextButton")
start.Size = UDim2.new(0,150,0,40)
start.Position = UDim2.new(0,10,1,-50)
start.BackgroundColor3 = Color3.fromRGB(45,150,70)
start.Text = "START SPY"
start.TextColor3 = Color3.new(1,1,1)
start.TextSize = 15
start.Font = Enum.Font.GothamBold
start.Parent = frame

local clear = Instance.new("TextButton")
clear.Size = UDim2.new(0,100,0,40)
clear.Position = UDim2.new(0,170,1,-50)
clear.BackgroundColor3 = Color3.fromRGB(70,70,70)
clear.Text = "CLEAR"
clear.TextColor3 = Color3.new(1,1,1)
clear.TextSize = 15
clear.Font = Enum.Font.GothamBold
clear.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.new(0,100,0,40)
close.Position = UDim2.new(1,-110,1,-50)
close.BackgroundColor3 = Color3.fromRGB(180,50,50)
close.Text = "CLOSE"
close.TextColor3 = Color3.new(1,1,1)
close.TextSize = 15
close.Font = Enum.Font.GothamBold
close.Parent = frame

local spying = false
local logs = {}
local seen = {}

local function addLog(text)
    table.insert(logs, text)

    if #logs > 100 then
        table.remove(logs, 1)
    end

    box.Text = table.concat(logs, "\n")
end

local function getValue(value, depth)
    depth = depth or 0

    if depth > 2 then
        return "..."
    end

    local t = typeof(value)

    if t == "string" then
        return '"' .. value .. '"'
    elseif t == "number" or t == "boolean" or t == "nil" then
        return tostring(value)
    elseif t == "Instance" then
        return value:GetFullName()
    elseif t == "table" then
        local result = "{"

        for k,v in pairs(value) do
            result = result ..
                "[" .. tostring(k) .. "]=" ..
                getValue(v, depth + 1) ..
                ", "
        end

        return result .. "}"
    else
        return tostring(value)
    end
end

-- Hook remote calls
local oldNamecall

if hookmetamethod and getnamecallmethod then

    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()

        if spying and
            (method == "FireServer" or method == "InvokeServer") and
            (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then

            local args = {...}
            local path = self:GetFullName()

            local id = method .. "|" .. path

            if not seen[id] then
                seen[id] = true

                addLog("")
                addLog("========== REMOTE ==========")
                addLog("Method: " .. method)
                addLog("Remote: " .. path)

                if #args > 0 then
                    addLog("Arguments:")

                    for i,v in ipairs(args) do
                        addLog(
                            "  [" .. i .. "] " ..
                            getValue(v)
                        )
                    end
                else
                    addLog("Arguments: NONE")
                end

                addLog("============================")
            end
        end

        return oldNamecall(self, ...)
    end)

else
    addLog("Executor không hỗ trợ hookmetamethod.")
end

start.MouseButton1Click:Connect(function()

    spying = not spying

    if spying then
        seen = {}
        logs = {}

        box.Text =
            "SPY ĐANG BẬT\n\n" ..
            "Bây giờ hãy click REFRESH trong game."

        start.Text = "STOP SPY"
        start.BackgroundColor3 = Color3.fromRGB(180,120,40)

    else

        start.Text = "START SPY"
        start.BackgroundColor3 = Color3.fromRGB(45,150,70)

        addLog("")
        addLog("SPY STOPPED")

    end
end)

clear.MouseButton1Click:Connect(function()
    logs = {}
    seen = {}
    box.Text = "Đã clear log."
end)

close.MouseButton1Click:Connect(function()
    spying = false
    gui:Destroy()
end)
