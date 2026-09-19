--==================================================
-- NPC + PLAYER TELEPORT
-- MANUAL LOAD VERSION
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "TeleportUI"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(380, 520)
Main.Position = UDim2.new(0.5, -190, 0.5, -260)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Main.BorderSizePixel = 0
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(65, 65, 80)
Stroke.Transparency = 0.2
Stroke.Parent = Main

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 65)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 33)
Header.BorderSizePixel = 0
Header.Parent = Main

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel")
Title.Position = UDim2.fromOffset(18, 8)
Title.Size = UDim2.new(1, -36, 0, 28)
Title.BackgroundTransparency = 1
Title.Text = "TELEPORT"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextSize = 21
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Count = Instance.new("TextLabel")
Count.Position = UDim2.fromOffset(19, 36)
Count.Size = UDim2.new(1, -140, 0, 18)
Count.BackgroundTransparency = 1
Count.Text = "Not loaded"
Count.TextColor3 = Color3.fromRGB(145,145,160)
Count.TextSize = 12
Count.Font = Enum.Font.Gotham
Count.TextXAlignment = Enum.TextXAlignment.Left
Count.Parent = Header

--==================================================
-- LOAD BUTTON
--==================================================

local LoadButton = Instance.new("TextButton")
LoadButton.AnchorPoint = Vector2.new(1, 0.5)
LoadButton.Position = UDim2.new(1, -15, 0.5, 0)
LoadButton.Size = UDim2.fromOffset(85, 34)
LoadButton.BackgroundColor3 = Color3.fromRGB(55,105,220)
LoadButton.BorderSizePixel = 0
LoadButton.Text = "LOAD"
LoadButton.TextColor3 = Color3.new(1,1,1)
LoadButton.TextSize = 12
LoadButton.Font = Enum.Font.GothamBold
LoadButton.Parent = Header

Instance.new("UICorner", LoadButton).CornerRadius = UDim.new(0, 8)

--==================================================
-- SEARCH
--==================================================

local SearchBox = Instance.new("TextBox")
SearchBox.Position = UDim2.fromOffset(15, 78)
SearchBox.Size = UDim2.new(1, -30, 0, 42)
SearchBox.BackgroundColor3 = Color3.fromRGB(30,30,40)
SearchBox.BorderSizePixel = 0
SearchBox.PlaceholderText = "Search NPC / Player..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(120,120,135)
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(235,235,240)
SearchBox.TextSize = 14
SearchBox.Font = Enum.Font.Gotham
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = Main

Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 10)

--==================================================
-- LIST
--==================================================

local List = Instance.new("ScrollingFrame")
List.Position = UDim2.fromOffset(15, 132)
List.Size = UDim2.new(1, -30, 1, -147)
List.BackgroundTransparency = 1
List.BorderSizePixel = 0
List.ScrollBarThickness = 4
List.ScrollBarImageColor3 = Color3.fromRGB(90,90,110)
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
-- ROOT
--==================================================

local function getRoot(model)
    return model:FindFirstChild("HumanoidRootPart")
        or model.PrimaryPart
end

--==================================================
-- DATA
--==================================================

local LoadedTargets = {}
local Loaded = false

--==================================================
-- TELEPORT
--==================================================

local function teleportTo(target)
    local character = Player.Character
    if not character then
        return
    end

    local playerRoot = getRoot(character)
    local targetRoot = getRoot(target)

    if playerRoot and targetRoot then
        playerRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
    end
end

--==================================================
-- BUTTON
--==================================================

local function createButton(target, targetType)
    local Button = Instance.new("TextButton")

    Button.Size = UDim2.new(1, -8, 0, 50)
    Button.BackgroundColor3 = Color3.fromRGB(28,28,38)
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = List

    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 9)

    local Name = Instance.new("TextLabel")
    Name.Position = UDim2.fromOffset(14, 5)
    Name.Size = UDim2.new(1, -110, 0, 23)
    Name.BackgroundTransparency = 1
    Name.Text = target.Name
    Name.TextColor3 = Color3.fromRGB(235,235,240)
    Name.TextSize = 14
    Name.Font = Enum.Font.GothamMedium
    Name.TextXAlignment = Enum.TextXAlignment.Left
    Name.TextTruncate = Enum.TextTruncate.AtEnd
    Name.Parent = Button

    local Type = Instance.new("TextLabel")
    Type.Position = UDim2.fromOffset(14, 27)
    Type.Size = UDim2.new(1, -110, 0, 16)
    Type.BackgroundTransparency = 1
    Type.Text = targetType
    Type.TextColor3 = Color3.fromRGB(130,130,145)
    Type.TextSize = 10
    Type.Font = Enum.Font.Gotham
    Type.TextXAlignment = Enum.TextXAlignment.Left
    Type.Parent = Button

    local TP = Instance.new("TextLabel")
    TP.AnchorPoint = Vector2.new(1, 0.5)
    TP.Position = UDim2.new(1, -10, 0.5, 0)
    TP.Size = UDim2.fromOffset(75, 28)
    TP.BackgroundColor3 = Color3.fromRGB(55,105,220)
    TP.Text = "TELEPORT"
    TP.TextColor3 = Color3.new(1,1,1)
    TP.TextSize = 10
    TP.Font = Enum.Font.GothamBold
    TP.Parent = Button

    Instance.new("UICorner", TP).CornerRadius = UDim.new(0, 7)

    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(37,37,49)
        TP.BackgroundColor3 = Color3.fromRGB(70,120,235)
    end)

    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(28,28,38)
        TP.BackgroundColor3 = Color3.fromRGB(55,105,220)
    end)

    Button.MouseButton1Click:Connect(function()
        teleportTo(target)
    end)
end

--==================================================
-- FILTER LOADED DATA
--==================================================

local function render()
    if not Loaded then
        return
    end

    for _, child in ipairs(List:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local search = SearchBox.Text:lower()
    local shown = 0

    for _, data in ipairs(LoadedTargets) do
        if data.Target
            and data.Target.Parent
            and getRoot(data.Target)
            and (
                search == ""
                or data.Target.Name:lower():find(search, 1, true)
            ) then

            createButton(data.Target, data.Type)
            shown += 1
        end
    end

    Count.Text = string.format("%d loaded • %d shown", #LoadedTargets, shown)
end

--==================================================
-- MANUAL LOAD
--==================================================

local function loadTargets()
    LoadedTargets = {}

    -- Players
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character
            and plr.Character ~= Player.Character
            and getRoot(plr.Character) then

            table.insert(LoadedTargets, {
                Target = plr.Character,
                Type = "PLAYER"
            })
        end
    end

    -- NPCs
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model")
            and obj ~= Player.Character
            and obj:FindFirstChildOfClass("Humanoid")
            and getRoot(obj) then

            -- Không thêm Character của Player lần nữa
            local isPlayerCharacter = false

            for _, plr in ipairs(Players:GetPlayers()) do
                if obj == plr.Character then
                    isPlayerCharacter = true
                    break
                end
            end

            if not isPlayerCharacter then
                table.insert(LoadedTargets, {
                    Target = obj,
                    Type = "NPC"
                })
            end
        end
    end

    Loaded = true
    render()
end

--==================================================
-- LOAD CLICK
--==================================================

LoadButton.MouseButton1Click:Connect(function()
    LoadButton.Text = "LOADING..."

    task.wait()

    loadTargets()

    LoadButton.Text = "RELOAD"
end)

--==================================================
-- SEARCH
--==================================================

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    if Loaded then
        render()
    end
end)

--==================================================
-- DRAG
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
