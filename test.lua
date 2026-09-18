--==================================================
-- INFINITI TOWER SPEED MONITOR
-- Detect 1x / 2x / 3x changes
--==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

--==================================================
-- REMOVE OLD
--==================================================

pcall(function()
    local old = CoreGui:FindFirstChild("InfinitiSpeedMonitor")

    if old then
        old:Destroy()
    end
end)

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "InfinitiSpeedMonitor"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 650, 0, 420)
Main.Position = UDim2.new(0.5, -325, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(18,18,22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0,10)
Corner.Parent = Main

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 40)
Title.Position = UDim2.new(0,10,0,5)
Title.BackgroundTransparency = 1
Title.Text = "Infiniti Tower Speed Monitor"
Title.TextColor3 = Color3.fromRGB(235,235,240)
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

--==================================================
-- STATUS
--==================================================

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 25)
Status.Position = UDim2.new(0,10,0,42)
Status.BackgroundTransparency = 1
Status.Text = "Monitoring..."
Status.TextColor3 = Color3.fromRGB(70,200,110)
Status.TextSize = 12
Status.Font = Enum.Font.GothamMedium
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

--==================================================
-- LOG
--==================================================

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -115)
Scroll.Position = UDim2.new(0,10,0,75)
Scroll.BackgroundColor3 = Color3.fromRGB(30,30,38)
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 5
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.CanvasSize = UDim2.new()
Scroll.Parent = Main

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0,7)
ScrollCorner.Parent = Scroll

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0,3)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Scroll

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0,6)
Padding.PaddingBottom = UDim.new(0,6)
Padding.PaddingLeft = UDim.new(0,6)
Padding.PaddingRight = UDim.new(0,6)
Padding.Parent = Scroll

local LogIndex = 0

local function Log(Text, Color)

    LogIndex += 1

    local Label = Instance.new("TextLabel")

    Label.Size = UDim2.new(1,0,0,22)

    Label.BackgroundTransparency = 1

    Label.Text =
        "[" ..
        tostring(LogIndex) ..
        "] " ..
        tostring(Text)

    Label.TextColor3 =
        Color or Color3.fromRGB(235,235,240)

    Label.TextSize = 11

    Label.Font = Enum.Font.Code

    Label.TextXAlignment =
        Enum.TextXAlignment.Left

    Label.TextWrapped = false

    Label.Parent = Scroll

    task.defer(function()
        Scroll.CanvasPosition =
            Vector2.new(
                0,
                math.max(
                    0,
                    Scroll.AbsoluteCanvasSize.Y
                )
            )
    end)

end

--==================================================
-- CLEAR
--==================================================

local Clear = Instance.new("TextButton")

Clear.Size = UDim2.new(0,100,0,30)
Clear.Position = UDim2.new(1,-110,1,-38)

Clear.BackgroundColor3 =
    Color3.fromRGB(38,38,46)

Clear.BorderSizePixel = 0

Clear.Text = "CLEAR"

Clear.TextColor3 =
    Color3.fromRGB(235,235,240)

Clear.TextSize = 11

Clear.Font = Enum.Font.GothamBold

Clear.Parent = Main

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0,6)
ClearCorner.Parent = Clear

Clear.MouseButton1Click:Connect(function()

    for _, v in ipairs(Scroll:GetChildren()) do

        if v:IsA("TextLabel") then
            v:Destroy()
        end

    end

    LogIndex = 0

end)

--==================================================
-- DRAG
--==================================================

local UIS = game:GetService("UserInputService")

local Dragging = false
local DragStart
local StartPosition

Title.InputBegan:Connect(function(Input)

    if Input.UserInputType ==
        Enum.UserInputType.MouseButton1 then

        Dragging = true

        DragStart =
            UIS:GetMouseLocation()

        StartPosition =
            Main.Position

    end

end)

UIS.InputEnded:Connect(function(Input)

    if Input.UserInputType ==
        Enum.UserInputType.MouseButton1 then

        Dragging = false

    end

end)

UIS.InputChanged:Connect(function(Input)

    if not Dragging then
        return
    end

    if Input.UserInputType ~=
        Enum.UserInputType.MouseMovement then
        return
    end

    local Mouse =
        UIS:GetMouseLocation()

    local Delta =
        Mouse - DragStart

    Main.Position = UDim2.new(
        StartPosition.X.Scale,
        StartPosition.X.Offset + Delta.X,

        StartPosition.Y.Scale,
        StartPosition.Y.Offset + Delta.Y
    )

end)

--==================================================
-- VALUE MONITOR
--==================================================

local WatchedClasses = {
    "NumberValue",
    "IntValue",
    "StringValue",
    "BoolValue"
}

local function IsWatchedClass(Object)

    for _, ClassName in ipairs(WatchedClasses) do

        if Object:IsA(ClassName) then
            return true
        end

    end

    return false

end

local function GetValue(Object)

    local Success, Result =
        pcall(function()

            return Object.Value

        end)

    if Success then
        return tostring(Result)
    end

    return "?"
end

local function WatchValue(Object)

    if not IsWatchedClass(Object) then
        return
    end

    local LastValue =
        GetValue(Object)

    Object:GetPropertyChangedSignal("Value"):Connect(function()

        local NewValue =
            GetValue(Object)

        if NewValue == LastValue then
            return
        end

        Log(
            "VALUE CHANGE | " ..
            Object:GetFullName() ..
            " | " ..
            LastValue ..
            " -> " ..
            NewValue,
            Color3.fromRGB(235,190,70)
        )

        LastValue = NewValue

    end)

end

--==================================================
-- ATTRIBUTE MONITOR
--==================================================

local function WatchAttributes(Object)

    local Attributes =
        Object:GetAttributes()

    for Name, Value in pairs(Attributes) do

        local LastValue =
            tostring(Value)

        Object:GetAttributeChangedSignal(Name):Connect(function()

            local NewValue =
                Object:GetAttribute(Name)

            local NewString =
                tostring(NewValue)

            if NewString == LastValue then
                return
            end

            Log(
                "ATTRIBUTE CHANGE | " ..
                Object:GetFullName() ..
                " | " ..
                tostring(Name) ..
                " | " ..
                LastValue ..
                " -> " ..
                NewString,
                Color3.fromRGB(100,180,255)
            )

            LastValue = NewString

        end)

    end

end

--==================================================
-- INITIAL SCAN
--==================================================

Log("========================================")
Log("INFINITI SPEED MONITOR STARTED")
Log("========================================")

Log("Player: " .. Player.Name)

Log("Scanning ReplicatedStorage...")

for _, Object in ipairs(
    ReplicatedStorage:GetDescendants()
) do

    if IsWatchedClass(Object) then

        local Name =
            string.lower(
                Object.Name
            )

        if string.find(Name,"speed",1,true)
        or string.find(Name,"fast",1,true)
        or string.find(Name,"time",1,true)
        or string.find(Name,"tower",1,true)
        or string.find(Name,"mult",1,true) then

            Log(
                "FOUND VALUE | " ..
                Object:GetFullName() ..
                " = " ..
                GetValue(Object),
                Color3.fromRGB(70,200,110)
            )

        end

    end

end

--==================================================
-- WATCH EXISTING OBJECTS
--==================================================

for _, Object in ipairs(
    ReplicatedStorage:GetDescendants()
) do

    WatchValue(Object)
    WatchAttributes(Object)

end

for _, Object in ipairs(
    Player:GetDescendants()
) do

    WatchValue(Object)
    WatchAttributes(Object)

end

--==================================================
-- WATCH NEW OBJECTS
--==================================================

ReplicatedStorage.DescendantAdded:Connect(function(Object)

    WatchValue(Object)
    WatchAttributes(Object)

    local Name =
        string.lower(
            Object.Name
        )

    if string.find(Name,"speed",1,true)
    or string.find(Name,"fast",1,true)
    or string.find(Name,"time",1,true)
    or string.find(Name,"tower",1,true)
    or string.find(Name,"mult",1,true) then

        Log(
            "NEW OBJECT | " ..
            Object:GetFullName() ..
            " [" ..
            Object.ClassName ..
            "]",
            Color3.fromRGB(70,200,110)
        )

    end

end)

Player.DescendantAdded:Connect(function(Object)

    WatchValue(Object)
    WatchAttributes(Object)

end)

--==================================================
-- GUI DESCENDANTS
--==================================================

Log("Monitoring ValueBase + Attributes...")
Log("Now enter Infiniti Tower.")
Log("Press 1x -> 2x -> 3x.")
Log("========================================")

--==================================================
-- PERIODIC SEARCH
--==================================================

task.spawn(function()

    while Gui.Parent do

        task.wait(2)

        local Found = {}

        for _, Root in ipairs({
            ReplicatedStorage,
            Player
        }) do

            for _, Object in ipairs(
                Root:GetDescendants()
            ) do

                local Name =
                    string.lower(
                        Object.Name
                    )

                if string.find(Name,"speed",1,true)
                or string.find(Name,"timescale",1,true)
                or string.find(Name,"time",1,true)
                or string.find(Name,"multiplier",1,true)
                or string.find(Name,"fast",1,true) then

                    local Key =
                        Object:GetFullName()

                    if not Found[Key] then

                        Found[Key] = true

                    end

                end

            end

        end

    end

end)
