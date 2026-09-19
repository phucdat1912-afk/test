--==================================================
-- SPIDER LILY TELEPORT UI
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
if not Player then
	warn("LocalPlayer chưa sẵn sàng")
	return
end

local PlayerGui = Player:WaitForChild("PlayerGui")

--==================================================
-- XÓA UI CŨ
--==================================================

local Old = PlayerGui:FindFirstChild("SpiderLilyUI")

if Old then
	Old:Destroy()
end

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "SpiderLilyUI"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(300, 150)
Main.Position = UDim2.new(0.5, -150, 0.5, -75)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 35)
Title.Position = UDim2.fromOffset(10, 8)
Title.BackgroundTransparency = 1
Title.Text = "SPIDER LILY"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 19
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

--==================================================
-- STATUS
--==================================================

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 25)
Status.Position = UDim2.fromOffset(10, 40)
Status.BackgroundTransparency = 1
Status.Text = "Ready"
Status.TextColor3 = Color3.fromRGB(180, 180, 180)
Status.TextSize = 13
Status.Font = Enum.Font.Gotham
Status.Parent = Main

--==================================================
-- BUTTON
--==================================================

local Button = Instance.new("TextButton")
Button.Size = UDim2.new(1, -20, 0, 50)
Button.Position = UDim2.fromOffset(10, 75)
Button.BackgroundColor3 = Color3.fromRGB(65, 120, 220)
Button.BorderSizePixel = 0
Button.Text = "TELEPORT SPIDER LILY"
Button.TextColor3 = Color3.new(1, 1, 1)
Button.TextSize = 14
Button.Font = Enum.Font.GothamBold
Button.Parent = Main

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 7)
ButtonCorner.Parent = Button

--==================================================
-- FIND SPIDER LILY
--==================================================

local function FindSpiderLily()
	local Debree = workspace:FindFirstChild("Debree")

	if not Debree then
		return nil
	end

	return Debree:FindFirstChild("Spider Lily")
end

--==================================================
-- GET TARGET PART
--==================================================

local function GetTargetPart(Object)
	if not Object then
		return nil
	end

	if Object:IsA("BasePart") then
		return Object
	end

	if Object:IsA("Model") then
		if Object.PrimaryPart then
			return Object.PrimaryPart
		end

		return Object:FindFirstChildWhichIsA(
			"BasePart",
			true
		)
	end

	return Object:FindFirstChildWhichIsA(
		"BasePart",
		true
	)
end

--==================================================
-- TELEPORT
--==================================================

local function Teleport()
	Status.Text = "Searching..."

	local SpiderLily = FindSpiderLily()

	if not SpiderLily then
		Status.Text = "Spider Lily not found"
		warn("workspace.Debree['Spider Lily'] không tồn tại")
		return
	end

	local TargetPart = GetTargetPart(SpiderLily)

	if not TargetPart then
		Status.Text = "No target part"
		warn("Spider Lily không có BasePart")
		return
	end

	local Character = Player.Character

	if not Character then
		Status.Text = "Character not found"
		return
	end

	local Root = Character:FindFirstChild(
		"HumanoidRootPart"
	)

	if not Root then
		Status.Text = "Root not found"
		return
	end

	Root.CFrame =
		TargetPart.CFrame
		* CFrame.new(0, 3, 0)

	Status.Text = "Teleported!"
end

Button.Activated:Connect(Teleport)

--==================================================
-- DRAG
--==================================================

local Dragging = false
local DragStart
local StartPosition

Title.InputBegan:Connect(function(Input)

	if Input.UserInputType == Enum.UserInputType.MouseButton1
		or Input.UserInputType == Enum.UserInputType.Touch
	then

		Dragging = true
		DragStart = Input.Position
		StartPosition = Main.Position

		Input.Changed:Connect(function()

			if Input.UserInputState ==
				Enum.UserInputState.End
			then
				Dragging = false
			end

		end)
	end
end)

UserInputService.InputChanged:Connect(function(Input)

	if not Dragging then
		return
	end

	if Input.UserInputType == Enum.UserInputType.MouseMovement
		or Input.UserInputType == Enum.UserInputType.Touch
	then

		local Delta =
			Input.Position - DragStart

		Main.Position = UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + Delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + Delta.Y
		)
	end
end)

print("[SpiderLilyUI] Loaded successfully")
