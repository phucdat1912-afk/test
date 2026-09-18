local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Logs = {}

local function Log(...)
    local s = table.concat({...}, " ")
    print(s)
    table.insert(Logs, s)
end

local function Copy()
    local text = table.concat(Logs, "\n")

    if setclipboard then
        setclipboard(text)
        print("========== LOG COPIED ==========")
    elseif toclipboard then
        toclipboard(text)
        print("========== LOG COPIED ==========")
    end
end

Log("========== 3X BUTTON MONITOR ==========")

local GameSpeed =
    Player.PlayerGui
    :WaitForChild("Frames")
    :WaitForChild("InfiniteBattle")
    :WaitForChild("GameSpeed")

local Buttons = {
    GameSpeed:FindFirstChild("Speed1x"),
    GameSpeed:FindFirstChild("Speed2x"),
    GameSpeed:FindFirstChild("Speed3x")
}

for _, Button in ipairs(Buttons) do
    if Button then

        Log(
            "[FOUND]",
            Button:GetFullName(),
            "Text=" .. tostring(Button.Text)
        )

        Button.MouseButton1Click:Connect(function()

            Log(
                "[CLICK]",
                Button:GetFullName(),
                "Text=" .. tostring(Button.Text)
            )

            -- Scan values/state immediately after click
            task.wait(0.1)

            for _, obj in ipairs(GameSpeed:GetDescendants()) do

                if obj:IsA("TextLabel")
                or obj:IsA("TextButton")
                or obj:IsA("IntValue")
                or obj:IsA("NumberValue")
                or obj:IsA("BoolValue")
                or obj:IsA("StringValue") then

                    local value = ""

                    pcall(function()
                        if obj:IsA("TextLabel")
                        or obj:IsA("TextButton") then
                            value = obj.Text
                        else
                            value = tostring(obj.Value)
                        end
                    end)

                    Log(
                        "[STATE]",
                        obj:GetFullName(),
                        "=",
                        tostring(value)
                    )
                end

            end

            Copy()
        end)
    end
end

Log("========== READY ==========")
Log("Bấm 2x rồi 3x để monitor...")
