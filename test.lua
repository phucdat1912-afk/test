--==================================================
-- INSTANT TOKEN COLLECTOR V2
-- ActiveVariantTokenSpawns POSITION MONITOR
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Systems = workspace:WaitForChild("Systems")

local VariantFolder = Systems:WaitForChild("ActiveVariantTokenSpawns")
local ActiveFolder = Systems:WaitForChild("ActiveCollectableObjects")
local CollectFolder = Systems:WaitForChild("CollectableObjects")

local Remote = game:GetService("ReplicatedStorage")
    :WaitForChild("Remotes")
    :WaitForChild("CollectCollectableObject")

--==================================================
-- SETTINGS
--==================================================

local TP_HEIGHT = 3
local DETECT_DISTANCE = 30
local POSITION_THRESHOLD = 1
local SCAN_INTERVAL = 0.05
local COLLECT_DELAY = 0.08

local Running = false
local VariantCount = 0
local ActiveCount = 0
local CollectCount = 0

local LastPositions = {}
local Processing = {}

--==================================================
-- GUI
--==================================================

local OldGui = PlayerGui:FindFirstChild("InstantTokenCollectorV2")

if OldGui then
    OldGui:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "InstantTokenCollectorV2"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 350, 0, 245)
Main.Position = UDim2.new(0.5, -175, 0.5, -120)
Main.BackgroundColor3 = Color3.fromRGB(25,25,25)
Main.BorderSizePixel = 0
Main.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0,10)
Corner.Parent = Main

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ Instant Token Collector V2"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

--==================================================
-- HIDE
--==================================================

local Hide = Instance.new("TextButton")
Hide.Size = UDim2.new(0, 35, 0, 30)
Hide.Position = UDim2.new(1, -75, 0, 5)
Hide.BackgroundColor3 = Color3.fromRGB(50,50,50)
Hide.Text = "—"
Hide.TextColor3 = Color3.new(1,1,1)
Hide.TextSize = 18
Hide.Font = Enum.Font.GothamBold
Hide.Parent = Main

local HideCorner = Instance.new("UICorner")
HideCorner.CornerRadius = UDim.new(0,6)
HideCorner.Parent = Hide

--==================================================
-- CLOSE
--==================================================

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 35, 0, 30)
Close.Position = UDim2.new(1, -38, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(120,40,40)
Close.Text = "X"
Close.TextColor3 = Color3.new(1,1,1)
Close.TextSize = 15
Close.Font = Enum.Font.GothamBold
Close.Parent = Main

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0,6)
CloseCorner.Parent = Close

--==================================================
-- STATUS
--==================================================

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 28)
Status.Position = UDim2.new(0,10,0,48)
Status.BackgroundTransparency = 1
Status.Text = "Status: STOPPED"
Status.TextColor3 = Color3.fromRGB(255,100,100)
Status.TextSize = 14
Status.Font = Enum.Font.GothamBold
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

--==================================================
-- INFO
--==================================================

local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, -20, 0, 85)
Info.Position = UDim2.new(0,10,0,78)
Info.BackgroundTransparency = 1
Info.Text = 
    "Variant: 0\n" ..
    "Active: 0\n" ..
    "Collectable: 0\n" ..
    "Target: NONE"

Info.TextColor3 = Color3.fromRGB(210,210,210)
Info.TextSize = 13
Info.Font = Enum.Font.Code
Info.TextXAlignment = Enum.TextXAlignment.Left
Info.TextYAlignment = Enum.TextYAlignment.Top
Info.Parent = Main

--==================================================
-- START / STOP
--==================================================

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(1, -20, 0, 42)
Toggle.Position = UDim2.new(0,10,1,-52)
Toggle.BackgroundColor3 = Color3.fromRGB(45,120,65)
Toggle.Text = "START"
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.TextSize = 15
Toggle.Font = Enum.Font.GothamBold
Toggle.Parent = Main

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0,7)
ToggleCorner.Parent = Toggle

--==================================================
-- MINI BUTTON
--==================================================

local Mini = Instance.new("TextButton")
Mini.Size = UDim2.new(0,55,0,55)
Mini.Position = UDim2.new(0,20,0.5,-25)
Mini.BackgroundColor3 = Color3.fromRGB(30,30,30)
Mini.Text = "⚡"
Mini.TextColor3 = Color3.new(1,1,1)
Mini.TextSize = 25
Mini.Visible = false
Mini.Parent = Gui

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(1,0)
MiniCorner.Parent = Mini

--==================================================
-- DRAG
--==================================================

local Dragging = false
local DragStart
local StartPosition

Title.InputBegan:Connect(function(Input)

    if Input.UserInputType == Enum.UserInputType.MouseButton1
    or Input.UserInputType == Enum.UserInputType.Touch then

        Dragging = true
        DragStart = Input.Position
        StartPosition = Main.Position

    end

end)

Title.InputEnded:Connect(function(Input)

    if Input.UserInputType == Enum.UserInputType.MouseButton1
    or Input.UserInputType == Enum.UserInputType.Touch then

        Dragging = false

    end

end)

UserInputService.InputChanged:Connect(function(Input)

    if not Dragging then
        return
    end

    if Input.UserInputType ~= Enum.UserInputType.MouseMovement
    and Input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local Delta = Input.Position - DragStart

    Main.Position = UDim2.new(
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

Close.MouseButton1Click:Connect(function()

    Running = false
    Gui:Destroy()

end)

--==================================================
-- CHARACTER
--==================================================

local function GetCharacter()

    local Character = Player.Character

    if not Character then
        return nil
    end

    local Root = Character:FindFirstChild("HumanoidRootPart")

    if not Root then
        return nil
    end

    return Character, Root

end

--==================================================
-- GET POSITION
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

        local Part = Object:FindFirstChildWhichIsA(
            "BasePart",
            true
        )

        if Part then
            return Part.Position
        end

    end

    local Part = Object:FindFirstChildWhichIsA(
        "BasePart",
        true
    )

    if Part then
        return Part.Position
    end

    return nil

end

--==================================================
-- TP
--==================================================

local function TeleportTo(Position)

    local Character = Player.Character

    if not Character then
        return false
    end

    local Root = Character:FindFirstChild("HumanoidRootPart")

    if not Root then
        return false
    end

    Character:PivotTo(
        CFrame.new(
            Position + Vector3.new(0, TP_HEIGHT, 0)
        )
    )

    return true

end

--==================================================
-- UI UPDATE
--==================================================

local function UpdateInfo(TargetName)

    Info.Text =
        "Variant: " .. VariantCount .. "\n" ..
        "Active: " .. ActiveCount .. "\n" ..
        "Collectable: " .. CollectCount .. "\n" ..
        "Target: " .. (TargetName or "NONE")

end

--==================================================
-- COLLECT
--==================================================

local function Collect(Object, Source)

    if not Object then
        return
    end

    if Processing[Object] then
        return
    end

    local Position = GetPosition(Object)

    if not Position then
        return
    end

    Processing[Object] = true

    local Name = Object:GetFullName()

    UpdateInfo(Name)

    print(
        "[COLLECT]",
        Source,
        Name,
        Position
    )

    TeleportTo(Position)

    task.wait(COLLECT_DELAY)

    pcall(function()

        Remote:FireServer(Object)

    end)

    task.delay(0.5, function()

        Processing[Object] = nil

    end)

end

--==================================================
-- FIND NEAREST COLLECTABLE
--==================================================

local function FindNearestCollectable(Position)

    local Character = Player.Character

    local Root = Character and Character:FindFirstChild(
        "HumanoidRootPart"
    )

    local BestObject = nil
    local BestDistance = DETECT_DISTANCE

    for _, Object in ipairs(CollectFolder:GetChildren()) do

        local ObjectPosition = GetPosition(Object)

        if ObjectPosition then

            local Distance = (
                ObjectPosition - Position
            ).Magnitude

            if Distance < BestDistance then

                BestDistance = Distance
                BestObject = Object

            end

        end

    end

    return BestObject, BestDistance

end

--==================================================
-- PROCESS VARIANT
--==================================================

local function ProcessVariant(Object)

    if not Running then
        return
    end

    local Position = GetPosition(Object)

    if not Position then
        return
    end

    VariantCount += 1

    print(
        "[VARIANT]",
        Object:GetFullName(),
        "POS:",
        Position
    )

    -- TP TRỰC TIẾP TỚI VARIANT
    TeleportTo(Position)

    UpdateInfo(
        "VARIANT -> " .. Object.Name
    )

    -- Sau đó tìm collectable gần variant
    local Target, Distance =
        FindNearestCollectable(Position)

    if Target then

        print(
            "[VARIANT TARGET]",
            Target:GetFullName(),
            "DIST:",
            Distance
        )

        Collect(
            Target,
            "Variant"
        )

    else

        print(
            "[VARIANT]",
            "Không tìm thấy Collectable gần variant"
        )

    end

end

--==================================================
-- PROCESS ACTIVE
--==================================================

local function ProcessActive(Object)

    if not Running then
        return
    end

    local Position = GetPosition(Object)

    if not Position then
        return
    end

    ActiveCount += 1

    print(
        "[ACTIVE]",
        Object:GetFullName(),
        Position
    )

    local Target = FindNearestCollectable(Position)

    if Target then

        Collect(
            Target,
            "Active"
        )

    end

end

--==================================================
-- DIRECT COLLECTABLE
--==================================================

local function ProcessCollectable(Object)

    if not Running then
        return
    end

    Collect(
        Object,
        "Collectable"
    )

end

--==================================================
-- INITIAL SNAPSHOT
--==================================================

local function SnapshotFolder(Folder, Type)

    for _, Object in ipairs(Folder:GetChildren()) do

        local Position = GetPosition(Object)

        if Position then

            if Type == "Variant" then

                LastPositions[Object] = Position

                print(
                    "[INIT VARIANT]",
                    Object:GetFullName(),
                    Position
                )

            elseif Type == "Active" then

                print(
                    "[INIT ACTIVE]",
                    Object:GetFullName(),
                    Position
                )

            end

        end

    end

end

--==================================================
-- CHILD ADDED
--==================================================

VariantFolder.ChildAdded:Connect(function(Object)

    task.wait()

    if Running then

        print(
            "[VARIANT NEW]",
            Object:GetFullName()
        )

        ProcessVariant(Object)

    end

end)

ActiveFolder.ChildAdded:Connect(function(Object)

    task.wait()

    if Running then

        print(
            "[ACTIVE NEW]",
            Object:GetFullName()
        )

        ProcessActive(Object)

    end

end)

CollectFolder.ChildAdded:Connect(function(Object)

    task.wait()

    if Running then

        print(
            "[COLLECTABLE NEW]",
            Object:GetFullName()
        )

        ProcessCollectable(Object)

    end

end)

--==================================================
-- POSITION MONITOR
--==================================================

task.spawn(function()

    while Gui.Parent do

        if Running then

            --======================================
            -- VARIANT TOKEN MONITOR
            --======================================

            for _, Object in ipairs(
                VariantFolder:GetChildren()
            ) do

                local Position = GetPosition(Object)

                if Position then

                    local OldPosition =
                        LastPositions[Object]

                    if not OldPosition then

                        LastPositions[Object] =
                            Position

                        print(
                            "[VARIANT DETECTED]",
                            Object:GetFullName(),
                            Position
                        )

                        ProcessVariant(Object)

                    else

                        local Distance =
                            (Position - OldPosition).Magnitude

                        if Distance >= POSITION_THRESHOLD then

                            LastPositions[Object] =
                                Position

                            print(
                                "[VARIANT MOVED]",
                                Object:GetFullName(),
                                "DIST:",
                                Distance,
                                "NEW:",
                                Position
                            )

                            ProcessVariant(Object)

                        end

                    end

                end

            end

            --======================================
            -- CLEAN OLD OBJECTS
            --======================================

            for Object, _ in pairs(LastPositions) do

                if not Object.Parent then
                    LastPositions[Object] = nil
                end

            end

        end

        task.wait(SCAN_INTERVAL)

    end

end)

--==================================================
-- START / STOP
--==================================================

local function Start()

    if Running then
        return
    end

    Running = true

    Status.Text = "Status: RUNNING"
    Status.TextColor3 =
        Color3.fromRGB(100,255,120)

    Toggle.Text = "STOP"
    Toggle.BackgroundColor3 =
        Color3.fromRGB(150,55,55)

    VariantCount = 0
    ActiveCount = 0
    CollectCount = 0

    print("====================================")
    print(" INSTANT TOKEN COLLECTOR V2 START")
    print("====================================")

    print(
        "Variant folder:",
        VariantFolder:GetFullName()
    )

    print(
        "Active folder:",
        ActiveFolder:GetFullName()
    )

    print(
        "Collect folder:",
        CollectFolder:GetFullName()
    )

    -- Quan trọng:
    -- lấy snapshot hiện tại để phát hiện
    -- lần thay đổi vị trí tiếp theo

    SnapshotFolder(
        VariantFolder,
        "Variant"
    )

    SnapshotFolder(
        ActiveFolder,
        "Active"
    )

    -- Collectable đang tồn tại
    for _, Object in ipairs(
        CollectFolder:GetChildren()
    ) do

        print(
            "[INIT COLLECTABLE]",
            Object:GetFullName(),
            GetPosition(Object)
        )

    end

end

local function Stop()

    Running = false

    Status.Text = "Status: STOPPED"
    Status.TextColor3 =
        Color3.fromRGB(255,100,100)

    Toggle.Text = "START"
    Toggle.BackgroundColor3 =
        Color3.fromRGB(45,120,65)

    print("========== STOP ==========")

end

Toggle.MouseButton1Click:Connect(function()

    if Running then
        Stop()
    else
        Start()
    end

end)

--==================================================
-- INITIAL
--==================================================

UpdateInfo("NONE")

print("====================================")
print(" INSTANT TOKEN COLLECTOR V2 LOADED")
print("====================================")
print("VARIANT:", VariantFolder:GetFullName())
print("ACTIVE:", ActiveFolder:GetFullName())
print("COLLECT:", CollectFolder:GetFullName())
print("====================================")
