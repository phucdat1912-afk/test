--========================================================
-- PORNHUB - ANIME CARD FARM
-- Pack Filter / Refresh Packs TEST
--========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local RequestConveyorOffer = Remotes:WaitForChild("RequestConveyorOffer")
local BuyPack = Remotes:WaitForChild("BuyPack")
local SetRecoverPack = Remotes:WaitForChild("SetRecoverPack")

--========================================================
-- SETTINGS
--========================================================

local AutoFarm = false
local AutoRefresh = false

local RollDelay = 1.5
local RefreshDelay = 10

local MAX_LOGS = 5

-- Danh sách pack phát hiện được
local DetectedPacks = {}

-- Pack người chơi đã chọn
local SelectedPacks = {}

local Logs = {}

--========================================================
-- DESTROY OLD UI
--========================================================

pcall(function()
    local old = CoreGui:FindFirstChild("Pornhub")
    if old then
        old:Destroy()
    end
end)

--========================================================
-- UI HELPERS
--========================================================

local function Create(class, properties, parent)
    local object = Instance.new(class)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    object.Parent = parent

    return object
end

local function AddCorner(object, radius)
    Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 6)
    }, object)
end

local function AddStroke(object)
    Create("UIStroke", {
        Color = Color3.fromRGB(55, 55, 65),
        Thickness = 1
    }, object)
end

--========================================================
-- MAIN WINDOW
--========================================================

local Gui = Create("ScreenGui", {
    Name = "Pornhub",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, CoreGui)

local Main = Create("Frame", {
    Size = UDim2.new(0, 760, 0, 500),
    Position = UDim2.new(0.5, -380, 0.5, -250),
    BackgroundColor3 = Color3.fromRGB(20, 20, 24),
    BorderSizePixel = 0
}, Gui)

AddCorner(Main, 8)
AddStroke(Main)

--========================================================
-- DRAG
--========================================================

local dragging = false
local dragStart
local startPosition

Main.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = true
        dragStart = input.Position
        startPosition = Main.Position

    end

end)

Main.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end

end)

UserInputService.InputChanged:Connect(function(input)

    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then

        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )

    end

end)

--========================================================
-- HEADER
--========================================================

local Header = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundColor3 = Color3.fromRGB(25, 25, 30),
    BorderSizePixel = 0
}, Main)

local Title = Create("TextLabel", {
    Size = UDim2.new(1, -20, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = "Pornhub",
    TextColor3 = Color3.fromRGB(235, 235, 240),
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, Header)

--========================================================
-- SIDEBAR
--========================================================

local Sidebar = Create("Frame", {
    Size = UDim2.new(0, 145, 1, -42),
    Position = UDim2.new(0, 0, 0, 42),
    BackgroundColor3 = Color3.fromRGB(23, 23, 28),
    BorderSizePixel = 0
}, Main)

local Content = Create("Frame", {
    Size = UDim2.new(1, -145, 1, -42),
    Position = UDim2.new(0, 145, 0, 42),
    BackgroundTransparency = 1
}, Main)

--========================================================
-- PAGES
--========================================================

local Pages = {}

local function CreatePage(name)

    local page = Create("ScrollingFrame", {
        Name = name,
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false
    }, Content)

    Pages[name] = page

    return page
end

local FarmPage = CreatePage("Farm")
local FilterPage = CreatePage("Filter")
local RefreshPage = CreatePage("Refresh")
local LogsPage = CreatePage("Logs")

FarmPage.Visible = true

--========================================================
-- SIDEBAR BUTTON
--========================================================

local function CreateTab(text, pageName, order)

    local button = Create("TextButton", {
        Size = UDim2.new(1, -20, 0, 34),
        Position = UDim2.new(0, 10, 0, 15 + ((order - 1) * 40)),
        BackgroundColor3 = Color3.fromRGB(30, 30, 35),
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = Color3.fromRGB(180, 180, 190),
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = false
    }, Sidebar)

    AddCorner(button, 5)

    button.MouseButton1Click:Connect(function()

        for name, page in pairs(Pages) do
            page.Visible = name == pageName
        end

        for _, child in ipairs(Sidebar:GetChildren()) do

            if child:IsA("TextButton") then
                child.BackgroundColor3 =
                    Color3.fromRGB(30, 30, 35)

                child.TextColor3 =
                    Color3.fromRGB(180, 180, 190)
            end

        end

        button.BackgroundColor3 =
            Color3.fromRGB(55, 55, 65)

        button.TextColor3 =
            Color3.fromRGB(255, 255, 255)

    end)

    return button
end

local FarmTab = CreateTab("Farm", "Farm", 1)
CreateTab("Pack Filter", "Filter", 2)
CreateTab("Refresh", "Refresh", 3)
CreateTab("Logs", "Logs", 4)

FarmTab.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
FarmTab.TextColor3 = Color3.fromRGB(255, 255, 255)

--========================================================
-- GROUPBOX
--========================================================

local function Groupbox(parent, title, width)

    local box = Create("Frame", {
        Size = UDim2.new(width or 1, -5, 0, 100),
        BackgroundColor3 = Color3.fromRGB(25, 25, 30),
        BorderSizePixel = 0
    }, parent)

    AddCorner(box, 6)
    AddStroke(box)

    Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(220, 220, 225),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    }, box)

    local container = Create("Frame", {
        Size = UDim2.new(1, -20, 1, -35),
        Position = UDim2.new(0, 10, 0, 32),
        BackgroundTransparency = 1
    }, box)

    local layout = Create("UIListLayout", {
        Padding = UDim.new(0, 7)
    }, container)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()

        box.Size = UDim2.new(
            width or 1,
            -5,
            0,
            layout.AbsoluteContentSize.Y + 45
        )

    end)

    return box, container
end

--========================================================
-- LOG
--========================================================

local LogText

local function AddLog(message)

    if #Logs >= MAX_LOGS then
        table.clear(Logs)
    end

    table.insert(
        Logs,
        "[" .. os.date("%H:%M:%S") .. "] " .. tostring(message)
    )

    if LogText then
        LogText.Text = table.concat(Logs, "\n")
    end

end

local function ClearLogs()

    table.clear(Logs)

    if LogText then
        LogText.Text = ""
    end

end

--========================================================
-- BUTTON
--========================================================

local function Button(parent, text, callback)

    local button = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Color3.fromRGB(40, 40, 47),
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = Color3.fromRGB(220, 220, 225),
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = false
    }, parent)

    AddCorner(button, 5)

    button.MouseButton1Click:Connect(function()

        task.spawn(function()

            pcall(callback)

        end)

    end)

    return button
end

--========================================================
-- TOGGLE
--========================================================

local function Toggle(parent, text, default, callback)

    local value = default or false

    local button = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Color3.fromRGB(32, 32, 38),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false
    }, parent)

    AddCorner(button, 5)

    local indicator = Create("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 7, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(45, 45, 50),
        BorderSizePixel = 0
    }, button)

    AddCorner(indicator, 4)

    Create("TextLabel", {
        Size = UDim2.new(1, -35, 1, 0),
        Position = UDim2.new(0, 33, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(210, 210, 215),
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, button)

    local function Update()

        if value then
            indicator.BackgroundColor3 =
                Color3.fromRGB(90, 150, 100)
        else
            indicator.BackgroundColor3 =
                Color3.fromRGB(45, 45, 50)
        end

    end

    button.MouseButton1Click:Connect(function()

        value = not value

        Update()

        if callback then
            callback(value)
        end

    end)

    Update()

    return button
end

--========================================================
-- FARM PAGE
--========================================================

local FarmBox, FarmContainer =
    Groupbox(FarmPage, "Auto Farm")

local Status = Create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 22),
    BackgroundTransparency = 1,
    Text = "Status: OFF",
    TextColor3 = Color3.fromRGB(220, 90, 90),
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, FarmContainer)

local FarmButton

FarmButton = Button(FarmContainer, "START AUTO FARM", function()

    AutoFarm = not AutoFarm

    if AutoFarm then

        FarmButton.Text = "STOP AUTO FARM"

        Status.Text = "Status: RUNNING"
        Status.TextColor3 =
            Color3.fromRGB(90, 210, 110)

        AddLog("Auto Farm ON")

    else

        FarmButton.Text = "START AUTO FARM"

        Status.Text = "Status: OFF"
        Status.TextColor3 =
            Color3.fromRGB(220, 90, 90)

        AddLog("Auto Farm OFF")

    end

end)

--========================================================
-- PACK FILTER PAGE
--========================================================

local FilterBox, FilterContainer =
    Groupbox(FilterPage, "Pack Filter")

local Dropdown = Create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 0, 260),
    BackgroundColor3 = Color3.fromRGB(17, 17, 21),
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y
}, FilterContainer)

AddCorner(Dropdown, 5)

Create("UIListLayout", {
    Padding = UDim.new(0, 4)
}, Dropdown)

Create("UIPadding", {
    PaddingTop = UDim.new(0, 5),
    PaddingBottom = UDim.new(0, 5),
    PaddingLeft = UDim.new(0, 5),
    PaddingRight = UDim.new(0, 5)
}, Dropdown)

--========================================================
-- FILTER UI
--========================================================

local function UpdatePackButton(button, packName)

    if SelectedPacks[packName] then

        button.Text = "✓  " .. packName

        button.BackgroundColor3 =
            Color3.fromRGB(55, 90, 65)

    else

        button.Text = packName

        button.BackgroundColor3 =
            Color3.fromRGB(38, 38, 44)

    end

end

local function RebuildPackFilter()

    for _, child in ipairs(Dropdown:GetChildren()) do

        if child:IsA("TextButton") then
            child:Destroy()
        end

    end

    local names = {}

    for name in pairs(DetectedPacks) do
        table.insert(names, name)
    end

    table.sort(names)

    for _, packName in ipairs(names) do

        local button = Create("TextButton", {
            Size = UDim2.new(1, -10, 0, 30),
            BackgroundColor3 = Color3.fromRGB(38, 38, 44),
            BorderSizePixel = 0,
            Text = packName,
            TextColor3 = Color3.fromRGB(215, 215, 220),
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false
        }, Dropdown)

        AddCorner(button, 4)

        Create("UIPadding", {
            PaddingLeft = UDim.new(0, 8)
        }, button)

        UpdatePackButton(button, packName)

        button.MouseButton1Click:Connect(function()

            if SelectedPacks[packName] then
                SelectedPacks[packName] = nil
            else
                SelectedPacks[packName] = true
            end

            UpdatePackButton(button, packName)

            AddLog(
                (SelectedPacks[packName] and "Selected: "
                    or "Unselected: ")
                .. packName
            )

        end)

    end

end

--========================================================
-- REFRESH PACKS
--========================================================

local function RefreshPacks()

    AddLog("Refreshing packs...")

    local success, result = pcall(function()

        return RequestConveyorOffer:InvokeServer(1)

    end)

    if not success then

        AddLog("Refresh failed")

        warn(result)

        return

    end

    if typeof(result) ~= "table" then

        AddLog("Invalid refresh data")

        return

    end

    -- Lưu danh sách cũ để phát hiện pack mới
    local oldPacks = {}

    for name in pairs(DetectedPacks) do
        oldPacks[name] = true
    end

    -- Chỉ cập nhật danh sách phát hiện
    -- KHÔNG đụng SelectedPacks
    table.clear(DetectedPacks)

    for _, offer in pairs(result) do

        if typeof(offer) == "table" then

            local packName = offer.PackName

            if packName then
                DetectedPacks[tostring(packName)] = true
            end

        end

    end

    local count = 0

    for name in pairs(DetectedPacks) do

        count += 1

        if not oldPacks[name] and next(oldPacks) ~= nil then
            AddLog("NEW PACK: " .. name)
        end

    end

    RebuildPackFilter()

    AddLog("Refresh complete: " .. count .. " pack(s)")

end

--========================================================
-- REFRESH PAGE
--========================================================

local RefreshBox, RefreshContainer =
    Groupbox(RefreshPage, "Pack Refresh")

Button(
    RefreshContainer,
    "REFRESH PACKS",
    RefreshPacks
)

Toggle(
    RefreshContainer,
    "AUTO REFRESH PACKS",
    false,
    function(value)

        AutoRefresh = value

        AddLog(
            value
            and "Auto Refresh ON"
            or "Auto Refresh OFF"
        )

    end
)

Button(
    RefreshContainer,
    "CLEAR FILTER",
    function()

        table.clear(SelectedPacks)

        RebuildPackFilter()

        AddLog("Pack filter cleared")

    end
)

--========================================================
-- LOG PAGE
--========================================================

local LogBox, LogContainer =
    Groupbox(LogsPage, "Logs")

LogText = Create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 230),
    BackgroundColor3 = Color3.fromRGB(16, 16, 20),
    BorderSizePixel = 0,
    Text = "",
    TextColor3 = Color3.fromRGB(205, 205, 210),
    TextSize = 11,
    Font = Enum.Font.Code,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextWrapped = true
}, LogContainer)

AddCorner(LogText, 5)

Button(
    LogContainer,
    "CLEAR LOG",
    ClearLogs
)

--========================================================
-- BUY / ROLL
--========================================================

local function HasSelectedPack()

    for _ in pairs(SelectedPacks) do
        return true
    end

    return false

end

local function BuyAndRoll()

    if not HasSelectedPack() then
        AddLog("No pack selected")
        return
    end

    local success, result = pcall(function()

        return RequestConveyorOffer:InvokeServer(1)

    end)

    if not success then

        AddLog("Offer request failed")

        return

    end

    if typeof(result) ~= "table" then

        AddLog("Invalid offer")

        return

    end

    for _, offer in pairs(result) do

        if typeof(offer) ~= "table" then
            continue
        end

        local packName = offer.PackName
        local mutation = offer.Mutation
        local offerId = offer.OfferId

        if not packName or not offerId then
            continue
        end

        --================================================
        -- FILTER CHỈ HOẠT ĐỘNG Ở ĐÂY
        --================================================

        if SelectedPacks[tostring(packName)] then

            AddLog("Buying: " .. tostring(packName))

            local buySuccess = pcall(function()

                BuyPack:FireServer(
                    packName,
                    mutation,
                    offerId
                )

            end)

            if not buySuccess then

                AddLog("BuyPack failed")

                return

            end

            task.wait(0.5)

            pcall(function()

                SetRecoverPack:FireServer(
                    offerId
                )

            end)

            AddLog(
                "Rolled: "
                .. tostring(packName)
                .. " | "
                .. tostring(mutation)
            )

            return

        end

    end

end

--========================================================
-- AUTO FARM LOOP
--========================================================

task.spawn(function()

    while Gui.Parent do

        if AutoFarm then

            local success, errorMessage =
                pcall(BuyAndRoll)

            if not success then
                warn(errorMessage)
            end

            task.wait(RollDelay)

        else

            task.wait(0.2)

        end

    end

end)

--========================================================
-- AUTO REFRESH LOOP
--========================================================

task.spawn(function()

    while Gui.Parent do

        if AutoRefresh then

            pcall(RefreshPacks)

            task.wait(10)

        else

            task.wait(0.5)

        end

    end

end)

--========================================================
-- INITIAL REFRESH
--========================================================

task.spawn(function()

    task.wait(1)

    pcall(RefreshPacks)

    AddLog("Pornhub loaded")

end)
