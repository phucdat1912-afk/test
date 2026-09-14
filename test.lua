local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local old = Player.PlayerGui:FindFirstChild("ConveyorSpy2")
if old then
    old:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "ConveyorSpy2"
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 999999
Gui.Parent = Player.PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(650, 450)
Main.Position = UDim2.new(.5,-325,.5,-225)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Main.Active = true
Main.Parent = Gui

local function makeButton(text,x,w)
    local b = Instance.new("TextButton")
    b.Position = UDim2.fromOffset(x,5)
    b.Size = UDim2.fromOffset(w,35)
    b.BackgroundColor3 = Color3.fromRGB(60,60,60)
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = text
    b.TextSize = 14
    b.ZIndex = 10
    b.Active = true
    b.Parent = Main
    return b
end

local Refresh = makeButton("REFRESH",10,100)
local Copy = makeButton("COPY",120,100)
local Clear = makeButton("CLEAR",230,100)

local Log = Instance.new("TextBox")
Log.Position = UDim2.fromOffset(10,50)
Log.Size = UDim2.new(1,-20,1,-60)
Log.BackgroundColor3 = Color3.fromRGB(10,10,10)
Log.TextColor3 = Color3.new(1,1,1)
Log.TextSize = 13
Log.Font = Enum.Font.Code
Log.TextXAlignment = Enum.TextXAlignment.Left
Log.TextYAlignment = Enum.TextYAlignment.Top
Log.MultiLine = true
Log.ClearTextOnFocus = false
Log.TextEditable = false
Log.Text = ""
Log.Parent = Main

local logs = {}

local function add(text)
    table.insert(logs,tostring(text))

    while #logs > 100 do
        table.remove(logs,1)
    end

    Log.Text = table.concat(logs,"\n")
end

Clear.Activated:Connect(function()
    logs = {}
    Log.Text = ""
end)

Copy.Activated:Connect(function()
    pcall(function()
        setclipboard(table.concat(logs,"\n"))
    end)

    Copy.Text = "COPIED!"

    task.delay(1,function()
        if Copy.Parent then
            Copy.Text = "COPY"
        end
    end)
end)

-- =========================================
-- DUMP VALUE
-- =========================================

local function dump(v,indent,depth)
    indent = indent or ""
    depth = depth or 0

    if depth > 4 then
        return indent .. "{MAX DEPTH}"
    end

    if typeof(v) ~= "table" then
        return indent .. tostring(v)
    end

    local out = {
        indent .. "{"
    }

    for k,val in pairs(v) do
        if typeof(val) == "table" then
            table.insert(
                out,
                indent .. "  [" .. tostring(k) .. "] ="
            )

            table.insert(
                out,
                dump(val,indent.."    ",depth+1)
            )
        else
            table.insert(
                out,
                indent
                .. "  ["
                .. tostring(k)
                .. "] = "
                .. tostring(val)
                .. "  <"
                .. typeof(val)
                .. ">"
            )
        end
    end

    table.insert(out,indent.."}")

    return table.concat(out,"\n")
end

-- =========================================
-- LISTEN TO ALL REMOTEEVENTS
-- =========================================

for _,remote in ipairs(Remotes:GetChildren()) do

    if remote:IsA("RemoteEvent") then

        local name = remote.Name

        remote.OnClientEvent:Connect(function(...)

            local args = {...}

            add("")
            add("===== EVENT: "..name.." =====")
            add("ARGS: "..#args)

            for i,value in ipairs(args) do

                add(
                    "["..i.."] "
                    .."TYPE="
                    ..typeof(value)
                )

                add(
                    dump(value,"    ")
                )
            end
        end)

    end
end

-- =========================================
-- REFRESH
-- =========================================

local GetConveyorInfo =
    Remotes:WaitForChild("GetConveyorInfo")

Refresh.Activated:Connect(function()

    add("")
    add("===== MANUAL REFRESH =====")

    local ok,result = pcall(function()
        return GetConveyorInfo:InvokeServer()
    end)

    if ok then
        add(
            "GetConveyorInfo = "
            ..typeof(result)
            .." : "
            ..tostring(result)
        )
    else
        add("ERROR = "..tostring(result))
    end

    add("Waiting for RemoteEvents...")

    task.wait(2)

    add("===== END =====")

end)

add("EVENT SPY READY")
add("Bấm REFRESH trong game.")
