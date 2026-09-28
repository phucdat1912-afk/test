--========================================================
-- INSTANT TOKEN COLLECT
-- CollectableObjects
-- ActiveCollectableObjects
-- ActiveVariantTokenSpawns
--========================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

local Systems = workspace:WaitForChild("Systems")

local CollectableObjects =
    Systems:WaitForChild("CollectableObjects")

local ActiveCollectableObjects =
    Systems:WaitForChild("ActiveCollectableObjects")

local ActiveVariantTokenSpawns =
    Systems:WaitForChild("ActiveVariantTokenSpawns")

local Remote =
    ReplicatedStorage
        :WaitForChild("Remotes")
        :WaitForChild("CollectCollectableObject")

local Enabled = false
local Processing = {}

local TP_HEIGHT = 3
local DETECT_DISTANCE = 20
local COLLECT_DELAY = 0.08

--========================================================
-- UI
--========================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "InstantTokenCollector"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 330, 0, 210)
Main.Position = UDim2.new(0.5, -165, 0.5, -105)
Main.BackgroundColor3 = Color3.fromRGB(24, 24, 29)
Main.BorderSizePixel = 0
Main.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(70, 70, 80)
Stroke.Thickness = 1
Stroke.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 38)
Title.BackgroundTransparency = 1
Title.Text = "⚡ INSTANT TOKEN COLLECT"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local Status = Instance.new("TextLabel")
Status.Position = UDim2.new(0, 15, 0, 43)
Status.Size = UDim2.new(1, -30, 0, 25)
Status.BackgroundTransparency = 1
Status.Text = "● OFF"
Status.TextColor3 = Color3.fromRGB(255, 80, 80)
Status.TextSize = 15
Status.Font = Enum.Font.GothamBold
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

local Target = Instance.new("TextLabel")
Target.Position = UDim2.new(0, 15, 0, 70)
Target.Size = UDim2.new(1, -30, 0, 25)
Target.BackgroundTransparency = 1
Target.Text = "Target: None"
Target.TextColor3 = Color3.fromRGB(210, 210, 210)
Target.TextSize = 13
Target.Font = Enum.Font.Gotham
Target.TextXAlignment = Enum.TextXAlignment.Left
Target.Parent = Main

local Source = Instance.new("TextLabel")
Source.Position = UDim2.new(0, 15, 0, 95)
Source.Size = UDim2.new(1, -30, 0, 25)
Source.BackgroundTransparency = 1
Source.Text = "Source: Waiting..."
Source.TextColor3 = Color3.fromRGB(170, 170, 170)
Source.TextSize = 12
Source.Font = Enum.Font.Gotham
Source.TextXAlignment = Enum.TextXAlignment.Left
Source.Parent = Main

local Button = Instance.new("TextButton")
Button.Position = UDim2.new(0.5, -70, 0, 135)
Button.Size = UDim2.new(0, 140, 0, 42)
Button.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
Button.BorderSizePixel = 0
Button.Text = "START"
Button.TextColor3 = Color3.new(1, 1, 1)
Button.TextSize = 16
Button.Font = Enum.Font.GothamBold
Button.Parent = Main

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = Button

local Info = Instance.new("TextLabel")
Info.Position = UDim2.new(0, 15, 0, 180)
Info.Size = UDim2.new(1, -30, 0, 20)
Info.BackgroundTransparency = 1
Info.Text = "Collectable: 0 | Spawn: 0"
Info.TextColor3 = Color3.fromRGB(130, 130, 140)
Info.TextSize = 11
Info.Font = Enum.Font.Gotham
Info.Parent = Main

--========================================================
-- GET POSITION
--========================================================

local function GetPosition(Object)

    if not Object or not Object.Parent then
        return nil
    end

    if Object:IsA("BasePart") then
        return Object.Position
    end

    if Object:IsA("Model") then
        return Object:GetPivot().Position
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

--========================================================
-- GET CHARACTER
--========================================================

local function GetCharacter()

    local Character = Player.Character

    if not Character then
        return nil
    end

    if not Character.Parent then
        return nil
    end

    return Character
end

--========================================================
-- FIND COLLECTABLE NEAREST TO POSITION
--========================================================

local function FindNearestCollectable(Position)

    local Best = nil
    local BestDistance = DETECT_DISTANCE

    for _, Object in ipairs(
        CollectableObjects:GetChildren()
    ) do

        if Object:IsA("BasePart")
            or Object:IsA("Model") then

            local ObjectPosition =
                GetPosition(Object)

            if ObjectPosition then

                local Distance =
                    (ObjectPosition - Position).Magnitude

                if Distance <= BestDistance then
                    BestDistance = Distance
                    Best = Object
                end
            end
        end
    end

    return Best
end

--========================================================
-- COLLECT ONE OBJECT
--========================================================

local function CollectObject(Object, SourceName)

    if not Enabled then
        return
    end

    if not Object or not Object.Parent then
        return
    end

    if Processing[Object] then
        return
    end

    Processing[Object] = true

    local Position = GetPosition(Object)

    if Position then

        local Character = GetCharacter()

        if Character then

            Target.Text =
                "Target: " .. Object.Name

            Source.Text =
                "Source: " .. SourceName

            -- TP
            Character:PivotTo(
                CFrame.new(
                    Position +
                    Vector3.new(0, TP_HEIGHT, 0)
                )
            )

            task.wait(COLLECT_DELAY)

            -- Remote
            if Object.Parent and Enabled then

                pcall(function()
                    Remote:FireServer(Object)
                end)

            end
        end
    end

    task.delay(0.2, function()
        Processing[Object] = nil
    end)
end

--========================================================
-- SPAWN POSITION -> FIND REAL COLLECTABLE
--========================================================

local function ProcessSpawnObject(Object)

    if not Enabled then
        return
    end

    local Position = GetPosition(Object)

    if not Position then
        return
    end

    -- Tìm Part thật trong CollectableObjects
    local TargetObject =
        FindNearestCollectable(Position)

    if TargetObject then

        task.spawn(function()

            CollectObject(
                TargetObject,
                "ActiveVariantTokenSpawns"
            )

        end)

    end
end

--========================================================
-- COLLECTABLE OBJECTS
--========================================================

CollectableObjects.ChildAdded:Connect(function(Object)

    if not Enabled then
        return
    end

    task.spawn(function()

        -- đợi object có vị trí hoàn chỉnh
        task.wait(0.03)

        CollectObject(
            Object,
            "CollectableObjects"
        )

    end)
end)

--========================================================
-- ACTIVE COLLECTABLE OBJECTS
--========================================================

ActiveCollectableObjects.ChildAdded:Connect(function(Object)

    if not Enabled then
        return
    end

    task.spawn(function()

        task.wait(0.03)

        local Position = GetPosition(Object)

        if Position then

            local TargetObject =
                FindNearestCollectable(Position)

            if TargetObject then

                CollectObject(
                    TargetObject,
                    "ActiveCollectableObjects"
                )

            end
        end
    end)
end)

--========================================================
-- ACTIVE VARIANT TOKEN SPAWNS
--========================================================

ActiveVariantTokenSpawns.ChildAdded:Connect(function(Object)

    if not Enabled then
        return
    end

    task.spawn(function()

        task.wait(0.03)

        ProcessSpawnObject(Object)

    end)
end)

--========================================================
-- BUTTON
--========================================================

Button.MouseButton1Click:Connect(function()

    Enabled = not Enabled

    if Enabled then

        Status.Text = "● ON"
        Status.TextColor3 =
            Color3.fromRGB(80, 255, 120)

        Button.Text = "STOP"
        Button.BackgroundColor3 =
            Color3.fromRGB(150, 45, 45)

        -- Xử lý item đã tồn tại
        for _, Object in ipairs(
            CollectableObjects:GetChildren()
        ) do

            task.spawn(function()
                CollectObject(
                    Object,
                    "Existing Collectable"
                )
            end)

        end

    else

        Status.Text = "● OFF"
        Status.TextColor3 =
            Color3.fromRGB(255, 80, 80)

        Button.Text = "START"
        Button.BackgroundColor3 =
            Color3.fromRGB(45, 45, 52)

        Target.Text = "Target: None"
        Source.Text = "Source: Waiting..."
    end
end)

--========================================================
-- LIVE COUNTER
--========================================================

task.spawn(function()

    while Gui.Parent do

        Info.Text =
            "Collectable: "
            .. #CollectableObjects:GetChildren()
            .. " | Spawn: "
            .. #ActiveVariantTokenSpawns:GetChildren()

        task.wait(0.2)
    end

end)
