--==================================================
-- SPIDER LILY TELEPORT UI
-- Roblox Studio / Game bạn sở hữu
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--==================================================
-- GUI
--==================================================

local OldGui = PlayerGui:FindFirstChild("SpiderLilyTeleport")
if OldGui then
	OldGui:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "SpiderLilyTeleport"
Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(280, 130)
Main.Position = UDim2.new(0.5, -140, 0.5, -65)
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
Title.Position = UDim2.fromOffset(10, 5)
Title.BackgroundTransparency = 1
Title.Text = "SPIDER LILY"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Main

--==================================================
-- TELEPORT BUTTON
--==================================================

local TeleportButton = Instance.new("TextButton")
TeleportButton.Size = UDim2.new(1, -20, 0, 50)
TeleportButton.Position = UDim2.fromOffset(10, 45)
TeleportButton.BackgroundColor3 = Color3.fromRGB(65, 125, 220)
TeleportButton.BorderSizePixel = 0
TeleportButton.Text = "TELEPORT SPIDER LILY"
TeleportButton.TextColor3 = Color3.new(1, 1, 1)
TeleportButton.Font = Enum.Font.GothamBold
TeleportButton.TextSize = 14
TeleportButton.Parent = Main

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 7)
ButtonCorner.Parent = TeleportButton

--==================================================
-- TELEPORT
--==================================================

local function TeleportToSpiderLily()

	local Debree = workspace:FindFirstChild("Debree")

	if not Debree then
		TeleportButton.Text = "DEBREE NOT FOUND"

		task.delay(1.5, function()
			if TeleportButton.Parent then
				TeleportButton.Text = "TELEPORT SPIDER LILY"
			end
		end)

		return
	end

	local SpiderLily = Debree:FindFirstChild("Spider Lily")

	if not SpiderLily then
		TeleportButton.Text = "SPIDER LILY NOT FOUND"

		task.delay(1.5, function()
			if TeleportButton.Parent then
				TeleportButton.Text = "TELEPORT SPIDER LILY"
			end
		end)

		return
	end

	local TargetPart

	if SpiderLily:IsA("BasePart") then
		TargetPart = SpiderLily

	elseif SpiderLily:IsA("Model") then
		TargetPart =
			SpiderLily.PrimaryPart
			or SpiderLily:FindFirstChildWhichIsA(
				"BasePart",
				true
			)
	end

	if not TargetPart then
		TeleportButton.Text = "NO TARGET PART"

		task.delay(1.5, function()
			if TeleportButton.Parent then
				TeleportButton.Text = "TELEPORT SPIDER LILY"
			end
		end)

		return
	end

	local Character = Player.Character

	if not Character then
		return
	end

	local Root =
		Character:FindFirstChild("HumanoidRootPart")

	if not Root then
		return
	end

	Root.CFrame =
		TargetPart.CFrame
		* CFrame.new(0, 3, 0)

	TeleportButton.Text = "TELEPORTED!"

	task.delay(1.2, function()
		if TeleportButton.Parent then
			TeleportButton.Text = "TELEPORT SPIDER LILY"
		end
	end)
end

TeleportButton.MouseButton1Click:Connect(
	TeleportToSpiderLily
)

--==================================================
-- DRAG UI
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

			if Input.UserInputState
				== Enum.UserInputState.End
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

print("[Spider Lily UI] Loaded")
