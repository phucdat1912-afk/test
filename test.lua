--==================================================
-- PROJECT SLAYERS 2
-- FULL NPC TELEPORT HUB
-- LOAD NPC = SCAN ENTIRE WORKSPACE
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- REMOVE OLD UI
--==================================================

for _, name in ipairs({
    "ProjectSlayers2Hub",
    "NPCTeleportUI",
    "TeleportUI"
}) do
    local old = PlayerGui:FindFirstChild(name)
    if old then
        old:Destroy()
    end
end

--==================================================
-- DATA
--==================================================

local LoadedTargets = {}
local Loaded = false
local CurrentTab = "ALL"

--==================================================
-- HELPERS
--==================================================

local function getCharacterRoot(character)
    if not character then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")
        or character.PrimaryPart
end

local function isPlayerCharacter(model, playerCharacters)
    return playerCharacters[model] == true
end

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProjectSlayers2Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(430, 590)
Main.Position = UDim2.new(0.5, -215, 0.5, -295)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(60, 60, 75)
Stroke.Thickness = 1
Stroke.Parent = Main

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 58)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 33)
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 14)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(18, 7)
Title.Size = UDim2.new(1, -120, 0, 25)
Title.Font = Enum.Font.GothamBold
Title.Text = "PROJECT SLAYERS 2"
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(245, 245, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Status = Instance.new("TextLabel")
Status.BackgroundTransparency = 1
Status.Position = UDim2.fromOffset(18, 32)
Status.Size = UDim2.new(1, -120, 0, 18)
Status.Font = Enum.Font.Gotham
Status.Text = "NPCs not loaded"
Status.TextSize = 11
Status.TextColor3 = Color3.fromRGB(150, 150, 165)
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Header

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.fromOffset(35, 35)
Minimize.Position = UDim2.new(1, -82, 0, 12)
Minimize.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
Minimize.Text = "—"
Minimize.TextColor3 = Color3.fromRGB(230, 230, 240)
Minimize.TextSize = 20
Minimize.Font = Enum.Font.GothamBold
Minimize.AutoButtonColor = false
Minimize.Parent = Header

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = Minimize

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(35, 35)
Close.Position = UDim2.new(1, -42, 0, 12)
Close.BackgroundColor3 = Color3.fromRGB(55, 35, 40)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255, 180, 185)
Close.TextSize = 21
Close.Font = Enum.Font.GothamBold
Close.AutoButtonColor = false
Close.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = Close

--==================================================
-- LOAD BUTTON
--==================================================

local LoadButton = Instance.new("TextButton")
LoadButton.Name = "LoadNPC"
LoadButton.Size = UDim2.new(1, -28, 0, 48)
LoadButton.Position = UDim2.fromOffset(14, 72)
LoadButton.BackgroundColor3 = Color3.fromRGB(55, 90, 150)
LoadButton.Text = "LOAD NPC"
LoadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadButton.TextSize = 14
LoadButton.Font = Enum.Font.GothamBold
LoadButton.AutoButtonColor = false
LoadButton.Parent = Main

local LoadCorner = Instance.new("UICorner")
LoadCorner.CornerRadius = UDim.new(0, 10)
LoadCorner.Parent = LoadButton

--==================================================
-- SEARCH
--==================================================

local Search = Instance.new("TextBox")
Search.Name = "Search"
Search.Size = UDim2.new(1, -28, 0, 42)
Search.Position = UDim2.fromOffset(14, 130)
Search.BackgroundColor3 = Color3.fromRGB(28, 28, 37)
Search.PlaceholderText = "Search NPC..."
Search.PlaceholderColor3 = Color3.fromRGB(110, 110, 125)
Search.Text = ""
Search.TextColor3 = Color3.fromRGB(240, 240, 245)
Search.TextSize = 13
Search.Font = Enum.Font.Gotham
Search.ClearTextOnFocus = false
Search.Parent = Main

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 9)
SearchCorner.Parent = Search

local SearchPadding = Instance.new("UIPadding")
SearchPadding.PaddingLeft = UDim.new(0, 13)
SearchPadding.PaddingRight = UDim.new(0, 13)
SearchPadding.Parent = Search

--==================================================
-- TABS
--==================================================

local TabFrame = Instance.new("Frame")
TabFrame.BackgroundTransparency = 1
TabFrame.Size = UDim2.new(1, -28, 0, 38)
TabFrame.Position = UDim2.fromOffset(14, 181)
TabFrame.Parent = Main

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
TabLayout.Padding = UDim.new(0, 6)
TabLayout.Parent = TabFrame

local Tabs = {}

local function createTab(name, text)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(0, 88, 1, 0)
    Button.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(175, 175, 190)
    Button.TextSize = 11
    Button.Font = Enum.Font.GothamBold
    Button.AutoButtonColor = false
    Button.Parent = TabFrame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button

    Tabs[name] = Button

    return Button
end

createTab("ALL", "ALL")
createTab("MUZAN", "MUZAN")
createTab("NPC", "NPC")

--==================================================
-- LIST
--==================================================

local List = Instance.new("ScrollingFrame")
List.Name = "NPCList"
List.Size = UDim2.new(1, -28, 1, -235)
List.Position = UDim2.fromOffset(14, 225)
List.BackgroundColor3 = Color3.fromRGB(23, 23, 31)
List.BorderSizePixel = 0
List.ScrollBarThickness = 5
List.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
List.CanvasSize = UDim2.new()
List.Parent = Main

local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0, 10)
ListCorner.Parent = List

local ListPadding = Instance.new("UIPadding")
ListPadding.PaddingTop = UDim.new(0, 8)
ListPadding.PaddingBottom = UDim.new(0, 8)
ListPadding.PaddingLeft = UDim.new(0, 8)
ListPadding.PaddingRight = UDim.new(0, 8)
ListPadding.Parent = List

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 6)
ListLayout.Parent = List

ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    List.CanvasSize = UDim2.new(
        0,
        0,
        0,
        ListLayout.AbsoluteContentSize.Y + 16
    )
end)

--==================================================
-- TELEPORT
--==================================================

local function teleportTo(target)
    if not target then
        return
    end

    local character = LocalPlayer.Character
    local characterRoot = getCharacterRoot(character)

    if not characterRoot then
        return
    end

    local model = target.Model

    if not model or not model.Parent then
        return
    end

    local targetRoot =
        model:FindFirstChild("HumanoidRootPart")
        or model.PrimaryPart

    if not targetRoot then
        return
    end

    characterRoot.CFrame =
        targetRoot.CFrame + Vector3.new(0, 3, 0)
end

--==================================================
-- RENDER
--==================================================

local function clearList()
    for _, child in ipairs(List:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end

local function matchesTarget(target)
    if CurrentTab == "MUZAN" then
        if target.Type ~= "NPC" then
            return false
        end

        if not string.find(
            string.lower(target.Name),
            "muzan",
            1,
            true
        ) then
            return false
        end
    elseif CurrentTab == "NPC" then
        if target.Type ~= "NPC" then
            return false
        end
    end

    local query = string.lower(Search.Text)

    if query ~= "" then
        return string.find(
            string.lower(target.Name),
            query,
            1,
            true
        ) ~= nil
    end

    return true
end

local function render()
    clearList()

    if not Loaded then
        return
    end

    local shown = 0

    for _, target in ipairs(LoadedTargets) do
        if matchesTarget(target) then
            shown += 1

            local Item = Instance.new("Frame")
            Item.Size = UDim2.new(1, 0, 0, 54)
            Item.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            Item.BorderSizePixel = 0
            Item.Parent = List

            local Corner = Instance.new("UICorner")
            Corner.CornerRadius = UDim.new(0, 8)
            Corner.Parent = Item

            local Name = Instance.new("TextLabel")
            Name.BackgroundTransparency = 1
            Name.Position = UDim2.fromOffset(12, 5)
            Name.Size = UDim2.new(1, -115, 0, 21)
            Name.Font = Enum.Font.GothamBold
            Name.Text = target.Name
            Name.TextSize = 12
            Name.TextColor3 = Color3.fromRGB(235, 235, 245)
            Name.TextXAlignment = Enum.TextXAlignment.Left
            Name.TextTruncate = Enum.TextTruncate.AtEnd
            Name.Parent = Item

            local Type = Instance.new("TextLabel")
            Type.BackgroundTransparency = 1
            Type.Position = UDim2.fromOffset(12, 28)
            Type.Size = UDim2.new(1, -115, 0, 17)
            Type.Font = Enum.Font.Gotham
            Type.Text = target.Type
            Type.TextSize = 10
            Type.TextColor3 = Color3.fromRGB(125, 125, 145)
            Type.TextXAlignment = Enum.TextXAlignment.Left
            Type.Parent = Item

            local Teleport = Instance.new("TextButton")
            Teleport.Size = UDim2.fromOffset(86, 34)
            Teleport.Position = UDim2.new(1, -94, 0.5, -17)
            Teleport.BackgroundColor3 = Color3.fromRGB(55, 90, 150)
            Teleport.Text = "TELEPORT"
            Teleport.TextColor3 = Color3.fromRGB(255, 255, 255)
            Teleport.TextSize = 10
            Teleport.Font = Enum.Font.GothamBold
            Teleport.AutoButtonColor = false
            Teleport.Parent = Item

            local TeleportCorner = Instance.new("UICorner")
            TeleportCorner.CornerRadius = UDim.new(0, 7)
            TeleportCorner.Parent = Teleport

            Teleport.Activated:Connect(function()
                teleportTo(target)
            end)
        end
    end

    if shown == 0 then
        local Empty = Instance.new("TextLabel")
        Empty.Size = UDim2.new(1, -16, 0, 50)
        Empty.BackgroundTransparency = 1
        Empty.Text = "No NPC found"
        Empty.TextColor3 = Color3.fromRGB(130, 130, 145)
        Empty.TextSize = 13
        Empty.Font = Enum.Font.Gotham
        Empty.Parent = List
    end
end

--==================================================
-- LOAD ALL NPC
--==================================================

local function loadAllNPCs()
    LoadedTargets = {}

    local playerCharacters = {}

    -- Character của tất cả player
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            playerCharacters[player.Character] = true
        end
    end

    -- QUÉT TOÀN BỘ WORKSPACE
    for _, obj in ipairs(workspace:GetDescendants()) do

        if obj:IsA("Model")
            and not isPlayerCharacter(obj, playerCharacters)
        then

            local humanoid = obj:FindFirstChildOfClass("Humanoid")

            if humanoid then
                local root =
                    obj:FindFirstChild("HumanoidRootPart")
                    or obj.PrimaryPart

                if root and root:IsA("BasePart") then

                    table.insert(LoadedTargets, {
                        Name = obj.Name,
                        Model = obj,
                        Root = root,
                        Type = "NPC",
                        Path = obj:GetFullName()
                    })
                end
            end
        end
    end

    Loaded = true

    Status.Text =
        "Loaded " .. tostring(#LoadedTargets) .. " NPCs"

    LoadButton.Text = "RELOAD NPC"

    render()

    print("================================")
    print("NPC LOAD COMPLETE")
    print("TOTAL NPC:", #LoadedTargets)
    print("================================")

    for _, npc in ipairs(LoadedTargets) do
        print(
            "[NPC]",
            npc.Name,
            "|",
            npc.Path
        )
    end
end

--==================================================
-- BUTTON EVENTS
--==================================================

LoadButton.Activated:Connect(function()
    LoadButton.Text = "LOADING..."

    task.wait()

    loadAllNPCs()
end)

Search:GetPropertyChangedSignal("Text"):Connect(function()
    if Loaded then
        render()
    end
end)

for name, button in pairs(Tabs) do
    button.Activated:Connect(function()
        CurrentTab = name

        for tabName, tabButton in pairs(Tabs) do
            if tabName == CurrentTab then
                tabButton.BackgroundColor3 =
                    Color3.fromRGB(55, 90, 150)

                tabButton.TextColor3 =
                    Color3.fromRGB(255, 255, 255)
            else
                tabButton.BackgroundColor3 =
                    Color3.fromRGB(32, 32, 42)

                tabButton.TextColor3 =
                    Color3.fromRGB(175, 175, 190)
            end
        end

        render()
    end)
end

--==================================================
-- INITIAL TAB
--==================================================

Tabs.ALL.BackgroundColor3 = Color3.fromRGB(55, 90, 150)
Tabs.ALL.TextColor3 = Color3.fromRGB(255, 255, 255)

--==================================================
-- MINIMIZE
--==================================================

local minimized = false

Minimize.Activated:Connect(function()
    minimized = not minimized

    Search.Visible = not minimized
    TabFrame.Visible = not minimized
    List.Visible = not minimized
    LoadButton.Visible = not minimized

    if minimized then
        Main.Size = UDim2.fromOffset(430, 58)
        Minimize.Text = "+"
    else
        Main.Size = UDim2.fromOffset(430, 590)
        Minimize.Text = "—"
    end
end)

--==================================================
-- CLOSE
--==================================================

Close.Activated:Connect(function()
    ScreenGui:Destroy()
end)

--==================================================
-- DRAG
--==================================================

local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
    then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position

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
        or input.UserInputType == Enum.UserInputType.Touch
    then
        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

--==================================================
-- DONE
--==================================================

print("Project Slayers 2 Hub loaded.")
print("Press LOAD NPC to scan the entire Workspace.")
