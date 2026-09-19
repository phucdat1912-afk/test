```lua
--==================================================
-- FULL MAP NPC + PLAYER + MUZAN
--==================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

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
Gui.Name = "FullMapHub"
Gui.ResetOnSpawn = false
Gui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(540, 620)
Main.Position = UDim2.new(0.5, -270, 0.5, -310)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -55, 0, 40)
Title.Position = UDim2.fromOffset(15, 5)
Title.BackgroundTransparency = 1
Title.Text = "FULL MAP NPC + PLAYER"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(35, 35)
Close.Position = UDim2.new(1, -40, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
Close.Text = "X"
Close.TextColor3 = Color3.new(1, 1, 1)
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
LoadButton.TextColor3 = Color3.new(1, 1, 1)
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
Search.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
Search.PlaceholderText = "Search loaded target..."
Search.Text = ""
Search.TextColor3 = Color3.new(1, 1, 1)
Search.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
Search.TextSize = 14
Search.Font = Enum.Font.Gotham
Search.ClearTextOnFocus = false
Search.Parent = Main

Instance.new("UICorner", Search).CornerRadius = UDim.new(0, 7)

--==================================================
-- TABS
--==================================================

local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -30, 0, 38)
TabFrame.Position = UDim2.fromOffset(15, 145)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = Main

local function CreateTab(Name, X)

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.fromOffset(120, 38)
    Button.Position = UDim2.fromOffset(X, 0)
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    Button.Text = Name
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamBold
    Button.Parent = TabFrame

    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

    Button.MouseButton1Click:Connect(function()
        CurrentTab = Name
        Refresh()
    end)
end

CreateTab("ALL", 0)
CreateTab("NPC", 125)
CreateTab("PLAYER", 250)
CreateTab("MUZAN", 375)

--==================================================
-- LIST
--==================================================

local List = Instance.new("ScrollingFrame")
List.Size = UDim2.new(1, -30, 1, -235)
List.Position = UDim2.fromOffset(15, 190)
List.BackgroundColor3 = Color3.fromRGB(27, 27, 33)
List.BorderSizePixel = 0
List.ScrollBarThickness = 5
List.CanvasSize = UDim2.new(0, 0, 0, 0)
List.Parent = Main

Instance.new("UICorner", List).CornerRadius = UDim.new(0, 7)

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 5)
Layout.Parent = List

--==================================================
-- ROOT
--==================================================

local function GetRoot(Model)

    if not Model then
        return nil
    end

    local Root = Model:FindFirstChild("HumanoidRootPart")

    if Root and Root:IsA("BasePart") then
        return Root
    end

    if Model.PrimaryPart
        and Model.PrimaryPart:IsA("BasePart")
    then
        return Model.PrimaryPart
    end

    return Model:FindFirstChildWhichIsA(
        "BasePart",
        true
    )
end

--==================================================
-- PLAYER CHECK
--==================================================

local function IsPlayerCharacter(Model)

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player.Character == Model then
            return true
        end
    end

    return false
end

--==================================================
-- ADD PLAYER
--==================================================

local function AddPlayer(Player)

    local Character = Player.Character

    if not Character then
        return false
    end

    local Root = GetRoot(Character)

    if not Root then
        return false
    end

    for _, Target in ipairs(Targets) do
        if Target.Player == Player then
            return false
        end
    end

    table.insert(Targets, {
        Name = Player.Name,
        DisplayName = Player.DisplayName,
        Type = "PLAYER",
        Model = Character,
        Root = Root,
        Player = Player
    })

    return true
end

--==================================================
-- SCAN ALL PLAYERS
--==================================================

local function ScanPlayers()

    local Count = 0

    for _, Player in ipairs(Players:GetPlayers()) do

        if AddPlayer(Player) then
            Count += 1
        end
    end

    return Count
end

--==================================================
-- NPC CHECK
--==================================================

local function IsNPC(Model)

    if not Model:IsA("Model") then
        return false
    end

    if IsPlayerCharacter(Model) then
        return false
    end

    local Root = GetRoot(Model)

    if not Root then
        return false
    end

    -- Humanoid NPC
    if Model:FindFirstChildOfClass("Humanoid") then
        return true
    end

    -- AnimationController NPC
    if Model:FindFirstChildOfClass("AnimationController") then
        return true
    end

    -- NPC có ProximityPrompt
    if Root:FindFirstChildOfClass("ProximityPrompt") then
        return true
    end

    -- Muzan marker
    if Model:FindFirstChild("MuzanIsHere123", true) then
        return true
    end

    return false
end

--==================================================
-- ADD NPC
--==================================================

local function AddNPC(Model)

    local Root = GetRoot(Model)

    if not Root then
        return false
    end

    for _, Target in ipairs(Targets) do

        if Target.Model == Model then
            return false
        end
    end

    local Name = Model.Name
    local Type = "NPC"

    if Model.Name == "MuzanLairModel"
        or Model:FindFirstChild("MuzanIsHere123", true)
    then
        Name = "Muzan"
        Type = "MUZAN"
    end

    table.insert(Targets, {
        Name = Name,
        DisplayName = Name,
        Type = Type,
        Model = Model,
        Root = Root
    })

    return true
end

--==================================================
-- SCAN ENTIRE WORKSPACE
--==================================================

local function ScanWorkspace()

    local Count = 0

    -- QUÉT TOÀN BỘ WORKSPACE
    -- KHÔNG CÓ DISTANCE / RADIUS

    for _, Object in ipairs(
        Workspace:GetDescendants()
    ) do

        if Object:IsA("Model")
            and IsNPC(Object)
        then

            if AddNPC(Object) then
                Count += 1
            end
        end
    end

    return Count
end

--==================================================
-- REFRESH UI
--==================================================

local function Refresh()

    for _, Child in ipairs(List:GetChildren()) do

        if Child:IsA("TextButton") then
            Child:Destroy()
        end
    end

    local SearchLower =
        string.lower(SearchText)

    local Amount = 0

    for _, Target in ipairs(Targets) do

        if Target.Model
            and Target.Model.Parent
            and Target.Root
            and Target.Root.Parent
        then

            local TabOK =
                CurrentTab == "ALL"
                or CurrentTab == Target.Type
                or (
                    CurrentTab == "NPC"
                    and Target.Type == "MUZAN"
                )

            local NameLower =
                string.lower(Target.Name or "")

            local DisplayLower =
                string.lower(Target.DisplayName or "")

            local SearchOK =
                SearchLower == ""
                or string.find(
                    NameLower,
                    SearchLower,
                    1,
                    true
                )
                or string.find(
                    DisplayLower,
                    SearchLower,
                    1,
                    true
                )

            if TabOK and SearchOK then

                local Button =
                    Instance.new("TextButton")

                Button.Size =
                    UDim2.new(1, -10, 0, 42)

                if Target.Type == "PLAYER" then

                    Button.BackgroundColor3 =
                        Color3.fromRGB(45, 90, 145)

                elseif Target.Type == "MUZAN" then

                    Button.BackgroundColor3 =
                        Color3.fromRGB(145, 70, 70)

                else

                    Button.BackgroundColor3 =
                        Color3.fromRGB(55, 55, 65)
                end

                Button.Text =
                    Target.Type
                    .. " | "
                    .. Target.Name

                Button.TextColor3 =
                    Color3.new(1, 1, 1)

                Button.TextSize = 13
                Button.Font = Enum.Font.GothamBold
                Button.Parent = List

                Instance.new("UICorner", Button)
                    .CornerRadius =
                    UDim.new(0, 6)

                Button.MouseButton1Click:Connect(
                    function()

                        local Character =
                            LocalPlayer.Character

                        if not Character then
                            return
                        end

                        local MyRoot =
                            Character:FindFirstChild(
                                "HumanoidRootPart"
                            )

                        if not MyRoot then
                            return
                        end

                        if Target.Root
                            and Target.Root.Parent
                        then

                            MyRoot.CFrame =
                                Target.Root.CFrame
                                * CFrame.new(0, 3, 0)
                        end
                    end
                )

                Amount += 1
            end
        end
    end

    List.CanvasSize =
        UDim2.new(
            0,
            0,
            0,
            Amount * 47
        )
end

--==================================================
-- LOAD
--==================================================

local function LoadFullMap()

    if Loaded then
        return
    end

    Loaded = true
    Targets = {}

    LoadButton.Text =
        "SCANNING FULL MAP..."

    -- PLAYER TOÀN SERVER
    local PlayerCount =
        ScanPlayers()

    -- NPC TOÀN WORKSPACE
    local NPCCount =
        ScanWorkspace()

    LoadButton.Text =
        "LOADED | PLAYER: "
        .. tostring(PlayerCount)
        .. " | NPC: "
        .. tostring(NPCCount)

    Refresh()
end

LoadButton.MouseButton1Click:Connect(
    LoadFullMap
)

--==================================================
-- SEARCH
--==================================================

Search:GetPropertyChangedSignal("Text")
    :Connect(function()

        SearchText = Search.Text

        -- SEARCH CHỈ FILTER
        -- KHÔNG SCAN LẠI
        Refresh()
    end)

--==================================================
-- DYNAMIC MUZAN
--==================================================

local function WatchDebree(Debree)

    Debree.ChildAdded:Connect(
        function(Object)

            if Object.Name
                ~= "MuzanLairModel"
            then
                return
            end

            task.wait(0.2)

            if not Loaded then
                return
            end

            if Object:IsA("Model") then

                if AddNPC(Object) then
                    Refresh()
                end
            end
        end
    )
end

local Debree =
    Workspace:FindFirstChild("Debree")

if Debree then
    WatchDebree(Debree)
end

Workspace.ChildAdded:Connect(
    function(Object)

        if Object.Name == "Debree" then
            WatchDebree(Object)
        end
    end
)

--==================================================
-- PLAYER REMOVED
--==================================================

Players.PlayerRemoving:Connect(
    function(Player)

        for i = #Targets, 1, -1 do

            if Targets[i].Player == Player then
                table.remove(Targets, i)
            end
        end

        if Loaded then
            Refresh()
        end
    end
)

--==================================================
-- DRAG
--==================================================

local Dragging = false
local DragStart
local StartPosition

Title.InputBegan:Connect(
    function(Input)

        if Input.UserInputType
            == Enum.UserInputType.MouseButton1
            or Input.UserInputType
            == Enum.UserInputType.Touch
        then

            Dragging = true
            DragStart = Input.Position
            StartPosition = Main.Position

            Input.Changed:Connect(
                function()

                    if Input.UserInputState
                        == Enum.UserInputState.End
                    then
                        Dragging = false
                    end
                end
            )
        end
    end
)

UserInputService.InputChanged:Connect(
    function(Input)

        if not Dragging then
            return
        end

        if Input.UserInputType
            == Enum.UserInputType.MouseMovement
            or Input.UserInputType
            == Enum.UserInputType.Touch
        then

            local Delta =
                Input.Position - DragStart

            Main.Position =
                UDim2.new(
                    StartPosition.X.Scale,
                    StartPosition.X.Offset + Delta.X,
                    StartPosition.Y.Scale,
                    StartPosition.Y.Offset + Delta.Y
                )
        end
    end
)

--==================================================
-- READY
--==================================================

Refresh()
```
