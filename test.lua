local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Gui = Player:WaitForChild("PlayerGui")

local result = {}

local keywords = {
    "conveyor",
    "pack",
    "card",
    "offer",
    "refresh"
}

local function match(name)
    name = string.lower(name)

    for _,word in ipairs(keywords) do
        if string.find(name, word, 1, true) then
            return true
        end
    end

    return false
end

for _,obj in ipairs(Gui:GetDescendants()) do
    if match(obj.Name) then

        local line =
            obj:GetFullName()
            .. " | "
            .. obj.ClassName

        table.insert(result,line)

        if obj:IsA("TextLabel")
            or obj:IsA("TextButton")
            or obj:IsA("TextBox") then

            table.insert(
                result,
                "    TEXT = "
                .. tostring(obj.Text)
            )
        end
    end
end

local output = table.concat(result,"\n")

print(output)

pcall(function()
    setclipboard(output)
end)

print("===== COPIED =====")
