```lua
--==================================================
-- INSTANT TOKEN COLLECTOR V4
-- ALL 3 FOLDERS
-- ANTI-AFK FROM 1TAP PACK FARM
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Systems = workspace:WaitForChild("Systems")

--==================================================
-- FOLDERS
--==================================================

local VariantFolder =
    Systems:WaitForChild("ActiveVariantTokenSpawns")

local ActiveFolder =
    Systems:WaitForChild("ActiveCollectableObjects")

local CollectFolder =
    Systems:WaitForChild("CollectableObjects")

--==================================================
-- REMOTE
--==================================================

local Remote =
    game:GetService("ReplicatedStorage")
    :WaitForChild("Remotes")
    :WaitForChild("CollectCollectableObject")

--==================================================
-- SETTINGS
--==================================================

local Running = false
local AntiAFK = true

local Processing = {}

local TP_HEIGHT = 3
local SCAN_DELAY = 0.05
local COLLECT_DELAY = 0.08

--==================================================
-- ANTI AFK
-- SAME METHOD AS 1TAP PACK FARM
--==================================================

Player.Idled:Connect(function()

    if AntiAFK then

        pcall(function()

            VirtualUser:CaptureController()

            VirtualUser:ClickButton2(
                Vector2.new()
            )

        end)

        print("[ANTI-AFK] Prevented idle kick")

    end

end)

--==================================================
-- REMOVE OLD GUI
--==================================================

local Old =
    PlayerGui:FindFirstChild(
        "InstantTokenCollectorV3"
    )

if Old then
    Old:Destroy()
end

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")

Gui.Name = "InstantTokenCollectorV3"
Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

--==================================================
-- MAIN
--==================================================

local Main = Instance.new("Frame")

Main.Size =
    UDim2.new(
        0,
        350,
        0,
        270
    )

Main.Position =
    UDim2.new(
        0.5,
        -175,
        0.5,
        -135
    )

Main.BackgroundColor3 =
    Color3.fromRGB(
        25,
        25,
        25
    )

Main.BorderSizePixel = 0
Main.Parent = Gui

local Corner =
    Instance.new("UICorner")

Corner.CornerRadius =
    UDim.new(
        0,
        10
    )

Corner.Parent = Main

--==================================================
-- TITLE
--==================================================

local Title =
    Instance.new("TextLabel")

Title.Size =
    UDim2.new(
        1,
        -80,
        0,
        40
    )

Title.Position =
    UDim2.new(
        0,
        10,
        0,
        0
    )

Title.BackgroundTransparency = 1

Title.Text =
    "⚡ Token Collector V4"

Title.TextColor3 =
    Color3.new(
        1,
        1,
        1
    )

Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment =
    Enum.TextXAlignment.Left

Title.Parent = Main

--==================================================
-- HIDE
--==================================================

local Hide =
    Instance.new("TextButton")

Hide.Size =
    UDim2.new(
        0,
        35,
        0,
        30
    )

Hide.Position =
    UDim2.new(
        1,
        -75,
        0,
        5
    )

Hide.Text = "—"
Hide.TextSize = 18

Hide.TextColor3 =
    Color3.new(
        1,
        1,
        1
    )

Hide.BackgroundColor3 =
    Color3.fromRGB(
        55,
        55,
        55
    )

Hide.Parent = Main

local HideCorner =
    Instance.new("UICorner")

HideCorner.CornerRadius =
    UDim.new(
        0,
        6
    )

HideCorner.Parent = Hide

--==================================================
-- CLOSE
--==================================================

local Close =
    Instance.new("TextButton")

Close.Size =
    UDim2.new(
        0,
        35,
        0,
        30
    )

Close.Position =
    UDim2.new(
        1,
        -38,
        0,
        5
    )

Close.Text = "X"
Close.TextSize = 15

Close.TextColor3 =
    Color3.new(
        1,
        1,
        1
    )

Close.BackgroundColor3 =
    Color3.fromRGB(
        130,
        40,
        40
    )

Close.Parent = Main

local CloseCorner =
    Instance.new("UICorner")

CloseCorner.CornerRadius =
    UDim.new(
        0,
        6
    )

CloseCorner.Parent = Close

--==================================================
-- STATUS
--==================================================

local Status =
    Instance.new("TextLabel")

Status.Size =
    UDim2.new(
        1,
        -20,
        0,
        30
    )

Status.Position =
    UDim2.new(
        0,
        10,
        0,
        45
    )

Status.BackgroundTransparency = 1

Status.Text =
    "Status: STOPPED"

Status.TextColor3 =
    Color3.fromRGB(
        255,
        100,
        100
    )

Status.TextSize = 14
Status.Font = Enum.Font.GothamBold

Status.TextXAlignment =
    Enum.TextXAlignment.Left

Status.Parent = Main

--==================================================
-- INFO
--==================================================

local Info =
    Instance.new("TextLabel")

Info.Size =
    UDim2.new(
        1,
        -20,
        0,
        95
    )

Info.Position =
    UDim2.new(
        0,
        10,
        0,
        75
    )

Info.BackgroundTransparency = 1

Info.Text =
    "Variant: 0\n" ..
    "Active: 0\n" ..
    "Collectable: 0\n" ..
    "Last: NONE\n" ..
    "Anti-AFK: ON"

Info.TextColor3 =
    Color3.fromRGB(
        220,
        220,
        220
    )

Info.TextSize = 13
Info.Font = Enum.Font.Code

Info.TextXAlignment =
    Enum.TextXAlignment.Left

Info.TextYAlignment =
    Enum.TextYAlignment.Top

Info.Parent = Main

--==================================================
-- ANTI AFK BUTTON
--==================================================

local AntiAFKButton =
    Instance.new("TextButton")

AntiAFKButton.Size =
    UDim2.new(
        0,
        100,
        0,
        32
    )

AntiAFKButton.Position =
    UDim2.new(
        0,
        10,
        1,
        -95
    )

AntiAFKButton.Text =
    "Anti-AFK: ON"

AntiAFKButton.TextColor3 =
    Color3.fromRGB(
        100,
        255,
        120
    )

AntiAFKButton.TextSize = 12
AntiAFKButton.Font =
    Enum.Font.GothamBold

AntiAFKButton.BackgroundColor3 =
    Color3.fromRGB(
        45,
        45,
        45
    )

AntiAFKButton.BorderSizePixel = 0

AntiAFKButton.Parent = Main

local AntiAFKCorner =
    Instance.new("UICorner")

AntiAFKCorner.CornerRadius =
    UDim.new(
        0,
        7
    )

AntiAFKCorner.Parent =
    AntiAFKButton

AntiAFKButton.MouseButton1Click:Connect(function()

    AntiAFK = not AntiAFK

    if AntiAFK then

        AntiAFKButton.Text =
            "Anti-AFK: ON"

        AntiAFKButton.TextColor3 =
            Color3.fromRGB(
                100,
                255,
                120
            )

    else

        AntiAFKButton.Text =
            "Anti-AFK: OFF"

        AntiAFKButton.TextColor3 =
            Color3.fromRGB(
                255,
                100,
                100
            )

    end

end)

--==================================================
-- BUTTON
--==================================================

local Toggle =
    Instance.new("TextButton")

Toggle.Size =
    UDim2.new(
        1,
        -125,
        0,
        42
    )

Toggle.Position =
    UDim2.new(
        0,
        115,
        1,
        -100
    )

Toggle.Text = "START"

Toggle.TextColor3 =
    Color3.new(
        1,
        1,
        1
    )

Toggle.TextSize = 15
Toggle.Font =
    Enum.Font.GothamBold

Toggle.BackgroundColor3 =
    Color3.fromRGB(
        45,
        120,
        65
    )

Toggle.Parent = Main

local ToggleCorner =
    Instance.new("UICorner")

ToggleCorner.CornerRadius =
    UDim.new(
        0,
        7
    )

ToggleCorner.Parent = Toggle

--==================================================
-- MINI
--==================================================

local Mini =
    Instance.new("TextButton")

Mini.Size =
    UDim2.new(
        0,
        55,
        0,
        55
    )

Mini.Position =
    UDim2.new(
        0,
        20,
        0.5,
        -25
    )

Mini.Text = "⚡"
Mini.TextSize = 25

Mini.TextColor3 =
    Color3.new(
        1,
        1,
        1
    )

Mini.BackgroundColor3 =
    Color3.fromRGB(
        30,
        30,
        30
    )

Mini.Visible = false
Mini.Parent = Gui

local MiniCorner =
    Instance.new("UICorner")

MiniCorner.CornerRadius =
    UDim.new(
        1,
        0
    )

MiniCorner.Parent = Mini

--==================================================
-- DRAG
--==================================================

local Dragging = false
local DragStart
local StartPosition

Title.InputBegan:Connect(function(Input)

    if Input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or
        Input.UserInputType ==
        Enum.UserInputType.Touch then

        Dragging = true

        DragStart =
            Input.Position

        StartPosition =
            Main.Position

    end

end)

Title.InputEnded:Connect(function(Input)

    if Input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or
        Input.UserInputType ==
        Enum.UserInputType.Touch then

        Dragging = false

    end

end)

UserInputService.InputChanged:Connect(function(Input)

    if not Dragging then
        return
    end

    if Input.UserInputType ~=
        Enum.UserInputType.MouseMovement
        and
        Input.UserInputType ~=
        Enum.UserInputType.Touch then

        return

    end

    local Delta =
        Input.Position -
        DragStart

    Main.Position =
        UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,

            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )

end)

--==================================================
-- HIDE / SHOW
--==================================================

Hide.MouseButton1Click:Connect(function()

    Main.Visible = false
    Mini.Visible = true

end)

Mini.MouseButton1Click:Connect(function()

    Main.Visible = true
    Mini.Visible = false

end)

--==================================================
-- POSITION
--==================================================

local function GetPosition(Object)

    if not Object then
        return nil
    end

    if Object:IsA("BasePart") then
        return Object.Position
    end

    if Object:IsA("Model") then

        if Object.PrimaryPart then
            return Object.PrimaryPart.Position
        end

        local Part =
            Object:FindFirstChildWhichIsA(
                "BasePart",
                true
            )

        if Part then
            return Part.Position
        end

    end

    local Part =
        Object:FindFirstChildWhichIsA(
            "BasePart",
            true
        )

    if Part then
        return Part.Position
    end

    return nil

end

--==================================================
-- TELEPORT
--==================================================

local function Teleport(Position)

    local Character =
        Player.Character

    if not Character then
        return false
    end

    local Root =
        Character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not Root then
        return false
    end

    Character:PivotTo(
        CFrame.new(
            Position +
            Vector3.new(
                0,
                TP_HEIGHT,
                0
            )
        )
    )

    return true

end

--==================================================
-- COUNTERS
--==================================================

local VariantCount = 0
local ActiveCount = 0
local CollectCount = 0

--==================================================
-- UPDATE INFO
--==================================================

local function Update(
    Source,
    Object
)

    local ObjectName = "UNKNOWN"

    pcall(function()
        ObjectName = Object.Name
    end)

    Info.Text =
        "Variant: " ..
        tostring(VariantCount) ..
        "\n" ..

        "Active: " ..
        tostring(ActiveCount) ..
        "\n" ..

        "Collectable: " ..
        tostring(CollectCount) ..
        "\n" ..

        "Last: " ..
        tostring(Source) ..
        " -> " ..
        tostring(ObjectName) ..
        "\n" ..

        "Anti-AFK: " ..
        (
            AntiAFK
            and "ON"
            or "OFF"
        )

end

--==================================================
-- COLLECT
--==================================================

local function Collect(
    Object,
    Source
)

    if not Running then
        return
    end

    if not Object then
        return
    end

    if Processing[Object] then
        return
    end

    local Position =
        GetPosition(Object)

    if not Position then
        return
    end

    Processing[Object] = true

    if Source == "Variant" then

        VariantCount += 1

    elseif Source == "Active" then

        ActiveCount += 1

    else

        CollectCount += 1

    end

    Update(
        Source,
        Object
    )

    print(
        "[PICKUP]",
        Source,
        Object:GetFullName(),
        Position
    )

    --==================================================
    -- TELEPORT
    --==================================================

    Teleport(Position)

    task.wait(
        COLLECT_DELAY
    )

    --==================================================
    -- REMOTE
    --==================================================

    local Success,
        Error =
        pcall(function()

            Remote:FireServer(
                Object
            )

        end)

    if Success then

        print(
            "[REMOTE OK]",
            Object:GetFullName()
        )

    else

        warn(
            "[REMOTE ERROR]",
            Error
        )

    end

    task.delay(
        0.4,
        function()

            Processing[Object] =
                nil

        end
    )

end

--==================================================
-- PROCESS VARIANT
--==================================================

local function ProcessVariant(Object)

    if not Running then
        return
    end

    local Position =
        GetPosition(Object)

    if not Position then
        return
    end

    print(
        "[VARIANT]",
        Object:GetFullName(),
        Position
    )

    Collect(
        Object,
        "Variant"
    )

end

--==================================================
-- PROCESS ACTIVE
--==================================================

local function ProcessActive(Object)

    if not Running then
        return
    end

    print(
        "[ACTIVE]",
        Object:GetFullName(),
        GetPosition(Object)
    )

    Collect(
        Object,
        "Active"
    )

end

--==================================================
-- PROCESS COLLECTABLE
--==================================================

local function ProcessCollectable(Object)

    if not Running then
        return
    end

    print(
        "[COLLECTABLE]",
        Object:GetFullName(),
        GetPosition(Object)
    )

    Collect(
        Object,
        "Collectable"
    )

end

--==================================================
-- DESCENDANT ADDED
--==================================================

VariantFolder.DescendantAdded:Connect(function(Object)

    task.wait()

    if Running then
        ProcessVariant(Object)
    end

end)

ActiveFolder.DescendantAdded:Connect(function(Object)

    task.wait()

    if Running then
        ProcessActive(Object)
    end

end)

CollectFolder.DescendantAdded:Connect(function(Object)

    task.wait()

    if Running then
        ProcessCollectable(Object)
    end

end)

--==================================================
-- POSITION MONITOR
--==================================================

local LastPositions = {}

task.spawn(function()

    while Gui.Parent do

        if Running then

            for _, Object in ipairs(
                VariantFolder:GetDescendants()
            ) do

                local Position =
                    GetPosition(Object)

                if Position then

                    local Old =
                        LastPositions[Object]

                    if not Old then

                        LastPositions[Object] =
                            Position

                    elseif
                        (
                            Position - Old
                        ).Magnitude > 1 then

                        LastPositions[Object] =
                            Position

                        print(
                            "[VARIANT MOVED]",
                            Object:GetFullName(),
                            Position
                        )

                        ProcessVariant(
                            Object
                        )

                    end

                end

            end

        end

        task.wait(
            SCAN_DELAY
        )

    end

end)

--==================================================
-- START
--==================================================

local function Start()

    Running = true

    Status.Text =
        "Status: RUNNING"

    Status.TextColor3 =
        Color3.fromRGB(
            100,
            255,
            120
        )

    Toggle.Text =
        "STOP"

    Toggle.BackgroundColor3 =
        Color3.fromRGB(
            150,
            55,
            55
        )

    print(
        "================================"
    )

    print(
        " TOKEN COLLECTOR V4 STARTED"
    )

    print(
        " ANTI-AFK:",
        AntiAFK
            and "ON"
            or "OFF"
    )

    print(
        "================================"
    )

end

--==================================================
-- STOP
--==================================================

local function Stop()

    Running = false

    Status.Text =
        "Status: STOPPED"

    Status.TextColor3 =
        Color3.fromRGB(
            255,
            100,
            100
        )

    Toggle.Text =
        "START"

    Toggle.BackgroundColor3 =
        Color3.fromRGB(
            45,
            120,
            65
        )

    print(
        "========== STOP =========="
    )

end

--==================================================
-- START / STOP BUTTON
--==================================================

Toggle.MouseButton1Click:Connect(function()

    if Running then

        Stop()

    else

        Start()

    end

end)

--==================================================
-- CLOSE
--==================================================

Close.MouseButton1Click:Connect(function()

    Running = false

    Gui:Destroy()

end)

--==================================================
-- READY
--==================================================

print(
    "================================"
)

print(
    " TOKEN COLLECTOR V4 LOADED"
)

print(
    "Variant:",
    VariantFolder:GetFullName()
)

print(
    "Active:",
    ActiveFolder:GetFullName()
)

print(
    "Collect:",
    CollectFolder:GetFullName()
)

print(
    "Anti-AFK: ON"
)

print(
    "================================"
)
```
