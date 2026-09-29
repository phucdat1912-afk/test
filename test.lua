--==================================================
-- INSTANT TOKEN COLLECTOR V5.2
-- ALL 3 FOLDERS
-- REAL ANTI-AFK
-- VARIANT POSITION MONITOR
-- SMART TELEPORT
-- NO TELEPORT LOOP
-- HIDE / SHOW
-- DRAGGABLE
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

--==================================================
-- CONFIG
--==================================================

local TP_HEIGHT = 3

-- Main scan interval
local SCAN_DELAY = 0.08

-- Delay before firing collect remote
local COLLECT_DELAY = 0.05

-- Minimum movement required before treating
-- an existing object as moved
local MOVE_DISTANCE = 0.5

-- Prevent the same object from being collected
-- repeatedly in a very short period
local OBJECT_COOLDOWN = 0.50

-- Prevent repeated collection of the same
-- position caused by tiny position changes
local POSITION_COOLDOWN = 0.35

-- Anti-AFK
local AntiAFK = true

-- Collector state
local Running = false

--==================================================
-- STATE
--==================================================

local Processing = {}
local LastPositions = {}
local LastCollectedPosition = {}
local LastCollectedTime = {}

local Connections = {}

local VariantCount = 0
local ActiveCount = 0
local CollectCount = 0

local LastSource = "NONE"
local LastObject = "NONE"

--==================================================
-- SYSTEMS
--==================================================

local Systems = workspace:FindFirstChild("Systems")

if not Systems then
    warn("[TOKEN V5.2] Systems not found")
    return
end

local VariantFolder =
    Systems:FindFirstChild("ActiveVariantTokenSpawns")

local ActiveFolder =
    Systems:FindFirstChild("ActiveCollectableObjects")

local CollectFolder =
    Systems:FindFirstChild("CollectableObjects")

--==================================================
-- REMOTE
--==================================================

local Remotes =
    ReplicatedStorage:FindFirstChild("Remotes")

local Remote =
    Remotes
    and Remotes:FindFirstChild(
        "CollectCollectableObject"
    )

if Remote then

    print(
        "[TOKEN V5.2] Remote:",
        Remote:GetFullName(),
        Remote.ClassName
    )

else

    warn(
        "[TOKEN V5.2] CollectCollectableObject not found"
    )

end

--==================================================
-- OLD GUI CLEANUP
--==================================================

local PlayerGui =
    Player:WaitForChild("PlayerGui")

local Old =
    PlayerGui:FindFirstChild(
        "InstantTokenCollectorV52"
    )

if Old then
    Old:Destroy()
end

--==================================================
-- GUI
--==================================================

local Gui =
    Instance.new("ScreenGui")

Gui.Name =
    "InstantTokenCollectorV52"

Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = PlayerGui

--==================================================
-- MAIN
--==================================================

local Main =
    Instance.new("Frame")

Main.Name = "Main"

Main.Size =
    UDim2.new(
        0,
        360,
        0,
        300
    )

Main.Position =
    UDim2.new(
        0.5,
        -180,
        0.5,
        -150
    )

Main.BackgroundColor3 =
    Color3.fromRGB(
        25,
        25,
        25
    )

Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner =
    Instance.new("UICorner")

MainCorner.CornerRadius =
    UDim.new(0, 10)

MainCorner.Parent = Main

--==================================================
-- TITLE
--==================================================

local Title =
    Instance.new("TextLabel")

Title.Size =
    UDim2.new(
        1,
        -90,
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
    "⚡ Token Collector V5.2"

Title.TextColor3 =
    Color3.new(1, 1, 1)

Title.TextSize = 17

Title.Font =
    Enum.Font.GothamBold

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
    Color3.new(1, 1, 1)

Hide.BackgroundColor3 =
    Color3.fromRGB(
        55,
        55,
        55
    )

Hide.BorderSizePixel = 0
Hide.Parent = Main

local HideCorner =
    Instance.new("UICorner")

HideCorner.CornerRadius =
    UDim.new(0, 6)

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
    Color3.new(1, 1, 1)

Close.BackgroundColor3 =
    Color3.fromRGB(
        130,
        40,
        40
    )

Close.BorderSizePixel = 0
Close.Parent = Main

local CloseCorner =
    Instance.new("UICorner")

CloseCorner.CornerRadius =
    UDim.new(0, 6)

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

Status.Font =
    Enum.Font.GothamBold

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
        125
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
    "Last: NONE"

Info.TextColor3 =
    Color3.fromRGB(
        220,
        220,
        220
    )

Info.TextSize = 13

Info.Font =
    Enum.Font.Code

Info.TextXAlignment =
    Enum.TextXAlignment.Left

Info.TextYAlignment =
    Enum.TextYAlignment.Top

Info.Parent = Main

--==================================================
-- ANTI AFK STATUS
--==================================================

local AFKStatus =
    Instance.new("TextLabel")

AFKStatus.Size =
    UDim2.new(
        1,
        -20,
        0,
        22
    )

AFKStatus.Position =
    UDim2.new(
        0,
        10,
        1,
        -100
    )

AFKStatus.BackgroundTransparency = 1

AFKStatus.Text =
    "Anti-AFK: ON"

AFKStatus.TextColor3 =
    Color3.fromRGB(
        100,
        255,
        120
    )

AFKStatus.TextSize = 12

AFKStatus.Font =
    Enum.Font.GothamBold

AFKStatus.TextXAlignment =
    Enum.TextXAlignment.Left

AFKStatus.Parent = Main

--==================================================
-- BUTTON
--==================================================

local Toggle =
    Instance.new("TextButton")

Toggle.Size =
    UDim2.new(
        1,
        -20,
        0,
        42
    )

Toggle.Position =
    UDim2.new(
        0,
        10,
        1,
        -52
    )

Toggle.Text =
    "START"

Toggle.TextColor3 =
    Color3.new(1, 1, 1)

Toggle.TextSize = 15

Toggle.Font =
    Enum.Font.GothamBold

Toggle.BackgroundColor3 =
    Color3.fromRGB(
        45,
        120,
        65
    )

Toggle.BorderSizePixel = 0
Toggle.Parent = Main

local ToggleCorner =
    Instance.new("UICorner")

ToggleCorner.CornerRadius =
    UDim.new(0, 7)

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
    Color3.new(1, 1, 1)

Mini.BackgroundColor3 =
    Color3.fromRGB(
        30,
        30,
        30
    )

Mini.BorderSizePixel = 0

Mini.Visible = false
Mini.Parent = Gui

local MiniCorner =
    Instance.new("UICorner")

MiniCorner.CornerRadius =
    UDim.new(1, 0)

MiniCorner.Parent = Mini

--==================================================
-- DRAG
--==================================================

local Dragging = false
local DragStart
local StartPosition

local function BeginDrag(Input)

    if
        Input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or
        Input.UserInputType ==
        Enum.UserInputType.Touch
    then

        Dragging = true
        DragStart = Input.Position
        StartPosition = Main.Position

    end

end

local function EndDrag(Input)

    if
        Input.UserInputType ==
        Enum.UserInputType.MouseButton1
        or
        Input.UserInputType ==
        Enum.UserInputType.Touch
    then

        Dragging = false

    end

end

Title.InputBegan:Connect(BeginDrag)
Title.InputEnded:Connect(EndDrag)

UserInputService.InputChanged:Connect(function(Input)

    if not Dragging then
        return
    end

    if
        Input.UserInputType ~=
        Enum.UserInputType.MouseMovement
        and
        Input.UserInputType ~=
        Enum.UserInputType.Touch
    then

        return

    end

    local Delta =
        Input.Position - DragStart

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

    return nil

end

--==================================================
-- TELEPORT
--==================================================

local function Teleport(Position)

    if not Position then
        return false
    end

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

    local Target =
        Position +
        Vector3.new(
            0,
            TP_HEIGHT,
            0
        )

    Character:PivotTo(
        CFrame.new(Target)
    )

    return true

end

--==================================================
-- UPDATE INFO
--==================================================

local function UpdateInfo()

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
        tostring(LastSource) ..
        " -> " ..
        tostring(LastObject)

end

--==================================================
-- REMOTE COLLECT
--==================================================

local function FireCollect(Object)

    if not Remote then

        warn(
            "[REMOTE] CollectCollectableObject missing"
        )

        return false

    end

    if not Object then
        return false
    end

    local Success, Error =
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

        return true

    end

    warn(
        "[REMOTE ERROR]",
        Error
    )

    return false

end

--==================================================
-- OBJECT VALIDATION
--==================================================

local function IsCollectableObject(Object)

    if not Object then
        return false
    end

    return
        Object:IsA("BasePart")
        or
        Object:IsA("Model")

end

--==================================================
-- SMART COOLDOWN
--==================================================

local function CanProcess(Object, Position)

    if not Object then
        return false
    end

    local Now =
        os.clock()

    -- Same object currently processing
    if Processing[Object] then
        return false
    end

    -- Same object recently processed
    local LastTime =
        LastCollectedTime[Object]

    if LastTime then

        if
            Now - LastTime
            <
            OBJECT_COOLDOWN
        then

            return false

        end

    end

    -- Prevent tiny position changes
    local OldPosition =
        LastCollectedPosition[Object]

    if OldPosition and Position then

        local Distance =
            (
                Position -
                OldPosition
            ).Magnitude

        if
            Distance
            <
            MOVE_DISTANCE
        then

            return false

        end

    end

    return true

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

    if not IsCollectableObject(Object) then
        return
    end

    local Position =
        GetPosition(Object)

    if not Position then
        return
    end

    if not CanProcess(
        Object,
        Position
    ) then

        return

    end

    -- Mark immediately
    Processing[Object] = true

    LastCollectedTime[Object] =
        os.clock()

    LastCollectedPosition[Object] =
        Position

    -- Counter
    if Source == "Variant" then

        VariantCount += 1

    elseif Source == "Active" then

        ActiveCount += 1

    else

        CollectCount += 1

    end

    LastSource =
        Source

    LastObject =
        Object.Name

    UpdateInfo()

    print(
        "[FOUND]",
        Source,
        Object:GetFullName()
    )

    --==================================================
    -- TELEPORT
    --==================================================

    local Teleported =
        Teleport(Position)

    if Teleported then

        print(
            "[TP]",
            Source,
            Object.Name
        )

    end

    --==================================================
    -- COLLECT
    --==================================================

    task.wait(
        COLLECT_DELAY
    )

    if Running then

        FireCollect(
            Object
        )

    end

    --==================================================
    -- RELEASE PROCESSING
    --==================================================

    task.delay(
        OBJECT_COOLDOWN,
        function()

            Processing[Object] = nil

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

    if not IsCollectableObject(Object) then
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

    if not IsCollectableObject(Object) then
        return
    end

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

    if not IsCollectableObject(Object) then
        return
    end

    Collect(
        Object,
        "Collectable"
    )

end

--==================================================
-- INITIAL SCAN
--==================================================

local function ScanFolder(
    Folder,
    Processor
)

    if not Folder then
        return
    end

    for _, Object in ipairs(
        Folder:GetDescendants()
    ) do

        if IsCollectableObject(Object) then

            task.spawn(
                Processor,
                Object
            )

        end

    end

end

--==================================================
-- SET INITIAL POSITION
--==================================================

local function CacheFolderPositions(Folder)

    if not Folder then
        return
    end

    for _, Object in ipairs(
        Folder:GetDescendants()
    ) do

        if IsCollectableObject(Object) then

            local Position =
                GetPosition(Object)

            if Position then

                LastPositions[Object] =
                    Position

            end

        end

    end

end

--==================================================
-- VARIANT NEW OBJECT
--==================================================

if VariantFolder then

    table.insert(
        Connections,

        VariantFolder.DescendantAdded:Connect(
            function(Object)

                task.wait()

                if not Running then
                    return
                end

                if IsCollectableObject(Object) then

                    local Position =
                        GetPosition(Object)

                    if Position then

                        LastPositions[Object] =
                            Position

                    end

                    ProcessVariant(
                        Object
                    )

                end

            end
        )
    )

end

--==================================================
-- ACTIVE NEW OBJECT
--==================================================

if ActiveFolder then

    table.insert(
        Connections,

        ActiveFolder.DescendantAdded:Connect(
            function(Object)

                task.wait()

                if not Running then
                    return
                end

                if IsCollectableObject(Object) then

                    local Position =
                        GetPosition(Object)

                    if Position then

                        LastPositions[Object] =
                            Position

                    end

                    ProcessActive(
                        Object
                    )

                end

            end
        )
    )

end

--==================================================
-- COLLECTABLE NEW OBJECT
--==================================================

if CollectFolder then

    table.insert(
        Connections,

        CollectFolder.DescendantAdded:Connect(
            function(Object)

                task.wait()

                if not Running then
                    return
                end

                if IsCollectableObject(Object) then

                    local Position =
                        GetPosition(Object)

                    if Position then

                        LastPositions[Object] =
                            Position

                    end

                    ProcessCollectable(
                        Object
                    )

                end

            end
        )
    )

end

--==================================================
-- POSITION MONITOR
--==================================================

task.spawn(function()

    while Gui.Parent do

        if Running then

            --==========================================
            -- VARIANT
            --==========================================

            if VariantFolder then

                for _, Object in ipairs(
                    VariantFolder:GetDescendants()
                ) do

                    if IsCollectableObject(Object) then

                        local Position =
                            GetPosition(Object)

                        if Position then

                            local OldPosition =
                                LastPositions[Object]

                            if not OldPosition then

                                LastPositions[Object] =
                                    Position

                            else

                                local Distance =
                                    (
                                        Position -
                                        OldPosition
                                    ).Magnitude

                                if
                                    Distance
                                    >=
                                    MOVE_DISTANCE
                                then

                                    LastPositions[Object] =
                                        Position

                                    print(
                                        "[VARIANT MOVED]",
                                        Object:GetFullName(),
                                        "Distance:",
                                        Distance
                                    )

                                    ProcessVariant(
                                        Object
                                    )

                                end

                            end

                        end

                    end

                end

            end

            --==========================================
            -- ACTIVE
            --==========================================

            if ActiveFolder then

                for _, Object in ipairs(
                    ActiveFolder:GetDescendants()
                ) do

                    if IsCollectableObject(Object) then

                        local Position =
                            GetPosition(Object)

                        if Position then

                            local OldPosition =
                                LastPositions[Object]

                            if not OldPosition then

                                LastPositions[Object] =
                                    Position

                            else

                                local Distance =
                                    (
                                        Position -
                                        OldPosition
                                    ).Magnitude

                                if
                                    Distance
                                    >=
                                    MOVE_DISTANCE
                                then

                                    LastPositions[Object] =
                                        Position

                                    ProcessActive(
                                        Object
                                    )

                                end

                            end

                        end

                    end

                end

            end

            --==========================================
            -- COLLECTABLE
            --==========================================

            if CollectFolder then

                for _, Object in ipairs(
                    CollectFolder:GetDescendants()
                ) do

                    if IsCollectableObject(Object) then

                        local Position =
                            GetPosition(Object)

                        if Position then

                            local OldPosition =
                                LastPositions[Object]

                            if not OldPosition then

                                LastPositions[Object] =
                                    Position

                            else

                                local Distance =
                                    (
                                        Position -
                                        OldPosition
                                    ).Magnitude

                                if
                                    Distance
                                    >=
                                    MOVE_DISTANCE
                                then

                                    LastPositions[Object] =
                                        Position

                                    ProcessCollectable(
                                        Object
                                    )

                                end

                            end

                        end

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
-- ANTI AFK
--==================================================

local AntiAFKConnection

local function StartAntiAFK()

    if AntiAFKConnection then

        AntiAFKConnection:Disconnect()
        AntiAFKConnection = nil

    end

    AntiAFK = true

    AntiAFKConnection =
        Player.Idled:Connect(
            function()

                if not AntiAFK then
                    return
                end

                pcall(function()

                    VirtualUser:Button2Down(
                        Vector2.new(0, 0),
                        workspace.CurrentCamera.CFrame
                    )

                    task.wait(0.1)

                    VirtualUser:Button2Up(
                        Vector2.new(0, 0),
                        workspace.CurrentCamera.CFrame
                    )

                end)

                print(
                    "[ANTI-AFK] Activity sent"
                )

            end
        )

    AFKStatus.Text =
        "Anti-AFK: ON"

    AFKStatus.TextColor3 =
        Color3.fromRGB(
            100,
            255,
            120
        )

    print(
        "[ANTI-AFK] Started"
    )

end

local function StopAntiAFK()

    AntiAFK = false

    if AntiAFKConnection then

        AntiAFKConnection:Disconnect()
        AntiAFKConnection = nil

    end

    AFKStatus.Text =
        "Anti-AFK: OFF"

    AFKStatus.TextColor3 =
        Color3.fromRGB(
            255,
            100,
            100
        )

    print(
        "[ANTI-AFK] Stopped"
    )

end

--==================================================
-- START
--==================================================

local function Start()

    if Running then
        return
    end

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

    print("==============================")
    print(" TOKEN COLLECTOR V5.2 STARTED")
    print("==============================")

    -- Cache current positions first
    -- so the monitor does not consider
    -- existing objects as "moved"
    CacheFolderPositions(
        VariantFolder
    )

    CacheFolderPositions(
        ActiveFolder
    )

    CacheFolderPositions(
        CollectFolder
    )

    -- Existing objects
    ScanFolder(
        VariantFolder,
        ProcessVariant
    )

    ScanFolder(
        ActiveFolder,
        ProcessActive
    )

    ScanFolder(
        CollectFolder,
        ProcessCollectable
    )

end

--==================================================
-- STOP
--==================================================

local function Stop()

    if not Running then
        return
    end

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

    -- Clear processing state
    Processing = {}

    print(
        "========== TOKEN STOP =========="
    )

end

--==================================================
-- TOGGLE
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

    StopAntiAFK()

    for _, Connection in ipairs(
        Connections
    ) do

        pcall(function()
            Connection:Disconnect()
        end)

    end

    Connections = {}

    Processing = {}
    LastPositions = {}
    LastCollectedPosition = {}
    LastCollectedTime = {}

    Gui:Destroy()

    print(
        "[TOKEN V5.2] CLOSED"
    )

end)

--==================================================
-- PLAYER RESPAWN
--==================================================

Player.CharacterAdded:Connect(function()

    task.wait(1)

    if Running then

        print(
            "[TOKEN V5.2] Character respawned"
        )

    end

end)

--==================================================
-- START ANTI-AFK
--==================================================

StartAntiAFK()

--==================================================
-- LOADED
--==================================================

print("==============================")
print(" TOKEN COLLECTOR V5.2 LOADED")
print("==============================")

print(
    "Variant:",
    VariantFolder
        and VariantFolder:GetFullName()
        or "NOT FOUND"
)

print(
    "Active:",
    ActiveFolder
        and ActiveFolder:GetFullName()
        or "NOT FOUND"
)

print(
    "Collect:",
    CollectFolder
        and CollectFolder:GetFullName()
        or "NOT FOUND"
)

print(
    "Remote:",
    Remote
        and Remote:GetFullName()
        or "NOT FOUND"
)

print(
    "Anti-AFK: ON"
)

print("==============================")
