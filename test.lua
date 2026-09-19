--==================================================
-- NPC TELEPORT UI
-- Clean / Modern / Searchable
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "NPCTeleportUI"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(360, 480)
Main.Position = UDim2.new(0.5, -180, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(65, 65, 80)
Stroke.Thickness = 1
Stroke.Transparency = 0.25
Stroke.Parent = Main

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 65)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 33)
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 14)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Position = UDim2.fromOffset(18, 10)
Title.Size = UDim2.new(1, -36, 0, 28)
Title.BackgroundTransparency = 1
Title.Text = "NPC TELEPORT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 21
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Count = Instance.new("TextLabel")
Count.Position = UDim2.fromOffset(19, 38)
Count.Size = UDim2.new(1, -38, 0, 18)
Count.BackgroundTransparency = 1
Count.Text = "0 NPCs found"
Count.TextColor3 = Color3.fromRGB(145, 145, 160)
Count.TextSize = 12
Count.Font = Enum.Font.Gotham
Count.TextXAlignment = Enum.TextXAlignment.Left
Count.Parent = Header

--==================================================
-- SEARCH
--==================================================

local SearchBox = Instance.new("TextBox")
SearchBox.Position = UDim2.fromOffset(15, 78)
SearchBox.Size = UDim2.new(1, -30, 0, 42)
SearchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
SearchBox.BorderSizePixel = 0
SearchBox.PlaceholderText = "  Search NPC..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 135)
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(235, 235, 240)
SearchBox.TextSize = 14
SearchBox.Font = Enum.Font.Gotham
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = Main

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 10)
SearchCorner.Parent = SearchBox

local SearchStroke = Instance.new("UIStroke")
SearchStroke.Color = Color3.fromRGB(55, 55, 70)
SearchStroke.Thickness = 1
SearchStroke.Parent = SearchBox

--==================================================
-- NPC LIST
--==================================================

local List = Instance.new("ScrollingFrame")
List.Position = UDim2.fromOffset(15, 132)
List.Size = UDim2.new(1, -30, 1, -147)
List.BackgroundTransparency = 1
List.BorderSizePixel = 0
List.ScrollBarThickness = 4
List.ScrollBarImageColor3 = Color3.fromRGB(90, 90, 110)
List.CanvasSize = UDim2.new()
List.AutomaticCanvasSize = Enum.AutomaticSize.Y
List.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 7)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = List

local Padding = Instance.new("UIPadding")
Padding.PaddingBottom = UDim.new(0, 5)
Padding.Parent = List

--==================================================
-- ROOT PART
--==================================================

local function getRoot(model)
    return model:FindFirstChild("HumanoidRootPart")
        or model.PrimaryPart
end

--==================================================
-- NPC CHECK
--==================================================

local function isNPC(model)
    if not model:IsA("Model") then
        return false
    end

    if model == Player.Character then
        return false
    end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local root = getRoot(model)

    return humanoid ~= nil and root ~= nil
end

--==================================================
-- TELEPORT
--==================================================

local function teleportTo(npc)
    local character = Player.Character
    if not character then
        return
    end

    local playerRoot = getRoot(character)
    local npcRoot = getRoot(npc)

    if not playerRoot or not npcRoot then
        return
    end

    playerRoot.CFrame = npcRoot.CFrame + Vector3.new(0, 3, 0)
end

--==================================================
-- BUTTON
--==================================================

local function createNPCButton(npc)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -8, 0, 48)
    Button.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = List

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 9)
    Corner.Parent = Button

    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = Color3.fromRGB(48, 48, 62)
    ButtonStroke.Thickness = 1
    ButtonStroke.Parent = Button

    local Name = Instance.new("TextLabel")
    Name.Position = UDim2.fromOffset(14, 0)
    Name.Size = UDim2.new(1, -105, 1, 0)
    Name.BackgroundTransparency = 1
    Name.Text = npc.Name
    Name.TextColor3 = Color3.fromRGB(235, 235, 240)
    Name.TextSize = 14
    Name.Font = Enum.Font.GothamMedium
    Name.TextXAlignment = Enum.TextXAlignment.Left
    Name.TextTruncate = Enum.TextTruncate.AtEnd
    Name.Parent = Button

    local Teleport = Instance.new("TextLabel")
    Teleport.AnchorPoint = Vector2.new(1, 0.5)
    Teleport.Position = UDim2.new(1, -10, 0.5, 0)
    Teleport.Size = UDim2.fromOffset(75, 28)
    Teleport.BackgroundColor3 = Color3.fromRGB(55, 105, 220)
    Teleport.Text = "TELEPORT"
    Teleport.TextColor3 = Color3.fromRGB(255, 255, 255)
    Teleport.TextSize = 10
    Teleport.Font = Enum.Font.GothamBold
    Teleport.Parent = Button

    local TeleportCorner = Instance.new("UICorner")
    TeleportCorner.CornerRadius = UDim.new(0, 7)
    TeleportCorner.Parent = Teleport

    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(36, 36, 48)
        Teleport.BackgroundColor3 = Color3.fromRGB(70, 120, 235)
    end)

    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
        Teleport.BackgroundColor3 = Color3.fromRGB(55, 105, 220)
    end)

    Button.MouseButton1Click:Connect(function()
        teleportTo(npc)
    end)

    return Button
end

--==================================================
-- REFRESH
--==================================================

local function refresh()
    for _, child in ipairs(List:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local npcs = {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        if isNPC(obj) then
            table.insert(npcs, obj)
        end
    end

    table.sort(npcs, function(a, b)
        return a.Name:lower() < b.Name:lower()
    end)

    local search = SearchBox.Text:lower()
    local shown = 0

    for _, npc in ipairs(npcs) do
        if search == "" or npc.Name:lower():find(search, 1, true) then
            createNPCButton(npc)
            shown += 1
        end
    end

    Count.Text = string.format("%d NPCs found", shown)
end

--==================================================
-- SEARCH
--==================================================

SearchBox:GetPropertyChangedSignal("Text"):Connect(refresh)

--==================================================
-- AUTO REFRESH
--==================================================

workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") then
        task.delay(0.15, refresh)
    end
end)

workspace.DescendantRemoving:Connect(function(obj)
    if obj:IsA("Model") then
        task.defer(refresh)
    end
end)

--==================================================
-- DRAG WINDOW
--==================================================

local dragging = false
local dragStart
local startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

--==================================================
-- START
--==================================================

refresh()
