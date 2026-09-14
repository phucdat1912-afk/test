local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local old = Player.PlayerGui:FindFirstChild("ConveyorSpy")
if old then
    old:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "ConveyorSpy"
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 999999
Gui.Parent = Player.PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(600, 400)
Main.Position = UDim2.new(0.5, -300, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Main.Active = true
Main.Parent = Gui

local function Button(text, x, width)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(width, 35)
    b.Position = UDim2.fromOffset(x, 5)
    b.BackgroundColor3 = Color3.fromRGB(60,60,60)
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = text
    b.TextSize = 14
    b.AutoButtonColor = true
    b.Active = true
    b.ZIndex = 10
    b.Parent = Main
    return b
end

local Refresh = Button("REFRESH", 10, 100)
local Copy = Button("COPY LOG", 120, 100)
local Clear = Button("CLEAR", 230, 100)

local Log = Instance.new("TextBox")
Log.Position = UDim2.fromOffset(10,50)
Log.Size = UDim2.new(1,-20,1,-60)
Log.BackgroundColor3 = Color3.fromRGB(10,10,10)
Log.TextColor3 = Color3.new(1,1,1)
Log.TextSize = 14
Log.Font = Enum.Font.Code
Log.TextXAlignment = Enum.TextXAlignment.Left
Log.TextYAlignment = Enum.TextYAlignment.Top
Log.MultiLine = true
Log.ClearTextOnFocus = false
Log.TextEditable = false
Log.Text = "UI READY\n"
Log.ZIndex = 5
Log.Parent = Main

local logs = {}

local function add(text)
    table.insert(logs, tostring(text))

    while #logs > 50 do
        table.remove(logs, 1)
    end

    Log.Text = table.concat(logs, "\n")
end

Clear.Activated:Connect(function()
    logs = {}
    Log.Text = ""
end)

Copy.Activated:Connect(function()
    local text = table.concat(logs, "\n")

    local ok = pcall(function()
        setclipboard(text)
    end)

    if ok then
        Copy.Text = "COPIED!"
        task.delay(1, function()
            if Copy.Parent then
                Copy.Text = "COPY LOG"
            end
        end)
    end
end)

local GetConveyorInfo = Remotes:WaitForChild("GetConveyorInfo")

Refresh.Activated:Connect(function()
    add("========== REFRESH ==========")

    local ok, result = pcall(function()
        return GetConveyorInfo:InvokeServer()
    end)

    if ok then
        add("TYPE: " .. typeof(result))
        add("VALUE: " .. tostring(result))
    else
        add("ERROR: " .. tostring(result))
    end
end)

add("READY - TEST BUTTON")
