```lua
--==================================================
-- PROJECT SLAYERS 2
-- FULL MAP NPC + PLAYER TELEPORT HUB
--==================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

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
Gui.Name = "FullMapTeleportHub"
Gui.ResetOnSpawn = false
Gui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 520, 0, 600)
Main.Position = UDim2.new(0.5, -260, 0.5, -300)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Main

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "FULL MAP NPC + PLAYER"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 35, 0, 35)
Close.Position = UDim2.new(1, -40, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(170, 50, 50)
Close.Text = "X"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.TextSize = 16
Close.Font = Enum.Font.GothamBold
Close.Parent = Main

Close.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)

--==================================================
-- LOAD BUTTON
--==================================================

local LoadButton = Instance.new("TextButton")
LoadButton.Size = UDim2.new(1, -30, 0, 42)
LoadButton.Position = UDim2.new(0, 15, 0, 50)
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
Search.Position = UDim2.new(0, 15, 0, 100)
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
TabFrame.Position = UDim2.new(0, 15, 0, 145)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = Main

local Tabs = {}

local function CreateTab(Name, X)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 115, 1, 0)
    Button.Position = UDim2.new(0, X, 0, 0)
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    Button.Text = Name
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamBold
    Button.Parent = TabFrame

    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

    Tabs[Name] = Button

    Button.MouseButton1Click:Connect(function()
        CurrentTab = Name
        Refresh()
    end)
end

CreateTab("ALL", 0)
CreateTab("NPC", 120)
CreateTab("PLAYER", 240)
CreateTab("MUZAN", 360)

--==================================================
-- LIST
--==================================================

local List = Instance.new("ScrollingFrame")
List.Size = UDim2.new(1, -30, 1, -235)
List.Position = UDim2.new(0, 15, 0, 190)
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
-- HELPERS
--==================================================

local function GetRoot(Model)
    if not Model then
        return nil
    end

    local Root = Model:FindFirstChild("HumanoidRootPart")

    if Root and Root:IsA("BasePart") then
        return Root
    end

    if Model.PrimaryPart and Model.PrimaryPart:IsA("BasePart") then
        return Model.PrimaryPart
    end

    return Model:FindFirstChildWhichIsA("BasePart", true)
end

local function IsPlayerCharacter(Model)
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player.Character == Model then
            return true
        end
    end

    return false
end

--==================================================
-- PLAYER SCAN
--==================================================

local function ScanPlayers()
    local Count = 0

    -- IMPORTANT:
    -- GetPlayers() lấy TOÀN BỘ player trong server
    -- Không scan theo khoảng cách.

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player.Character then

            local Root = GetRoot(Player.Character)

            if Root then
                table.insert(Targets, {
                    Name = Player.Name,
                    DisplayName = Player.DisplayName,
                    Type = "PLAYER",
                    Model = Player.Character,
                    Root = Root,
                    Player = Player
                })

                Count += 1
            end
        end
    end

    return Count
end

--==================================================
-- NPC DETECTION
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

    -- ProximityPrompt NPC
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
-- NPC SCAN
--==================================================

local function ScanNPCs()
    local Count = 0

    for _, Object in ipairs(workspace:GetDescendants()) do

        if Object:IsA("Model") and IsNPC(Object) then

            local Root = GetRoot(Object)

            if Root then

                local Name = Object.Name

                local Type = "NPC"

                if Name == "MuzanLairModel"
                    or Object:FindFirstChild("MuzanIsHere123", true)
                then
                    Type = "MUZAN"
                    Name = "Muzan"
                end

                table.insert(Targets, {
                    Name = Name,
                    DisplayName = Name,
                    Type = Type,
                    Model = Object,
                    Root = Root
                })

                Count += 1
            end
        end
    end

    return Count
end

--==================================================
-- FORCE MUZAN
--==================================================

local function ScanMuzan()
    local Debree = workspace:FindFirstChild("Debree")

    if not Debree then
        return
    end

    local Muzan = Debree:FindFirstChild("MuzanLairModel")

    if not Muzan or not Muzan:IsA("Model") then
        return
    end

    local Root = GetRoot(Muzan)

    if not Root then
        return
    end

    -- tránh duplicate
    for _, Target in ipairs(Targets) do
        if Target.Model == Muzan then
            return
        end
    end

    table.insert(Targets, {
        Name = "Muzan",
        DisplayName = "Muzan",
        Type = "MUZAN",
        Model = Muzan,
        Root = Root
    })
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

    local SearchLower = string.lower(SearchText)
    local Amount = 0

    for _, Target in ipairs(Targets) do

        local PassTab =
            CurrentTab == "ALL"
            or CurrentTab == Target.Type
            or (CurrentTab == "NPC" and Target.Type == "MUZAN")

        local PassSearch =
            SearchLower == ""
            or string.find(string.lower(Target.Name), SearchLower, 1, true)
            or string.find(string.lower(Target.DisplayName or ""), SearchLower, 1, true)

        if PassTab and PassSearch then

            local Button = Instance.new("TextButton")

            Button.Size = UDim2.new(1, -10, 0, 42)
            Button.BackgroundColor3 =
                Target.Type == "PLAYER"
                and Color3.fromRGB(45, 90, 145)
                or Target.Type == "MUZAN"
                and Color3.fromRGB(145, 70, 70)
                or Color3.fromRGB(55, 55, 65)

            Button.Text = Target.Type .. "  |  " .. Target.Name
            Button.TextColor3 = Color3.new(1, 1, 1)
            Button.TextSize = 13
            Button.Font = Enum.Font.GothamBold
            Button.Parent = List

            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

            Button.MouseButton1Click:Connect(function()

                local Character = LocalPlayer.Character

                if not Character then
                    return
                end

                local MyRoot = Character:FindFirstChild("HumanoidRootPart")

                if not MyRoot then
                    return
                end

                local TargetRoot = Target.Root

                if TargetRoot and TargetRoot.Parent then
                    MyRoot.CFrame =
                        TargetRoot.CFrame
                        * CFrame.new(0, 3, 0)
                end
            end)

            Amount += 1
        end
    end

    List.CanvasSize = UDim2.new(0, 0, 0, Amount * 47)
end

--==================================================
-- FULL MAP LOAD
--==================================================

local function LoadFullMap()

    if Loaded then
        return
    end

    Loaded = true
    Targets = {}

    LoadButton.Text = "SCANNING FULL MAP..."

    -- Player: toàn bộ server
    local PlayerCount = ScanPlayers()

    -- NPC: toàn bộ Workspace hiện client có
    local NPCCount = ScanNPCs()

    -- Muzan: path đặc biệt
    ScanMuzan()

    LoadButton.Text =
        "LOADED  |  PLAYER: "
        .. tostring(PlayerCount)
        .. "  NPC: "
        .. tostring(NPCCount)

    Refresh()
end

--==================================================
-- SEARCH = FILTER ONLY
--==================================================

Search:GetPropertyChangedSignal("Text"):Connect(function()

    SearchText = Search.Text

    -- KHÔNG scan lại
    Refresh()
end)

--==================================================
-- LOAD
--==================================================

LoadButton.MouseButton1Click:Connect(function()
    LoadFullMap()
end)

--==================================================
-- PLAYER JOIN/LEAVE
--==================================================

-- Không tự scan lại khi search.
-- Nếu player mới vào sau khi Load thì chỉ cập nhật
-- khi người dùng bấm LOAD lại bằng cách reset Loaded.

Players.PlayerAdded:Connect(function()
    if Loaded then
        -- Không tự rescan để giữ đúng yêu cầu
        -- "search chỉ filter danh sách đã load".
    end
end)

Players.PlayerRemoving:Connect(function(Player)

    for i = #Targets, 1, -1 do

        local Target = Targets[i]

        if Target.Player == Player then
            table.remove(Targets, i)
        end
    end

    if Loaded then
        Refresh()
    end
end)

--==================================================
-- DRAG
--==================================================

local UserInputService = game:GetService("UserInputService")

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

            if Input.UserInputState == Enum.UserInputState.End then
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

        local Delta = Input.Position - DragStart

        Main.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
    end
end)

--==================================================
-- READY
--==================================================

Refresh()
```
