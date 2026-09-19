--==================================================
-- NPC + PLAYER HUB V2
-- LOAD / SEARCH / TAB / TELEPORT / ESP + NAME
--==================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

--==================================================
-- CLEAN
--==================================================

for _, name in ipairs({
	"SpiderLilyHub",
	"NPCPlayerHub",
	"NPCPlayerHub_V2"
}) do
	local old = PG:FindFirstChild(name)
	if old then
		old:Destroy()
	end
end

--==================================================
-- DATA
--==================================================

local NPCs = {}
local PlayerData = {}

local CurrentTab = "ALL"
local ESPEnabled = false
local ESPData = {}

--==================================================
-- GUI
--==================================================

local GUI = Instance.new("ScreenGui")
GUI.Name = "NPCPlayerHub_V2"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.Parent = PG

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(400, 570)
Main.Position = UDim2.new(0.5, -200, 0.5, -285)
Main.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
Main.BorderSizePixel = 0
Main.Parent = GUI

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 38)
Title.Position = UDim2.fromOffset(10, 5)
Title.BackgroundTransparency = 1
Title.Text = "NPC + PLAYER HUB V2"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

--==================================================
-- LOAD
--==================================================

local Load = Instance.new("TextButton")
Load.Size = UDim2.new(1, -20, 0, 42)
Load.Position = UDim2.fromOffset(10, 48)
Load.BackgroundColor3 = Color3.fromRGB(65, 120, 220)
Load.BorderSizePixel = 0
Load.Text = "LOAD NPC + PLAYER"
Load.TextColor3 = Color3.new(1,1,1)
Load.TextSize = 13
Load.Font = Enum.Font.GothamBold
Load.Parent = Main

local LoadCorner = Instance.new("UICorner")
LoadCorner.CornerRadius = UDim.new(0, 8)
LoadCorner.Parent = Load

--==================================================
-- ESP
--==================================================

local ESP = Instance.new("TextButton")
ESP.Size = UDim2.new(1, -20, 0, 36)
ESP.Position = UDim2.fromOffset(10, 96)
ESP.BackgroundColor3 = Color3.fromRGB(45,45,55)
ESP.BorderSizePixel = 0
ESP.Text = "ESP: OFF"
ESP.TextColor3 = Color3.new(1,1,1)
ESP.TextSize = 13
ESP.Font = Enum.Font.GothamBold
ESP.Parent = Main

local ESPCorner = Instance.new("UICorner")
ESPCorner.CornerRadius = UDim.new(0, 7)
ESPCorner.Parent = ESP

--==================================================
-- TABS
--==================================================

local Tabs = Instance.new("Frame")
Tabs.Size = UDim2.new(1, -20, 0, 36)
Tabs.Position = UDim2.fromOffset(10, 140)
Tabs.BackgroundTransparency = 1
Tabs.Parent = Main

local function MakeTab(text, x)

	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0.32, -4, 1, 0)
	b.Position = UDim2.new(x, 0, 0, 0)
	b.BackgroundColor3 = Color3.fromRGB(45,45,55)
	b.BorderSizePixel = 0
	b.Text = text
	b.TextColor3 = Color3.new(1,1,1)
	b.TextSize = 12
	b.Font = Enum.Font.GothamBold
	b.Parent = Tabs

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0,7)
	c.Parent = b

	return b
end

local AllTab = MakeTab("ALL", 0)
local NPCTab = MakeTab("NPC", 0.34)
local PlayerTab = MakeTab("PLAYER", 0.68)

--==================================================
-- SEARCH
--==================================================

local Search = Instance.new("TextBox")
Search.Size = UDim2.new(1, -20, 0, 35)
Search.Position = UDim2.fromOffset(10, 184)
Search.BackgroundColor3 = Color3.fromRGB(35,35,43)
Search.BorderSizePixel = 0
Search.PlaceholderText = "Search loaded NPC / Player..."
Search.PlaceholderColor3 = Color3.fromRGB(140,140,140)
Search.Text = ""
Search.TextColor3 = Color3.new(1,1,1)
Search.TextSize = 13
Search.Font = Enum.Font.Gotham
Search.ClearTextOnFocus = false
Search.Parent = Main

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0,7)
SearchCorner.Parent = Search

--==================================================
-- LIST
--==================================================

local List = Instance.new("ScrollingFrame")
List.Size = UDim2.new(1, -20, 1, -230)
List.Position = UDim2.fromOffset(10, 229)
List.BackgroundColor3 = Color3.fromRGB(29,29,36)
List.BorderSizePixel = 0
List.ScrollBarThickness = 5
List.CanvasSize = UDim2.new()
List.Parent = Main

local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0,8)
ListCorner.Parent = List

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0,5)
Layout.Parent = List

--==================================================
-- ROOT
--==================================================

local function GetRoot(obj)

	if not obj then
		return nil
	end

	if obj:IsA("BasePart") then
		return obj
	end

	if obj:IsA("Model") and obj.PrimaryPart then
		return obj.PrimaryPart
	end

	return obj:FindFirstChildWhichIsA("BasePart", true)
end

--==================================================
-- SCAN NPC
--==================================================

local function ScanNPC()

	table.clear(NPCs)

	for _, obj in ipairs(workspace:GetDescendants()) do

		if obj:IsA("Model") then

			local hum =
				obj:FindFirstChildOfClass("Humanoid")

			if hum and not Players:GetPlayerFromCharacter(obj) then
				table.insert(NPCs, obj)
			end
		end
	end
end

--==================================================
-- SCAN PLAYERS
--==================================================

local function ScanPlayers()

	table.clear(PlayerData)

	for _, plr in ipairs(Players:GetPlayers()) do

		if plr ~= LP then
			table.insert(PlayerData, plr)
		end
	end
end

--==================================================
-- TELEPORT
--==================================================

local function TeleportTo(obj)

	local target

	if typeof(obj) == "Instance" then
		target = GetRoot(obj)

	elseif typeof(obj) == "table" then

		if obj.Character then
			target = GetRoot(obj.Character)
		end
	end

	if not target then
		return
	end

	local char = LP.Character
	if not char then
		return
	end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	root.CFrame =
		target.CFrame * CFrame.new(0, 3, 0)
end

--==================================================
-- ESP REMOVE
--==================================================

local function RemoveESP(obj)

	local data = ESPData[obj]

	if not data then
		return
	end

	if data.Highlight then
		data.Highlight:Destroy()
	end

	if data.Billboard then
		data.Billboard:Destroy()
	end

	ESPData[obj] = nil
end

--==================================================
-- ESP ADD
--==================================================

local function AddESP(obj, name)

	if not obj or not obj.Parent then
		return
	end

	local root = GetRoot(obj)
	if not root then
		return
	end

	RemoveESP(obj)

	local highlight = Instance.new("Highlight")
	highlight.Name = "HubESP"
	highlight.Adornee = obj
	highlight.DepthMode =
		Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillTransparency = 0.75
	highlight.OutlineTransparency = 0
	highlight.Parent = obj

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "HubName"
	billboard.Adornee = root
	billboard.Size = UDim2.fromOffset(220, 35)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = root

	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1,1)
	text.BackgroundTransparency = 1
	text.Text = name
	text.TextColor3 = Color3.new(1,1,1)
	text.TextStrokeTransparency = 0
	text.TextSize = 14
	text.Font = Enum.Font.GothamBold
	text.Parent = billboard

	ESPData[obj] = {
		Highlight = highlight,
		Billboard = billboard
	}
end

--==================================================
-- UPDATE ESP
--==================================================

local function UpdateESP()

	for obj in pairs(ESPData) do
		RemoveESP(obj)
	end

	if not ESPEnabled then
		return
	end

	for _, npc in ipairs(NPCs) do

		if npc.Parent then
			AddESP(npc, "NPC: " .. npc.Name)
		end
	end

	for _, plr in ipairs(PlayerData) do

		local char = plr.Character

		if char and char.Parent then
			AddESP(
				char,
				"PLAYER: " .. plr.Name
			)
		end
	end
end

--==================================================
-- CLEAR LIST
--==================================================

local function ClearList()

	for _, child in ipairs(List:GetChildren()) do

		if child:IsA("Frame") then
			child:Destroy()
		end
	end
end

--==================================================
-- ITEM
--==================================================

local function CreateItem(name, typeName, obj)

	local item = Instance.new("Frame")
	item.Size = UDim2.new(1, -10, 0, 45)
	item.BackgroundColor3 = Color3.fromRGB(42,42,50)
	item.BorderSizePixel = 0
	item.Parent = List

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,6)
	corner.Parent = item

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -100, 1, 0)
	label.Position = UDim2.fromOffset(10,0)
	label.BackgroundTransparency = 1
	label.Text = "[" .. typeName .. "] " .. name
	label.TextColor3 = Color3.new(1,1,1)
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.Gotham
	label.Parent = item

	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(80,30)
	button.Position = UDim2.new(1,-88,0.5,-15)
	button.BackgroundColor3 = Color3.fromRGB(65,120,220)
	button.BorderSizePixel = 0
	button.Text = "TELEPORT"
	button.TextColor3 = Color3.new(1,1,1)
	button.TextSize = 10
	button.Font = Enum.Font.GothamBold
	button.Parent = item

	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0,5)
	bc.Parent = button

	button.Activated:Connect(function()
		TeleportTo(obj)
	end)
end

--==================================================
-- REFRESH
--==================================================

local function Refresh()

	ClearList()

	local query = string.lower(Search.Text)

	local function Match(name)

		return query == ""
			or string.find(
				string.lower(name),
				query,
				1,
				true
			)
	end

	if CurrentTab == "ALL"
		or CurrentTab == "NPC"
	then

		for _, npc in ipairs(NPCs) do

			if npc.Parent and Match(npc.Name) then

				CreateItem(
					npc.Name,
					"NPC",
					npc
				)
			end
		end
	end

	if CurrentTab == "ALL"
		or CurrentTab == "PLAYER"
	then

		for _, plr in ipairs(PlayerData) do

			if Match(plr.Name) then

				CreateItem(
					plr.Name,
					"PLAYER",
					plr
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

Load.Activated:Connect(function()

	Load.Text = "LOADING..."

	ScanNPC()
	ScanPlayers()

	Load.Text =
		"LOADED "
		.. #NPCs
		.. " NPC / "
		.. #PlayerData
		.. " PLAYER"

	Refresh()

	if ESPEnabled then
		UpdateESP()
	end
end)

--==================================================
-- ESP TOGGLE
--==================================================

ESP.Activated:Connect(function()

	ESPEnabled = not ESPEnabled

	ESP.Text =
		ESPEnabled
		and "ESP: ON"
		or "ESP: OFF"

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

local dragging = false
local dragStart
local startPos

Title.InputBegan:Connect(function(input)

	if input.UserInputType ==
		Enum.UserInputType.MouseButton1
		or input.UserInputType ==
		Enum.UserInputType.Touch
	then

		dragging = true
		dragStart = input.Position
		startPos = Main.Position

		input.Changed:Connect(function()

			if input.UserInputState ==
				Enum.UserInputState.End
			then
				dragging = false
			end
		end)
	end
end)

UIS.InputChanged:Connect(function(input)

	if not dragging then
		return
	end

	if input.UserInputType ==
		Enum.UserInputType.MouseMovement
		or input.UserInputType ==
		Enum.UserInputType.Touch
	then

		local delta =
			input.Position - dragStart

		Main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,

			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

print("[NPCPlayerHub_V2] FULL HUB LOADED")
