--// AUTO TELEPORT COLLECT
--// Teleport -> Collect -> Next Item

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

local Remote = ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("CollectCollectableObject")

local Folder = workspace
    :WaitForChild("Systems")
    :WaitForChild("CollectableObjects")

--==================================================
-- SETTINGS
--==================================================

local Enabled = false
local TeleportHeight = 3
local CollectDelay = 0.15
local ScanDelay = 0.2

--==================================================
-- UI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "AutoTeleportCollect"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 300, 0, 190)
Main.Position = UDim2.new(0.5, -150, 0.5, -95)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "⚡ AUTO TELEPORT COLLECT"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local Status = Instance.new("TextLabel")
Status.Position = UDim2.new(0, 10, 0, 42)
Status.Size = UDim2.new(1, -20, 0, 25)
Status.BackgroundTransparency = 1
Status.Text = "● OFF"
Status.TextColor3 = Color3.fromRGB(255, 80, 80)
Status.TextSize = 15
Status.Font = Enum.Font.GothamBold
Status.Parent = Main

local Target = Instance.new("TextLabel")
Target.Position = UDim2.new(0, 10, 0, 70)
Target.Size = UDim2.new(1, -20, 0, 25)
Target.BackgroundTransparency = 1
Target.Text = "Target: None"
Target.TextColor3 = Color3.fromRGB(200, 200, 200)
Target.TextSize = 14
Target.Font = Enum.Font.Gotham
Target.Parent = Main

local Count = Instance.new("TextLabel")
Count.Position = UDim2.new(0, 10, 0, 94)
Count.Size = UDim2.new(1, -20, 0, 25)
Count.BackgroundTransparency = 1
Count.Text = "Items: 0"
Count.TextColor3 = Color3.fromRGB(200, 200, 200)
Count.TextSize = 14
Count.Font = Enum.Font.Gotham
Count.Parent = Main

local Button = Instance.new("TextButton")
Button.Position = UDim2.new(0.5, -65, 0, 130)
Button.Size = UDim2.new(0, 130, 0, 40)
Button.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
Button.BorderSizePixel = 0
Button.Text = "START"
Button.TextColor3 = Color3.new(1, 1, 1)
Button.TextSize = 16
Button.Font = Enum.Font.GothamBold
Button.Parent = Main

Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)

--==================================================
-- CHARACTER
--==================================================

local function UpdateCharacter()
    Character = Player.Character or Player.CharacterAdded:Wait()
    Root = Character:WaitForChild("HumanoidRootPart")
end

Player.CharacterAdded:Connect(function()
    task.wait(1)
    UpdateCharacter()
end)

--==================================================
-- GET ITEM POSITION
--==================================================

local function GetPosition(Object)
    if Object:IsA("BasePart") then
        return Object.Position
    end

    if Object:IsA("Model") then
        local Part = Object.PrimaryPart
            or Object:FindFirstChildWhichIsA("BasePart", true)

        if Part then
            return Part.Position
        end
    end

    return nil
end

--==================================================
-- TELEPORT + COLLECT
--==================================================

local function CollectItem(Item)

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

    Target.Text = "Target: " .. Item.Name

    -- Teleport tới item
    Root.CFrame = CFrame.new(
        Position + Vector3.new(0, TeleportHeight, 0)
    )

    task.wait(CollectDelay)

    -- Nhặt
    if Item.Parent then
        pcall(function()
            Remote:FireServer(Item)
        end)
    end

    task.wait(CollectDelay)
end

--==================================================
-- BUTTON
--==================================================

Button.MouseButton1Click:Connect(function()

    Enabled = not Enabled

    if Enabled then
        Status.Text = "● ON"
        Status.TextColor3 = Color3.fromRGB(80, 255, 120)

        Button.Text = "STOP"
        Button.BackgroundColor3 = Color3.fromRGB(150, 45, 45)

    else
        Status.Text = "● OFF"
        Status.TextColor3 = Color3.fromRGB(255, 80, 80)

        Button.Text = "START"
        Button.BackgroundColor3 = Color3.fromRGB(45, 45, 50)

        Target.Text = "Target: None"
    end
end)

--==================================================
-- MAIN LOOP
--==================================================

task.spawn(function()

    while Gui.Parent do

        if Enabled then

            UpdateCharacter()

            local Items = Folder:GetChildren()

            Count.Text = "Items: " .. #Items

            for _, Item in ipairs(Items) do

                if not Enabled then
                    break
                end

                if Item and Item.Parent then
                    CollectItem(Item)
                end

            end

        else

            Count.Text = "Items: " .. #Folder:GetChildren()

        end

        task.wait(ScanDelay)
    end

end)
