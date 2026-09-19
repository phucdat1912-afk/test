--==================================================
-- NPC + PLAYER HUB
-- LOAD MANUALLY
-- TELEPORT + ESP + NAME
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- CLEAN OLD
--==================================================

local Old = PlayerGui:FindFirstChild("NPCPlayerHub")

if Old then
	Old:Destroy()
end

--==================================================
-- DATA
--==================================================

local NPCList = {}
local PlayerList = {}

local CurrentTab = "ALL"
local ESPEnabled = false
local ESPObjects = {}

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "NPCPlayerHub"
Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(390, 560)
Main.Position = UDim2.new(0.5, -195, 0.5, -280)
Main.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 40)
Title.Position = UDim2.fromOffset(10, 5)
Title.BackgroundTransparency = 1
Title.Text = "NPC + PLAYER HUB"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 19
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

--==================================================
-- LOAD BUTTON
--==================================================

local LoadButton = Instance.new("TextButton")
LoadButton.Size = UDim2.new(1, -20, 0, 40)
LoadButton.Position = UDim2.fromOffset(10, 48)
LoadButton.BackgroundColor3 = Color3.fromRGB(65, 120, 220)
LoadButton.BorderSizePixel = 0
LoadButton.Text = "LOAD NPC + PLAYER"
LoadButton.TextColor3 = Color3.new(1, 1, 1)
LoadButton.TextSize = 13
LoadButton.Font = Enum.Font.GothamBold
LoadButton.Parent = Main

local LoadCorner = Instance.new("UICorner")
LoadCorner.CornerRadius = UDim.new(0, 8)
LoadCorner.Parent = LoadButton

--==================================================
-- ESP BUTTON
--==================================================

local ESPButton = Instance.new("TextButton")
ESPButton.Size = UDim2.new(1, -20, 0, 35)
ESPButton.Position = UDim2.fromOffset(10, 93)
ESPButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
ESPButton.BorderSizePixel = 0
ESPButton.Text = "ESP: OFF"
ESPButton.TextColor3 = Color3.new(1, 1, 1)
ESPButton.TextSize = 13
ESPButton.Font = Enum.Font.GothamBold
ESPButton.Parent = Main

local ESPCorner = Instance.new("UICorner")
ESPCorner.CornerRadius = UDim.new(0, 7)
ESPCorner.Parent = ESPButton

--==================================================
-- TABS
--==================================================

local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -20, 0, 35)
TabFrame.Position = UDim2.fromOffset(10, 135)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = Main

local function CreateTab(Name, X)

	local Button = Instance.new("TextButton")

	Button.Size = UDim2.new(0.32, -4, 1, 0)
	Button.Position = UDim2.new(X, 0, 0, 0)

	Button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	Button.BorderSizePixel = 0

	Button.Text = Name
	Button.TextColor3 = Color3.new(1, 1, 1)
	Button.TextSize = 12
	Button.Font = Enum.Font.GothamBold

	Button.Parent = TabFrame

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 7)
	Corner.Parent = Button

	return Button
end

local AllTab = CreateTab("ALL", 0)
local NPCTab = CreateTab("NPC", 0.34)
local PlayerTab = CreateTab("PLAYER", 0.68)

--==================================================
-- SEARCH
--==================================================

local Search = Instance.new("TextBox")
Search.Size = UDim2.new(1, -20, 0, 35)
Search.Position = UDim2.fromOffset(10, 178)
Search.BackgroundColor3 = Color3.fromRGB(35, 35, 43)
Search.BorderSizePixel = 0
Search.PlaceholderText = "Search loaded NPC / Player..."
Search.Text = ""
Search.TextColor3 = Color3.new(1, 1, 1)
Search.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
Search.TextSize = 13
Search.Font = Enum.Font.Gotham
Search.Parent = Main

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 7)
SearchCorner.Parent = Search

--==================================================
-- LIST
--==================================================

local List = Instance.new("ScrollingFrame")
List.Size = UDim2.new(1, -20, 1, -225)
List.Position = UDim2.fromOffset(10, 223)
List.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
List.BorderSizePixel = 0
List.ScrollBarThickness = 5
List.CanvasSize = UDim2.new()
List.Parent = Main

local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0, 8)
ListCorner.Parent = List

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 5)
Layout.Parent = List

--==================================================
-- GET ROOT
--==================================================

local function GetRoot(Object)

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
	end

	return Object:FindFirstChildWhichIsA(
		"BasePart",
		true
	)
end

--==================================================
-- SCAN NPC
--==================================================

local function ScanNPC()

	table.clear(NPCList)

	for _, Object in ipairs(workspace:GetDescendants()) do

		if Object:IsA("Model") then

			local Humanoid =
				Object:FindFirstChildOfClass("Humanoid")

			if Humanoid then

				local Player =
					Players:GetPlayerFromCharacter(Object)

				if not Player then
					table.insert(NPCList, Object)
				end
			end
		end
	end
end

--==================================================
-- SCAN PLAYER
--==================================================

local function ScanPlayers()

	table.clear(PlayerList)

	for _, Player in ipairs(Players:GetPlayers()) do

		if Player ~= LocalPlayer then
			table.insert(PlayerList, Player)
		end
	end
end

--==================================================
-- TELEPORT
--==================================================

local function TeleportTo(Object)

	local TargetPart

	if typeof(Object) == "Instance" then

		TargetPart = GetRoot(Object)

	elseif typeof(Object) == "table" then

		if Object.Character then
			TargetPart =
				GetRoot(Object.Character)
		end
	end

	if not TargetPart then
		return
	end

	local Character = LocalPlayer.Character

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
end

--==================================================
-- REMOVE ESP
--==================================================

local function RemoveESP(Object)

	local Data = ESPObjects[Object]

	if not Data then
		return
	end

	if Data.Highlight then
		Data.Highlight:Destroy()
	end

	if Data.Billboard then
		Data.Billboard:Destroy()
	end

	ESPObjects[Object] = nil
end

--==================================================
-- ADD ESP
--==================================================

local function AddESP(Object, DisplayName)

	if not Object or not Object.Parent then
		return
	end

	local Part = GetRoot(Object)

	if not Part then
		return
	end

	RemoveESP(Object)

	local Highlight = Instance.new("Highlight")
	Highlight.Name = "NPCPlayerESP"
	Highlight.Adornee = Object
	Highlight.DepthMode =
		Enum.HighlightDepthMode.AlwaysOnTop
	Highlight.FillTransparency = 0.75
	Highlight.OutlineTransparency = 0
	Highlight.Parent = Object

	local Billboard = Instance.new("BillboardGui")
	Billboard.Name = "NPCPlayerName"
	Billboard.Adornee = Part
	Billboard.Size = UDim2.fromOffset(220, 40)
	Billboard.StudsOffset =
		Vector3.new(0, 3, 0)
	Billboard.AlwaysOnTop = true
	Billboard.Parent = Part

	local Text = Instance.new("TextLabel")
	Text.Size = UDim2.fromScale(1, 1)
	Text.BackgroundTransparency = 1
	Text.Text = DisplayName
	Text.TextColor3 = Color3.new(1, 1, 1)
	Text.TextStrokeTransparency = 0
	Text.TextSize = 14
	Text.Font = Enum.Font.GothamBold
	Text.Parent = Billboard

	ESPObjects[Object] = {
		Highlight = Highlight,
		Billboard = Billboard
	}
end

--==================================================
-- UPDATE ESP
--==================================================

local function UpdateESP()

	for Object in pairs(ESPObjects) do
		RemoveESP(Object)
	end

	if not ESPEnabled then
		return
	end

	-- NPC
	for _, NPC in ipairs(NPCList) do

		if NPC.Parent then
			AddESP(
				NPC,
				"NPC: " .. NPC.Name
			)
		end
	end

	-- PLAYER
	for _, Player in ipairs(PlayerList) do

		local Character = Player.Character

		if Character and Character.Parent then

			AddESP(
				Character,
				"PLAYER: " .. Player.Name
			)
		end
	end
end

--==================================================
-- CLEAR LIST
--==================================================

local function ClearList()

	for _, Child in ipairs(List:GetChildren()) do

		if Child:IsA("Frame") then
			Child:Destroy()
		end
	end
end

--==================================================
-- CREATE ITEM
--==================================================

local function CreateItem(Name, Type, Object)

	local Item = Instance.new("Frame")

	Item.Size = UDim2.new(1, -10, 0, 45)
	Item.BackgroundColor3 =
		Color3.fromRGB(40, 40, 48)
	Item.BorderSizePixel = 0
	Item.Parent = List

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 6)
	Corner.Parent = Item

	local Label = Instance.new("TextLabel")

	Label.Size = UDim2.new(1, -100, 1, 0)
	Label.Position = UDim2.fromOffset(10, 0)
	Label.BackgroundTransparency = 1

	Label.Text =
		"[" .. Type .. "] " .. Name

	Label.TextColor3 = Color3.new(1, 1, 1)
	Label.TextSize = 12
	Label.TextXAlignment =
		Enum.TextXAlignment.Left
	Label.Font = Enum.Font.Gotham

	Label.Parent = Item

	local Button = Instance.new("TextButton")

	Button.Size = UDim2.fromOffset(80, 30)
	Button.Position =
		UDim2.new(1, -88, 0.5, -15)

	Button.BackgroundColor3 =
		Color3.fromRGB(65, 120, 220)

	Button.BorderSizePixel = 0
	Button.Text = "TELEPORT"
	Button.TextColor3 = Color3.new(1, 1, 1)
	Button.TextSize = 10
	Button.Font = Enum.Font.GothamBold
	Button.Parent = Item

	local ButtonCorner = Instance.new("UICorner")
	ButtonCorner.CornerRadius = UDim.new(0, 5)
	ButtonCorner.Parent = Button

	Button.Activated:Connect(function()
		TeleportTo(Object)
	end)
end

--==================================================
-- REFRESH
--==================================================

local function Refresh()

	ClearList()

	local Query =
		string.lower(Search.Text)

	local function Match(Name)

		return Query == ""
			or string.find(
				string.lower(Name),
				Query,
				1,
				true
			)
	end

	-- NPC
	if CurrentTab == "ALL"
		or CurrentTab == "NPC"
	then

		for _, NPC in ipairs(NPCList) do

			if NPC.Parent
				and Match(NPC.Name)
			then

				CreateItem(
					NPC.Name,
					"NPC",
					NPC
				)
			end
		end
	end

	-- PLAYER
	if CurrentTab == "ALL"
		or CurrentTab == "PLAYER"
	then

		for _, Player in ipairs(PlayerList) do

			if Match(Player.Name) then

				CreateItem(
					Player.Name,
					"PLAYER",
					Player
				)
			end
		end
	end

	task.defer(function()

		List.CanvasSize = UDim2.fromOffset(
			0,
			Layout.AbsoluteContentSize.Y + 10
		)

	end)
end

--==================================================
-- LOAD
--==================================================

LoadButton.Activated:Connect(function()

	LoadButton.Text = "LOADING..."

	ScanNPC()
	ScanPlayers()

	LoadButton.Text =
		"LOADED: "
		.. #NPCList
		.. " NPC / "
		.. #PlayerList
		.. " PLAYER"

	Refresh()

	if ESPEnabled then
		UpdateESP()
	end
end)

--==================================================
-- ESP TOGGLE
--==================================================

ESPButton.Activated:Connect(function()

	ESPEnabled = not ESPEnabled

	if ESPEnabled then
		ESPButton.Text = "ESP: ON"
	else
		ESPButton.Text = "ESP: OFF"
	end

	UpdateESP()
end)

--==================================================
-- TABS
--==================================================

AllTab.Activated:Connect(function()

	CurrentTab = "ALL"
	Refresh()

end)

NPCTab.Activated:Connect(function()

	CurrentTab = "NPC"
	Refresh()

end)

PlayerTab.Activated:Connect(function()

	CurrentTab = "PLAYER"
	Refresh()

end)

--==================================================
-- SEARCH
--==================================================

Search:GetPropertyChangedSignal("Text"):Connect(function()
	Refresh()
end)

--==================================================
-- DRAG
--==================================================

local Dragging = false
local DragStart
local StartPosition

Title.InputBegan:Connect(function(Input)

	if Input.UserInputType ==
		Enum.UserInputType.MouseButton1
		or Input.UserInputType ==
		Enum.UserInputType.Touch
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

	if Input.UserInputType ==
		Enum.UserInputType.MouseMovement
		or Input.UserInputType ==
		Enum.UserInputType.Touch
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

print("[NPCPlayerHub] Loaded")
