--// AUTO COLLECT ON SPAWN
--// Item xuất hiện -> TP ngay -> Collect

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

local Remote = ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("CollectCollectableObject")

local Folder = workspace
    :WaitForChild("Systems")
    :WaitForChild("CollectableObjects")

local Enabled = false
local Height = 3

--==================================================
-- UI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "InstantAutoCollect"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 300, 0, 150)
Main.Position = UDim2.new(0.5, -150, 0.5, -75)
Main.BackgroundColor3 = Color3.fromRGB(25,25,30)
Main.BorderSizePixel = 0
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,40)
Title.BackgroundTransparency = 1
Title.Text = "⚡ INSTANT AUTO COLLECT"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local Status = Instance.new("TextLabel")
Status.Position = UDim2.new(0,10,0,42)
Status.Size = UDim2.new(1,-20,0,25)
Status.BackgroundTransparency = 1
Status.Text = "● OFF"
Status.TextColor3 = Color3.fromRGB(255,80,80)
Status.TextSize = 15
Status.Font = Enum.Font.GothamBold
Status.Parent = Main

local Target = Instance.new("TextLabel")
Target.Position = UDim2.new(0,10,0,67)
Target.Size = UDim2.new(1,-20,0,25)
Target.BackgroundTransparency = 1
Target.Text = "Waiting..."
Target.TextColor3 = Color3.fromRGB(190,190,190)
Target.TextSize = 13
Target.Font = Enum.Font.Gotham
Target.Parent = Main

local Button = Instance.new("TextButton")
Button.Position = UDim2.new(0.5,-60,0,100)
Button.Size = UDim2.new(0,120,0,38)
Button.BackgroundColor3 = Color3.fromRGB(45,45,50)
Button.Text = "START"
Button.TextColor3 = Color3.new(1,1,1)
Button.TextSize = 15
Button.Font = Enum.Font.GothamBold
Button.Parent = Main

Instance.new("UICorner", Button).CornerRadius = UDim.new(0,8)

--==================================================
-- POSITION
--==================================================

local function GetPosition(Item)

    if Item:IsA("BasePart") then
        return Item.Position
    end

    if Item:IsA("Model") then
        return Item:GetPivot().Position
    end

    local Part = Item:FindFirstChildWhichIsA("BasePart", true)

    if Part then
        return Part.Position
    end

    return nil
end

--==================================================
-- COLLECT IMMEDIATELY
--==================================================

local function Collect(Item)

    if not Enabled then
        return
    end

    if not Item or not Item.Parent then
        return
    end

    local Position = GetPosition(Item)

    if not Position then
        return
    end

    local Character = Player.Character

    if not Character then
        return
    end

    Target.Text = "TP → " .. Item.Name

    -- TP NGAY
    Character:PivotTo(
        CFrame.new(Position + Vector3.new(0, Height, 0))
    )

    -- Collect NGAY
    task.defer(function()

        if Enabled and Item.Parent then

            pcall(function()
                Remote:FireServer(Item)
            end)

            Target.Text = "Collected → " .. Item.Name
        end

    end)
end

--==================================================
-- TOGGLE
--==================================================

Button.MouseButton1Click:Connect(function()

    Enabled = not Enabled

    if Enabled then

        Status.Text = "● ON"
        Status.TextColor3 = Color3.fromRGB(80,255,120)

        Button.Text = "STOP"
        Button.BackgroundColor3 = Color3.fromRGB(150,45,45)

        -- Nhặt luôn những item đã có
        for _, Item in ipairs(Folder:GetChildren()) do
            task.spawn(function()
                Collect(Item)
            end)
        end

    else

        Status.Text = "● OFF"
        Status.TextColor3 = Color3.fromRGB(255,80,80)

        Button.Text = "START"
        Button.BackgroundColor3 = Color3.fromRGB(45,45,50)

        Target.Text = "Waiting..."
    end
end)

--==================================================
-- INSTANT SPAWN DETECTION
--==================================================

Folder.ChildAdded:Connect(function(Item)

    if not Enabled then
        return
    end

    -- item vừa xuất hiện
    task.defer(function()

        if Item and Item.Parent then
            Collect(Item)
        end

    end)
end)
