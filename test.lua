local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local RequestConveyorOffer = Remotes:WaitForChild("RequestConveyorOffer")
local BuyPack = Remotes:WaitForChild("BuyPack")
local SetRecoverPack = Remotes:WaitForChild("SetRecoverPack")

--==================================================
-- SETTINGS
--==================================================

local Running = false
local Delay = 1.5

local DetectedPacks = {}
local SelectedPacks = {}

local MAX_LOGS = 5

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "PackAutoFarm"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 380, 0, 480)
Main.Position = UDim2.new(0.5, -190, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

--==================================================
-- DRAG
--==================================================

local dragging = false
local dragStart
local startPos

Main.InputBegan:Connect(function(input)

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

    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then

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
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "Pack Auto Farm"
Title.TextColor3 = Color3.fromRGB(235, 235, 235)
Title.TextSize = 19
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

--==================================================
-- STATUS
--==================================================

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 22)
Status.Position = UDim2.new(0, 10, 0, 43)
Status.BackgroundTransparency = 1
Status.Text = "Status: OFF"
Status.TextColor3 = Color3.fromRGB(255, 90, 90)
Status.TextSize = 13
Status.Font = Enum.Font.Gotham
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

--==================================================
-- START
--==================================================

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(1, -20, 0, 36)
Toggle.Position = UDim2.new(0, 10, 0, 68)
Toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
Toggle.Text = "START"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.TextSize = 14
Toggle.Font = Enum.Font.GothamBold
Toggle.Parent = Main

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 7)
ToggleCorner.Parent = Toggle

--==================================================
-- SELECTED PACK LABEL
--==================================================

local SelectedLabel = Instance.new("TextLabel")
SelectedLabel.Size = UDim2.new(1, -20, 0, 20)
SelectedLabel.Position = UDim2.new(0, 10, 0, 115)
SelectedLabel.BackgroundTransparency = 1
SelectedLabel.Text = "Selected Pack"
SelectedLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
SelectedLabel.TextSize = 13
SelectedLabel.Font = Enum.Font.GothamBold
SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
SelectedLabel.Parent = Main

--==================================================
-- DROPDOWN
--==================================================

local Dropdown = Instance.new("TextButton")
Dropdown.Size = UDim2.new(1, -20, 0, 36)
Dropdown.Position = UDim2.new(0, 10, 0, 138)
Dropdown.BackgroundColor3 = Color3.fromRGB(38, 38, 43)
Dropdown.Text = "No pack selected"
Dropdown.TextColor3 = Color3.fromRGB(230, 230, 230)
Dropdown.TextSize = 13
Dropdown.Font = Enum.Font.Gotham
Dropdown.TextXAlignment = Enum.TextXAlignment.Left
Dropdown.Parent = Main

local DropdownPadding = Instance.new("UIPadding")
DropdownPadding.PaddingLeft = UDim.new(0, 12)
DropdownPadding.Parent = Dropdown

local DropdownCorner = Instance.new("UICorner")
DropdownCorner.CornerRadius = UDim.new(0, 7)
DropdownCorner.Parent = Dropdown

--==================================================
-- DROPDOWN LIST
--==================================================

local PackList = Instance.new("ScrollingFrame")
PackList.Size = UDim2.new(1, -20, 0, 120)
PackList.Position = UDim2.new(0, 10, 0, 178)
PackList.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
PackList.BorderSizePixel = 0
PackList.ScrollBarThickness = 4
PackList.Visible = false
PackList.ZIndex = 10
PackList.CanvasSize = UDim2.new(0, 0, 0, 0)
PackList.AutomaticCanvasSize = Enum.AutomaticSize.Y
PackList.Parent = Main

local PackListCorner = Instance.new("UICorner")
PackListCorner.CornerRadius = UDim.new(0, 7)
PackListCorner.Parent = PackList

local PackLayout = Instance.new("UIListLayout")
PackLayout.Padding = UDim.new(0, 3)
PackLayout.Parent = PackList

local PackPadding = Instance.new("UIPadding")
PackPadding.PaddingTop = UDim.new(0, 5)
PackPadding.PaddingBottom = UDim.new(0, 5)
PackPadding.PaddingLeft = UDim.new(0, 5)
PackPadding.PaddingRight = UDim.new(0, 5)
PackPadding.Parent = PackList

--==================================================
-- UPDATE SELECTED TEXT
--==================================================

local function UpdateSelectedText()

    local selected = {}

    for packName in pairs(SelectedPacks) do
        table.insert(selected, packName)
    end

    table.sort(selected)

    if #selected == 0 then

        Dropdown.Text = "No pack selected"

    else

        Dropdown.Text = table.concat(selected, ", ")

    end

end

--==================================================
-- LOG
--==================================================

local LogTitle = Instance.new("TextLabel")
LogTitle.Size = UDim2.new(1, -20, 0, 20)
LogTitle.Position = UDim2.new(0, 10, 0, 310)
LogTitle.BackgroundTransparency = 1
LogTitle.Text = "Roll Log"
LogTitle.TextColor3 = Color3.fromRGB(210, 210, 210)
LogTitle.TextSize = 13
LogTitle.Font = Enum.Font.GothamBold
LogTitle.TextXAlignment = Enum.TextXAlignment.Left
LogTitle.Parent = Main

local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Size = UDim2.new(1, -20, 0, 85)
LogFrame.Position = UDim2.new(0, 10, 0, 335)
LogFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 19)
LogFrame.BorderSizePixel = 0
LogFrame.ScrollBarThickness = 4
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogFrame.Parent = Main

local LogCorner = Instance.new("UICorner")
LogCorner.CornerRadius = UDim.new(0, 7)
LogCorner.Parent = LogFrame

local LogText = Instance.new("TextLabel")
LogText.Size = UDim2.new(1, -10, 0, 0)
LogText.Position = UDim2.new(0, 5, 0, 5)
LogText.BackgroundTransparency = 1
LogText.Text = ""
LogText.TextColor3 = Color3.fromRGB(220, 220, 220)
LogText.TextSize = 11
LogText.Font = Enum.Font.Code
LogText.TextXAlignment = Enum.TextXAlignment.Left
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.TextWrapped = true
LogText.AutomaticSize = Enum.AutomaticSize.Y
LogText.Parent = LogFrame

local Logs = {}

local function RefreshLog()

    LogText.Text = table.concat(Logs, "\n")

    task.defer(function()

        local height = LogText.AbsoluteSize.Y + 10

        LogFrame.CanvasSize = UDim2.new(
            0,
            0,
            0,
            height
        )

        LogFrame.CanvasPosition = Vector2.new(
            0,
            math.max(
                0,
                height - LogFrame.AbsoluteSize.Y
            )
        )

    end)

end

local function ClearLogs()

    table.clear(Logs)

    LogText.Text = ""

    LogFrame.CanvasSize =
        UDim2.new(0, 0, 0, 0)

    LogFrame.CanvasPosition =
        Vector2.new(0, 0)

end

local function AddLog(message)

    if #Logs >= MAX_LOGS then
        ClearLogs()
    end

    table.insert(
        Logs,
        "[" .. os.date("%H:%M:%S") .. "] "
        .. tostring(message)
    )

    RefreshLog()

end

--==================================================
-- CLEAR LOG
--==================================================

local ClearButton = Instance.new("TextButton")
ClearButton.Size = UDim2.new(0.48, -5, 0, 32)
ClearButton.Position = UDim2.new(0, 10, 0, 430)
ClearButton.BackgroundColor3 = Color3.fromRGB(65, 65, 70)
ClearButton.Text = "CLEAR LOG"
ClearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearButton.TextSize = 12
ClearButton.Font = Enum.Font.GothamBold
ClearButton.Parent = Main

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 7)
ClearCorner.Parent = ClearButton

--==================================================
-- SCAN BUTTON
--==================================================

local ScanButton = Instance.new("TextButton")
ScanButton.Size = UDim2.new(0.48, -5, 0, 32)
ScanButton.Position = UDim2.new(0.52, 0, 0, 430)
ScanButton.BackgroundColor3 = Color3.fromRGB(55, 100, 165)
ScanButton.Text = "SCAN PACKS"
ScanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanButton.TextSize = 12
ScanButton.Font = Enum.Font.GothamBold
ScanButton.Parent = Main

local ScanCorner = Instance.new("UICorner")
ScanCorner.CornerRadius = UDim.new(0, 7)
ScanCorner.Parent = ScanButton

--==================================================
-- CLEAR BUTTONS IN DROPDOWN
--==================================================

local function ClearPackList()

    for _, child in ipairs(PackList:GetChildren()) do

        if child:IsA("TextButton") then
            child:Destroy()
        end

    end

end

--==================================================
-- CREATE PACK ENTRY
--==================================================

local function CreatePackEntry(packName)

    local Button = Instance.new("TextButton")

    Button.Size = UDim2.new(1, -10, 0, 28)
    Button.BackgroundColor3 = Color3.fromRGB(42, 42, 47)
    Button.TextColor3 = Color3.fromRGB(230, 230, 230)
    Button.TextSize = 12
    Button.Font = Enum.Font.Gotham
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Button.ZIndex = 11
    Button.Parent = PackList

    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 10)
    Padding.Parent = Button

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Button

    local function RefreshButton()

        if SelectedPacks[packName] then

            Button.Text = "✓  " .. packName
            Button.BackgroundColor3 =
                Color3.fromRGB(55, 105, 70)

        else

            Button.Text = packName
            Button.BackgroundColor3 =
                Color3.fromRGB(42, 42, 47)

        end

    end

    RefreshButton()

    Button.MouseButton1Click:Connect(function()

        if SelectedPacks[packName] then

            SelectedPacks[packName] = nil

        else

            SelectedPacks[packName] = true

        end

        RefreshButton()
        UpdateSelectedText()

    end)

end

--==================================================
-- SCAN PACKS
--==================================================

local function ScanPacks()

    AddLog("Scanning packs...")

    local success, result = pcall(function()

        return RequestConveyorOffer:InvokeServer(1)

    end)

    if not success then

        AddLog("ERROR: Scan failed")

        warn(
            "RequestConveyorOffer:",
            result
        )

        return

    end

    if typeof(result) ~= "table" then

        AddLog("ERROR: Invalid scan result")

        return

    end

    table.clear(DetectedPacks)

    for _, offer in pairs(result) do

        if typeof(offer) == "table" then

            local packName = offer.PackName

            if packName then
                DetectedPacks[packName] = true
            end

        end

    end

    ClearPackList()

    local count = 0

    for packName in pairs(DetectedPacks) do

        count += 1

        CreatePackEntry(packName)

    end

    -- Remove selections that no longer exist
    for packName in pairs(SelectedPacks) do

        if not DetectedPacks[packName] then
            SelectedPacks[packName] = nil
        end

    end

    UpdateSelectedText()

    AddLog(
        "Found "
        .. tostring(count)
        .. " pack(s)"
    )

end

--==================================================
-- DROPDOWN TOGGLE
--==================================================

Dropdown.MouseButton1Click:Connect(function()

    PackList.Visible =
        not PackList.Visible

end)

--==================================================
-- SCAN
--==================================================

ScanButton.MouseButton1Click:Connect(function()

    ScanButton.Text = "SCANNING..."
    ScanButton.Active = false

    task.spawn(function()

        ScanPacks()

        ScanButton.Text = "SCAN PACKS"
        ScanButton.Active = true

    end)

end)

--==================================================
-- CLEAR LOG
--==================================================

ClearButton.MouseButton1Click:Connect(function()
    ClearLogs()
end)

--==================================================
-- CHECK SELECTED PACK
--==================================================

local function IsSelectedPack(packName)

    return SelectedPacks[packName] == true

end

--==================================================
-- BUY + ROLL
--==================================================

local function BuyAndRoll()

    local hasSelection = false

    for _ in pairs(SelectedPacks) do
        hasSelection = true
        break
    end

    if not hasSelection then

        AddLog(
            "No pack selected"
        )

        return

    end

    local success, result = pcall(function()

        return RequestConveyorOffer:InvokeServer(1)

    end)

    if not success or typeof(result) ~= "table" then

        AddLog(
            "ERROR: Cannot get offer"
        )

        return

    end

    for _, offer in pairs(result) do

        if typeof(offer) ~= "table" then
            continue
        end

        local packName =
            offer.PackName

        local mutation =
            offer.Mutation

        local offerId =
            offer.OfferId

        if not packName or not offerId then
            continue
        end

        if IsSelectedPack(packName) then

            AddLog(
                "Buying: "
                .. tostring(packName)
                .. " | "
                .. tostring(mutation)
            )

            local buySuccess, buyError =
                pcall(function()

                    BuyPack:FireServer(
                        packName,
                        mutation,
                        offerId
                    )

                end)

            if not buySuccess then

                warn(
                    "BuyPack:",
                    buyError
                )

                AddLog(
                    "ERROR: BuyPack"
                )

                return

            end

            AddLog(
                "Bought: "
                .. tostring(packName)
            )

            task.wait(0.5)

            local rollSuccess, rollError =
                pcall(function()

                    SetRecoverPack:FireServer(
                        offerId
                    )

                end)

            if not rollSuccess then

                warn(
                    "SetRecoverPack:",
                    rollError
                )

                AddLog(
                    "ERROR: SetRecoverPack"
                )

            else

                AddLog(
                    "ROLLED: "
                    .. tostring(packName)
                    .. " | "
                    .. tostring(mutation)
                )

            end

            return

        end

    end

    AddLog(
        "No selected pack in offer"
    )

end

--==================================================
-- AUTO LOOP
--==================================================

task.spawn(function()

    while true do

        if Running then

            BuyAndRoll()

            task.wait(Delay)

        else

            task.wait(0.2)

        end

    end

end)

--==================================================
-- START / STOP
--==================================================

Toggle.MouseButton1Click:Connect(function()

    Running = not Running

    if Running then

        Toggle.Text = "STOP"

        Toggle.BackgroundColor3 =
            Color3.fromRGB(145, 55, 55)

        Status.Text =
            "Status: RUNNING"

        Status.TextColor3 =
            Color3.fromRGB(80, 230, 100)

        AddLog(
            "Auto Farm STARTED"
        )

    else

        Toggle.Text = "START"

        Toggle.BackgroundColor3 =
            Color3.fromRGB(45, 45, 50)

        Status.Text =
            "Status: OFF"

        Status.TextColor3 =
            Color3.fromRGB(255, 90, 90)

        AddLog(
            "Auto Farm STOPPED"
        )

    end

end)

--==================================================
-- INITIAL SCAN
--==================================================

task.spawn(function()

    task.wait(1)

    ScanPacks()

end)