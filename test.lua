local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "SpiderLilyTest"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(260, 60)
button.Position = UDim2.new(0.5, -130, 0.5, -30)
button.Text = "TELEPORT SPIDER LILY"
button.TextSize = 16
button.Parent = gui

button.Activated:Connect(function()
	local debree = workspace:FindFirstChild("Debree")
	local target = debree and debree:FindFirstChild("Spider Lily")

	if not target then
		button.Text = "Spider Lily NOT FOUND"
		return
	end

	local part

	if target:IsA("BasePart") then
		part = target
	elseif target:IsA("Model") then
		part = target.PrimaryPart
			or target:FindFirstChildWhichIsA("BasePart", true)
	end

	local root = player.Character
		and player.Character:FindFirstChild("HumanoidRootPart")

	if part and root then
		root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
		button.Text = "TELEPORTED!"
	else
		button.Text = "TARGET ERROR"
	end
end)
