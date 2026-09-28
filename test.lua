-- AUTO COLLECT - TP TEST

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CollectCollectableObject")
local Folder = workspace:WaitForChild("Systems"):WaitForChild("CollectableObjects")

local Enabled = false

-- UI
local Gui = Instance.new("ScreenGui")
Gui.Name = "TPCollectTest"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(0, 180, 0, 50)
Button.Position = UDim2.new(0.5, -90, 0.5, -25)
Button.BackgroundColor3 = Color3.fromRGB(40,40,45)
Button.TextColor3 = Color3.new(1,1,1)
Button.Text = "TP TEST: OFF"
Button.TextSize = 18
Button.Font = Enum.Font.GothamBold
Button.Parent = Gui

Instance.new("UICorner", Button).CornerRadius = UDim.new(0,10)

local function GetRoot()
    local Character = Player.Character
    if not Character then return nil end

    return Character:FindFirstChild("HumanoidRootPart")
        or Character.PrimaryPart
end

local function GetPosition(Object)

    if Object:IsA("BasePart") then
        return Object.Position
    end

    if Object:IsA("Model") then
        return Object:GetPivot().Position
    end

    local Part = Object:FindFirstChildWhichIsA("BasePart", true)

    if Part then
        return Part.Position
    end

    return nil
end

Button.MouseButton1Click:Connect(function()

    Enabled = not Enabled

    if not Enabled then
        Button.Text = "TP TEST: OFF"
        return
    end

    Button.Text = "TP TEST: ON"

    -- lấy item đầu tiên
    local Item = Folder:GetChildren()[1]

    if not Item then
        Button.Text = "NO ITEM"
        Enabled = false
        return
    end

    local Position = GetPosition(Item)
    local Root = GetRoot()

    if not Position then
        Button.Text = "NO POSITION"
        Enabled = false
        return
    end

    if not Root then
        Button.Text = "NO ROOT"
        Enabled = false
        return
    end

    -- TP tới item
    Root.CFrame = CFrame.new(Position + Vector3.new(0, 3, 0))

    task.wait(0.5)

    -- gọi collect
    pcall(function()
        Remote:FireServer(Item)
    end)

    Button.Text = "TP: " .. Item.Name

    task.wait(1)

    Enabled = false
    Button.Text = "TP TEST: OFF"
end)
