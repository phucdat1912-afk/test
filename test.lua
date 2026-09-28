--// AUTO COLLECT UI
--// Simple UI + Auto Collect

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local CollectRemote = ReplicatedStorage:WaitForChild("Remotes")
    :WaitForChild("CollectCollectableObject")

local Folder = workspace:WaitForChild("Systems")
    :WaitForChild("CollectableObjects")

--==================================================
-- UI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "AutoCollectUI"
Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 280, 0, 180)
Main.Position = UDim2.new(0.5, -140, 0.5, -90)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(70, 70, 80)
Stroke.Thickness = 1
Stroke.Parent = Main

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "🧲 AUTO COLLECT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

-- Status
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 25)
Status.Position = UDim2.new(0, 10, 0, 42)
Status.BackgroundTransparency = 1
Status.Text = "● OFF"
Status.TextColor3 = Color3.fromRGB(255, 80, 80)
Status.TextSize = 15
Status.Font = Enum.Font.GothamSemibold
Status.Parent = Main

-- Item count
local Count = Instance.new("TextLabel")
Count.Size = UDim2.new(1, -20, 0, 25)
Count.Position = UDim2.new(0, 10, 0, 68)
Count.BackgroundTransparency = 1
Count.Text = "Items found: 0"
Count.TextColor3 = Color3.fromRGB(200, 200, 200)
Count.TextSize = 14
Count.Font = Enum.Font.Gotham
Count.Parent = Main

-- Toggle
local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0, 120, 0, 38)
Toggle.Position = UDim2.new(0.5, -60, 0, 105)
Toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
Toggle.BorderSizePixel = 0
Toggle.Text = "START"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.TextSize = 16
Toggle.Font = Enum.Font.GothamBold
Toggle.Parent = Main

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = Toggle

-- Delay
local DelayLabel = Instance.new("TextLabel")
DelayLabel.Size = UDim2.new(1, -20, 0, 20)
DelayLabel.Position = UDim2.new(0, 10, 0, 150)
DelayLabel.BackgroundTransparency = 1
DelayLabel.Text = "Scan delay: 0.15s"
DelayLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
DelayLabel.TextSize = 12
DelayLabel.Font = Enum.Font.Gotham
DelayLabel.Parent = Main

--==================================================
-- AUTO COLLECT
--==================================================

local Enabled = false
local Delay = 0.15

local function UpdateUI()
    if Enabled then
        Status.Text = "● ON"
        Status.TextColor3 = Color3.fromRGB(80, 255, 120)

        Toggle.Text = "STOP"
        Toggle.BackgroundColor3 = Color3.fromRGB(150, 45, 45)
    else
        Status.Text = "● OFF"
        Status.TextColor3 = Color3.fromRGB(255, 80, 80)

        Toggle.Text = "START"
        Toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    end
end

Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    UpdateUI()
end)

task.spawn(function()
    while Gui.Parent do

        if Enabled then

            local Items = Folder:GetChildren()

            Count.Text = "Items found: " .. #Items

            for _, item in ipairs(Items) do

                if not Enabled then
                    break
                end

                if item and item.Parent then
                    pcall(function()
                        CollectRemote:FireServer(item)
                    end)

                    task.wait(Delay)
                end
            end

        else
            Count.Text = "Items found: " .. #Folder:GetChildren()
            task.wait(0.2)
        end

        task.wait(Delay)
    end
end)

UpdateUI()
