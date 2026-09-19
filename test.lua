```lua
--==================================================
-- FULL MAP NPC + PLAYER SCANNER
--==================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

--==================================================
-- DATA
--==================================================

local Targets = {}
local Loaded = false
local CurrentTab = "ALL"
local SearchText = ""

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "FullMapScanner"
Gui.ResetOnSpawn = false
Gui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(520, 600)
Main.Position = UDim2.new(0.5, -260, 0.5, -300)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 0, 40)
Title.Position = UDim2.fromOffset(15, 5)
Title.BackgroundTransparency = 1
Title.Text = "FULL MAP NPC + PLAYER"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(35, 35)
Close.Position = UDim2.new(1, -40, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
Close.Text = "X"
Close.TextColor3 = Color3.new(1,1,1)
Close.TextSize = 16
Close.Font = Enum.Font.GothamBold
Close.Parent = Main

Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)

Close.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)

--==================================================
-- LOAD BUTTON
--==================================================

local LoadButton = Instance.new("TextButton")
LoadButton.Size = UDim2.new(1, -30, 0, 42)
LoadButton.Position = UDim2.fromOffset(15, 50)
LoadButton.BackgroundColor3 = Color3.fromRGB(45, 120, 220)
LoadButton.Text = "LOAD NPC + PLAYER - FULL MAP"
LoadButton.TextColor3 = Color3.new(1,1,1)
LoadButton.TextSize = 15
LoadButton.Font = Enum.Font.GothamBold
LoadButton.Parent = Main

Instance.new("UICorner", LoadButton).CornerRadius = UDim.new(0, 7)

--==================================================
-- SEARCH
--==================================================

local Search = Instance.new("TextBox")
Search.Size = UDim2.new(1, -30, 0, 38)
Search.Position = UDim2.fromOffset(15, 100)
Search.BackgroundColor3 = Color3.fromRGB(35,35,42)
Search.PlaceholderText = "Search loaded target..."
Search.Text = ""
Search.TextColor3 = Color3.new(1,1,1)
Search.PlaceholderColor3 = Color3.fromRGB(150,150,150)
Search.TextSize = 14
Search.Font = Enum.Font.Gotham
Search.ClearTextOnFocus = false
Search.Parent = Main

Instance.new("UICorner", Search).CornerRadius = UDim.new(0, 7)

--==================================================
-- LIST
--==================================================

local List = Instance.new("ScrollingFrame")
List.Size = UDim2.new(1, -30, 1, -235)
List.Position = UDim2.fromOffset(15, 190)
List.BackgroundColor3 = Color3.fromRGB(27,27,33)
List.BorderSizePixel = 0
List.ScrollBarThickness = 5
List.CanvasSize = UDim2.new()
List.Parent = Main

Instance.new("UICorner", List).CornerRadius = UDim.new(0, 7)

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 5)
Layout.Parent = List

--==================================================
-- ROOT
--==================================================

local function GetRoot(model)
    if not model then
        return nil
    end

    local root = model:FindFirstChild("HumanoidRootPart")

    if root and root:IsA("BasePart") then
        return root
    end

    if model.PrimaryPart and model.PrimaryPart:IsA("BasePart") then
        return model.PrimaryPart
    end

    return model:FindFirstChildWhichIsA("BasePart", true)
end

--==================================================
-- PLAYER CHARACTER CHECK
--==================================================

local function IsPlayerCharacter(model)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character == model then
            return true
        end
    end

    return false
end

--==================================================
-- ADD PLAYER
--==================================================

local function AddPlayer(player)

    if not player.Character then
        return
    end

    local root = GetRoot(player.Character)

    if not root then
        return
    end

    -- tránh duplicate
    for _, target in ipairs(Targets) do
        if target.Player == player then
            return
        end
    end

    table.insert(Targets, {
        Name = player.Name,
        DisplayName = player.DisplayName,
        Type = "PLAYER",
        Model = player.Character,
        Root = root,
        Player = player
    })
end

--==================================================
-- SCAN ALL PLAYERS
--==================================================

local function ScanPlayers()

    local count = 0

    -- LẤY TOÀN BỘ PLAYER TRONG SERVER
    for _, player in ipairs(Players:GetPlayers()) do

        local before = #Targets

        AddPlayer(player)

        if #Targets > before then
            count += 1
        end
    end

    return count
end

--==================================================
-- NPC DETECTION
--==================================================

local function IsNPC(model)

    if not model:IsA("Model") then
        return false
    end

    if IsPlayerCharacter(model) then
        return false
    end

    local root = GetRoot(model)

    if not root then
        return false
    end

    -- NPC bình thường
    if model:FindFirstChildOfClass("Humanoid") then
        return true
    end

    -- NPC dùng AnimationController
    if model:FindFirstChildOfClass("AnimationController") then
        return true
    end

    -- NPC có prompt
    if root:FindFirstChildOfClass("ProximityPrompt") then
        return true
    end

    return false
end

--==================================================
-- ADD NPC
--==================================================

local function AddNPC(model)

    local root = GetRoot(model)

    if not root then
        return
    end

    -- tránh duplicate
    for _, target in ipairs(Targets) do
        if target.Model == model then
            return
        end
    end

    local name = model.Name
    local typeName = "NPC"

    -- Muzan chỉ khi model thật sự tồn tại
    if model.Name == "MuzanLairModel"
        or model:FindFirstChild("MuzanIsHere123", true)
    then
        name = "Muzan"
        typeName = "MUZAN"
    end

    table.insert(Targets, {
        Name = name,
        DisplayName = name,
        Type = typeName,
        Model = model,
        Root = root
    })
end

--==================================================
-- SCAN ENTIRE WORKSPACE
--==================================================

local function ScanWorkspace()

    local count = 0

    -- KHÔNG DÙNG DISTANCE
    -- QUÉT TOÀN BỘ WORKSPACE MÀ CLIENT ĐÃ NHẬN

    for _, object in ipairs(workspace:GetDescendants()) do

        if object:IsA("Model") and IsNPC(object) then

            local before = #Targets

            AddNPC(object)

            if #Targets > before then
                count += 1
            end
        end
    end

    return count
end

--==================================================
-- REFRESH
--==================================================

local function Refresh()

    for _, child in ipairs(List:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local search = string.lower(SearchText)
    local amount = 0

    for _, target in ipairs(Targets) do

        local modelValid =
            target.Model
            and target.Model.Parent
            and target.Root
            and target.Root.Parent

        if modelValid then

            local tabOK =
                CurrentTab == "ALL"
                or CurrentTab == target.Type
                or (
                    CurrentTab == "NPC"
                    and target.Type == "MUZAN"
                )

            local name = string.lower(target.Name or "")
            local display = string.lower(target.DisplayName or "")

            local searchOK =
                search == ""
                or string.find(name, search, 1, true)
                or string.find(display, search, 1, true)

            if tabOK and searchOK then

                local button = Instance.new("TextButton")

                button.Size = UDim2.new(1, -10, 0, 42)

                if target.Type == "PLAYER" then
                    button.BackgroundColor3 =
                        Color3.fromRGB(45,90,145)

                elseif target.Type == "MUZAN" then
                    button.BackgroundColor3 =
                        Color3.fromRGB(145,70,70)

                else
                    button.BackgroundColor3 =
                        Color3.fromRGB(55,55,65)
                end

                button.Text =
                    target.Type .. " | " .. target.Name

                button.TextColor3 = Color3.new(1,1,1)
                button.TextSize = 13
                button.Font = Enum.Font.GothamBold
                button.Parent = List

                Instance.new("UICorner", button).CornerRadius =
                    UDim.new(0,6)

                button.MouseButton1Click:Connect(function()

                    local character = LocalPlayer.Character
                    if not character then
                        return
                    end

                    local myRoot =
                        character:FindFirstChild("HumanoidRootPart")

                    if not myRoot then
                        return
                    end

                    if target.Root
                        and target.Root.Parent
                    then
                        myRoot.CFrame =
                            target.Root.CFrame *
                            CFrame.new(0,3,0)
                    end
                end)

                amount += 1
            end
        end
    end

    List.CanvasSize =
        UDim2.new(0,0,0,amount * 47)
end

--==================================================
-- TABS
--==================================================

local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1,-30,0,38)
TabFrame.Position = UDim2.fromOffset(15,145)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = Main

local function MakeTab(name, x)

    local button = Instance.new("TextButton")

    button.Size = UDim2.fromOffset(115,38)
    button.Position = UDim2.fromOffset(x,0)
    button.BackgroundColor3 = Color3.fromRGB(40,40,48)
    button.Text = name
    button.TextColor3 = Color3.new(1,1,1)
    button.TextSize = 13
    button.Font = Enum.Font.GothamBold
    button.Parent = TabFrame

    Instance.new("UICorner", button).CornerRadius =
        UDim.new(0,6)

    button.MouseButton1Click:Connect(function()
        CurrentTab = name
        Refresh()
    end)
end

MakeTab("ALL",0)
MakeTab("NPC",120)
MakeTab("PLAYER",240)
MakeTab("MUZAN",360)

--==================================================
-- LOAD
--==================================================

local function LoadFullMap()

    if Loaded then
        return
    end

    Loaded = true
    Targets = {}

    LoadButton.Text = "SCANNING..."

    local players = ScanPlayers()
    local npcs = ScanWorkspace()

    LoadButton.Text =
        "LOADED | PLAYER: "
        .. players
        .. " | NPC: "
        .. npcs

    Refresh()
end

LoadButton.MouseButton1Click:Connect(LoadFullMap)

--==================================================
-- SEARCH
--==================================================

Search:GetPropertyChangedSignal("Text"):Connect(function()

    SearchText = Search.Text

    -- chỉ filter danh sách
    -- KHÔNG scan lại
    Refresh()
end)

--==================================================
-- MUZAN SPAWN WATCH
--==================================================

local function WatchDebree(debree)

    debree.ChildAdded:Connect(function(object)

        if object:IsA("Model")
            and object.Name == "MuzanLairModel"
        then

            task.wait(0.2)

            if Loaded then
                AddNPC(object)
                Refresh()
            end
        end
    end)
end

local debree = workspace:FindFirstChild("Debree")

if debree then
    WatchDebree(debree)
end

workspace.ChildAdded:Connect(function(object)

    if object.Name == "Debree" then
        WatchDebree(object)
    end
end)

--==================================================
-- PLAYER REMOVED
--==================================================

Players.PlayerRemoving:Connect(function(player)

    for i = #Targets, 1, -1 do

        if Targets[i].Player == player then
            table.remove(Targets,i)
        end
    end

    if Loaded then
        Refresh()
    end
end)

--==================================================
-- DRAG
--==================================================

local dragging = false
local dragStart
local startPosition

Title.InputBegan:Connect(function(input)

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

UIS.InputChanged:Connect(function(input)

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
-- READY
--==================================================

Refresh()
```
