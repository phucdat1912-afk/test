local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Remote = ReplicatedStorage.Remotes.CollectCollectableObject
local Folder = workspace.Systems.CollectableObjects

local Enabled = false

-- UI
local Gui = Instance.new("ScreenGui")
Gui.Name = "AutoCollectDebug"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 210)
Main.Position = UDim2.new(0.5, -160, 0.5, -105)
Main.BackgroundColor3 = Color3.fromRGB(25,25,30)
Main.BorderSizePixel = 0
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,35)
Title.BackgroundTransparency = 1
Title.Text = "AUTO COLLECT DEBUG"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

local Info = Instance.new("TextLabel")
Info.Position = UDim2.new(0,10,0,40)
Info.Size = UDim2.new(1,-20,0,80)
Info.BackgroundTransparency = 1
Info.Text = "Waiting..."
Info.TextColor3 = Color3.fromRGB(200,200,200)
Info.TextSize = 13
Info.Font = Enum.Font.Gotham
Info.TextWrapped = true
Info.TextXAlignment = Enum.TextXAlignment.Left
Info.TextYAlignment = Enum.TextYAlignment.Top
Info.Parent = Main

local Button = Instance.new("TextButton")
Button.Position = UDim2.new(0.5,-65,0,135)
Button.Size = UDim2.new(0,130,0,40)
Button.BackgroundColor3 = Color3.fromRGB(50,50,55)
Button.Text = "START"
Button.TextColor3 = Color3.new(1,1,1)
Button.TextSize = 16
Button.Font = Enum.Font.GothamBold
Button.Parent = Main

Instance.new("UICorner", Button).CornerRadius = UDim.new(0,8)

-- Lấy character mới nhất
local function GetRoot()
    local Character = Player.Character or Player.CharacterAdded:Wait()

    return Character:FindFirstChild("HumanoidRootPart")
        or Character:FindFirstChild("UpperTorso")
        or Character:FindFirstChild("Torso")
end

-- Lấy vị trí object
local function GetObjectPosition(Object)

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

    if Enabled then
        Button.Text = "STOP"
        Button.BackgroundColor3 = Color3.fromRGB(150,50,50)
    else
        Button.Text = "START"
        Button.BackgroundColor3 = Color3.fromRGB(50,50,55)
        Info.Text = "Stopped"
    end
end)

task.spawn(function()

    while Gui.Parent do

        if Enabled then

            local Items = Folder:GetChildren()

            Info.Text =
                "Items: " .. #Items ..
                "\nScanning..."

            for _, Item in ipairs(Items) do

                if not Enabled then
                    break
                end

                if Item.Parent then

                    local Position = GetObjectPosition(Item)
                    local Root = GetRoot()

                    if Position and Root then

                        Info.Text =
                            "Target: " .. Item:GetFullName() ..
                            "\nPosition: " ..
                            math.floor(Position.X) .. ", " ..
                            math.floor(Position.Y) .. ", " ..
                            math.floor(Position.Z) ..
                            "\nTeleporting..."

                        -- TP
                        Root.CFrame =
                            CFrame.new(Position + Vector3.new(0,3,0))

                        task.wait(0.5)

                        Info.Text =
                            "Target: " .. Item.Name ..
                            "\nTeleport done\nCollecting..."

                        -- Collect
                        pcall(function()
                            Remote:FireServer(Item)
                        end)

                        task.wait(0.3)
                    end
                end
            end

        else
            task.wait(0.2)
        end

        task.wait(0.1)
    end
end)
