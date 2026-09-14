--// Anime Card Multiverse - Ouroboros Style Pack Buyer
--// Remotes confirmed:
--// GetConveyorInfo
--// RequestConveyorOffer
--// BuyPack

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local GetConveyorInfo = Remotes:WaitForChild("GetConveyorInfo")
local RequestConveyorOffer = Remotes:WaitForChild("RequestConveyorOffer")
local BuyPack = Remotes:WaitForChild("BuyPack")

--==================================================
-- SETTINGS
--==================================================

local MAX_SLOTS = 10
local BUY_DELAY = 0.7
local LOG_LIMIT = 5

--==================================================
-- STATE
--==================================================

local Running = false
local Minimized = false

local Packs = {}
local Selected = {}

local Logs = {}

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "OuroborosPackBuyer"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Parent = Gui
Main.Size = UDim2.new(0, 430, 0, 520)
Main.Position = UDim2.new(0.5, -215, 0.5, -260)
Main.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
Main.BorderSizePixel = 0

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(55, 55, 65)
MainStroke.Thickness = 1
MainStroke.Parent = Main

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Parent = Main
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(22, 22, 27)
Header.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Parent = Header
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Ouroboros  •  Pack Buyer"
Title.TextColor3 = Color3.fromRGB(235, 235, 240)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left

local MinButton = Instance.new("TextButton")
MinButton.Parent = Header
MinButton.Size = UDim2.new(0, 30, 0, 28)
MinButton.Position = UDim2.new(1, -68, 0, 8)
MinButton.BackgroundColor3 = Color3.fromRGB(38, 38, 45)
MinButton.Text = "−"
MinButton.TextColor3 = Color3.fromRGB(230, 230, 235)
MinButton.TextSize = 18
MinButton.Font = Enum.Font.GothamBold

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinButton

local CloseButton = Instance.new("TextButton")
CloseButton.Parent = Header
CloseButton.Size = UDim2.new(0, 30, 0, 28)
CloseButton.Position = UDim2.new(1, -34, 0, 8)
CloseButton.BackgroundColor3 = Color3.fromRGB(38, 38, 45)
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(230, 230, 235)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

--==================================================
-- STATUS
--==================================================

local Status = Instance.new("TextLabel")
Status.Parent = Main
Status.Size = UDim2.new(1, -24, 0, 34)
Status.Position = UDim2.new(0, 12, 0, 55)
Status.BackgroundColor3 = Color3.fromRGB(24, 24, 29)
Status.Text = "● STOPPED"
Status.TextColor3 = Color3.fromRGB(190, 190, 200)
Status.Font = Enum.Font.GothamBold
Status.TextSize = 12
Status.TextXAlignment = Enum.TextXAlignment.Left

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 7)
StatusCorner.Parent = Status

--==================================================
-- BUTTONS
--==================================================

local RefreshButton = Instance.new("TextButton")
RefreshButton.Parent = Main
RefreshButton.Size = UDim2.new(0.5, -15, 0, 36)
RefreshButton.Position = UDim2.new(0, 12, 0, 99)
RefreshButton.BackgroundColor3 = Color3.fromRGB(42, 42, 50)
RefreshButton.Text = "REFRESH CARDS"
RefreshButton.TextColor3 = Color3.fromRGB(235, 235, 240)
RefreshButton.Font = Enum.Font.GothamBold
RefreshButton.TextSize = 12

local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 7)
RefreshCorner.Parent = RefreshButton

local ScanButton = RefreshButton:Clone()
ScanButton.Parent = Main
ScanButton.Position = UDim2.new(0.5, 3, 0, 99)
ScanButton.Text = "SCAN PACKS"

--==================================================
-- FILTER
--==================================================

local FilterLabel = Instance.new("TextLabel")
FilterLabel.Parent = Main
FilterLabel.Size = UDim2.new(1, -24, 0, 20)
FilterLabel.Position = UDim2.new(0, 12, 0, 145)
FilterLabel.BackgroundTransparency = 1
FilterLabel.Text = "PACK FILTER"
FilterLabel.TextColor3 = Color3.fromRGB(140, 140, 150)
FilterLabel.Font = Enum.Font.GothamBold
FilterLabel.TextSize = 10
FilterLabel.TextXAlignment = Enum.TextXAlignment.Left

local Filter = Instance.new("TextBox")
Filter.Parent = Main
Filter.Size = UDim2.new(1, -24, 0, 34)
Filter.Position = UDim2.new(0, 12, 0, 166)
Filter.BackgroundColor3 = Color3.fromRGB(24, 24, 29)
Filter.BorderSizePixel = 0
Filter.PlaceholderText = "Search pack..."
Filter.PlaceholderColor3 = Color3.fromRGB(105, 105, 115)
Filter.Text = ""
Filter.TextColor3 = Color3.fromRGB(235, 235, 240)
Filter.Font = Enum.Font.Gotham
Filter.TextSize = 12

local FilterCorner = Instance.new("UICorner")
FilterCorner.CornerRadius = UDim.new(0, 7)
FilterCorner.Parent = Filter

--==================================================
-- PACK LIST
--==================================================

local PackLabel = Instance.new("TextLabel")
PackLabel.Parent = Main
PackLabel.Size = UDim2.new(1, -24, 0, 20)
PackLabel.Position = UDim2.new(0, 12, 0, 208)
PackLabel.BackgroundTransparency = 1
PackLabel.Text = "PACKS"
PackLabel.TextColor3 = Color3.fromRGB(140, 140, 150)
PackLabel.Font = Enum.Font.GothamBold
PackLabel.TextSize = 10
PackLabel.TextXAlignment = Enum.TextXAlignment.Left

local PackList = Instance.new("ScrollingFrame")
PackList.Parent = Main
PackList.Size = UDim2.new(1, -24, 0, 145)
PackList.Position = UDim2.new(0, 12, 0, 230)
PackList.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
PackList.BorderSizePixel = 0
PackList.ScrollBarThickness = 4
PackList.CanvasSize = UDim2.new(0, 0, 0, 0)

local PackCorner = Instance.new("UICorner")
PackCorner.CornerRadius = UDim.new(0, 7)
PackCorner.Parent = PackList

local PackLayout = Instance.new("UIListLayout")
PackLayout.Parent = PackList
PackLayout.Padding = UDim.new(0, 4)

--==================================================
-- CONTROL BUTTONS
--==================================================

local StartButton = Instance.new("TextButton")
StartButton.Parent = Main
StartButton.Size = UDim2.new(0.5, -15, 0, 36)
StartButton.Position = UDim2.new(0, 12, 0, 385)
StartButton.BackgroundColor3 = Color3.fromRGB(35, 75, 48)
StartButton.Text = "START"
StartButton.TextColor3 = Color3.fromRGB(225, 240, 230)
StartButton.Font = Enum.Font.GothamBold
StartButton.TextSize = 12

local StartCorner = Instance.new("UICorner")
StartCorner.CornerRadius = UDim.new(0, 7)
StartCorner.Parent = StartButton

local StopButton = StartButton:Clone()
StopButton.Parent = Main
StopButton.Position = UDim2.new(0.5, 3, 0, 385)
StopButton.BackgroundColor3 = Color3.fromRGB(75, 38, 40)
StopButton.Text = "STOP"

--==================================================
-- LOG
--==================================================

local LogLabel = Instance.new("TextLabel")
LogLabel.Parent = Main
LogLabel.Size = UDim2.new(1, -24, 0, 20)
LogLabel.Position = UDim2.new(0, 12, 0, 429)
LogLabel.BackgroundTransparency = 1
LogLabel.Text = "LOG"
LogLabel.TextColor3 = Color3.fromRGB(140, 140, 150)
LogLabel.Font = Enum.Font.GothamBold
LogLabel.TextSize = 10
LogLabel.TextXAlignment = Enum.TextXAlignment.Left

local LogBox = Instance.new("TextLabel")
LogBox.Parent = Main
LogBox.Size = UDim2.new(1, -110, 0, 62)
LogBox.Position = UDim2.new(0, 12, 0, 450)
LogBox.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
LogBox.BorderSizePixel = 0
LogBox.Text = "Ready."
LogBox.TextColor3 = Color3.fromRGB(145, 145, 155)
LogBox.Font = Enum.Font.Code
LogBox.TextSize = 10
LogBox.TextXAlignment = Enum.TextXAlignment.Left
LogBox.TextYAlignment = Enum.TextYAlignment.Top
LogBox.TextWrapped = true

local LogCorner = Instance.new("UICorner")
LogCorner.CornerRadius = UDim.new(0, 7)
LogCorner.Parent = LogBox

local ClearLog = Instance.new("TextButton")
ClearLog.Parent = Main
ClearLog.Size = UDim2.new(0, 82, 0, 62)
ClearLog.Position = UDim2.new(1, -94, 0, 450)
ClearLog.BackgroundColor3 = Color3.fromRGB(38, 38, 45)
ClearLog.Text = "CLEAR\nLOG"
ClearLog.TextColor3 = Color3.fromRGB(220, 220, 225)
ClearLog.Font = Enum.Font.GothamBold
ClearLog.TextSize = 10

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 7)
ClearCorner.Parent = ClearLog

--==================================================
-- LOG SYSTEM
--==================================================

local function AddLog(Text)
    table.insert(Logs, Text)

    while #Logs > LOG_LIMIT do
        table.remove(Logs, 1)
    end

    LogBox.Text = table.concat(Logs, "\n")
end

--==================================================
-- PACK LIST
--==================================================

local function ClearPackButtons()
    for _, Child in ipairs(PackList:GetChildren()) do
        if Child:IsA("Frame") then
            Child:Destroy()
        end
    end
end

local function RefreshPackList()
    ClearPackButtons()

    local Search = string.lower(Filter.Text)

    for PackName, _ in pairs(Packs) do

        if Search == "" or string.find(string.lower(PackName), Search, 1, true) then

            local Row = Instance.new("Frame")
            Row.Parent = PackList
            Row.Size = UDim2.new(1, -6, 0, 30)
            Row.BackgroundColor3 = Color3.fromRGB(27, 27, 32)
            Row.BorderSizePixel = 0

            local RowCorner = Instance.new("UICorner")
            RowCorner.CornerRadius = UDim.new(0, 5)
            RowCorner.Parent = Row

            local Toggle = Instance.new("TextButton")
            Toggle.Parent = Row
            Toggle.Size = UDim2.new(0, 28, 0, 24)
            Toggle.Position = UDim2.new(0, 4, 0, 3)
            Toggle.Text = Selected[PackName] and "✓" or ""
            Toggle.TextColor3 = Color3.fromRGB(220, 235, 225)
            Toggle.TextSize = 13
            Toggle.Font = Enum.Font.GothamBold
            Toggle.BackgroundColor3 =
                Selected[PackName]
                and Color3.fromRGB(45, 90, 55)
                or Color3.fromRGB(38, 38, 45)

            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 5)
            ToggleCorner.Parent = Toggle

            local Name = Instance.new("TextLabel")
            Name.Parent = Row
            Name.Size = UDim2.new(1, -42, 1, 0)
            Name.Position = UDim2.new(0, 38, 0, 0)
            Name.BackgroundTransparency = 1
            Name.Text = PackName
            Name.TextColor3 = Color3.fromRGB(220, 220, 225)
            Name.TextSize = 11
            Name.Font = Enum.Font.Gotham
            Name.TextXAlignment = Enum.TextXAlignment.Left

            Toggle.Activated:Connect(function()
                Selected[PackName] = not Selected[PackName]
                RefreshPackList()
            end)
        end
    end

    task.wait()

    PackList.CanvasSize = UDim2.new(
        0,
        0,
        0,
        PackLayout.AbsoluteContentSize.Y + 5
    )
end

--==================================================
-- SCAN ONE SLOT
--==================================================

local function GetOffer(Slot)
    local Success, Result = pcall(function()
        return RequestConveyorOffer:InvokeServer(Slot)
    end)

    if not Success or type(Result) ~= "table" then
        return nil
    end

    local Offer = Result[1]

    if type(Offer) ~= "table" then
        return nil
    end

    if not Offer.PackName or not Offer.OfferId then
        return nil
    end

    return Offer
end

--==================================================
-- SCAN PACKS
--==================================================

local function ScanPacks()
    local Found = 0

    for Slot = 1, MAX_SLOTS do

        local Offer = GetOffer(Slot)

        if Offer then

            if not Packs[Offer.PackName] then
                Packs[Offer.PackName] = true

                -- New packs are OFF by default
                if Selected[Offer.PackName] == nil then
                    Selected[Offer.PackName] = false
                end
            end

            Found = Found + 1

            AddLog(
                "[SCAN] "
                .. Offer.PackName
                .. " | "
                .. Offer.Mutation
            )
        end
    end

    RefreshPackList()

    AddLog("[+] Found " .. tostring(Found) .. " offer(s)")
end

--==================================================
-- REFRESH
--==================================================

RefreshButton.Activated:Connect(function()

    local Success = pcall(function()
        GetConveyorInfo:InvokeServer()
    end)

    if Success then
        AddLog("[REFRESH] Cards refreshed")
    else
        AddLog("[!] Refresh failed")
    end
end)

ScanButton.Activated:Connect(function()
    ScanPacks()
end)

Filter:GetPropertyChangedSignal("Text"):Connect(function()
    RefreshPackList()
end)

--==================================================
-- BUY CURRENT SELECTED PACKS
--==================================================

local function TryBuy()

    for Slot = 1, MAX_SLOTS do

        if not Running then
            return
        end

        local Offer = GetOffer(Slot)

        if Offer and Selected[Offer.PackName] then

            local Success = pcall(function()

                BuyPack:FireServer(
                    Offer.PackName,
                    Offer.Mutation,
                    Offer.OfferId
                )

            end)

            if Success then
                AddLog("[BUY] " .. Offer.PackName)
            else
                AddLog("[!] Buy failed")
            end

            task.wait(BUY_DELAY)
        end
    end
end

--==================================================
-- START
--==================================================

StartButton.Activated:Connect(function()

    if Running then
        return
    end

    Running = true

    Status.Text = "● RUNNING"
    Status.TextColor3 = Color3.fromRGB(120, 220, 145)

    AddLog("[START] Auto Buy started")

    task.spawn(function()

        while Running do

            TryBuy()

            task.wait(0.2)

        end

    end)
end)

--==================================================
-- STOP
--==================================================

StopButton.Activated:Connect(function()

    Running = false

    Status.Text = "● STOPPED"
    Status.TextColor3 = Color3.fromRGB(190, 190, 200)

    AddLog("[STOP] Auto Buy stopped")
end)

--==================================================
-- CLEAR LOG
--==================================================

ClearLog.Activated:Connect(function()

    table.clear(Logs)

    LogBox.Text = "Logs cleared."
end)

--==================================================
-- MINIMIZE
--==================================================

local FullSize = UDim2.new(0, 430, 0, 520)
local MiniSize = UDim2.new(0, 430, 0, 45)

MinButton.Activated:Connect(function()

    Minimized = not Minimized

    if Minimized then

        Main.Size = MiniSize
        MinButton.Text = "+"

        for _, Child in ipairs(Main:GetChildren()) do
            if Child ~= Header then
                Child.Visible = false
            end
        end

    else

        Main.Size = FullSize
        MinButton.Text = "−"

        for _, Child in ipairs(Main:GetChildren()) do
            Child.Visible = true
        end
    end
end)

--==================================================
-- CLOSE
--==================================================

CloseButton.Activated:Connect(function()

    Running = false
    Gui:Destroy()

end)

--==================================================
-- DRAG
--==================================================

local Dragging = false
local DragStart
local StartPosition

Header.InputBegan:Connect(function(Input)

    if Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch then

        Dragging = true
        DragStart = Input.Position
        StartPosition = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(Input)

    if not Dragging then
        return
    end

    if Input.UserInputType == Enum.UserInputType.MouseMovement
        or Input.UserInputType == Enum.UserInputType.Touch then

        local Delta = Input.Position - DragStart

        Main.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(Input)

    if Input.UserInputType == Enum.UserInputType.MouseButton1
        or Input.UserInputType == Enum.UserInputType.Touch then

        Dragging = false
    end
end)

--==================================================
-- INITIAL
--==================================================

AddLog("[READY] Ouroboros Pack Buyer loaded")
AddLog("[INFO] Press SCAN PACKS")
